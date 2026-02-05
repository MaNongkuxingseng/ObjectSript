/// 人工重推单目标结果 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultItemDTO Extends %SerialObject
{

/// 前端关键字
Property Keyword As %String;

/// Target 唯一标识（类名）
Property TargetClass As %String;

/// 是否成功
Property Success As %Boolean;

/// 结果信息
Property Message As %String;

}
