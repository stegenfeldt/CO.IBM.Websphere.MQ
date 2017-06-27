[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true)]
	[string] $QueueManager,
	#[string] $QueueName,
	[string] $DisplayParameter
)

function Get-MQPerfdataFromCmd ($CommandResult, $DisplayParameter)
{
	$CommandResult -match "$DisplayParameter\((.*)\)" | Out-Null
	if ($matches -ne $null) {
	if ($matches.count -gt 1) {
		$perfResult = $matches[1] -as [double]
		if ($perfResult) {
			return $perfResult
		} else {
			return $null
		}
	}}
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

	$queueSearch = Select-String -InputObject $qlResult -Pattern "QUEUE\((.*?)\)" -AllMatches
	$queueNames = New-Object -TypeName System.Collections.ArrayList
	foreach ($match in $queueSearch.Matches.Groups)
	{
		if ($match.Groups) {
			[string]$queueName = $match.Groups[1].Value
			$queueName = $queueName.Trim()
			$queueNames.Add($queueName) | Out-Null
		}
	}

	return $queueNames
}

function Write-DebugLog ($Message) {
	if ($MyInvocation.ScriptName.Length -gt 0) {
		$scriptName = $MyInvocation.ScriptName
		$scriptName = $scriptName.Substring($scriptName.LastIndexOf("\")+1,$scriptName.LastIndexOf(".") - $scriptName.LastIndexOf("\")-1)
	}
	else {
		$scriptName = $PID
	}
	$logFilePath = ("{0}\{2}_{1}.log" -f "C:\Windows\Temp",$(Get-Date -Format yyyyMMdd),$scriptName)
	$Message = "{0}`t{1}`t{3}`t{2}" -f $(Get-Date -Format o),$PID,$Message,$env:USERNAME
	Out-File -LiteralPath $logFilePath -InputObject $Message -Append
}

function Main()
{
	Write-DebugLog -Message "Starting script using parameters: QueueManager=$QueueManager; QueueName=$QueueName; DisplayParameter=$DisplayParameter"
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
		Write-DebugLog -Message "Checking Queue: $queueName"


		# prepare array with relevant counters
		$displayParameters = @(
			"CURDEPTH",
			"IPPROCS",
			"OPPROCS",
			"SESSIONS"
		)
		# loop through counters, return values in PB
		foreach ($DisplayParameter in $displayParameters) {
			# execute "display <DisplayParameter>(<queueName>) | runmqsc <QueueManager>"
			$displayResult = Invoke-MQDisplayQueue -QueueManager $QueueManager -QueueName $queueName -DisplayParameter $DisplayParameter
			# extract performance data
			$perfData = Get-MQPerfdataFromCmd -CommandResult $displayResult -DisplayParameter $DisplayParameter

			if ($perfData) {
				# Create property bag object and populate values
				$omPb = $omApi.CreatePropertyBag()
				$omPb.AddValue("Value", $perfData)
				$omPb.AddValue("Object", $QueueManager)
				$omPb.AddValue("Instance", $queueName)
				$omPb.AddValue("Counter", $DisplayParameter)

				Write-DebugLog -Message "$DisplayParameter on $QueueManager/$queueName = $perfData"

				# Return property bag to workflow
				$omPb
			}
		}
	}
}
Main