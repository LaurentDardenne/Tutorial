﻿ConvertFrom-StringData @' 
 "Les noms d'alias de paramétre ('$SearchedParameter') ne sont pas prise en charge. Utilisez le nom primaire : '$SearchedParameterAlias'."
          Write-Error "Le paramétre '$SearchedParameter' n'est pas un nom de paramètre valide de la commande '$CommandName'." 
 ParameterStringEmpty=Le paramètre '{0}' ne peut être une chaîne vide.
 PathMustExist=Le nom de chemin n'existe pas : {0}
 PathIsNotAFile=Le chemin ne référence pas un fichier ou le chemin est invalide : {0}  
 ValueNotSupported=La valeur '{0}' n'est pas supportée par PSIonic.
 TypeNotSupported={0}: le type '{1}' n'est pas supporté.
 CommentMaxValue=Le contenu du paramètre 'Comment' ne doit pas excéder 32767 caractères.   
 
 isBadPasswordWarning=Mot de passe invalide pour l'archive {0}
 ZipArchiveBadPassword=Mot de passe incorrect pour l'extraction de l'archive {0}
 InvalidPasswordForDataEncryptionValue=La valeur du paramètre Password ('{0}') est invalide pour la valeur de DataEncryption '{1}'.
 ZipArchiveCheckPasswordError=Erreur lors du contrôle de mot de passe sur l'archive {0} : {1}
  
 AddEntryError=Impossible d'ajouter l'élement '{0}' dans l'archive '{1}' : {2}
 EntryIsNull=L'entrée '{0}' est `$null.
 ExpandZipEntryError=L'entrée nommée '{0}' n'existe pas dans l'archive '{1}'
 
 RemoveEntryError=Impossible de supprimer l'élement '{0}' dans l'archive '{1}', car il n'existe pas.
 RemoveEntryNullError=L'argument reçu est null. Archive concernée '{0}'
 
 ZipArchiveReadError=Une erreur s'est produite lors de la lecture de l'archive {0} : {1}
 ZipArchiveExtractError=Une erreur s'est produite lors de l'extraction de l'archive {0} : {1}
 ZipArchiveCheckIntegrityError=Erreur lors du contrôle d'intégrité de l'archive {0} : {1}
 isCorruptedZipArchiveWarning=Archive corrompue : {0}
 
 TestisArchiveError=Erreur lors du test de l'archive {0} : {1}
 isNotZipArchiveWarning=Le fichier n'est pas une archive Zip : {0}
 
 ExcludedObject=L'objet courant n'est pas une instance du type System.IO.FileInfo : {0}
 IsNullOrEmptyArchivePath=Le nom de fichier est vide ou ToString() a renvoyée une chaîne vide.
 ItemNotFound=Impossible de trouver le chemin d'accès '{0}', car il n'existe pas.
 EmptyResolve=La résolution ne trouve pas de fichier.
 PathNotInEntryPathRoot=Le chemin n'est pas dans l'arborescence racine : {0}
 UnableToConvertEntryRootPath=Impossible de convertir le chemin racine : {0}
 FromPathEntryNotFound=Impossible de trouver le chemin d'accès '{0}' dans l'archive '{1}', car il n'existe pas.
 
 ThisParameterRequiresThisParameter=Le paramètre '{0}' nécessite de déclarer le paramètre '{1}'.
 
 ProgressBarExtract=Extraction en cours
'@ 

