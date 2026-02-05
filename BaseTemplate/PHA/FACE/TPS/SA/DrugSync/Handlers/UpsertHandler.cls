/// Decide add/update (ARCIM + INCI) - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Handlers.UpsertHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    // This handler runs inside transaction scope
    b ;UpsertHandler
#;    set arcId = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.ARCIMLookup).FindByCode(context.DTO.arcimCode)
#;    set inciId = ##class(PHA.FACE.TPS.SA.DrugSync.Lookup.INCILookup).FindByCode(context.DTO.inciCode)
    set arcId = context.DTO.arci
    set inciId = context.DTO.inci

    if (arcId'="")||(inciId'="") {
        set context.Action = "UPDATE"
    } else {
        set context.Action = "ADD"
    }
    quit $$$OK
}

}
