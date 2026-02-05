Class PHA.FACE.TPS.SA.Template.Pipeline.ValidationHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

Property rules As %ListOfObjects;

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
	s sc = $$$OK
    For i=1:1:context.Documents.Count() {
        Set doc = context.Documents.GetAt(i)
        Set tmpSC = ##class(PHA.FACE.TPS.SA.Template.Validation.ValidationEngine).ValidateDocument(doc, ..rules)
        If $$$ISERR(tmpSC) Set sc = $$$ADDSC(sc, tmpSC)
    }
    
    Quit sc
}

}
