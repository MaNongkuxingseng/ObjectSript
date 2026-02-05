/// 业务推送模板核心执行类。
///   
Class PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate Extends %RegisteredObject [ Abstract ]
{

Method Execute(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As PHA.COM.BaseBizPush.Engine.Result.PushSummary
{
        s summary = ##class(PHA.COM.BaseBizPush.Engine.Result.PushSummary).%New()
        s regs = ..Registrations()
        s matched = 0
        s bizData = ..GetBizData(ctx)  // 提前获取业务数据用于过滤判断
        d ctx.SetBizData(bizData)

        for i=1:1:regs.Count() {
            s reg = regs.GetAt(i)
#;            if (reg.HospId '= ctx.HospId) continue
#;            if (reg.DeptCode '= ctx.DeptCode) continue
            // 统一入口注册匹配
            s isMatch = ##class(PHA.COM.BaseBizPush.Engine.Match.EntryMatcher).IsMatch(reg, ctx)
	        if 'isMatch {
	            continue
	        }

            s matched = 1
            
            
            // 遍历所有目标，先进行过滤判断
            for j=1:1:reg.Targets.Count() {
#;                s cls = reg.Targets.GetAt(j)
#;                s target = $classmethod(cls,"%New")
                set treg = reg.Targets.GetAt(j)
                set target = $classmethod(treg.TargetClass, "%New")

                // 人工模式下仅执行选中的 TargetClass
                if (ctx.TriggerMode = "MANUAL") {
                    if ('$isobject(ctx.AllowedTargetClasses)) {
                        continue
                    }
                    if ($get(ctx.AllowedTargetClasses.(treg.TargetClass)) '= 1) {
                        continue
                    }
                }
                
                // ★【新增】平台注册声明校验（只校验一次调用即可）
			    set sc = ..ValidatePlatformRegistration(treg,target)
			    if $$$ISERR(sc) {
			        // 注册错误直接记录为失败结果，不再执行
			        set r = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
			        set r.Success = 0
			        set r.ActionCode = ..ActionCode()
			        set r.ActionName = ..ActionName()
			        set r.Message = $SYSTEM.Status.GetErrorText(sc)
			        d summary.AddResult(r)
			        continue
			    }
	            
                
                // 新增：执行前置过滤判断
                s filterResult = ..CheckFilter(target, bizData, ctx, summary)
                if (filterResult = 0) continue  // 过滤掉了，跳过执行
                
                // 通过过滤，执行推送
#;				if (target.IsAsync()) {
#;				    // 异步推送
#;				    d ..ExecuteAsync(target, bizData, ctx, summary)
#;				} else {
#;				    // 同步推送
#;				    d ..ExecuteOne(target, bizData, ctx, summary)
#;				}

				// 新增与平台交互使用平台推送上下文
				// 构造平台上下文
			    s pctx = ##class(PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext).%New()
			    s pctx.PlatformCode = treg.PlatformCode
			    s pctx.PlatformClass = treg.PlatformClass
				s pctx.MethodName    = treg.MethodName
			    s pctx.PlatformData = treg.PlatformData
                d ..ExecuteOne(target,pctx, bizData, ctx, summary)
            }
        }

        if ('matched) {
            d summary.AddResult(..BuildNotRegisteredResult(ctx))
        }
        q summary
}

/// 检查目标过滤器，如果被过滤则生成过滤结果
/// 检查目标过滤器，如果被过滤则生成过滤结果（修改：整合两种过滤方式）
Method CheckFilter(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, summary As PHA.COM.BaseBizPush.Engine.Result.PushSummary) As %Boolean
{
    set r = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
    set r.ActionCode = ..ActionCode()
    set r.ActionName = ..ActionName()
    set r.HospId = ctx.HospId
    set r.DeptCode = ctx.DeptCode
    set r.BizMainInfo = ctx.GetBizInfo().%ToJSON()
    
    set r.TargetCode = target.GetCode()
    set r.TargetName = target.GetName()
    set r.TargetClass = $classname(target)
    set r.PlatformInfo = "N/A（前置过滤）"
    
    // ============ 方式1：使用GetDataFilter过滤器（原有方式） ============
    set filter = target.GetDataFilter()
    if $isobject(filter) {
        if (filter.ShouldFilter(bizData, ctx)) {
            set r.Success = 0
            set r.Message = "数据被过滤器过滤："_filter.GetFilterMessage(bizData, ctx)
            do summary.AddResult(r)
            return 0  // 被过滤，不执行
        }
    }
    
    // ============ 方式2：使用CustomFilter自定义过滤方法（新增方式） ============
    set filterResult = target.CustomFilter(bizData, ctx)
    if $isobject(filterResult) && filterResult.%IsDefined("passed") {
        if (filterResult.passed = 0) {
            set r.Success = 0
            set message = $s(filterResult.message="":"数据被自定义过滤",1:filterResult.message)
            set r.Message = message
            
            // 可以记录附加数据到日志
            if filterResult.%IsDefined("data") {
                set r.Message = r.Message _ " 附加数据：" _ filterResult.data.%ToJSON()
            }
            
            do summary.AddResult(r)
            return 0  // 被过滤，不执行
        }
    } else {
        // 过滤结果格式异常，默认不通过
        set r.Success = 0
        set r.Message = "自定义过滤结果格式异常"
        do summary.AddResult(r)
        return 0
    }
    
    return 1  // 通过所有过滤，继续执行
}

/// =====================================================
/// Method: ExecuteOne
/// Author: Template
/// Date: 2025-12-25
/// Description:
///     执行单个 Target 的推送（同步 / 异步分流）
/// Input:
///     target  - 推送目标实例
///     bizData - 业务数据（DynamicObject）
///     ctx     - 推送上下文
///     summary - 推送结果汇总对象
/// =====================================================
Method ExecuteOne(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, pctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, summary As PHA.COM.BaseBizPush.Engine.Result.PushSummary)
{
    s result = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()

    // ---------- Action 信息 ----------
    s result.ActionCode = ..ActionCode()
    s result.ActionName = ..ActionName()
    s result.HospId = ctx.HospId
    s result.DeptCode = ctx.DeptCode

    // ---------- Target 信息 ----------
    s result.TargetCode  = target.GetCode()
    s result.TargetName  = target.GetName()
    s result.TargetClass = $classname(target)
	
    // ---------- Platform 信息 ----------
    if pctx.getPlatformAdapter() '= "" {
         s result.PlatformInfo = pctx.GetDisplay()
    }else {
	   	s invoke = target.GetInvoke()
	    s result.PlatformInfo = invoke.GetDisplay()
    }

    // ---------- 同步 / 异步 ----------
    if (target.IsAsync()) {
		
        // 异步执行，仅提交 Job
        job ..ExecuteAsync(
		    $classname(target),
		    pctx.PlatformCode,
		    pctx.PlatformClass,
		    pctx.MethodName,
		    pctx.PlatformData,
		    bizData,
		    ctx.ToDynamicObject()
		)

        // 是否成功由异步内部判定，这里只说明“已提交”
        s result.Success = 1
        s result.Message = "异步推送任务已提交"

    } else {

        // 同步执行
        d ..ExecuteSync(
            target,
            pctx,
            bizData,
            ctx,
            result
        )
    }

    d summary.AddResult(result)
}

