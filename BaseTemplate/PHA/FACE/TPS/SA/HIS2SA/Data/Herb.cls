/// 推送SA接口-草药数据
Class PHA.FACE.TPS.SA.HIS2SA.Data.Herb Extends PHA.COM.Data.Base
{

/// 获取完整处方数据（主信息 + 明细）
/// 返回结构：
/// {
///   main: {...},
///   detail: [ {...}, {...} ]
/// }
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescData("O251202000004")
ClassMethod GetPrescData(prescNo As %String) As %DynamicObject
{
    Set result = ..Msg(0,,{})

    // 获取主信息
    Set main = ..GetPrescMain(prescNo)
    Quit:($IsObject(main)=0) ..Msg(-1,main)  // 直接返回错误字符串

    // 获取明细信息
    Set detail = ..GetPrescDetail(prescNo)
    Quit:($IsObject(detail)=0) ..Msg(-1,detail)

    Do result.data.%Set("main", main)
    Do result.data.%Set("detail", detail)

    Quit result
}

/// 获取草药发药的批次数据
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescBatchData("O251202000011")
ClassMethod GetPrescBatchData(prescNo As %String) As %DynamicObject
{
	Set result = ..Msg(0,,{})

    // 获取主信息
    Set main = ..GetPrescMain(prescNo)
    Quit:($IsObject(main)=0) ..Msg(-1,main)  // 直接返回错误字符串

    // 获取明细信息
    Set detail = ..GetPrescBatchDetail(prescNo)
    Quit:($IsObject(detail)=0) ..Msg(-1,detail)

    Do result.data.%Set("main", main)
    Do result.data.%Set("detail", detail)

    Quit result
}

/// 获取处方主信息
/// 返回 %DynamicObject，失败时返回 "-1^错误信息"
ClassMethod GetPrescMain(prescNo As %String) As %DynamicObject
{
    // -----------------------------
    // 基础校验
    // -----------------------------
    Quit:(prescNo="") "-1^处方号不能为空"

    Set PhbdId = ##class(PHA.HERB.Com.Method).GetPhbdByPresc(prescNo)
    Quit:(+PhbdId=0) "-1^药房发药失败！"
    Quit:'$Data(^BS.PHA.HERB.DISPEND(PhbdId)) "-1^HIS发药还未完成！"

    // -----------------------------
    // 机构权限校验
    // -----------------------------
    Set phaLocId = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId),7)
    Set hospId   = ..HospIdByLoc(phaLocId)
	
	Set phaLocDesc = ..LocCode(phaLocId)
    Set hospName = ..HospDesc(hospId)

    // -----------------------------
    // 处方基础信息
    // -----------------------------
    Set prescInfo = ##class(PHA.COM.Order).GetPaQueInfo(prescNo)
    Quit:(prescInfo="") "-1^该草药处方异常！"

    Set preFactor   = $Piece(prescInfo,"^",2)     // 付数
    Set instrucDesc = $Piece(prescInfo,"^",1)     // 用法
    Set orderQty    = $Piece(prescInfo,"^",3)     // 用量
    Set freqDesc    = $Piece(prescInfo,"^",9)     // 频次
    Set preCreatDate= $Piece(prescInfo,"^",25)    // 开方时间
    Set prescForm	= $Piece(prescInfo,"^",8)    // 剂型

    Set prescDesc = "共:"_preFactor_"付 用法:"_instrucDesc_freqDesc_" 每次:"_orderQty

    // -----------------------------
    // 患者信息
    // -----------------------------
    Set admDr     = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId),6)
    Set patInfo   = ..GetPatInfo(admDr)

    Set patName   = $Piece(patInfo,"^",1)
    Set patSex    = $Piece(patInfo,"^",2)
    Set patAgeStr = $Piece(patInfo,"^",3)
    Set patTel    = $Piece(patInfo,"^",4)
    Set patNo  = $Piece(patInfo,"^",6)

    // -----------------------------
    // 医生与科室
    // -----------------------------
    Set phbdCh = $Order(^BS.PHA.HERB.DISPEND(PhbdId,"I",""),-1)
    Quit:(phbdCh="") "-1^HIS发药还未完成！"

    Set oeori = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh),3)
    Quit:(oeori="") "-1^该处方有误！"

    Set docLocDesc = $Piece(##class(PHA.COM.Order).GetOrdDocLoc(oeori),"^",2)
    Set doctorName = $Piece(##class(PHA.COM.Order).OeoriDoctor(oeori),"^",2)

    // -----------------------------
    // 金额与状态
    // -----------------------------
    Set preMoney = $Piece(##class(PHA.HERB.Com.Method).GetPrescAmt(prescNo),"^",2)
    Set feeType  = ##class(PHA.OP.COM.Method).GetPrescFeeType(prescNo)

    // -----------------------------
    // 构建返回对象
    // -----------------------------
    Set obj = {}

    Do obj.%Set("prescNo", prescNo)
    Do obj.%Set("patientName", patName)
    Do obj.%Set("patientSex", patSex)
    Do obj.%Set("patientAge", patAgeStr)
    Do obj.%Set("patientTel", patTel)
    Do obj.%Set("patientMedNo", patNo)

    Do obj.%Set("doctorName", doctorName)
    Do obj.%Set("deptName", docLocDesc)

    Do obj.%Set("prescDesc", prescDesc)
    Do obj.%Set("preFactor", preFactor)
    Do obj.%Set("preMoney", preMoney)
    Do obj.%Set("feeType", feeType)
    Do obj.%Set("prescTime", preCreatDate)
	Do obj.%Set("prescForm", prescForm)
	
    Do obj.%Set("hospitalName", hospName)
    Do obj.%Set("phaLocDesc", phaLocDesc)
    Do obj.%Set("dataSource", "HIS")
    Do obj.%Set("paymentStatus", "PAYED")

    Quit obj
}

/// 获取处方明细列表
/// 返回 %DynamicArray
ClassMethod GetPrescDetail(prescNo As %String) As %DynamicArray
{
    Set PhbdId = ##class(PHA.HERB.Com.Method).GetPhbdByPresc(prescNo)
    Quit:(+PhbdId=0) "-1^未找到对应发药记录"

    Set prescInfo = ##class(PHA.COM.Order).GetPaQueInfo(prescNo)
    Quit:(prescInfo="") "-1^该草药处方异常！"

    Set preFactor = $Piece(prescInfo,"^",2)

    // 明细数组
    Set detailArr = []

    // 临时内存结构
    Kill drugMap

    // -----------------------------
    // 汇总发药数据
    // -----------------------------
    Set phbdCh=""
    For {
        Set phbdCh=$Order(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh))
        Quit:phbdCh=""
        Set oeori = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh),3)
        Quit:oeori=""

        Set dspId = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh),4)
        Quit:dspId=""

        Set dspbId=0
        For {
            Set dspbId=$Order(^DHCOEDISQTY(dspId,"I",dspbId))
            Quit:dspbId=""
            Set dspbData = ^DHCOEDISQTY(dspId,"I",dspbId)

            Set inciId = $Piece(dspbData,"^",5)
            Set qty    = $Piece(dspbData,"^",2)
            Set sp     = $Piece(dspbData,"^",4)
            Set amt    = ##class(PHA.COM.Util).AddZero(qty*sp)
            Set inclb  = $Piece(dspbData,"^",1)

            If '$Data(drugMap(inciId)) {
                Set drugMap(inciId,"qty") = qty
                Set drugMap(inciId,"amt") = amt
            } Else {
                Set drugMap(inciId,"qty") = drugMap(inciId,"qty")+qty
                Set drugMap(inciId,"amt") = drugMap(inciId,"amt")+amt
            }
        }
    }

    // -----------------------------
    // 生成明细对象
    // -----------------------------
    Set inciId="", idx=0
    For {
        Set inciId=$Order(drugMap(inciId))
        Quit:inciId=""

        Set drugForm = $ListGet(##class(PHA.COM.Drug).GetForm(inciId),3)

        Set idx=idx+1

        Set obj = {}
        Do obj.%Set("seq", idx)
        Do obj.%Set("drugCode", $Piece(^INCI(inciId,1),"^",1))
        Do obj.%Set("drugName", $Piece(^INCI(inciId,1),"^",2))
        Do obj.%Set("doseHerb", drugMap(inciId,"qty")/preFactor)
        Do obj.%Set("amount", drugMap(inciId,"amt"))

        Do detailArr.%Push(obj)
    }

    Quit detailArr
}

