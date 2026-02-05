/// 基础校验策略抽象类  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator Extends %RegisteredObject
{

/// 抽象校验方法，所有子策略必须实现  
/// 参数 fieldName: 字段名称  
/// 参数 value: 字段值  
/// 参数 rule: 校验规则(JSON)
/// 
Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status [ Abstract ]
{
}

}
