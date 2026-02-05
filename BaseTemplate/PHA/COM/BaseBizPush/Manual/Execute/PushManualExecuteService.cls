/// 人工重推执行服务
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.Execute.PushManualExecuteService Extends %RegisteredObject
{

/// 执行指定 TargetClass 的人工重推
/// 说明：
/// 1) 只执行 Entry.Execute
/// 2) Target 仅作为白名单参与 Entry 内部流程
/// 3) 通过重建 PushContext + BizInfo 触发 Entry 内部重新取数
ClassMethod Execute(req As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO) As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultDTO
{
    set resp = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultDTO).%New()
    do ..InitResponse(resp)

    set msg = ..ValidateRequest(req)
    if msg '= "" {
        set resp.Message = msg
        quit resp
    }

    set entryClass = ##class(PHA.COM.BaseBizPush.Business.App.PushService).ResolveEntryClass(req.EntryCode)
    if entryClass = "" {
        set resp.Message = "未找到业务入口["_req.EntryCode_"]"
        quit resp
    }

    set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    set ctx.TriggerCode = req.EntryCode
    set ctx.HospId = req.HospId
    set ctx.DeptCode = req.DeptCode
    set ctx.BizInfo = req.BizInfo
    set ctx.TriggerMode = "MANUAL"
    set ctx.AllowedTargetClasses = ..BuildAllowedMap(req.TargetClasses)

    set entry = $classmethod(entryClass, "%New")
    set summary = entry.Execute(ctx)

    do ..BuildItems(resp, summary, req.TargetClasses)
    set resp.Success = (resp.FailureCount=0)
    set resp.Message = $select(resp.Success: "ok", 1: "执行完成，存在失败项")
    quit resp
}

ClassMethod InitResponse(ByRef resp As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultDTO)
{
    set resp.Success = 0
    set resp.Message = ""
    set resp.SuccessCount = 0
    set resp.FailureCount = 0
    set resp.Items = ##class(%ListOfObjects).%New()
}

ClassMethod ValidateRequest(req As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO) As %String
{
    if '$isobject(req) quit "请求不能为空"
    if req.EntryCode = "" quit "entryCode不能为空"
    if req.HospId = "" quit "hospId不能为空"
    if req.DeptCode = "" quit "deptCode不能为空"
    if '$isobject(req.TargetClasses) quit "targetClasses不能为空"
    if req.TargetClasses.Count()=0 quit "targetClasses不能为空"
    quit ""
}

ClassMethod BuildAllowedMap(targetClasses As %ListOfDataTypes) As %DynamicObject
{
    set map = {}
    for i=1:1:targetClasses.Count() {
        set cls = targetClasses.GetAt(i)
        continue:cls=""
        set map.(cls) = 1
    }
    quit map
}

/// 将引擎结果封装为前端最小可用结构（一个 Target 一个结果）
ClassMethod BuildItems(ByRef resp As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultDTO, summary As PHA.COM.BaseBizPush.Engine.Result.PushSummary, selected As %ListOfDataTypes)
{
    set seen = {}

    for i=1:1:summary.Results.Count() {
        set r = summary.Results.GetAt(i)
        continue:r.TargetClass=""
        continue:'..InList(selected, r.TargetClass)

        set item = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultItemDTO).%New()
        set item.TargetClass = r.TargetClass
        set item.Keyword = r.TargetClass
        set item.Success = r.Success
        set item.Message = r.Message

        do resp.Items.Insert(item)
        set seen.(r.TargetClass)=1

        if item.Success {
            set resp.SuccessCount = resp.SuccessCount + 1
        } else {
            set resp.FailureCount = resp.FailureCount + 1
        }
    }

    // 对未返回结果的已选 Target 补充失败项，避免前端对不齐
    for j=1:1:selected.Count() {
        set cls = selected.GetAt(j)
        continue:cls=""
        continue:$get(seen.(cls))=1

        set miss = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultItemDTO).%New()
        set miss.TargetClass = cls
        set miss.Keyword = cls
        set miss.Success = 0
        set miss.Message = "未产生执行结果"
        do resp.Items.Insert(miss)
        set resp.FailureCount = resp.FailureCount + 1
    }
}

ClassMethod InList(list As %ListOfDataTypes, value As %String) As %Boolean
{
    if '$isobject(list) quit 0
    for i=1:1:list.Count() {
        if list.GetAt(i)=value quit 1
    }
    quit 0
}

}