/// Description：
///   按【药品 + 批次】维度获取草药发药明细
///   字段定义保持 HIS 原生语义，用于后续 DTO 映射
/// Return：
///   %DynamicArray
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescBatchDetail("O251202000011")
ClassMethod GetPrescBatchDetail(prescNo As %String) As %DynamicArray
{
    // -----------------------------
    // 1. 基础校验
    // -----------------------------
    Quit:(prescNo="") "-1^处方号不能为空"

    Set PhbdId = ##class(PHA.HERB.Com.Method).GetPhbdByPresc(prescNo)
    Quit:(+PhbdId=0) "-1^未找到对应发药记录"

    // -----------------------------
    // 2. 汇总容器
    // key = inciId ^ batchNo
    // -----------------------------
    Kill batchMap
    Set detailArr = []

    // -----------------------------
    // 3. 遍历发药记录
    // -----------------------------
    Set phbdCh=""
    For {
        Set phbdCh=$Order(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh))
        Quit:phbdCh=""

        Set oeori = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh),3)
        Quit:oeori=""

        Set dspId = $ListGet(^BS.PHA.HERB.DISPEND(PhbdId,"I",phbdCh),4)
        Quit:dspId=""

        // -----------------------------
        // 关键：按批次读取
        // -----------------------------
        Set dspbId=0
        For {
            Set dspbId=$Order(^DHCOEDISQTY(dspId,"I",dspbId))
            Quit:dspbId=""

            Set dspbData = ^DHCOEDISQTY(dspId,"I",dspbId)

            Set inclb = $Piece(dspbData,"^",1)   // inclb 批号
            Set qty     = $Piece(dspbData,"^",2)   // 发药数量
            Set price   = $Piece(dspbData,"^",4)   // 单价
            Set inciId  = $Piece(dspbData,"^",5)   // 药品ID

            Quit:(inclb="")!(inciId="")

            Set key = inciId_"^"_inclb

            If '$Data(batchMap(key)) {
                Set batchMap(key,"inciId")  = inciId
                Set batchMap(key,"inclb") = inclb
                Set batchMap(key,"qty")     = qty
                Set batchMap(key,"price")   = price
                Set batchMap(key,"oeori")   = oeori
                Set batchMap(key,"taxRate")	= 0
            } Else {
                Set batchMap(key,"qty") = batchMap(key,"qty") + qty
            }
        }
    }

    // -----------------------------
    // 4. 生成返回数组
    // -----------------------------
    Set key="", idx=0
    For {
        Set key=$Order(batchMap(key))
        Quit:key=""

        Set idx = idx + 1

        Set inciId  = batchMap(key,"inciId")
        Set batchNo = batchMap(key,"inclb")
        Set qty     = batchMap(key,"qty")
        Set price   = batchMap(key,"price")

        Set obj = {}

        Do obj.%Set("seq", idx)
        Set drugData = ##class(PHA.COM.Data.Drug).%New(inciId)
        Set inciCode = drugData.Code()
        Set inciDesc = drugData.Desc()
        Set bUomId = drugData.BUomId()

        // 药品信息
        Do obj.%Set("drugCode", inciCode)
        Do obj.%Set("drugName", inciDesc)
        Do obj.%Set("uomId", bUomId)
        Do obj.%Set("uomDesc", ..UomDesc(bUomId))

        // 批次信息
        Do obj.%Set("inclb", inclb)
        Set incldData = ##class(PHA.IN.TRANS.Data).GetInclbData(inclb,bUomId,{})
		Do obj.%Set("batNo", incldData."batNo")
		Do obj.%Set("expDate", incldData."expDate")

        // 数量与金额
        Do obj.%Set("qty", qty)
        Do obj.%Set("price", price)
        Do obj.%Set("amount", qty * price)

        // 医嘱
        Do obj.%Set("oeori", batchMap(key,"oeori"))

        Do detailArr.%Push(obj)
    }

    Quit detailArr
}

