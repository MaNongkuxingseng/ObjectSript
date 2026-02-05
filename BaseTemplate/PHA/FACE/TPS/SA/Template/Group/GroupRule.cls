Class PHA.FACE.TPS.SA.Template.Group.GroupRule Extends %RegisteredObject
{

Property Fields As %ListOfDataTypes [ InitialExpression = {##class(%ListOfDataTypes).%New()} ];

Method AddKey(name As %String) As %Status
{
    Do ..Fields.Insert(name)
    Quit $$$OK
}

}
