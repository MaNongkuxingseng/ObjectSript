/// 退药推送 DTO（Root）
Class PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO Extends %RegisteredObject
{

Property Header As PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchHeader;

Property Items As list Of PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchItem;

Method %OnNew() As %Status
{
    Set ..Header = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchHeader).%New()
    Set ..Items = ##class(%ListOfObjects).%New()
    Quit $$$OK
}

/// DTO 转换为 JSON 对象
Method ToJSONObj() As %DynamicObject
{
    Set json = {}
    
    If $IsObject(..Header) {
        Do json.%Set("header", ..Header.ToJSONObj())
    } Else {
        Do json.%Set("header", {})
    }

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

/// 构建退药 DTO
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO).Build({}).%ToJSON()
ClassMethod Build(bizData As %DynamicObject) As PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO
{
    If '$IsObject(bizData) {
        Throw ##class(%Exception.General).%New("bizData 不能为空")
    }

    Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO).%New()

    Set h = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchHeader).%New()
    Set h.FIDNo = bizData.main.refundId
    Set h.FBillTypeID = "退药"
    Set h.FDate = bizData.main.refundDate
    Set h.FSaleOrgId = bizData.main.hospitalName
    Set h.FSaleDeptID = bizData.main.phaLocDesc
    Set dto.Header = h

    Set i = 0
    For i=0:1:bizData.detail.%Size()-1 {
        Set d = bizData.detail.%Get(i)
        Set item = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchItem).%New()
        
        Set item.FCustomerID = bizData.main.patientMedNo
        Set item.Order = d.oeori
        Set item.FMaterialID = d.drugCode
        Set item.FMaterialIDdesc = d.drugName
        Set item.FUnitID = d.unit
        Set item.FRealQty = d.qty
        Set item.FTaxPrice = d.price
        Set item.FEntryTaxRate = d.taxRate
        Set item.ypssje = d.amount
        Set item.Ypph = d.batNo
        Set item.Batid = d.batNo

        Do dto.Items.Insert(item)
    }

    Quit dto
}

}
