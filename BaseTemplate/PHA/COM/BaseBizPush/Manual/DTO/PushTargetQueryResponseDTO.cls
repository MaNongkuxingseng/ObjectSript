/// 人工重推目标查询响应 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushTargetQueryResponseDTO Extends %SerialObject
{

/// 查询是否成功
Property Success As %Boolean;

/// 响应消息
Property Message As %String;

/// 可选目标列表
Property Targets As list Of %ListOfObjects;

/// hisui 关键字列表（与 Targets 对齐）
Property Keywords As list Of %ListOfDataTypes;

/// 数量
Property Total As %Integer;

}
