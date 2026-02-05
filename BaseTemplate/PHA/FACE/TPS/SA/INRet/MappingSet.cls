/// 退货 MappingSet
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 定义SA字段到HIS字段的映射关系
Class PHA.FACE.TPS.SA.INRet.MappingSet Extends PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{

/// 初始化MappingSet，调用Build方法构建映射规则
Method %OnNew() As %Status
{
    Do ##super()
    Do ..Build()
    Quit $$$OK
}

/// 构建字段映射规则
/// Mapping Rule Types:
/// - AddDictRule: 字典映射 (需要查字典表转换)
/// - AddEnumRule: 枚举映射 (固定值映射)
/// - AddFieldRule: 字段直接映射
/// - AddConstRule: 常量映射
Method Build() As %Status
{
    // ===== Main 表头映射 =====
    Do ..AddFieldRule("thno","thno","Main")                    // 退货单号
    Do ..AddDictRule("thloc","loc","Main","HIS_LOC")              // 退货科室 → 科室
    Do ..AddDictRule("type","operateType","Main","HIS_RETOPER_TYPE")       // 退货类型 → 操作类型
    Do ..AddDictRule("vendor","vendor","Main","HIS_VENDOR")       // 供应商 → 供应商
    Do ..AddFieldRule("note","remarks","Main")                    // 备注 → 备注
    Do ..AddDictRule("thuser","logonUser","Main","HIS_USER")      // 制单人 → 登录用户
    Do ..AddDictRule("thloc","logonLoc","Main","HIS_LOC")         // 退货科室 → 登录科室
    Do ..AddConstRule("42","logonGroup","Main")                   // 常量 → 登录院区组
    Do ..AddFieldRule("thDate","thDate","Main") 
    Do ..AddFieldRule("thTime","thTime","Main") 
    // 院区映射
	Do ..AddMethodRule("thloc", "logonHosp", "Main", "PHA.FACE.TPS.SA.INAsp.Com","GetHosp4LocCode",{})

    // ===== Row 明细映射 =====
    Do ..AddDictRule("incno","inci","Row","HIS_DRUG")             // 药品代码 → 药品ID
    Do ..AddFieldRule("incdesc","inciDesc","Row")                 // 药品名称 → 药品描述
    Do ..AddDictRule("uom","uom","Row","HIS_UOM")                 // 单位 → 单位
    Do ..AddDictRule("manf","manf","Row","HIS_MANF")              // 生产企业 → 生产厂家
    Do ..AddFieldRule("manfdesc","manfDesc","Row")                // 生产企业描述 → 生产厂家描述
    Do ..AddFieldRule("qty","qty","Row")                          // 数量 → 数量
    Do ..AddFieldRule("rp","rp","Row")                            // 进价 → 进价
    Do ..AddFieldRule("sp","sp","Row")                            // 售价 → 售价
    Do ..AddFieldRule("rpAmt","rpAmt","Row")                      // 进价金额 → 进价金额
    Do ..AddFieldRule("spAmt","spAmt","Row")                      // 售价金额 → 售价金额
    Do ..AddFieldRule("Batid","batNo","Row")                      // SA批次id → 批号
    Do ..AddFieldRule("expDate","expDate","Row")                  // 效期 → 效期
    // Do ..AddFieldRule("rkId","recItmID","Row")                  // 入库明细id → his入库明细id

    Quit $$$OK
}

}
