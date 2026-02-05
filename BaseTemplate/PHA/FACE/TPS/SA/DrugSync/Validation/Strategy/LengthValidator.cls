/// 长度校验策略 (min / max)  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.LengthValidator Extends PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator
{

Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status
{
    // 安全地获取 min 和 max 值
    set min = ""
    set max = ""
    
    try {
        set min = rule.%Get("min")
    } catch ex {
        // min 属性不存在，这是可接受的
    }
    
    try {
        set max = rule.%Get("max")
    } catch ex {
        // max 属性不存在，这是可接受的
    }

    // 如果 value 为空，不进行长度检查（除非有特殊要求）
    if value = "" quit $$$OK
    
    if (rule.%IsDefined("message")) {
	    s tipMsg = rule.message
    }else {
	    s tipMsg = ""
    }
    
    set len = $length(value)
    
    if min '= "", (min '= $c(0)), (len < min) {
        quit $$$ERROR($$$GeneralError, fieldName_" 长度不能小于 "_min_tipMsg)
    }
    
    if max '= "", (max '= $c(0)), (len > max) {
        quit $$$ERROR($$$GeneralError, fieldName_" 长度不能大于 "_max_tipMsg)
    }
    
    quit $$$OK
}

}
