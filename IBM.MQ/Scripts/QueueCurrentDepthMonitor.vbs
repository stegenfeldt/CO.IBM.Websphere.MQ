Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName
QueueManagerName= oArgs(0)
QueueName= oArgs(1)
WarningThreshold= oArgs(2)
ErrorThreshold= oArgs(3)
HealthyThreshold= oArgs(4)

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")

Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display Queue(" & QueueName & ") CURDEPTH | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
MQText = objExecObject.StdOut.ReadLine()
IF INSTR(MQText,"CURDEPTH(") THEN
StatusArray =  Split(MQText, "CURDEPTH(")
CurDepth= CINT(TRIM(REPLACE(StatusArray(1),")","")))

END IF
Loop

Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("CurDepth",CurDepth)
Call oBag.AddValue("WarningThreshold",WarningThreshold)
Call oBag.AddValue("ErrorThreshold",ErrorThreshold)
Call oBag.AddValue("HealthyThreshold",HealthyThreshold)
Call oAPI.Return(oBag)