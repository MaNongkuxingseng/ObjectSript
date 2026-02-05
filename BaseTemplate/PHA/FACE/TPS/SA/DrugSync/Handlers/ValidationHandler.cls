/// 动态校验 Handler  
/// 基于策略模式，可灵活扩展校验规则  
/// 作者: valen MPF  
/// 日期: 2025-02-16
/// 
Class PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

/// Replace: PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler:Handle
/// 说明 (中文/EN): 批量构造字段规则并调用 ValidationEngine.ValidateBatch 执行所有校验。
/// 变量 (s dto = DTO.value): dto (输入 DTO)，rules (校验规则集合)
Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    s dto = context.DTO
    s rules = ##class(%ListOfObjects).%New()

    ; ==================== 1. 药学分类必填字段 ====================
    ; PHCCCode - 药学分类代码
    d rules.Insert( ..FieldRule("PHCCCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("PHCCCode","Length",{"min":1,"max":50}) )
    
    ; PHCCCat - 药学分类描述
    d rules.Insert( ..FieldRule("PHCCCat","Required") )
    d rules.Insert( ..FieldRuleWithOptions("PHCCCat","Length",{"min":1,"max":100}) )

    ; ==================== 2. 品种通用名必填字段 ====================
    ; HisPhisId - 品种通用名代码
    d rules.Insert( ..FieldRule("HisPhisId","Required") )
    d rules.Insert( ..FieldRuleWithOptions("HisPhisId","Length",{"min":1,"max":50}) )
    
    ; HisPhis - 品种通用名称
    d rules.Insert( ..FieldRule("HisPhis","Required") )
    d rules.Insert( ..FieldRuleWithOptions("HisPhis","Length",{"min":1,"max":200}) )

    ; ==================== 3. 处方通用名必填字段 ====================
    ; HisChisId - 处方通用名代码
    d rules.Insert( ..FieldRule("HisChisId","Required") )
    d rules.Insert( ..FieldRuleWithOptions("HisChisId","Length",{"min":1,"max":50}) )
    
    ; HisChis - 处方通用名
    d rules.Insert( ..FieldRule("HisChis","Required") )
    d rules.Insert( ..FieldRuleWithOptions("HisChis","Length",{"min":1,"max":200}) )
    
    ; phcGene - 处方通用名id
    d rules.Insert( ..FieldRule("phcGene","Required") )
    //d rules.Insert( ..FieldRuleWithOptions("HisChis","Length",{"min":1,"max":200}) )
    
    ; YPJXCode - 剂型代码（字典）
    d rules.Insert( ..FieldRule("YPJXCode","Required") )
    //d rules.Insert( ..DictFieldRule("YPJXCode","YPJX") )
    
    ; YPJXName - 剂型描述
    d rules.Insert( ..FieldRule("YPJXName","Required") )
    d rules.Insert( ..FieldRuleWithOptions("YPJXName","Length",{"min":1,"max":50}) )

    ; ==================== 4. 医嘱项必填字段 ====================
    ; arcimCode - 医嘱项代码
    d rules.Insert( ..FieldRule("arcimCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("arcimCode","Length",{"min":1,"max":50}) )
    
    ; arcimDesc - 医嘱项名称
    d rules.Insert( ..FieldRule("arcimDesc","Required") )
    d rules.Insert( ..FieldRuleWithOptions("arcimDesc","Length",{"min":1,"max":200}) )
    
    ; ARCICCode - 医嘱项子类（医嘱子类）
    d rules.Insert( ..FieldRule("ARCICCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("ARCICCode","Length",{"min":1,"max":50}) )
    
    ; arcimBillGrp - 账单子组	arcimBillGrp
    d rules.Insert( ..FieldRule("ARCSGCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("ARCSGCode","Length",{"min":1,"max":50}) )
    
    ; arcimPartialValue - 住院单次剂量偏好
    d rules.Insert( ..FieldRule("arcimPartialValue","Required") )
    //d rules.Insert( ..FieldRule("arcimPartialValue","Number") )
    d rules.Insert( ..FieldRuleWithOptions("arcimPartialValue","Length",{"min":1,"max":10}) )
    
    ; arcimOPPartialValue - 门急诊单次剂量偏好
    d rules.Insert( ..FieldRule("arcimOPPartialValue","Required") )
    //d rules.Insert( ..FieldRule("arcimOPPartialValue","Number") )
    d rules.Insert( ..FieldRuleWithOptions("arcimOPPartialValue","Length",{"min":1,"max":10}) )
    
    ; arcimStDate 医嘱项生效日期
    d rules.Insert( ..FieldRuleWithOptions("InitTime","Length",{"max":10,"message":"格式要求:'YYYY-M-DD'"}) ) ; yyyy-mm-dd
    
    ; ARCIMEffDate - 生效日期
    d rules.Insert( ..FieldRule("ARCIMEffDate","Required") )
    d rules.Insert( ..FieldRuleWithOptions("ARCIMEffDate","Length",{"min":8,"max":10,"message":"格式要求:'YYYY-M-DD'"}) ) ; yyyy-mm-dd
    
    ; phcUom - 药学基本单位
    d rules.Insert( ..FieldRule("phcUom","Required") )
    //d rules.Insert( ..DictFieldRule("phcUom","UOM") )
    
    ; arcimOwn - 独立医嘱标志 (Y/N)
    //d rules.Insert( ..FieldRule("arcimOwn","Required") )
    d rules.Insert( ..FieldRuleWithOptions("arcimOwn","Enum",{"enumArr":["Y","N"]}) )

    ; ==================== 5. 库存项必填字段 ====================
    ; inciCode - 库存项代码
    d rules.Insert( ..FieldRule("inciCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("inciCode","Length",{"min":1,"max":50}) )
    
    ; inciDesc - 库存项名称
    d rules.Insert( ..FieldRule("inciDesc","Required") )
    d rules.Insert( ..FieldRuleWithOptions("inciDesc","Length",{"min":1,"max":200}) )
    
    ; inciBUom - 基本单位
    d rules.Insert( ..FieldRule("inciBUom","Required") )
    //d rules.Insert( ..DictFieldRule("inciBUom","UOM") )
    
    ; inciPUom - 包装单位
    d rules.Insert( ..FieldRule("inciPUom","Required") )
    //d rules.Insert( ..DictFieldRule("inciPUom","UOM") )
    
    ; inciOutUom - 门诊发药单位
    d rules.Insert( ..FieldRule("inciOutUom","Required") )
    //d rules.Insert( ..DictFieldRule("inciOutUom","UOM") )
    
    ; inciInUom - 住院整包装发药单位
    d rules.Insert( ..FieldRule("inciInUom","Required") )
    //d rules.Insert( ..DictFieldRule("inciInUom","UOM") )
    
    ; WareUnit - 入库单位（商品单位）
    d rules.Insert( ..FieldRule("WareUnit","Required") )
    //d rules.Insert( ..DictFieldRule("WareUnit","UOM") )
    
    ; inciStkCat - 库存分类
    d rules.Insert( ..FieldRule("inciStkCat","Required") )
    d rules.Insert( ..FieldRuleWithOptions("inciStkCat","Length",{"min":1,"max":50}) )
    
    ; inciExpReq - 效期要求 (Required,Optional,Non Required) inciExpReq
    d rules.Insert( ..FieldRule("YPXQ","Required") )
    d rules.Insert( ..FieldRuleWithOptions("YPXQ","Enum",{"enumArr":["R","O","N"]}) )

    ; ==================== 6. 收费项相关必填字段 ====================
    ; tarCode - 收费项代码
    d rules.Insert( ..FieldRule("tarCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("tarCode","Length",{"min":1,"max":50}) )
    
    ; tarDesc - 收费项名称
    d rules.Insert( ..FieldRule("tarDesc","Required") )
    d rules.Insert( ..FieldRuleWithOptions("tarDesc","Length",{"min":1,"max":200}) )
    
    ; NTARMCCode - 新病案首页子类
    d rules.Insert( ..FieldRule("NTARMCCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("NTARMCCode","Length",{"min":1,"max":50}) )
    
    ; TARMCCode - 病案子类
    d rules.Insert( ..FieldRule("TARMCCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TARMCCode","Length",{"min":1,"max":50}) )
    
    ; TAROCCode - 门诊子类
    d rules.Insert( ..FieldRule("TAROCCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TAROCCode","Length",{"min":1,"max":50}) )
    
    ; TARICCode - 住院子类
    d rules.Insert( ..FieldRule("TARICCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TARICCode","Length",{"min":1,"max":50}) )
    
    ; TARECCode - 核算子类
    d rules.Insert( ..FieldRule("TARECCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TARECCode","Length",{"min":1,"max":50}) )
    
    ; TARACCode - 会计子类
    d rules.Insert( ..FieldRule("TARACCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TARACCode","Length",{"min":1,"max":50}) )
    
    ; TARSCCode - 收费子类
    d rules.Insert( ..FieldRule("TARSCCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("TARSCCode","Length",{"min":1,"max":50}) )

    ; ==================== 7. SA系统核心字段 ====================
    ; WareCode - 商品编码
    d rules.Insert( ..FieldRule("WareCode","Required") )
    d rules.Insert( ..FieldRuleWithOptions("WareCode","Length",{"min":1,"max":64}) )
    
    ; WareName - 商品完整名称
    d rules.Insert( ..FieldRule("WareName","Required") )
    d rules.Insert( ..FieldRuleWithOptions("WareName","Length",{"min":1,"max":200}) )
    
    ; WareSpec - 商品规格
    d rules.Insert( ..FieldRule("WareSpec","Required") )
    d rules.Insert( ..FieldRuleWithOptions("WareSpec","Length",{"min":1,"max":100}) )
    
    ; FactoryName - 生产企业
    d rules.Insert( ..FieldRule("FactoryName","Required") )
    d rules.Insert( ..FieldRuleWithOptions("FactoryName","Length",{"min":1,"max":100}) )
    
    ; FileNo - 批准文号
    d rules.Insert( ..FieldRule("FileNo","Required") )
    d rules.Insert( ..FieldRuleWithOptions("FileNo","Length",{"min":1,"max":50}) )
    
    ; WaregeneralName - 通用名
    d rules.Insert( ..FieldRule("WaregeneralName","Required") )
    d rules.Insert( ..FieldRuleWithOptions("WaregeneralName","Length",{"min":1,"max":100}) )
    
    ; MinUnit - 拆零单位
    d rules.Insert( ..FieldRule("MinUnit","Required") )
    //d rules.Insert( ..DictFieldRule("MinUnit","UOM") )
    
    ; MinQty - 批零比率
    d rules.Insert( ..FieldRule("MinQty","Required") )
    d rules.Insert( ..FieldRule("MinQty","Number") )
    d rules.Insert( ..FieldRuleWithOptions("MinQty","Length",{"min":1,"max":10}) )
    
    ; Status - 启用状态
    d rules.Insert( ..FieldRule("Status","Required") )
    d rules.Insert( ..FieldRuleWithOptions("Status","Enum",{"enumArr":["0","1"]}) ) ; 0=停用,1=启用

    ; ==================== 8. 数值格式校验 ====================
    ; AdvsalePrice - 建议零售价
    d rules.Insert( ..FieldRule("AdvsalePrice","Number") )
    
    ; inciRp - 进价
    d rules.Insert( ..FieldRule("inciRp","Number") )
    
    ; inciSp - 售价
    d rules.Insert( ..FieldRule("inciSp","Number") )
    
    ; inciMaxSp - 最高售价
    d rules.Insert( ..FieldRule("inciMaxSp","Number") )

    ; ==================== 9. 日期格式校验 ====================
    ; ARCIMEffDateTo - 医嘱结束日期 (可为空)
    d rules.Insert( ..FieldRuleWithOptions("ARCIMEffDateTo","Length",{"min":0,"max":10,"message":"格式要求:'YYYY-M-DD'"}) )
    
    ; inciPriceDate - 调价日期
    d rules.Insert( ..FieldRuleWithOptions("inciPriceDate","Length",{"min":0,"max":10}) )
    
    ; inciPrcFileDate - 调价文号日期
    d rules.Insert( ..FieldRuleWithOptions("inciPrcFileDate","Length",{"min":0,"max":10}) )
    
    ; InitTime - 建档日期
    d rules.Insert( ..FieldRuleWithOptions("InitTime","Length",{"min":0,"max":19,"message":"格式要求:'YYYY-M-DD HH:MM:SS'"}) ) ; yyyy-mm-dd hh:mm:ss
    
    ; LastTime - 最终修改时间
    d rules.Insert( ..FieldRuleWithOptions("LastTime","Length",{"min":0,"max":19,"message":"格式要求:'YYYY-M-DD HH:MM:SS'"}) )

    ; ==================== 10. 业务逻辑校验 ====================
    ; UpdateFlag - 更新标识
    d rules.Insert( ..FieldRule("UpdateFlag","Required") )
    d rules.Insert( ..FieldRuleWithOptions("UpdateFlag","Enum",{"enumArr":["add","update"]}) )
    
    ; IsInsurance - 医保标识
    d rules.Insert( ..FieldRuleWithOptions("IsInsurance","Enum",{"enumArr":["Y","N"]}) )
    
    ; INFOBasicDrug - 基本药物标志
    d rules.Insert( ..FieldRuleWithOptions("INFOBasicDrug","Enum",{"enumArr":["Y","N"]}) )
    
    ; INFOImportFlag - 进口标志
    d rules.Insert( ..FieldRuleWithOptions("INFOImportFlag","Enum",{"enumArr":["国产","进口","合资"]}) )
    
    ; YPXQ - 效期要求 --  对应到 inciExpReq 此处不再校验
    //d rules.Insert( ..FieldRuleWithOptions("YPXQ","Enum",{"enumArr":["要求","不要求"]}) )

    ; ==================== 11. 执行验证 ====================
    ; 收集所有错误一次性返回
    q ##class(PHA.FACE.TPS.SA.DrugSync.Validation.ValidationEngine).ValidateBatch(dto, rules)
}

Method FieldRuleWithOptions(field As %String, validator As %String, opts As %DynamicObject) As PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule
{
    s fr = ##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).%New()
    s fr.FieldName = field

    // 构建 rule = { "validator": validator , ...opts }
    s rule = {}
    d rule.%Set("validator", validator)

    // 将 opts 合并进 rule
#;    s key=""
#;    f  s key = opts.%GetNext(key)  q:key=""  d rule.%Set(key, opts.%Get(key))
	s rule = ##class(PHA.COM.Json).Extend(rule,opts)

    d fr.Rules.Insert(rule)
    q fr
}

Method FieldRule(field As %String, validator As %String) As PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule
{
    s fr=##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).%New()
    s fr.FieldName=field
    d fr.Rules.Insert({"validator":(validator)})
    q fr
}

Method DictFieldRule(field As %String, dictType As %String) As PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule
{
    s fr=##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).%New()
    s fr.FieldName=field
    d fr.Rules.Insert({"validator":"DictionaryExist","dictType":(dictType)})
    q fr
}

ClassMethod Test()
{
	s fr=##class(PHA.FACE.TPS.SA.DrugSync.Validation.FieldRule).%New()

	s fr.FieldName="test"
	s h = ##class(PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler).%New()
	s fr = h.FieldRuleWithOptions("test","Enum",{"enumArr":([0,1,2])})
	w fr.Rules.GetAt(1).%ToJSON()
}

}
