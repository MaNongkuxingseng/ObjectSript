/// Base handler - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.Handlers.BaseHandler Extends %RegisteredObject
{

Method Handle(context As PHA.FACE.TPS.SA.DrugSync.SyncContext) As %Status [ Abstract ]
{
}

Method GetHandleInfo() As %DynamicObject
{
	#dim info as %DynamicObject = {"handleClass":""}
	s info.handleClass = $classname($this)
	q info
}

}
