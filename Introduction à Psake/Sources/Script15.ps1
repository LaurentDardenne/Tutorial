#!!!! 
#Ceci est un script Powershell, pas un script PSake

#Par défaut Invoke-Psake exécute la tache nommée 'default'
#On peut exécuter + taches
Invoke-psake .\Script16.ps1 -taskList build,Autonome,Build2

#Ici ces tâches référencent chacune des tâches déjà exécutées
#Chaque tâche est exécutée une seule fois.
Invoke-psake .\Script16.ps1 -taskList Autonome,build2,Build2