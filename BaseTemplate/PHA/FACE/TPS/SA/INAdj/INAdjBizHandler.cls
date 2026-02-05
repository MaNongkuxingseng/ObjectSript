/// =====================================================================
/// Class Name  : PHA.FACE.TPS.SA.INAdj.INAdjBizHandler
/// Description :
///   INAdj 业务处理器。
///   负责将 SA 输入的 inci + batNo + qty + uom
///   转换为 HIS 保存所需的 inclb 明细数据。
/// 
///   转换流程：
///     doc.Data.rows
///        → 基本单位换算
///        → 批次分配（InclbAllocateService）
///        → doc.rows（inclb 粒度）
/// 
/// Author      : Valen MPF
/// Date        : 2025-12-31
/// =====================================================================
Class PHA.FACE.TPS.SA.INAdj.INAdjBizHandler Extends PHA.FACE.TPS.SA.Template.Pipeline.Handler
{

/// ---------------------------------------------------------------------
/// Method Name : Handle
/// Description :
///   INAdj 入口方法。
///   完成：
///     1) 批次分配
///     2) 组装 HIS 数据
///     3) 调用 HIS 保存接口
/// 
/// Input  : context As DocumentContext
/// Output : %Status
/// ---------------------------------------------------------------------
Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    #dim sc As %Status = $$$OK

    TSTART

	try {
	    For i = 1:1:context.Documents.Count() {

	        s doc = context.Documents.GetAt(i)
			s hisData = doc.Data.main
			s hisRows = []
	        // 1. 批次分配并生成 doc.rows（已在前一步完成）
	        s sc = ..processDocument(doc, .hisRows)
	        i $$$ISERR(sc) {
	            TROLLBACK
	            return sc
	        }

	        // 2. 构建 HIS 保存对象
	        s hisData.rows = hisRows

	        // 3. 调用 HIS 接口
	        s sc = ..callHisSave(hisData)
	        i $$$ISERR(sc) {
	            TROLLBACK
	            return sc
	        }
	    }
	}catch(ex) {
		TROLLBACK
		Return $$$ERROR($$$GeneralError,"处理his业务数据'"_$classname()_"' 执行异常: "_ex.DisplayString())
	}

    TCOMMIT
    q sc
}

/// ---------------------------------------------------------------------
/// Method Name : processDocument
/// Description :
///   处理单个 Document，完成 rows 的批次分配转换。
/// 
/// Input  :
///   doc     单据对象
///   context DocumentContext
/// 
/// Output : %Status
/// ---------------------------------------------------------------------
Method processDocument(doc, ByRef hisRows) As %Status
{
    #dim sc As %Status = $$$OK

    i '$isObject(doc.Data) {
        q $$$ERROR($$$GeneralError, "Document.Data 缺失")
    }
	s main = doc.Data.main
	s locId = main.adjLocId
	s hospId = ##class(PHA.COM.Data.Base).HospIdByLoc(locId)
    // 生成 HIS 专用 rows（inclb 粒度）
    s sc = ..buildHisRows(
        doc.Data.rows,
        locId,
        hospId,
        .hisRows
    )
    i $$$ISERR(sc) q sc

    // ★ 核心：直接替换 doc.rows，供后续 handle 保存
    // s doc.rows = hisRows

    q sc
}

