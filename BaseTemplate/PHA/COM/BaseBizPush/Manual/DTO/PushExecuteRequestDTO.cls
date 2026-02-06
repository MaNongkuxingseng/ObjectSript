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

/// 业务主信息（强约束 DTO，避免 DynamicObject 无序扩张）
Property BizInfo As PHA.COM.BaseBizPush.Manual.DTO.PushBizInfoDTO;

/// 选中的 TargetClass 列表
Property TargetClasses As list Of %ListOfDataTypes;

Method %OnNew() As %Status
{
    if '$isobject(..BizInfo) {
        set ..BizInfo = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushBizInfoDTO).%New()
    }
    quit $$$OK
}

/// 由动态对象反序列化请求
ClassMethod FromDynamicObject(dyn As %DynamicObject) As PHA.COM.BaseBizPush.Manual.DTO.PushExecuteRequestDTO
{
    set req = ..%New()
    if '$isobject(dyn) quit req

    set req.EntryCode = $get(dyn.entryCode)
    set req.HospId = $get(dyn.hospId)
    set req.DeptCode = $get(dyn.deptCode)

    if dyn.%IsDefined("bizInfo") && $isobject(dyn.bizInfo) {
        set req.BizInfo = ##class(PHA.COM.BaseBizPush.Manual.DTO.PushBizInfoDTO).FromDynamicObject(dyn.bizInfo)
    }

    if dyn.%IsDefined("targetClasses") && $isobject(dyn.targetClasses) {
        set list = ##class(%ListOfDataTypes).%New()
        for i=0:1:dyn.targetClasses.%Size()-1 {
            do list.Insert(dyn.targetClasses.%Get(i))
        }
        set req.TargetClasses = list
    }

    quit req
}

}
