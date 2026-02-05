/// Template 批次分配工具
Class PHA.FACE.TPS.SA.Template.Service.InclbAllocateService Extends %RegisteredObject
{

/// Description : 按效期优先 / FIFO 规则匹配本次出库批次（支持指定批号）
/// Author      : Valen MPF
/// Date        : 2025-12-31
/// Input       : inclbList(ByRef) 批次分配结果
///               locId   科室ID
///               inci    药品库存项
///               qty     需求数量
///               batNoFilter 指定批号（为空表示不限制）
/// Output      : %String 错误信息，成功返回空串
ClassMethod Allocate(ByRef inclbList, locId As %String, inci As %String, qty As %String, batNoFilter As %String = "") As %Library.String
{
	#dim result As %String = ""

	k inclbList
	k GetInclbForTransferDATA

	// -----------------------------
	// 1. 基础校验
	// -----------------------------
	q:'$d(^INCI("IL_LOC", locId, inci)) "无科室库存项"

	s hospId = $p($g(^CTLOC(locId)), "^", 22)           ; 医院ID(hospital id)
	s appPropObj = ##class(PHA.IN.TRANS.Ref).GetParamP("^^^"_hospId)            ; 应用参数(application property)

	s newQty = qty                                     ; 剩余待分配数量
	s inclb = 0

	// -----------------------------
	// 2. 扫描库存批次
	// -----------------------------
	for {
		s inclb = $o(^DHCINCLBi("ACISTKBT", "Y", locId, inci, inclb))
		q:(inclb = "")

		s il = $p(inclb, "||", 2)                        ; 库存层级ID(IL)
		s lb = $p(inclb, "||", 3)                        ; 批次层级ID(LB)

		continue:'$d(^INCI(inci, "IL", il, "LB", lb))

		s incib = $p(^INCI(inci, "IL", il, "LB", lb), "^", 1)
		s itm   = $p(incib, "||", 2)
		s incibData = ^INCI(inci, "IB", itm)

		s batNo   = $p(incibData, "^", 1)                ; 批号(batch no)
		s expDate = +$p(incibData, "^", 2)               ; 有效期(expire date)

		// -----------------------------
		// 2.1 批号严格过滤（核心改造点）
		// -----------------------------
		if (batNoFilter '= "") && (batNo '= batNoFilter) {
			continue                                   ; 非指定批号，直接跳过
		}

		// -----------------------------
		// 2.2 有效期校验
		// -----------------------------
		q:(appPropObj.ExpLimitFlag = "Y")&&(expDate '= 0)&&(expDate <= +$h)

		// -----------------------------
		// 2.3 库存数量校验
		// -----------------------------
		s inclbObj = ##class(PHA.COM.Data.INCLB).%New(inclb)
		s stockQty = inclbObj.GetQty()                   ; 总库存
		s resQty   = inclbObj.GetResQty()                ; 预留库存
		s avaQty   = inclbObj.GetAvaQty()                ; 可用库存
		s dirtyQty = inclbObj.GetDirtyQty()              ; 污染库存

		continue:(avaQty <= 0)

		// -----------------------------
		// 2.4 批次排序辅助字段
		// -----------------------------
		s data = batNo_"^"_stockQty_"^"_expDate_"^"_inclb_"^"_resQty_"^"_avaQty

		s (dateAdd, timeAdd) = 0
		s dhcIncib = $o(^DHCINCIB(0, "INCIB", incib, ""))
		if dhcIncib'="" {
			s dhcIncibData = $g(^DHCINCIB(dhcIncib))
			s dateAdd = +$p(dhcIncibData, "^", 10)
			s timeAdd = +$p(dhcIncibData, "^", 11)
		}

		// -----------------------------
		// 2.5 排序策略
		// -----------------------------
		if (appPropObj.SeekBatMethod = 0) {
			s index1 = +expDate                         ; 有效期优先
			s index2 = dateAdd
			s index3 = timeAdd
		}
		else {
			s index1 = +dateAdd                         ; FIFO
			s index2 = timeAdd
			s index3 = expDate
		}

		s inclbIndex = +$replace(inclb, "||", "")
		s GetInclbForTransferDATA(index1, index2, index3, inclbIndex) = data
	}

	q:'$d(GetInclbForTransferDATA) "无有效批次"

	// -----------------------------
	// 3. 按排序规则分配数量
	// -----------------------------
	s inclbCnt = 0
	s index1 = ""

	for {
		s index1 = $o(GetInclbForTransferDATA(index1))
		q:(index1 = "")||(newQty = 0)

		s index2 = ""
		for {
			s index2 = $o(GetInclbForTransferDATA(index1, index2))
			q:(index2 = "")||(newQty = 0)

			s index3 = ""
			for {
				s index3 = $o(GetInclbForTransferDATA(index1, index2, index3))
				q:(index3 = "")||(newQty = 0)

				s inclbIndex = ""
				for {
					s inclbIndex = $o(GetInclbForTransferDATA(index1, index2, index3, inclbIndex))
					q:(inclbIndex = "")||(newQty = 0)

					s inclbCnt = inclbCnt + 1
					s data = GetInclbForTransferDATA(index1, index2, index3, inclbIndex)
					s inclbList(inclbCnt) = data

					s avaQty = $p(data, "^", 6)
					continue:(avaQty <= 0)

					if (avaQty >= newQty) {
						s $p(inclbList(inclbCnt), "^", 7) = newQty   ; 本批次分配量
						s newQty = 0
					}
					else {
						s $p(inclbList(inclbCnt), "^", 7) = avaQty
						s newQty = newQty - avaQty
					}
				}
			}
		}
	}

	q ""
}

}
