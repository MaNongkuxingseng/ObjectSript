/// 退货应用
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 定义 INRet Pipeline 执行流程
Class PHA.FACE.TPS.SA.INRet.App Extends PHA.FACE.TPS.SA.Template.App.BaseApplication
{

/// SA传入的原始JSON字符串
Property jsonStr As %String;

/// 初始化文档上下文，将JSON转换为文档结构
Method initContext() As PHA.FACE.TPS.SA.Template.Context.DocumentContext
{
    Set context = ##class(PHA.FACE.TPS.SA.Template.Context.DocumentContext).%New()
    Set arr = ##class(%DynamicArray).%FromJSON(..jsonStr)
	// 将{}展开为扁平数组
    if arr.%IsA("%DynamicObject") {
		s arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(arr,"drugList")
	}
    For i=0:1:arr.%Size()-1 {
        Set dto = ##class(PHA.FACE.TPS.SA.INRet.Dto.INRetFlatDto).FromJson(arr.%Get(i),"PHA.FACE.TPS.SA.INRet.Dto.INRetFlatDto")
        Do context.SourceList.Insert(
        	##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).ToDynamicObject(dto)
        )
    }
    Quit context
}

/// 获取分单规则
Method getGroupRule() As PHA.FACE.TPS.SA.Template.Group.GroupRule
{
 Quit ##class(PHA.FACE.TPS.SA.INRet.GroupRule).%New()
}

/// 获取字段映射规则
Method getMappingSet() As PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{
 Quit ##class(PHA.FACE.TPS.SA.INRet.MappingSet).%New()
}

/// 获取字段级校验规则
Method getValidationRules() As %ListOfObjects
{
 Quit ##class(PHA.FACE.TPS.SA.INRet.ValidationRules).Build()
}

/// 获取单据级校验器
Method getDocumentValidator() As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{
 Quit ##class(PHA.FACE.TPS.SA.INRet.InRetDocumentValidator).%New()
}

/// 获取业务处理器
Method getBizHandler() As PHA.FACE.TPS.SA.Template.Pipeline.Handler
{
 Quit ##class(PHA.FACE.TPS.SA.INRet.BizHandler).%New()
}

}
