Class PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbConsumeTarget Extends PHA.COM.BaseBizPush.Engine.Target.ITarget
{

Method GetCode() As %String
{
		Quit "HERB_CONSUME"
}

Method GetName() As %String
{
		Quit "草药发药消耗数据推送"
}

Method GetDesc() As %String
{
		Quit "门诊草药发药完成后，推送草药实际消耗数据"
}

Method IsAsync() As %Boolean
{
		Quit 0  // 同步推送
}

Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.TmpCharacter
{
	Set arr = []
	Set prescNo = ctx.BizInfo.prescNo
	/// 获取处方的批次发药数据
	Set bizData = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetPrescBatchData(prescNo)
	Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.DispenseBatchDTO).Build(bizData.data)
	Set tmpData = dto.ToJSONObj()
	Set dataObj = tmpData.header
	Set dataObj."Items" = tmpData.items
	Set arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(dataObj,"Items")
	
	s stream = ##class(%Stream.GlobalCharacter).%New()
	d arr.%ToJSON(.stream)
	Quit stream
}

Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
    Set inv = ##class(PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke).%New()
    Set inv.PlatformName  = "SA 消耗接口"
    Set inv.PlatformClass = "web.SA.HerbConsume.Service"
    Set inv.MethodName    = "PushConsume"
    Set inv.NeedCode      = 1
    Quit inv
}

Method ParseResponse(rawResp As %String) As %DynamicObject
{
    Set result = {}
    Do result.%Set("raw", rawResp)

    If rawResp = "success" {
        Do result.%Set("success", 1)
        Quit result
    }

    Do result.%Set("success", 0)
    Do result.%Set("message", rawResp)
    Quit result
}

Method IsSuccess(parsedResp As %DynamicObject) As %Boolean
{
    Quit parsedResp.success
}

Method BuildResultMessage(parsedResp As %DynamicObject) As %String
{
    Quit $Get(parsedResp.raw, "无返回信息")
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbConsumeTarget).Tesst()
ClassMethod Tesst()
{
	s ht = ##class(PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbConsumeTarget).%New()
	s dispData = ht.BuildPayload({},{"BizInfo":{"prescNo":"O251202000011"}})
	q dispData.Read()
}

/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbConsumeTarget).Tesst1()
ClassMethod Tesst1()
{
	
	set Stream="{""FIDNo"":""O251202000011"",""FBillTypeID"":""发药"",""FDate"":""2025-12-02 18:14:37"",""FSaleOrgId"":""昆明-人民中路馆"",""FSaleDeptID"":""ZYYX005"",""FCustomerID"":""0000000001"",""Order"":""1308||45"",""FMaterialID"":""YPC000109"",""FMaterialIDdesc"":""防风[饮片]"",""FUnitID"":"""",""FRealQty"":""14"",""FTaxPrice"":"".21759"",""FEntryTaxRate"":"""",""ypssje"":3.04626,""Ypph"":""202304200002"",""Batid"":""202304200002""},{""FIDNo"":""O251202000011"",""FBillTypeID"":""发药"",""FDate"":""2025-12-02 18:14:37"",""FSaleOrgId"":""昆明-人民中路馆"",""FSaleDeptID"":""ZYYX005"",""FCustomerID"":""0000000001"",""Order"":""1308||44"",""FMaterialID"":""YPC000122"",""FMaterialIDdesc"":""甘草[饮片]"",""FUnitID"":"""",""FRealQty"":""14"",""FTaxPrice"":"".0575"",""FEntryTaxRate"":"""",""ypssje"":0.805,""Ypph"":""202304200002"",""Batid"":""202304200002""}"
	set soap=##class(web.DHCENS.STBLL.SOAP.PUB0005Soap).%New()
    set rtn=soap.HIPMessageInfo("MES0029",Stream,"02","HD1005")	//每条都单独调用
	quit rtn
}

}
