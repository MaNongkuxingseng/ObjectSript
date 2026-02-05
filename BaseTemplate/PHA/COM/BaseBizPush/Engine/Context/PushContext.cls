/// 推送执行上下文
/// Author: Valen MPF
/// 
Class PHA.COM.BaseBizPush.Engine.Context.PushContext Extends %RegisteredObject
{

/// 业务入口编码(entry code)
Property TriggerCode As %String;

/// 医院ID(hospital id)
Property HospId As %String;

/// 科室ID(department id)
Property DeptCode As %String;

/// 统一业务上下文（推荐使用）
Property Biz As PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO;

/// 业务主信息（兼容字段，建议使用 GetBizInfo/SetBizInfo）
/// 推荐约定：{"data":{"id":"","no":""},"ext":{}}
/// 兼容历史：phd/refundId/prescNo 等字段可由 BizInfoContext 归一化
Property BizInfo As %DynamicObject;

/// 业务数据（兼容字段，建议使用 GetBizData/SetBizData）
Property BizData As %DynamicObject;

/// 触发模式(AUTO / MANUAL)
Property TriggerMode As %String;

/// 允许执行的 TargetClass 白名单
/// 示例：{"PHA.Target.A":1}
/// 
Property AllowedTargetClasses As %DynamicObject;

Method %OnNew() As %Status
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    quit $$$OK
}

/// 设置业务主信息（统一写入 Biz.Info + 兼容字段）
Method SetBizInfo(info As %DynamicObject)
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    do ..Biz.SetInfo(info)
    set ..BizInfo = ..Biz.GetInfo()
}

/// 获取业务主信息（优先 Biz.Info）
Method GetBizInfo() As %DynamicObject
{
    if $isobject(..Biz) {
        set info = ..Biz.GetInfo()
        if $isobject(info) quit info
    }
    quit $case($isobject(..BizInfo),1:..BizInfo,:{})
}

/// 设置业务数据（统一写入 Biz.Data + 兼容字段）
Method SetBizData(data As %DynamicObject)
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    do ..Biz.SetData(data)
    set ..BizData = ..Biz.GetData()
}

/// 获取业务数据（优先 Biz.Data）
Method GetBizData() As %DynamicObject
{
    if $isobject(..Biz) {
        set data = ..Biz.GetData()
        if $isobject(data) quit data
    }
    quit $case($isobject(..BizData),1:..BizData,:{})
}

}
