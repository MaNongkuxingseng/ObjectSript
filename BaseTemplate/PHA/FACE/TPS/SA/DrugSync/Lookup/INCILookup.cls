/// INCI lookup - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Lookup.INCILookup Extends %RegisteredObject
{

ClassMethod FindByCode(code As %String) As %String
{
    if code="" quit ""
    quit $g(^INCI("CODE",code,"ID"))
}

}
