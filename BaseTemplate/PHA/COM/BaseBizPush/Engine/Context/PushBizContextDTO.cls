/// 推送业务上下文 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO Extends %SerialObject
{

/// 业务主信息（用于取数）
Property Info As %DynamicObject;

/// 业务明细数据（GetBizData 后写入）
Property Data As %DynamicObject;

Method %OnNew() As %Status
{
    if '$isobject(..Info) set ..Info = {}
    if '$isobject(..Data) set ..Data = {}
    quit $$$OK
}

Method SetInfo(info As %DynamicObject)
{
    set ..Info = $case($isobject(info),1:info,:{})
}

Method SetData(data As %DynamicObject)
{
    set ..Data = $case($isobject(data),1:data,:{})
}

Method GetInfo() As %DynamicObject
{
    quit $case($isobject(..Info),1:..Info,:{})
}

Method GetData() As %DynamicObject
{
    quit $case($isobject(..Data),1:..Data,:{})
}

}
