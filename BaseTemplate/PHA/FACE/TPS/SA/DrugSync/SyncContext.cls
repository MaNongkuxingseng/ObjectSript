Class PHA.FACE.TPS.SA.DrugSync.SyncContext Extends %RegisteredObject
{

Property DTO As PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO;

Property Dict As %DynamicObject;

Property Action As %String;

Property ArcJson As %DynamicObject;

Property InciJson As %DynamicObject;

Property Logon As %String [ InitialExpression = "1^1^1^2" ];

Method %OnNew() As %Status
{
    set ..Dict = {}.%New()
    set ..Action = ""
    quit $this
}

}
