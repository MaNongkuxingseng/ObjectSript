/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 映射规则集，定义SA到HIS的调价数据映射规则
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspMappingSet Extends PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 对象初始化方法
/// Input: 无
/// Output: %Status - 初始化状态
Method %OnNew() As %Status
{
    Set sc = ##super()
    Quit:$$$ISERR(sc) sc
    
    Set sc = ..Build()
    Quit sc
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 构建SA→HIS调价映射规则
/// Input: 无
/// Output: %Status - 构建状态
/// Example: d ##class(PHA.FACE.TPS.SA.INAsp.INAspMappingSet).Build()
Method Build() As %Status
{
    // ===== Main 部分映射 =====
    // 用户映射：SA调价用户 → HIS用户
    Do ..AddDictRule("tjuser", "logonUser", "Main", "HIS_USER")
    
    // 科室映射：SA调价科室 → HIS科室
    Do ..AddDictRule("tjloc", "logonLoc", "Main", "HIS_LOC")
    
    // 院区映射
    Do ..AddMethodRule("tjloc", "logonHosp", "Main", "PHA.FACE.TPS.SA.INAsp.Com","GetHosp4LocCode",{})
            
    // 调价单号直接映射
    Do ..AddFieldRule("tjno", "aspno", "Main")
    
    // 调价日期映射（如果有的话）
    // Do ..AddFieldRule("tjDate", "preExecuteDate", "Main")
    
    // ===== Row 部分映射 =====
    // 药品代码映射：SA药品代码 → HIS药品字典
    Do ..AddDictRule("incno", "inci", "Row", "HIS_DRUG")
    
    // 单位映射：SA单位 → HIS单位字典
    Do ..AddDictRule("uom", "uom", "Row", "HIS_UOM")
    
    // 价格映射
    Do ..AddFieldRule("thrp", "retUomRp", "Row")
    Do ..AddFieldRule("thsp", "retUomSp", "Row")
    
    // 调价原因映射：SA调价原因 → HIS调价原因字典
    Do ..AddDictRule("tjreason", "reason", "Row", "HIS_ASPREASON")
    
    // 计划执行日期映射
    Do ..AddFieldRule("PlanDate", "preExecuteDate", "Row")
    
    // 备注信息映射
#;    Do ..AddFieldRule("remark", "remark", "Row")
    
    // 批次信息映射（可选）
#;    Do ..AddFieldRule("batNo", "warrentNo", "Row")
#;    Do ..AddFieldRule("expDate", "warrentNoDate", "Row")
    
    // 行序号映射
#;    Do ..AddFieldRule("rowIndex", "rowIndex", "Row")
	
	// 院区映射
	Do ..AddMethodRule("tjloc", "hosp", "Row", "PHA.FACE.TPS.SA.INAsp.Com","GetHosp4LocCode",{})
        
    Quit $$$OK
}

}
