Class PHA.FACE.TPS.SA.HIS2SA.Data.OPReturn Extends PHA.COM.Data.Base
{

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPReturn).GetPrescReturnDetail(182)
ClassMethod GetPrescReturnDetail(phdReturn As %String) As %DynamicObject
{
    Quit:(phdReturn="") "-1^退药单号不能为空"
    
    Set result = ..Msg(0,,{})
    
    Set main = ..GetReturnMain(phdReturn)
    Quit:'$IsObject(main) ..Msg(-1,main)
    
    // 获取退药明细
    Kill returnMap
    Do ..GetReturnDetail(phdReturn, .returnMap)
    Set detail = ..BuildReturnDetailArray(.returnMap)
    
    Do result.data.%Set("main", main)
    Do result.data.%Set("detail", detail)
    
    Quit result
}

ClassMethod GetReturnMain(phdReturn As %String) As %DynamicObject
{
    Quit:(phdReturn="") "-1^退药单号不能为空"
    
    // TODO: 根据实际HIS退药表结构调整
    // 这里假设退药主表为 ^DHCPHRET(phdReturn)
    Quit:'$Data(^DHCPHRET(phdReturn)) "-1^退药记录不存在"
    
    Set returnData = ^DHCPHRET(phdReturn)
    Set prescNo = $Piece(returnData,"^",1)  // 原处方号
    Set returnReason = $Piece(returnData,"^",2)  // 退药原因
    Set returnDate = $Piece(returnData,"^",3)  // 退药日期
    Set returnTime = $Piece(returnData,"^",4)  // 退药时间
    Set returnOperator = $Piece(returnData,"^",5)  // 退药操作员
    Set phaLocId = $Piece(returnData,"^",6)  // 药房ID
    Set admDr = $Piece(returnData,"^",7)  // 就诊ID
    
    // 获取患者信息
    Set patInfo = ##class(PHA.COM.Order).GetPatInfo(admDr)
    Set patName = $Piece(patInfo,"^",3)
    Set patSex = $Piece(patInfo,"^",4)
    Set patAgeStr = $Piece(patInfo,"^",4)
    Set patNo = $Piece(patInfo,"^",1)
    
    // 获取医生和科室信息
    Set oeori = ..GetFirstOeoriByReturn(phdReturn)
    Set doctorName = ""
    Set deptName = ""
    
    If oeori '= "" {
        Set doctorName = $Piece(##class(PHA.COM.Order).OeoriDoctor(oeori),"^",2)
        Set deptName = $Piece(##class(PHA.COM.Order).GetOrdDocLoc(oeori),"^",2)
    }
    
    // 机构信息
    Set phaLocDesc = ..LocCode(phaLocId)
    Set hospName = ..HospDesc(..HospIdByLoc(phaLocId))
    
    // 构建返回对象
    Set obj = {}
    Do obj.%Set("returnNo", phdReturn)
    Do obj.%Set("prescNo", prescNo)
    Do obj.%Set("returnReason", returnReason)
    Do obj.%Set("returnDate", returnDate)
    Do obj.%Set("returnTime", returnTime)
    Do obj.%Set("returnOperator", returnOperator)
    Do obj.%Set("patientName", patName)
    Do obj.%Set("patientSex", patSex)
    Do obj.%Set("patientAge", patAgeStr)
    Do obj.%Set("patientMedNo", patNo)
    Do obj.%Set("doctorName", doctorName)
    Do obj.%Set("deptName", deptName)
    Do obj.%Set("hospitalName", hospName)
    Do obj.%Set("phaLocDesc", phaLocDesc)
    Do obj.%Set("dataSource", "HIS")
    Do obj.%Set("returnStatus", "COMPLETED")
    
    Quit obj
}

ClassMethod GetReturnDetail(phdReturn As %String, ByRef returnMap)
{
    // 遍历退药明细
    Set returnSub = 0
    For {
        Set returnSub = $Order(^DHCPHRTI(phdReturn,"RTI",returnSub))
        Quit:returnSub=""
        
        Set itemData = ^DHCPHRTI(phdReturn,"RTI",returnSub)
        
        Set inclb = $Piece(itemData,"^",13)    // 批次ID
        Set qty = $Piece(itemData,"^",3)      // 退药数量
        Set price = $Piece(itemData,"^",6)    // 单价
        Set oeori = $Piece(itemData,"^",2)    // 医嘱ID
        Set inciId = +inclb                   // 药品ID
        
        Quit:(inclb="")!(inciId=0)
        
        Set key = inciId_"^"_inclb
        
        If '$Data(returnMap(key)) {
            Set returnMap(key,"inciId") = inciId
            Set returnMap(key,"inclb") = inclb
            Set returnMap(key,"qty") = qty
            Set returnMap(key,"price") = price
            Set returnMap(key,"oeori") = oeori
        } Else {
            // 相同批次和药品，数量累加
            Set returnMap(key,"qty") = returnMap(key,"qty") + qty
        }
    }
}

ClassMethod BuildReturnDetailArray(ByRef returnMap) As %DynamicArray
{
    Set arr=[]
    Set key="",idx=0
    
    For {
        Set key=$Order(returnMap(key))
        Quit:key=""
        
        Set idx=idx+1
        Set inciId = returnMap(key,"inciId")
        Set inclb  = returnMap(key,"inclb")
        Set qty    = returnMap(key,"qty")
        Set price  = returnMap(key,"price")
        Set oeori  = returnMap(key,"oeori")
        
        Set drug = ##class(PHA.COM.Data.Drug).%New(inciId)
        
        Set obj={}
        Do obj.%Set("seq", idx)
        Do obj.%Set("drugCode", drug.Code())
        Do obj.%Set("drugName", drug.Desc())
        Do obj.%Set("uomDesc", ..UomDesc(drug.BUomId()))
        Do obj.%Set("qty", qty)  // 退药数量（正数，但逻辑上是退回）
        Do obj.%Set("price", price)
        Do obj.%Set("amount", qty * price)  // 退药金额
        Do obj.%Set("oeori", oeori)
        
        // 批次信息
        Do obj.%Set("inclb", inclb)
        Set incldData = ##class(PHA.IN.TRANS.Data).GetInclbData(inclb,drug.BUomId(),{})
		Do obj.%Set("batNo", incldData."batNo")
		Do obj.%Set("expDate", incldData."expDate")
        
        Do arr.%Push(obj)
    }
    
    Quit arr
}

ClassMethod GetFirstOeoriByReturn(phdReturn As %String) As %String
{
    Set oeori = ""
    Set returnSub = $Order(^DHCPHRTI(phdReturn,"RTI",""))
    
    If returnSub '= "" {
        Set itemData = ^DHCPHRTI(phdReturn,"RTI",returnSub)
        Set oeori = $Piece(itemData,"^",2)
    }
    
    Quit oeori
}

ClassMethod TestGetReturnData() As %String
{
    // 测试方法
    Set phdReturn = "101"
    Set data = ..GetPrescReturnDetail(phdReturn)
    
    If $IsObject(data) && data.%IsDefined("data") {
        Quit data.data.%ToJSON()
    }
    
    Quit data
}

}