/// ---------------------------------------------------------------------
/// Method Name : buildHisRows
/// Description :
///   将 SA 输入 rows（inci + batNo + qty + uom）
///   转换为 HIS rows（inclb + qty）。
/// 
/// Input  :
///   srcRows SA 输入 rows
///   locId   科室ID
///   hospId  医院ID
/// 
/// Output :
///   hisRows HIS 专用 rows(ByRef)
/// 
/// Return : %Status
/// ---------------------------------------------------------------------
Method buildHisRows(srcRows, locId As %String, hospId As %String, ByRef hisRows) As %Status
{
    #dim sc As %Status = $$$OK
    #dim tmpSC As %Status

    s hisRows = []

    // -----------------------------
    // 0. 系统级入参校验
    // -----------------------------
    i '$isObject(srcRows) {
        q $$$ERROR($$$GeneralError, "输入 rows 为空")
    }

    // -----------------------------
    // 1. 遍历 DynamicArray
    // -----------------------------
    for idx = 0:1:(srcRows.%Size() - 1) {

        s row = srcRows.%Get(idx)

        // -----------------------------
        // 1.1 解析 SA 输入字段
        // -----------------------------
        s inci  = row.inci          ; 库存项(inci)
        s batNo = row.batNo         ; 批号(batch no)
        s qty   = +row.qty          ; 输入数量
        s uomId = row.uomId         ; 输入单位
        s drugObj = ##class(PHA.COM.Data.Drug).%New(inci)

        // ---- 行级校验（累计错误）
        i inci = "" {
            s tmpSC = $$$ERROR($$$GeneralError,"第"_ (idx+1) _"行缺少 inci")
            s sc = $$$ADDSC(sc, tmpSC)
            continue
        }

        i batNo = "" {
            s tmpSC = $$$ERROR($$$GeneralError,"库存项 "_drugObj.Desc()_" 第"_ (idx+1) _"行缺少批号")
            s sc = $$$ADDSC(sc, tmpSC)
            continue
        }

        i +qty = 0 {
	        s tmpSC = $$$ERROR($$$GeneralError,"库存项 "_drugObj.Desc()_" 第"_ (idx+1) _"行调整数量为 0")
            s sc = $$$ADDSC(sc, tmpSC)
            continue
        }

        // -----------------------------
        // 2. 单位换算 → 基本单位
        // -----------------------------
        s baseQty = ##class(PHA.COM.Data.Format).BizToBaseQty(inci, qty, uomId)

        // -----------------------------
        // 3. 批次分配
        // -----------------------------
        k inclbList
        s serRet =  ##class(PHA.FACE.TPS.SA.Template.Service.InclbAllocateService).Allocate(
	        .inclbList,locId,inci,baseQty,batNo
           )
		if (serRet'="") {
			s tmpSC = $$$ERROR($$$GeneralError,drugObj.Desc()_"批次["_batNo_"]分配错误:"_serRet)
            s sc = $$$ADDSC(sc, tmpSC)
            continue
        }

        // -----------------------------
        // 4. 构建 HIS rows
        // -----------------------------
        s tmpSC = ..appendHisRows(
            .hisRows,
            .inclbList,
            inci,
            uomId,
            qty,
            baseQty
        )

        i $$$ISERR(tmpSC) {
            s sc = $$$ADDSC(sc, tmpSC)
            continue
        }
    }

    // -----------------------------
    // 5. 最终结果判断
    // -----------------------------
    i hisRows.%Size() < 1 {
        s tmpSC = $$$ERROR($$$GeneralError,"未生成任何有效批次明细")
        s sc = $$$ADDSC(sc, tmpSC)
    }

    q sc
}

/// ---------------------------------------------------------------------
/// Method Name : appendHisRows
/// Description :
///   根据批次分配结果，追加 HIS 明细行。
/// 
/// Input  :
///   hisRows   HIS rows(ByRef)
///   inclbList 批次分配结果
///   inci      库存项
///   uomId     原输入单位
///   qty       原输入数量
///   baseQty   基本单位数量
/// 
/// Output : %Status
/// ---------------------------------------------------------------------
Method appendHisRows(ByRef hisRows, ByRef inclbList, inci As %String, uomId As %String, qty As %Numeric, baseQty As %Numeric) As %Status
{
    s bUomId = $p(^INCI(inci, 1), "^", 10)
    s fac = ##class(PHA.COM.Data.Base).UOMFac(uomId, bUomId)

    s i = ""
    for {
        s i = $o(inclbList(i))
        q:(i = "")

        s info = inclbList(i)

        s inclb    = $p(info, "^", 4)
        s allocQty = $p(info, "^", 7)          ; 基本单位数量

        // 单位回退（与原 INAdj 逻辑一致）
        if (allocQty # fac '= 0) {
            s outQty   = allocQty
            s outUomId = bUomId
        } else {
            s outQty   = ##class(PHA.COM.Data.Format).BaseToUomQty(+inclb,allocQty,uomId)
            s outUomId = uomId
        }

        s hisRow = {
            "adjItmId"  : "",
            "inclb"     : (inclb),
            "uomId"     : (outUomId),
            "qty"       : (outQty)
        }

        d hisRows.%Push(hisRow)
    }

    q $$$OK
}

/// ---------------------------------------------------------------------
/// Method Name : callHisSave
/// Description :
///   调用 HIS 入库调整保存接口。
/// 
/// Input  : hisData HIS 保存数据
/// Output : %Status
/// ---------------------------------------------------------------------
Method callHisSave(hisData As %DynamicObject) As %Status
{
    // 调试输出（需要可保留）
    w !, "SEND TO HIS:", hisData.%ToJSON()

    s ret = ##class(PHA.IN.ADJ.Api).SaveData(hisData)

    i '$isObject(ret) {
        q $$$ERROR($$$GeneralError, "HIS返回结果异常"+ret)
    }

    i ret.code '= 0 {
        q $$$ERROR($$$GeneralError,"HIS处理数据失败:" _ ret.%ToJSON())
    }
    
    // 处理审核流程。
    s adjId = ret.data
	s adjData = ##class(PHA.IN.ADJ.Data).GetMainData(adjId)
    Set sc = ##class(PHA.FACE.TPS.SA.INAdj.Method).AutoAuditCore(adjData)
    If $$$ISERR(sc) {
        return sc
    }
    
    q $$$OK
}

}
