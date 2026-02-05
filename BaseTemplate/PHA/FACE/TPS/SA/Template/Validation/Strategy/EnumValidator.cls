Class PHA.FACE.TPS.SA.Template.Validation.Strategy.EnumValidator Extends BaseValidator
{

Method Validate(field As %String, value As %String, rule As %DynamicObject) As %Status
{
    set arr = rule.enumArr
    for i=0:1:arr.%Size()-1 {
        if arr.%Get(i)=value return $$$OK
    }
    quit $$$ERROR($$$GeneralError, field_" 枚举值非法")
}

}
