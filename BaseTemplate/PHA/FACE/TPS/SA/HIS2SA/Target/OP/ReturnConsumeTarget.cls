/// 门诊退药推送消耗数据
Class PHA.FACE.TPS.SA.HIS2SA.Target.OP.ReturnConsumeTarget Extends PHA.COM.BaseBizPush.Engine.Target.ITarget
{

Method GetCode() As %String
{
    Quit "OP_RETURNCONSUMETARGET"
}

Method GetName() As %String
{
    Quit "门诊退药推送"
}

Method GetDesc() As %String
{
    Quit "门诊西药退药完成后，推送退药消耗数据"
}

Method IsAsync() As %Boolean
{
    Quit 0  // 同步推送
}

Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.TmpCharacter
{
	Set arr = []
#;	Set prescNo = ctx.BizInfo.prescNo
#;	/// 获取处方的批次发药数据
#;	Set bizData = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescBatchData(prescNo)
	Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO).Build(bizData.data)
	Set tmpData = dto.ToJSONObj()
	Set dataObj = tmpData.header
	Set dataObj."Items" = tmpData.items
	Set arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(dataObj,"Items")
	
	s stream = ##class(%Stream.GlobalCharacter).%New()
	d arr.%ToJSON(.stream)
	Quit stream
}

Method BuildPayloadByJSON(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.Object
{
    Set arr = []
    
    // 从上下文获取退药单号
    Set info = ctx.GetBizInfo()
    Set phdReturn = $Get(info.phdReturn)
    
    // 如果bizData已经是正确格式，直接使用；否则重新获取
    If '$IsObject(bizData.data) {
        // 重新获取业务数据
        Set bizData = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPReturn).GetPrescReturnDetail(phdReturn)
    }
    
    // 使用DTO构建器创建数据（类似ConsumeTarget的方式）
    Set batchBizData = ..ConvertToBatchData(bizData.data)
    
    // 构建退药DTO对象
    Set dto = ..BuildReturnDTO(batchBizData)
    
    // 转换为扁平化数组格式
    Set tmpData = dto.ToJSONObj()
    Set dataObj = tmpData.header
    Set dataObj."Items" = tmpData.items
    
    // 使用模板方法扁平化数据
    Set arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(dataObj, "Items")
    
    // 转换为流
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Do arr.%ToJSON(.stream)
    
    Quit stream
}

