/// SA → HIS 退货接口入口
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 接收 SA 退货数据并触发 Pipeline 执行
Class PHA.FACE.TPS.SA.INRet.Api Extends %RegisteredObject
{

/// SA → HIS 退货接口入口
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 接收 SA 退货数据并触发 Pipeline 执行
/// w ##class(PHA.FACE.TPS.SA.INRet.Api).HandleSave()
ClassMethod HandleSave(jsonStr As %String) As %DynamicObject
{
	// s jsonStr=^MPF("inret")
	//s json = [{"thno":"TH202601150001","thloc":"187","vendor":"30","vendordesc":"供应商名称","type":"34","note":"","incno":"8","incdesc":"0.9%氯化钠注射液(袋装)[250ml]","inciCode":"XDS000008","qty":"1.0000","uom":"24","manf":"895","manfdesc":"青岛华仁药业","rp":"8.00","sp":"8.00","rpAmt":"8","spAmt":"8","batNo":"20251118","expDate":"2027-11-18","spec":"250ml","thuser":"20667","thDate":"2026-01-15","thTime":"14:30:00","thshuser":"","thshDate":"","thshTime":"","stkCatGrp":"3","dataLinkFrom":"","retID":"","mainRowID":"","reason":"4","reasonDesc":"其他"}]
    s jsonStr = {"thno":"260130000200000001","thloc":"ZYYX009","vendor":"YP00001","vendordesc":"初始化供应商","type":"正常退货","thuser":"0119","thDate":"2026-01-30","thTime":"11:39:30","thshuser":"0119","thshDate":"2026-01-30","thshTime":"11:39:44","drugList":[{"incno":"1000016","incdesc":"蛤蚧[饮片]","qty":"5","uom":"g","manf":"0","manfdesc":"以批次为准","rp":"3","sp":"3","rpAmt":"15","spAmt":"15","batNo":"120232","expDate":"2028-09-08","Batid":"2719"},{"incno":"1000017","incdesc":"蛤壳[饮片]","qty":"10","uom":"g","manf":"0","manfdesc":"以批次为准","rp":"28","sp":"28","rpAmt":"280","spAmt":"280","batNo":"12456","expDate":"2028-08-09","Batid":"2720"}]}.%ToJSON()
    Set app = ##class(PHA.FACE.TPS.SA.INRet.App).%New()
    Set app.jsonStr = jsonStr
    Set runResult = app.RunInternal()
    Quit app.ParseRunResult(runResult).%ToJSON()
}

}
