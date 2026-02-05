Class PHA.FACE.TPS.SA.Template.Pipeline.DocumentBuildHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    set iter=context.GroupResult.%GetIterator()
    while iter.%GetNext(.key,.arr) {
        set doc=##class(PHA.FACE.TPS.SA.Template.Context.Document).%New()
        set doc.Key=key
        Write !,"创建文档，Key: ",key, " Items数量: ",arr.%Size()
        for i=0:1:arr.%Size()-1 { 
            Set item = arr.%Get(i)
            Write !,"  文档Item[",i,"]: "
            If $IsObject(item) {
                Write item.%ToJSON()
            } Else {
                Write "非对象: ",item
            }
            do doc.Items.Insert(item) 
        }
        do context.Documents.Insert(doc)
    }
    quit $$$OK
}

}
