/// 发药单据头 DTO
Class PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchHeader Extends %RegisteredObject
{

/// 发药单号
Property FIDNo As %String;

/// 单据类型（发药）
Property FBillTypeID As %String;

/// 业务日期
Property FDate As %TimeStamp;

/// 销售组织（医馆）
Property FSaleOrgId As %String;

/// 销售部门（药房）
Property FSaleDeptID As %String;

Method ToJSONObj() As %DynamicObject
{
    Set json = {}

    Do json.%Set("FIDNo",        ..FIDNo)
    Do json.%Set("FBillTypeID",  ..FBillTypeID)
    Do json.%Set("FDate",        ..FDate)
    Do json.%Set("FSaleOrgId",   ..FSaleOrgId)
    Do json.%Set("FSaleDeptID",  ..FSaleDeptID)

    Quit json
}

}
