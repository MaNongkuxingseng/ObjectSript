/// 推送目标查询结果 DTO
/// Author: Valen MPF
/// 
Class PHA.COM.BaseBizPush.DTO.PushTargetQueryResultDTO Extends %SerialObject
{

Property EntryCode As %String;

Property EntryName As %String;

Property HospId As %String;

Property DeptCode As %String;

Property Targets As list Of %ListOfObjects;

Property Total As %Integer;

Property Timestamp As %String;

Storage Default
{
<Data name="PushTargetQueryResultDTOState">
<Value name="1">
<Value>EntryCode</Value>
</Value>
<Value name="2">
<Value>EntryName</Value>
</Value>
<Value name="3">
<Value>HospId</Value>
</Value>
<Value name="4">
<Value>DeptCode</Value>
</Value>
<Value name="5">
<Value>Targets</Value>
</Value>
<Value name="6">
<Value>Total</Value>
</Value>
<Value name="7">
<Value>Timestamp</Value>
</Value>
</Data>
<State>PushTargetQueryResultDTOState</State>
<StreamLocation>^PHA.COM.Ba1EB4.PushTargetQB465S</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}
