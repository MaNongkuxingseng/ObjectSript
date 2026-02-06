/// 住院发药推送业务入口类
/// 负责住院药品发药后的数据推送流程控制
Class PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.IP.Dispense Extends PHA.COM.BaseBizPush.Business.BaseBizPushTemplate
{

/// 获取业务入口编码
/// 唯一标识符，用于系统识别
Method ActionCode() As %String
{
    Quit "IP_DISPENSE"
}

/// 获取业务入口名称
/// 用于界面显示和日志记录
Method ActionName() As %String
{
    Quit "住院发药推送"
}

/// 获取业务入口描述
/// 详细说明业务功能
Method ActionDesc() As %String
{
    Quit "住院药品发药完成后，推送发药数据"
}

/// 注册推送目标和平台配置
/// 定义院区、科室和对应的推送目标
/// 支持多院区多科室配置
Method Registrations() As %ListOfObjects
{
    Set list = ##class(%ListOfObjects).%New()

    Set reg = ##class(PHA.COM.BaseBizPush.Engine.Definition.PushRegistration).%New()
    Set reg.HospId   = "SC001"
    Set reg.DeptCode = "IPHA1"

    Do reg.AddTarget(
        "PHA.FACE.TPS.SA.HIS2SA.Target.IP.DispenseConsumeTarget",
        "MES_IP_DISPENSE",
        "web.DHCENS.STBLL.SOAP.PUB0005Soap",
        "HIPMessageInfo",
        {}
    )

    Do list.Insert(reg)

    Quit list
}

/// 获取住院发药业务数据
/// 根据发药单号从数据层获取完整业务数据
Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
    Set info = ctx.GetBizInfo()
    Set dspId = ##class(PHA.COM.BaseBizPush.Engine.Context.PushBizContextDTO).Read(info, "dspId", "")
    Quit ##class(PHA.FACE.TPS.SA.HIS2SA.Data.IPDispense).GetDispenseDetail(dspId)
}

/// 业务推送测试方法
/// 用于本地调试和验证推送流程
/// 模拟完整推送场景
ClassMethod TestBizPush()
{
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = "IP_DISPENSE"
    Set ctx.HospId      = "SC001"
    Set ctx.DeptCode    = "IPHA1"

    Set info = {}
    Set info.dspId = 201
    Do ctx.SetBizInfo(info)

    Set entry = ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.IP.Dispense).%New()
    Set summary = entry.Execute(ctx)

    Quit summary.ToFrontDTO().%ToJSON()
}

}
