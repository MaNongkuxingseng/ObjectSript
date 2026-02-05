/// 用于将 context 中的字典值复写回 DTO
Class PHA.FACE.TPS.SA.DrugSync.Handlers.DictRewriteHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

// 增强版：添加更多检查和日志

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    s sc = $$$OK
    // 参数检查
    If '$IsObject(context) Quit $$$ERROR($$$InvalidArgument, "context不能为空")
    If '$IsObject(context.DTO) Quit $$$ERROR($$$InvalidArgument, "DTO不能为空")
    
    // 检查Dict对象是否存在
    If '$IsObject(context.Dict) Quit $$$OK  // Dict可能为空，直接返回成功
    
    s Dict = context.Dict
    s dto = context.DTO
    s map = ..DictRewriteMap()
    
    // 检查map是否有效
    If '$IsObject(map) Quit $$$ERROR($$$GeneralError, "映射配置无效")
    
    s iterator = map.%GetIterator()
    While iterator.%GetNext(.key, .dtoField) {
        Continue:dtoField=""
        
        // 检查Dict中是否存在该属性
        If Dict.%IsDefined(key) {
            s val = Dict.%Get(key)
            
            // 跳过对象类型的值（如果需要）
            If $IsObject(val) {
                // 可以选择记录日志或处理对象转换
                Continue
            }
            
            Try {
                // 只覆盖非空值
                If val '= "" {
                    s $Property(dto, dtoField) = val
                    // 可选：记录成功的映射
                    // $$$TRACE("映射成功: "_key_" -> "_dtoField_" = "_val)
                }
            }
            Catch ex {
                // 记录错误但继续处理其他字段
                // s sc = $$$ERROR($$$GeneralError, "从SyncContext.Dict设置DTO属性失败: "_dtoField_" = "_val_" 错误: "_ex.DisplayString())
                // 或者使用更轻量的记录方式，避免覆盖原有sc
                s error = $$$ERROR($$$GeneralError, "设置DTO属性失败: "_dtoField)
                if $$$ISERR(sc) s sc = $$$ADDSC(sc, error)
                else  s sc = error
            }
        }
    }
    
    Quit sc
}

ClassMethod DictRewriteMap() As %DynamicObject
{
    // 从SyncContext.Dict映射到DTO
    Quit {
#;        "PHARMACYCATEGORYID": "PharmacyCategoryId",	// 药学分类
#;        "GenericNameId": "GenericNameId",		// 品种通用名
#;        "DosageFormId": "DosageFormId",			// 剂型
        "PRESCRIPTIONGENERICNAMEID": "phcGene",	// 处方通用名
        "arcimPartialValue": "arcimPartialValue",
        "arcimOPPartialValue": "arcimOPPartialValue",
        "phcUom": "phcUom",
        "inciBUom": "inciBUom",
        "inciPUom": "inciPUom",
        "inciOutUom": "inciOutUom",
        "inciInUom": "inciInUom",
        "incscId": "inciStkCat",
        "arcimBillSub":"arcimBillSub",
        "inci":"inci",
        "arci":"arci",
        "arcimItemCat":"arcimItemCat",
        "inciManf":"inciManf",
        // 添加TAR相关字段映射
        "tarSubCate": "tarSubCate",
        "tarInpatCate": "tarInpatCate",
        "tarOutpatCate": "tarOutpatCate",
        "tarAcctCate": "tarAcctCate",
        "tarMCCate": "tarMCCate",
        "tarEMCCate": "tarEMCCate",
        "tarMCCateNew": "tarMCCateNew"
    }
}

}
