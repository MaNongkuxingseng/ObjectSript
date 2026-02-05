Class PHA.FACE.TPS.SA.INAdj.INAdjDocumentValidator Extends PHA.FACE.TPS.SA.Template.Validation.IDocumentValidator
{

Method Validate(doc As PHA.FACE.TPS.SA.Template.Context.Document) As %Status
{
    Set tzno = doc.Data.main.tzno
    
    If tzno="" {
	    Quit $$$ERROR($$$GeneralError,"单据校验不通过:库存调整单号不能为空")
    }
    If $Data(^DHCINAD(0,"No",$$ALPHAUP^SSUTIL4(tzno))) {
        Quit $$$ERROR($$$GeneralError,"调整单已存在，禁止重复提交: "_tzno)
    }

    Quit $$$OK
}

}
