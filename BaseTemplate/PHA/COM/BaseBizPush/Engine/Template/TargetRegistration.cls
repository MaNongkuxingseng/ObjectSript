Class PHA.COM.BaseBizPush.Engine.Template.TargetRegistration Extends %RegisteredObject
{

/// Target 类名
Property TargetClass As %String;

/// 平台消息 Code，如 MES0022
Property PlatformCode As %String;

/// 平台实现类（如 web.DHCENS.STBLL.SOAP.PUB0005Soap）
Property PlatformClass As %String;

/// 调用的方法名（如 HIPMessageInfo）
Property MethodName As %String;

/// 平台扩展参数（透传至 Context）
Property PlatformData As %DynamicObject [ InitialExpression = {{}} ];

Method ValidatePlatformRegistration() As %Status
{
	s sc = $$$OK
	s treg = $this
    i (treg.PlatformClass="") || (treg.MethodName="") {
        q $$$ERROR($$$GeneralError,"平台调用声明缺失")
    }
    
    q sc
}

}
