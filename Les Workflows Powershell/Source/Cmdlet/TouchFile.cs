using System;
using System.IO;
using System.Management.Automation;
using System.Collections.ObjectModel;

namespace PSBook.Chapter4
{
  //from : 
  // http://www.wrox.com/WileyCDA/WroxTitle/Professional-Windows-PowerShell-Programming-Snapins-Cmdlets-Hosts-and-Providers.productCd-0470173939.html
  //Touch-File
    [Cmdlet("Update", "FileLastWriteTime", DefaultParameterSetName = "Path")]
    public class UpdateFileLastWriteTimeCommand : PSCmdlet
    {
        private string path = null;

        [Parameter(ParameterSetName = "Path", Mandatory = true, Position = 1,
            ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty]
        [Alias("FullName")]
        public string Path
        {
            get
            {
                return path;
            }
            set
            {
                path = value;
            }
        }

        private FileInfo fileInfo = null;

        [Parameter(ParameterSetName = "FileInfo", Mandatory = true, Position = 1,
            ValueFromPipeline = true)]
        public FileInfo FileInfo
        {
            get
            {
                return fileInfo;
            }
            set
            {
                fileInfo = value;
            }
        }

        DateTime date = DateTime.Now;

        [Parameter]
        public DateTime Date
        {
            get
            {
                return date;
            }
            set
            {
                date = value;
            }
        }

        protected override void ProcessRecord()
        {
            if (fileInfo != null)
            {
                TouchFile(fileInfo);
                return;
            }

            ProviderInfo provider = null;
            Collection<String> resolvedPaths = GetResolvedProviderPathFromPSPath(path, 
                                                   out provider);

            foreach (string resolvedPath in resolvedPaths)
            {
                if (File.Exists(resolvedPath))
                {
                    FileInfo myFileInfo = new FileInfo(resolvedPath);
                    TouchFile(myFileInfo);
                }
                else
                {
                    string message = String.Format("File '{0}' is not found", 
                                                   resolvedPath);
                    ArgumentException ae = new ArgumentException(message);

                    ErrorRecord errorRecord = new ErrorRecord(ae,
                        "FileNotFound",
                        ErrorCategory.ObjectNotFound,
                        resolvedPath);

                    WriteError(errorRecord);
                    return;
                }
            }
        }

        private void TouchFile(FileInfo myFileInfo)
        {
            if (myFileInfo != null)
            {
                if (this.ShouldProcess(myFileInfo.FullName, 
                                       "set last write time to be " + date.ToString()))
                {
                    try
                    {
                        myFileInfo.LastWriteTime = date;
                    }
                    catch (UnauthorizedAccessException uae)
                    {
                        ErrorRecord errorRecord = new ErrorRecord(uae,
                            "UnauthorizedFileAccess",
                            ErrorCategory.PermissionDenied,
                            myFileInfo.FullName);

                        string detailMessage = String.Format("Not able to touch file '{0}'. Please check whether it is readonly.", 
                                        myFileInfo.FullName);

                        errorRecord.ErrorDetails = new ErrorDetails(detailMessage);

                        WriteError(errorRecord);
                        return;
                    }

                    WriteObject(myFileInfo);
                }
            }
        }
    }
}