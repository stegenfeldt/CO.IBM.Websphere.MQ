Dim oArgs
Set oArgs = WScript.Arguments
Dim QueueManagerName
QueueManagerName= oArgs(0)
QueueName= oArgs(1)

Dim oAPI, oBag
Set oAPI = CreateObject("MOM.ScriptAPI")

Set objShell = WScript.CreateObject("WScript.Shell")
 QueueCommand = "cmd /c echo Display Queue(" & QueueName & ") IPPROCS | runmqsc " & QueueManagerName
Set objExecObject = objShell.Exec(QueueCommand)

Do While Not objExecObject.StdOut.AtEndOfStream
    MQText = objExecObject.StdOut.ReadLine()
    IF INSTR(MQText,"IPPROCS(") THEN
     StatusArray =  Split(MQText, "CURDEPTH(")
     IPPROCS = CINT(TRIM(REPLACE(StatusArray(1),")","")))

    END IF
Loop

Set oBag = oAPI.CreatePropertyBag()
Call oBag.AddValue("IPPROCS",IPPROCS)
Call oAPI.Return(oBag)