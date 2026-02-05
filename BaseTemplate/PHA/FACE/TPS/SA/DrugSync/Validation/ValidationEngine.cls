Class PHA.FACE.TPS.SA.DrugSync.Validation.ValidationEngine Extends %RegisteredObject
{

/// 执行所有字段的校验规则  
/// 任何校验失败立即返回  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Method Validate(dto As PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO, fieldRules As %ListOfObjects) As %Status
{
    set sc = $$$OK

    if '$isobject(fieldRules) quit sc

    for i=1:1:fieldRules.Count() {
        set fr = fieldRules.GetAt(i)
        set fname = $get(fr.FieldName)
        if fname="" {
            return $$$ERROR($$$GeneralError, "Validation rule missing FieldName at index "_i)
        }

        // 安全取得 DTO 字段值
        set value = ""
        try {
            set value = dto.%Get(fname)
        } catch ex {
            return $$$ERROR($$$GeneralError, "DTO property not found: "_fname)
        }

        // 执行每个策略
        for j=1:1:fr.Rules.Count() {
            set rule = fr.Rules.GetAt(j)
            set validator = ##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).GetValidatorInstance($get(rule.validator))
            if validator="" {
                return $$$ERROR($$$GeneralError, "Validator not found: "_$get(rule.validator)_" for field "_fname)
            }
            set sc = validator.Validate(fname, value, rule)
            if $$$ISERR(sc) return sc
        }
    }

    quit sc
}

/// 执行所有字段的校验规则  
/// 收集所有校验失败信息一次性返回  
/// 作者: valen MPF  
/// 日期: 2025-02-16
ClassMethod ValidateBatch(dto As PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO, fieldRules As %ListOfObjects) As %Status
{
	set errorList = ##class(%ListOfDataTypes).%New()
    set hasError = 0

    if '$isobject(fieldRules) quit $$$OK

    for i=1:1:fieldRules.Count() {
        set fr = fieldRules.GetAt(i)
        // 检查 fr 是否为有效对象
        if '$isobject(fr) {
            do errorList.Insert("Invalid rule object at index "_i)
            set hasError = 1
            continue
        }
        
        // 安全地获取 FieldName
        try {
            set fname = fr.FieldName
        } catch ex {
            do errorList.Insert("Cannot access FieldName at index "_i_": "_ex.DisplayString())
            set hasError = 1
            continue
        }
        
        if fname="" {
            do errorList.Insert("Missing FieldName at index "_i)
            set hasError = 1
            continue
        }

        // 安全获取 DTO 字段
        // 使用 $property 获取 DTO 属性值
        set value = ""
        try {
            // 尝试使用 $property 获取属性值
            set value = $property(dto, fname)
        } catch ex {
            // 如果 $property 失败，尝试使用 %Get
            try {
                set value = dto.%Get(fname)
            } catch ex2 {
                do errorList.Insert("DTO property not found: "_fname)
                set hasError = 1
                continue
            }
        }

        // 检查 Rules 属性是否存在
        if '$isobject(fr.Rules) {
            do errorList.Insert("Rules not defined for field: "_fname)
            set hasError = 1
            continue
        }
        
        for j=1:1:fr.Rules.Count() {
            set rule = fr.Rules.GetAt(j)
            if '$isobject(rule) {
                do errorList.Insert("Invalid rule object for field "_fname_" at index "_j)
                set hasError = 1
                continue
            }
            
            set validatorName = rule.validator
            if validatorName="" {
                do errorList.Insert("Validator name is empty for field "_fname_" at index "_j)
                set hasError = 1
                continue
            }
            
            set validator = ##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).GetValidatorInstance(validatorName)
            if validator="" {
                do errorList.Insert("Validator not found: "_validatorName_" for field "_fname)
                set hasError = 1
                continue
            }
            
            set sc = validator.Validate(fname, value, rule)
            if $$$ISERR(sc) {
                set hasError = 1
                set errorMsg = $system.Status.GetOneErrorText(sc)
                do errorList.Insert(errorMsg)
            }
        }
    }

    if hasError {
        set errorText = ""
        for i=1:1:errorList.Count() {
            set errorText = errorText _ errorList.GetAt(i) _ ";"
        }
        quit $$$ERROR($$$GeneralError, "验证失败: "_errorText)
    }

    quit $$$OK
}

}
