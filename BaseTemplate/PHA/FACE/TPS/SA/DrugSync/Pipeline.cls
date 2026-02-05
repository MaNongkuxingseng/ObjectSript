Class PHA.FACE.TPS.SA.DrugSync.Pipeline Extends %RegisteredObject
{

Property Handlers As %ListOfObjects;

Property UseTransaction As %Boolean [ InitialExpression = 1 ];

Method %OnNew() As %Status
{
    set ..Handlers = ##class(%ListOfObjects).%New()
    quit $$$OK
}

Method SetUseTransaction(useTransaction As %Boolean)
{
    set ..UseTransaction = useTransaction
}

Method Execute(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
	s $zt = "ErrExecute"
    set sc = $$$OK
    
    // 执行前验证管道配置
    set validateSc = ..ValidatePipeline()
    if $$$ISERR(validateSc) {
        quit $$$ERROR($$$GeneralError, "管道配置无效: "_$system.Status.GetErrorText(validateSc))
    }
    
    // 根据配置决定是否开启事务
    if ..UseTransaction {
        TSTART
    }
    
    set i = 1
    for  {
        set handler = ..Handlers.GetAt(i)
        if handler="" quit
        
        set sc = handler.Handle(context)
        if $$$ISERR(sc) {
            // 遇到错误立即退出循环
            quit
        }
        set i = i + 1
    }

    // 处理事务提交或回滚
    if ..UseTransaction {
        if $$$ISERR(sc) {
            TROLLBACK
            // 获取处理器信息
            s handlerInfo = "处理器类:["_$classname(handler)_"]"
            // 使用$$$ERROR抛出详细错误信息
            set errorMsg = handlerInfo_$system.Status.GetErrorText(sc)
            quit $$$ERROR($$$GeneralError, "管道执行失败，事务已回滚: "_errorMsg)
        } else {
            TCOMMIT
        }
    } elseif $$$ISERR(sc) {
        // 非事务模式下也使用$$$ERROR抛出错误
        set errorMsg = $system.Status.GetErrorText(sc)
        quit $$$ERROR($$$GeneralError, "管道执行失败: "_errorMsg)
    }
    
    quit sc
    
ErrExecute
	s $zt = ""
    // 回滚事务
    if ..UseTransaction {
        TROLLBACK
    }
    // 使用$$$ERROR抛出异常信息
    quit $$$ERROR($$$GeneralError, "管道执行过程中发生异常: "_$ze)
}

Method ExecuteWithoutTransaction(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    set originalSetting = ..UseTransaction
    set ..UseTransaction = 0
    set sc = ..Execute(context)
    set ..UseTransaction = originalSetting
    quit sc
}

Method AddHandler(handler As PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler)
{
    do ..Handlers.Insert(handler)
}

Method ClearHandlers()
{
    do ..Handlers.Clear()
}

Method GetHandlerCount() As %Integer
{
    quit ..Handlers.Count()
}

Method ValidatePipeline() As %Status
{
    if ..Handlers.Count() = 0 {
        quit $$$ERROR($$$GeneralError, "管道中没有配置任何处理器")
    }
    
    set i = 1
    for  {
        set handler = ..Handlers.GetAt(i)
        if handler="" quit
        s handlerInfo = ..GetHandlerByPosition(i).%ToJSON()
        if '$isobject(handler) {
            return $$$ERROR($$$GeneralError, "第"_i_"个处理器不是有效的对象"_handlerInfo)
        }
        
        if '$method(handler, "%IsA", "PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler") {
            return $$$ERROR($$$GeneralError, "第"_i_"个处理器不是BaseHandler的子类"_handlerInfo)
        }
        
        set i = i + 1
    }
    
    quit $$$OK
}

Method GetPipelineInfo() As %DynamicObject
{
    set info = {
        "handlerCount": (..Handlers.Count()),
        "useTransaction": (..UseTransaction),
        "handlers": []
    }
    
    set i = 1
    for  {
        set handler = ..Handlers.GetAt(i)
        if handler="" quit
        
        do info.handlers.%Push({
            "index": (i),
            "className": ($classname(handler)),
            "description": (..GetHandlerDescription(handler))
        })
        
        set i = i + 1
    }
    
    quit info
}

ClassMethod GetHandlerDescription(handler As PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler) As %String
{
    set className = $classname(handler)
    
    // 根据类名返回对应的描述
    if className = "PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler" {
        quit "数据验证处理器"
    } elseif className = "PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.FactorySyncHandler" {
        quit "生产企业字典同步处理器"
    } elseif className = "PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.UOMSyncHandler" {
        quit "单位字典同步处理器"
    } elseif className = "PHA.FACE.TPS.SA.DrugSync.Handlers.MappingHandler" {
        quit "数据映射处理器"
    } elseif className = "PHA.FACE.TPS.SA.DrugSync.Handlers.UpsertHandler" {
        quit "新增/更新决策处理器"
    } elseif className = "PHA.FACE.TPS.SA.DrugSync.Handlers.SaveHandler" {
        quit "数据保存处理器"
    } else {
        quit "未知处理器"
    }
}

/// 根据位置索引获取处理器详细信息
/// position: 处理器位置索引 (从1开始)
Method GetHandlerByPosition(position As %Integer) As %DynamicObject
{
    if (position < 1) || (position > ..Handlers.Count()) {
        quit {"success": 0, "error": ("位置索引超出范围 (1-"_..Handlers.Count()_")"), "position": (position)}
    }
    
    set handler = ..Handlers.GetAt(position)
    if '$isobject(handler) {
        quit {"success": 0, "error": "该位置处理器不存在", "position": (position)}
    }
    
    set className = $classname(handler)
    set handlerDesc = ..GetHandlerDescription(handler)
    
    set handlerInfo = {
        "success": 1,
        "position": (position),
        "className": (className),
        "description": (handlerDesc),
        "properties": {},
        "methods": []
    }
    
    // 获取处理器属性信息
    try {
        set classDefinition = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        if $isobject(classDefinition) {
            // 获取属性
            for i=1:1:classDefinition.Properties.Count() {
                set prop = classDefinition.Properties.GetAt(i)
                if $isobject(prop) {
	                continue:prop.Name'="Handle"
                    do handlerInfo.properties.%Set(prop.Name, {
                        "type": (prop.Type),
                        "description": (prop.Description)
                    })
                }
            }
            
            // 获取方法
            for i=1:1:classDefinition.Methods.Count() {
                set method = classDefinition.Methods.GetAt(i)
                if $isobject(method) && (method.Name '= "%OnNew") && (method.Name '= "Handle") {
                    do handlerInfo.methods.%Push({
                        "name": (method.Name),
                        "description": (method.Description),
                        "returnType": (method.ReturnType)
                    })
                }
            }
        }
    } catch ex {
        // 忽略获取类定义时的错误
    }
    
    quit handlerInfo
}

}
