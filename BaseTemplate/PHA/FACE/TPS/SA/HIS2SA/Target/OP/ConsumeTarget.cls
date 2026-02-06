Class PHA.FACE.TPS.SA.HIS2SA.Target.OP.ConsumeTarget Extends PHA.COM.BaseBizPush.Engine.Target.ITarget
{

Method GetCode() As %String
{
    Quit "OP_CONSUME"
}

Method GetName() As %String
{
    Quit "门诊发药消耗推送"
}

Method GetDesc() As %String
{
    Quit "向平台推送门诊发药后的药品消耗明细"
}

Method IsAsync() As %Boolean
{
    Quit 0  // 消耗推送一般同步
}

Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.TmpCharacter
{
	Set arr = []
#;	Set prescNo = ctx.BizInfo.prescNo
#;	/// 获取处方的批次发药数据
#;	Set bizData = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescBatchData(prescNo)
	Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO).Build(bizData.data)
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
    // 从上下文获取发药单号
    Set info = ctx.GetBizInfo()
    Set phd = $Get(info.phd)
    
    // 转换业务数据为平台需要的格式
    Set json = {}
    
    // 构建消耗数据格式（根据SA平台要求）
    // Header信息
    Set header = {}
    Do header.%Set("FIDNo", $Get(bizData.data.main.prescNo, ""))  // 处方号
    Do header.%Set("FBillTypeID", "门诊发药消耗")  // 单据类型
    Do header.%Set("FDate", $Get(bizData.data.main.prescTime, $ZDateTime($Now(), 3)))  // 业务日期
    Do header.%Set("FSaleOrgId", $Get(bizData.data.main.hospitalName, ""))  // 销售组织
    Do header.%Set("FSaleDeptID", $Get(bizData.data.main.phaLocDesc, ""))  // 销售部门
    
    // 构建明细数组
    Set items = []
    
    // 遍历明细数据
    If $IsObject(bizData.data.detail) && bizData.data.detail.%IsA("%DynamicArray") {
        For i=0:1:bizData.data.detail.%Size()-1 {
            Set detail = bizData.data.detail.%Get(i)
            
            Set item = {}
            
            // 患者信息（可以从main中获取）
            Do item.%Set("FCustomerID", $Get(bizData.data.main.patientMedNo, ""))  // 患者登记号
            
            // 医嘱信息
            Do item.%Set("Order", $Get(detail.oeori, ""))  // 医嘱ID
            
            // 药品信息
            Do item.%Set("FMaterialID", $Get(detail.drugCode, ""))  // 药品代码
            Do item.%Set("FMaterialIDdesc", $Get(detail.drugName, ""))  // 药品名称
            Do item.%Set("FUnitID", $Get(detail.uomDesc, ""))  // 单位
            
            // 数量与金额
            Do item.%Set("FRealQty", +$Get(detail.qty, 0))  // 发药数量
            Do item.%Set("FTaxPrice", +$Get(detail.price, 0))  // 含税单价
            Do item.%Set("FEntryTaxRate", 0)  // 税率（默认0）
            Do item.%Set("ypssje", (+$Get(detail.qty, 0) * +$Get(detail.price, 0)))  // 实收金额
            
            // 批次信息
            Do item.%Set("Ypph", $Get(detail.batNo, ""))  // 批号
            Do item.%Set("Batid", $Get(detail.inclb, ""))  // 批次号
            
            Do items.%Push(item)
        }
    }
    
    // 组装最终JSON结构
    Do json.%Set("Header", header)
    Do json.%Set("Items", items)
    
    // 转换为流
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Do json.%ToJSON(.stream)
    
    Quit stream
}

Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
    Set inv = ##class(PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke).%New()
    Set inv.PlatformName = "SA 消耗同步接口"
    Set inv.PlatformClass = "web.DHCENS.STBLL.SOAP.PUB0005Soap"
    Set inv.MethodName = "HIPMessageInfo"
    Set inv.NeedCode = 1  // 需要传入平台消息码
    
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
        
        // 根据SA平台返回格式判断成功
        // 示例：{"code":"0","message":"成功","data":{}}
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
    
    // 检查处方号
    Set prescNo = $Get(bizData.data.main.prescNo)
    If prescNo = "" {
        Do ..UpdateFilterResult(.result, 0, "处方号为空")
        Quit result
    }
    
    // ============ 2. 明细数据检查 ============
    If '$IsObject(bizData.data.detail) || 'bizData.data.detail.%IsA("%DynamicArray") {
        Do ..UpdateFilterResult(.result, 0, "明细数据缺失或格式错误")
        Quit result
    }
    
    If bizData.data.detail.%Size() = 0 {
        Do ..UpdateFilterResult(.result, 0, "没有发药明细数据")
        Quit result
    }
    
    // ============ 3. 业务逻辑检查 ============
    
    // 检查是否有有效的发药数量
    Set hasValidQty = 0
    For i=0:1:bizData.data.detail.%Size()-1 {
        Set detail = bizData.data.detail.%Get(i)
        Set qty = +$Get(detail.qty, 0)
        If qty > 0 {
            Set hasValidQty = 1
            Quit
        }
    }
    
    If 'hasValidQty {
        Do ..UpdateFilterResult(.result, 0, "所有明细的发药数量都为0")
        Quit result
    }
    
    // ============ 4. 综合判断 ============
    If result.failedChecks.%Size() > 0 {
        Set result.message = "发现" _ result.failedChecks.%Size() _ "个问题：" _ result.message
    }
    
    Quit result
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Target.OP.ConsumeTarget).TestBuildPayload()
ClassMethod TestBuildPayload() As %String
{
    // 测试方法
    Set target = ##class(PHA.FACE.TPS.SA.HIS2SA.Target.OP.ConsumeTarget).%New()
    
    // 模拟业务数据
    Set bizData = {}
    Set bizData.data = {}
    
    // 主数据
    Set main = {}
    Do main.%Set("prescNo", "O202601010001")
    Do main.%Set("prescTime", "2026-01-01 10:30:00")
    Do main.%Set("hospitalName", "SC001医院")
    Do main.%Set("phaLocDesc", "门诊西药房")
    Do main.%Set("patientMedNo", "P202601001")
    Set bizData.data.main = main
    
    // 明细数据
    Set detailArr = []
    
    Set item1 = {}
    Do item1.%Set("oeori", "123456||1")
    Do item1.%Set("drugCode", "YB001")
    Do item1.%Set("drugName", "阿司匹林片")
    Do item1.%Set("uomDesc", "片")
    Do item1.%Set("qty", 20)
    Do item1.%Set("price", 0.5)
    Do item1.%Set("batNo", "20251201")
    Do item1.%Set("inclb", "12345||1||1")
    Do detailArr.%Push(item1)
    
    Set item2 = {}
    Do item2.%Set("oeori", "123456||2")
    Do item2.%Set("drugCode", "YB002")
    Do item2.%Set("drugName", "头孢克肟胶囊")
    Do item2.%Set("uomDesc", "粒")
    Do item2.%Set("qty", 14)
    Do item2.%Set("price", 1.2)
    Do item2.%Set("batNo", "20251215")
    Do item2.%Set("inclb", "12345||2||1")
    Do detailArr.%Push(item2)
    
    Set bizData.data.detail = detailArr
    Set bizData.data = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPDispen).GetPrescDispDetail(281).data
    // 模拟上下文
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set info = {}
    Set info.phd = "281"
    Do ctx.SetBizInfo(info)
    
    // 构建Payload
    Set stream = target.BuildPayload(bizData, ctx)
    Quit stream.Read()
}

}