/// =====================================================
/// Method: ExecuteSync
/// Author: Template
/// Date: 2025-12-25
/// Description:
///     同步执行平台调用 + 返回解析 + 成功判定
/// =====================================================
Method ExecuteSync(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, pctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, result As PHA.COM.BaseBizPush.Engine.Result.PushResult)
{
    try {
	    s pctx.Payload = target.BuildPayload(bizData, ctx)
	    
        // ---------- 平台调用 ----------
        d ..DoInvoke(
            target,
            pctx,
            bizData,
            ctx
        )

        // ---------- 返回解析 ----------
        // rawResp 可能是 string / stream / object
        s parsed = target.ParseResponse(pctx.RawResponse)

        // ---------- 成功判定 ----------
        s result.Success = target.IsSuccess(parsed)

        // ---------- 结果消息 ----------
        s result.Message = target.BuildResultMessage(parsed)
    }
    catch ex {
        s result.Success = 0
        s result.Message = ex.DisplayString()
    }
}

/// =====================================================
/// ClassMethod: ExecuteAsync
/// Author: Template
/// Date: 2025-12-25
/// Description:
///     异步执行推送逻辑（Job）
/// =====================================================
ClassMethod ExecuteAsync(targetClass As %String, platformCode As %String, platformClass As %String, methodName As %String, platformData As %DynamicObject, bizData As %DynamicObject, ctxObj As %DynamicObject)
{
    try {
	    // ---------- 还原 Context ----------
	    s ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
	    s ctx.TriggerCode = ctxObj.triggerCode
	    s ctx.HospId      = ctxObj.hospId
	    s ctx.DeptCode    = ctxObj.deptCode
	    d ctx.SetBizInfo(ctxObj.bizInfo)

	    s target = $classmethod(targetClass, "%New")
		// ---------- ★ 重新构造 PlatformInvokeContext ----------
	    s pctx = ##class(PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext).%New()
	    s pctx.PlatformCode = platformCode
	    s pctx.PlatformClass = platformClass
	    s pctx.MethodName = methodName
	    s pctx.PlatformData = platformData
	    s pctx.Payload = target.BuildPayload(bizData, ctx)
	
        d ..DoInvoke(
            target,
            pctx,
            bizData,
            ctx
        )
		// rawResp 可能是 string / stream / object
        s parsed = target.ParseResponse(pctx.RawResponse)

        // 异步同样执行成功判定（用于日志 / 统计）
        s success = target.IsSuccess(parsed)

    }
    catch ex {
        // 异步异常仅记录，不抛出
    }
}

