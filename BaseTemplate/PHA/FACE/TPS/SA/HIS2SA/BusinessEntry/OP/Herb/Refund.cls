/// 门诊草药退药推送入口
Class PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Refund Extends PHA.COM.BaseBizPush.Business.BaseBizPushTemplate
{

/// 入口编码
Method ActionCode() As %String
{
    Quit "OP_HERB_REFUND"
}

/// 入口名称
Method ActionName() As %String
{
    Quit "门诊草药退药推送"
}

/// 入口描述
Method ActionDesc() As %String
{
    Quit "门诊草药退药完成后，推送退药数据到相关系统"
}

/// 注册声明
Method Registrations() As %ListOfObjects
{
    Set list = ##class(%ListOfObjects).%New()

    // =============================
    // 注册1: SC001 - PHA1 科室
    // =============================
    Set reg = ##class(PHA.COM.BaseBizPush.Engine.Definition.PushRegistration).%New()
    Set reg.HospId   = "2"
    Set reg.DeptCode = "ALL"

    // Target 2: SA系统退药消耗
    Set platformData = {}
    Do platformData.%Set("input1", "MES0030")
    Do platformData.%Set("dataFormat", "02")
    Do platformData.%Set("opCode", "HD1006")
    
    Do reg.AddTarget(
        "PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbRefundTarget",
        "MES0030",
        "web.DHCENS.STBLL.SOAP.PUB0005Soap",
        "HIPMessageInfo",
        platformData
    )

    Do list.Insert(reg)

    Quit list
}

/// 获取业务数据
Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    // 优先使用 BizInfo 统一约定 data.id，兼容历史字段 refundId
    Set info = ctx.GetBizInfo()
    Set refundId = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).GetId(info)
    if refundId = "" {
        Set refundId = $Get(info.refundId)
    }
    Set data = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetRefundData(refundId)
    Quit data
}

/// 按业务入口测试
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Refund).TestRefundPush()
ClassMethod TestRefundPush() As %String
{
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = "OP_HERB_REFUND"
    Set ctx.HospId = "SC001"
    Set ctx.DeptCode = "PHA1"
    Set info = {}
    Set info.refundId = "31"
    Set info.prescNo = "O251202000004"
    Do ctx.SetBizInfo(info)
    
    Set tpl = ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Refund).%New()
    Set summary = tpl.Execute(ctx)

    Quit summary.ToFrontDTO().%ToJSON()
}

/// 单目标测试	目标-业务入口代码-上下文-平台参数
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Refund).TestRefundTarget()
ClassMethod TestRefundTarget()
{
	w ##class(PHA.COM.BaseBizPush.Test.TargetTester).TestTargetByClass(
	"PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbRefundTarget","OP_HERB_REFUND","SC001","PHA1",{"refundId":"33"},0,
	"MES0030","web.DHCENS.STBLL.SOAP.PUB0005Soap","HIPMessageInfo")
}

}
