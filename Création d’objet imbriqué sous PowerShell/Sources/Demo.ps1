$path='Votre_Répertoire_Des_Sources'
Write-Warning "Modifiez le path"
return

ipmo "$path\PsObjectHelper.psm1"

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
            Informations= new PSObject();
            roinformations= new PSObject();
        }


        private readonly string nom;
        public string Nom
        {
            get { return nom; }
        }

        private readonly PSObject roinformations;
        public PSObject ROInformations
        {
            get { return roinformations; }
        }
        
        public PSObject Informations; 
    }
}
"@

Add-Type $Code
$Personne=New-Object ClassesPS.Personne 'Dupont'
$Personne
# Nom                                     ROInformations                          Informations
# ---                                     --------------                          ------------
# Dupont

$Personne.Informations -eq $null
# false
$Personne.ROInformations -eq $null
# false

$Personne.ROInformations=New-Object PSObject
# . : « ROInformations » est une propriété ReadOnly.

$Personne.ROInformations.PSObject.Properties.Add( (New-PSVariableProperty 'Age' 25 -ReadOnly) )
$Personne
# Nom                                     ROInformations                          Informations
# ---                                     --------------                          ------------
# Dupont                                  @{Age=25}

$Personne.ROInformations.Age=20
# . : Impossible de remplacer la variable Age, car elle est constante ou en lecture seule.

$Personne.Informations.PSObject.Properties.Add( (New-PSVariableProperty 'Adresse' '25 chemin des Dames' -ReadOnly) )
$Personne
# Nom                                     ROInformations                          Informations
# ---                                     --------------                          ------------
# Dupont                                  @{Age=25}                               @{Adresse= 25 chemin des Dames}
# 
$Personne.Informations.Adresse=$null
# . : Impossible de remplacer la variable Adresse, car elle est constante ou en lecture seule.

#La propriété info peut être réaffectée:

$Personne.Informations=New-Object 'ClassesPS.Personne' 'Durant'

#Pour contraindre sur le type des objets autorisés, on peut utiliser un attribut mais celui-ci peut être supprimé.

#Dans une nouvelle session 
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
        /// <param name="psobject">Instance d'un objet Personne adapté.</param>
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
 
 #Compile le code ou charge une dll
Add-Type $Code
$Personne=New-Object 'ClassesPS.Personne' 'Dupont'
$Personne

# Crée les accesseurs CodeProperty
$InformationGetter=[ClassesPS.AdapterCodeProperty].GetMethod('DatasGet')
$InformationSetter=[ClassesPS.AdapterCodeProperty].GetMethod('DatasSet')
Add-Member -InputObject $Personne -MemberType CodeProperty -Name Informations -Value $InformationGetter -SecondValue $InformationSetter

$Personne.Informations.PSObject.Properties.Add( (New-PSVariableProperty 'Adresse' '25 chemin des Dames') )

$Personne.Informations=$null
$Personne.Informations=10
$Personne.Informations=new-object psobject -Property @{Age=25}
