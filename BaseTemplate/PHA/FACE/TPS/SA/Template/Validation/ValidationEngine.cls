Class PHA.FACE.TPS.SA.Template.Validation.ValidationEngine Extends %RegisteredObject
{

ClassMethod Validate(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext, rules As %ListOfObjects) As %Status
{
    Set sc = $$$OK
    For i=1:1:rules.Count() {
        Set fr = rules.GetAt(i)
        Set field = fr.FieldName
        Set value = context.Data.%Get(field)
        For j=1:1:fr.Rules.Count() {
            Set rule=fr.Rules.GetAt(j)
            Set vClass="PHA.FACE.TPS.SA.Template.Validation.Strategy."_rule.validator_"Validator"
            Set validator=$ClassMethod(vClass,"%New")
            Set tmpSC=validator.Validate(field,value,rule)
            If $$$ISERR(tmpSC) Set sc = $$$ADDSC(sc,tmpSC)
        }
    }
    Quit sc
}

ClassMethod ValidateDocument(doc As PHA.FACE.TPS.SA.Template.Context.Document, rules As %ListOfObjects) As %Status
{
    Set sc = $$$OK

    // 验证原始数据行（doc.Items）
    For i=1:1:doc.Items.Count() {
        Set row = doc.Items.GetAt(i)  // 原始数据行
        
        For j=1:1:rules.Count() {
            Set fr = rules.GetAt(j)
            Set field = fr.FieldName
            Set scope = fr.Scope
            
            // 只验证 Main 作用域的字段（因为这些字段在每个分组中是一样的）
            // 实际上，对于按 rkno 分组的数据，Main 字段就是每行的某些字段
            If scope = "Main" {
                Set value = ""
                If row.%IsDefined(field) {
                    Set value = row.%Get(field)
                }
                
                For k=1:1:fr.Rules.Count() {
                    Set rule = fr.Rules.GetAt(k)
                    Set vClass = "PHA.FACE.TPS.SA.Template.Validation.Strategy."_rule.validator_"Validator"
                    Set validator = $ClassMethod(vClass,"%New")
                    Set tmpSC = validator.Validate(field, value, rule)
                    If $$$ISERR(tmpSC) Set sc = $$$ADDSC(sc,tmpSC)
                }
            }
            ElseIf scope = "Row" {
                // 对于 Row 作用域的字段，直接验证每行的数据
                Set value = ""
                If row.%IsDefined(field) {
                    Set value = row.%Get(field)
                }
                
                For k=1:1:fr.Rules.Count() {
                    Set rule = fr.Rules.GetAt(k)
                    Set vClass = "PHA.FACE.TPS.SA.Template.Validation.Strategy."_rule.validator_"Validator"
                    Set validator = $ClassMethod(vClass,"%New")
                    Set tmpSC = validator.Validate(field_"(第"_i_"行)", value, rule)
                    If $$$ISERR(tmpSC) Set sc = $$$ADDSC(sc,tmpSC)
                }
            }
        }
    }

    Quit sc
}

}
