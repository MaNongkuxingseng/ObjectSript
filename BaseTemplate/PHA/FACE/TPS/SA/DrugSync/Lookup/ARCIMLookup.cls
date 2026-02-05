/// ARCIM lookup - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Lookup.ARCIMLookup Extends %RegisteredObject
{

ClassMethod FindByCode(code As %String) As %String
{
    if code="" quit ""
    quit $g(^ARCIM(0,"Code",$$ALPHAUP^SSUTIL4(code)))
}

}
