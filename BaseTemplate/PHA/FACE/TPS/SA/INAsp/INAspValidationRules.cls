/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 验证规则，定义调价数据验证规则
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspValidationRules Extends %RegisteredObject
{

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 构建验证规则列表
/// Input: 无
/// Output: %ListOfObjects - 验证规则列表
/// Example: d ##class(PHA.FACE.TPS.SA.INAsp.INAspValidationRules).Build()
ClassMethod Build() As %ListOfObjects
{
    Set lst = ##class(%ListOfObjects).%New()
    
    // Main 部分验证规则
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "tjuser", "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "tjloc", "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "tjno", "Main")
    
    // Row 部分验证规则
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "incno", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "uom", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "thrp", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "thsp", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "tjreason", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "PlanDate", "Row")
    
    // 数值类型验证
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddNumber(lst, "thrp", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddNumber(lst, "thsp", "Row")
        
    Quit lst
}

}
