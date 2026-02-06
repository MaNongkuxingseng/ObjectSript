/// 单目标推送结果日志服务
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Engine.Result.PushResultLogService Extends %RegisteredObject
{

/// 记录单目标推送结果日志（失败不影响主流程）
ClassMethod Write(r As PHA.COM.BaseBizPush.Engine.Result.PushResult) As %Status
{
    if '$isobject(r) quit $$$ERROR($$$GeneralError, "PushResult为空")

    try {
        set logRowId = ""
        set payload = r.ToFrontDTO().%ToJSON()
        set user = ##class(PHA.COM.Err).GetSessionVal("LOGON.USERID","")

        do ##class(PHA.FACE.COM.Log).Log(.logRowId, "", "OP", "PHA.COM.BaseBizPush.Business.App.PushService", "Push", , "", user, "")
        do ##class(PHA.FACE.COM.Log).Log(.logRowId, payload)
    } catch ex {
        quit $$$ERROR($$$GeneralError, "记录推送结果日志失败: "_ex.DisplayString())
    }

    quit $$$OK
}

}
