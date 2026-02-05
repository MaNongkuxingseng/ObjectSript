Class PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule Extends %RegisteredObject
{

/// 字段名
Property FieldName As %String;

/// 策略数组，每个策略包含：
/// { "validator":"Required", "message":"xxx", "dictType":"UOM", ... }
Property Rules As list Of %DynamicObject;

Method %OnNew() As %Status
{
    set ..Rules = ##class(%ListOfObjects).%New()
    quit $$$OK
}

/// 创建校验策略实例
ClassMethod GetValidatorInstance(name As %String) As %RegisteredObject
{
    s class="PHA.FACE.TPS.SA.DrugSync.Validation.Strategy."_name_"Validator"
    q $classmethod(class,"%New")
}

}
