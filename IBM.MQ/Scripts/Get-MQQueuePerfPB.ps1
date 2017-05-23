[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	[string] $QueueManager,
	[string] $QueueName,
	[Parameter(Mandatory=$true)]
	[ValidateSet("CURDEPTH","IPPROCS","SESSIONS","OPPROCS")]
	[string] $DisplayParameter
)

function Extract-MQPerfdataFromCmd ($CommandResult, $DisplayParameter)
{
	$CommandResult -match "$DisplayParameter\((.*)\)" | Out-Null
	$perfResult = $matches[1] -as [double]
	if ($perfResult) {
		return $perfResult
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
		[string]$DisplayParameter
	)
	$commandString = "cmd"
	$commandArguments = "/c echo Display Queue($QueueName) $DisplayParameter | runmqsc $QueueManager"

	[string]$commandResult = & $commandString $commandArguments
	return $commandResult
}

function Get-MQQueueNames
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)]
		[string]$QueueManager
	)

	$commandString = "cmd"
	$commandArguments = "/c echo Display QL(*) | runmqsc $QueueManager"
	[string] $qlResult = & $commandString $commandArguments

	$queueSearch = Select-String -InputObject $qlResult -Pattern "QUEUE\((.*)\) " -AllMatches
	$queueNames = New-Object -TypeName System.Collections.ArrayList
	foreach ($match in $queueSearch.Matches)
	{
		[string]$queueName = $match.Groups[1].Value
		$queueName = $queueName.Trim()
		$queueNames.Add($queueName) | Out-Null
	}

	return $queueNames
}

function Main()
{
	# Is QueueName provided?
	if ($QueueName)
	{
		# Verify Length
		if ($QueueName.Length -gt 0)
		{
			$queueNames = $QueueName
		}
	} else {
		# No QueueName provided, gather all locally available
		$queueNames = Get-MQQueueNames -QueueManager $QueueManager
	}

	# Initiate MOM.ScriptAPI-objects for the property bags
	$omApi = New-Object -ComObject "MOM.ScriptApi"

	foreach ($queueName in $queueNames)
	{
		# execute "display <DisplayParameter>(<queueName>) | runmqsc <QueueManager>"
		$displayResult = Invoke-MQDisplayQueue -QueueManager $QueueManager -QueueName $queueName -DisplayParameter $DisplayParameter
		$perfData = Extract-MQPerfdataFromCmd -CommandResult $displayResult -DisplayParameter $DisplayParameter

		# Create property bag object and populate values
		$omPb = $omApi.CreatePropertyBag()
		$omPb.AddValue("Value", $perfData)
		$omPb.AddValue("Object", $QueueManager)
		$omPb.AddValue("Instance", $queueName)
		$omPb.AddValue("Counter", $DisplayParameter)

		# Return property bag to workflow
		$omPb
	}
}
Main