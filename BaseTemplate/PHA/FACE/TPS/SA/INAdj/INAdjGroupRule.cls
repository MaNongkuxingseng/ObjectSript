Class PHA.FACE.TPS.SA.INAdj.INAdjGroupRule Extends PHA.FACE.TPS.SA.Template.Group.GroupRule
{

Method %OnNew() As %Status
{
    Do ..AddKey("tzno")
    Do ..AddKey("tzloc")
    Quit $$$OK
}

}
