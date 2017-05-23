Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName
QueueManagerName= oArgs(0)
ChannelName= oArgs(1)

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")

Set objShell = WScript.CreateObject("WScript.Shell")

Status = "Not Available"

QueueCommand = "cmd /c echo Display chs(" & ChannelName & ") | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
MQText = objExecObject.StdOut.ReadLine()
IF INSTR(MQText,"STATUS(") THEN
StatusArray =  Split(MQText, "STATUS(")
StatusArray2 =  Split(StatusArray(1), ")")
Status = StatusArray2(0)
Exit do
END IF
Loop

'wscript.echo Status

Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("Status",Status)
Call oAPI.Return(oBag)
