/// 推送目标抽象接口定义。
/// 每个 Target 负责：
///   - 数据组织
///   - 平台调用定义
///   - 返回解析
///   - 数据过滤（可选）
///   
Class PHA.COM.BaseBizPush.Engine.Target.ITarget Extends %RegisteredObject [ Abstract ]
{

Method GetCode() As %String [ Abstract ]
{
}

Method GetName() As %String [ Abstract ]
{
}

Method GetDesc() As %String [ Abstract ]
{
}

Method IsAsync() As %Boolean [ Abstract ]
{
}

/// 获取数据过滤器（可选，返回空表示不过滤）
Method GetDataFilter() As PHA.COM.BaseBizPush.Engine.Filter.IDataFilter
{
	q ""
}

/// target自定义的数据过滤
Method CheckDataFilte(bizData As %DynamicObject) As %Boolean [ Abstract ]
{
	q ""
}

Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.Object [ Abstract ]
{
}

/// 已经使用了PHA.COM.BaseBizPush.Engine.Platform.Adapter.PlatformAdapter对象来作平台处理
/// 此处仅提供基本的##class(platformclass).platformmethod(code = "", streamdata) 方式的调用
Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
}

Method ParseResponse(rawResp) As %DynamicObject [ Abstract ]
{
}

Method IsSuccess(parsedResp As %DynamicObject) As %Boolean [ Abstract ]
{
}

Method BuildResultMessage(parsedResp As %DynamicObject) As %String [ Abstract ]
{
}

/// 自定义数据过滤方法（新增）
/// 直接在Target中进行业务逻辑过滤判断
/// 返回结构化的过滤结果对象
/// {
///   "passed": 1/0,      // 是否通过过滤（1=通过，0=被过滤）
///   "message": "说明",  // 过滤结果消息
///   "data": {}          // 附加数据（可选）
/// }
Method CustomFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    // 默认实现返回通过
    set result = {}
    set result.passed = 1
    set result.message = "通过自定义过滤"
    set result.data = {}
    return result
}

/// 更新过滤结果（辅助方法）
Method UpdateFilterResult(ByRef result As %DynamicObject, passed As %Boolean, message As %String)
{
    // 如果已经失败，保持失败状态，只更新消息
    if (result.passed = 0) && (passed = 0) {
        // 追加错误消息
        if result.message '= "" {
            set result.message = result.message _ "; " _ message
        } else {
            set result.message = message
        }
    } else {
        // 更新状态
        set result.passed = passed
        set result.message = message
    }
}

}
