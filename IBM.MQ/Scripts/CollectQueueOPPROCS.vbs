Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName, QueueName
QueueManagerName= oArgs(0)
QueueName = oArgs(1)

OPPROCS = 0

Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display Queue(" & QueueName & ") OPPROCS | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
MQText = objExecObject.StdOut.ReadLine()
IF INSTR(MQText,"OPPROCS(") THEN
StatusArray =  Split(MQText, "OPPROCS(")
OPPROCS= CDBL(TRIM(REPLACE(StatusArray(1),")","")))
END IF
Loop

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")
Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("PerfValue",OPPROCS)
Call oAPI.Return(oBag)