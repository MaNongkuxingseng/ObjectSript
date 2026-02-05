/// Dict repository (create-if-missing) - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository Extends (PHA.FACE.TPS.SA.DrugSync.Repository.DictResult, PHA.LIB.SYS)
{

/// Description: 药学分类-保存
ClassMethod SavePHCCat(PHCCatId, DataStr) As %Status
{
	set saveRet = ##class(PHA.IN.DHCPHCCat.Save).Save(PHCCatId, DataStr)
	
	q ..FromSaveRet(saveRet,saveRet)
}

/// Description: 品种通用名-保存
/// w ##class(PHA.IN.DHCPHChemical.Save).Save("","1^yun^yun")
ClassMethod SavePHCChem(ChemId, DataStr)
{
	set saveRet = ##class(PHA.IN.DHCPHChemical.Save).Save(ChemId, DataStr)
    
    q ..FromSaveRet(saveRet,saveRet)
}

/// Description: 药品剂型-保存
ClassMethod SavePHCForm(PHCFId, DataStr)
{
	//pClassName=web.DHCBL.CT.PHCForm&pClassMethod=SaveEntity&pEntityName=web.Entity.CT.PHCForm";
	if (PHCFId = "")
	{	
        s obj=##class(User.PHCForm).%New()
        s oldData=""
	}
	else
	{
		s obj=##class(User.PHCForm).%OpenId(PHCFId)
		s oldData=##class(PHA.COM.Json).TableToJson("PHC_Form",PHCFId)
	}
	s PHCFCode = $p(DataStr,"^",1)
	s PHCFDesc = $p(DataStr,"^",2)
	s obj.PHCFCode = PHCFCode
	s obj.PHCFDesc = PHCFDesc
	s sc=obj.%Save()
	// 表结果处理,错误日志+平台日志
	s comSC=##class(PHA.COM.Status).%New()
	s comSC.TblObj=obj
	s comSC.TblDesc="药房药库-品种通用名"
	s comSC.TblInfo=PHCFDesc
	s comSC.StatusCode=sc
	s comSC.OldData=oldData
	d comSC.%ComHandler()
	if comSC.IsOK=1 {
		s saveRet = comSC.Id
	}else {
		s saveRet = "-5^"_comSC.Err
	}	
    
    
	q ..FromSaveRet(saveRet,PHCFId)
}

/// Description: 处方通用名-保存
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SavePHCGene("","1^yun^yun")
ClassMethod SavePHCGene(GeneId, DataStr)
{
	s $zt="ErrorSave"	
	s chkRet=##class(PHA.IN.PHCGeneric.Save).CheckSave(GeneId, DataStr)
	q:$p(chkRet,"^",1)<0 ..FromSaveRet(chkRet,GeneId)
	s saveRet=##class(PHA.IN.PHCGeneric.Save).SavePHCGeneric(GeneId, DataStr)
	q:+$p(saveRet,"^",1)<0 ..FromSaveRet(saveRet,GeneId)
	s geneId=saveRet,GeneId=geneId
	s saveRet=##class(PHA.IN.PHCGeneric.Save).SaveDHCPhcGeneric(geneId, DataStr)
	q:+$p(saveRet,"^",1)<0 ..FromSaveRet(saveRet,GeneId)
	s saveRet=##class(PHA.IN.Drug.Save).OverridePhcdFromGene(geneId)
	q:+$p(saveRet,"^",1)<0 ..FromSaveRet(saveRet,GeneId)
	
	q ..FromSaveRet(saveRet,GeneId)
ErrorSave
	s $zt = ""
	// 捕获异常	
	s errObj=##class(PHA.COM.Err).%New()
	d errObj.%Error()
	q ..FromSaveRet("-5^"_errObj.Msg,GeneId)
}

/// Description: 单位-保存
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveCTUom("1","袋(6)^袋(6)")
ClassMethod SaveCTUom(uomId, DataStr)
{
	s CTUOMCode = $p(DataStr,"^",1)
	s CTUOMDesc = $p(DataStr,"^",2)
	s flag= ##class(web.DHCBL.CT.CTUOM).FormValidate(uomId,CTUOMCode,CTUOMDesc)
	if flag=1 q ..Error(CTUOMDesc_"该记录已经存在！",uomId) //"{success:'false',errorinfo:'该记录已经存在！'}"
	
	if (uomId="")       
	{
		s obj=##class(User.CTUOM).%New()
		s oldData=""
	}
	else                           
	{
		s obj=##class(User.CTUOM).%OpenId(uomId)
		s oldData=##class(PHA.COM.Json).TableToJson("CT_Uom",uomId)
	}

	s obj.CTUOMCode = CTUOMCode
	s obj.CTUOMDesc = CTUOMDesc
	s obj.CTUOMForeignDesc = CTUOMDesc
	
	s sc=obj.%Save()
	// 表结果处理,错误日志+平台日志
	s comSC=##class(PHA.COM.Status).%New()
	s comSC.TblObj=obj
	s comSC.TblDesc="药房药库-单位"
	s comSC.TblInfo=CTUOMDesc
	s comSC.StatusCode=sc
	s comSC.OldData=oldData
	d comSC.%ComHandler()
	if comSC.IsOK=1 {
		s saveRet = comSC.Id
	}else {
		s saveRet = "-5^"_comSC.Err
	}	
    
    
	q ..FromSaveRet(saveRet,comSC.Id)
}

/// Description: 单位转换系数-保存
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).SaveCTUom("1","袋(6)^袋(6)")
ClassMethod SaveCTConFac(ctcfId, DataStr)
{
	s fromUomId = $p(DataStr,"^",1)
	s toUomId = $p(DataStr,"^",2)
	s ctcfFactor = $p(DataStr,"^",3)
	
	s CTCFActiveFlag="Y"
	s validateflag=##class(web.DHCBL.CT.CTConFac).FormValidate(ctcfId,fromUomId,toUomId)
	if (validateflag=1) q ..Error(DataStr_"该单位转换记录已经存在！",uomId) //"{success:'false',errorinfo:'该记录已经存在！'}"
	
	if (ctcfId="")
	{	
		s obj=##class(User.CTConFac).%New()
		s oldData=""
	}
	else
	{
		s obj=##class(User.CTConFac).%OpenId(ctcfId)
		s oldData=##class(PHA.COM.Json).TableToJson("CT_Uom",uomId)
	}
	s obj.CTCFActiveFlag = CTCFActiveFlag                     
	s obj.CTCFFactor = ctcfFactor    
	d obj.CTCFFrUOMDRSetObjectId(fromUomId)               	 
	d obj.CTCFToUOMDRSetObjectId(toUomId) 

	s CTUOMDesc=$p($g(^CT("UOM",fromUomId)),"^",2) //码表日志里描述取"从单位"的Desc
	
	s sc=obj.%Save()
	// 表结果处理,错误日志+平台日志
	s comSC=##class(PHA.COM.Status).%New()
	s comSC.TblObj=obj
	s comSC.TblDesc="药房药库-单位转换系数"
	s comSC.TblInfo=CTUOMDesc
	s comSC.StatusCode=sc
	s comSC.OldData=oldData
	d comSC.%ComHandler()
	if comSC.IsOK=1 {
		s saveRet = comSC.Id
	}else {
		s saveRet = "-5^"_comSC.Err
	}	
    
    
	q ..FromSaveRet(saveRet,comSC.Id)
}

