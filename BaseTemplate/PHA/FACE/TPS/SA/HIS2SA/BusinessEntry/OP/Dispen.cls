/// 门诊发药推送入口
Class PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Dispen Extends PHA.COM.BaseBizPush.Business.BaseBizPushTemplate
{

/// 入口编码（唯一）
Method ActionCode() As %String
{
    Quit "OP_DISPEN"
}

/// 入口名称
Method ActionName() As %String
{
    Quit "门诊发药推送"
}

/// 入口描述
Method ActionDesc() As %String
{
    Quit "门诊西药发药完成后，推送数据"
}

/// 注册声明
/// 一个入口可以注册多个【院区 + 科室 + Target + 平台Code】
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
    Do platformData.%Set("input1", "MES0029")
    Do platformData.%Set("dataFormat", "02")
    Do platformData.%Set("opCode", "HD1005")

    Do reg.AddTarget(
        "PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbConsumeTarget",
        "MES0029",
        "web.DHCENS.STBLL.SOAP.PUB0005Soap",
        "HIPMessageInfo",
        platformData
    )

    Do list.Insert(reg)

    Quit list
}

/// 获取业务数据
/// ctx.GetBizInfo().phd = 发药单号
Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    // 优先使用 BizInfo 统一约定 data.id，兼容历史字段 phd
    Set info = ctx.GetBizInfo()
    Set phd = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).GetId(info)
    if phd = "" {
        Set phd = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).Read(info, "phd", "")
    }
    Quit ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPDispen).GetPrescDispDetail(phd)
}

/// 本地测试
ClassMethod TestBizPush()
{
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = "OP_DISPEN"
    Set ctx.HospId      = "SC001"
    Set ctx.DeptCode    = "PHA1"

    Set info = {}
    Set info.phd = 281   // 发药单号
    Do ctx.SetBizInfo(info)

    Set entry = ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Dispen).%New()
    Set summary = entry.Execute(ctx)

    zw summary.GetAllResult()
}

}
