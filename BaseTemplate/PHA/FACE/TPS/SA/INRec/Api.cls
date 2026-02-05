Class PHA.FACE.TPS.SA.INRec.Api Extends %RegisteredObject
{

/// HIS接收SA数据完成入库
/// w ##class(PHA.FACE.TPS.SA.INRec.Api).HandleSave()
ClassMethod HandleSave(jsonStr As %String) As %DynamicObject
{
	//set jsonStr = [{"rkno":"R20251223","rkloc":"ZYYX003","vendor":"YP00450","vendordesc":"协宇东盈医疗科技北京有限公司","type":"正常入库","cguser":"YF01","note":"第一批入库","incno":"XDS000003","incdesc":"5%葡萄糖注射液(袋装)[500ml]","qty":"10","uom":"袋","manf":"G00898","manfdesc":"青岛华仁药业","rp":"7.20","sp":"7.20","rpAmt":"72","spAmt":"72","batNo":"202501223","expDate":"2028-03-31","zduser":"YF01","zdDate":"2025-12-23","zdTime":"09:00:00","shuser":"YF01","shDate":"2025-12-23","shTime":"09:00:00","Batid":"B0001"},{"rkno":"R20251223","rkloc":"ZYYX003","vendor":"YP00450","vendordesc":"协宇东盈医疗科技北京有限公司","type":"正常入库","cguser":"YF01","note":"第一批入库","incno":"XDS000001","incdesc":"5%葡萄糖注射液(袋装)[100ml]","qty":"10","uom":"袋","manf":"G00898","manfdesc":"青岛华仁药业","rp":"6.60","sp":"6.60","rpAmt":"66","spAmt":"66","batNo":"202501223","expDate":"2028-03-31","zduser":"YF01","zdDate":"2025-12-23","zdTime":"09:00:00","shuser":"YF01","shDate":"2025-12-23","shTime":"09:00:00","Batid":"B0002"}].%ToJSON()

    set app = ##class(PHA.FACE.TPS.SA.INRec.App).%New()
    set app.jsonStr = jsonStr
    Set runResult = app.RunInternal()

	Set resp = app.ParseRunResult(runResult)
	q resp.%ToJSON()
}

}
