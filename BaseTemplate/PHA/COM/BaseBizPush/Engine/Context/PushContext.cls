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

/// 统一业务上下文
/// - Info: 入口取数主信息
/// - Data: 入口取数后的业务明细
Property Biz As PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO;

/// 触发模式(AUTO / MANUAL)
Property TriggerMode As %String;

/// 允许执行的 TargetClass 白名单
/// 示例：{"PHA.Target.A":1}
Property AllowedTargetClasses As %DynamicObject;

Method %OnNew() As %Status
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    quit $$$OK
}

Method SetBizInfo(info As %DynamicObject)
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    do ..Biz.SetInfo(##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).NormalizeInfo(info))
}

Method GetBizInfo() As %DynamicObject
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    quit ..Biz.GetInfo()
}

Method SetBizData(data As %DynamicObject)
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    do ..Biz.SetData(data)
}

Method GetBizData() As %DynamicObject
{
    if '$isobject(..Biz) {
        set ..Biz = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).%New()
    }
    quit ..Biz.GetData()
}

}
