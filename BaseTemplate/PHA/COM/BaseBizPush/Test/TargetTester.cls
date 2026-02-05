/// 单目标推送测试工具
/// 用于在开发调试时单独测试某个Target，避免触发所有注册的推送
Class PHA.COM.BaseBizPush.Test.TargetTester Extends %RegisteredObject
{

/// 按Target类名测试单个目标
/// 示例：
/// w ##class(PHA.COM.BaseBizPush.Test.TargetTester).TestTargetByClass(
///     "PHA.FACE.TPS.SA.HIS2SA.Target.HerbRefundTarget",
///     "OP_HERB_REFUND",
///     "SC001",
///     "PHA1",
///     {"refundId":"REFUND001"}
/// 		"MES0030"
/// 		"web.DHCENS.STBLL.SOAP.PUB0005Soap"
/// 		"HIPMessageInfo"
/// 		{}
/// )
ClassMethod TestTargetByClass(targetClass As %String, entryCode As %String, hospId As %String, deptCode As %String, bizInfo As %DynamicObject, skipFilter As %Boolean = 0, platformCode As %String = "", platformClass As %String = "", platformMethod As %String = "", platformData As %DynamicObject = "") As %String
{
    Write !, "========================================", !
    Write "单目标测试工具", !
    Write "========================================", !
    Write "Target类: ", targetClass, !
    Write "入口代码: ", entryCode, !
    Write "院区: ", hospId, !
    Write "科室: ", deptCode, !
    Write "跳过过滤: ", $Select(skipFilter:"是",1:"否"), !
    Write "========================================", !!
    
    // 1. 构造上下文
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = entryCode
    Set ctx.HospId = hospId
    Set ctx.DeptCode = deptCode
    Set ctx.BizInfo = bizInfo
    
    // 2. 获取Entry实例以获取业务数据
    Set entryClass = ..ResolveEntryClass(entryCode)
    If entryClass = "" {
        Write "错误: 未找到入口类 [", entryCode, "]", !
        Quit ""
    }
    
    Set entry = $classmethod(entryClass, "%New")
    Write "Entry类: ", entryClass, !!
    
    // 3. 获取业务数据
    Write "获取业务数据...", !
    Set bizData = entry.GetBizData(ctx)
    Write "业务数据获取完成", !!
    
    // 4. 创建Target实例
    Write "创建Target实例...", !
    Set target = $classmethod(targetClass, "%New")
    If '$IsObject(target) {
        Write "错误: 无法创建Target实例", !
        Quit ""
    }
    Write "Target: ", target.GetName(), " [", target.GetCode(), "]", !!
    
    // 5. 检查过滤器（可选）
    If 'skipFilter {
        Write "检查数据过滤...", !
        
        // 检查GetDataFilter
        Set filter = target.GetDataFilter()
        If $IsObject(filter) {
            If filter.ShouldFilter(bizData, ctx) {
                Write "❌ 数据被过滤器过滤: ", filter.GetFilterMessage(bizData, ctx), !
                Quit ""
            }
        }
        
        // 检查CustomFilter
        Set filterResult = target.CustomFilter(bizData, ctx)
        If $IsObject(filterResult) && (filterResult.passed = 0) {
            Write "❌ 数据被自定义过滤: ", filterResult.message, !
            Quit ""
        }
        
        Write "✓ 通过过滤检查", !!
    } Else {
        Write "⚠️  跳过过滤检查", !!
    }
    
    // 6. 构造平台调用上下文
    Write "构造平台调用上下文...", !
    Set pctx = ##class(PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext).%New()
    
    // 如果指定了平台参数，使用指定的；否则使用默认的
    If platformCode '= "" {
        Set pctx.PlatformCode = platformCode
        Set pctx.PlatformClass = platformClass
        Set pctx.MethodName = platformMethod
        Set pctx.PlatformData = platformData
        Write "使用自定义平台参数", !
    } Else {
        // 从Target的GetInvoke获取默认平台信息
        Set invoke = target.GetInvoke()
        Set pctx.PlatformCode = ""
        Set pctx.PlatformClass = invoke.PlatformClass
        Set pctx.MethodName = invoke.MethodName
        Set pctx.PlatformData = {}
        Write "使用Target默认平台配置", !
    }
    
    Write "平台: ", pctx.PlatformClass, "->", pctx.MethodName, !!
    
    // 7. 构建Payload
    Write "构建推送数据...", !
    Set pctx.Payload = target.BuildPayload(bizData, ctx)
    
    // 显示Payload预览
    If $IsObject(pctx.Payload) {
        Set preview = pctx.Payload.Read(500)
        Do pctx.Payload.Rewind()
        Write "Payload预览 (前500字符):", !
        Write preview, !
        If pctx.Payload.Size > 500 {
            Write "... (总计 ", pctx.Payload.Size, " 字符)", !
        }
    }
    Write !
    
    // 8. 执行推送
    Write "执行推送...", !
    Write "----------------------------------------", !
    
    Set result = ##class(PHA.COM.BaseBizPush.Engine.Result.PushResult).%New()
    Set result.ActionCode = entryCode
    Set result.ActionName = entry.ActionName()
    Set result.HospId = hospId
    Set result.DeptCode = deptCode
    Set result.TargetCode = target.GetCode()
    Set result.TargetName = target.GetName()
    Set result.TargetClass = targetClass
    
    Try {
        // 调用平台
        Do ..DoInvoke(target, pctx, bizData, ctx)
        
        // 解析返回
        Set parsed = target.ParseResponse(pctx.RawResponse)
        Set result.Success = target.IsSuccess(parsed)
        Set result.Message = target.BuildResultMessage(parsed)
        
        Write "平台返回: ", pctx.RawResponse, !
        Write "解析结果: ", parsed.%ToJSON(), !
        
    } Catch ex {
        Set result.Success = 0
        Set result.Message = ex.DisplayString()
        Write "❌ 异常: ", ex.DisplayString(), !
    }
    
    Write "----------------------------------------", !!
    
    // 9. 显示结果
    If result.Success {
        Write "✅ 推送成功", !
    } Else {
        Write "❌ 推送失败", !
    }
    Write "消息: ", result.Message, !!
    
    // 10. 返回JSON结果
    Set dto = result.ToFrontDTO()
    Quit dto.%ToJSON()
}

