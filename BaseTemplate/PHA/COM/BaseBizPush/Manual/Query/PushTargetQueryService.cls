/// 人工重推目标查询服务
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.Query.PushTargetQueryService Extends %RegisteredObject
{

/// 根据当前上下文查询可参与重推的 Target 列表
/// 说明：Entry 是唯一执行单元，Target 仅用于前端选择参与项
ClassMethod Query(entryCode As %String, hospId As %String, deptCode As %String) As PHA.COM.BaseBizPush.Manual.DTO.PushTargetQueryResponseDTO
{
    set resp = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushTargetQueryResponseDTO).%New()
    do ..InitResponse(resp)

    if entryCode = "" {
        set resp.Message = "entryCode不能为空"
        quit resp
    }

    set entryClass = ##class(PHA.COM.BaseBizPush.Business.App.PushService).ResolveEntryClass(entryCode)
    if entryClass = "" {
        set resp.Message = "未找到业务入口["_entryCode_"]"
        quit resp
    }

    set entry = $classmethod(entryClass, "%New")
    set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    set ctx.TriggerCode = entryCode
    set ctx.HospId = hospId
    set ctx.DeptCode = deptCode

    set seen = {}
    set regs = entry.Registrations()
    for i=1:1:regs.Count() {
        set reg = regs.GetAt(i)
        continue:'##class(PHA.COM.BaseBizPush.Engine.Match.EntryMatcher).IsMatch(reg, ctx)

        for j=1:1:reg.Targets.Count() {
            set treg = reg.Targets.GetAt(j)
            set cls = treg.TargetClass
            continue:cls=""
            continue:$get(seen.(cls))=1

            set target = $classmethod(cls, "%New")
            set item = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushTargetInfoDTO).%New()
            set item.TargetClass = cls
            set item.DisplayName = target.GetName()
            set item.Keyword = ..BuildKeyword(cls)

            do resp.Targets.Insert(item)
            do resp.Keywords.Insert(item.Keyword)
            set seen.(cls)=1
        }
    }

    set resp.Total = resp.Targets.Count()
    set resp.Success = 1
    set resp.Message = "ok"
    quit resp
}

/// 初始化响应对象
ClassMethod InitResponse(ByRef resp As PHA.COM.BaseBizPush.Manual.DTO.PushTargetQueryResponseDTO)
{
    set resp.Success = 0
    set resp.Message = ""
    set resp.Targets = ##class(%ListOfObjects).%New()
    set resp.Keywords = ##class(%ListOfDataTypes).%New()
    set resp.Total = 0
}

/// 生成前端关键字（hisui 可直接用）
ClassMethod BuildKeyword(targetClass As %String) As %String
{
    // 约定：以类名作为唯一关键字，保证前后端一致映射
    quit targetClass
}

}