/// Description: 生产企业-保存
/// w ##class(PHA.IN.DHCPHChemical.Save).Save("","1^yun^yun")
ClassMethod SavePHManufacturer(PhManfId, DataStr)
{
    
	s pJson = {
		"HospId":($p(DataStr,"^",1)),
		"ManfCodei":($p(DataStr,"^",2)),
		"ManfNamei":($p(DataStr,"^",3))
	}
	s $ZT="ErrSave"
	s HospId  = pJson.HospId
	s ManfCode	= pJson.ManfCodei
	s ManfName	= pJson.ManfNamei
	s phManfTB = "PH_Manufacturer"
	s result = ##class(PHA.IN.COM.DataCheck).CheckRepeat(phManfTB, ManfCode, ManfName, HospId, PhManfId)
	q:(result '= "") ..Error(DataStr_"该记录已经存在！",PhManfId)
#;	s CodeExist	= ..CheckCodeRepeat(PhManfId,ManfCode,HospId)
#;	q:CodeExist="Y" ..Msg(-1,"代码重复！(过滤特殊符号后)")
#;	s ManfName	= pJson.ManfNamei
#;	s DescExist	= ..CheckNameRepeat(PhManfId,ManfName,HospId)
#;	q:DescExist="Y" ..Msg(-1,"名称重复！(过滤特殊符号后)")
	s Tel		= pJson.Tel
	s Address	= pJson.Address
	s ParManf	= pJson.ParManf
	s Status	= "Y"			// pJson.Status
	q:(PhManfId'="")&&(PhManfId=ParManf) ..Error("上级生产企业不能和生产企业重复！",PhManfId)
	
	s Type = ..#StkType
	/// 保存生产企业主表
	i PhManfId="" d
	.s Obj = ##class(User.PHManufacturer).%New()
	.s oldData=""
	e  d
	.s Obj = ##class(User.PHManufacturer).%OpenId(PhManfId)
	.d Obj.%Reload()
	.s oldData=##class(PHA.COM.Json).TableToJson("PH_Manufacturer",PhManfId)
	s Obj.PHMNFCode=ManfCode
	s Obj.PHMNFName=ManfName
	s Obj.PHMNFTel=Tel
	d Obj.PHMNFAddress.Clear()
 	d Obj.PHMNFAddress.InsertList($lfs(Address,$c(3)))	//地址
	s sc=Obj.%Save()
	if $$$ISOK(sc)
	{   
		if (PhManfId=""){
	        s PhManfId=Obj.%Id()
	        s retinfo=##class(PHA.FACE.IN.Com).SaveBasicDataHosp("PH_Manufacturer",PhManfId,HospId)
	        i +retinfo<0  q ..Error("生产企业授权失败！",PhManfId)
		}
    }
    else{
	    q ..Error("保存生产企业失败！",PhManfId)
    }	
	// 表结果处理,错误日志+平台日志
	s comSC	=##class(PHA.COM.Status).%New()
	s comSC.TblObj		= Obj
	s comSC.TblDesc		= "药房药库-生产企业维护"
	s comSC.TblInfo		= ManfName
	s comSC.StatusCode	= sc
	s comSC.OldData		= oldData
	d comSC.%ComHandler()
	i comSC.IsOK'=1  q ..Error(comSC.Err)
	
	//保存生产企业附加表信息
	s DHCPhManfId =$O(^DHCMANF(0,"MANF",PhManfId,""))
	i DHCPhManfId="" d
	.s Obji = ##class(User.DHCManfAddionInfo).%New()
	.d Obji.MANFPhcManfDRSetObjectId(PhManfId)
	.s oldData=""
	e  d
	.s Obji = ##class(User.DHCManfAddionInfo).%OpenId(DHCPhManfId)
	.d Obji.%Reload()
	.s oldData=##class(PHA.COM.Json).TableToJson("DHC_Manf_AddionInfo",DHCPhManfId)
	s Obji.MANFType=Type
	s Obji.MANFActive=Status
	d Obji.MANFParManfDRSetObjectId(ParManf)

	s sc=Obji.%Save()
	if $$$ISERR(sc)
	{   
	    q ..Error("保存附加表生产企业失败！",PhManfId)
    }	
	// 表结果处理,错误日志+平台日志
	s comSCi	=##class(PHA.COM.Status).%New()
	s comSCi.TblObj			= Obji
	s comSCi.TblDesc		= "药房药库-生产企业附加表维护"
	s comSCi.TblInfo		= ManfName
	s comSCi.StatusCode		= sc
	s comSCi.OldData		= oldData
	d comSCi.%ComHandler()
	if comSC.IsOK=1 {
		s saveRet = comSC.Id
	}else {
		s saveRet = "-5^"_comSC.Err
	}
	
	q ..FromSaveRet(saveRet,PhManfId)
	
ErrSave
	s $zt= ""
	s errObj=##class(PHA.COM.Err).%New()
	d errObj.%Error()
	q ..Error(errObj.Msg)
}

/// Description: 库存分类-保存
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository.SaveCTConFac("1","袋(6)^袋(6)")
ClassMethod SaveINCStkCat(incscId, DataStr)
{
	s incsCode = $p(DataStr,"^",1)
	s incsDesc = $p(DataStr,"^",2)
	s incsType = "G"
		
	if (incscId="")
	{	
		s obj=##class(User.INCStkCat).%New()
		s oldData=""
	}
	else
	{
		s obj=##class(User.INCStkCat).%OpenId(incscId)
		s oldData=##class(PHA.COM.Json).TableToJson("INC_StkCat",incscId)
	}
	s obj.INCSCCode = incsCode                     
	s obj.INCSCDesc= incsDesc    
	s obj.INCSCStkType = incsType              	 

	
	s sc=obj.%Save()
	// 表结果处理,错误日志+平台日志
	s comSC=##class(PHA.COM.Status).%New()
	s comSC.TblObj=obj
	s comSC.TblDesc="药房药库-库存分类"
	s comSC.TblInfo=incsDesc
	s comSC.StatusCode=sc
	s comSC.OldData=oldData
	d comSC.%ComHandler()
	if comSC.IsOK=1 {
		s saveRet = comSC.Id
	}else {
		s saveRet = "-5^"_comSC.Err
	}	
    
    
	q ..FromSaveRet(saveRet,comSC.Id)
}

}
