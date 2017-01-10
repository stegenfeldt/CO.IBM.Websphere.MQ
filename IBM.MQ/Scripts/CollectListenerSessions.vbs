Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName, QueueName
QueueManagerName= oArgs(0)
ListenerName = oArgs(1)

SESSIONS = 0

Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display Listener(" & ListenerName & ") SESSIONS | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
    MQText = objExecObject.StdOut.ReadLine()
    IF INSTR(MQText,"SESSIONS(") THEN
     StatusArray =  Split(MQText, "SESSIONS(")
     SESSIONS = CDBL(TRIM(REPLACE(StatusArray(1),")","")))
    END IF
Loop

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")
Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("PerfValue",SESSIONS)
Call oAPI.Return(oBag)