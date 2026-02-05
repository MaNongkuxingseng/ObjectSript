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

/// 业务数据(business data)
Property BizData As %DynamicObject;

/// 触发模式(AUTO / MANUAL)
Property TriggerMode As %String;

/// 允许执行的 TargetClass 白名单
/// 示例：{"PHA.Target.A":1}
/// 
Property AllowedTargetClasses As %DynamicObject;

}
