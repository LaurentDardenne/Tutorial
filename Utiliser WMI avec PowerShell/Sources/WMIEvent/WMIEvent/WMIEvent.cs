using System;
using System.Diagnostics;
using System.Management;
using System.Configuration.Install;
using System.Management.Instrumentation;

// Précise l'espace de nom WMI où est déclaré l'événement
[assembly:Instrumented("Root/Default")]

// On utilise InstallUtil.exe pour installer l'assembly
[System.ComponentModel.RunInstaller(true)]
public class MyInstaller : 
    DefaultManagementProjectInstaller {}   

namespace WMIEvent
{
    // Ebauche d'une hiérarchie d'événements WMI
    //Laurent Dardenne 30/06/09
    // http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/Utiliser-WMI-avec-PowerShell/

    #region PoshTransmissionActor
    /// <summary>
    /// Défini le type de l'émetteur d'un événement. 
    /// Soit une instance de PowerShell.exe (PowerShell).
    /// Soit un host PowerShell(Hosting). Par exemple une application .NET utilisant le hosting de PowerShell. 
    /// Soit un runspace(Runspace) d'un host PowerShell.
    /// Soit une source inconnue (Unknown), une application n'utilisant pas les API PowerShell.
    /// </summary>
    public enum PoshTransmissionActor
    {
     Unknown =1,
     PowerShell,
     Runspace,
     Hosting  
    }
    #endregion
    #region PoshRole
    /// <summary>
    /// Défini le rôle de l'émetteur d'un événement. 
    /// </summary>
    public enum PoshRole
    {
        Transmitter = 1,
        Receiver
    }
        #endregion

    #region PoshOperationEventArgumentException
    /// <summary>
    /// Un des arguments d'un des constructeurs de la hiérarchie PoshOperationEvent n'est pas valide.
    /// </summary>
    public class PoshOperationEventArgumentException : System.ArgumentException
    {
        public PoshOperationEventArgumentException(String message)
            : base(message)
        {
        }
        public PoshOperationEventArgumentException(String message, Exception inner)
            : base(message, inner)
        {
        }
    } 
    #endregion


    #region PoshOperationEvent

