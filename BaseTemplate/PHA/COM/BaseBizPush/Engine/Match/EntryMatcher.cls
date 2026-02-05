Class PHA.COM.BaseBizPush.Engine.Match.EntryMatcher Extends %RegisteredObject
{

/// 判断某个入口注册是否与当前推送上下文匹配
ClassMethod IsMatch(reg As PHA.COM.BaseBizPush.Engine.Definition.PushRegistration, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Boolean
{
    // 入口动作必须一致（入口类已保证 ActionCode 语义）
    
    // 院区匹配（支持未来扩展）
    if '##class(PHA.COM.BaseBizPush.Engine.Match.EntryMatcher).MatchValue(reg.HospId, ctx.HospId) {
        q 0
    }

    // 科室匹配
    if '##class(PHA.COM.BaseBizPush.Engine.Match.EntryMatcher).MatchValue(reg.DeptCode, ctx.DeptCode) {
        q 0
    }

    q 1
}

/// 基础值匹配策略（当前等值，后续可扩展）
ClassMethod MatchValue(regValue As %String, ctxValue As %String) As %Boolean
{
    // 精确匹配
    if regValue = ctxValue {
        q 1
    }

    // 预留：支持 ALL / * / 空值
    if regValue = "ALL" q 1

    q 0
}

}
