using System;
using System.Diagnostics;
using System.Management;
using System.Configuration.Install;
using System.Management.Instrumentation;

// Pr�cise l'espace de nom WMI o� est d�clar� l'�v�nement
[assembly:Instrumented("Root/Default")]

// On utilise InstallUtil.exe pour installer l'assembly
[System.ComponentModel.RunInstaller(true)]
public class MyInstaller : 
    DefaultManagementProjectInstaller {}   

namespace WMIEvent
{
    // Ebauche d'une hi�rarchie d'�v�nements WMI
    //Laurent Dardenne 30/06/09
    // http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/Utiliser-WMI-avec-PowerShell/

    #region PoshTransmissionActor
    /// <summary>
    /// D�fini le type de l'�metteur d'un �v�nement. 
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
    /// D�fini le r�le de l'�metteur d'un �v�nement. 
    /// </summary>
    public enum PoshRole
    {
        Transmitter = 1,
        Receiver
    }
        #endregion

    #region PoshOperationEventArgumentException
    /// <summary>
    /// Un des arguments d'un des constructeurs de la hi�rarchie PoshOperationEvent n'est pas valide.
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
    /// Classe d'�v�nement WMI manag� d�di� � PowerShell.
    /// On ne connait que l'�metteur de l'�v�nement (�change simplex)
    /// </summary>
    public class PoshOperationEvent :
        System.Management.Instrumentation.BaseEvent
    {

        /// <summary>
        /// Type de l'�metteur de l'�v�nement.
        /// </summary>
        protected PoshTransmissionActor actor;
        public int Actor
        {
            get { return (int)actor; }
        }

        /// <summary>
        /// Num�ro du process �metteur de cet �v�nement.
        /// </summary>
        //IntPtr : type inconnu sous WMI. On utilise le constructeur IntPtr(Int32)
        protected Int32 processID;
        public Int32 ProcessID
        {
            get { return processID; }
        }

        /// <summary>
        /// Num�ro du runspace Powershell � partir du quel cet �v�nement a �t� �mis.
        /// </summary>
        //Guid : type inconnu sous WMI. On utilise le constructeur Guid(Byte[])
        protected Byte[] runspaceInstanceId;

        public Byte[] RunspaceInstanceId
        {
            get { return runspaceInstanceId; }
        }


        /// <summary>
        /// Nom de l'�v�nement.
        /// </summary>
        protected String eventName;
        public string EventName
        {
            get { return this.eventName; }
        }
        /// <summary>
        /// Constructeur par d�faut.
        /// </summary>
        /// <param name="EventName">Nom de l'�v�nement</param>
        /// <param name="ProcessHandle">Handle du process � partir du quel est �mis l'�v�nement.
        /// Par d�faut dans PowerShell.exe on utilisera la variable :
        ///  $PID
        /// </param>
        /// <param name="InstanceId">Identifiant du runspace � partir du quel est �mis l'�v�nement. 
        /// Par d�faut dans PowerShell.exe on utilisera la variable :
        ///  ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID
        /// </param>
        /// <remarks>
        /// Par d�faut le membre actor_T est initialis� avec la valeur PoshTransmissionActor.Unknown.
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
        /// Constructeur permettant de d�finir le type de l'�metteur de l'�v�nement.
        /// </summary>
        /// <param name="TransmitterActor">Type de l'�metteur de l'�v�nement.</param>
        /// <remarks>
        /// Si le param�tre TransmissionActor � pour valeur PoshTransmissionActor.Runspace alors le param�tre InstanceId doit �tre renseign�.
        /// </remarks>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">[R�le xx]Le param�tre RunspaceInstanceId est un GUID vide, il doit �tre renseign�.</exception>
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
        /// Valide la coh�rence entre Actor et RunspaceInstanceId.
        /// Si on indique que le type de l'acteur est un runspace alors RunspaceInstanceId doit �tre renseign�.
        /// Sinon on ne pourra pas retrouver le runspace concern�.
        /// </summary>
        /// <param name="Informations">Donn�es de l'�v�nement � valider.</param>
        /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le param�tre RunspaceInstanceId est un GUID vide, il doit �tre renseign�.</exception>
        protected void ValidateActor(PoshTransmissionActor Actor, Byte[] RunspaceID)
        {
            if (Actor == PoshTransmissionActor.Runspace)
            {
                Guid guid = new Guid(RunspaceID);
                if (guid == Guid.Empty)
                {
                    throw new PoshOperationEventArgumentException("Le param�tre RunspaceInstanceId est un GUID vide, il doit �tre renseign�.");
                }
            }
        }

        /// <summary>
        /// Valide le num�ro de handle d'un process.
        /// Le process peut ne pas ou ne plus exister lors de l'envoi du message.
        /// </summary>
        /// <param name="ProcessHandle">Handle du process � valider.</param>
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
    /// Classe d'�v�nement WMI notifiant une fin de traitement effectu� au sein d'un runspace.
    /// Le membre Transmitter.Actor est �gal � PoshTransmissionActor.Runspace
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
    /// Classe d'�v�nement WMI notifiant une demande d'arr�t de la surveillance de l'event EventName.
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
    /// Classe d'�v�nement WMI manag� d�di� � PowerShell.
    /// On conna�t l'�metteur et le r�cepteur de l'�v�nement (�change "simili half-duplex")
    /// </summary>
    /// <exception cref="WMIEvent.PoshOperationEventArgumentException">[R�le xx]Le param�tre RunspaceInstanceId est un GUID vide, il doit �tre renseign�.</exception>
    /// <exception cref="WMIEvent.PoshOperationEventArgumentException">Le handle de process xx n'existe pas.</exception>
    public class PoshOperationEventRcvr : PoshOperationEvent
    {
        /// <summary>
        /// Information concernant le destinataire de cet �v�nement.
        /// </summary>
        /// <summary>
        /// Type du r�cepteur de l'�v�nement.
        /// </summary>
        protected PoshTransmissionActor actor_R;
        public int Actor_R
        {
            get { return (int)actor_R; }
        }

        /// <summary>
        /// Num�ro du process r�cepteur de cet �v�nement.
        /// </summary>
        //IntPtr : type inconnu sous WMI. On utilise le constructeur IntPtr(Int32)
        protected Int32 processID_R;
        public Int32 ProcessID_R
        {
            get { return processID_R; }
        }

        /// <summary>
        /// Num�ro du runspace Powershell � partir du quel cet �v�nement a �t� �mis.
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
    /// Classe d'�v�nement WMI notifiant une fin de traitement effectu� au sein d'un runspace.
    /// Le membre Transmitter.Actor est �gal � PoshTransmissionActor.Runspace
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
    /// Classe d'�v�nement WMI notifiant une demande d'arr�t de la surveillance de l'event EventName.
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
