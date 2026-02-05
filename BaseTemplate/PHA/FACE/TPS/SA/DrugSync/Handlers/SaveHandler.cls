/// Save handler - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Handlers.SaveHandler Extends PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler
{

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status
{
    // This handler runs inside transaction scope and must return a status
    set action = context.Action
    set arcJson = context.ArcJson
    set inciJson = context.InciJson
    set logon = context.Logon		// 登录信息固定

    if action="ADD" {
        set arcRet = ##class(PHA.IN.ARCItmMast.Save).SaveArcPhc("", arcJson.%ToJSON(), logon)
        if +$piece(arcRet,"^",1)<0 quit $$$ERROR($$$GeneralError, "ARCIM save failed: "_arcRet)
        set arcId = arcRet
        set inciJson.inciArcim = arcId		// 保存时需要关联更新库存项对应的医嘱项
        set inciRet = ##class(PHA.IN.INCItm.Save).SaveInciTar("", inciJson.%ToJSON(), logon)
        if +$piece(inciRet,"^",1)<0 quit $$$ERROR($$$GeneralError, "INCI save failed: "_inciRet)
        set inciId = inciRet
    } else  {
        set arcRet = ##class(PHA.IN.ARCItmMast.Save).SaveArcPhc(context.DTO.arci, arcJson.%ToJSON(), logon)
        if +$piece(arcRet,"^",1)<0 quit $$$ERROR($$$GeneralError, "ARCIM update failed: "_arcRet)
        set arcId = arcRet
        set inciJson.inciArcim = arcId		// 保存时需要关联更新库存项对应的医嘱项
        set inciRet = ##class(PHA.IN.INCItm.Save).SaveInciTar(context.DTO.inci, inciJson.%ToJSON(), logon)
        if +$piece(inciRet,"^",1)<0 quit $$$ERROR($$$GeneralError, "INCI update failed: "_inciRet)
        set inciId = inciRet
    }

    do context.Dict.%Set("ARCIMID",arcId)
    do context.Dict.%Set("INCIID",inciId)
    quit $$$OK
}

}