/// 按Target代码测试
/// 示例：
/// w ##class(PHA.COM.BaseBizPush.Test.TargetTester).TestTargetByCode(
///     "HERB_REFUND",
///     "OP_HERB_REFUND",
///     "SC001",
///     "PHA1",
///     {"refundId":"REFUND001"}
/// )
ClassMethod TestTargetByCode(targetCode As %String, entryCode As %String, hospId As %String, deptCode As %String, bizInfo As %DynamicObject, skipFilter As %Boolean = 0) As %String
{
    // 通过Target代码找到Target类
    Set targetClass = ..FindTargetClassByCode(targetCode, entryCode, hospId, deptCode)
    
    If targetClass = "" {
        Write "❌ 未找到Target代码: ", targetCode, !
        Write "请检查:", !
        Write "  1. Target代码是否正确", !
        Write "  2. Target是否已注册到指定的Entry/院区/科室", !
        Quit ""
    }
    
    // 调用按类名测试的方法
    Quit ..TestTargetByClass(targetClass, entryCode, hospId, deptCode, bizInfo, skipFilter)
}

/// 仅测试Payload构建（不实际推送）
/// w ##class(PHA.COM.BaseBizPush.Test.TargetTester).TestPayloadOnly(
///     "PHA.FACE.TPS.SA.HIS2SA.Target.HerbRefundTarget",
///     "OP_HERB_REFUND",
///     "SC001",
///     "PHA1",
///     {"refundId":"REFUND001"}
/// )
ClassMethod TestPayloadOnly(targetClass As %String, entryCode As %String, hospId As %String, deptCode As %String, bizInfo As %DynamicObject) As %String
{
    Write !, "========================================", !
    Write "Payload构建测试（不实际推送）", !
    Write "========================================", !
    Write "Target类: ", targetClass, !
    Write "========================================", !!
    
    // 构造上下文
    Set ctx = ##class(PHA.COM.BaseBizPush.Engine.Context.PushContext).%New()
    Set ctx.TriggerCode = entryCode
    Set ctx.HospId = hospId
    Set ctx.DeptCode = deptCode
    Set ctx.BizInfo = bizInfo
    
    // 获取Entry和业务数据
    Set entryClass = ..ResolveEntryClass(entryCode)
    Set entry = $classmethod(entryClass, "%New")
    Set bizData = entry.GetBizData(ctx)
    
    // 创建Target
    Set target = $classmethod(targetClass, "%New")
    
    // 构建Payload
    Write "构建Payload...", !!
    Set payload = target.BuildPayload(bizData, ctx)
    
    If $IsObject(payload) {
        Set content = payload.Read()
        Write "========================================", !
        Write "Payload 内容:", !
        Write "========================================", !
        Write content, !
        Write "========================================", !
        Write "大小: ", payload.Size, " 字符", !
        Quit content
    } Else {
        Write "❌ Payload构建失败", !
        Quit ""
    }
}

