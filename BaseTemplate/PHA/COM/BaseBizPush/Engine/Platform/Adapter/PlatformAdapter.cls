/// 平台适配器抽象 用于隔离平台方法签名变化
Class PHA.COM.BaseBizPush.Engine.Platform.Adapter.PlatformAdapter Extends %RegisteredObject [ Abstract ]
{

Property PlatformName As %String [ InitialExpression = "基类平台适配器" ];

Method Invoke(ctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext) As %Status [ Abstract ]
{
}

Method %OnNew() As %Status
{
    quit $$$OK
}

Method GetPlatformInfo() As %String [ Abstract ]
{
    quit ""
}

}
