/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 调价应用类，处理调价业务的主应用类
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspApplication Extends PHA.FACE.TPS.SA.Template.App.BaseApplication
{

/// JSON格式的调价数据字符串
Property jsonStr As %String(MAXLEN = "");

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 初始化DocumentContext
/// Input: 无
/// Output: PHA.FACE.TPS.SA.Template.Context.DocumentContext - 文档上下文对象
Method initContext() As PHA.FACE.TPS.SA.Template.Context.DocumentContext
{
	Set context = ##class(PHA.FACE.TPS.SA.Template.Context.DocumentContext).%New()
	Set arr = ##class(%DynamicArray).%FromJSON(..jsonStr)

	// 将{}展开为扁平数组
    if arr.%IsA("%DynamicObject") {
		s arr = ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList(arr,"drugList")
	}
	For i=0:1:arr.%Size()-1 {
		Set dto = ##class(PHA.FACE.TPS.SA.INRet.Dto.INRetFlatDto).FromJson(arr.%Get(i),"PHA.FACE.TPS.SA.INAsp.INAspFlatDto")
		Do context.SourceList.Insert(dto.Export())
	}

	Quit context
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 获取分组规则
/// Input: 无
/// Output: PHA.FACE.TPS.SA.Template.Group.GroupRule - 分组规则对象
Method getGroupRule() As PHA.FACE.TPS.SA.Template.Group.GroupRule
{
	Quit ##class(PHA.FACE.TPS.SA.INAsp.INAspGroupRule).%New()
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 获取映射规则集
/// Input: 无
/// Output: PHA.FACE.TPS.SA.Template.Mapping.MappingSet - 映射规则集对象
Method getMappingSet() As PHA.FACE.TPS.SA.Template.Mapping.MappingSet
{
	Quit ##class(PHA.FACE.TPS.SA.INAsp.INAspMappingSet).%New()
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 获取验证规则列表
/// Input: 无
/// Output: %ListOfObjects - 验证规则列表对象
Method getValidationRules() As %ListOfObjects
{
	Quit ##class(PHA.FACE.TPS.SA.INAsp.INAspValidationRules).Build()
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 获取文档验证器
/// Input: 无
/// Output: PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator - 文档验证器对象
Method getDocumentValidator() As PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{
	Quit ##class(PHA.FACE.TPS.SA.INAsp.INAspDocumentValidator).%New()
}

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 获取业务处理器
/// Input: 无
/// Output: PHA.FACE.TPS.SA.Template.Pipeline.Handler - 业务处理器对象
Method getBizHandler() As PHA.FACE.TPS.SA.Template.Pipeline.Handler
{
	Quit ##class(PHA.FACE.TPS.SA.INAsp.INAspBizHandler).%New()
}

}
