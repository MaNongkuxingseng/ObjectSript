/// 应用层 Facade / API 类
Class PHA.COM.BaseBizPush.Business.App.PushService Extends %RegisteredObject
{

/// 前端触发业务推送统一入口
/// Author: Valen MPF
/// Date: 2025-12
/// Description:
///   根据前端传参，构造 PushContext 并执行业务入口
/// Input:
///   entryCode As %String,
///   hospId As %String,
///   deptCode As %String,
///   bizInfo As %DynamicObject
/// Output:
///   %DynamicObject（前端可用）
/// Debuge
///   w ##class(PHA.COM.BaseBizPush.Business.App.PushService).Execute("OP_HERB_DISPEN","SC001","PHA1",{"prescNo":"O251202000004","dispenseId":"CHD20250101001"})
ClassMethod Execute(entryCode As %String, hospId As %String, deptId As %String, bizInfo As %DynamicObject) As %DynamicObject
{
    // =========================
    // 1. 基础参数校验
    // =========================
    if entryCode = "" {
        q ..BuildError("entryCode不能为空")
    }
    if hospId = "" {
        q ..BuildError("hospId不能为空")
    }
    if deptCode = "" {
        q ..BuildError("deptCode不能为空")
    }

    // =========================
    // 2. 组织推送核心方法参数
    // =========================
    s reqObj = {
	    "entryCode" : (entryCode),
	    "hospId" : (hospId),
	    "deptCode" : (deptId),
	    "bizInfo" : (bizInfo)
    }

    // =========================
    // 3. 执行入口
    // =========================
    s summary = ..Push(reqObj)

    // =========================
    // 4. 输出前端可用结构
    // =========================
    q summary
}

/// Author: Valen MPF
/// Date: 2025-12
/// Description:
///   根据前端传参，构造 PushContext 并执行业务入口
/// Input:
///   reqObj %DynamicObject
/// Output:
///   %DynamicObject（前端可用）
///   w ##class(PHA.COM.BaseBizPush.Business.App.PushService).Push()
ClassMethod Push(reqObj As %DynamicObject) As %DynamicObject
{
    // =========================
    // 1. 参数校验
    // =========================
    if reqObj.entryCode = "" {
        s resp = ..BuildError("entryCode不能为空")
        d ..LogPushResponse(resp)
        q resp
    }
    if reqObj.hospId = "" {
        s resp = ..BuildError("hospId不能为空")
        d ..LogPushResponse(resp)
        q resp
    }
    if reqObj.deptId = "" {
        s resp = ..BuildError("deptCode不能为空")
        d ..LogPushResponse(resp)
        q resp
    }

    // =========================
    // 2. 根据 entryCode 找入口类
    // =========================
    // ToDo:将入口代码映射修改为公共字典维护(DHC_StkComDictionary)中入口代码与入口类的字典关系。
    s entryClass = ..ResolveEntryClass(reqObj.entryCode)
    if entryClass = "" {
        s resp = ..BuildError("未找到业务入口[" _ reqObj.entryCode _ "]")
        d ..LogPushResponse(resp)
        q resp
    }

    // =========================
    // 3. 构造 PushContext
    // =========================
    s ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    s ctx.TriggerCode = reqObj.entryCode
    s ctx.HospId = reqObj.hospId
    s ctx.DeptCode = reqObj.deptId
    d ctx.SetBizInfo(reqObj.bizInfo)

    // =========================
    // 4. 执行业务入口
    // =========================
    s entry = $classmethod(entryClass, "%New")
    s summary = entry.Execute(ctx)

    // =========================
    // 5. 返回结果
    // =========================
    s resp = summary.ToFrontDTO()
    d ..LogPushResponse(resp)
    q resp
}

/// ===============================
/// Entry 注册解析
/// ===============================
/// w ##class(PHA.COM.BaseBizPush.Business.App.PushService).ResolveEntryClass("OP_HERB_DISPEN")
ClassMethod ResolveEntryClass(entryCode As %String) As %String
{
	s cls = ""
	s entryCode = $zconvert(entryCode, "U")
    s rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")

    // 扫描所有 BaseEntry 子类
    d rs.Execute("PHA.COM.BaseBizPush.Business.BaseBizPushTemplate")

    while rs.Next() {
        s clsName = rs.Get("Name")
		s bizClass = $classmethod(clsName, "%New")

        if bizClass.ActionCode() = entryCode {
            s cls = clsName
            quit
        }else {
	        k bizClass
        }
    }

    q cls
	
    // 门诊草药发药后推送
    if entryCode = "OP_HERB_DISPEN" {
        q "PHA.COM.BaseBizPush.Business.OPHerbDispenEntry"
    }

    q ""
}

/// ===============================
/// 错误返回构造
/// ===============================
ClassMethod BuildError(msg As %String) As %DynamicObject
{
    s o = {}
    s o.success = 0
    s o.message = msg
    s o.results = []
    q o
}

/// ===============================
/// Push 返回日志
/// ===============================
ClassMethod LogPushResponse(resp As %DynamicObject) As %Status
{
    try {
        s logRowId = ""
        s payload = $select($isobject(resp):resp.%ToJSON(),1:"")
        s user = ##class(PHA.COM.Err).GetSessionVal("LOGON.USERID","")
        do ##class(PHA.FACE.COM.Log).Log(.logRowId, "", "OP", "PHA.COM.BaseBizPush.Business.App.PushService", "Push", , "", user, "")
        do ##class(PHA.FACE.COM.Log).Log(.logRowId, payload)
    } catch ex {
        // 日志失败不影响主流程
    }
    q $$$OK
}

}
