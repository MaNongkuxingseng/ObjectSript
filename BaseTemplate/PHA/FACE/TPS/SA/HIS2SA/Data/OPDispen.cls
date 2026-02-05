/// 门诊发药取数据
Class PHA.FACE.TPS.SA.HIS2SA.Data.OPDispen Extends PHA.COM.Data.Base
{

/// 获取门诊西药发药数据
/// w ##class(PHA.FACE.TPS.SA.HIS2SA.Data.OPDispen).GetPrescDispDetail(281)
ClassMethod GetPrescDispDetail(phd As %String) As %DynamicArray
{
    Quit:(phd="") "-1^发药单号不能为空"

    
    Set result = ..Msg(0,,{})

    Set main = ..GetPrescMain(phd)
    Quit:'$IsObject(main) ..Msg(-1,main)

	Set fyFlag = $Piece(^DHCPHDISP(phd),"^",4)
    Kill dispMap
    If (fyFlag = 1) {
        Do ..GetDispDetailByPHD(phd,.dispMap)
    } Else {
        Do ..GetDispDetailByDSP(phd,.dispMap)
    }
    Set detail = ..BuildDispDetailArray(.dispMap)

    Do result.data.%Set("main", main)
    Do result.data.%Set("detail", detail)

    Quit result
}

/// 获取门诊处方主信息
ClassMethod GetPrescMain(phd As %String) As %DynamicObject
{
    Quit:(phd="") "-1^发药单号不能为空"

    Set prescNo = $Piece(^DHCPHDISP(phd,2),"^",1)
    Quit:(prescNo="") "-1^未找到处方号"

    // 药房
    Set phaLocId = $Piece(##class(PHA.OP.COM.Method).GetPrescRecLoc(prescNo),"^",2)
    Set phaLocDesc = ..LocCode(phaLocId)

    // 患者
    Set admDr = ##class(PHA.OP.COM.Method).GetAdmIdByPresc(prescNo)
    Set patInfo = ##class(PHA.OP.COM.Method).GetPatInfo(prescNo)

    // 医生
    Set oeori = ##class(PHA.HERB.Com.Data).GetOrdItmByPrescNo(prescNo)
    Set doctorName = $Piece(##class(PHA.COM.Order).OeoriDoctor(oeori),"^",2)
    Set deptName   = $Piece(##class(PHA.COM.Order).GetOrdDocLoc(oeori),"^",2)

    Set obj = {}
    Do obj.%Set("prescNo", prescNo)
    Do obj.%Set("patientName", $Piece(patInfo,"^",3))
    Do obj.%Set("patientSex",  $Piece(patInfo,"^",4))
    Do obj.%Set("patientAge",  $Piece(patInfo,"^",5))
    Do obj.%Set("patientMedNo",$Piece(patInfo,"^",1))
    Do obj.%Set("doctorName", doctorName)
    Do obj.%Set("deptName", deptName)
    Do obj.%Set("prescTime", ##class(PHA.COM.Order).OeoriDateTime(oeori))
    Do obj.%Set("hospitalName", ..HospDesc(..HospIdByLoc(phaLocId)))
    Do obj.%Set("phaLocDesc", phaLocDesc)
    Do obj.%Set("dataSource", "HIS")

    Quit obj
}

/// 从 PHD 发药明细取数（已完成发药）
ClassMethod GetDispDetailByPHD(phd As %String, ByRef dispMap)
{
    Set phdCh=0
    For {
        Set phdCh=$Order(^DHCPHDI(phd,"PHDI",phdCh))
        Quit:phdCh=""

        Set phdSub=0
        For {
            Set phdSub=$Order(^DHCPHDI(phd,"PHDI",phdCh,"INCLB",phdSub))
            Quit:phdSub=""

            Set row = ^DHCPHDI(phd,"PHDI",phdCh,"INCLB",phdSub)

            Set inclb = $Piece(row,"^",3)
            Set qty   = $Piece(row,"^",1)
            Set inciId= +inclb

            Quit:(inclb="")!(inciId=0)

            Set key = inciId_"^"_inclb

            If '$Data(dispMap(key)) {
                Set dispMap(key,"inciId") = inciId
                Set dispMap(key,"inclb")  = inclb
                Set dispMap(key,"qty")    = qty
            } Else {
                Set dispMap(key,"qty") = dispMap(key,"qty") + qty
            }
        }
    }
}

/// 从医嘱发药数量表取数
ClassMethod GetDispDetailByDSP(phd As %String, ByRef dispMap)
{
    Set phdCh=0
    For {
        Set phdCh=$Order(^DHCPHDI(phd,"PHDI",phdCh))
        Quit:phdCh=""

        Set oeori = $Piece(^DHCPHDI(phd,"PHDI",phdCh),"^",5)
        Quit:oeori=""

        Set dspId = $Order(^DHCOEDISQTY(0,"OEORI",oeori,""))
        Quit:dspId=""

        Set dspSub=0
        For {
            Set dspSub=$Order(^DHCOEDISQTY(dspId,"I",dspSub))
            Quit:dspSub=""

            Set row = ^DHCOEDISQTY(dspId,"I",dspSub)

            Set inclb = $Piece(row,"^",1)
            Set qty   = $Piece(row,"^",2)
            Set inciId= +$Piece(row,"^",5)

            Quit:(inclb="")!(inciId=0)

            Set key = inciId_"^"_inclb

            If '$Data(dispMap(key)) {
                Set dispMap(key,"inciId") = inciId
                Set dispMap(key,"inclb")  = inclb
                Set dispMap(key,"qty")    = qty
            } Else {
                Set dispMap(key,"qty") = dispMap(key,"qty") + qty
            }
        }
    }
}

/// 构建发药明细返回数组
ClassMethod BuildDispDetailArray(ByRef dispMap) As %DynamicArray
{
    Set arr=[]
    Set key="",idx=0

    For {
        Set key=$Order(dispMap(key))
        Quit:key=""

        Set idx=idx+1
        Set inciId = dispMap(key,"inciId")
        Set inclb  = dispMap(key,"inclb")
        Set qty    = dispMap(key,"qty")

        Set drug = ##class(PHA.COM.Data.Drug).%New(inciId)

        Set obj={}
        Do obj.%Set("seq", idx)
        Do obj.%Set("drugCode", drug.Code())
        Do obj.%Set("drugName", drug.Desc())
        Do obj.%Set("uomDesc", ..UomDesc(drug.BUomId()))
        Do obj.%Set("qty", qty)
        
        // 批次信息
        Do obj.%Set("inclb", inclb)
        Set incldData = ##class(PHA.IN.TRANS.Data).GetInclbData(inclb,drug.BUomId(),{})
		Do obj.%Set("batNo", incldData."batNo")
		Do obj.%Set("expDate", incldData."expDate")

        Do arr.%Push(obj)
    }

    Quit arr
}

}
