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
    set ..Info = ..EnsureObject(info)
}

Method SetData(data As %DynamicObject)
{
    set ..Data = ..EnsureObject(data)
}

Method GetInfo() As %DynamicObject
{
    quit ..EnsureObject(..Info)
}

Method GetData() As %DynamicObject
{
    quit ..EnsureObject(..Data)
}

/// 归一化业务主信息：规范结构 data.id/data.no + 兼容历史字段
ClassMethod NormalizeInfo(info As %DynamicObject) As %DynamicObject
{
    set o = ..EnsureObject(info)

    if 'o.%IsDefined("data") || '$isobject(o.data) {
        set o.data = {}
    }
    if 'o.%IsDefined("ext") || '$isobject(o.ext) {
        set o.ext = {}
    }

    if '$data(o.data.id) || o.data.id="" {
        set o.data.id = ..PickFirst(o, "id,rowId,phd,dspId,refundId,phdReturn")
    }
    if '$data(o.data.no) || o.data.no="" {
        set o.data.no = ..PickFirst(o, "no,prescNo,billNo")
    }

    quit o
}

ClassMethod GetId(info As %DynamicObject) As %String
{
    set o = ..NormalizeInfo(info)
    quit $get(o.data.id)
}

ClassMethod GetNo(info As %DynamicObject) As %String
{
    set o = ..NormalizeInfo(info)
    quit $get(o.data.no)
}

ClassMethod PickFirst(obj As %DynamicObject, keys As %String) As %String
{
    for i=1:1:$length(keys,",") {
        set key = $piece(keys,",",i)
        continue:key=""
        if obj.%IsDefined(key), obj.%Get(key)'="" {
            quit obj.%Get(key)
        }
    }
    quit ""
}

ClassMethod EnsureObject(o As %DynamicObject) As %DynamicObject
{
    quit $case($isobject(o),1:o,:{})
}

}
