Class PHA.FACE.TPS.SA.Template.Validation.Strategy.LengthValidator Extends BaseValidator
{

Method Validate(field As %String, value As %String, rule As %DynamicObject) As %Status
{
    if value="" quit $$$OK

    set len = $length(value)
    if $data(rule.min), len < rule.min {
        quit $$$ERROR($$$GeneralError, field_" 长度小于最小值")
    }
    if $data(rule.max), len > rule.max {
        quit $$$ERROR($$$GeneralError, field_" 长度大于最大值")
    }
    quit $$$OK
}

}
