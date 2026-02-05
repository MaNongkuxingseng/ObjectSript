Class PHA.FACE.TPS.SA.INAdj.INAdjFlatDto Extends (%RegisteredObject, %JSON.Adaptor, %XML.Adaptor)
{

/// 库存调整单号
/// 如：ADJ20250319001
Property tzno As %String(MAXLEN = 50) [ Required ];

/// 调整科室
/// 传入科室代码（按医馆传科室代码给his）
Property tzloc As %String(MAXLEN = 100) [ Required ];

/// 调整原因
/// 类型：过期调整、调整差距、盘点调整
Property tzreason As %String(MAXLEN = 100) [ Required ];

/// 库存调整制单人
/// 传入工号
Property tzuser As %String(MAXLEN = 50) [ Required ];

/// 库存调整制单日期
/// 格式：YYYY-MM-DD
Property tzDate As %Date [ Required ];

/// 库存调整制单时间
/// 格式：hh:mm:ss
Property tzTime As %Time [ Required ];

/// 库存调整审核人
/// 传入工号
Property tzshuser As %String(MAXLEN = 50) [ Required ];

/// 库存调整审核日期
/// 格式：YYYY-MM-DD
Property tzshDate As %Date [ Required ];

/// 库存调整审核时间
/// 格式：hh:mm:ss
Property tzshTime As %Time [ Required ];

/// 药品代码
Property incno As %String(MAXLEN = 50) [ Required ];

/// 药品名称
Property incdesc As %String(MAXLEN = 200) [ Required ];

/// 调整数量
/// 调高是正数，调低是负数
/// 注意：接口文档中类型为VARCHAR(20)，这里使用%Decimal以支持计算
Property qty As %Decimal(SCALE = 2) [ Required ];

/// 调整单位
Property uom As %String(MAXLEN = 50) [ Required ];

/// 进价
/// 注意：接口文档中类型为VARCHAR(20)，这里使用%Decimal以支持计算
Property rp As %Decimal(SCALE = 4) [ Required ];

/// 售价
/// 待讨论字段
Property sp As %Decimal(SCALE = 4);

/// 进价金额
/// 注意：接口文档中类型为VARCHAR(20)，这里使用%Decimal以支持计算
Property rpAmt As %Decimal(SCALE = 2) [ Required ];

/// 售价金额
/// 待讨论字段
Property spAmt As %Decimal(SCALE = 2);

/// 批号
Property batNo As %String(MAXLEN = 50) [ Required ];

/// 批次id (Required)
Property Batid As %String(MAXLEN = 50) [ Required ];

/// 效期
/// 格式：YYYY-MM-DD
Property expDate As %Date [ Required ];

/// 从JSON对象创建DTO实例
ClassMethod FromJson(json As %DynamicObject) As PHA.FACE.TPS.SA.INAdj.INAdjFlatDto
{
    Set dto = ..%New()
    
    // 直接映射同名属性
    Set dto.tzno = json.%Get("tzno",,"")
    Set dto.tzloc = json.%Get("tzloc",,"")
    Set dto.tzreason = json.%Get("tzreason",,"")
    Set dto.tzuser = json.%Get("tzuser",,"")
    
    // 处理日期字段
    Set tzDateStr = json.%Get("tzDate",,"")
    If tzDateStr '= "" {
        Set dto.tzDate = $ZDateH(tzDateStr, 3)  // 3表示YYYY-MM-DD格式
    }
    
    // 处理时间字段
    Set tzTimeStr = json.%Get("tzTime",,"")
    If tzTimeStr '= "" {
        Set dto.tzTime = $ZTimeH(tzTimeStr, 1)  // 1表示hh:mm:ss格式
    }
    
    Set dto.tzshuser = json.%Get("tzshuser",,"")
    
    // 处理审核日期
    Set tzshDateStr = json.%Get("tzshDate",,"")
    If tzshDateStr '= "" {
        Set dto.tzshDate = $ZDateH(tzshDateStr, 3)
    }
    
    // 处理审核时间
    Set tzshTimeStr = json.%Get("tzshTime",,"")
    If tzshTimeStr '= "" {
        Set dto.tzshTime = $ZTimeH(tzshTimeStr, 1)
    }
    
    Set dto.incno = json.%Get("incno",,"")
    Set dto.incdesc = json.%Get("incdesc",,"")
    Set dto.qty = json.%Get("qty",,"")
    Set dto.uom = json.%Get("uom",,"")
    Set dto.rp = json.%Get("rp",,"")
    Set dto.sp = json.%Get("sp",,"")
    Set dto.rpAmt = json.%Get("rpAmt",,"")
    Set dto.spAmt = json.%Get("spAmt",,"")
    Set dto.batNo = json.%Get("batNo",,"")
    
    // 处理效期
    Set expDateStr = json.%Get("expDate",,"")
    If expDateStr '= "" {
        Set dto.expDate = $ZDateH(expDateStr, 3)
    }
    
    Quit dto
}

