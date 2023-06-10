$Code=@"
using System;
using System.Management.Automation;

namespace ClassesPS
{
    public class Personne
    {
        public Personne(String aNom)
        {
            nom= aNom;
            Datas= new PSObject();
        }

        private readonly string nom;
        public string Nom
        {
            get { return nom; }
        }

        protected internal PSObject Datas; 
    }

    /// CodeProperty associée à une propriété d'un objet Powershell (PSObject).
    public class AdapterCodeProperty
    {

        /// <summary>
        /// Getter de la propriété 'Datas'.
        /// </summary>
        /// <param name="psobject">Instance de la classe Personne adaptée.</param>
        /// <returns>L'objet contenu dans la propriété Datas.</returns>
        /// <remarks>Le type de l'objet renvoyé par le getter doit être du même type que celui du paramètre value du setter.</remarks>
        public static Object DatasGet(PSObject psobject)
        {
            return ((Personne)psobject.BaseObject).Datas;
        }

        /// <summary>
        /// Setter de la propriété 'Datas'. La valeur à affecter est transformée en PSObject si ce n'est pas déjà le cas.
        /// </summary>
        /// <param name="psobject">Instance de la classe Personne adaptée.</param>
        /// <param name="value">Valeur à assigner à la propriété Datas.</param>
        /// <remarks>Le type paramètre value doit être le même que celui renvoyé par le getter.</remarks>
        public static void DatasSet(PSObject psobject, Object value)
        {
            //L'objet imbriqué peut être manipulé par ailleurs
            if ((psobject == null) || (psobject.BaseObject == null) ) 
             throw new ArgumentNullException();
             
             //Régle de gestion
            if  (value == null)  
             throw new ArgumentNullException();

              //On s'assure de tjr manipuler un PSObject
            ((Personne)psobject.BaseObject).Datas=PSObject.AsPSObject(value); 
        }
    }
}
"@

Add-Type $Code
Import-Module "$pwd\PSObjectHelper.psm1"
