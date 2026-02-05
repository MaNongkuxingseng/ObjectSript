Class PHA.FACE.TPS.SA.INAdj.INAdjMappingSet Extends PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{

Method %OnNew() As %Status
{
    Do ##super()
    Do ..Build()
    Quit $$$OK
}

Method Build() As %Status
{
    // ========= Main =========
    Do ..AddConstRule("", "adjId", "Main")
    Do ..AddFieldRule("tzno", "tzno", "Main")
    Do ..AddDictRule("tzloc", "adjLocId", "Main", "HIS_LOC")
    Do ..AddDictRule("tzreason", "reasonId", "Main", "ADJ_REASON",{"defaultValue":5})
    Do ..AddDictRule("tzuser", "userId", "Main", "HIS_USER")
    Do ..AddFieldRule("", "remarks", "Main")
    Do ..AddFieldRule("tzDate", "tzDate", "Main")
    Do ..AddFieldRule("tzTime", "tzTime", "Main")
    
    // ========= Row =========
    Do ..AddDictRule("incno", "inci", "Row", "HIS_DRUG")
    Do ..AddDictRule("uom", "uomId", "Row", "HIS_UOM")
    Do ..AddFieldRule("qty", "qty", "Row")
    Do ..AddConstRule("", "resultQty", "Row")
    Do ..AddConstRule("", "adjItmId", "Row")
    Do ..AddFieldRule("Batid", "batNo", "Row")
    
    Quit $$$OK
}

}
