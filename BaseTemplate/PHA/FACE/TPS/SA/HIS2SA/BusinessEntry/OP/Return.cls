Class PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Return Extends PHA.COM.BaseBizPush.Business.BaseBizPushTemplate
{

Method ActionCode() As %String
{
    Quit "OP_RETURN"
}

Method ActionName() As %String
{
    Quit "门诊退药推送"
}

Method ActionDesc() As %String
{
    Quit "门诊西药退药完成后，推送退药数据"
}

Method Registrations() As %ListOfObjects
{
    Set list = ##class(%ListOfObjects).%New()

    // =========================
    // 示例：SC001 医院 PHA1 药房
    // =========================
    Set reg = ##class(PHA.COM.BaseBizPush.Engine.Definition.PushRegistration).%New()
    Set reg.HospId   = "2"
    Set reg.DeptCode = "ALL"
    // Target 2: SA系统消耗
    Set platformData = {}
    Do platformData.%Set("input1", "MES0030")
    Do platformData.%Set("dataFormat", "02")
    Do platformData.%Set("opCode", "HD106")

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

Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    Set phdReturn = $Get(ctx.BizInfo.phdReturn)
    Quit ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPReturn).GetPrescReturnDetail(phdReturn)
}

Method TestBizPush() As %String
{
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = "OP_RETURN"
    Set ctx.HospId      = "SC001"
    Set ctx.DeptCode    = "PHA1"

    Set ctx.BizInfo = {}
    Set ctx.BizInfo.phdReturn = 101   // 退药单号

    Set entry = ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Return).%New()
    Set summary = entry.Execute(ctx)

    Quit summary.ToFrontDTO().%ToJSON()
}

}
