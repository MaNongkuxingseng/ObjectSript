/// 江阴阴天草药颗粒剂设备接口
Class PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HollysysAppTarget Extends PHA.COM.BaseBizPush.Engine.Target.ITarget
{

Method GetCode() As %String
{
        Quit "HOLLYSYS_APP"
}

Method GetName() As %String
{
        Quit "Hollysys 草药系统"
}

Method GetDesc() As %String
{
        Quit "向江阴阴天草药颗粒剂设备Hollysys 草药调剂系统推送处方 XML"
}

/// 是否异步
Method IsAsync() As %Boolean
{
        Quit 0  // 同步
}

/// 草药过滤（只推草药）
Method GetDataFilter() As PHA.COM.BaseBizPush.Engine.Filter.IDataFilter
{
    // 创建复合过滤器
    q ""	// 直接使用方法过滤
}

/// 自定义数据过滤方法（融合版本）
/// 返回结构化的过滤结果对象
Method CustomFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    // 初始化返回结果
    set result = {}
    set result.passed = 1
    set result.message = "通过所有自定义过滤检查"
    set result.data = {}
    set result.failedChecks = []  // 记录失败的检查项

    // ============ 1. 业务逻辑检查 ============
    
    // 检查处方类型
    set prescType = bizData.data.main.prescForm
    if prescType="颗粒剂" {
            do result.failedChecks.%Push("处方类型检查失败")
            do ..UpdateFilterResult(.result, 0, "处方类型'" _ prescType _ "'不支持")
        }
    
    // ============ 2. 处方明细检查 ============
    
    
    // ============ 3. 其他业务检查 ============
    
    
    // ============ 4. 综合判断 ============
    
    // 如果之前有检查失败，更新最终消息
    if result.failedChecks.%Size() > 0 {
        // 已经通过UpdateFilterResult更新了状态，这里可以添加综合消息
        set result.message = "发现" _ result.failedChecks.%Size() _ "个问题：" _ result.message
    } else {
        // 所有检查通过
        
    }
        
    return result
}

/// 构建 XML Payload
/// 返回：
///   xmlStr（符合接口文档的 <Prescriberecord> XML）
Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.Object
{
	/// 根据 GetPresc 返回的数据构建处方 XML 字符串
	// -----------------------------
    Set main   = bizData.data.main
    Set detail = bizData.data.detail

    // -----------------------------
    // 创建 XML 根节点
    // -----------------------------
    Set root  = ##class(PHA.COM.XML).%New("root")
    Set presc = ##class(PHA.COM.XML).%New("Prescriberecord")

    // -----------------------------
    // ========== 主表字段映射 ==========
    // -----------------------------

    // 处方号（必填）
    Set presc.Id = main.prescNo

    // 挂号单（当前无来源，留空）
    Set presc.RegisterId = ""

    // 患者基本信息
    Set presc.Name = main.patientName
    Set presc.Sex  = main.patientSex

    // 年龄拆分（示例：34岁）
    Set presc.Age       = +$Piece(main.patientAge,"岁",1)
    Set presc.AgeMonths = ""
    Set presc.AgeDays   = ""

    Set presc.Tele = main.patientTel
    Set presc.Email = ""

    // 位置（床位/门诊，当前无）
    Set presc.PatientLocation = ""

    // 医嘱信息
    Set presc.DepartmentName = main.deptName
    Set presc.DoctorName     = main.doctorName

    // 处方类型（未区分，默认空）
    Set presc.PrescriptionType = ""

    // 协定方名称（未提供）
    Set presc.PrescriptionName = ""

    // 处方时间
    Set presc.PrescribeTime = main.prescTime

    // 以下字段文档要求填写 null
    Set presc.CreatorName  = "null"
    Set presc.CreationTime = "null"

    // 划价信息（暂无）
    Set presc.ValueSn        = ""
    Set presc.ValuerName    = ""
    Set presc.ValuationTime = ""

    // 单剂价格（当前无单剂，填 0）
    Set presc.Price = 0

    // 一付几袋（接口要求必填，当前未维护，默认 1）
    Set presc.OnepresPackages = 1

    // 袋数 = 付数 * 2（与原系统逻辑保持一致）
    Set presc.Quantity = (+main.preFactor) * 2

    // 付数
    Set presc.QuantityDay = +main.preFactor

    // 处方总价
    Set presc.PriceTotal = main.preMoney

    // 缴费方式
    Set presc.PaymentType = main.feeType

    // 固定值
    Set presc.PaymentStatus = "PAYED"
    Set presc.DataSource    = "HIS"
    Set presc.DeviceId      = "null"
    Set presc.ProcessStatus = "NEW"

    // 备注
    Set presc.Description = main.prescDesc

    // -----------------------------
    // ========== 明细节点 ==========
    // -----------------------------
    Set detailsNode = ##class(PHA.COM.XML).%New("Prescribedetails")

    Set i = 0
    For i=0:1:detail.%Size()-1 {
        Set d = detail.%Get(i)

        Set detailNode = ##class(PHA.COM.XML).%New("Prescribedetail")

        // 对应主表处方号
        Set detailNode.Id = main.prescNo

        // 颗粒序号
        Set detailNode.No = d.seq

        // 颗粒信息
        Set detailNode.GranuleId   = d.drugCode
        Set detailNode.GranuleName = d.drugName

        // 剂量信息
        Set detailNode.DoseHerb  = d.doseHerb
        Set detailNode.Equivalent = 0
        Set detailNode.Dose       = 0

        // 颗粒价格
        Set detailNode.Price = d.amount

        // 加入明细集合
        Do detailsNode.Insert(detailNode)
    }

    // -----------------------------
    // 组装 XML 结构
    // -----------------------------
    Do presc.Insert(detailsNode)
    Do root.Insert(presc)

    // -----------------------------
    // 输出 XML 字符串
    // -----------------------------
    // w root.ToXML()
    Quit root.ToXMLStream()
}