/// 列出指定Entry下所有注册的Target
/// w ##class(PHA.COM.BaseBizPush.Test.TargetTester).ListAllTargets("OP_HERB_REFUND")
ClassMethod ListAllTargets(entryCode As %String) As %String
{
    Write !, "========================================", !
    Write "Entry [", entryCode, "] 注册的所有Target", !
    Write "========================================", !!
    
    Set entryClass = ..ResolveEntryClass(entryCode)
    If entryClass = "" {
        Write "❌ 未找到Entry: ", entryCode, !
        Quit ""
    }
    
    Set entry = $classmethod(entryClass, "%New")
    Set regs = entry.Registrations()
    
    Set result = []
    Set totalCount = 0
    
    For i=1:1:regs.Count() {
        Set reg = regs.GetAt(i)
        
        Write "【", i, "】院区: ", reg.HospId, " | 科室: ", reg.DeptCode, !
        Write "    Target列表:", !
        
        For j=1:1:reg.Targets.Count() {
            Set treg = reg.Targets.GetAt(j)
            Set targetClass = treg.TargetClass
            
            Set target = $classmethod(targetClass, "%New")
            
            Set totalCount = totalCount + 1
            
            Write "    [", totalCount, "] ", target.GetName(), !
            Write "        代码: ", target.GetCode(), !
            Write "        类名: ", targetClass, !
            Write "        平台: ", treg.PlatformClass, "->", treg.MethodName, !
            Write "        异步: ", $Select(target.IsAsync():"是",1:"否"), !
            Write !
            
            Set targetInfo = {
                "code": (target.GetCode()),
                "name": (target.GetName()),
                "class": (targetClass),
                "hospId": (reg.HospId),
                "deptCode": (reg.DeptCode),
                "isAsync": (target.IsAsync())
            }
            Do result.%Push(targetInfo)
        }
    }
    
    Write "========================================", !
    Write "共找到 ", totalCount, " 个Target", !
    Write "========================================", !!
    
    Quit result.%ToJSON()
}

/// 通过Target代码查找Target类名
ClassMethod FindTargetClassByCode(targetCode As %String, entryCode As %String, hospId As %String, deptCode As %String) As %String
{
    Set entryClass = ..ResolveEntryClass(entryCode)
    If entryClass = "" Quit ""
    
    Set entry = $classmethod(entryClass, "%New")
    Set regs = entry.Registrations()
    
    For i=1:1:regs.Count() {
        Set reg = regs.GetAt(i)
        
        // 匹配院区和科室
        If (reg.HospId '= hospId) Continue
        If (reg.DeptCode '= deptCode) Continue
        
        For j=1:1:reg.Targets.Count() {
            Set treg = reg.Targets.GetAt(j)
            Set targetClass = treg.TargetClass
            Set target = $classmethod(targetClass, "%New")
            
            If target.GetCode() = targetCode {
                Quit targetClass
            }
        }
    }
    
    Quit ""
}

/// 解析Entry类名（复用PushService的逻辑）
ClassMethod ResolveEntryClass(entryCode As %String) As %String
{
    Set cls = ""
    Set entryCode = $zconvert(entryCode, "U")
    Set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")
    
    Do rs.Execute("PHA.COM.BaseBizPush.Business.BaseBizPushTemplate")
    
    While rs.Next() {
        Set clsName = rs.Get("Name")
        Set bizClass = $classmethod(clsName, "%New")
        
        If bizClass.ActionCode() = entryCode {
            Set cls = clsName
            Quit
        } Else {
            Kill bizClass
        }
    }
    
    Quit cls
}

/// 执行平台调用（简化版）
ClassMethod DoInvoke(target As PHA.COM.BaseBizPush.Engine.Target.ITarget, pctx As PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext, bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext)
{
    // 优先使用Adapter
    Set adapterClass = pctx.getPlatformAdapter()
    
    If adapterClass '= "" {
        Set adapter = $classmethod(adapterClass, "%New")
        Do adapter.Invoke(pctx)
    } Else {
        // 兜底使用PlatformInvoke
        Set invoke = target.GetInvoke()
        Set pctx.RawResponse = invoke.Invoke(pctx.PlatformCode, pctx.Payload)
    }
}

/// 快速测试方法 - 使用简化参数
/// 示例：
/// // 退药Target测试
/// d ##class(PHA.COM.BaseBizPush.Test.TargetTester).QuickTest("HERB_REFUND", "REFUND001")
/// 
/// // 发药Target测试
/// d ##class(PHA.COM.BaseBizPush.Test.TargetTester).QuickTest("HERB_CONSUME", "DISP001", "OP_HERB_DISPEN")
/// 
ClassMethod QuickTest(targetCode As %String, bizId As %String, entryCode As %String = "OP_HERB_REFUND", hospId As %String = "SC001", deptCode As %String = "PHA1")
{
    Write !, "========================================", !
    Write "快速测试: ", targetCode, !
    Write "========================================", !!
    
    // 根据entryCode构造不同的bizInfo
    Set bizInfo = {}
    
    If entryCode = "OP_HERB_REFUND" {
        Do bizInfo.%Set("refundId", bizId)
    } ElseIf entryCode = "OP_HERB_DISPEN" {
        Do bizInfo.%Set("prescNo", bizId)
    } Else {
        Do bizInfo.%Set("id", bizId)
    }
    
    // 调用测试
    Write ##class(PHA.COM.BaseBizPush.Test.TargetTester).TestTargetByCode(
        targetCode,
        entryCode,
        hospId,
        deptCode,
        bizInfo
    )
}

}
