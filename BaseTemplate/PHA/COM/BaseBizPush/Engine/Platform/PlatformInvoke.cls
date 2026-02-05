/// 平台调用封装类。
/// 用于描述平台类、方法及调用方式。
///   
Class PHA.COM.BaseBizPush.Engine.Platform.PlatformInvoke Extends %RegisteredObject
{

Property PlatformName As %String;

Property PlatformClass As %String;

Property MethodName As %String;

Property NeedCode As %Boolean [ InitialExpression = 0 ];

Method Invoke(code As %String = "", stream As %Stream.Object = "") As %DynamicObject
{
		s platform = $classmethod(..PlatformClass,"%New")
        if (..NeedCode) {
	        q platform.MethodName(code, stream)
        }else{
	        q platform.MethodName(stream)
        }
}

Method InvokeByMethod(code As %String = "", stream As %Stream.Object = "") As %DynamicObject
{
        if (..NeedCode) {
            q $classmethod(..PlatformClass, ..MethodName, code, stream)
        }
        q $classmethod(..PlatformClass, ..MethodName, stream)
}

Method GetDisplay() As %String
{
        q ..PlatformName_"["_..PlatformClass_"->"_..MethodName_"]"
}

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
