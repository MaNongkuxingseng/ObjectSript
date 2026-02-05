/// 处理入库业务的其他方法
Class PHA.FACE.TPS.SA.INRec.Method Extends PHA.IN.REC.Base
{

/// 执行全部入库审核流程
/// w ##class(PHA.FACE.TPS.SA.INRec.Method).AutoAuditCore()
ClassMethod AutoAuditCore(recData As %DynamicObject) As %Status
{
    #dim sc As %Status = $$$OK
    #dim statusArr As %DynamicArray = []
	s recId = recData.%Get("recID")
	s userId = recData.%Get("createUser")
    TStart
    Try {
        // ======================================
        // 1. 基础上下文
        // ======================================
        Set proLocId = ##class(PHA.IN.REC.Data).GetLoc(recId)

        // ======================================
        // 2. 状态校验
        // ======================================
        Set statusObj = ##class(PHA.IN.REC.Ref).GetCurrentStatus(recId)
        If statusObj.code '= "COMP" {
            Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "入库单为"_statusObj.desc_"状态，不允许审核")
                )
        }

        // ======================================
        // 5. 获取流程路径
        // ======================================
        Set sc = ##class(PHA.IN.REC.Data).GetStatusList("COMP","AUDIT",proLocId,.statusArr)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, ..LocDesc(proLocId)_"未获取到可用入库审核流程")
                )
        }

        // ======================================
        // 6. 权限校验
        // ======================================
        Set sc = ##class(PHA.IN.REC.Data).CheckStatusPower(.statusArr, userId)
        if ($$$phaIsError(sc)) {
	        Throw ##class(%Exception.StatusException).CreateFromStatus(
            	$$$ERROR($$$GeneralError, "流程权限错误:"_sc)
                )
        }

        // ======================================
        // 7. 加锁
        // ======================================
        Set sc = ..LockMain(recId)
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
				d recData.%Set("statusCode",statusCode)
		        /* 执行库存操作 */
		        Set sc = ##class(PHA.IN.REC.Biz).HandleAudit(recData)
			}else{
	            Set sc = ##class(PHA.IN.REC.Ref).HandleStatus(recId, statusCode, userId)
			}
            if ($$$phaIsError(sc)) {
		        Throw ##class(%Exception.StatusException).CreateFromStatus(
	            	$$$ERROR($$$GeneralError, "入库流程执行失败:"_sc)
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

    Do:($Data(recId)) ..LockMain(recId,"-")

    Quit sc
}

}
