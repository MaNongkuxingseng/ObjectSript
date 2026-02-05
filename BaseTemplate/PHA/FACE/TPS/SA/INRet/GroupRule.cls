/// 退货单分单规则
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 根据退货单号、科室、供应商进行分组
Class PHA.FACE.TPS.SA.INRet.GroupRule Extends PHA.FACE.TPS.SA.Template.Group.GroupRule
{

/// 初始化分单规则，设置分组键
Method %OnNew() As %Status
{
    Do ..AddKey("thno")     // 退货单号
    Do ..AddKey("thloc")    // 退货科室
    Do ..AddKey("vendor")   // 供应商
    Quit $$$OK
}

}
