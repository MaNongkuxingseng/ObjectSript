/// 精简后的 Context，汇总 DTO、Documents、GroupResult、Data
/// 
Class PHA.FACE.TPS.SA.Template.Context.DocumentContext Extends %RegisteredObject
{

Property SourceList As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Property Documents As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Property GroupResult As %DynamicObject;

// Property Data As %DynamicObject [ InitialExpression = {{}} ];

Method %OnNew() As %Status
{
    Set ..SourceList=##class(%ListOfObjects).%New()
    Set ..Documents=##class(%ListOfObjects).%New()
    Quit $$$OK
}

Method MergeFrom(dto As %RegisteredObject) As %Status
{
	Quit $$$OK	// 废弃
    Set className = dto.%ClassName(1)
    Set class = ##class(%Dictionary.CompiledClass).%OpenId(className)
    If '$isobject(class) Quit $$$ERROR($$$ClassDoesNotExist,className)
    For i=1:1:class.Properties.Count() {
        Set prop = class.Properties.GetAt(i)
        Set propName = prop.Name
        Set value = $Property(dto, propName)
        //If value'="" Do ..Data.%Set(propName,value)
    }
    Do ..SourceList.Insert(dto)
    Quit $$$OK
}

}
