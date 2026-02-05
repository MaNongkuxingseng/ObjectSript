/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01
/// Description: INAsp 调价API入口类，HIS接收统一调价数据入口类
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.Api Extends %RegisteredObject
{

/// Author: Valen MPF
/// Date: 2026-01
/// Description: HIS接收统一调价数据入口方法
/// Input: jsonStr - JSON格式的调价数据数组
/// Output: %Status - 操作状态
/// Example: w ##class(PHA.FACE.TPS.SA.INAsp.Api).HandleSave("[{}]")
ClassMethod HandleSave(jsonStr As %String) As %Status
{
	//s jsonStr = [{"tjloc":"ZYYX010","tjno":"ASP20260104001","tjreason":"价格上涨","tjuser":"yf01","tjDate":"","tjTime":"","PlanDate":"2026-01-05","incno":"YPC000035","incdesc":"北豆根[饮片]","batNo":"","Batid":"","expDate":"","uom":"g","thrp":"0.03","thsp":"0.03"}]
    Set app = ##class(PHA.FACE.TPS.SA.INAsp.INAspApplication).%New()
    Set app.jsonStr = jsonStr    ;.%ToJSON()
    Set runResult = app.RunInternal()
    Quit app.ParseRunResult(runResult).%ToJSON()
}

}
