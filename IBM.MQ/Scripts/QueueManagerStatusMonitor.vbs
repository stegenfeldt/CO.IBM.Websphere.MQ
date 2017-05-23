Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName
QueueManagerName= oArgs(0)

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")

Status = "Not Available"

Set objShell = WScript.CreateObject("WScript.Shell")
Set objExecObject = objShell.Exec("dspmq -m "&QueueManagerName&" -s")

Do While Not objExecObject.StdOut.AtEndOfStream
MQText = objExecObject.StdOut.ReadLine()
IF INSTR(MQText,"STATUS(") THEN
StatusArray =  Split(MQText, "STATUS(")
Status = REPLACE(StatusArray(1),")","")
Exit do
END IF
Loop

Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("Status",Status)
Call oAPI.Return(oBag)