/// 平台调用定义
Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
        Set inv = ##class(PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke).%New()
#;        Set inv.PlatformName  = "Hollysys SOAP"
#;        Set inv.PlatformClass = "PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HollysysAppTarget"
#;        Set inv.MethodName    = "TestPlatForm"
#;        Set inv.NeedCode      = 1
#;        Quit inv
        
        Set inv.PlatformName  = "Hollysys SOAP"
        Set inv.PlatformClass = "web.DHCENS.STBLL.SOAP.PUB0002Soap"
        Set inv.MethodName    = "HIPMessageServer"
        Set inv.NeedCode      = 1
        Quit inv
}

/// 解析平台返回结果
/// 成功：返回 success
/// 失败：返回以 error 开头的错误信息
/// 返回统一 %DynamicObject 结构，方便上层处理
Method ParseResponse(rawResp As %String) As %DynamicObject
{
    Set result = {}

    // -----------------------------
    // 原始返回内容处理
    // -----------------------------
    Set rawResp = $ZStrip(rawResp, "<W")  // 去除首尾空白

    // 保存原始返回
    Do result.%Set("raw", rawResp)

    // -----------------------------
    // 空返回处理
    // -----------------------------
    If rawResp = "" {
        Do result.%Set("success", 0)
        Do result.%Set("code", "-1")
        Do result.%Set("message", "error: empty response")
        Quit result
    }

    // -----------------------------
    // 成功返回
    // -----------------------------
    If rawResp = "success" {
        Do result.%Set("success", 1)
        Do result.%Set("code", "0")
        Do result.%Set("message", "success")
        Quit result
    }

    // -----------------------------
    // 失败返回（以 error 开头）
    // -----------------------------
    If $Extract(rawResp, 1, 5) = "error" {
        Do result.%Set("success", 0)
        Do result.%Set("code", "-1")
        Do result.%Set("message", rawResp)
        Quit result
    }

    // -----------------------------
    // 非预期返回
    // -----------------------------
    Do result.%Set("success", 0)
    Do result.%Set("code", "-1")
    Do result.%Set("message", "error: unknown response format")

    Quit result
}

Method IsSuccess(parsedResp As %DynamicObject) As %Boolean
{
    Quit parsedResp.success
}

Method BuildResultMessage(parsedResp As %DynamicObject) As %String
{
	q parsedResp
    Quit $Get(parsedResp.raw, "无返回信息")
}

ClassMethod TestPlatForm(code, stream As %Stream.TmpCharacter)
{
	q "success"
}

}
