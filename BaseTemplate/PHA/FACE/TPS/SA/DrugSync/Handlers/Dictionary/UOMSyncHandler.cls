/// UOM sync handler - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.UOMSyncHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    set uname = $get(context.DTO.phcUom)
    set uid = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).CreateIfNotExists("UOM", uname)
    if +uid<1 quit "-1^uom insert failed"
    set context.Dict("UOMID") = uid
    quit $$$OK
}

}
