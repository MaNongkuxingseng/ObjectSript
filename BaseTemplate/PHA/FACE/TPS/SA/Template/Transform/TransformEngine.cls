Class PHA.FACE.TPS.SA.Template.Transform.TransformEngine Extends %RegisteredObject
{

ClassMethod Execute(doc As PHA.FACE.TPS.SA.Template.Context.Document, rules As %ListOfObjects) As %Status
{
    For i=1:1:rules.Count() {
        Set r     = rules.GetAt(i)
        Set field = r.FieldName
        Set value = doc.Data.%Get(field)

        If r.Resolver'="" {
            Set t = $ClassMethod(r.Resolver, "%New")
            Do doc.Data.%Set(field, t.Resolve(value))
        }
    }

    Quit $$$OK
}

}
