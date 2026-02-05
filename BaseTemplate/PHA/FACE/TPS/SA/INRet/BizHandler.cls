/// 退货业务处理器
/// Author : Valen MPF
/// Date   : 2026-01
/// Desc   : 调用 HIS 退货接口执行业务操作（inclb 批次分配就地生效）
Class PHA.FACE.TPS.SA.INRet.BizHandler Extends (PHA.FACE.TPS.SA.Template.Pipeline.Handler, PHA.COM.Base)
{

/// ---------------------------------------------------------------------
/// Method Name : handle
/// Description :
///   主业务入口，逐单据处理退货业务。
///   inclb 分配结果直接回写至 doc.Data.rows。
/// ---------------------------------------------------------------------
Method handle(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    #dim sc As %Status = $$$OK

    TSTART
    try {
        For i = 1:1:context.Documents.Count() {

            s doc = context.Documents.GetAt(i)
            s hisData = doc.Data

            // 1. 处理单据（inclb 分配并直接修改 doc.Data.rows）
            s sc = ..processDocument(doc)
            i $$$ISERR(sc) {
                TROLLBACK
                return sc
            }

            // 2. HIS 保存数据直接使用 doc.Data.rows
            s hisData.rows = doc.Data.rows

            // 3. 调用 HIS 接口
            s sc = ..callHisSave(hisData)
            i $$$ISERR(sc) {
                TROLLBACK
                return sc
            }
        }
    } catch (ex) {
        TROLLBACK
        return $$$ERROR($$$GeneralError,"处理 his 业务数据 '"_$classname()_"' 执行异常: "_ex.DisplayString())
    }

    TCOMMIT
    q sc
}

/// ---------------------------------------------------------------------
/// Method Name : processDocument
/// Description :
///   处理单个 Document，完成 rows 的 inclb 批次分配并回写。
/// ---------------------------------------------------------------------
Method processDocument(doc) As %Status
{
    #dim sc As %Status = $$$OK

    i '$isObject(doc.Data) {
        q $$$ERROR($$$GeneralError, "Document.Data 缺失")
    }

    s main   = doc.Data.main
    s locId  = main.logonLoc
    s hospId = ##class(PHA.COM.Data.Base).HospIdByLoc(locId)

    // 对 doc.Data.rows 就地进行 inclb 批次分配
    s rows = doc.Data.rows
    s sc = ..buildHisRows(doc.Data.rows, locId, hospId, .newRows)
	i $$$ISERR(sc) q sc

	; 在这里统一替换
	s doc.Data.rows = newRows
	q sc
}

/// ---------------------------------------------------------------------
/// Method Name : buildHisRows
/// Description :
///   对原始 SA rows 进行 inclb 批次分配。
///   采用“新数组重建”方式，最终整体替换 rows。
/// ---------------------------------------------------------------------
Method buildHisRows(srcRows, locId As %String, hospId As %String, ByRef outRows) As %Status
{
    #dim sc As %Status = $$$OK
    #dim tmpSC As %Status

    i '$isObject(srcRows) {
        q $$$ERROR($$$GeneralError, "输入 rows 为空")
    }

    ; 新 rows（最终替换 doc.Data.rows）
    s outRows = []

    ; 遍历 SA 原始行
    for idx = 0:1:(srcRows.%Size() - 1) {

        s row = srcRows.%Get(idx)

        ; -------- 1. 基础字段 --------
        s inci  = row.inci
        s batNo = row.batNo
        s qty   = +row.qty
        s uomId = row.uom

        s drugObj = ##class(PHA.COM.Data.Drug).%New(inci)

        ; -------- 2. 行级校验 --------
        i inci = "" {
            s sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError,"第"_ (idx+1) _"行缺少 inci"))
            continue
        }
        i batNo = "" {
            s sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError,"库存项 "_drugObj.Desc()_" 第"_ (idx+1) _"行缺少批号"))
            continue
        }
        i qty = 0 {
            s sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError,"库存项 "_drugObj.Desc()_" 第"_ (idx+1) _"行数量为 0"))
            continue
        }

        ; -------- 3. 单位换算 --------
        s baseQty = ##class(PHA.COM.Data.Format).BizToBaseQty(inci, qty, uomId)

        ; -------- 4. 批次分配 --------
        k inclbList
        s ret = ##class(PHA.FACE.TPS.SA.Template.Service.InclbAllocateService).Allocate(
            .inclbList, locId, inci, baseQty, batNo
        )
        i ret'="" {
            s sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError,drugObj.Desc()_"批次["_batNo_"]分配错误:"_ret))
            continue
        }

        ; -------- 5. 生成 inclb 行 --------
        s tmpSC = ..appendHisRows(.outRows, row, .inclbList)
        i $$$ISERR(tmpSC) {
            s sc = $$$ADDSC(sc,tmpSC)
        }
    }

    ; -------- 6. 最终校验 --------
    i outRows.%Size() < 1 {
        s sc = $$$ADDSC(sc,$$$ERROR($$$GeneralError,"未生成任何有效批次明细"))
    }

    q sc
}