/// Description:获取病人相关信息   
/// Input:		AdmDr-就诊ID
/// Output:		
/// Return：	姓名、性别、年龄、电话号码
/// Others:     
ClassMethod GetPatInfo(AdmDr) As %String
{
	s papmi=$p(^PAADM(AdmDr), "^", 1)
	s papmi=+papmi
    s patName=$p(^PAPER(papmi, "ALL"), "^", 1)					//姓名
   	s patAge=##class(PHA.FACE.IN.Com).GetAge(papmi, AdmDr)	//年龄
   	s sexdr=$p(^PAPER(papmi, "ALL"), "^", 7)
   	s patSex=$p(^CT("SEX", sexdr), "^", 2)						//性别
   	s patTel=$p(^PAPER(papmi, "PER", 1), "^", 11)				//电话号码
   	s admType = $p(^PAADM(AdmDr), "^", 2)
   	s patMedNo = ##class(PHA.FACE.IN.Com).GetMrNoByEpisodeID(AdmDr, admType)
   	s patNo = $p(^PAPER(papmi, "PAT", 1), "^", 1)
	//输出
   	s Data=patName_"^"_patSex_"^"_patAge_"^"_patTel_"^"_patMedNo_"^"_patNo	
   	q Data
}

/// 获取退药完整数据（主信息 + 明细）
/// 返回结构：{ main: {...}, detail: [...] }
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetRefundData("33").data.%ToJSON()
ClassMethod GetRefundData(refundId As %String) As %DynamicObject
{
    Set result = ..Msg(0,,{})

    // 获取退药主信息
    Set main = ..GetRefundMain(refundId)
    Quit:($IsObject(main)=0) ..Msg(-1, main)

    // 获取退药明细
    Set detail = ..GetRefundBatchDetail(refundId)
    Quit:($IsObject(detail)=0) ..Msg(-1, detail)

    Do result.data.%Set("main", main)
    Do result.data.%Set("detail", detail)

    Quit result
}

