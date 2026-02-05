Class PHA.FACE.TPS.SA.DrugSync.Handlers.MappingHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

/// 从DTO映射到ARCIM/INCI JSON - valen MPF
Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    set dto = context.DTO
    
    // 映射ARCIM字段
    set context.ArcJson = ..MapToArcJson(dto)
    
    // 映射INCI字段
    set context.InciJson = ..MapToInciJson(dto)
    
    quit $$$OK
}

/// 映射DTO到ARCIM JSON
Method MapToArcJson(dto As PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO) As %DynamicObject
{
    set arc = {}.%New()
    
    // 基础ARCIM字段映射 保持与药品信息维护字典一致，需要从SA新增的请放到最后
    do arc.%Set("phcGene", ..GetStringValue(dto.phcGene))
    do arc.%Set("arcimCode", ..GetStringValue(dto.arcimCode))
    do arc.%Set("arcimDesc", ..GetStringValue(dto.arcimDesc))
    do arc.%Set("arcimOrdCat", ..GetStringValue(dto.arcimOrdCat))
    do arc.%Set("arcimItemCat", ..GetStringValue(dto.arcimItemCat))
    do arc.%Set("arcimBillGrp", ..GetStringValue(dto.arcimBillGrp))
    do arc.%Set("arcimBillSub", ..GetStringValue(dto.arcimBillSub))
    do arc.%Set("arcimPri", ..GetStringValue(dto.arcimPri))
    do arc.%Set("arcimNoOfCumDays", ..GetStringValue(dto.arcimNoOfCumDays))
    do arc.%Set("arcimMaxQty", ..GetStringValue(dto.arcimMaxQty))
    do arc.%Set("arcimWarnQty", ..GetStringValue(dto.arcimWarnQty))
    do arc.%Set("arcimMaxCumDose", ..GetStringValue(dto.arcimMaxCumDose))
    do arc.%Set("arcimMaxQtyDay", ..GetStringValue(dto.arcimMaxQtyDay))
    do arc.%Set("arcimPartialValue", ..GetStringValue(dto.arcimPartialValue))
    do arc.%Set("arcimOPPartialValue", ..GetStringValue(dto.arcimOPPartialValue))
    do arc.%Set("arcimStDate", ..GetStringValue(dto.arcimStDate))
    do arc.%Set("arcimEdDate", ..GetStringValue(dto.arcimEdDate))
    do arc.%Set("arcimOEMsg", ..GetStringValue(dto.arcimOEMsg))
    do arc.%Set("arcimOwn", ..GetBooleanValue(dto.arcimOwn))
    do arc.%Set("arcimWoStock", ..GetBooleanValue(dto.arcimWoStock))
    do arc.%Set("arcimFree", ..GetBooleanValue(dto.arcimFree))
    do arc.%Set("arcimOP", ..GetBooleanValue(dto.arcimOP))
    do arc.%Set("arcimEM", ..GetBooleanValue(dto.arcimEM))
    do arc.%Set("arcimIP", ..GetBooleanValue(dto.arcimIP))
    do arc.%Set("arcimHP", ..GetBooleanValue(dto.arcimHP))
    do arc.%Set("phcIPOneDay", ..GetBooleanValue(dto.phcIPOneDay))
    do arc.%Set("arcimCMAllowDecimal", ..GetBooleanValue(dto.arcimCMAllowDecimal))
    
    // PHC相关字段
    do arc.%Set("phcUom", ..GetStringValue(dto.phcUom))
    do arc.%Set("phcSpec", ..GetStringValue(dto.phcSpec))
    do arc.%Set("phcPoison", ..GetStringValue(dto.phcPoison))
    do arc.%Set("phcFreq", ..GetStringValue(dto.phcFreq))
    do arc.%Set("phcInstuc", ..GetStringValue(dto.phcInstuc))
    do arc.%Set("phcDura", ..GetStringValue(dto.phcDura))
    do arc.%Set("phcHighRisk", ..GetStringValue(dto.phcHighRisk))
    do arc.%Set("phcOTC", ..GetStringValue(dto.phcOTC))
    do arc.%Set("phcLabel21", ..GetStringValue(dto.phcLabel21))
    do arc.%Set("phcLabel22", ..GetStringValue(dto.phcLabel22))
    do arc.%Set("phcLabel1", ..GetStringValue(dto.phcLabel1))
    do arc.%Set("phcSpeed", ..GetStringValue(dto.phcSpeed))
    do arc.%Set("phcWHODDD", ..GetStringValue(dto.phcWHODDD))
    do arc.%Set("phcWHODDDUom", ..GetStringValue(dto.phcWHODDDUom))
    do arc.%Set("phcDDD", ..GetStringValue(dto.phcDDD))
    do arc.%Set("phcWHONET", ..GetStringValue(dto.phcWHONET))
    do arc.%Set("phcAntiLevel", ..GetStringValue(dto.phcAntiLevel))
    do arc.%Set("phcCHSpec", ..GetStringValue(dto.phcCHSpec))
    do arc.%Set("phcGranulesFac", ..GetStringValue(dto.phcGranulesFac))
    
    // 药品基础信息标志
    do arc.%Set("phcBaseDrug", ..GetBooleanValue(dto.phcBaseDrug))
    do arc.%Set("phcBaseDrugPro", ..GetBooleanValue(dto.phcBaseDrugPro))
    do arc.%Set("phcBaseDrugCity", ..GetBooleanValue(dto.phcBaseDrugCity))
    do arc.%Set("phcBaseDrugCou", ..GetBooleanValue(dto.phcBaseDrugCou))
    do arc.%Set("phcOPOneDay", ..GetBooleanValue(dto.phcOPOneDay))
    do arc.%Set("phcOPSkin", ..GetBooleanValue(dto.phcOPSkin))
    do arc.%Set("phcIPSkin", ..GetBooleanValue(dto.phcIPSkin))
    do arc.%Set("phcCodeX", ..GetBooleanValue(dto.phcCodeX))
    do arc.%Set("phcProComm", ..GetBooleanValue(dto.phcProComm))
    do arc.%Set("phcTest", ..GetBooleanValue(dto.phcTest))
    do arc.%Set("phcTPN", ..GetBooleanValue(dto.phcTPN))
    do arc.%Set("phcAnti", ..GetBooleanValue(dto.phcAnti))
    do arc.%Set("phcCritical", ..GetBooleanValue(dto.phcCritical))
    do arc.%Set("phcMonitor", ..GetBooleanValue(dto.phcMonitor))
    do arc.%Set("phcSingle", ..GetBooleanValue(dto.phcSingle))
    do arc.%Set("phcChemotherapeutic", ..GetBooleanValue(dto.phcChemotherapeutic))
    do arc.%Set("phcDietTaboo", ..GetBooleanValue(dto.phcDietTaboo))
    do arc.%Set("phcTumble", ..GetBooleanValue(dto.phcTumble))
    do arc.%Set("phcDope", ..GetBooleanValue(dto.phcDope))
    do arc.%Set("phcAllergy", ..GetBooleanValue(dto.phcAllergy))
    do arc.%Set("phcCQZT", ..GetBooleanValue(dto.phcCQZT))
    do arc.%Set("phcONE", ..GetBooleanValue(dto.phcONE))
    do arc.%Set("phcOM", ..GetBooleanValue(dto.phcOM))
    do arc.%Set("phcFirstAid", ..GetBooleanValue(dto.phcFirstAid))
    do arc.%Set("phcNoAllergy", ..GetBooleanValue(dto.phcNoAllergy))
    
    // 从SA字段映射到ARCIM的额外字段
    do arc.%Set("arcimCode", ..GetStringValue(dto.WareCode))
    do arc.%Set("arcimDesc", ..GetStringValue(dto.WareName))
    do arc.%Set("wareSpec", ..GetStringValue(dto.WareSpec))
    do arc.%Set("factoryName", ..GetStringValue(dto.FactoryName))
    do arc.%Set("barCode", ..GetStringValue(dto.BarCode))
    do arc.%Set("wareGeneralName", ..GetStringValue(dto.WaregeneralName))
    do arc.%Set("wareUnit", ..GetStringValue(dto.WareUnit))
    do arc.%Set("status", ..GetStringValue(dto.Status))
    
    do arc.%Set("arcimMaxQty", ..GetStringValue(dto.HisZDL))   //  最大量
    do arc.%Set("arcimWarnQty", ..GetStringValue(dto.Hisjxyl))  //极限用量
    do arc.%Set("arcimMaxCumDose", ..GetStringValue(dto.Hisdczdjl))   //单次最大剂量
    do arc.%Set("arcimMaxQtyDay", ..GetStringValue(dto.Hismrzdjl))   //每日最大剂量
    do arc.%Set("arcimStDate", ..GetStringValue(dto.InitTime))   //生效日期
    do arc.%Set("arcimOwn", ..GetBooleanValue(dto.Status))   //独立医嘱

    
    quit arc
}

