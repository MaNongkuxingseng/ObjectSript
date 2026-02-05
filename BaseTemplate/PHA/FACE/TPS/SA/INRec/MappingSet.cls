Class PHA.FACE.TPS.SA.INRec.MappingSet Extends PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{

Method %OnNew() As %Status
{
    Do ##super()
    Do ..Build()
    Quit $$$OK
}

/// =====================================================
/// 入库接口 MappingSet
/// SA 入库接口 → HIS 入库接口
/// 
/// 约定：
/// - Main  : 单据头
/// - Row   : 明细行
/// - 所有字典转换由 Template Resolver 完成
/// =====================================================
Method Build() As %Status
{
    // =========================
    // Main（单据头）
    // =========================
	Do ..AddFieldRule("rkno", "rkno", "Main") // 新增：映射 rkno 到 Main.rkno
    /// 入库科室（SA code → HIS loc）
    Do ..AddDictRule("rkloc", "loc", "Main", "HIS_LOC")

    /// 入库类型（中文描述 → HIS operateType）
    Do ..AddEnumRule("type", "operateType", "Main", "InRecType")

    /// 供应商（SA code → HIS vendor）
    Do ..AddDictRule("vendor", "vendor", "Main", "HIS_VENDOR")

    /// 采购人员（工号 → HIS user）
    Do ..AddDictRule("cguser", "purchUser", "Main", "HIS_USER")

    /// 入库备注
    Do ..AddFieldRule("note", "remarks", "Main")

    /// 制单人（登录人）
    Do ..AddDictRule("zduser", "logonUser", "Main", "HIS_USER")
    
    /// 制单日期
    Do ..AddFieldRule("zdDate", "zdDate", "Main")
#;    Do ..AddMethodRule(
#;	    "zdDate",                               // Source
#;	    "zdDate",                               // Target
#;	    "Main",                                 // Scope
#;	    "PHA.FACE.TPS.SA.Util.DateUtil",        // 工具类
#;	    "NormalizeDate",                        // 方法名
#;	    {"format":"YYYY-MM-DD"}                 // 可选参数
#;	)
    
    /// 制单时间
    Do ..AddFieldRule("zdTime", "zdTime", "Main")

    /// 登录科室（与入库科室一致）
    Do ..AddDictRule("rkloc", "logonLoc", "Main", "HIS_LOC")

    /// 医院、集团（系统常量）
    Do ..AddConstRule("2",  "logonHosp",  "Main")
    Do ..AddConstRule("42", "logonGroup", "Main")

    // =========================
    // Row（明细行）
    // =========================

    /// 药品编码（SA → HIS）
    Do ..AddDictRule("incno", "inci", "Row", "HIS_DRUG")

    /// 药品名称
    Do ..AddFieldRule("incdesc", "inciDesc", "Row")

    /// 单位（SA 单位 → HIS 单位 ID）
    Do ..AddDictRule("uom", "uom", "Row", "HIS_UOM")

    /// 单位描述
    //Do ..AddFieldRule("uom", "uomDesc", "Row")

    /// 生产企业（SA code → HIS manf）
    Do ..AddDictRule("manf", "manf", "Row", "HIS_MANF")

    /// 生产企业描述
    Do ..AddFieldRule("manfdesc", "manfDesc", "Row")

    /// 数量
    Do ..AddFieldRule("qty", "qty", "Row")

    /// 进价
    Do ..AddFieldRule("rp", "rp", "Row")

    /// 售价（如后续启用）
    Do ..AddFieldRule("sp", "sp", "Row")

    /// 进价金额
    Do ..AddFieldRule("rpAmt", "rpAmt", "Row")

    /// 售价金额
    Do ..AddFieldRule("spAmt", "spAmt", "Row")

    /// 批号
    /// Do ..AddFieldRule("batNo", "batNo", "Row")

    /// 效期
    Do ..AddFieldRule("expDate", "expDate", "Row")

    /// 批次号---- 直接使用海典的批次号作为批次标识
    Do ..AddFieldRule("Batid", "batNo", "Row")

    Quit $$$OK
}

/// w ##class(PHA.FACE.TPS.SA.INRec.MappingSet).Test()
ClassMethod Test()
{
	Set ms = ##class(PHA.FACE.TPS.SA.INRec.MappingSet).%New()

	Try {
	    Do ms.AddDictRule("a","b","Main","TEST")
	    Write "OK"
	} Catch ex {
	    Write ex.DisplayString()
	}
}

}
