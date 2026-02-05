Class PHA.FACE.TPS.SA.Template.Pipeline.DocumentValidationHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

/// 业务提供的校验器
Property validator As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator;

/// ========================================
/// Pipeline 执行入口
/// ========================================
Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    Set sc = $$$OK

    If '$IsObject(..validator) {
        Quit sc
    }

    For i=1:1:context.Documents.Count() {

        Set doc = context.Documents.GetAt(i)
        Set vsc  = ..validator.Validate(doc)

        If $$$ISERR(vsc) {
            Set sc = $$$ADDSC(sc, vsc)
        }
    }

    Quit sc
}

}
