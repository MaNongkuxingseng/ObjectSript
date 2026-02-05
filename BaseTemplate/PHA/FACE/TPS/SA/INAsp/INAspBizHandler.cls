/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 业务处理器，处理调价业务逻辑
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspBizHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 执行业务处理
/// Input: context - PHA.FACE.TPS.SA.Template.Context.DocumentContext 文档上下文对象
/// Output: %Status - 操作状态
Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
	TStart
	For i=1:1:context.Documents.Count() {
		Set doc = context.Documents.GetAt(i)
		Set ret = ##class(PHA.IN.ASP.Api).HandleSave(doc.Data)
		If ret.failureCnt'=0 {
			TROLLBACK
			return $$$ERROR($$$GeneralError,"HIS 调价失败:"_ret.%ToJSON())
		}
	}
	TCommit
	Quit $$$OK
}

}
