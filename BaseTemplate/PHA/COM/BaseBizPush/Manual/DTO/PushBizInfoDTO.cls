/// 人工重推业务主信息 DTO（收敛常见主键）
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushBizInfoDTO Extends %SerialObject
{

/// 通用主键ID（推荐）
Property Id As %String;

/// 通用业务单号（推荐）
Property No As %String;

/// 历史兼容字段：发药单号
Property Phd As %String;

/// 历史兼容字段：退费单号
Property RefundId As %String;

/// 历史兼容字段：住院发药ID
Property DspId As %String;

/// 历史兼容字段：退药单号
Property PhdReturn As %String;

/// 历史兼容字段：处方号
Property PrescNo As %String;

/// 历史兼容字段：业务单号
Property BillNo As %String;

/// 扩展字段（受控扩展入口）
Property Ext As %DynamicObject;

Method %OnNew() As %Status
{
    if '$isobject(..Ext) {
        set ..Ext = {}
    }
    quit $$$OK
}

/// 转为引擎可用 DynamicObject
Method ToDynamicObject() As %DynamicObject
{
    set o = {
        "data": {
            "id": (..Id),
            "no": (..No)
        },
        "id": (..Id),
        "no": (..No),
        "phd": (..Phd),
        "refundId": (..RefundId),
        "dspId": (..DspId),
        "phdReturn": (..PhdReturn),
        "prescNo": (..PrescNo),
        "billNo": (..BillNo),
        "ext": {}
    }

    if $isobject(..Ext) {
        set o.ext = ..Ext
    }

    quit o
}

/// 由 DynamicObject 反序列化为 DTO
ClassMethod FromDynamicObject(dyn As %DynamicObject) As PHA.COM.BaseBizPush.Manual.DTO.PushBizInfoDTO
{
    set dto = ..%New()
    if '$isobject(dyn) quit dto

    // data 优先
    if dyn.%IsDefined("data") && $isobject(dyn.data) {
        set dto.Id = $select(dyn.data.%IsDefined("id"):dyn.data.%Get("id"),1:"")
        set dto.No = $select(dyn.data.%IsDefined("no"):dyn.data.%Get("no"),1:"")
    }

    // 顶层回填
    if dto.Id="" set dto.Id = $select(dyn.%IsDefined("id"):dyn.%Get("id"),1:"")
    if dto.No="" set dto.No = $select(dyn.%IsDefined("no"):dyn.%Get("no"),1:"")

    set dto.Phd = $select(dyn.%IsDefined("phd"):dyn.%Get("phd"),1:"")
    set dto.RefundId = $select(dyn.%IsDefined("refundId"):dyn.%Get("refundId"),1:"")
    set dto.DspId = $select(dyn.%IsDefined("dspId"):dyn.%Get("dspId"),1:"")
    set dto.PhdReturn = $select(dyn.%IsDefined("phdReturn"):dyn.%Get("phdReturn"),1:"")
    set dto.PrescNo = $select(dyn.%IsDefined("prescNo"):dyn.%Get("prescNo"),1:"")
    set dto.BillNo = $select(dyn.%IsDefined("billNo"):dyn.%Get("billNo"),1:"")

    if dyn.%IsDefined("ext") && $isobject(dyn.ext) {
        set dto.Ext = dyn.ext
    }

    quit dto
}

}
