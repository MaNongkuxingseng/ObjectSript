Class PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Dispen Extends PHA.COM.BaseBizPush.Business.BaseBizPushTemplate
{

/// 入口编码
Method ActionCode() As %String
{
        Quit "OP_HERB_DISPEN"
}

/// 入口名称
Method ActionName() As %String
{
        Quit "门诊草药发药后推送"
}

/// 入口描述
Method ActionDesc() As %String
{
        Quit "门诊草药发药完成后，推送处方数据"
}

/// 注册声明
Method Registrations() As %ListOfObjects
{
        Set list = ##class(%ListOfObjects).%New()

        Set reg = ##class(PHA.COM.BaseBizPush.Engine.Definition.PushRegistration).%New()
        Set reg.HospId   = "2"
        Set reg.DeptCode = "PHA1"
		
		// 和利康源颗粒剂-发药推送
        Do reg.AddTarget(
            "PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HollysysAppTarget",
            "MES0022",
            "web.DHCENS.STBLL.SOAP.PUB0002Soap",
            "HIPMessageServer",
            {}
        )
        Do list.Insert(reg)
        
        // 2.其他科室，目标定义
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
Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject
{
        Set data = {}
        Set prescNo     = ctx.BizInfo.prescNo
        
        s data = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescData(prescNo)
        Quit data
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Dispen).TestBizPush()
ClassMethod TestBizPush()
{
	s ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
	s ctx.TriggerCode = "PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Dispen"
	s ctx.HospId = "SC001"
	s ctx.DeptCode = "PHA1"
	s ctx.BizInfo = {}
	s ctx.BizInfo.dispenseId = "123"
	s ctx.BizInfo.prescNo = "O251202000004"
	
	s tpl = ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Dispen).%New()
	s summary = tpl.Execute(ctx)

	q summary.ToFrontDTO().%ToJSON()
	zw summary.GetAllResult()
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.BusinessEntry.OP.Herb.Dispen).Push()
ClassMethod Push()
{
	s phbd = 234
	s prescNo = "O260204000007"
	s hospId = 2
	s ctloc = 183
	// 退药入口公共消息推送
    s contextData = {}
    s contextData.hospId = ##class(PHA.COM.Err).GetSessionVal("LOGON.HOSPID",hospId)
    s contextData.deptId = ctloc
    s contextData.entryCode = "OP_HERB_DISPEN"
    s contextData.bizInfo = {"phbd":(phbd),"prescNo":(prescNo)}
    q ##class(PHA.COM.BaseBizPush.Business.App.PushService).Push(contextData)
}

}
