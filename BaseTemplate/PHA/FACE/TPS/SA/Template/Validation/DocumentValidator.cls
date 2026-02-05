Class PHA.FACE.TPS.SA.Template.Validation.DocumentValidator Extends PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{

/// 单据规则集合
Property rules As %ListOfObjects;

/// ========================================
/// 执行所有单据规则
/// ========================================
Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status
{
    Set sc = $$$OK

    If '$IsObject(..rules) {
        Quit sc
    }

    For i=1:1:..rules.Count() {
        Set rule = ..rules.GetAt(i)

        Set rsc = rule.Check(doc)
        If $$$ISERR(rsc) {
            Set sc = $$$ADDSC(sc, rsc)
        }
    }

    Quit sc
}

}
