Class PHA.FACE.TPS.SA.INRet.Method Extends PHA.IN.RET.Base
{

/// 根据批次获取入库字表id
/// w ##class(PHA.FACE.TPS.SA.INRet.Method).GetRecItm4Bat("8||4||7")
ClassMethod GetRecItm4Bat(inclb)
{
	// s ^MPF("GetRecItm4Bat") = inclb
	// ^DHCINGR(0,"GRI_INCIB",{INGRI_INCIB_DR},{DHC_INGdRec.INGR_RowId},{INGRI_ChildSub})
	s recItmId = ""
	s lbData = ##class(PHA.COM.Data.INCLB).%New(inclb)
	s ib = lbData.Incib()
	s recId = $o(^DHCINGR(0,"GRI_INCIB",ib,""))
	q:recId="" recItmId
	s itmId = $o(^DHCINGR(0,"GRI_INCIB",ib,recId,""))
	q:itmId="" recItmId
	s recItmId = recId_"||"_itmId
	q recItmId
}

/// 执行全部入库审核流程
/// w ##class(PHA.FACE.TPS.SA.INRec.Method).AutoAuditCore()
ClassMethod AutoAuditCore(retData As %DynamicObject) As %Status
{
    #dim sc As %Status = $$$OK
    #dim statusArr As %DynamicArray = []
	s retId = retData.%Get("retID")
	s userId = retData.%Get("createUser")
    TStart
    Try {
        // ======================================
        // 1. 基础上下文
        // ======================================
        Set proLocId = ##class(PHA.IN.RET.Data).GetLoc(retId)

        // ======================================
        // 2. 状态校验
        // ======================================
        Set statusObj = ##class(PHA.IN.RET.Ref).GetCurrentStatus(retId)
        If statusObj.code '= "COMP" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "退货单为"_statusObj.desc_"状态，不允许审核")
                )
        }

        // ======================================
        // 5. 获取流程路径
        // ======================================
        Set sc = ##class(PHA.IN.RET.Data).GetStatusList("COMP","AUDIT",proLocId,.statusArr)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, ..LocDesc(proLocId)_"未获取到可用退货审核流程")
                )
        }

        // ======================================
        // 6. 权限校验
        // ======================================
        Set sc = ##class(PHA.IN.RET.Data).CheckStatusPower(.statusArr, userId)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "流程权限错误:"_sc)
                )
        }

        // ======================================
        // 7. 加锁
        // ======================================
        Set sc = ..LockMain(retId)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "获取锁错误"_sc)
			)
        }

        // ======================================
        // 8. 推进流程
        // ======================================
        For i = 0:1:statusArr.%Size()-1 {
	        s status = statusArr.%Get(i)
            Set statusCode = status.code
			Set bindOperate = status.%Get("bindOperate")
			if bindOperate = "STK" {
				d retData.%Set("statusCode",statusCode)
		        /* 执行库存操作 */
		        Set sc = ##class(PHA.IN.RET.Biz).HandleAudit(retData)
			}else{
	            Set sc = ##class(PHA.IN.RET.Ref).HandleStatus(retId, statusCode, userId)
			}
            if ($$$phaIsError(sc)) {
		        Throw ##class(%Exception.StatusException).CreateFromStatus(
	            	$$$ERROR($$$GeneralError, "退货流程执行失败:"_statusCode_sc)
				)
	        }
        }

        TCommit
    }
    Catch ex {
        TRollback
        s result = ##class(PHA.COM.Err).LogErrors()
        Set sc = ex.AsStatus()
    }

    Do:($Data(retId)) ..LockMain(retId,"-")

    Quit sc
}

}
