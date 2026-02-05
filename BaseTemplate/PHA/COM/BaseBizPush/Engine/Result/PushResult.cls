/// 单个推送目标执行结果对象。
///   
Class PHA.COM.BaseBizPush.Engine.Result.PushResult Extends %RegisteredObject
{

Property Success As %Boolean [ InitialExpression = 0 ];

Property ActionCode As %String;

Property ActionName As %String;

Property HospId As %String;

Property DeptCode As %String;

Property BizMainInfo As %String;

Property TargetCode As %String;

Property TargetName As %String;

Property TargetClass As %String;

Property PlatformInfo As %String;

Property Message As %String;

Method ToText() As %String
{
        s t = ""
        s t = t _ ..ActionName _ "[" _ ..ActionCode _ "]"_$c(13,10)
        s t = t _ "入口信息:"_$c(13,10)
        s t = t _ "  院区=" _ ..HospId_$c(13,10)
        s t = t _ "  科室=" _ ..DeptCode_$c(13,10)
        s t = t _ "  业务主信息=" _ ..BizMainInfo_$c(13,10)
        if (..TargetClass '= "") {
            s t = t _ "目标:"_$c(13,10)
            s t = t _ "  [" _ ..TargetCode _ "][" _ ..TargetClass _ "]"_$c(13,10)
            s t = t _ "平台:"_$c(13,10)
            s t = t _ "  [" _ ..PlatformInfo _ "]"_$c(13,10)
        }
        if (..Success) {
            s t = t _ "结果: 成功"
        } else {
            s t = t _ "结果: 失败[" _ ..Message _ "]"
        }
        q t
}

/// 转换为前端DTO格式
Method ToFrontDTO() As %DynamicObject
{
    s dto = {
        "type": "PushResult",
        "success": (..Success = 1),
        "actionCode": (..ActionCode),
        "actionName": (..ActionName),
        "hospId": (..HospId),
        "deptCode": (..DeptCode),
        "bizMainInfo": (..BizMainInfo),
#;        "targetCode": (..TargetCode),
#;        "targetName": (..TargetName),
#;        "targetClass": (..TargetClass),
#;        "platformInfo": (..PlatformInfo),
        "message": (..Message)
    }
    
    // 如果有目标信息，则添加目标相关字段
    if ..TargetClass '= "" {
        s dto.hasTarget = 1
        s dto.target = {
            "code": (..TargetCode),
            "name": (..TargetName),
            "class": (..TargetClass)
        }
        s dto.platform = {
            "info": (..PlatformInfo)
        }
    } else {
        s dto.hasTarget = 0
    }
    
    // 添加状态文本和颜色标识
    if ..Success {
        s dto.status = "success"
        s dto.statusText = "成功"
        s dto.statusColor = "#52c41a"  // 绿色
    } else {
        s dto.status = "error"
        s dto.statusText = "失败"
        s dto.statusColor = "#f5222d"  // 红色
    }
    
    // 添加简要信息（用于列表显示）
    s dto.briefInfo = ..ActionName _ "(" _ ..ActionCode _ ")"
    if ..TargetName '= "" {
        s dto.briefInfo = dto.briefInfo _ " → " _ ..TargetName
    }
    
    q dto
}

}
