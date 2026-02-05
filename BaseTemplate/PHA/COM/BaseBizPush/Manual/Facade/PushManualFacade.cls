/// 人工重推前端 Facade
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.Facade.PushManualFacade Extends %RegisteredObject
{

/// 前端查询可用推送目标
/// 入参最小化：entryCode + 当前上下文(hospId,deptCode)
ClassMethod QueryTargets(entryCode As %String, hospId As %String, deptCode As %String) As %DynamicObject
{
    set resp = ##class(PHA.COM.BaseBizPush.Manual.Query.PushTargetQueryService).Query(entryCode, hospId, deptCode)
    quit resp.ToDynamicObject()
}

/// 前端执行选中目标（强类型 DTO）
ClassMethod Execute(req As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO) As %DynamicObject
{
    set resp = ##class(PHA.COM.BaseBizPush.Manual.Execute.PushManualExecuteService).Execute(req)
    quit resp.ToDynamicObject()
}

/// 前端执行选中目标（动态对象入参，内部反序列化）
ClassMethod ExecuteByDynamic(reqDyn As %DynamicObject) As %DynamicObject
{
    set req = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO).FromDynamicObject(reqDyn)
    quit ..Execute(req)
}

}
