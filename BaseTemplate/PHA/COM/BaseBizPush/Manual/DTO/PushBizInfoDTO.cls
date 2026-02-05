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
        set dto.Id = $get(dyn.data.id)
        set dto.No = $get(dyn.data.no)
    }

    // 顶层回填
    if dto.Id="" set dto.Id = $get(dyn.id)
    if dto.No="" set dto.No = $get(dyn.no)

    set dto.Phd = $get(dyn.phd)
    set dto.RefundId = $get(dyn.refundId)
    set dto.DspId = $get(dyn.dspId)
    set dto.PhdReturn = $get(dyn.phdReturn)
    set dto.PrescNo = $get(dyn.prescNo)
    set dto.BillNo = $get(dyn.billNo)

    if dyn.%IsDefined("ext") && $isobject(dyn.ext) {
        set dto.Ext = dyn.ext
    }

    quit dto
}

}
