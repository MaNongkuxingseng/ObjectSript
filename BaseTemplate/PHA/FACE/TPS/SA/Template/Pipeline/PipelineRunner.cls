Class PHA.FACE.TPS.SA.Template.Pipeline.PipelineRunner Extends %RegisteredObject
{

Property handlers As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Method AddHandler(h As PHA.FACE.TPS.SA.Template.Pipeline.Handler) As %Status
{
    Do ..handlers.Insert(h)
    Quit $$$OK
}

Method Run(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    For i=1:1:..handlers.Count() {
        Set handler=..handlers.GetAt(i)
        Try {
            Set sc = handler.handle(context)
            If $$$ISERR(sc) Return sc
        } Catch ex {
            Return $$$ERROR($$$GeneralError,"Handler '"_$classname(handler)_"' 执行异常: "_ex.DisplayString())
        }
    }
    Quit $$$OK
}

Method %OnNew() As %Status
{
	Set ..handlers = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

}
