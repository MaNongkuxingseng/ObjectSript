Class PHA.FACE.TPS.SA.Template.Validation.Strategy.NumberValidator Extends BaseValidator
{

Method Validate(field As %String, value As %String, rule As %DynamicObject) As %Status
{
    if value'?1.N.1".".N {
        quit $$$ERROR($$$GeneralError, field_" 必须为数字")
    }
    quit $$$OK
}

}
