Class PHA.FACE.TPS.SA.DrugSync.SyncService Extends PHA.COM.Base
{

/// 同步药品信息（默认使用事务）
/// w ##class(PHA.FACE.TPS.SA.DrugSync.SyncService).SyncDrug({}).%ToJSON()
ClassMethod SyncDrug(jsonStr As %String = {{}}) As %Status
{
	// {"AdvsalePrice":"","CompId":"","FactoryId":"G00003","FactoryName":"西安利君精华药业有限责任公司","InitTime":"2025-12-02","InitUser":"demo","IsInsurance":"","LastModify":"demo","LastTime":"2025-12-02","MaxQty":100,"MidQty":1,"WareUnit":"盒(36)","MinQty":36,"MinUnit":"粒","Pile":36,"PurStatus":"","SaleStatus":"","SaleTax":"","Status":"1","WareAbc":"AMXL","WareCode":"H001234","WareName":"阿莫西林胶囊","WaregeneralName":"阿莫西林胶囊","WareKind":"1","WareSpec":"0.25g×36粒","WarningDays":180,"AreaCode":"A01","AreaName":"云南","BarCode":"6901234567890","ExtNo":"","FileNo":"国药准字2565","ListingHolder":"李四","MinBarcode":"","MinOutQty":"","Notes":"","PurTaxX":0.13,"PurTaxY":0.16,"ScanFlag":"","StoreReq":"","WareType":"","ChemElement":"","ChemName":"","DoubleCheck":"","Efficacy":"","Instructions":"","MainElement":"","MaintainType":"","PHCCCode":"2","PHCCCat":"各科用药","HisPhisId":"HX022511","HisPhis":"阿莫西林1111","HisChisId":"TY0225","HisChis":"阿莫西林胶囊","HisChisBM":"amxljn","YPJXCode":"胶囊剂","YPJXName":"胶囊剂","HisZDL":3,"Hisjxyl":4,"Hisdczdjl":1,"Hismrzdjl":2,"scSGCode":"口服药","scSGDesc":"口服药","scSCCode":"西药费","scSCDesc":"西药费","ARCIMEffDate":"2025-01-01","ARCIMEffDateTo":"2027-12-31","ORCATCode":"西药","ARCICCode":"西药胶囊剂","ARCSGCode":"西药费","TARSCCode":"西药费","TARICCode":"西药费","TAROCCode":"西药费","TARECCode":"西药费","TARACCode":"西药费","TARMCCode":"西药费","NTARMCCode":"西药费","INFOBasicDrug":"Y","INFOImportFlag":"国产","YPXQ":"R","UpdateFlag":"add"}
    ;s jsonStr = {"AdvsalePrice":"","CompId":"","FactoryId":"dhcc01","FactoryName":"dhcc测试","InitTime":"2025-12-03","InitUser":"demo","IsInsurance":"","LastModify":"demo","LastTime":"2025-12-03","MaxQty":100,"MidQty":1,"WareUnit":"盒(10)","MinQty":10,"MinUnit":"片","Pile":10,"PurStatus":"","SaleStatus":"","SaleTax":"","Status":"1","WareAbc":"AMXL","WareCode":"dhcc01","WareName":"测试药品00001","WaregeneralName":"测试药品","WareKind":"1","WareSpec":"0.25g×10片","WarningDays":180,"AreaCode":"A01","AreaName":"云南","BarCode":"6901234567890","ExtNo":"","FileNo":"国药准字2565","ListingHolder":"李四","MinBarcode":"","MinOutQty":"","Notes":"","PurTaxX":0.18,"PurTaxY":0.11,"ScanFlag":"","StoreReq":"","WareType":"","ChemElement":"","ChemName":"","DoubleCheck":"","Efficacy":"","Instructions":"","MainElement":"","MaintainType":"","PHCCCode":"2","PHCCCat":"各科用药","HisPhisId":"sacs001","HisPhis":"圣爱测试药品 ","HisChisId":"sacs001","HisChis":"圣爱测试药品","HisChisBM":"amxljn","YPJXCode":"胶囊剂","YPJXName":"胶囊剂","HisZDL":3,"Hisjxyl":4,"Hisdczdjl":1,"Hismrzdjl":2,"scSGCode":"CY001","scSGDesc":"中草药","scSCCode":"中草药","scSCDesc":"中草药","ARCIMEffDate":"2025-01-01","ARCIMEffDateTo":"2027-12-31","ORCATCode":"中草药","ARCICCode":"中药饮片","ARCSGCode":"西药费","TARSCCode":"西药费","TARICCode":"西药费","TAROCCode":"西药费","TARECCode":"西药费","TARACCode":"西药费","TARMCCode":"西药费","NTARMCCode":"西药费","INFOBasicDrug":"Y","INFOImportFlag":"国产","YPXQ":"R","UpdateFlag":"add"}
    //s jsonStr = {"AdvsalePrice":"0","CompId":"0","FactoryId":"0","FactoryName":"以批次为准","InitTime":"2025/12/18 16:01:30","InitUser":"","IsInsurance":"0","LastModify":"168","LastTime":"2025/12/18 16:01:30","MaxQty":"1","MidQty":"1","WareUnit":"g","MinQty":"1","MinUnit":"g","Pile":"0","PurStatus":"1","SaleStatus":"1","SaleTax":"0","Status":"1","WareAbc":"HK","WareCode":"1000017","WareName":"蛤壳","WaregeneralName":"蛤壳","WareKind":"1","WareSpec":"净制","WarningDays":"720","AreaCode":"00","AreaName":"","BarCode":"123","ExtNo":"1000017","FileNo":"《中国药典》2020年版一部","ListingHolder":"","MinBarcode":"","MinOutQty":"","Notes":"","PurTaxX":"0","PurTaxY":"0","ScanFlag":"","StoreReq":"01","WareType":"","ChemElement":"","ChemName":"","DoubleCheck":"","Efficacy":"","Instructions":"","MainElement":"","MaintainType":"","PHCCCode":"无","PHCCCat":"无","HisPhisId":"无","HisPhis":"无","HisChisId":"无","HisChis":"无","HisChisBM":"无","YPJXCode":"无","YPJXName":"无","HisZDL":"","Hisjxyl":"","Hisdczdjl":"","Hismrzdjl":"","scSGCode":"无","scSGDesc":"无","scSCCode":"无","scSCDesc":"无","ARCIMEffDate":"2026/1/8 11:15:07","ARCIMEffDateTo":"","ORCATCode":"无","ARCICCode":"无","ARCSGCode":"无","TARSCCode":"无","TARICCode":"无","TAROCCode":"无","TARECCode":"无","TARACCode":"无","TARMCCode":"无","NTARMCCode":"无","INFOBasicDrug":"无","INFOImportFlag":"无","YPXQ":"无","UpdateFlag":"add"}
    set dto = ##class(PHA.FACE.TPS.SA.DrugSync.Adapter.DrugAdapter).FromJSON(jsonStr)
    set ctx = ##class(PHA.FACE.TPS.SA.DrugSync.SyncContext).%New()
    set ctx.DTO = dto

    set pipeline = ##class(PHA.FACE.TPS.SA.DrugSync.Pipeline).%New()
    // 默认启用事务
    do pipeline.SetUseTransaction(1)
    
    // 构建处理器链
    // 1. 构建从dto到his药品数据映射
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.MappingHandler).%New())
#;    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.FactorySyncHandler).%New())
#;    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.UOMSyncHandler).%New())
	// 2. 从dto获取his字典数据
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.DrugDictSyncHandler).%New())
    // 3. 字典数据回写到dto
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.DictRewriteHandler).%New())
    // 4. 带字典数据的dto再次映射到his药品数据映射
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.MappingHandler).%New())
    // 5. his数据保存前的数据校验
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler).%New())
    // 6. 更新插入执行判断
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.UpsertHandler).%New())
    // 7. his保存数据最终执行
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.SaveHandler).%New())

    set sc = pipeline.Execute(ctx)
    if $$$ISERR(sc) {
	    // w ..GetExeRet(sc).%ToJSON()
        quit ..GetExeRet(sc,ctx.Dict).%ToJSON()
    }

    set arc = ctx.Dict.%Get("arci")
    set inci = ctx.Dict.%Get("inci")
    quit ..GetExeRet(sc,ctx.Dict).%ToJSON()
}

