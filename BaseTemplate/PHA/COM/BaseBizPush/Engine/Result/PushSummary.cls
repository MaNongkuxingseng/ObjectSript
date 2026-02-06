/// 推送结果汇总对象。
///   
Class PHA.COM.BaseBizPush.Engine.Result.PushSummary Extends %RegisteredObject
{

Property Results As list Of PHA.COM.BaseBizPush.Engine.Result.PushResult;

Method %OnNew() As %Status
{
    s ..Results = ##class(%ListOfObjects).%New()
    q $$$OK
}

Method AddResult(r As PHA.COM.BaseBizPush.Engine.Result.PushResult)
{
    d ..Results.Insert(r)

    // 日志记录放在结果汇总入口，保证所有执行分支（成功/失败/异常）统一落日志
    // 日志失败不阻断主流程
    set logSc = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResultLogService).Write(r)
}

Method GetAllResult() As %String
{
    s list = []

    for i=1:1:..Results.Count() {
        s r = ..Results.GetAt(i)
        w r.ToText(),!
    }
    
    q 0
}

/// 转换为前端DTO格式
Method ToFrontDTO() As %DynamicObject
{
    // 创建结果数组
    s resultArray = []
    
    // 遍历所有PushResult对象并转换为DTO
    for i = 1:1:..Results.Count() {
        s result = ..Results.GetAt(i)
        d resultArray.%Push(result.ToFrontDTO())
    }
    
    // 构建返回对象
    s dto = {
        "type": "PushSummary",
        "successCount": 0,
        "failureCount": 0,
        "totalCount": 0,
        "results": (resultArray),
        "summary": "",
        "timestamp": ($zdt($h, 3))
    }
    
    // 统计成功和失败数量
    for i = 0:1:(resultArray.%Size() - 1) {
        s item = resultArray.%Get(i)
        if item.success {
            s dto.successCount = dto.successCount + 1
        } else {
            s dto.failureCount = dto.failureCount + 1
        }
    }
    
    s dto.totalCount = dto.successCount + dto.failureCount
    
    // 生成汇总信息
    if dto.successCount = dto.totalCount {
        s dto.summary = "全部成功"
    } elseif dto.failureCount = dto.totalCount {
        s dto.summary = "全部失败"
    } else {
        s dto.summary = "部分成功（成功：" _ dto.successCount _ "，失败：" _ dto.failureCount _ "）"
    }
    
    q dto
}

/// 示例：如何在前端使用
/// w ##class(PHA.COM.BaseBizPush.Engine.Result.PushSummary).ExampleUsage()
ClassMethod ExampleUsage()
{
    // 创建推送结果对象
    s summary = ##class(PHA.COM.BaseBizPush.Engine.Result.PushSummary).%New()
    
    // 添加一些测试结果
    s result1 = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
    s result1.Success = 1
    s result1.ActionCode = "ACT001"
    s result1.ActionName = "医嘱推送"
    s result1.HospId = "H001"
    s result1.DeptCode = "D001"
    s result1.BizMainInfo = "医嘱号：123456"
    s result1.TargetCode = "T001"
    s result1.TargetName = "HIS系统"
    s result1.TargetClass = "HIS.Push.Target"
    s result1.PlatformInfo = "HIS V3.0"
    s result1.Message = ""
    
    s result2 = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
    s result2.Success = 0
    s result2.ActionCode = "ACT001"
    s result2.ActionName = "医嘱推送"
    s result2.HospId = "H001"
    s result2.DeptCode = "D001"
    s result2.BizMainInfo = "医嘱号：123457"
    s result2.TargetCode = "T002"
    s result2.TargetName = "LIS系统"
    s result2.TargetClass = "LIS.Push.Target"
    s result2.PlatformInfo = "LIS V2.5"
    s result2.Message = "网络连接超时"
    
    d summary.AddResult(result1)
    d summary.AddResult(result2)
    
    // 转换为前端DTO
    s frontDTO = summary.ToFrontDTO()
    
    // 输出为JSON格式（前端可直接使用）
    w frontDTO.%ToJSON()
    
    /*
    输出示例：
    {
        "type": "PushSummary",
        "successCount": 1,
        "failureCount": 1,
        "totalCount": 2,
        "results": [
            {
                "type": "PushResult",
                "success": true,
                "actionCode": "ACT001",
                "actionName": "医嘱推送",
                "hospId": "H001",
                "deptCode": "D001",
                "bizMainInfo": "医嘱号：123456",
                "targetCode": "T001",
                "targetName": "HIS系统",
                "targetClass": "HIS.Push.Target",
                "platformInfo": "HIS V3.0",
                "message": "",
                "hasTarget": 1,
                "target": {
                    "code": "T001",
                    "name": "HIS系统",
                    "class": "HIS.Push.Target"
                },
                "platform": {
                    "info": "HIS V3.0"
                },
                "status": "success",
                "statusText": "成功",
                "statusColor": "#52c41a",
                "briefInfo": "医嘱推送(ACT001) → HIS系统"
            },
            {
                // 第二个结果的类似结构...
            }
        ],
        "summary": "部分成功（成功：1，失败：1）",
        "timestamp": "2024-01-01 10:30:00"
    }
    */
}

}
