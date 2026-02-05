/// 退货扁平 DTO
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 承载 SA 侧退货单字段，用于数据转换和映射
Class PHA.FACE.TPS.SA.INRet.Dto.INRetFlatDto Extends PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter
{

/// 退货单号 (Required)
Property thno As %String;

/// 退货科室 (Required)
Property thloc As %String;

/// 供应商 (Required)
Property vendor As %String;

/// 供应商描述
Property vendordesc As %String;

/// 退货类型 (34-普通退货, 其他值待定义)
Property type As %String;

/// 药品代码/ID (Required)
Property incno As %String;

/// 药品名称
Property incdesc As %String;

/// 退货数量 (Required)
Property qty As %Decimal;

/// 单位 (Required)
Property uom As %String;

/// 生产企业代码
Property manf As %String;

/// 生产企业描述
Property manfdesc As %String;

/// 进价
Property rp As %Decimal;

/// 售价
Property sp As %Decimal;

/// 进价金额
Property rpAmt As %Decimal;

/// 售价金额
Property spAmt As %Decimal;

/// 批号 (Required)
Property batNo As %String;

/// 批次id (Required)
Property Batid As %String;

/// 效期 (Required, 格式: YYYY-MM-DD)
Property expDate As %Date;

/// 制单人
Property thuser As %String;

/// 制单日期 (格式: YYYY-MM-DD)
Property thDate As %Date;

/// 制单时间 (格式: HH:MM:SS)
Property thTime As %Time;

/// 审核人
Property thshuser As %String;

/// 审核日期 (格式: YYYY-MM-DD)
Property thshDate As %Date;

/// 审核时间 (格式: HH:MM:SS)
Property thshTime As %Time;

/// 备注信息
Property note As %String;

/// 药品规格
Property spec As %String;

/// 药品编码
Property inciCode As %String;

/// 库存类组
Property stkCatGrp As %String;

/// 退货原因
Property reason As %String;

/// 退货原因描述
Property reasonDesc As %String;

}
