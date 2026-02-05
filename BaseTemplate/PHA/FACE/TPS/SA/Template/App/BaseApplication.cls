Class PHA.FACE.TPS.SA.Template.App.BaseApplication Extends %RegisteredObject
{

/*
=========================================================
BaseApplication
---------------------------------------------------------
Author: Valen MPF
Date  : 2025-12-30
Description:
    Template 应用基类，负责：
    - 定义 Pipeline 的标准构建顺序
    - 明确哪些能力是【必须实现】
    - 明确哪些能力是【业务可选扩展】
    
    设计原则：
    - Template 不包含任何业务判断
    - 所有业务差异通过重写扩展点完成
=========================================================
*/

/* =====================================================
 * 必须实现的方法（流程义务）
 * ===================================================== */

/*
---------------------------------------------------------
initContext
---------------------------------------------------------
Author: Valen MPF
Description:
    初始化 DocumentContext，构建 SourceList
    没有 Context，Pipeline 无法运行
---------------------------------------------------------
Output:
    PHA.FACE.TPS.SA.Template.Context.DocumentContext
---------------------------------------------------------
*/
Method initContext() As PHA.FACE.TPS.SA.Template.Context.DocumentContext [ Abstract ]
{
}

/*
---------------------------------------------------------
getBizHandler
---------------------------------------------------------
Author: Valen MPF
Description:
    返回业务处理 Handler（Pipeline 终点）
    不允许缺省实现
---------------------------------------------------------
Output:
    PHA.FACE.TPS.SA.Template.Pipeline.Handler
---------------------------------------------------------
*/
Method getBizHandler() As PHA.FACE.TPS.SA.Template.Pipeline.Handler [ Abstract ]
{
}

/*
---------------------------------------------------------
getGroupRule
---------------------------------------------------------
Description:
    返回分组规则（如按单据号分单）
    默认不启用
---------------------------------------------------------
*/
Method getGroupRule() As PHA.FACE.TPS.SA.Template.Group.GroupRule [ Abstract ]
{
    Quit ""
}

/* =====================================================
 * 可选扩展点（能力，不是义务）
 * ===================================================== */

/*

---------------------------------------------------------
getValidationRules
---------------------------------------------------------
Description:
    字段级 / 行级校验规则
    在映射前执行
---------------------------------------------------------
*/
Method getValidationRules() As %ListOfObjects
{
    Quit ""
}

/*
---------------------------------------------------------
getMappingSet
---------------------------------------------------------
Description:
    映射规则定义
    Mapping 是可选能力，不强制
---------------------------------------------------------
*/
Method getMappingSet() As PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{
    Quit ""
}

/*
---------------------------------------------------------
getTransformRules
---------------------------------------------------------
Description:
    映射后的二次转换规则
---------------------------------------------------------
*/
Method getTransformRules() As %ListOfObjects
{
    Quit ""
}

/*
---------------------------------------------------------
getDocumentValidator
---------------------------------------------------------
Description:
    单据级业务校验器（业务自决）
    返回实现了 IDocumentValidator 的实例
---------------------------------------------------------
*/
Method getDocumentValidator() As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{
    Quit ""
}

/* =====================================================
 * Pipeline 构建（Template 核心）
 * ===================================================== */

/*
---------------------------------------------------------
buildPipeline
---------------------------------------------------------
Author: Valen MPF
Description:
    按既定顺序构建 Pipeline：
    1. Group
    2. DocumentBuild
    3. Field Validation
    4. Mapping
    5. Transform
    6. Document Validation（业务自定义）
    7. BizHandler
---------------------------------------------------------
*/
Method buildPipeline(runner As PHA.FACE.TPS.SA.Template.Pipeline.PipelineRunner) As %Status
{
    // =========================
    // 1. 分组处理
    // =========================
    Set gr = ..getGroupRule()
    If $IsObject(gr) {
        Set gh = ##class(PHA.FACE.TPS.SA.Template.Pipeline.GroupHandler).%New()
        Set gh.rule = gr
        Do runner.AddHandler(gh)
    }

    // =========================
    // 2. 构建 Document
    // =========================
    Do runner.AddHandler(
        ##class(PHA.FACE.TPS.SA.Template.Pipeline.DocumentBuildHandler).%New()
    )

    // =========================
    // 3. 字段级校验（映射前）
    // =========================
    Set vr = ..getValidationRules()
    If $IsObject(vr), vr.Count() > 0 {
        Set vh = ##class(PHA.FACE.TPS.SA.Template.Pipeline.ValidationHandler).%New()
        Set vh.rules = vr
        Do runner.AddHandler(vh)
    }

    // =========================
    // 4. 映射处理
    // =========================
    Set ms = ..getMappingSet()
    If $IsObject(ms) {
        Set mh = ##class(PHA.FACE.TPS.SA.Template.Pipeline.MappingHandler).%New()
        Set mh.mappingSet = ms
        Do runner.AddHandler(mh)
    }

    // =========================
    // 5. 转换处理
    // =========================
    Set tr = ..getTransformRules()
    If $IsObject(tr), tr.Count() > 0 {
        Set th = ##class(PHA.FACE.TPS.SA.Template.Pipeline.TransformHandler).%New()
        Set th.rules = tr
        Do runner.AddHandler(th)
    }

    // =========================
    // 6. 单据级业务校验
    // =========================
    Set validator = ..getDocumentValidator()
    If $IsObject(validator) {
        Set dh = ##class(PHA.FACE.TPS.SA.Template.Pipeline.DocumentValidationHandler).%New()
        Set dh.validator = validator
        Do runner.AddHandler(dh)
    }

    // =========================
    // 7. 业务处理（终点）
    // =========================
    Do runner.AddHandler(..getBizHandler())

    Quit $$$OK
}

/* =====================================================
 * 应用入口
 * ===================================================== */

/*
---------------------------------------------------------
Run
---------------------------------------------------------
Author: Valen MPF
Description:
    应用统一入口：
    - 初始化 Context
    - 构建 Pipeline
    - 执行 Pipeline
---------------------------------------------------------
*/
Method Run11() As %Status
{
    Set sc = $$$OK

    Set context = ..initContext()
    If '$IsObject(context) {
        Quit $$$ERROR($$$GeneralError,"initContext 未返回有效的 Context")
    }

    Set runner = ##class(PHA.FACE.TPS.SA.Template.Pipeline.PipelineRunner).%New()

    Set sc = ..buildPipeline(runner)
    If $$$ISERR(sc) {
        Quit sc
    }

    Quit runner.Run(context)
}

