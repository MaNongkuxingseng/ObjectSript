/// 字段级校验规则
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 定义退货单字段的校验规则，确保数据完整性
Class PHA.FACE.TPS.SA.INRet.ValidationRules Extends %RegisteredObject
{

/// 构建字段级校验规则列表
/// Rule Types:
/// - Required: 必填校验
/// - DataType: 数据类型校验
/// - Range: 范围校验
/// - Regex: 正则表达式校验
ClassMethod Build() As %ListOfObjects
{
    Set lst = ##class(%ListOfObjects).%New()

    // ===== Main 表头必填校验 =====
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"thno","Main")       // 退货单号必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"thloc","Main")      // 退货科室必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"vendor","Main")     // 供应商必填

    // ===== Row 明细必填校验 =====
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"incno","Row")       // 药品代码必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"qty","Row")         // 数量必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"uom","Row")         // 单位必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"batNo","Row")       // 批号必填
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"expDate","Row")     // 效期必填

    Quit lst
}

}
