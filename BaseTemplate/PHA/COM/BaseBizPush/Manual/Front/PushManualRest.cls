/// 人工重推前端 REST 接口
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.Front.PushManualRest Extends %CSP.REST
{

XData UrlMap
{
<Routes>
    <Route Url="/query" Method="POST" Call="QueryTargets"/>
    <Route Url="/execute" Method="POST" Call="ExecutePush"/>
</Routes>
}

ClassMethod QueryTargets() As %Status
{
    set body = {}
    do %request.Content.Rewind()
    set json = %request.Content.Read()
    if json '= "" {
        set body = ##class(%DynamicObject).%FromJSON(json)
    }

    set entryCode = $select(body.%IsDefined("entryCode"):body.%Get("entryCode"),1:"")
    set hospId = $select(body.%IsDefined("hospId"):body.%Get("hospId"),1:"")
    set deptCode = $select(body.%IsDefined("deptCode"):body.%Get("deptCode"),1:"")

    set result = ##class(PHA.COM.BaseBizPush.Manual.Facade.PushManualFacade).QueryTargets(entryCode, hospId, deptCode)
    do ..WriteJSON(result)
    quit $$$OK
}

ClassMethod ExecutePush() As %Status
{
    set body = {}
    do %request.Content.Rewind()
    set json = %request.Content.Read()
    if json '= "" {
        set body = ##class(%DynamicObject).%FromJSON(json)
    }

    set result = ##class(PHA.COM.BaseBizPush.Manual.Facade.PushManualFacade).ExecuteByDynamic(body)
    do ..WriteJSON(result)
    quit $$$OK
}

ClassMethod WriteJSON(obj As %DynamicObject)
{
    set %response.ContentType = "application/json; charset=utf-8"
    write obj.%ToJSON()
}

}
