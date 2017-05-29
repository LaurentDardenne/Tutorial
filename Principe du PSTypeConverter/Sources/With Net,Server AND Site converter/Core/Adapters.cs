/*   Adapters.cs                                                               */

using System;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using log4net;
 
namespace GetAdmin
{
 
    public static class Logger
    {
        public static readonly ILog log = Logger.GetLogger("DebugLogger");
        
        public static ILog GetLogger(string name)
        {
           log4net.LogManager.CreateRepository("log4net-default-repository");
           
           string path=System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location)+"\\Log4Net.Config.xml";
           if(log4net.LogManager.GetCurrentLoggers("log4net-default-repository").Length == 0)
           {
             log4net.Repository.ILoggerRepository Repo =log4net.LogManager.GetRepository("log4net-default-repository");
             log4net.Config.XmlConfigurator.Configure(Repo, new System.IO.FileInfo(path));
           }
           return LogManager.GetLogger("log4net-default-repository",name);
        }

        public static void Write(string message)
        {
          log.Info(message);
        }
    }
    
    public class NetConverter : PSTypeConverter
    {
        public override bool CanConvertFrom(object sourceValue, Type destinationType)
        {
            Logger.log.Info("NetConverter.CanConvertFrom");
            string src = sourceValue as string;
            if (src != null)
            {
                try
                {
                    string[] Fields = src.Split(new char[1] { ',' });
                    if (Fields.GetLength(0) == 3)
                    {
                        return true;
                    }
                }
                catch (Exception)
                {
                    return false;
                }
            }
            return false;
        }

        /// Override for the ConvertFrom Method
        public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider provider, bool IgnoreCase)
        {
            Logger.log.Info("NetConverter.ConvertFrom");
            string src = sourceValue as string;
            if (string.IsNullOrEmpty(src))
               throw new InvalidCastException("Null or empty. No conversion possible");
            try
            {
                
                GetAdmin.Net net = new GetAdmin.Net();
                //split our string into an array using commas as the delim
                string[] Fields = src.Split(new char[1] { ',' });

                net.Interface  = Fields[0];
                net.IPAddress  = System.Net.IPAddress.Parse(Fields[1]);
                net.Netmask    = Fields[2];
                return net;
            }
            catch (Exception)
            {
                throw new InvalidCastException("Split. No conversion possible");

            }
        }  
        /// Default to PowerShell conversion for other types.
        /// Return False here
        public override bool CanConvertTo(object Value, Type destinationType)
        {
            Logger.log.Info("NetConverter.CanConvertTo");
            return false;
        }
        /// Do not handle conversion for other types
        public override object ConvertTo(object Value, Type destinationType,
        IFormatProvider provider, bool IgnoreCase)
        {
            Logger.log.Info("NetConverter.ConvertTo");
            throw new InvalidCastException("conversion failed");
        }
    }

    public class ServerConverter : PSTypeConverter
    {
        public override bool CanConvertFrom(PSObject sourceValue, Type destinationType)
        {
          Logger.log.Info("SiteConverter.CanConvertFrom");
          return sourceValue.TypeNames.Contains("Deserialized.GetAdmin.Server");
        }
        public override bool CanConvertFrom(object sourceValue, Type destinationType)
        {
            throw new NotImplementedException();
        }

       
        public override object ConvertFrom(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
        {
            Logger.log.Info("ServerConverter.ConvertFrom");
            if (destinationType == null)
            {
                throw new ArgumentNullException("destinationType");
            }

            if (sourceValue == null)
            {
                throw new PSInvalidCastException("InvalidCastWhenRehydratingFromNull");
            }

            GetAdmin.Server server = new GetAdmin.Server();
            server.Name =sourceValue.Properties["Name"].Value as string;  

            PSObject pso=(PSObject)sourceValue.Properties["Network"].Value;
            server.Network= pso.ImmediateBaseObject as System.Collections.ArrayList;
       
            return server;
       }

       public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new NotImplementedException();
       }


       public override bool CanConvertTo(object sourceValue, Type destinationType)
       {
          Logger.log.Info("ServerConverter.CanConvertTo");
          return false;
       }

       public override bool CanConvertTo(PSObject sourceValue, Type destinationType)
       {
           throw new NotImplementedException();
       }

    
       public override object ConvertTo(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new InvalidCastException();
       }

       public override object ConvertTo(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new NotImplementedException();
       }
    }

    public class SiteConverter : PSTypeConverter
    {
        public override bool CanConvertFrom(PSObject sourceValue, Type destinationType)
        {
          Logger.log.Info("SiteConverter.CanConvertFrom");
          return sourceValue.TypeNames.Contains("Deserialized.GetAdmin.Site");
        }
        public override bool CanConvertFrom(object sourceValue, Type destinationType)
        {
            throw new NotImplementedException();
        }

       
        public override object ConvertFrom(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
        {
            Logger.log.Info("SiteConverter.ConvertFrom");
            if (destinationType == null)
            {
                throw new ArgumentNullException("destinationType");
            }

            if (sourceValue == null)
            {
                throw new PSInvalidCastException("InvalidCastWhenRehydratingFromNull");
            }

            GetAdmin.Site Site = new GetAdmin.Site();
            Site.Name =sourceValue.Properties["Name"].Value as string;  

            PSObject pso=(PSObject)sourceValue.Properties["Servers"].Value;
            Site.Servers= ((ArrayList)pso.ImmediateBaseObject).Cast<Server>().ToList();

            return Site;
       }

       public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new NotImplementedException();
       }


       public override bool CanConvertTo(object sourceValue, Type destinationType)
       {
           Logger.log.Info("SiteConverter.CanConvertTo");
           return false;
       }

       public override bool CanConvertTo(PSObject sourceValue, Type destinationType)
       {
           throw new NotImplementedException();
       }

    
       public override object ConvertTo(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new InvalidCastException();
       }

       public override object ConvertTo(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
       {
           throw new NotImplementedException();
       }
    }

    public class Net
    {

        public string Interface { get; set; }
        public System.Net.IPAddress IPAddress { get; set; }
        public string Netmask { get; set; } 


        public Net()
        {
            Logger.log.Info("ctor Net()");
            Interface = null;
            IPAddress = new System.Net.IPAddress((long)16777343);
            Netmask = null;
        }
        public Net(
            string name,
            System.Net.IPAddress ipaddress,
            string netmask
        )
        {
            Logger.log.Info("ctor Net(1,2,3)");
            Interface = name;
            IPAddress = ipaddress;
            Netmask = netmask;
        }
    }

    public class Server
    {
        public string    Name    { get; set; }
        public ArrayList Network { get; set; } 
 
        public Server()
        {
            Logger.log.Info("ctor Server()");
            Name    = null;
            Network = new ArrayList();
        }
        
        public Server(
            string name,
            ArrayList network
        )
        {
            Logger.log.Info("ctor Server(1,2)");
            Name    = name;
            Network = network;
        }
    }

    public class Site
    {
 
        public string    Name    { get; set; }
        public List<Server> Servers { get; set; } 
 
 
        public Site()
        {
            Logger.log.Info("ctor Site()");
            Name    = null;
            Servers = new List<Server>();
        }

        public Site(
            string name,
            List<Server> servers
        )
        {
            Logger.log.Info("ctor Site(1,2)");
            Name    = name;
            Servers = servers;
        }
    }
}
