/// 推送能力查询服务
/// Author: Valen MPF
/// 
Class PHA.COM.BaseBizPush.App.PushCapabilityService Extends %RegisteredObject
{

/// 查询指定业务入口下可人工重推的 Target
ClassMethod QueryAvailableTargets(entryCode As %String, hospId As %String, deptCode As %String) As PHA.COM.BaseBizPush.DTO.PushTargetQueryResultDTO
{
    s result = ##class(PHA.COM.BaseBizPush.DTO.PushTargetQueryResultDTO).%New()
    s result.EntryCode = entryCode
    s result.HospId = hospId
    s result.DeptCode = deptCode
    s result.Targets = ##class(%ListOfObjects).%New()

    s ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    s ctx.TriggerCode = entryCode
    s ctx.HospId = hospId
    s ctx.DeptCode = deptCode

    s entryClass = ##class(PHA.COM.BaseBizPush.Business.App.PushService).ResolveEntryClass(entryCode)
    q:entryClass="" result

    s entry = $classmethod(entryClass, "%New")
    s result.EntryName = entry.ActionName()

    s regs = entry.Registrations()
    for i=1:1:regs.Count() {
        s reg = regs.GetAt(i)
        i '##class(PHA.COM.BaseBizPush.Engine.Match.EntryMatcher).IsMatch(reg, ctx) {
            continue
        }

        for j=1:1:reg.Targets.Count() {
            s treg = reg.Targets.GetAt(j)
            s target = $classmethod(treg.TargetClass, "%New")

            s dto = ##class(PHA.COM.BaseBizPush.DTO.PushTargetDTO).%New()
            s dto.Key = treg.TargetClass
            s dto.Label = target.GetName()
            s dto.Desc = target.GetDesc()

            s dto.EntryCode = entryCode
            s dto.HospId = reg.HospId
            s dto.DeptCode = reg.DeptCode

            s dto.TargetClass = treg.TargetClass
            s dto.PlatformClass = treg.PlatformClass
            s dto.PlatformMethod = treg.MethodName

            s dto.SupportRetry = 1
            s dto.DefaultSelected = 0

            d result.Targets.Insert(dto)
        }
    }

    s result.Total = result.Targets.Count()
    s result.Timestamp = $zdt($h,3)
    q result
}

}
