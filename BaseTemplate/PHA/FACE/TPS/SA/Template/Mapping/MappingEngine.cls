Class PHA.FACE.TPS.SA.Template.Mapping.MappingEngine Extends %RegisteredObject
{

/// =====================================================
/// MapDocument
/// -----------------------------------------------------
/// 根据 MappingSet 将 SA Document 映射为 HIS 数据结构
/// - MainRules : 单据头
/// - RowRules  : 明细行
/// - Resolver  : 唯一执行入口
/// =====================================================
ClassMethod MapDocument(doc As PHA.FACE.TPS.SA.Template.Context.Document, mappingSet As PHA.FACE.TPS.SA.Template.Mapping.MappingSet) As %Status
{
    Set sc = $$$OK
    Set result = ##class(%DynamicObject).%New()

    // =========================
    // 1. Main 映射
    // =========================
    If mappingSet.MainRules.Count() > 0 {
        Set main = ##class(%DynamicObject).%New()

        If doc.Items.Count() = 0 {
            Quit $$$ERROR($$$GeneralError,"Main 映射失败：Document.Items 为空")
        }

        Set src = doc.Items.GetAt(1)

        For i=1:1:mappingSet.MainRules.Count() {
            Set r = mappingSet.MainRules.GetAt(i)

            Set sc = $$$ADDSC(sc,..ApplyRule(src, main, r, "Main"))
        }

        Do result.%Set("main", main)
    }

    // =========================
    // 2. Row 映射
    // =========================
    If mappingSet.RowRules.Count() > 0 {
        Set rows = ##class(%DynamicArray).%New()

        For rowIndex=1:1:doc.Items.Count() {
            Set src = doc.Items.GetAt(rowIndex)
            Set row = ##class(%DynamicObject).%New()

            For j=1:1:mappingSet.RowRules.Count() {
                Set r = mappingSet.RowRules.GetAt(j)

                Set sc = $$$ADDSC(sc,..ApplyRule(src, row, r, "Row["_rowIndex_"]"))
            }

            Do rows.%Push(row)
        }

        Do result.%Set("rows", rows)
    }

    Set doc.Data = result
    Quit sc
}

/// =====================================================
/// ApplyRule
/// -----------------------------------------------------
/// 应用单条映射规则
/// - 统一 Source 读取
/// - 统一 Resolver 执行
/// - 统一 Target 写入
/// =====================================================
ClassMethod ApplyRule(src As %DynamicObject, targetObj As %DynamicObject, rule As PHA.FACE.TPS.SA.Template.Mapping.MappingRule, scopeLabel As %String) As %Status
{
    // ---------- Source 校验 ----------
    If rule.Source '= "" {
        If '$IsObject(src) {
            Quit $$$ERROR($$$GeneralError,scopeLabel_" 源数据不是对象")
        }

        If 'src.%IsDefined(rule.Source) {
            Quit $$$ERROR($$$GeneralError,scopeLabel_" 映射字段不存在: "_rule.Source)
        }

        Set value = src.%Get(rule.Source)
    }
    Else {
        Set value = ""
    }

    // ---------- Resolver 执行 ----------
    If rule.Resolver = "" {
        Quit $$$ERROR($$$GeneralError,scopeLabel_" Resolver 未配置，Target="_rule.Target)
    }

    Set value = ..ApplyResolver(
        rule.Resolver,
        value,
        rule.Params
    )

    // Resolver 结果为空，直接失败
    If (rule.NullAble=$$$NO)&&(value = "") {
        Quit $$$ERROR($$$GeneralError,scopeLabel_" 字段映射结果为空, Source="_rule.Source_", Target="_rule.Target)
    }
#;    If rule.Resolver '= "" {
#;        Set value = ..ApplyResolver(
#;            rule.Resolver,
#;            value,
#;            rule.Params
#;        )
#;
#;        // ★ 映射结果为空直接报错
#;        If value = "" {
#;            Quit $$$ERROR($$$GeneralError,scopeLabel_" 字段映射结果为空，Source="_rule.Source_", Target="_rule.Target_", Params="_rule.Params.%ToJSON())
#;        }
#;    }ELSE{
#;	    B ;
#;    }

    // ---------- 写入 Target ----------
    Do ..SetTargetValue(targetObj, rule.Target, value)

    Quit $$$OK
}

/// =====================================================
/// ApplyResolver
/// -----------------------------------------------------
/// 调用 Resolver 执行值转换
/// Resolver 必须实现：
///   ClassMethod Resolve(value, params) As %String
/// =====================================================
ClassMethod ApplyResolver(resolverClass As %String, value, params As %DynamicObject) As %String
{
    If resolverClass = "" Quit value

    Try {
        Set result =
            $ClassMethod(resolverClass, "Resolve", value, params)
    }
    Catch ex {
        Throw ##class(%Exception.General).%New(
            "Resolver 执行失败 ["_resolverClass_"] : "
            _ex.DisplayString()
        )
    }

    Quit result
}

/// =====================================================
/// SetTargetValue
/// -----------------------------------------------------
/// 按路径写入 DynamicObject
/// - 支持多级路径 a.b.c
/// - 自动创建中间节点
/// =====================================================
ClassMethod SetTargetValue(targetObj As %DynamicObject, targetPath As %String, value)
{
    If targetPath = "" Quit

    Set parts = $ListFromString(targetPath,".")
    Set node  = targetObj
    Set cnt   = $ListLength(parts)

    For i=1:1:(cnt-1) {
        Set key = $ListGet(parts,i)

        // ★ 修正点：必须先 Set，再 Get
        If 'node.%IsDefined(key) {
            Do node.%Set(key, ##class(%DynamicObject).%New())
        }

        Set node = node.%Get(key)
    }

    Set leaf = $ListGet(parts,cnt)
    Do node.%Set(leaf, value)
}

}
