/// 业务推送业务入口基类。
/// 所有具体业务入口（如 afterdispen）均需继承此类。
/// 仅用于语义与分层标识。
///   
Class PHA.COM.BaseBizPush.Business.BaseBizPushTemplate Extends PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate [ Abstract ]
{

/// 入口动作业务描述
Method ActionDesc() As %String [ Abstract ]
{
}

/// 入口动作业务编码
Method ActionCode() As %String [ Abstract ]
{
}

}