/* =====================================================
 * 内部执行（结构化结果）
 * ===================================================== */

/*
---------------------------------------------------------
RunInternal
---------------------------------------------------------
Description:
    执行 Pipeline，返回结构化结果对象
---------------------------------------------------------
Output:
    %DynamicObject
    {
        success : true|false,
        status  : %Status,
        message : string,
        data    : any
    }
---------------------------------------------------------
*/
Method RunInternal() As %DynamicObject
{
    Set result = {}
    Set result.success = 0
    Set result.status  = $$$OK
    Set result.message = ""
    Set result.data    = ""

    Try {
        Set context = ..initContext()
        If '$IsObject(context) {
            Throw ##class(%Exception.General).%New(
                "initContext 返回空对象"
            )
        }

        Set runner = ##class(PHA.FACE.TPS.SA.Template.Pipeline.PipelineRunner).%New()

        Set sc = ..buildPipeline(runner)
        If $$$ISERR(sc) {
            Set result.status = sc
            Set result.message = $SYSTEM.Status.GetErrorText(sc)
            return result
        }

        Set sc = runner.Run(context)
        If $$$ISERR(sc) {
            Set result.status = sc
            Set result.message = $SYSTEM.Status.GetErrorText(sc)
            return result
        }

        // 成功
        Set result.success = 1
        Set result.data = context.Output

    } Catch ex {
        Set result.status = $$$ERROR($$$GeneralError, ex.DisplayString())
        Set result.message = ex.DisplayString()
    }

    Quit result
}

/* =====================================================
 * 兼容入口（保持原语义）
 * ===================================================== */
Method Run() As %Status
{
    Set runResult = ..RunInternal()
    Quit runResult.status
}

/* =====================================================
 * 前端解析方法（新增）
 * ===================================================== */

/*
---------------------------------------------------------
ParseRunResult
---------------------------------------------------------
Author: Valen MPF
Description:
    将 RunInternal 结果转换为前端标准返回
---------------------------------------------------------
Input:
    runResult As %DynamicObject
---------------------------------------------------------
Output:
    %DynamicObject
    {
        success : boolean,
        message : string,
        data    : any
    }
---------------------------------------------------------
*/
/// /ResultCode、ResultMsg
ClassMethod ParseRunResult(runResult As %DynamicObject) As %DynamicObject
{
    Set resp = {}

    If '$IsObject(runResult) {
        Set resp.ResultCode = 1
        Set resp.ResultMsg = "系统未返回执行结果"
        Quit resp
    }

    If runResult.success {
        Set resp.ResultCode = 0
        Set resp.ResultMsg = "success"
        Set resp.data = runResult.data
    } Else {
        Set resp.ResultCode = 1
        Set resp.ResultMsg = runResult.message
    }

    Quit resp
}

}
