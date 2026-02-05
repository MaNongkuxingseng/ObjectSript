/// 单据级校验器
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 对退货单据进行业务级校验
Class PHA.FACE.TPS.SA.INRet.InRetDocumentValidator Extends PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{

/// 单据级校验方法
/// Business Logic: 退货单号不能为空
Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status
{
	Set thno = doc.Data.main.thno
    If thno = "" {
        Quit $$$ERROR($$$GeneralError,"单据校验失败:退货单号不能为空")
    }
    
    If $Data(^INGRT(0,"RETNO",$$ALPHAUP^SSUTIL4(thno))) {
        Quit $$$ERROR($$$GeneralError,"退货单已存在，禁止重复提交: "_thno)
    }
    Quit $$$OK
}

}
