Class PHA.FACE.TPS.SA.INRec.BizHandler Extends (PHA.FACE.TPS.SA.Template.Pipeline.Handler, PHA.COM.Base)
{

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    // 注意：MappingHandler 已经生成 doc.Data 包含 Main/Rows
    // 如果需要额外处理 HIS 字段，可在此扩展
    s sc = $$$OK
    TStart
    For i=1:1:context.Documents.Count() {
        Set doc=context.Documents.GetAt(i)
        Set hisData=doc.Data
        ; 此处直接调用 HIS 接口
        Write !,"SEND TO HIS:",hisData.%ToJSON()
        //s ret = ##class(PHA.IN.REC.Api).HandleSave(hisData)
        s ret = ##class(PHA.IN.REC.Biz).HandleSaveFinish(hisData)
        if ($$$phaIsError(ret)) {
	        tro
	        s sc = $$$ERROR($$$GeneralError,"HIS处理数据失败:"_ret)
	        return sc
        }
        // 处理审核流程。
        s recId = ret
		s recData = ##class(PHA.IN.REC.Data).GetMainData(recId)
		//d recData.%Set("statusCode",recData.%Get("status"))
        Set sc = ##class(PHA.FACE.TPS.SA.INRec.Method).AutoAuditCore(recData)
        If $$$ISERR(sc) {
	        tro
            return sc
        }
    }
    tc
    Quit sc
}

}
