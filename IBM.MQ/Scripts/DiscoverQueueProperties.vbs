﻿Dim oAPI
Dim oArgs
Set oArgs = WScript.Arguments
' Check for the required script arguments.


FUNCTION getMqProperty(mqType, pName, Property, queueMgr)
    Set objShell = WScript.CreateObject("WScript.Shell")
    QueueCommand = "cmd /c echo Display " & mqType & "(" & pName & ") " & Property & " | runmqsc " & queueMgr
    Set objExecObject = objShell.Exec(QueueCommand)
    Do While Not objExecObject.StdOut.AtEndOfStream
        QueryText = objExecObject.StdOut.ReadLine()
        IF INSTR(QueryText,Property & "(") THEN
            MqProperty = QueryText
            MqPropertyArray = split(MqProperty, Property & "(")
            MqPropertyArray2 = split(MqPropertyArray(1),")")
            getMqProperty = MqPropertyArray2(0)
            Exit Do
        END IF
    Loop
END Function


Dim QueueManagerName

SourceId = oArgs(0) ' The GUID of the discovery object that launched the script.
ManagedEntityId = oArgs(1) ' The GUID of the computer class targeted by the script.
TargetComputer = oArgs(2) ' The FQDN of the computer targeted by the script.
QueueManagerName = oArgs(3)
QueueName = oArgs(4)

Set oAPI = CreateObject("MOM.ScriptAPI")
Dim oDiscoveryData, oInst
Set oDiscoveryData = oAPI.CreateDiscoveryData(0, SourceId, ManagedEntityId)


' Discovered the application. Create the application instance.
Set oInst = oDiscoveryData.CreateClassInstance("$MPElement[Name='IBM.MQ.Queue']$")
' Define the property values for this instance. Available
' properties are determined by the Management Pack that
' defines the class.

Call oInst.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", TargetComputer)
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/QueueName$",QueueName)
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/QueueManagerName$", QueueManagerName)
Call oInst.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", QueueName)

' Discover Properties
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/TYPE$", getMqProperty("Queue", QueueName, "TYPE", QueueManagerName))
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/DESCR$", getMqProperty("Queue", QueueName, "DESCR", QueueManagerName))
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/MAXDEPTH$", getMqProperty("Queue", QueueName, "MAXDEPTH", QueueManagerName))
Call oInst.AddProperty("$MPElement[Name='IBM.MQ.Queue']/MAXMSGL$", getMqProperty("Queue", QueueName, "MAXMSGL", QueueManagerName))

Call oDiscoveryData.AddInstance(oInst)
Call oAPI.Return(oDiscoveryData)

Set oDiscoveryData = nothing
Set oAPI = nothing