/// 人工重推执行结果 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushExecuteResultDTO Extends %SerialObject
{

/// 总体是否成功
Property Success As %Boolean;

/// 总体消息
Property Message As %String;

/// 成功数
Property SuccessCount As %Integer;

/// 失败数
Property FailureCount As %Integer;

/// 明细（一个 Target 一个结果）
Property Items As list Of %ListOfObjects;

}
