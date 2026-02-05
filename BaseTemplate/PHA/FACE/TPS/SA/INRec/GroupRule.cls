Class PHA.FACE.TPS.SA.INRec.GroupRule Extends PHA.FACE.TPS.SA.Template.Group.GroupRule
{

Method %OnNew() As %Status
{
	// 入库单分组(分单)规则
    Do ..AddKey("rkno")
    Do ..AddKey("rkloc")
    Do ..AddKey("vendor")
    Do ..AddKey("zduser")
    Quit $$$OK
}

}
