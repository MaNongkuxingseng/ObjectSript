/// 业务入口下的推送声明定义。
/// 用于声明：
///   - 哪个院区
///   - 哪个科室
///   - 推送哪些 Target
///   
Class PHA.COM.BaseBizPush.Engine.Definition.PushRegistration Extends %RegisteredObject
{

/// 院区编码
Property HospId As %String;

/// 科室编码
Property DeptCode As %String;

/// 推送目标注册定义列表
Property Targets As %ListOfObjects;

Method %OnNew() As %Status
{
        s ..Targets = ##class(%ListOfObjects).%New()
        q $$$OK
}

/// 添加 Target
/// 使用platformData向平台传递扩展参数
Method AddTarget(targetClass As %String, platformCode As %String, platformClass As %String, platformMethod As %String, platformData As %DynamicObject = "")
{
        #dim t As PHA.COM.BaseBizPush.Engine.Template.TargetRegistration
        s t = ##class(PHA.COM.BaseBizPush.Engine.Template.TargetRegistration).%New()

        s t.TargetClass  = targetClass
        s t.PlatformCode = platformCode
        s t.PlatformClass = platformClass
        s t.MethodName = platformMethod

        i $isObject(platformData) {
	        if platformData.%IsA("%Library.DynamicObject") {
            	s t.PlatformData = platformData
	        }
        }

        d ..Targets.Insert(t)
}

/// 注册一个推送目标（平台调用声明完整）
Method RegisterTarget(reg As PHA.COM.BaseBizPush.Engine.Definition.PushRegistration, targetClass As %String, platformCode As %String, platformClass As %String, methodName As %String, platformData As %DynamicObject)
{
    s treg = ##class(PHA.COM.BaseBizPush.Engine.Template.TargetRegistration).%New()

    s treg.TargetClass   = targetClass
    s treg.PlatformCode  = platformCode
    s treg.PlatformClass = platformClass
    s treg.MethodName    = methodName
    s treg.PlatformData  = platformData

    d reg.Targets.Insert(treg)
}

}