    /// <summary>
    /// Classe d'événement WMI managé dédié à PowerShell.
    /// On ne connait que l'émetteur de l'événement (échange simplex)
    /// </summary>
    public class PoshOperationEvent :
        System.Management.Instrumentation.BaseEvent
    {

        /// <summary>
        /// Type de l'émetteur de l'événement.
        /// </summary>
        protected PoshTransmissionActor actor;
        public int Actor
        {
            get { return (int)actor; }
        }

        /// <summary>
        /// Numéro du process émetteur de cet événement.
        /// </summary>
        //IntPtr : type inconnu sous WMI. On utilise le constructeur IntPtr(Int32)
        protected Int32 processID;
        public Int32 ProcessID
        {
            get { return processID; }
        }

        /// <summary>
        /// Numéro du runspace Powershell à partir du quel cet événement a été émis.
        /// </summary>
        //Guid : type inconnu sous WMI. On utilise le constructeur Guid(Byte[])
        protected Byte[] runspaceInstanceId;

        public Byte[] RunspaceInstanceId
        {
            get { return runspaceInstanceId; }
        }


        /// <summary>
        /// Nom de l'événement.
        /// </summary>
        protected String eventName;
        public string EventName
        {
            get { return this.eventName; }
        }
        /// <summary>
        /// Constructeur par défaut.
        /// </summary>
        /// <param name="EventName">Nom de l'événement</param>
        /// <param name="ProcessHandle">Handle du process à partir du quel est émis l'événement.
        /// Par défaut dans PowerShell.exe on utilisera la variable :
        ///  $PID
        /// </param>
        /// <param name="InstanceId">Identifiant du runspace à partir du quel est émis l'événement. 
        /// Par défaut dans PowerShell.exe on utilisera la variable :
        ///  ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID
        /// </param>
        /// <remarks>
        /// Par défaut le membre actor_T est initialisé avec la valeur PoshTransmissionActor.Unknown.
        /// </remarks>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le handle de process xx n'existe pas.</exception>
        public PoshOperationEvent(String EventName, Int32 ProcessHandle, Guid InstanceId)
        {
            ValidateProcessHandle(ProcessHandle);
            this.eventName = EventName;
            this.processID= ProcessHandle;
            this.runspaceInstanceId=InstanceId.ToByteArray();
            this.actor = PoshTransmissionActor.Unknown;
        }

        /// <summary>
        /// Constructeur permettant de définir le type de l'émetteur de l'événement.
        /// </summary>
        /// <param name="TransmitterActor">Type de l'émetteur de l'événement.</param>
        /// <remarks>
        /// Si le paramètre TransmissionActor à pour valeur PoshTransmissionActor.Runspace alors le paramètre InstanceId doit être renseigné.
        /// </remarks>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">[Rôle xx]Le paramètre RunspaceInstanceId est un GUID vide, il doit être renseigné.</exception>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le handle de process xx n'existe pas.</exception>
        public PoshOperationEvent(String EventName,
                                  Int32 ProcessHandle,
                                  Guid InstanceId,
                                  PoshTransmissionActor TransmissionActor)
            :this(EventName, ProcessHandle, InstanceId)
        {
            ValidateActor(TransmissionActor,this.runspaceInstanceId);
            this.actor = TransmissionActor;
        }


        /// <summary>
        /// Valide la cohérence entre Actor et RunspaceInstanceId.
        /// Si on indique que le type de l'acteur est un runspace alors RunspaceInstanceId doit être renseigné.
        /// Sinon on ne pourra pas retrouver le runspace concerné.
        /// </summary>
        /// <param name="Informations">Données de l'événement à valider.</param>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le paramètre RunspaceInstanceId est un GUID vide, il doit être renseigné.</exception>
        protected void ValidateActor(PoshTransmissionActor Actor, Byte[] RunspaceID)
        {
            if (Actor == PoshTransmissionActor.Runspace)
            {
                Guid guid = new Guid(RunspaceID);
                if (guid == Guid.Empty)
                {
                    throw new PoshOperationEventArgumentException("Le paramètre RunspaceInstanceId est un GUID vide, il doit être renseigné.");
                }
            }
        }

        /// <summary>
        /// Valide le numéro de handle d'un process.
        /// Le process peut ne pas ou ne plus exister lors de l'envoi du message.
        /// </summary>
        /// <param name="ProcessHandle">Handle du process à valider.</param>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le handle de process xx n'existe pas.</exception>
        protected static void ValidateProcessHandle(Int32 ProcessHandle)
        {
            if (Process.GetProcessById(ProcessHandle) == null)
            {
                throw new PoshOperationEventArgumentException(String.Format("Le handle de process {0} n'existe pas.", ProcessHandle));
            }
        }
    }
    #endregion
    #region  PoshJobCompletedEvent
    /// <summary>
    /// Classe d'événement WMI notifiant une fin de traitement effectué au sein d'un runspace.
    /// Le membre Transmitter.Actor est égal à PoshTransmissionActor.Runspace
    /// </summary>
    public class PoshJobCompletedEvent : PoshOperationEvent
    {
        public PoshJobCompletedEvent(String EventName, Int32 ProcessHandle, Guid InstanceId)
            : base(EventName, ProcessHandle, InstanceId, PoshTransmissionActor.Runspace)
        {
        }
    }

        #endregion

    #region  PoshStopWatchingEvent
    /// <summary>
    /// Classe d'événement WMI notifiant une demande d'arrêt de la surveillance de l'event EventName.
    /// </summary>
    public class PoshStopWatchingEvent : PoshOperationEvent
    {
        public PoshStopWatchingEvent(String EventName, Int32 ProcessHandle, Guid InstanceId, PoshTransmissionActor Transmitter)
            : base(EventName, ProcessHandle, InstanceId, Transmitter)
        {
        }
    }

