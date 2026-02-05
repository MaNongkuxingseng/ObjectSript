Class PHA.FACE.TPS.SA.INAdj.Method Extends (PHA.IN.ADJ.Base, PHA.COM.Data.Base)
{

/// 执行全部库存调整审核流程
/// w ##class(PHA.FACE.TPS.SA.INRec.Method).AutoAuditCore()
ClassMethod AutoAuditCore(retData As %DynamicObject) As %Status
{
    #dim statusArr As %DynamicArray = []
	s adjId = retData.%Get("adjId")
	s userId = retData.%Get("adjUserDr")
    TStart
    Try {
        // ======================================
        // 1. 基础上下文
        // ======================================
        Set proLocId = retData.adjLocId

        // ======================================
        // 2. 状态校验
        // ======================================
        Set statusObj = ##class(PHA.IN.ADJ.Ref).GetCurrentStatus(proLocId,adjId)
        If statusObj.code '= "SAVE" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "调整单为"_statusObj.desc_"状态，不允许审核")
                )
        }

        // ======================================
        // 5. 获取流程路径
        // ======================================
        Set sc = ##class(PHA.IN.ADJ.Data).GetStatusList("SAVE","AUDIT",proLocId,.statusArr)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, ..LocDesc(proLocId)_"未获取到可用退货审核流程")
                )
        }

        // ======================================
        // 6. 权限校验
        // ======================================
        Set sc = ##class(PHA.IN.ADJ.Data).CheckStatusPower(.statusArr, userId)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "流程权限错误:"_sc)
                )
        }

        // ======================================
        // 7. 加锁
        // ======================================
        Set sc = ..LockAdj(adjId)
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
				d retData.%Set("adjStatus",statusCode)
		        /* 执行库存操作 */
		        Set statusRet = ##class(PHA.IN.ADJ.Biz).Audit(retData)
		        if (statusRet.code'=0) {
			        Throw ##class(%Exception.StatusException).CreateFromStatus(
		            	$$$ERROR($$$GeneralError, "退货流程执行失败:"_statusCode_statusRet.%ToJSON())
					)
		        }
			}else{
	            Set statusRet = ##class(PHA.IN.ADJ.Biz).SaveProcess(adjId, userId, statusCode)
		        if ($$$phaIsError(statusRet)) {
			        Throw ##class(%Exception.StatusException).CreateFromStatus(
		            	$$$ERROR($$$GeneralError, "退货流程执行失败:"_statusCode_statusRet)
					)
		        }
			}
            
        }

        TCommit
    }
    Catch ex {
        TRollback
        s result = ##class(PHA.COM.Err).LogErrors()
        Set sc = ex.AsStatus()
    }

    Do:($Data(adjId)) ..UnLockAdj(adjId)

    Quit $$$OK
}

}
