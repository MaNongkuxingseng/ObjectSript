Class PHA.FACE.TPS.SA.Template.Mapping.MappingSet Extends %RegisteredObject
{

/// =====================================================
/// MainRules / RowRules
/// =====================================================
Property MainRules As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Property RowRules As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

Method %OnNew() As %Status
{
    Set ..MainRules = ##class(%ListOfObjects).%New()
    Set ..RowRules  = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

/// =====================================================
/// 内部统一注册入口
/// =====================================================
Method AddRuleObject(rule As PHA.FACE.TPS.SA.Template.Mapping.MappingRule) As %Status
{
    // ---------- 基础校验 ----------
    If rule.Target = "" {
        Quit $$$ERROR($$$GeneralError,"MappingRule.Target 不能为空")
    }

    If rule.Resolver = "" {
        Quit $$$ERROR($$$GeneralError,"MappingRule.Resolver 未设置，Target="_rule.Target)
    }

    If rule.Scope = "Main" {
        Do ..MainRules.Insert(rule)
    }
    ElseIf rule.Scope = "Row" {
        Do ..RowRules.Insert(rule)
    }
    Else {
        Quit $$$ERROR($$$GeneralError,"Unknown Mapping Scope: "_rule.Scope)
    }

    Quit $$$OK
}

/// =================================================
/// 普通字段映射Field 规则（现在也是 Resolver 驱动）
/// =================================================
Method AddFieldRule(src As %String, tgt As %String, scope As %String) As %Status
{
    Set r = ##class(PHA.FACE.TPS.SA.Template.Mapping.MappingRule).%New()
    Set r.Source   = src
    Set r.Target   = tgt
    Set r.Scope    = scope
    Set r.RuleType = "Field"
    Set r.Resolver =
        "PHA.FACE.TPS.SA.Template.Mapping.Resolver.FieldResolver"
    Set r.NullAble = $$$YES

    Quit ..AddRuleObject(r)
}

/// =====================================================
/// 字典映射
/// =====================================================
Method AddDictRule(src As %String, tgt As %String, scope As %String, dictType As %String, params As %DynamicObject = {{}}) As %Status
{
    Set r = ##class(PHA.FACE.TPS.SA.Template.Mapping.MappingRule).%New()
    Set r.Source   = src
    Set r.Target   = tgt
    Set r.Scope    = scope
    Set r.RuleType = "Dict"
    Set r.Resolver =
        "PHA.FACE.TPS.SA.Template.Mapping.Resolver.DictResolver"

    Set r.Params.dictType = dictType
    Set r.Params.defaultValue = params.defaultValue

    Quit ..AddRuleObject(r)
}

/// =====================================================
/// 枚举映射
/// =====================================================
Method AddEnumRule(src As %String, tgt As %String, scope As %String, enumType As %String) As %Status
{
    Set r = ##class(PHA.FACE.TPS.SA.Template.Mapping.MappingRule).%New()
    Set r.Source   = src
    Set r.Target   = tgt
    Set r.Scope    = scope
    Set r.RuleType = "Enum"
    Set r.Resolver =
        "PHA.FACE.TPS.SA.Template.Mapping.Resolver.EnumResolver"

    Set r.Params.enumType = enumType

    Quit ..AddRuleObject(r)
}

/// =====================================================
/// 常量映射
/// =====================================================
Method AddConstRule(value, tgt As %String, scope As %String) As %Status
{
    Set r = ##class(PHA.FACE.TPS.SA.Template.Mapping.MappingRule).%New()
    Set r.Target   = tgt
    Set r.Scope    = scope
    Set r.RuleType = "Const"
    Set r.Resolver =
        "PHA.FACE.TPS.SA.Template.Mapping.Resolver.ConstResolver"
	Set r.NullAble = $$$YES

    Set r.Params.value = value

    Quit ..AddRuleObject(r)
}

/// =====================================================
/// 方法映射（日期/时间/金额等）
/// =====================================================
Method AddMethodRule(src As %String, tgt As %String, scope As %String, utilClass As %String, methodName As %String, params As %DynamicObject = "") As %Status
{
    Set r = ##class(PHA.FACE.TPS.SA.Template.Mapping.MappingRule).%New()
    Set r.Source   = src
    Set r.Target   = tgt
    Set r.Scope    = scope
    Set r.RuleType = "Method"
    Set r.Resolver =
        "PHA.FACE.TPS.SA.Template.Mapping.Resolver.MethodResolver"
	Set r.NullAble = $$$YES
	
    Set r.Params.utilClass = utilClass
    Set r.Params.method    = methodName

    If $IsObject(params) {
        Do ##class(PHA.COM.Json).Extend(r.Params , params)
    }

    Quit ..AddRuleObject(r)
}

}
