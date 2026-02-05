/// 平台调用统一上下文
Class PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext Extends %RegisteredObject
{

/// 平台消息编码(target)
Property PlatformCode As %String;

/// 平台实现类（如 web.DHCENS.STBLL.SOAP.PUB0005Soap）
Property PlatformClass As %String;

/// 调用的方法名（如 HIPMessageInfo）
Property MethodName As %String;

/// 平台数据(biz code)  
Property PlatformData As %DynamicObject [ InitialExpression = {{}} ];

/// 业务数据(json/xml)
Property Payload As %Stream.TmpCharacter;

/// 原始平台返回（string / stream / object）
Property RawResponse;

/// Adapter 规范化后的返回（可选）
Property Result;

/// 获取公共字典定义的平台适配器
/// SA.PlatformCode中定义了:PlatformClass_MethodName对应的平台适配器类
Method getPlatformAdapter() As %String
{
	s dicId = ""
	s dicCode = $$ALPHAUP^SSUTIL4(..PlatformClass_"_"_..MethodName)
	q:dicCode="" dicId
	s dicId = $o(^DHCSTSCDI(0,"TYPECODE","SAPLATFORMCODE",dicCode,""))
	s adapterClass = ##class(PHA.COM.Data.Base).StkComDictionaryDesc(dicId)
	q adapterClass
}

Method GetPlatformInfo() As %String
{
	s platformInfo = ""
	s pa = ..getPlatformAdapter()
	try{
		s pa = $classmethod(pa, "%New")
		s platformInfo = pa.GetPlatformInfo()
	}catch ex{
		s platformInfo = ""
	}
    quit "SA和利康源颗粒剂发药数据"
}

/// 获取当前平台的简要信息
Method GetDisplay() As %String
{
        q ..GetPlatformInfo()_"["_..PlatformClass_"->"_..MethodName_"("_..PlatformData.%ToJSON()_")]"
}

}