Method ConvertToBatchData(bizData As %DynamicObject) As %DynamicObject
{
    // 将原始退药数据转换为批次维度数据
    Set result = {}
    
    // 复制主数据
    Set result.main = {}
    Do result.main.%Set("returnNo", $Get(bizData.main.returnNo, ""))
    Do result.main.%Set("prescNo", $Get(bizData.main.prescNo, ""))
    Do result.main.%Set("returnTime", $Get(bizData.main.returnTime, $ZDateTime($Now(), 3)))
    Do result.main.%Set("hospitalName", $Get(bizData.main.hospitalName, ""))
    Do result.main.%Set("phaLocDesc", $Get(bizData.main.phaLocDesc, ""))
    Do result.main.%Set("patientMedNo", $Get(bizData.main.patientMedNo, ""))
    Do result.main.%Set("returnOperator", $Get(bizData.main.returnOperator, ""))
    Do result.main.%Set("returnReason", $Get(bizData.main.returnReason, ""))
    
    // 转换明细数据为批次维度
    Set batchMap = {}
    Set batchArr = []
    
    If $IsObject(bizData.detail) && bizData.detail.%IsA("%DynamicArray") {
        For i=0:1:bizData.detail.%Size()-1 {
            Set detail = bizData.detail.%Get(i)
            Set inclb = $Get(detail.inclb, "")
            Set drugCode = $Get(detail.drugCode, "")
            
            // 如果有批次信息，按批次汇总（退药数量为负数）
            If inclb '= "" {
                Set key = drugCode _ "||" _ inclb
                
                If '$Data(batchMap(key)) {
                    Set batchMap(key) = {
                        "seq": (batchArr.%Size() + 1),
                        "drugCode": (drugCode),
                        "drugName": ($Get(detail.drugName, "")),
                        "inclb": (inclb),
                        "qty": (-$Get(detail.qty, 0)),  // 退药数量为负数
                        "price": (+$Get(detail.price, 0)),
                        "batNo": ($Get(detail.batNo, "")),
                        "oeori": ($Get(detail.oeori, "")),
                        "amount": (-(+$Get(detail.qty, 0) * +$Get(detail.price, 0)))  // 退药金额为负数
                    }
                } Else {
                    // 相同批次和药品，数量累加（退药数量为负数）
                    Set batchItem = batchMap(key)
                    Set batchItem.qty = batchItem.qty - $Get(detail.qty, 0)
                    Set batchItem.amount = batchItem.qty * batchItem.price
                }
            } Else {
                // 没有批次信息，直接添加
                Set batchItem = {
                    "seq": (batchArr.%Size() + 1),
                    "drugCode": (drugCode),
                    "drugName": ($Get(detail.drugName, "")),
                    "inclb": (inclb),
                    "qty": (-$Get(detail.qty, 0)),  // 退药数量为负数
                    "price": (+$Get(detail.price, 0)),
                    "batNo": "",
                    "oeori": "",
                    "amount": (-(+$Get(detail.qty, 0) * +$Get(detail.price, 0)))  // 退药金额为负数
                }
                Do batchArr.%Push(batchItem)
            }
        }
        
        // 将map中的批次数据转换为数组
        Set key = ""
        For {
            Set key = $Order(batchMap(key))
            Quit:key=""
            
            Do batchArr.%Push(batchMap(key))
        }
    }
    
    Set result.detail = batchArr
    Quit result
}

Method BuildReturnDTO(batchBizData As %DynamicObject) As PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO
{
    // 构建退药DTO对象
    Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO).%New()
    
    // Header
    Set h = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchHeader).%New()
    Set h.FIDNo = $Get(batchBizData.main.returnNo, $Get(batchBizData.main.prescNo, ""))
    Set h.FBillTypeID = "门诊退药"
    Set h.FDate = $Get(batchBizData.main.returnTime, $ZDateTime($Now(), 3))
    Set h.FSaleOrgId = $Get(batchBizData.main.hospitalName, "")
    Set h.FSaleDeptID = $Get(batchBizData.main.phaLocDesc, "")
    Set dto.Header = h
    
    // Items
    Set i = 0
    For i=0:1:batchBizData.detail.%Size()-1 {
        Set d = batchBizData.detail.%Get(i)
        
        Set item = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchItem).%New()
        
        // 患者信息
        Set item.FCustomerID = $Get(batchBizData.main.patientMedNo, "")
        
        // 医嘱和药品信息
        Set item.Order = $Get(d.oeori, "")
        Set item.FMaterialID = $Get(d.drugCode, "")
        Set item.FMaterialIDdesc = $Get(d.drugName, "")
        Set item.FUnitID = ..GetUnitByDrugCode($Get(d.drugCode, ""))
        
        // 数量与金额（退药为负数）
        Set item.FRealQty = +$Get(d.qty, 0)  // 负数
        Set item.FTaxPrice = +$Get(d.price, 0)
        Set item.FEntryTaxRate = 0  // 默认税率
        Set item.ypssje = +$Get(d.amount, 0)  // 退药金额（负数）
        
        // 批次信息
        Set item.Ypph = $Get(d.batNo, "")
        Set item.Batid = $Get(d.inclb, "")
        
        Do dto.Items.Insert(item)
    }
    
    Quit dto
}

Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
    Set inv = ##class(PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke).%New()
    Set inv.PlatformName = "SA 退药同步接口"
    Set inv.PlatformClass = "web.DHCENS.STBLL.SOAP.PUB0005Soap"
    Set inv.MethodName = "HIPMessageInfo"
    Set inv.NeedCode = 1
    
    Quit inv
}

