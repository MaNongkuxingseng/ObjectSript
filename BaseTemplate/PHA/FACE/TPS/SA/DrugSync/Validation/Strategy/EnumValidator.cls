/// 枚举校验策略  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.EnumValidator Extends PHA.FACE.TPS.SA.DrugSync.Validation.Strategy.BaseValidator
{

Method Validate(fieldName As %String, value As %String, rule As %DynamicObject) As %Status
{
	// 如果值为空，跳过校验（除非规则明确要求）
    if value = "" quit $$$OK
    
    // 安全获取 enumArr - 不使用 try-catch 中的 quit
    set enum = ""
    
    // 使用标志变量
    set hasError = 0
    
    try {
        set enum = rule.%Get("enumArr")
    } catch ex {
        set hasError = 1
    }
    
    // 在 try-catch 外部处理错误
    if hasError {
        quit $$$ERROR($$$GeneralError, fieldName _ " 枚举校验配置错误: enumArr 不存在")
    }
    
    // 检查 enum 是否为有效数组
    if '$isobject(enum) {
        quit $$$ERROR($$$GeneralError, fieldName _ " 枚举校验配置错误: enumArr 不是有效对象")
    }
    
    if 'enum.%IsA("%Library.DynamicArray") {
        quit $$$ERROR($$$GeneralError, fieldName _ " 枚举校验配置错误: enumArr 不是数组类型")
    }
    
    // 如果数组为空，跳过校验
    if enum.%Size() = 0 quit $$$OK

    // 遍历查找
    set found = 0
    set size = enum.%Size()
    for i = 0 : 1 : size - 1 {
        try {
            if enum.%Get(i) = value {
                set found = 1
                quit
            }
        } catch ex {
            // 跳过无效的数组元素
        }
    }

    // 未找到
    if 'found {
        // 拼接枚举为字符串方便阅读
        set enumStr = ""
        for i = 0 : 1 : size - 1 {
            try {
                set elem = enum.%Get(i)
                set enumStr = enumStr _ elem
                if i < (size - 1) set enumStr = enumStr _ ","
            } catch ex {
                // 跳过无效元素
            }
        }
        quit $$$ERROR($$$GeneralError, fieldName _ " 必须为以下值之一: " _ enumStr)
    }

    quit $$$OK
}

}
