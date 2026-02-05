Class PHA.FACE.TPS.SA.INAdj.App Extends PHA.FACE.TPS.SA.Template.App.BaseApplication
{

Property jsonStr As %String;

Method initContext() As PHA.FACE.TPS.SA.Template.Context.DocumentContext
{
    Set context = ##class(PHA.FACE.TPS.SA.Template.Context.DocumentContext).%New()
    Set arr = ##class(%DynamicArray).%FromJSON(..jsonStr)
    // 将{}展开为扁平数组
    if arr.%IsA("%DynamicObject") {
		s arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(arr,"drugList")
	}
    For i=0:1:arr.%Size()-1 {
        Set dto = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FromJson(arr.%Get(i),"PHA.FACE.TPS.SA.INAdj.INAdjFlatDto")

        Do context.SourceList.Insert(
            ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).ToDynamicObject(dto)
        )
    }
    Quit context
}

Method getGroupRule() As PHA.FACE.TPS.SA.Template.Group.GroupRule
{
    Quit ##class(PHA.FACE.TPS.SA.INAdj.INAdjGroupRule).%New()
}

Method getMappingSet() As PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{
    Quit ##class(PHA.FACE.TPS.SA.INAdj.INAdjMappingSet).%New()
}

Method getValidationRules() As %ListOfObjects
{
    Quit ##class(PHA.FACE.TPS.SA.INAdj.INAdjValidationRules).Build()
}

Method getTransformRules() As %ListOfObjects
{
    Quit ##class(%ListOfObjects).%New()
}

Method getDocumentValidator() As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{
    Quit ##class(PHA.FACE.TPS.SA.INAdj.INAdjDocumentValidator).%New()
}

Method getBizHandler() As PHA.FACE.TPS.SA.Template.Pipeline.Handler
{
    Quit ##class(PHA.FACE.TPS.SA.INAdj.INAdjBizHandler).%New()
}

}
