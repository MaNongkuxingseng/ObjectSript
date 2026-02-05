/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 分组规则，定义调价数据分组规则
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspGroupRule Extends PHA.FACE.TPS.SA.Template.Group.GroupRule
{

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 初始化分组键
/// Input: 无
/// Output: %Status - 初始化状态
Method %OnNew() As %Status
{
	Do ..AddKey("tjno")
	Do ..AddKey("tjloc")
	Do ..AddKey("tjuser")
	Quit $$$OK
}

}
