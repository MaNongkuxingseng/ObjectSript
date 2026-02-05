Class PHA.FACE.TPS.SA.Template.Pipeline.TransformHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

Property rules As %ListOfObjects;

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    Set sc = $$$OK

    For i=1:1:context.Documents.Count() {
        Set doc = context.Documents.GetAt(i)		// ExecuteDocument
        Set tmpSC = ##class(PHA.FACE.TPS.SA.Template.Transform.TransformEngine).Execute(doc, ..rules)
        If $$$ISERR(tmpSC) return tmpSC
    }

    Quit sc
}

}
