Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName, QueueName
QueueManagerName= oArgs(0)
QueueName = oArgs(1)

CURDEPTH = 0

Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display Queue(" & QueueName & ") CURDEPTH| runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
MQText = objExecObject.StdOut.ReadLine()
IF INSTR(MQText,"CURDEPTH(") THEN
StatusArray =  Split(MQText, "CURDEPTH(")
CURDEPTH= CDBL(TRIM(REPLACE(StatusArray(1),")","")))
END IF
Loop

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")
Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("PerfValue",CURDEPTH)
Call oAPI.Return(oBag)
