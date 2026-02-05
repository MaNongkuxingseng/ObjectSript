/// 入库应用类，继承 Template.BaseApplication，定义 Pipeline 执行流程
Class PHA.FACE.TPS.SA.INRec.App Extends PHA.FACE.TPS.SA.Template.App.BaseApplication
{

/// JSON 数据传入属性
Property jsonStr As %String;

/// 初始化 Context，用于存放 DTO 列表和分组数据
Method initContext() As PHA.FACE.TPS.SA.Template.Context.DocumentContext
{
    set context = ##class(PHA.FACE.TPS.SA.Template.Context.DocumentContext).%New()

    // 解析 JSON 数组
    Set arr = ##class(%DynamicArray).%FromJSON(..jsonStr)
    // 将{}展开为扁平数组
    if arr.%IsA("%DynamicObject") {
		s arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(arr,"drugList")
	}
    
    For i=0:1:arr.%Size()-1 {
        // 1. JSON转DTO
        Set jsonObj = arr.%Get(i)
        Set dto = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FromJson(jsonObj,"PHA.FACE.TPS.SA.INRec.InRecFlatDto")
        
        // 2. DTO基础验证
        Set sc = dto.Validate()
        If $$$ISERR(sc) {
            // 记录验证错误
            Write !,"DTO验证失败: ",$System.Status.GetErrorText(sc)
            Continue
        }
        
        // 3. DTO转动态对象，放入SourceList
        Set dynamicObj = dto.ToDynamicObject()
        Do context.SourceList.Insert(dynamicObj)
    }

    Quit context
}

Method getGroupRule() As PHA.FACE.TPS.SA.Template.Group.GroupRule
{
        Quit ##class(PHA.FACE.TPS.SA.INRec.GroupRule).%New()
}

Method getMappingSet() As PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{
        Quit ##class(PHA.FACE.TPS.SA.INRec.MappingSet).%New()
}

Method getValidationRules() As %ListOfObjects
{
        Quit ##class(PHA.FACE.TPS.SA.INRec.ValidationRules).Build()
}

Method getTransformRules() As %ListOfObjects
{
        Quit ##class(%ListOfObjects).%New()
}

Method getDocumentValidator() As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{
    Quit ##class(PHA.FACE.TPS.SA.INRec.InRecDocumentValidator).%New()
}

Method getBizHandler() As PHA.FACE.TPS.SA.Template.Pipeline.Handler
{
        Quit ##class(PHA.FACE.TPS.SA.INRec.BizHandler).%New()
}

}
