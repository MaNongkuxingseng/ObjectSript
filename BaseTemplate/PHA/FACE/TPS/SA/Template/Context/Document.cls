/// Document 对象，包含 Key、Items、Data
Class PHA.FACE.TPS.SA.Template.Context.Document Extends %RegisteredObject
{

Property Key As %String;

Property Items As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Property Data As %DynamicObject [ InitialExpression = {{}} ];

Method %OnNew() As %Status
{
    Set ..Items=##class(%ListOfObjects).%New()
    Set ..Data={}
    Quit $$$OK
}

}
