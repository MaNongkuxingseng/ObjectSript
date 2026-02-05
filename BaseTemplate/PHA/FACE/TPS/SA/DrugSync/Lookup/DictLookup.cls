/// Dictionary lookup helper - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup Extends %RegisteredObject
{

ClassMethod LookupPharmacyCategory(code As %String) As %String
{
	q:code="" ""
    &SQL(SELECT PHCC_RowId into :id FROM SQLUSER.DHC_PHCCat WHERE PHCC_Code=:code)
    q id
}

ClassMethod LookupPHChemical(code As %String) As %String
{
	q:code="" ""
    &SQL(SELECT PHCM_RowId into :id FROM SQLUSER.DHC_PHChemical WHERE PHCM_Code=:code)
    q id
}

ClassMethod LookupGenericName(code As %String) As %String
{
	q:code="" ""
    &SQL(SELECT PHCGE_RowId into :id FROM SQLUSER.PHC_Generic WHERE PHCGE_Code=:code)
    q id
}

ClassMethod LookupDosageForm(code As %String) As %String
{
	q:code="" ""
    &SQL(SELECT PHCF_RowId into :id FROM SQLUSER.PHC_Form WHERE PHCF_Code=:code)
    q id
}

ClassMethod LookupUom(uomDesc As %String) As %String
{
	q:uomDesc="" ""
	&sql(SELECT CTUOM_RowId into :id FROM SQLUSER.CT_UOM WHERE CTUOM_Desc=:uomDesc)
	q id
}

ClassMethod LookupCTConFac(fromUomId As %String, toUomId As %String) As %String
{
	s ctcfId = $o(^CT("CTCF",0,"UOM",fromUomId,toUomId,""))
	q ctcfId
}

/// 查询库存分类
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupINCStkCat("口服药")
ClassMethod LookupINCStkCat(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT INCSC_RowId into :id FROM SQLUSER.INC_StkCat WHERE INCSC_Code=:code)
	q id
}

/// 查询医嘱项账单子组
ClassMethod LookupARCBillSub(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT ARCSG_RowId into :id FROM SQLUSER.ARC_BillSub WHERE ARCSG_Desc=:code)
	q id
}

/// 查询库存项厂商ID
ClassMethod LookupPHManufacturer(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT PHMNF_RowId into :id FROM SQLUSER.PH_Manufacturer WHERE PHMNF_Code=:code)
	q id
}

/// 查询库存项ID
ClassMethod LookupINCItm(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT INCI_RowId into :id FROM SQLUSER.INC_Itm WHERE INCI_Code=:code)
	q id
}

/// 查询医嘱项ID
ClassMethod LookupARCItmMast(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT ARCIM_RowId into :id FROM SQLUSER.ARC_ItmMast WHERE ARCIM_Code=:code)
	q id
}

/// 查询医嘱子类ID
ClassMethod LookupARCItemCat(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT ARCIC_RowId into :id FROM SQLUSER.ARC_ItemCat WHERE ARCIC_Code=:code)
	q id
}

/// 查询收费子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTARSubCate("西药费")
ClassMethod LookupDHCTarSubCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TARSC_RowId into :id FROM SQLUSER.DHC_TarSubCate WHERE TARSC_Code=:code)
	q id
}

/// 查询住院收费子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTARInpatCate("西药费")
ClassMethod LookupTARInpatCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TARIC_RowId into :id FROM SQLUSER.DHC_TARInpatCate WHERE TARIC_Code=:code)
	q id
}

/// 查询门诊收费子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTAROutpatCate("西药费")
ClassMethod LookupTAROutpatCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TAROC_RowId into :id FROM SQLUSER.DHC_TAROutpatCate WHERE TAROC_Code=:code)
	q id
}

/// 查询核算子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTAREConCate("西药费")
ClassMethod LookupDHCTarEMCCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TAREC_RowId into :id FROM SQLUSER.DHC_TarEMCCate WHERE TAREC_Code=:code)
	q id
}

/// 查询会计子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTARAcctCate("西药费")
ClassMethod LookupDHCTARAcctCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TARAC_RowId into :id FROM SQLUSER.DHC_TARAcctCate WHERE TARAC_Code=:code)
	q id
}

/// 查询病案子类ID	DHC_TARMRSubCate
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupTARMRSubCate("西药费")
ClassMethod LookupDHCTarMCCate(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TARMC_RowId into :id FROM SQLUSER.DHC_TarMRCate WHERE TARMC_Code=:code)
	q id
}

/// 查询新病案首页子类ID
/// w ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.DictLookup).LookupDHCTarMCCateNew("西药费")
ClassMethod LookupDHCTarMCCateNew(code As %String) As %String
{
	q:code="" ""
	&sql(SELECT TARMCCNew_RowId into :id FROM SQLUSER.DHC_TarMCCateNew WHERE TARMCCNew_Code=:code)
	q id
}

}
