/// 草药退药消耗数据推送目标
Class PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbRefundTarget Extends PHA.COM.BaseBizPush.Engine.Target.ITarget
{

Method GetCode() As %String
{
    Quit "HERB_REFUND"
}

Method GetName() As %String
{
    Quit "草药退药消耗数据推送"
}

Method GetDesc() As %String
{
    Quit "门诊草药退药完成后，推送草药退药消耗数据到SA系统"
}

Method IsAsync() As %Boolean
{
    Quit 0
}

Method BuildPayload(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Stream.TmpCharacter
{
    Set arr = []
    Set info = ctx.GetBizInfo()
    Set refundId = $Get(info.refundId)
    
    Set bizData = ##class(PHA.FACE.TPS.SA.HIS2SA.Data.Herb).GetRefundData(refundId)
    Set dto = ##class(PHA.FACE.TPS.SA.HIS2SA.DTO.RefundBatchDTO).Build(bizData.data)
    Set tmpData = dto.ToJSONObj()
    Set dataObj = tmpData.header
    Set dataObj."Items" = tmpData.items
    
    Set arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(dataObj, "Items")
    
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Do arr.%ToJSON(.stream)
    Quit stream
}

Method GetInvoke() As PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke
{
    Set inv = ##class(PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke).%New()
    Set inv.PlatformName = "SA 退药消耗接口"
    Set inv.PlatformClass = "web.SA.HerbRefund.Service"
    Set inv.MethodName = "PushRefund"
    Set inv.NeedCode = 1
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

/// 测试方法
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbRefundTarget).TestPayload()
ClassMethod TestPayload() As %String
{
    Set target = ##class(PHA.FACE.TPS.SA.HIS2SA.Target.Herb.HerbRefundTarget).%New()
    Set ctx = {"BizInfo": {"refundId": "REFUND001"}}
    Set stream = target.BuildPayload({}, ctx)
    Quit stream.Read()
}

}
