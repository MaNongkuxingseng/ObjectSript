/// 字典校验策略 (需在字典中存在)  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.DictionaryExistValidator Extends PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator
{

Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status
{
    // 如果值为空，跳过校验
    if value = "" quit $$$OK
    
    // 安全获取 dictType
    set dictType = ""
    set hasError = 0
    
    try {
        set dictType = rule.%Get("dictType")
    } catch ex {
        set hasError = 1
    }
    
    if hasError {
        quit $$$ERROR($$$GeneralError, fieldName_" 字典校验配置错误: dictType 不存在")
    }
    
    if dictType = "" {
        quit $$$ERROR($$$GeneralError, fieldName_" 字典校验配置错误: dictType 为空")
    }
    
    set exists = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).Find(dictType, value)

    if exists = "" {
        quit $$$ERROR($$$GeneralError, fieldName_" 字典不存在: "_value_" (字典类型: "_dictType_")")
    }
    
    quit $$$OK
}

}
