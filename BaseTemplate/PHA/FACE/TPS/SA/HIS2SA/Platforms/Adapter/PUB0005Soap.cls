/// /*
/// * web.DHCENS.STBLL.SOAP.PUB0005Soap平台适配器
/// * 适配方法：
/// *   HIPMessageInfo(input1, data, dataFormat, opCode)
/// */
Class PHA.FACE.TPS.SA.HIS2SA.Platforms.Adapter.PUB0005Soap Extends PHA.COM.BaseBizPush.Engine.Platform.Adapter.PlatformAdapter
{

/**
 * Author: MPF
 * Date: 2026-01-28
 * Description:
 *   PUB0005 
 	发药数据推送
 	业务代码（opCode）：固定传入:HD105
 	数据格式（dataFormat）：固定传入02
	业务数据（data）:数据json串
	input1：MES0029
	
	推送退药数据
	业务代码（opCode）：固定传入：HD1006
	数据格式（dataFormat）：固定传入02
	业务数据（data）:数据json串
	input1：MES0030
 */
Method Invoke(ctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext) As %Status
{
    #dim sc As %Status = $$$OK
    #dim input1 As %String
    #dim dataFormat As %String
    #dim opCode As %String
    #dim result As %String

    // 固定参数内聚
    s input1     = ctx.PlatformCode  ; 平台接入号
    s platformData = ctx.PlatformData	; 平台数据参数
    s dataFormat = platformData.dataFormat       ; JSON
    s:dataFormat="" dataFormat = "02"
    s opCode     = dataFormat.opCode   ; 发药业务

    // 平台调用
    s platform = ##class(web.DHCENS.STBLL.SOAP.PUB0005Soap).%New()
    s ctx.RawResponse = platform.HIPMessageInfo(
        input1,
        ctx.Payload,
        dataFormat,
        opCode
    )

    q sc
}

Method GetPlatformInfo() As %String
{
    quit "SA海典HIS消耗同步"
}

}