/// 将DTO转换为动态对象
Method ToDynamicObject() As %DynamicObject
{
    Set obj = {}
    
    Set obj.tzno = ..tzno
    Set obj.tzloc = ..tzloc
    Set obj.tzreason = ..tzreason
    Set obj.tzuser = ..tzuser
    
    // 格式化日期
    If ..tzDate '= "" {
        Set obj.tzDate = $ZDate(..tzDate, 3)  // YYYY-MM-DD格式
    } Else {
        Set obj.tzDate = ""
    }
    
    // 格式化时间
    If ..tzTime '= "" {
        Set obj.tzTime = $ZTime(..tzTime, 1)  // hh:mm:ss格式
    } Else {
        Set obj.tzTime = ""
    }
    
    Set obj.tzshuser = ..tzshuser
    
    // 格式化审核日期
    If ..tzshDate '= "" {
        Set obj.tzshDate = $ZDate(..tzshDate, 3)
    } Else {
        Set obj.tzshDate = ""
    }
    
    // 格式化审核时间
    If ..tzshTime '= "" {
        Set obj.tzshTime = $ZTime(..tzshTime, 1)
    } Else {
        Set obj.tzshTime = ""
    }
    
    Set obj.incno = ..incno
    Set obj.incdesc = ..incdesc
    Set obj.qty = ..qty
    Set obj.uom = ..uom
    Set obj.rp = ..rp
    Set obj.sp = ..sp
    Set obj.rpAmt = ..rpAmt
    Set obj.spAmt = ..spAmt
    Set obj.batNo = ..batNo
    
    // 格式化效期
    If ..expDate '= "" {
        Set obj.expDate = $ZDate(..expDate, 3)
    } Else {
        Set obj.expDate = ""
    }
    
    Quit obj
}

/// 验证DTO数据的完整性
Method Validate() As %Status
{
    Set sc = $$$OK
    
    // 检查必填字段
    If ..tzno = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "库存调整单号不能为空"))
    }
    
    If ..tzloc = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "调整科室不能为空"))
    }
    
    If ..tzreason = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "调整原因不能为空"))
    }
    
    If ..tzuser = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "制单人不能为空"))
    }
    
    If ..tzDate = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "制单日期不能为空"))
    }
    
    If ..tzTime = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "制单时间不能为空"))
    }
    
    If ..tzshuser = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "审核人不能为空"))
    }
    
    If ..tzshDate = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "审核日期不能为空"))
    }
    
    If ..tzshTime = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "审核时间不能为空"))
    }
    
    If ..incno = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "药品代码不能为空"))
    }
    
    If ..incdesc = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "药品名称不能为空"))
    }
    
    If ..qty = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "调整数量不能为空"))
    }
    
    If ..uom = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "调整单位不能为空"))
    }
    
    If ..rp = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "进价不能为空"))
    }
    
    If ..rpAmt = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "进价金额不能为空"))
    }
    
    If ..batNo = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "批号不能为空"))
    }
    
    If ..expDate = "" {
        Set sc = $$$ADDSC(sc, $$$ERROR($$$GeneralError, "效期不能为空"))
    }
    
    Quit sc
}

/// 获取格式化显示信息
Method GetDisplayInfo() As %String
{
    Set info = "调整单号: " _ ..tzno _ ", "
    Set info = info _ "药品: " _ ..incdesc _ "(" _ ..incno _ "), "
    Set info = info _ "数量: " _ ..qty _ " " _ ..uom _ ", "
    Set info = info _ "批号: " _ ..batNo _ ", "
    Set info = info _ "效期: " _ $ZDate(..expDate, 3)
    
    Quit info
}

}
