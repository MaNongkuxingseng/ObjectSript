/// 退药批次明细 DTO
Class PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchItem Extends %RegisteredObject
{

/// 客户（患者登记号）
Property FCustomerID As %String;

/// 医嘱ID
Property Order As %String;

/// 药品代码
Property FMaterialID As %String;

/// 药品名称
Property FMaterialIDdesc As %String;

/// 退药单位
Property FUnitID As %String;

/// 实际退药数量（负数）
Property FRealQty As %Numeric;

/// 含税单价
Property FTaxPrice As %Numeric;

/// 税率
Property FEntryTaxRate As %Numeric;

/// 退药金额（负数）
Property ypssje As %Numeric;

/// 批号
Property Ypph As %String;

/// 批次号
Property Batid As %String;

Method ToJSONObj() As %DynamicObject
{
    Set json = {}
    Do json.%Set("FCustomerID", ..FCustomerID)
    Do json.%Set("Order", ..Order)
    Do json.%Set("FMaterialID", ..FMaterialID)
    Do json.%Set("FMaterialIDdesc", ..FMaterialIDdesc)
    Do json.%Set("FUnitID", ..FUnitID)
    Do json.%Set("FRealQty", ..FRealQty)
    Do json.%Set("FTaxPrice", ..FTaxPrice)
    Do json.%Set("FEntryTaxRate", ..FEntryTaxRate)
    Do json.%Set("ypssje", ..ypssje)
    Do json.%Set("Ypph", ..Ypph)
    Do json.%Set("Batid", ..Batid)
    Quit json
}

}
