[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$QueueName,
    [Parameter(Mandatory=$true)]
    [string]$QueueManager,
    [Parameter(Mandatory=$true)]
    [ValidateSet("CURDEPTH","IPPROCS","SESSIONS","OPPROCS")]
    [string]$DisplayParameter
)

#$cmdResult = @"
#5724-H72 (C) Copyright IBM Corp. 1994, 2009.  ALL RIGHTS RESERVED.
#Starting MQSC for queue manager EXT_QM.


#     1 : Display Queue(   CHANGE_REQUEST) CURDEPTH
#AMQ8409: Display Queue details.
#   QUEUE(CHANGE_REQUEST)                   TYPE(QLOCAL)
#   CURDEPTH(242)
#One MQSC command read.
#No commands have a syntax error.
#All valid MQSC commands were processed.
#"@

function Extract-MQCurrDepthFromCmd ($CommandResult)
{
    $CommandResult -match "CURDEPTH\((.*)\)" | Out-Null
    $currDepth = $matches[1] -as [double]
    if ($currDepth) {
        return $currDepth
    } else {
        return $null
    }
}

function Invoke-MQDisplayQueue
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$QueueName,
        [Parameter(Mandatory=$true)]
        [string]$QueueManager,
        [Parameter(Mandatory=$true)]
        [ValidateSet("CURDEPTH","IPPROCS","SESSIONS")]
        [string]$DisplayParameter
    )
    $commandString = "cmd"
    $commandArguments = "/c echo Display Queue($QueueName) $DisplayParameter | runmqsc $QueueManager"

    & $commandString $commandArguments
}

$mqQueueResult = Invoke-MQDisplayQueue -QueueName "TESTQUEUE" -QueueManager "TESTQUQUEMANAGER" -DisplayParameter CURDEPTH
#Extract-MQCurrDepthFromCmd -CommandResult $cmdResult