/// ---------------------------------------------------------------------
/// 根据 inclb 分配结果，将一条 SA 行拆为多条 HIS 行
/// ---------------------------------------------------------------------
Method appendHisRows(ByRef outRows, row, ByRef inclbList) As %Status
{
    #dim sc As %Status = $$$OK

    s inci  = row.inci
    s uomId = row.uom

    s bUomId = $p(^INCI(inci, 1), "^", 10)
    s fac    = ##class(PHA.COM.Data.Base).UOMFac(uomId, bUomId)

    s i = ""
    for {
        s i = $o(inclbList(i))
        q:i=""

        s info     = inclbList(i)
        s inclb    = $p(info, "^", 4)
        s allocQty = $p(info, "^", 7)

        ; 单位回退
        i (allocQty # fac '= 0) {
            s outQty   = allocQty
            s outUomId = bUomId
        } else {
            s outQty   = ##class(PHA.COM.Data.Format).BaseToUomQty(+inclb,allocQty,uomId)
            s outUomId = uomId
        }

        s newRow = {}
        d ##class(PHA.COM.Json).Extend(newRow,row)

        ; ===== 覆盖 HIS 字段 =====
        s newRow.inci     = +inclb
        s newRow.inclb    = inclb
        s newRow.qty      = outQty
        s newRow.uom      = outUomId
        s newRow.recItmID = ##class(PHA.FACE.TPS.SA.INRet.Method).GetRecItm4Bat(inclb)
        s newRow.reason   = "4"

        d outRows.%Push(newRow)
    }

    q sc
}

/// ---------------------------------------------------------------------
/// Method Name : callHisSave
/// Description :
///   调用 HIS 退货保存接口。
/// ---------------------------------------------------------------------
Method callHisSave(hisData As %DynamicObject) As %Status
{
    // 调试输出
    w !, "SEND TO HIS:", hisData.%ToJSON()

    s ret = ##class(PHA.IN.RET.Biz).HandleSaveFinish(hisData)
    if ($$$phaIsError(ret)) {
        s sc = $$$ERROR($$$GeneralError,"HIS处理数据失败:"_ret)
        return sc
    }
    // 处理审核流程。
    s retId = ret
	s recData = ##class(PHA.IN.RET.Data).GetMainData(retId)
    Set sc = ##class(PHA.FACE.TPS.SA.INRet.Method).AutoAuditCore(recData)
    If $$$ISERR(sc) {
        return sc
    }

#;    i '$isObject(ret) {
#;        q $$$ERROR($$$GeneralError, "HIS 返回结果异常: "_ret)
#;    }
#;
#;    i ret.code '= 0 {
#;        q $$$ERROR($$$GeneralError, "HIS 处理数据失败: "_ret.%ToJSON())
#;    }

    q $$$OK
}

/// 处理文档上下文，调用HIS退货接口
/// 退货需要依据入库批次，海典无法提供，使用上面的批次分配。
Method handle11(context As PHA.FACE.TPS.SA.Template.Context.DocumentContext) As %Status
{
    Set sc = $$$OK
    TStart
    For i=1:1:context.Documents.Count() {
        Set doc = context.Documents.GetAt(i)
        Set ret = ##class(PHA.IN.RET.Api).HandleSave(doc.Data)		// PHA.IN.RET.Biz->SaveMainItmHandler
        If ret.code '= 0 {
            TROLLBACK
            return $$$ERROR($$$GeneralError,"HIS退货失败:"_ret.%ToJSON())
        }
    }
    TCommit
    Quit sc
}

}