    #endregion

    #region  PoshOperationEventRcvr
    /// <summary>
    /// Classe d'événement WMI managé dédié à PowerShell.
    /// On connaît l'émetteur et le récepteur de l'événement (échange "simili half-duplex")
    /// </summary>
    /// <exception cref="WMIEvent.PoshOperationEventArgumentException">[Rôle xx]Le paramètre RunspaceInstanceId est un GUID vide, il doit être renseigné.</exception>
    /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le handle de process xx n'existe pas.</exception>
    public class PoshOperationEventRcvr : PoshOperationEvent
    {
        /// <summary>
        /// Information concernant le destinataire de cet événement.
        /// </summary>
        /// <summary>
        /// Type du récepteur de l'événement.
        /// </summary>
        protected PoshTransmissionActor actor_R;
        public int Actor_R
        {
            get { return (int)actor_R; }
        }

        /// <summary>
        /// Numéro du process récepteur de cet événement.
        /// </summary>
        //IntPtr : type inconnu sous WMI. On utilise le constructeur IntPtr(Int32)
        protected Int32 processID_R;
        public Int32 ProcessID_R
        {
            get { return processID_R; }
        }

        /// <summary>
        /// Numéro du runspace Powershell à partir du quel cet événement a été émis.
        /// </summary>
        //Guid : type inconnu sous WMI. On utilise le constructeur Guid(Byte[])
        protected Byte[] runspaceInstanceId_R;
        public Byte[] RunspaceInstanceId_R
        {
            get { return runspaceInstanceId_R; }
        }


        public PoshOperationEventRcvr(String EventName, Int32 ProcessHandle, Guid InstanceId, PoshTransmissionActor Transmitter,
                                      Int32 R_ProcessHandle, Guid R_InstanceId, PoshTransmissionActor Receiver)
            : base(EventName, ProcessHandle, InstanceId, Transmitter)
        {
            ValidateProcessHandle(processID_R);
            this.processID_R = R_ProcessHandle;
            this.runspaceInstanceId_R = R_InstanceId.ToByteArray();
            ValidateActor(Receiver, this.runspaceInstanceId_R);
            this.actor_R = Receiver;
            
        }
    }
    #endregion
    #region  PoshJobCompletedEvent
    /// <summary>
    /// Classe d'événement WMI notifiant une fin de traitement effectué au sein d'un runspace.
    /// Le membre Transmitter.Actor est égal à PoshTransmissionActor.Runspace
    /// </summary>
    public class PoshJobCompletedEventRcvr : PoshOperationEventRcvr
    {
        public PoshJobCompletedEventRcvr(String EventName, Int32 ProcessHandle, Guid InstanceId, PoshTransmissionActor Transmitter,
                                         Int32 R_ProcessHandle, Guid R_InstanceId, PoshTransmissionActor Receiver)
            : base(EventName, ProcessHandle, InstanceId, Transmitter,R_ProcessHandle, R_InstanceId, Receiver)
        {
        }
    }

        #endregion

    #region  PoshStopWatchingEventRcvr
    /// <summary>
    /// Classe d'événement WMI notifiant une demande d'arrêt de la surveillance de l'event EventName.
    /// </summary>
    public class PoshStopWatchingEventRcvr : PoshOperationEventRcvr
    {
        public PoshStopWatchingEventRcvr(String EventName, Int32 ProcessHandle, Guid InstanceId, PoshTransmissionActor Transmitter,
                                         Int32 R_ProcessHandle, Guid R_InstanceId, PoshTransmissionActor Receiver)
            : base(EventName, ProcessHandle, InstanceId, Transmitter, R_ProcessHandle, R_InstanceId, Receiver)
        {
        }
    }
    #endregion
}
