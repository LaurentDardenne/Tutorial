﻿function Invoke-BackgroundTimer {
    #From http://poshcode.org/5560
    #.Synopsis
    #   An example of how to run a script repeatedly on a timer...
    #.Example
    #   Invoke-BackgroundTimer {
    #       Get-Process Sublime* | 
    #           Select-Object ProcessName, PagedMemorySize, PagedSystemMemorySize, 
    #                  @{ Name = "Time"; Expr = { Get-Date } } 
    #   }
    #   
    #   Shows the memory footprint of sublime every second for 30 seconds
    [CmdletBinding(DefaultParameterSetName="Milliseconds")]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [ScriptBlock[]]$Action,

        [Parameter(ParameterSetName="Milliseconds")]
        [int]$TimerMilliseconds = 1000,
        [Parameter(ParameterSetName="Milliseconds")]
        [int]$LimitSeconds = "30",

        [Parameter(ParameterSetName="TimeSpan")]
        [TimeSpan]$Every = "0:0:1",
        [Parameter(ParameterSetName="TimeSpan", Mandatory=$true)]
        [TimeSpan]$For

    )

    if($PSCmdlet.ParameterSetName -eq "Timespan") {
        $TimerMilliseconds = $Every.Milliseconds
        $LimitMilliseconds = $For.Milliseconds
    } else {
        $LimitMilliseconds = $LimitSeconds * 1000
    }

    # The resolution of the timer matters:
    $ProcessTimer = New-Object System.Timers.Timer $TimerMilliseconds

    # I'm arbitrarily using a stopwatch as the limit to this task
    # You could just count events instead ...
    $StopWatch = New-Object System.Diagnostics.StopWatch

    $MessageData = @{
        Action = $Action
        StopWatch = $StopWatch
        Limit = $LimitMilliseconds
    }

    $Job = Register-ObjectEvent $ProcessTimer -SourceIdentifier LoopTimer -EventName Elapsed -MessageData $MessageData -Action {
        # This is the exit condition, don't run it any more
        if($Event.MessageData.StopWatch.ElapsedMilliseconds -ge $Event.MessageData.Limit) {
            Unregister-Event LoopTimer
            break
        }

        # If you want to be able to tell that something's happening ...
        # You're going to want to write something to the screen in here...
        Write-Progress "Processing" -SecondsRemaining (($Event.MessageData.Limit - $Event.MessageData.StopWatch.ElapsedMilliseconds) / 1000)

        # This is the actual work. In our example, we're just monitoring a process memory footprint
        $Event.MessageData.Action | %{ & $_ }
    }

    $ProcessTimer.Start()
    $StopWatch.Start()

    Write-Warning "If you stop the script using Ctrl+C at this point, you need to manually Unregister-Event LoopTimer"
    # To avoid missing events sleep an order of magnitude less than the TimerResolution
    while(!$Job.Finished.WaitOne($TimerMilliseconds/10)) {
        $Job | Receive-Job
    }
    # Just to make sure the job is empty ...
    $Job | Receive-Job
    $Job | Remove-Job

    # Clean up after ourselves
    $ProcessTimer.Dispose()
    $StopWatch.Stop()
}