/// 映射DTO到INCI JSON
Method MapToInciJson(dto As PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO) As %DynamicObject
{
    set inci = {}.%New()
    
    // 基础INCI字段映射 保持与药品信息维护字典一致，需要从SA新增得请放到最后
    //do inci.%Set("inciArcim", ..GetStringValue(dto.inciArcim))
    do inci.%Set("inciCode", ..GetStringValue(dto.inciCode))
    do inci.%Set("inciDesc", ..GetStringValue(dto.inciDesc))
    do inci.%Set("inciBUom", ..GetStringValue(dto.inciBUom))
    do inci.%Set("inciPUom", ..GetStringValue(dto.inciPUom))
    do inci.%Set("inciPUom4TCode", ..GetStringValue(dto.inciPUom4TCode))
    do inci.%Set("inciOutUom", ..GetStringValue(dto.inciOutUom))
    do inci.%Set("inciInUom", ..GetStringValue(dto.inciInUom))
    do inci.%Set("inciStkCat", ..GetStringValue(dto.inciStkCat))
    do inci.%Set("inciBookCat", ..GetStringValue(dto.inciBookCat))
    do inci.%Set("inciExpReq", ..GetStringValue(dto.YPXQ))
    do inci.%Set("inciExpLen", ..GetStringValue(dto.inciExpLen))
    do inci.%Set("inciManf", ..GetStringValue(dto.inciManf))
    do inci.%Set("inciSpec", ..GetStringValue(dto.inciSpec))
    do inci.%Set("inciOrigin", ..GetStringValue(dto.inciOrigin))
    do inci.%Set("inciMarkType", ..GetStringValue(dto.inciMarkType))
    do inci.%Set("inciRp", ..GetStringValue(dto.inciRp))
    do inci.%Set("inciSp", ..GetStringValue(dto.inciSp))
    do inci.%Set("inciMaxSp", ..GetStringValue(dto.inciMaxSp))
    do inci.%Set("inciPriceDate", ..GetStringValue(dto.inciPriceDate))
    do inci.%Set("inciPrcFile", ..GetStringValue(dto.inciPrcFile))
    do inci.%Set("inciPrcFileDate", ..GetStringValue(dto.inciPrcFileDate))
    do inci.%Set("inciBarCode", ..GetStringValue(dto.inciBarCode))
    do inci.%Set("inciStandardCode", ..GetStringValue(dto.inciStandardCode))
    do inci.%Set("inciImport", ..GetStringValue(dto.inciImport))
    do inci.%Set("inciComeFrom", ..GetStringValue(dto.inciComeFrom))
    do inci.%Set("inciQualityNo", ..GetStringValue(dto.inciQualityNo))
    do inci.%Set("inciQualityLev", ..GetStringValue(dto.inciQualityLev))
    do inci.%Set("inciInMedBasis", ..GetStringValue(dto.inciInMedBasis))
    do inci.%Set("inciDrugUse", ..GetStringValue(dto.inciDrugUse))
    do inci.%Set("inciPackUom", ..GetStringValue(dto.inciPackUom))
    do inci.%Set("inciPackUomFac", ..GetStringValue(dto.inciPackUomFac))
    do inci.%Set("inciReportingDays", ..GetStringValue(dto.inciReportingDays))
    do inci.%Set("inciRRReason", ..GetStringValue(dto.inciRRReason))
    do inci.%Set("inciPurPlanCode", ..GetStringValue(dto.inciPurPlanCode))
    do inci.%Set("dmDrugIdByself", ..GetStringValue(dto.dmDrugIdByself))
    do inci.%Set("inciRemark1", ..GetStringValue(dto.inciRemark1))
    do inci.%Set("inciRemark2", ..GetStringValue(dto.inciRemark2))
    
    // 布尔字段映射
    do inci.%Set("inciBAFlag", ..GetBooleanValue(dto.inciBAFlag))
    do inci.%Set("inciCentralPur", ..GetBooleanValue(dto.inciCentralPur))
    do inci.%Set("inciNegoFlag", ..GetBooleanValue(dto.inciNegoFlag))
    do inci.%Set("inciInHosp", ..GetBooleanValue(dto.inciInHosp))
    do inci.%Set("inciRecFlag", ..GetBooleanValue(dto.inciRecFlag))
    do inci.%Set("inciSHCentPurFlag", ..GetBooleanValue(dto.inciSHCentPurFlag))
    do inci.%Set("inciSkinTest", ..GetBooleanValue(dto.inciSkinTest))
    do inci.%Set("inciEasyConfuse", ..GetBooleanValue(dto.inciEasyConfuse))
    do inci.%Set("inciEdible", ..GetBooleanValue(dto.inciEdible))
    do inci.%Set("inciTemPurchase", ..GetBooleanValue(dto.inciTemPurchase))
    do inci.%Set("inciHighPrice", ..GetBooleanValue(dto.inciHighPrice))
    do inci.%Set("inciWholeDispFlag", ..GetBooleanValue(dto.inciWholeDispFlag))
    do inci.%Set("incPropNoTraceCode", ..GetBooleanValue(dto.incPropNoTraceCode))
    do inci.%Set("inciNotUse", ..GetBooleanValue(dto.inciNotUse))
    
    do inci.%Set("inciOrdEdDate", ..GetStringValue(dto.inciOrdEdDate))
    do inci.%Set("inciNotUseRea", ..GetStringValue(dto.inciNotUseRea))
    
    // TAR相关字段
    do inci.%Set("tarCode", ..GetStringValue(dto.tarCode))
    do inci.%Set("tarDesc", ..GetStringValue(dto.tarDesc))
    do inci.%Set("tarMCCateNew", ..GetStringValue(dto.tarMCCateNew))
    do inci.%Set("tarMCCate", ..GetStringValue(dto.tarMCCate))
    do inci.%Set("tarOutpatCate", ..GetStringValue(dto.tarOutpatCate))
    do inci.%Set("tarInpatCate", ..GetStringValue(dto.tarInpatCate))
    do inci.%Set("tarEMCCate", ..GetStringValue(dto.tarEMCCate))
    do inci.%Set("tarAcctCate", ..GetStringValue(dto.tarAcctCate))
    do inci.%Set("tarSubCate", ..GetStringValue(dto.tarSubCate))
    do inci.%Set("tarInsuCode", ..GetStringValue(dto.tarInsuCode))
    do inci.%Set("tarInsuDesc", ..GetStringValue(dto.tarInsuDesc))
    
    // PB相关字段
    do inci.%Set("inciPbFlag", ..GetBooleanValue(dto.inciPbFlag))
    do inci.%Set("inciPbVendor", ..GetStringValue(dto.inciPbVendor))
    do inci.%Set("inciPbLevel", ..GetStringValue(dto.inciPbLevel))
    do inci.%Set("inciPbManf", ..GetStringValue(dto.inciPbManf))
    do inci.%Set("inciPbList", ..GetStringValue(dto.inciPbList))
    do inci.%Set("inciPbCarrier", ..GetStringValue(dto.inciPbCarrier))
    do inci.%Set("inciPbRp", ..GetStringValue(dto.inciPbRp))
    
    // 从SA字段映射到INCI的额外字段
    do inci.%Set("inciCode", ..GetStringValue(dto.WareCode))
    do inci.%Set("inciDesc", ..GetStringValue(dto.WareName))
    do inci.%Set("factoryId", ..GetStringValue(dto.FactoryId))
    do inci.%Set("factoryName", ..GetStringValue(dto.FactoryName))
    do inci.%Set("barCode", ..GetStringValue(dto.BarCode))
    do inci.%Set("fileNo", ..GetStringValue(dto.FileNo))
    do inci.%Set("inciSpec", ..GetStringValue(dto.WareSpec))
    do inci.%Set("wareUnit", ..GetStringValue(dto.WareUnit))
    do inci.%Set("minUnit", ..GetStringValue(dto.MinUnit))
    do inci.%Set("status", ..GetStringValue(dto.Status))
    
    do inci.%Set("tarGeneralTaxRate", ..GetStringValue(dto.PurTaxY))  // 一般纳税人税率
    do inci.%Set("tarSmallTaxRate", ..GetStringValue(dto.PurTaxX))   // 小规模纳税人税率
    
    quit inci
}

/// 安全获取字符串值
Method GetStringValue(value As %String) As %String
{
    quit $get(value)
}

/// 安全获取布尔值
Method GetBooleanValue(value As %String) As %Boolean
{
    if value = "1" || ($$$LOWER(value) = "true") || ($$$LOWER(value) = "是") {
        quit 1
    }
    quit 0
}

}