/// 同步药品信息（无事务模式，用于只读或测试）
ClassMethod SyncDrugWithoutTransaction(jsonStr As %String) As %Status
{
    set dto = ##class(PHA.FACE.TPS.SA.DrugSync.Adapter.DrugAdapter).FromJSON(jsonStr)
    set ctx = ##class(PHA.FACE.TPS.SA.DrugSync.SyncContext).%New()
    set ctx.DTO = dto

    set pipeline = ##class(PHA.FACE.TPS.SA.DrugSync.Pipeline).%New()
    do pipeline.SetUseTransaction(0)  // 禁用事务
    
    // 构建处理器链
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler).%New())
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.FactorySyncHandler).%New())
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.UOMSyncHandler).%New())
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.MappingHandler).%New())
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.UpsertHandler).%New())
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.SaveHandler).%New())

    set sc = pipeline.Execute(ctx)
    if $$$ISERR(sc) {
        quit ..GetExeRet(sc)
    }

    set arc = ctx.Dict.%Get("ARCIMID")
    set inci = ctx.Dict.%Get("INCIID")
    quit $$$OK
}

/// 仅验证数据（无事务，无保存操作）
/// w ##class(PHA.FACE.TPS.SA.DrugSync.SyncService).ValidateDrugData({}).%ToJSON()
ClassMethod ValidateDrugData(jsonStr As %String) As %DynamicObject
{
	s jsonStr = {"AdvsalePrice":"0","CompId":"0","FactoryId":"0","FactoryName":"以批次为准","InitTime":"2025/12/18 16:01:30","InitUser":"","IsInsurance":"0","LastModify":"168","LastTime":"2025/12/18 16:01:30","MaxQty":"1","MidQty":"1","WareUnit":"g","MinQty":"1","MinUnit":"g","Pile":"0","PurStatus":"1","SaleStatus":"1","SaleTax":"0","Status":"1","WareAbc":"HK","WareCode":"1000017","WareName":"蛤壳","WaregeneralName":"蛤壳","WareKind":"1","WareSpec":"净制","WarningDays":"720","AreaCode":"00","AreaName":"","BarCode":"123","ExtNo":"1000017","FileNo":"《中国药典》2020年版一部","ListingHolder":"","MinBarcode":"","MinOutQty":"","Notes":"","PurTaxX":"0","PurTaxY":"0","ScanFlag":"","StoreReq":"01","WareType":"","ChemElement":"","ChemName":"","DoubleCheck":"","Efficacy":"","Instructions":"","MainElement":"","MaintainType":"","PHCCCode":"无","PHCCCat":"无","HisPhisId":"无","HisPhis":"无","HisChisId":"无","HisChis":"无","HisChisBM":"无","YPJXCode":"无","YPJXName":"无","HisZDL":"","Hisjxyl":"","Hisdczdjl":"","Hismrzdjl":"","scSGCode":"无","scSGDesc":"无","scSCCode":"无","scSCDesc":"无","ARCIMEffDate":"2026/1/8 11:15:07","ARCIMEffDateTo":"","ORCATCode":"无","ARCICCode":"无","ARCSGCode":"无","TARSCCode":"无","TARICCode":"无","TAROCCode":"无","TARECCode":"无","TARACCode":"无","TARMCCode":"无","NTARMCCode":"无","INFOBasicDrug":"无","INFOImportFlag":"无","YPXQ":"无","UpdateFlag":"add"}
    set dto = ##class(PHA.FACE.TPS.SA.DrugSync.Adapter.DrugAdapter).FromJSON(jsonStr)
    set ctx = ##class(PHA.FACE.TPS.SA.DrugSync.SyncContext).%New()
    set ctx.DTO = dto

    set pipeline = ##class(PHA.FACE.TPS.SA.DrugSync.Pipeline).%New()
    do pipeline.SetUseTransaction(0)  // 禁用事务
    
    // 只添加验证处理器
    do pipeline.AddHandler(##class(PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler).%New())

    set sc = pipeline.Execute(ctx)
    
    set result = {
        "success": ($$$ISOK(sc)),
        "message": ($case($$$ISOK(sc), 1: "验证通过", : $system.Status.GetErrorText(sc))),
        "data": {
            "valid": ($$$ISOK(sc))
        }
    }
    
    quit result
}

/// 快速验证（仅验证，最快返回）
ClassMethod QuickValidate(jsonStr As %String) As %Status
{
    set dto = ##class(PHA.FACE.TPS.SA.DrugSync.Adapter.DrugAdapter).FromJSON(jsonStr)
    set ctx = ##class(PHA.FACE.TPS.SA.DrugSync.SyncContext).%New()
    set ctx.DTO = dto

    // 只执行验证Handler
    set handler = ##class(PHA.FACE.TPS.SA.DrugSync.Handlers.ValidationHandler).%New()
    quit handler.Handle(ctx)
}

/// 获取同步结果信息
ClassMethod GetSyncResult(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %DynamicObject
{
    set result = {
        "success": 1,
        "action": (context.Action),
        "arcimId": (context.Dict.ARCIMID),
        "inciId": (context.Dict.INCIID),
        "factoryId": (context.Dict.FACTORYID),
        "uomId": (context.Dict.UOMID)
    }
    
    quit result
}

ClassMethod GetExeRet(sc, data As %DynamicObject = {{}})
{
	set result = {
        "success": ($$$ISOK(sc)),
        "message": ($case($$$ISOK(sc), 1: "成功", : $system.Status.GetErrorText(sc))),
        "data": (data)
    }
    
    q result
}

}
