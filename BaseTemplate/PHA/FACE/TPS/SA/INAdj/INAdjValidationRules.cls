Class PHA.FACE.TPS.SA.INAdj.INAdjValidationRules Extends %RegisteredObject
{

ClassMethod Build() As %ListOfObjects
{
    Set lst = ##class(%ListOfObjects).%New()
    
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"tzno","Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"tzloc","Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"tzreason","Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"tzuser","Main")
    
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"incno","Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"qty","Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst,"uom","Row")
    
    Quit lst
}

}
