Class PHA.FACE.TPS.SA.INAdj.Api Extends %RegisteredObject
{

/// 库存调整业务入口
/// w ##class(PHA.FACE.TPS.SA.INAdj.Api).HandleSave()
ClassMethod HandleSave(jsonStr As %String) As %DynamicObject
{
	// {"adjId":"","adjLocId":"183","reasonId":"5","remarks":"","userId":"20667","rows":[{"adjItmId":"","inclb":"2266||2||1","uomId":"88","qty":"1.0000","resultQty":"999999.9580"}]}
    // s jsonStr = {"tzno":"260130000200005","tzloc":"ZYYX009","tzreason":"调整差距","tzuser":"3695","tzDate":"2026-01-30","tzTime":"15:45:12","tzshuser":"0119","tzshDate":"2026-01-30","tzshTime":"15:45:58","drugList":[{"incno":"1000016","incdesc":"蛤蚧[饮片]","qty":"-4","uom":"g","rp":"3","sp":"332.35","rpAmt":"270","spAmt":"270","batNo":"120232","expDate":"2028-09-08","Batid":"2719"},{"incno":"1000017","incdesc":"蛤壳[饮片]","qty":"1","uom":"g","rp":"28","sp":".034","rpAmt":"2576","spAmt":"2576","batNo":"12456","expDate":"2028-08-09","Batid":"2720"}]}.%ToJSON()
    Set app = ##class(PHA.FACE.TPS.SA.INAdj.App).%New()
    Set app.jsonStr = jsonStr
    
    Set runResult = app.RunInternal()
    Quit app.ParseRunResult(runResult).%ToJSON()
}

/// 示例3：使用动态对象构建参数
/// w ##class(PHA.FACE.TPS.SA.INAdj.Api).TestHandleSave()
ClassMethod TestHandleSave()
{
    // 构建动态数组
    Set arr = [{
	    "tzno": "ADJ20250319001",
	    "tzloc": "ZYYX005",
	    "tzreason": "盘点调整",
	    "tzuser": "yf01",
	    "tzDate": "2025-03-19",
	    "tzTime": "09:30:00",
	    "tzshuser": "U002",
	    "tzshDate": "2025-03-19",
	    "tzshTime": "10:00:00",
	    "incno": "XKF000351",
	    "incdesc": "阿司匹林肠溶片",
	    "qty": "10.5",
	    "uom": "盒",
	    "rp": "25.50",
	    "sp": "35.00",
	    "rpAmt": "267.75",
	    "spAmt": "367.50",
	    "batNo": "B20250301",
	    "expDate": "2026-03-01"
	  },
	  {
	    "tzno": "ADJ20250319001",
	    "tzloc": "ZYYX005",
	    "tzreason": "盘点调整",
	    "tzuser": "yf01",
	    "tzDate": "2025-03-19",
	    "tzTime": "09:30:00",
	    "tzshuser": "U002",
	    "tzshDate": "2025-03-19",
	    "tzshTime": "10:00:00",
	    "incno": "XKF000178",
	    "incdesc": "布洛芬缓释胶囊",
	    "qty": "-5.0",
	    "uom": "瓶",
	    "rp": "18.50",
	    "sp": "28.00",
	    "rpAmt": "-92.50",
	    "spAmt": "-140.00",
	    "batNo": "B20241201",
	    "expDate": "2025-06-30"
	  },
	  {
	    "tzno": "ADJ20250319002",
	    "tzloc": "ZYYX005",
	    "tzreason": "过期调整",
	    "tzuser": "yf01",
	    "tzDate": "2025-03-19",
	    "tzTime": "14:30:00",
	    "tzshuser": "U004",
	    "tzshDate": "2025-03-19",
	    "tzshTime": "15:00:00",
	    "incno": "XKF000132",
	    "incdesc": "头孢克肟片",
	    "qty": "-20.0",
	    "uom": "盒",
	    "rp": "45.80",
	    "sp": "68.50",
	    "rpAmt": "-916.00",
	    "spAmt": "-1370.00",
	    "batNo": "B20240615",
	    "expDate": "2025-03-15"
	  },
	  {
	    "tzno": "ADJ20250319003",
	    "tzloc": "ZYYX005",
	    "tzreason": "调整差距",
	    "tzuser": "yf01",
	    "tzDate": "2025-03-19",
	    "tzTime": "16:15:00",
	    "tzshuser": "U006",
	    "tzshDate": "2025-03-19",
	    "tzshTime": "16:30:00",
	    "incno": "XKF000390",
	    "incdesc": "盐酸二甲双胍片",
	    "qty": "8.0",
	    "uom": "瓶",
	    "rp": "12.30",
	    "sp": "18.00",
	    "rpAmt": "98.40",
	    "spAmt": "144.00",
	    "batNo": "B20250210",
	    "expDate": "2026-08-10"
	  },
	  {
	    "tzno": "ADJ20250319003",
	    "tzloc": "ZYYX005",
	    "tzreason": "调整差距",
	    "tzuser": "yf01",
	    "tzDate": "2025-03-19",
	    "tzTime": "16:15:00",
	    "tzshuser": "U006",
	    "tzshDate": "2025-03-19",
	    "tzshTime": "16:30:00",
	    "incno": "XKF000669",
	    "incdesc": "硝苯地平控释片",
	    "qty": "3.5",
	    "uom": "盒",
	    "rp": "32.40",
	    "sp": "48.60",
	    "rpAmt": "113.40",
	    "spAmt": "170.10",
	    "batNo": "B20250120",
	    "expDate": "2026-07-20"
	  }
	]
    
    // 转换为JSON字符串
    Set jsonStr = arr.%ToJSON()
    
    // 调用API
    Set result = ##class(PHA.FACE.TPS.SA.INAdj.Api).HandleSave(jsonStr)
    
    // 处理结果
    If result.success {
        Write "库存调整成功！", !
        Write "调整单号:", result.data.adjNo, !
        Write "调整时间:", result.data.adjTime
    } Else {
        Write "库存调整失败！", !
        Write "错误信息:", result.message, !

    }
}

}
