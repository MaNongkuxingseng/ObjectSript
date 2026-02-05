/// 入库 DTO，按 rkno 分组，包含所有入库接口字段，供 Pipeline 使用
Class PHA.FACE.TPS.SA.INRec.InRecFlatDto Extends %RegisteredObject
{

/// 入库单号 非空 唯一
Property rkno As %String [ Required ];

/// 入库科室
Property rkloc As %String [ Required ];

/// 供应商
Property vendor As %String [ Required ];

/// 供应商描述
Property vendordesc As %String;

/// 入库类型
Property type As %String [ Required ];

/// 采购员
Property cguser As %String [ Required ];

/// 备注
Property note As %String;

/// 药品代码
Property incno As %String [ Required ];

/// 药品描述
Property incdesc As %String [ Required ];

/// 数量 最小单位或者包装单位，如片或盒（20）
Property qty As %Decimal [ Required ];

/// 单位
Property uom As %String [ Required ];

/// 厂商 生产企业代码
Property manf As %String [ Required ];

/// 厂商描述
Property manfdesc As %String [ Required ];

/// 进价
Property rp As %Decimal [ Required ];

/// 售价
Property sp As %Decimal;

/// 进价金额
Property rpAmt As %Decimal [ Required ];

/// 售价金额
Property spAmt As %Decimal;

/// 批号
Property batNo As %String [ Required ];

/// 效期
Property expDate As %Date [ Required ];

/// 制单人 非空 传入工号
Property zduser As %String;

/// 制单日期
Property zdDate As %Date;

/// 制单时间
Property zdTime As %Time;

/// 审核人
Property shuser As %String;

/// 审核日期
Property shDate As %Date;

/// 审核时间
Property shTime As %Time;

/// 批次ID
Property Batid As %String;

/// 验证DTO数据
Method Validate() As %Status
{
    Set sc = $$$OK
    
    // 基本验证
    If ..rkno = "" {
        Set sc = $$$ADDSC(sc,$$$ERROR("入库单号不能为空"))
    }
    
    If ..qty <= 0 {
        Set sc = $$$ADDSC(sc,$$$ERROR("数量必须大于0"))
    }
    
    If ..rp <= 0 {
        Set sc = $$$ADDSC(sc,$$$ERROR("进价必须大于0"))
    }
    
    // 业务规则验证
#;    If ..expDate '= "" {
#;        If ..expDate < +$Horolog {
#;            Set sc = $$$ADDSC(sc,$$$ERROR("药品已过期"))
#;        }
#;    }
    
    Quit sc
}

/// 转换为动态对象（用于后续处理）
Method ToDynamicObject() As %DynamicObject
{
    Set obj = {}
    
    // 使用反射获取所有属性
    Set class = ##class(%Dictionary.CompiledClass).%OpenId($ClassName())
    For i=1:1:class.Properties.Count() {
        Set prop = class.Properties.GetAt(i)
        Set propName = prop.Name
        Set value = $Property($this, propName)
        Do obj.%Set(propName, value)
#;        If value '= "" {
#;            Do obj.%Set(propName, value)
#;        }
    }
    
    Quit obj
}

}
