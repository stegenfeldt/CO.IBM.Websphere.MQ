Option Explicit
'SetLocale("en-us")

Dim oArgs
Set oArgs = WScript.Arguments

Dim QueueManagerName, QueueName, WarningThreshold, ErrorThreshold
QueueManagerName= oArgs(0)
QueueName= oArgs(1)
WarningThreshold= CDbl(oArgs(2))
ErrorThreshold= CDbl(oArgs(3))

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")

Dim objShell, objExecObject, QueueCommand
Set objShell = WScript.CreateObject("WScript.Shell")
QueueCommand = "cmd /c echo Display Queue(" & Trim(QueueName) & ") CURDEPTH | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Dim MQText, StatusArray, CurDepth
Do While Not objExecObject.StdOut.AtEndOfStream
    MQText = objExecObject.StdOut.ReadLine()
    IF INSTR(MQText,"CURDEPTH(") THEN
        StatusArray =  Split(MQText, "CURDEPTH(")
        CurDepth= CDbl(TRIM(REPLACE(StatusArray(1),")","")))
    END IF
Loop

Dim Status ' OK, WARNING or ERROR
Status = "OK"
If CurDepth >= ErrorThreshold Then
    Status = "ERROR"
ElseIf CurDepth >= WarningThreshold Then
    Status = "WARNING"
End If

oAPI.LogScriptEvent(QueueCurrentDepthMonitor.vbs, 17001, 0, "Status: " & Status & vbCrLf & "CurDepth: " & CurDepth)
Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("CurDepth", CurDepth)
Call oBag.AddValue("Status", Status)
Call oAPI.Return(oBag)