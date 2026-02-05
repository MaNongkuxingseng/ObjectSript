/// 人工推送执行服务
/// Author: Valen MPF
/// 
Class PHA.COM.BaseBizPush.App.PushManualExecuteService Extends %RegisteredObject
{

/// 通过控制 Context，仅执行指定 TargetClass
ClassMethod ExecuteByTargets(req As PHA.COM.BaseBizPush.DTO.PushExecuteRequestDTO) As %Status
{
    s ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    s ctx.TriggerCode = req.EntryCode
    s ctx.HospId = req.HospId
    s ctx.DeptCode = req.DeptCode
    s ctx.TriggerMode = "MANUAL"

    s ctx.AllowedTargetClasses = {}
    for i=1:1:req.TargetClasses.Count() {
        s ctx.AllowedTargetClasses.(req.TargetClasses.GetAt(i)) = 1
    }

    s entryClass = ##class(PHA.COM.BaseBizPush.Business.App.PushService).ResolveEntryClass(req.EntryCode)
    q:entryClass="" $$$ERROR($$$GeneralError,"Entry not found")

    s entry = $classmethod(entryClass, "%New")
    q entry.Execute(.ctx)
}

}
