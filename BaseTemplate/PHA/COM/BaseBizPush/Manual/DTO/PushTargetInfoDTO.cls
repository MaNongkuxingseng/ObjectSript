/// 人工重推目标简要信息 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushTargetInfoDTO Extends %SerialObject
{

/// 前端关键字（用于 hisui 可选项）
Property Keyword As %String;

/// Target 唯一标识（类名）
Property TargetClass As %String;

/// 展示名称
Property DisplayName As %String;

}
