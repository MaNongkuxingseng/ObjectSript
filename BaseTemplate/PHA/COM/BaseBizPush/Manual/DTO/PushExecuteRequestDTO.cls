/// 人工重推执行请求 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO Extends %SerialObject
{

/// 入口编码（唯一执行单元）
Property EntryCode As %String;

/// 当前院区
Property HospId As %String;

/// 当前科室
Property DeptCode As %String;

/// 业务主信息（Entry 内部据此重新获取 bizData）
Property BizInfo As %DynamicObject;

/// 选中的 TargetClass 列表
Property TargetClasses As list Of %ListOfDataTypes;

}
