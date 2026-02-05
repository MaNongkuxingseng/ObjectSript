/// ===============================================================================
/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: INAsp 扁平数据传输对象，调价数据扁平化传输对象
/// ===============================================================================
Class PHA.FACE.TPS.SA.INAsp.INAspFlatDto Extends PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter
{

/// 调价科室（SA → HIS 科室）
Property tjloc As %String;

/// 调价单号
Property tjno As %String;

/// 调价原因（SA → HIS 调价原因）
Property tjreason As %String;

/// 调价用户（SA → HIS 用户）
Property tjuser As %String;

/// 调价日期
Property tjDate As %String;

/// 调价时间
Property tjTime As %String;

/// 计划执行日期
Property PlanDate As %String;

/// 药品代码（SA → HIS 药品字典）
Property incno As %String;

/// 药品描述
Property incdesc As %String;

/// 批号
Property batNo As %String;

/// 批次ID
Property Batid As %String;

/// 有效期
Property expDate As %String;

/// 单位（SA → HIS 单位字典）
Property uom As %String;

/// 调后零售价
Property thrp As %String;

/// 调后供应价
Property thsp As %String;

/// Author: Valen MPF
/// Date: 2026-01-04
/// Description: 将DTO转换为DynamicObject
/// Input: 无
/// Output: %DynamicObject - 转换后的动态对象
Method Export() As %DynamicObject
{
	Set obj = {}

	Set obj.tjloc    = ..tjloc
	Set obj.tjno     = ..tjno
	Set obj.tjreason = ..tjreason
	Set obj.tjuser   = ..tjuser
	Set obj.tjDate   = ..tjDate
	Set obj.tjTime   = ..tjTime
	Set obj.PlanDate = ..PlanDate

	Set obj.incno    = ..incno
	Set obj.incdesc  = ..incdesc
	Set obj.batNo    = ..batNo
	Set obj.Batid    = ..Batid
	Set obj.expDate  = ..expDate
	Set obj.uom      = ..uom

	Set obj.thrp     = ..thrp
	Set obj.thsp     = ..thsp

	Quit obj
}

}
