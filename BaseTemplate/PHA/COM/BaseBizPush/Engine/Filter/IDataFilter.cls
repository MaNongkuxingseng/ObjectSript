/// 推送数据过滤器抽象接口。
/// 用于在推送前进行业务逻辑过滤，如判断发药类型、业务条件等。
///   
Class PHA.COM.BaseBizPush.Engine.Filter.IDataFilter Extends %RegisteredObject [ Abstract ]
{

/// 判断是否应该过滤此数据
Method ShouldFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Boolean
{
}

/// 获取过滤原因描述
Method GetFilterMessage(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %String
{
}

}
