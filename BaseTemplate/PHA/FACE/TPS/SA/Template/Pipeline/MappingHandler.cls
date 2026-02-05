Class PHA.FACE.TPS.SA.Template.Pipeline.MappingHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

Property mappingSet As PHA.FACE.TPS.SA.Template.Mapping.MappingSet;

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    for i=1:1:context.Documents.Count() {
        set doc=context.Documents.GetAt(i)
        Write !,"映射前文档Items数量: ",doc.Items.Count()
        set sc=##class(PHA.FACE.TPS.SA.Template.Mapping.MappingEngine).MapDocument(doc,..mappingSet)
        Write !,"映射结果: ",doc.Data.%ToJSON()
        if $$$ISERR(sc) return sc
    }
    quit $$$OK
}

}