Method ParseResponse(rawResp As %String) As %DynamicObject
{
    Set result = {}
    Do result.%Set("raw", rawResp)
    
    // 去除首尾空白
    Set rawResp = $ZStrip(rawResp, "<W")
    
    // 空返回处理
    If rawResp = "" {
        Do result.%Set("success", 0)
        Do result.%Set("code", "-1")
        Do result.%Set("message", "error: empty response")
        Quit result
    }
    
    // 尝试解析为JSON
    Try {
        Set respObj = ##class(%DynamicObject).%FromJSON(rawResp)
        
        // 根据平台返回格式判断成功
        If $IsObject(respObj) && respObj.%IsDefined("code") {
            Set code = respObj.code
            Do result.%Set("success", (code = "0" || code = "200"))
            Do result.%Set("code", code)
            Do result.%Set("message", $Get(respObj.message, ""))
            Do result.%Set("data", $Get(respObj.data, {}))
        } Else {
            // 非标准JSON返回，按字符串处理
            Do result.%Set("success", (rawResp = "success" || rawResp = "SUCCESS"))
            Do result.%Set("code", $Select(rawResp = "success": "0", rawResp = "SUCCESS": "0", 1: "-1"))
            Do result.%Set("message", rawResp)
        }
    } Catch ex {
        // 非JSON返回，按字符串处理
        Do result.%Set("success", (rawResp = "success" || rawResp = "SUCCESS"))
        Do result.%Set("code", $Select(rawResp = "success": "0", rawResp = "SUCCESS": "0", 1: "-1"))
        Do result.%Set("message", rawResp)
    }
    
    Quit result
}

Method IsSuccess(parsedResp As %DynamicObject) As %Boolean
{
    Quit parsedResp.success
}

Method BuildResultMessage(parsedResp As %DynamicObject) As %String
{
    Quit $Get(parsedResp.message, $Get(parsedResp.raw, "无返回信息"))
}

Method CustomFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    Set result = {}
    Set result.passed = 1
    Set result.message = "通过所有自定义过滤检查"
    Set result.data = {}
    Set result.failedChecks = []
    
    // ============ 1. 基础数据检查 ============
    If '$IsObject(bizData) || '$IsObject(bizData.data) {
        Do ..UpdateFilterResult(.result, 0, "业务数据为空或不合法")
        Quit result
    }
    
    // 检查main数据
    If '$IsObject(bizData.data.main) {
        Do ..UpdateFilterResult(.result, 0, "主数据缺失")
        Quit result
    }
    
    // 检查退药单号
    Set returnNo = $Get(bizData.data.main.returnNo)
    Set prescNo = $Get(bizData.data.main.prescNo)
    
    If returnNo = "" && (prescNo = "") {
        Do ..UpdateFilterResult(.result, 0, "退药单号和处方号都为空")
        Quit result
    }
    
    // ============ 2. 明细数据检查 ============
    If '$IsObject(bizData.data.detail) || 'bizData.data.detail.%IsA("%DynamicArray") {
        Do ..UpdateFilterResult(.result, 0, "明细数据缺失或格式错误")
        Quit result
    }
    
    If bizData.data.detail.%Size() = 0 {
        Do ..UpdateFilterResult(.result, 0, "没有退药明细数据")
        Quit result
    }
    
    // ============ 3. 业务逻辑检查 ============
    
    // 检查是否有有效的退药数量（应该为负数）
    Set hasValidReturnQty = 0
    For i=0:1:bizData.data.detail.%Size()-1 {
        Set detail = bizData.data.detail.%Get(i)
        Set qty = +$Get(detail.qty, 0)
        
        // 退药数量应该大于0（实际存储的是正数，但逻辑上是退回）
        If qty > 0 {
            Set hasValidReturnQty = 1
            Quit
        }
    }
    
    If 'hasValidReturnQty {
        Do ..UpdateFilterResult(.result, 0, "所有明细的退药数量都为0")
        Quit result
    }
    
    // ============ 4. 综合判断 ============
    If result.failedChecks.%Size() > 0 {
        Set result.message = "发现" _ result.failedChecks.%Size() _ "个问题：" _ result.message
    }
    
    Quit result
}

