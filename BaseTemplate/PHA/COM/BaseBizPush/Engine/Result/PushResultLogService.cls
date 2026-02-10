/// 单目标推送结果日志服务
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Engine.Result.PushResultLogService Extends %RegisteredObject
{

/// 记录单目标推送结果日志（失败不影响主流程）
ClassMethod Write(r As PHA.COM.BaseBizPush.Engine.Result.PushResult, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext = "") As %Status
{
    if '$isobject(r) quit $$$ERROR($$$GeneralError, "PushResult为空")

    try {
        set logRowId = ""
        set dto = r.ToFrontDTO()
        if $isobject(ctx) {
            set ctxInfo = {
                "triggerCode": (ctx.TriggerCode),
                "hospId": (ctx.HospId),
                "deptCode": (ctx.DeptCode),
                "triggerMode": (ctx.TriggerMode),
                "bizInfo": (ctx.GetBizInfo()),
                "bizData": (ctx.GetBizData())
            }
            if $isobject(ctx.AllowedTargetClasses) {
                set ctxInfo.allowedTargetClasses = ctx.AllowedTargetClasses
            }
            set dto.context = ctxInfo
            set manualReq = {
                "entryCode": (ctx.TriggerCode),
                "hospId": (ctx.HospId),
                "deptCode": (ctx.DeptCode),
                "bizInfo": (ctx.GetBizInfo()),
                "targetClasses": []
            }
            if $isobject(ctx.AllowedTargetClasses) {
                set iter = ctx.AllowedTargetClasses.%GetIterator()
                while iter.%GetNext(.key, .value) {
                    if value = 1 {
                        do manualReq.targetClasses.%Push(key)
                    }
                }
            }
            set dto.manualRequest = manualReq
        }
        set payload = dto.%ToJSON()
        set user = ##class(PHA.COM.Err).GetSessionVal("LOGON.USERID","")

        do ##class(PHA.FACE.COM.Log).Log(.logRowId, "", "OP", "PHA.COM.BaseBizPush.Business.App.PushService", "Push", , "", user, "")
        do ##class(PHA.FACE.COM.Log).Log(.logRowId, payload)
    } catch ex {
        quit $$$ERROR($$$GeneralError, "记录推送结果日志失败: "_ex.DisplayString())
    }

    quit $$$OK
}

}
