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
