using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;

namespace Synthetique
{
    public class MembresEtendus
    {
         //méthode privée
        static double ConvertExposant(PSObject ObjetPS)
        {
            if (ObjetPS.Properties["Exposant"].Value is PSObject)
             { return Convert.ToDouble((ObjetPS.Properties["Exposant"].Value as PSObject).BaseObject); }

            return Convert.ToDouble(ObjetPS.Properties["Exposant"].Value);

        }
        public static double Puissance (PSObject ObjetPS)                          
        {
            Double x = Convert.ToDouble(ObjetPS.BaseObject);
            return Math.Pow(x, MembresEtendus.ConvertExposant(ObjetPS));
        }

        public static double ExposantGet (PSObject ObjetPS)                          
        {
            return MembresEtendus.ConvertExposant(ObjetPS);
	    }

	    public static void ExposantSet (PSObject ObjetPS,  double valeur)                          
        {
            ObjetPS.Properties["Exposant"].Value= valeur;
	    }

    }
}
