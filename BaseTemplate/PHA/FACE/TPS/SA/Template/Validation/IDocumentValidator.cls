Class PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator Extends %RegisteredObject
{

/// ========================================
/// 单据级校验接口
/// 由业务系统实现
/// ========================================
Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status [ Abstract ]
{
    Quit $$$OK
}

}
