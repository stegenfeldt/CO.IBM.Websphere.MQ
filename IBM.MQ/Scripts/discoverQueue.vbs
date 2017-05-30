Dim oAPI
Dim oArgs
Set oArgs = WScript.Arguments
' Check for the required script arguments.
if oArgs.Count < 2 Then
    ' If the script is called without the required arguments,
    ' create an information event and then quit.
    Call oAPI.LogScriptEvent("discoverQueue.vbs",101,0, _
        "script was called with fewer than three arguments and was not executed.")
    Wscript.Quit -1
End If

Dim SourceID, ManagedEntityId, TargetComputer, QueueManagerName

SourceId = oArgs(0) ' The GUID of the discovery object that launched the script.
ManagedEntityId = oArgs(1) ' The GUID of the computer class targeted by the script.
TargetComputer = oArgs(2) ' The FQDN of the computer targeted by the script.
QueueManagerName = oArgs(3)

Set oAPI = CreateObject("MOM.ScriptAPI")
Dim oDiscoveryData, oInst
Set oDiscoveryData = oAPI.CreateDiscoveryData(0, SourceId, ManagedEntityId)

Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display QL(*) | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
    QueueText = objExecObject.StdOut.ReadLine()

    IF INSTR(QueueText, "QUEUE(") THEN
        MQTextArray = split(QueueText,")")
        QueueName = Trim(Replace(MQTextArray(0),"QUEUE(",""))

        ' Discovered the application. Create the application instance.
        Set oInst = oDiscoveryData.CreateClassInstance("$MPElement[Name='IBM.MQ.Queue']$")
        ' Define the property values for this instance. Available
        ' properties are determined by the Management Pack that
        ' defines the class.

        Call oInst.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", TargetComputer)
        Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/QueueName$",QueueName)
        Call oInst.AddProperty("$MPElement[Name='IBM.MQ.QueueManager']/QueueManagerName$", QueueManagerName)
        Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/QueueManagerName$", QueueManagerName)
        Call oInst.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", QueueName)

        Call oDiscoveryData.AddInstance(oInst)

        ' Submit the discovery data for processing.
        Call oAPI.LogScriptEvent("discoverQueue.vbs",10011,0,"New Queue: " & QueueName & " Added to Discovery")
    END IF
Loop

Call oAPI.Return(oDiscoveryData)

Set oDiscoveryData = nothing
Set oAPI = nothing

