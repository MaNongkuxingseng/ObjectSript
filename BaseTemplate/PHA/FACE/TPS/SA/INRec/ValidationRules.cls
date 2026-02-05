Class PHA.FACE.TPS.SA.INRec.ValidationRules Extends %RegisteredObject
{

ClassMethod Build() As %ListOfObjects
{
    set lst = ##class(%ListOfObjects).%New()

    // ======================
    // Main 级校验
    // ======================

    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "rkno",   "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "rkloc",  "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "vendor", "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "type",   "Main")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "cguser", "Main")

    // ======================
    // Row 级校验（逐行）
    // ======================

    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "incno",    "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "incdesc",  "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "qty",      "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "uom",      "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "manf",     "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "manfdesc", "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "rp",       "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "rpAmt",    "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "batNo",    "Row")
    Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "expDate",  "Row")
	Do ##class(PHA.FACE.TPS.SA.Template.Validation.RuleBuilder).AddRequired(lst, "Batid",  "Row")
    Quit lst
}

ClassMethod AddRequired11(lst As %ListOfObjects, field As %String, scope As %String) As %Status
{
    set fr = ##class(PHA.FACE.TPS.SA.Template.Validation.FieldRule).%New()
    set fr.FieldName = field
    set fr.Scope     = scope

    set rules = ##class(%ListOfObjects).%New()
    set rule  = ##class(%DynamicObject).%New()
    set rule.validator = "Required"

    do rules.Insert(rule)
    set fr.Rules = rules

    do lst.Insert(fr)
    Quit $$$OK
}

}
