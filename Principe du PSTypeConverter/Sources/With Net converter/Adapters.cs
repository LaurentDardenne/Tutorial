﻿using System;
using System.Diagnostics;
using System.Collections;
using System.Management.Automation;
 
namespace GetAdmin
{
    public class NetConverter : PSTypeConverter
    {
        public override bool CanConvertFrom(Object sourceValue, Type destinationType)
        {
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

        public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider provider, bool IgnoreCase)
        {
            if (sourceValue == null)
                throw new InvalidCastException("no conversion possible");
            if (this.CanConvertFrom(sourceValue, destinationType))
            {
                try
                {
                    // Cast our input as a string just in case
                    string src = sourceValue as string;
                    // create a new GetAdmin.Net object
                    GetAdmin.Net n = new GetAdmin.Net();
 
                    if (src != null || src != "")
                    {
                        //split our string into an array using commas as the delim
                        string[] Fields = src.Split(new char[1] { ',' });
 
                        //populate our new object
                        n.Interface  = Fields[0];
                        n.IPAddress  = System.Net.IPAddress.Parse(Fields[1]);
                        n.Netmask    = Fields[2];
                    }
                    return n;
                }
                catch (Exception)
                {
                    throw new InvalidCastException("no conversion possible");
                }
            }
            throw new InvalidCastException("no conversion possible");
        }
        /// Default to PowerShell conversion for other types.
        /// Return False here
        public override bool CanConvertTo(object Value, Type destinationType)
        {
            return false;
        }
        /// Do not handle conversion for other types
        public override object ConvertTo(object Value, Type destinationType,
        IFormatProvider provider, bool IgnoreCase)
        {
            throw new InvalidCastException("conversion failed");
        }
    }

    public class Net
    {

        public string Interface { get; set; }
        public System.Net.IPAddress IPAddress { get; set; }
        public string Netmask { get; set; } 


        public Net()
        {
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
            Name    = null;
            Network = new ArrayList();
        }
        public Server(
            string name,
            ArrayList network
        )
        {
            Name    = name;
            Network = network;
        }
    }
}