/// 辅助方法：根据药品代码获取单位
Method GetUnitByDrugCode(drugCode As %String) As %String
{
    // 这里应该调用实际的业务方法获取单位
    // 简化实现：根据药品类型返回默认单位
    If drugCode = "" Quit ""
    
    // 示例：查询药品基本信息获取单位
    Set inciId = ..GetInciIdByCode(drugCode)
    If inciId '= "" {
        // 查询基本单位
        Quit $Piece($Get(^INCI(inciId, 1)), "^", 12)
    }
    
    Quit "基本单位"
}

/// 辅助方法：根据药品代码获取INC_Itm ID
Method GetInciIdByCode(drugCode As %String) As %String
{
    Quit:""=$Get(drugCode) ""
    Quit $Order(^INCI(0,"Code1",$$ALPHAUP^SSUTIL4(drugCode)_"Z",""))
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Target.OP.ReturnConsumeTarget).TestBuildPayload(182)
ClassMethod TestBuildPayload(retId = "") As %String
{
    // 测试方法
    Set target = ##class(PHA.FACE.TPS.SA.HIS2SA.Target.OP.ReturnConsumeTarget).%New()
    
    // 模拟业务数据
    Set bizData = {}
    Set bizData.data = {}
    
    // 主数据
    Set main = {}
    Do main.%Set("returnNo", "RT202601010001")
    Do main.%Set("prescNo", "O202601010001")
    Do main.%Set("returnTime", "2026-01-01 14:30:00")
    Do main.%Set("hospitalName", "SC001医院")
    Do main.%Set("phaLocDesc", "门诊西药房")
    Do main.%Set("patientMedNo", "P202601001")
    Do main.%Set("returnOperator", "张三")
    Do main.%Set("returnReason", "药品不良反应")
    Set bizData.data.main = main
    
    // 明细数据
    Set detailArr = []
    
    Set item1 = {}
    Do item1.%Set("oeori", "123456||1")
    Do item1.%Set("drugCode", "YB001")
    Do item1.%Set("drugName", "阿司匹林片")
    Do item1.%Set("uomDesc", "片")
    Do item1.%Set("qty", 10)  // 退回10片
    Do item1.%Set("price", 0.5)
    Do item1.%Set("batNo", "20251201")
    Do item1.%Set("inclb", "12345||1||1")
    Do item1.%Set("amount", -5)  // 退药金额-5元
    Do detailArr.%Push(item1)
    
    Set item2 = {}
    Do item2.%Set("oeori", "123456||2")
    Do item2.%Set("drugCode", "YB002")
    Do item2.%Set("drugName", "头孢克肟胶囊")
    Do item2.%Set("uomDesc", "粒")
    Do item2.%Set("qty", 7)  // 退回7粒
    Do item2.%Set("price", 1.2)
    Do item2.%Set("batNo", "20251215")
    Do item2.%Set("inclb", "12345||2||1")
    Do item2.%Set("amount", -8.4)  // 退药金额-8.4元
    Do detailArr.%Push(item2)
    
    Set bizData.data.detail = detailArr
    Set:retId'="" bizData.data = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPReturn).GetPrescReturnDetail(182).data
    
    // 模拟上下文
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set info = {}
    Set info.phdReturn = "101"
    Do ctx.SetBizInfo(info)
    
    // 构建Payload
    Set stream = target.BuildPayload(bizData, ctx)
    Quit stream.Read()
}

}
