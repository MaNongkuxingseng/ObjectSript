/// 必填校验策略  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.RequiredValidator Extends PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator
{

Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status
{
    i value="" q $$$ERROR($$$GeneralError, fieldName_" 字段不能为空")
    q $$$OK
}

}