/// 获取退药主信息
/// 返回 %DynamicObject，失败时返回 "-1^错误信息"
ClassMethod GetRefundMain(refundId As %String) As %DynamicObject
{
    // -----------------------------
    // 基础校验
    // -----------------------------
    Quit:(refundId="") "-1^退药ID不能为空"

    // TODO: 根据实际HIS系统退药表结构调整
    // 这里假设退药记录存储在 ^BS.PHA.HERB.REFUND(refundId)
    Quit:'$Data(^BS.PHA.HERB.RETURND(refundId)) "-1^退药记录不存在"

    // -----------------------------
    // 获取退药基础信息
    // -----------------------------
    Set refundData = ^BS.PHA.HERB.RETURND(refundId)
    Set prescNo = $ListGet(refundData, 6)      // 原处方号
    Set refundReason = $ListGet(refundData, 2) // 退药原因
    Set refundDate = $ListGet(refundData, 3)   // 退药时间
    Set refundOperator = $ListGet(refundData, 4) // 退药操作员
    Set phaLocId = $ListGet(refundData, 5)     // 药房
    Set admDr = $ListGet(refundData, 11)        // 就诊ID

    // -----------------------------
    // 获取原处方信息（复用发药查询）
    // -----------------------------
    Set prescInfo = ##class(PHA.COM.Order).GetPaQueInfo(prescNo)
    Quit:(prescInfo="") "-1^原处方信息异常"

    Set preFactor = $Piece(prescInfo,"^",2)
    Set instrucDesc = $Piece(prescInfo,"^",1)
    Set orderQty = $Piece(prescInfo,"^",3)
    Set freqDesc = $Piece(prescInfo,"^",9)
    Set prescForm = $Piece(prescInfo,"^",8)

    // -----------------------------
    // 机构信息
    // -----------------------------
    Set hospId = ..HospIdByLoc(phaLocId)
    Set phaLocDesc = ..LocCode(phaLocId)
    Set hospName = ..HospDesc(hospId)

    // -----------------------------
    // 患者信息（复用）
    // -----------------------------
    Set patInfo = ..GetPatInfo(admDr)
    Set patName = $Piece(patInfo,"^",1)
    Set patSex = $Piece(patInfo,"^",2)
    Set patAgeStr = $Piece(patInfo,"^",3)
    Set patTel = $Piece(patInfo,"^",4)
    Set patNo = $Piece(patInfo,"^",6)

    // -----------------------------
    // 医生与科室
    // -----------------------------
    Set oeori = ##class(PHA.HERB.Com.Data).GetOrdItmByPrescNo(prescNo)
    Set docLocDesc = $Piece(##class(PHA.COM.Order).GetOrdDocLoc(oeori),"^",2)
    Set doctorName = $Piece(##class(PHA.COM.Order).OeoriDoctor(oeori),"^",2)

    // -----------------------------
    // 退药金额（负数）
    // -----------------------------
    Set refundMoney = $Piece(##class(PHA.HERB.Com.Method).GetPrescAmt(prescNo),"^",2)

    // -----------------------------
    // 构建返回对象
    // -----------------------------
    Set obj = {}

    Do obj.%Set("refundId", refundId)
    Do obj.%Set("prescNo", prescNo)
    Do obj.%Set("refundReason", refundReason)
    Do obj.%Set("refundDate", refundDate)
    Do obj.%Set("refundOperator", refundOperator)

    Do obj.%Set("patientName", patName)
    Do obj.%Set("patientSex", patSex)
    Do obj.%Set("patientAge", patAgeStr)
    Do obj.%Set("patientTel", patTel)
    Do obj.%Set("patientMedNo", patNo)

    Do obj.%Set("doctorName", doctorName)
    Do obj.%Set("deptName", docLocDesc)

    Do obj.%Set("prescDesc", "退药-"_preFactor_"付")
    Do obj.%Set("preFactor", preFactor)
    Do obj.%Set("refundMoney", refundMoney)
    Do obj.%Set("prescForm", prescForm)
    
    Do obj.%Set("hospitalName", hospName)
    Do obj.%Set("phaLocDesc", phaLocDesc)
    Do obj.%Set("dataSource", "HIS")
    Do obj.%Set("refundStatus", "COMPLETED")

    Quit obj
}

/// 获取退药批次明细
/// 返回 %DynamicArray
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetRefundBatchDetail("REFUND001").%ToJSON()
ClassMethod GetRefundBatchDetail(refundId As %String) As %DynamicArray
{
    // -----------------------------
    // 基础校验
    // -----------------------------
    Quit:(refundId="") "-1^退药ID不能为空"
    Quit:'$Data(^BS.PHA.HERB.RETURND(refundId)) "-1^退药记录不存在"

    Set detailArr = []
    Kill batchMap

    // -----------------------------
    // 遍历退药明细
    // TODO: 根据实际表结构调整
    // -----------------------------
    Set refundItemId = ""
    For {
        Set refundItemId = $Order(^BS.PHA.HERB.RETURND(refundId, "I", refundItemId))
        Quit:refundItemId=""

        Set itemData = ^BS.PHA.HERB.RETURND(refundId, "I", refundItemId)
        
        Set inclb = $ListGet(itemData, 4)    // 批号
        Set inciId = +inclb					// 药品ID
        Set qty = $ListGet(itemData, 3)      // 退药数量（负数）
        Set price = $ListGet(itemData, 5)    // 单价
        Set oeori = $ListGet(itemData, 2)    // 医嘱ID
        Set amt = $ListGet(itemData, 8)    // 售价金额

        Quit:(inclb="")!(inciId="")

        Set key = inciId_"^"_inclb

        If '$Data(batchMap(key)) {
            Set batchMap(key, "inciId") = inciId
            Set batchMap(key, "inclb") = inclb
            Set batchMap(key, "qty") = qty
            Set batchMap(key, "price") = price
            Set batchMap(key, "oeori") = oeori
            Set batchMap(key, "taxRate") = 0
            Set batchMap(key, "amt") = amt
        } Else {
            Set batchMap(key, "qty") = batchMap(key, "qty") + qty
            Set batchMap(key, "amt") = batchMap(key, "qty") + amt
        }
    }

    // -----------------------------
    // 生成返回数组
    // -----------------------------
    Set key = "", idx = 0
    For {
        Set key = $Order(batchMap(key))
        Quit:key=""

        Set idx = idx + 1

        Set inciId = batchMap(key, "inciId")
        Set batchNo = batchMap(key, "inclb")
        Set qty = batchMap(key, "qty")
        Set price = batchMap(key, "price")
        

        Set obj = {}

        Do obj.%Set("seq", idx)
        
        Set drugData = ##class(PHA.COM.Data.Drug).%New(inciId)
        Set inciCode = drugData.Code()
        Set inciDesc = drugData.Desc()
        Set bUomId = drugData.BUomId()

        // 药品信息
        Do obj.%Set("drugCode", inciCode)
        Do obj.%Set("drugName", inciDesc)
        Do obj.%Set("unit", ..UomDesc(bUomId))

        // 批次信息
        Set incldData = ##class(PHA.IN.TRANS.Data).GetInclbData(inclb, bUomId, {})
        Do obj.%Set("batNo", incldData."batNo")
        Do obj.%Set("expDate", incldData."expDate")

        // 数量与金额（退药为负数）
        Do obj.%Set("qty", qty)
        Do obj.%Set("price", price)
        Do obj.%Set("amount", batchMap(key, "amt"))
        Do obj.%Set("taxRate", 0)

        // 医嘱
        Do obj.%Set("oeori", batchMap(key, "oeori"))

        Do detailArr.%Push(obj)
    }

    Quit detailArr
}

}
