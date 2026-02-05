/// BizInfo 公共上下文约定工具
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Engine.Context.BizInfoContext Extends %RegisteredObject
{

/// 规范结构：{"data":{"id":"","no":""},"ext":{}}
ClassMethod Normalize(bizInfo As %DynamicObject) As %DynamicObject
{
    set info = $case($isobject(bizInfo), 1:bizInfo, :{})

    if 'info.%IsDefined("data") || '$isobject(info.data) {
        set info.data = {}
    }
    if 'info.%IsDefined("ext") || '$isobject(info.ext) {
        set info.ext = {}
    }

    // 兼容历史字段映射到 data.id
    if '$data(info.data.id) || info.data.id="" {
        set info.data.id = ..PickFirst(info, "id,rowId,phd,dspId,refundId,phdReturn")
    }

    // 兼容历史字段映射到 data.no
    if '$data(info.data.no) || info.data.no="" {
        set info.data.no = ..PickFirst(info, "no,prescNo,billNo")
    }

    quit info
}

ClassMethod GetId(bizInfo As %DynamicObject) As %String
{
    set info = ..Normalize(bizInfo)
    quit $get(info.data.id)
}

ClassMethod GetNo(bizInfo As %DynamicObject) As %String
{
    set info = ..Normalize(bizInfo)
    quit $get(info.data.no)
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

}
