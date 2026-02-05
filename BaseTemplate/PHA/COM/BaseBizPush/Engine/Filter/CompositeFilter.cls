/// 复合过滤器，支持多个过滤条件的AND/OR组合。
///   
Class PHA.COM.BaseBizPush.Engine.Filter.CompositeFilter Extends PHA.COM.BaseBizPush.Engine.Filter.IDataFilter
{

/// 过滤器列表
Property Filters As list Of PHA.COM.BaseBizPush.Engine.Filter.IDataFilter;

/// 逻辑类型：AND（所有条件都满足）或 OR（任一条件满足）
Property LogicType As %String [ InitialExpression = "AND" ];

Method ShouldFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Boolean
{
        s filterCount = ..Filters.Count()
        if (filterCount = 0) q 0
        
        if (..LogicType = "AND") {
            // AND逻辑：所有过滤器都返回true时才过滤
            for i=1:1:filterCount {
                s filter = ..Filters.GetAt(i)
                if ('filter.ShouldFilter(bizData, ctx)) {
                    return 0  // 有一个不满足就不过滤
                }
            }
            q 1  // 所有条件都满足，过滤
        } else {
            // OR逻辑：任一过滤器返回true就过滤
            for i=1:1:filterCount {
                s filter = ..Filters.GetAt(i)
                if (filter.ShouldFilter(bizData, ctx)) {
                    return 1  // 有一个满足就过滤
                }
            }
            q 0  // 所有条件都不满足，不过滤
        }
}

Method GetFilterMessage(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %String
{
        s messages = ""
        for i=1:1:..Filters.Count() {
            s filter = ..Filters.GetAt(i)
            if (filter.ShouldFilter(bizData, ctx)) {
                s msg = filter.GetFilterMessage(bizData, ctx)
                if (messages '= "") s messages = messages _ "; "
                s messages = messages _ msg
            }
        }
        q messages
}

Method AddFilter(filter As PHA.COM.BaseBizPush.Engine.Filter.IDataFilter)
{
        d ..Filters.Insert(filter)
}

}
