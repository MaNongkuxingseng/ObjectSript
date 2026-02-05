Class PHA.FACE.TPS.SA.INRec.InRecDocumentValidator Extends PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{

/// ========================================
/// 入库单据级校验
/// ========================================
Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status
{
    Set rkno = doc.Data.main.rkno

    If rkno = "" {
        Quit $$$ERROR($$$GeneralError, "入库单号不能为空")
    }

    If $Data(^DHCINGR(0,"No",$$ALPHAUP^SSUTIL4(rkno))) {
        Quit $$$ERROR($$$GeneralError,"入库单已存在，禁止重复提交: "_rkno)
    }

    Quit $$$OK
}

}
