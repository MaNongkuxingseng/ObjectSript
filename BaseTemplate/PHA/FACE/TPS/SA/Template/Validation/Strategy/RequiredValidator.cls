Class PHA.FACE.TPS.SA.Template.Validation.Strategy.RequiredValidator Extends BaseValidator
{

Method Validate(field As %String, value As %String, rule As %DynamicObject) As %Status
{
    if value="" {
        quit $$$ERROR($$$GeneralError, field_" 不能为空")
    }
    quit $$$OK
}

}
