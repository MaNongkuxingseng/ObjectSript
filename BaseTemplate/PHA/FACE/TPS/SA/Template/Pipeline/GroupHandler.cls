Class PHA.FACE.TPS.SA.Template.Pipeline.GroupHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

Property rule As PHA.FACE.TPS.SA.Template.Group.GroupRule;

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    If '$isobject(..rule) { Quit $$$ERROR($$$GeneralError,"GroupRule not defined") }
    Set context.GroupResult=##class(PHA.FACE.TPS.SA.Template.Group.MultiFieldGroupEngine).Group(context.SourceList,..rule.Fields)
    
    Write !,"分组结果: ",context.GroupResult.%ToJSON()
    Quit $$$OK
}

}
