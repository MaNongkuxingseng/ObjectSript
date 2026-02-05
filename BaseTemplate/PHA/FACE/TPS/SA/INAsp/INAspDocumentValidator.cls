/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 文档验证器，验证调价文档数据
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspDocumentValidator Extends PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 验证文档数据
/// Input: doc - PHA.FACE.TPS.SA.Template.Context.Document 文档对象
/// Output: %Status - 验证状态
Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status
{
	If doc.Data.rows.%Size()=0 {
		Quit $$$ERROR($$$GeneralError,"调价明细不能为空")
	}
	Quit $$$OK
}

}
