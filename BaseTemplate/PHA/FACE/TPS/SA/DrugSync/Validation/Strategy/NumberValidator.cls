/// 数字格式校验策略  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.NumberValidator Extends PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator
{

Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status
{
    // 如果值为空，跳过校验（除非规则明确要求）
    if value = "" quit $$$OK
    
    // 检查是否为数字（允许整数和小数）
    if value '?1.N.1".".N {
        quit $$$ERROR($$$GeneralError, fieldName_" 必须为数字")
    }
    
    quit $$$OK
}

}
