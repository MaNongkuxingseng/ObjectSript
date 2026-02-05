Class PHA.FACE.TPS.SA.Template.Validation.RuleBuilder Extends %RegisteredObject
{

ClassMethod AddRequired(lst As %ListOfObjects, field As %String, scope As %String) As %Status
{
    Quit ..AddRule(lst,field,scope,"Required",{})
}

ClassMethod AddEnum(lst As %ListOfObjects, field As %String, scope As %String, values As %String) As %Status
{
    set opts={}
    set arr=##class(%DynamicArray).%New()
    for i=1:1:$length(values,",") {
        do arr.%Push($piece(values,",",i))
    }
    set opts.enumArr=arr
    Quit ..AddRule(lst,field,scope,"Enum",opts)
}

ClassMethod AddLength(lst As %ListOfObjects, field As %String, scope As %String, min As %Integer = "", max As %Integer = "") As %Status
{
    set opts={}
    if min'="" set opts.min=min
    if max'="" set opts.max=max
    Quit ..AddRule(lst,field,scope,"Length",opts)
}

ClassMethod AddNumber(lst As %ListOfObjects, field As %String, scope As %String) As %Status
{
    Quit ..AddRule(lst,field,scope,"Number",{})
}

// 

// ===== 内部统一构造方法 =====

// 

ClassMethod AddRule(lst As %ListOfObjects, field As %String, scope As %String, validator As %String, opts As %DynamicObject) As %Status
{
    set fr = ##class(PHA.FACE.TPS.SA.Template.Validation.FieldRule).%New()
    set fr.FieldName = field
    set fr.Scope     = scope

    set rule = ##class(%DynamicObject).%New()
    set rule.validator = validator

    set iter = opts.%GetIterator()
    while iter.%GetNext(.k,.v) {
        do rule.%Set(k,v)
    }

    set rules = ##class(%ListOfObjects).%New()
    do rules.Insert(rule)
    set fr.Rules = rules

    do lst.Insert(fr)
    Quit $$$OK
}

}
