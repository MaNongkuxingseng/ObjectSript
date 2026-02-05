/// 发药消耗推送 DTO（Root）
Class PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO Extends %RegisteredObject
{

Property Header As PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchHeader;

Property Items As list Of PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchItem;

Method %OnNew() As %Status
{
    /// 初始化集合，避免空指针
    Set Header = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchHeader).%New()
    Set ..Items = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

/// DTO 转换为 JSON 对象
/// 返回 %DynamicObject，由上层决定是否序列化为字符串
Method ToJSONObj() As %DynamicObject
{
    Set json = {}
    
    // =============================
    // 1. Header
    // =============================
    If $IsObject(..Header) {
        Do json.%Set("header", ..Header.ToJSONObj())
    } Else {
        Do json.%Set("header", {})
    }

    // =============================
    // 2. Items
    // =============================
    Set arr = []
    Set idx = ""

    For {
        Set idx = ..Items.Next(idx)
        Quit:idx=""

        Set item = ..Items.GetAt(idx)
        If $IsObject(item) {
            Do arr.%Push(item.ToJSONObj())
        }
    }

    Do json.%Set("items", arr)

    Quit json
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO).Build()
ClassMethod Build(bizData As %DynamicObject) As PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO
{
    If '$IsObject(bizData) {
        Throw ##class(%Exception.General).%New("bizData 不能为空")
    }

    Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO).%New()

    // Header
    Set h = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchHeader).%New()
    Set h.FIDNo        = bizData.main.prescNo
    Set h.FBillTypeID  = "发药"
    Set h.FDate        = bizData.main.prescTime
    Set h.FSaleOrgId   = bizData.main.hospitalName
    // Set h.FCustomerID  = bizData.main.patientMedNo
    Set h.FSaleDeptID  = bizData.main.phaLocDesc
    Set dto.Header = h

    // Items
    Set i=0
    For i=0:1:bizData.detail.%Size()-1 {
        Set d = bizData.detail.%Get(i)

        Set item = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchItem).%New()
		
		Set item.FCustomerID	 = bizData.main.patientMedNo
        Set item.Order           = d.oeori
        Set item.FMaterialID     = d.drugCode
        Set item.FMaterialIDdesc = d.drugName
        Set item.FUnitID         = d.unit
        Set item.FRealQty        = d.qty
        Set item.FTaxPrice       = d.price
        Set item.FEntryTaxRate   = d.taxRate
        Set item.ypssje          = d.amount
        Set item.Ypph            = d.batNo
        Set item.Batid           = d.batNo

        Do dto.Items.Insert(item)
    }

    Quit dto
}

}
