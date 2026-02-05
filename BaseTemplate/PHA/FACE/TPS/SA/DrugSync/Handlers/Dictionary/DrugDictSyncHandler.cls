/// 药品字典同步处理器 - 保存药学分类、品种通用名、处方通用名
/// 继承自 BaseHandler，符合管道模式
/// 作者: valen MPF
/// 日期: 2025-12-01
/// 
Class PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.DrugDictSyncHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

/// 处理字典信息同步
/// 1. 保存药学分类
/// 2. 保存品种通用名  
/// 3. 保存处方通用名
/// 符合管道模式，返回 %Status
Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    set dto = context.DTO
    set sc = $$$OK
    
    // 1. 同步药学分类
    if (dto.PHCCCode '= "") && (dto.PHCCCat '= "") {
	    s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupPharmacyCategory(dto.PHCCCode)
	    if id="" {
		    s dataStr = "^"_dto.PHCCCode_"^"_dto.PHCCCat
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHCCat(id, dataStr)
	        if result.code<0 {
		        b ;
	            quit $$$ERROR($$$GeneralError, "同步药学分类失败: "_result.msg)
	        }
	        do context.Dict.%Set("PHARMACYCATEGORYID", result.data.id)
	        do context.Dict.%Set("PHARMACYCATEGORYACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("PHARMACYCATEGORYID", id)
	        do context.Dict.%Set("PHARMACYCATEGORYACTION", "null")
	    }
        
    }
    
    // 2. 同步品种通用名
    if (dto.HisPhisId '= "") && (dto.HisPhis '= "") {
	    s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupPHChemical(dto.HisPhisId)
	    if id="" {
		    s dataStr = dto.HisPhisId_"^"_dto.HisPhis
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHCChem(id, dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步品种通用名失败: "_result.msg)
	        }
	        do context.Dict.%Set("GENERICNAMEID", result.data.id)
	        do context.Dict.%Set("GENERICNAMEACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("GENERICNAMEID", id)
	        do context.Dict.%Set("GENERICNAMEACTION", "null")
	    }
    }
    
    // 3. 同步剂型
    if (dto.YPJXCode '= "") && (dto.YPJXName '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDosageForm(dto.YPJXCode)
	    if id="" {
		    s dataStr = dto.YPJXCode_"^"_dto.YPJXName
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHCForm(id, dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步品种通用名失败: "_result.msg)
	        }
	        do context.Dict.%Set("DOSAGEFORMID", result.data.id)
	        do context.Dict.%Set("DOSAGEFORMACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("DOSAGEFORMID", id)
	        do context.Dict.%Set("DOSAGEFORMACTION", "null")
	    }
    }
    
    // 4. 同步处方通用名（需要关联信息）
    if (dto.HisChisId '= "") && (dto.HisChis '= "") {
#;        set extraInfo = {
#;            "PHARMACYCATEGORYCODE": (dto.PHCCCode),
#;            "GENERICNAMECODE": (dto.HisPhisId),
#;            "DOSAGEFORMCODE": (dto.YPJXCode),
#;            "PRESCRIPTIONGENERICNAME":(dto.HisPhisId)
#;        }
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupGenericName(dto.HisChisId)
	    if id="" {
	        s PHCCatId = context.Dict.%Get("PHARMACYCATEGORYID")
			s ChemId = context.Dict.%Get("GENERICNAMEID")
			s FormId = context.Dict.%Get("DOSAGEFORMID")
			s GeneCode = dto.HisChisId
			s GeneName = dto.HisChis
			s GeneStDate = ""
			s GeneEdDate = ""
	        s dataStr = PHCCatId_"^"_ChemId_"^"_FormId_"^"_GeneCode_"^"_GeneName_"^"_GeneStDate_"^"_GeneEdDate
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHCGene(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步品种通用名失败: "_result.msg)
	        }
	        do context.Dict.%Set("PRESCRIPTIONGENERICNAMEID", result.data.id)
	        do context.Dict.%Set("PRESCRIPTIONGENERICNAMEACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("PRESCRIPTIONGENERICNAMEID", id)
	        do context.Dict.%Set("PRESCRIPTIONGENERICNAMEACTION", "null")
	    }
    }
    
    // 5. 同步基本单位
    if (dto.MinUnit '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupUom(dto.MinUnit)
	    if id="" {
	        
	        s dataStr = dto.MinUnit_"^"_dto.MinUnit
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveCTUom(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步基本单位失败: "_result.msg)
	        }
	        do context.Dict.%Set("inciBUom", result.data.id)
	        do context.Dict.%Set("inciBUomACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("inciBUom", id)
	        do context.Dict.%Set("inciBUomACTION", "null")
	    }
	    do context.Dict.%Set("inciInUom", context.Dict.inciBUom)	// 门诊发药单位同步取基本单位
    }
    
    // 6. 同步入库单位
    if (dto.WareUnit '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupUom(dto.WareUnit)
	    if id="" {
	        
	        s dataStr = dto.WareUnit_"^"_dto.WareUnit
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveCTUom(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步入库单位失败: "_result.msg)
	        }
	        do context.Dict.%Set("inciPUom", result.data.id)
	        do context.Dict.%Set("inciPUomACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("inciPUom", id)
	        do context.Dict.%Set("inciPUomACTION", "null")
	    }
        do context.Dict.%Set("inciOutUom", context.Dict.inciPUom)		// 门诊发药单位同步取入库单位
    }
    
    // 7. 同步单位转换系数
    if (dto.WareUnit '= "") {
	    s fromUomId = context.Dict.%Get("inciPUom")
	    s toUomId = context.Dict.%Get("inciBUom")
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupCTConFac(fromUomId,toUomId)
	    if id="" {
	        
	        s dataStr = dto.WareUnit_"^"_dto.MinUnit
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveCTConFac(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步入库单位失败: "_result.msg)
	        }
	        do context.Dict.%Set("ctcfId", result.data.id)
	        do context.Dict.%Set("ctcfIdACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("ctcfId", id)
	        do context.Dict.%Set("ctcfIdACTION", "null")
	    }
    }
    // 8.同步厂商
    if (dto.FactoryId '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupPHManufacturer(dto.FactoryId)
        if id="" {
	        s hospId = $p(context.Logon,"^",4)
	        s dataStr = hospId_"^"_dto.FactoryId_"^"_dto.FactoryName
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHManufacturer(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步生产企业失败: "_result.msg)
	        }
	        do context.Dict.%Set("inciManf", result.data.id)
		    do context.Dict.%Set("inciManfACTION", "null")
	    }else{
		    do context.Dict.%Set("inciManf", id)
		    do context.Dict.%Set("inciManfACTION", "null")
	    }
    }
    
    // 9. 同步库存分类
    if (dto.scSCCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupINCStkCat(dto.scSCCode)
	    if id="" {
	        
	        s dataStr = dto.scSCCode_"^"_dto.scSCDesc
	        set result = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveINCStkCat(id,dataStr)
	        if result.code<0 {
	            quit $$$ERROR($$$GeneralError, "同步库存分类失败: "_result.msg)
	        }
	        do context.Dict.%Set("incscId", result.data.id)
	        do context.Dict.%Set("incscIdACTION", result.data.action)
	    }else{
		    do context.Dict.%Set("incscId", id)
	        do context.Dict.%Set("incscIdACTION", "null")
	    }
    }
    
    // 10.获取账单子组id
    if (dto.ARCSGCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupARCBillSub(dto.ARCSGCode)
	    do context.Dict.%Set("arcimBillSub", id)
	    do context.Dict.%Set("arcimBillSubACTION", "null")
    }
    
    // 10.获取医嘱项id
    if (dto.WareCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupARCItmMast(dto.WareCode)
	    do context.Dict.%Set("arci", id)
	    do context.Dict.%Set("arciACTION", "null")
	    do context.Dict.%Set("inciArcim", id)
	    do context.Dict.%Set("inciArcimACTION", "null")
    }
    
    // 11.获取库存项id
    if (dto.WareCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupINCItm(dto.WareCode)
	    do context.Dict.%Set("inci", id)
	    do context.Dict.%Set("inciACTION", "null")
    }
    
    // 12.获取医嘱子类id
    if (dto.ARCICCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupARCItemCat(dto.ARCICCode)
	    do context.Dict.%Set("arcimItemCat", id)
	    do context.Dict.%Set("arcimItemCatACTION", "null")
    }
    
    // 13. 获取收费子类id
    if (dto.TARSCCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTarSubCate(dto.TARSCCode)
        do context.Dict.%Set("tarSubCate", id)
        do context.Dict.%Set("tarSubCateACTION", "null")
    }
    
    // 14. 获取住院收费子类id
    if (dto.TARICCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTARInpatCate(dto.TARICCode)
        do context.Dict.%Set("tarInpatCate", id)
        do context.Dict.%Set("tarInpatCateACTION", "null")
    }
    
    // 15. 获取门诊收费子类id
    if (dto.TAROCCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTAROutpatCate(dto.TAROCCode)
        do context.Dict.%Set("tarOutpatCate", id)
        do context.Dict.%Set("tarOutpatCateACTION", "null")
    }
    
    // 16. 获取核算子类id
    if (dto.TARECCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTarEMCCate(dto.TARECCode)
        do context.Dict.%Set("tarEMCCate", id)
        do context.Dict.%Set("tarEMCCateACTION", "null")
    }
    
    // 17. 获取会计子类id
    if (dto.TARACCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTARAcctCate(dto.TARACCode)
        do context.Dict.%Set("tarAcctCate", id)
        do context.Dict.%Set("tarAcctCateACTION", "null")
    }
    
    // 18. 获取病案子类id
    if (dto.TARMCCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTarMCCate(dto.TARMCCode)
        do context.Dict.%Set("tarMCCate", id)
        do context.Dict.%Set("tarMCCateACTION", "null")
    }
    
    // 19. 获取新病案首页子类id
    if (dto.NTARMCCode '= "") {
        s id = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTarMCCateNew(dto.NTARMCCode)
        do context.Dict.%Set("tarMCCateNew", id)
        do context.Dict.%Set("tarMCCateNewACTION", "null")
    }
    
    // 20.其他默认值字段
    do context.Dict.%Set("arcimPartialValue", "A")
    do context.Dict.%Set("arcimOPPartialValue", "FU")
    // 账单子组 ARCIM_BillSub_DR
    do context.Dict.%Get("ARCSGCode")	// ^ARCBG("SG_Desc",$$ALPHAUP({ARCSG_Desc}),{ARC_BillGrp.ARCBG_RowId},{ARCSG_ChildSub})
    do context.Dict.%Set("phcUom", context.Dict.%Get("inciBUom"))
    
    // 以上字典字段将在PHA.FACE.TPS.SA.DrugSync.Handlers.DictRewriteHandler中复写到DTO中
    
    quit sc
}

/// 测试方法
ClassMethod Test()
{
    write "测试 DrugDictSyncHandler...", !
    
    // 创建测试上下文
    set context = ##class(PHA.FACE.TPS.SA.DrugSync.SyncContext).%New()
    set dto = ##class(PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO).%New()
    set context.DTO = dto
    
    // 设置测试数据
    set dto.PHCCCode = "PC001"
    set dto.PHCCCat = "抗感染药物"
    set dto.HisPhisId = "GN001"
    set dto.HisPhis = "阿莫西林"
    set dto.HisChisId = "PGN001"
    set dto.HisChis = "阿莫西林胶囊"
    set dto.YPJXCode = "JN001"
    
    // 创建处理器并执行
    set handler = ##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.DrugDictSyncHandler).%New()
    set sc = handler.Handle(context)
    
    if $$$ISOK(sc) {
        write "字典同步测试通过!", !
        write "保存的字典ID:", !
        write "  药学分类ID: ", context.Dict.PHARMACYCATEGORYID, !
        write "  品种通用名ID: ", context.Dict.GENERICNAMEID, !
        write "  处方通用名ID: ", context.Dict.PRESCRIPTIONGENERICNAMEID, !
    } else {
        write "字典同步测试失败: ", $system.Status.GetErrorText(sc), !
    }
    
    quit sc
}

}
