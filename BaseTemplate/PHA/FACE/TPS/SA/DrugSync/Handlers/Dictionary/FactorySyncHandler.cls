/// Factory sync handler (create-if-missing) - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Handlers.Dictionary.FactorySyncHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    set fname = $get(context.DTO.FactoryName)
    set fid = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictRepository).CreateIfNotExists("FACTORY", $get(context.DTO.FactorydI))
    if +fid<1 quit "-1^factory insert failed"
    set context.Dict("FACTORYID") = fid
    quit $$$OK
}

}