/**
 * Author: MPF
 * Date: 2026-01-28
 * Description:
 *   平台调用统一入口
 *   优先 Adapter → 兜底 PlatformInvoke
 */
Method DoInvoke(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, pctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, ByRef rawResp) As %Status
{
    #dim sc As %Status = $$$OK
    #dim adapterClass As %String
    #dim adapter As PHA.COM.BaseBizPush.Engine.Platform.Adapter.PlatformAdapter

    // 1. Adapter 优先
    s adapterClass = pctx.getPlatformAdapter()

    if adapterClass '= "" {
        s adapter = $classmethod(adapterClass, "%New")
        s sc = adapter.Invoke(pctx)
        q sc
    }else {

	    // 2. 兜底旧 PlatformInvoke
	    s pctx.RawResponse = target.GetInvoke().Invoke(
	        pctx.PlatformCode,
	        pctx.Payload
	    )
    }

    q sc
}

/// =====================================================
/// Method: DoInvoke
/// Description:
///     执行平台接口调用，返回原始平台响应（不限定类型）
/// =====================================================
Method DoBaseInvoke(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, platformCode As %String, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, ByRef rawResp)
{
    s payload = target.BuildPayload(bizData, ctx)
	// rawResp 可能是 string / stream / object
    s rawResp = target.GetInvoke().Invoke(
        platformCode,		//target.GetCode(),
        payload
    )
}

Method ExecuteOneSync(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, platformCode As %String, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext, summary As PHA.COM.BaseBizPush.Engine.Result.PushSummary)
{
        s r = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
        s r.ActionCode = ..ActionCode()
        s r.ActionName = ..ActionName()
        s r.HospId = ctx.HospId
        s r.DeptCode = ctx.DeptCode
        s r.BizMainInfo = ctx.GetBizInfo().%ToJSON()

        s r.TargetCode = target.GetCode()
        s r.TargetName = target.GetName()
        s r.TargetClass = $classname(target)

        s invoke = target.GetInvoke()
        s r.PlatformInfo = invoke.GetDisplay()

        // 注意：这里移除了过滤逻辑，因为已经在CheckFilter中处理了
        try {
            s payload = target.BuildPayload(bizData, ctx) 
            s rawResp = invoke.Invoke(platformCode, payload)	//r.TargetCode
            s parsed = target.ParseResponse(rawResp)
            s r.Success = target.IsSuccess(parsed)
            s r.Message = target.BuildResultMessage(parsed)
        } catch ex {
            s r.Success = 0
            s r.Message = ex.DisplayString()
        }

        d summary.AddResult(r)
}

Method BuildNotRegisteredResult(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As PHA.COM.BaseBizPush.Engine.Result.PushResult
{
        s r = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
        s r.Success = 0
        s r.ActionCode = ..ActionCode()
        s r.ActionName = ..ActionName()
        s r.HospId = ctx.HospId
        s r.DeptCode = ctx.DeptCode
        s r.BizMainInfo = ctx.GetBizInfo().%ToJSON()
        s r.Message = "推送接口未注册"
        q r
}

Method ActionCode() As %String [ Abstract ]
{
}

Method ActionName() As %String [ Abstract ]
{
}

Method Registrations() As %ListOfObjects [ Abstract ]
{
}

Method GetBizData(ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %DynamicObject [ Abstract ]
{
}

Method ValidatePlatformRegistration(treg As PHA.COM.BaseBizPush.Engine.Template.TargetRegistration, target As PHA.COM.BaseBizPush.Engine.Target.ITarget)
{
	s sc = treg.ValidatePlatformRegistration()
	if $$$ISERR(sc) {
		q sc
	}else {
		s platform = target.GetInvoke()
		s sc = platform.ValidatePlatformRegistration()
	}
	
	q sc
}

}
