using System;
using System.Collections;
using System.Management.Automation;
 
namespace GetAdmin
{
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

        public static Net Parse(string value)
        {
            if (string.IsNullOrEmpty(value))
              throw new ArgumentNullException("value");;
            GetAdmin.Net n = new GetAdmin.Net();
            //"ns0,192.168.1.1,255.255.255.0"
            // TODO tests -> "ns0,,", ",,255.255.255.0" ,",192.," ...
            string[] Fields = value.Split(new char[1] { ',' });
            if (Fields.GetLength(0) != 3)
            {
              throw new ArgumentOutOfRangeException("value must contains 3 fields");
            }
            n.Interface  = Fields[0];
            n.IPAddress  = System.Net.IPAddress.Parse(Fields[1]);
            n.Netmask    = Fields[2];
            
            return n;
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
