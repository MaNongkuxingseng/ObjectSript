Class PHA.FACE.TPS.SA.Template.Validation.ValidationSet Extends %RegisteredObject
{

/// <summary>
/// 单据级校验规则集合
/// </summary>
/// Author : Architecture
/// Date   : 2025-12-30
Property Rules As %ListOfObjects [ InitialExpression = {##class(%ListOfObjects).%New()} ];

/// <summary>
/// 执行所有 DocumentRule
/// </summary>
Method Validate(docData As %DynamicObject) As %Status
{
	s sc = $$$OK
    Set rule = ""
    For i=1:1:..Rules.Count() {
        Set rule = ..Rules.GetAt(i)
        Set rSc = rule.Validate(docData)
        If $$$ISERR(rSc) {
	        s sc = $$$ADDSC(sc,rSc)
        }
    }
    Quit sc
}

}
