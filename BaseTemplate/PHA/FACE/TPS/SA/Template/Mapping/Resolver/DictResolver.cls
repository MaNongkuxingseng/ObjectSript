Import sqlUser

Class PHA.FACE.TPS.SA.Template.Mapping.Resolver.DictResolver Extends %RegisteredObject
{

/// 缓存前缀
Parameter CACHEPREFIX = "FACE.TPS.DICT.";

/// =====================================================
/// Resolve
/// -----------------------------------------------------
/// 字典映射统一入口
/// 
/// @param value
///     SA 侧业务编码 / 代码 / 外部标识
/// 
/// @param params
///     动态参数对象，必须包含：
///     - params.dictType : 字典类型标识
/// 
/// @return %String
///     HIS 侧字典 ID（找不到时返回空字符串）
/// 
/// @throws
///     当 dictType 未配置时抛出异常
/// =====================================================
ClassMethod Resolve(value As %String, params As %DynamicObject = "") As %String
{
    // -------------------------
    // 1. 空值直接返回
    // -------------------------
    If (value = "") || (value = $c(0)) {
        Quit ""
    }
    
    // -------------------------
    // 2. 参数处理
    // -------------------------
    If '$IsObject(params) {
        Set params = {}
    }
    
    If 'params.%IsDefined("dictType") {
        Throw ##class(%Exception.General).%New(
            "DictResolver requires params.dictType",
            "DictResolver",
            5001,
            ,
            "必须指定字典类型(dictType)"
        )
    }

    Set dictType = params.dictType
    Set useCache = 0
    Set allowCreate = 0
    Set createUser = "FACE.TPS"
    
    If params.%IsDefined("useCache") {
        Set useCache = +params.%Get("useCache")
    }
    
    If params.%IsDefined("allowCreate") {
        Set allowCreate = +params.%Get("allowCreate")
    }
    
    If params.%IsDefined("createUser") {
        Set createUser = params.%Get("createUser")
    }

    // -------------------------
    // 3. 检查缓存
    // -------------------------
    If useCache {
        Set cacheKey = ..#CACHEPREFIX_dictType_":"_value
        Set cachedId = $Get(^CacheTemp(cacheKey))
        If cachedId '= "" {
            Quit cachedId
        }
    }

    // -------------------------
    // 4. 按字典类型分派
    // -------------------------
    Set hisId = ""
    
    Try {
        If dictType = "HIS_VENDOR" {
            Set hisId = ..ResolveVendor(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_LOC" {
            Set hisId = ..ResolveLoc(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_USER" {
            Set hisId = ..ResolveUser(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_UOM" {
            Set hisId = ..ResolveUom(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_MANF" {
            Set hisId = ..ResolveManf(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_DRUG" {
            Set hisId = ..ResolveDrug(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_OPER_TYPE" {
            Set hisId = ..ResolveOperType(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_DOSAGE_FORM" {
            Set hisId = ..ResolveDosageForm(value, allowCreate, createUser, .params)
        }
        ElseIf dictType = "HIS_ASPREASON" {
            Set hisId = ..ResolveAspReason(value, allowCreate, createUser, .params)
        }
        // 退货类型
        ElseIf dictType = "HIS_RETOPER_TYPE" {
            Set hisId = ..ResolveRetOperType(value, allowCreate, createUser, .params)
        }
        Else {
            // 未识别的字典类型
            Throw ##class(%Exception.General).%New(
                "Unknown DictType: "_dictType,
                "DictResolver",
                5002,
                ,
                "未知的字典类型"
            )
        }
    }
    Catch ex {
        // 记录错误日志
        // Do ..LogError("Resolve", dictType, value, ex.DisplayString())
        
        // 如果参数指定了默认值，使用默认值
        If params.%IsDefined("defaultValue") {
            Set hisId = params.defaultValue
        }
        Else {
            Set hisId = ""
        }
    }

    // -------------------------
    // 5. 缓存结果
    // -------------------------
    If (useCache && (hisId '= "")) {
        Set cacheKey = ..#CACHEPREFIX_dictType_":"_value
        Set ^CacheTemp(cacheKey) = hisId
        
        // 设置缓存超时时间（默认1小时）
        Set timeout = params.%Set("cacheTimeout", 3600)
        Set ^CacheTemp(cacheKey, "expire") = $Horolog + timeout
    }
    if (hisId = "") {
		If params.%IsDefined("defaultValue") {
	        Set hisId = params.defaultValue
	    }
    }
    Quit hisId
}

/// =====================================================
/// ResolveVendor
/// -----------------------------------------------------
/// 供应商字典映射
/// SA.vendor → HIS.vendorId
/// =====================================================
ClassMethod ResolveVendor(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按代码查询
    &sql(
        SELECT APCVM_RowId INTO :hisId 
        FROM APC_Vendor
        WHERE APCVM_Code = :code
           OR APCVM_Name = :code
    )
    
    // 方法2：如果没找到，尝试按助记码查询
    If SQLCODE '= 0 {
        &sql(
            SELECT APCVM_RowId INTO :hisId 
            FROM APC_Vendor
            WHERE APCVM_Acronym [ :code
        )
    }
    
    // 方法3：如果允许创建，创建新供应商
    If (SQLCODE '= 0) && allowCreate {
        Set hisId = ..CreateVendor(code, createUser, .params)
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveLoc
/// -----------------------------------------------------
/// 科室 / 库房映射
/// SA.rkloc → HIS.loc
/// =====================================================
ClassMethod ResolveLoc(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按代码查询
    &sql(
        SELECT CTLOC_RowId INTO :hisId 
        FROM CT_Loc
        WHERE CTLOC_Code = :code
    )
    
    // 方法2：按名称查询
    If SQLCODE '= 0 {
        &sql(
            SELECT CTLOC_RowId INTO :hisId 
            FROM CT_Loc
            WHERE CTLOC_Desc = :code
        )
    }
    
    // 方法3：按库房类型查询（如果是库房）
    If (SQLCODE '= 0) && $Data(params.locType) {
        Set locType = params.locType
        &sql(
            SELECT CTLOC_RowId INTO :hisId 
            FROM CT_Loc
            WHERE CTLOC_Desc = :code
              AND CTLOC_Type = :locType
        )
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveUser
/// -----------------------------------------------------
/// 人员工号映射
/// SA.cguser / zduser → HIS.userId
/// =====================================================
ClassMethod ResolveUser(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按工号查询
    &sql(
        SELECT SSUSR_RowId INTO :hisId 
        FROM SS_User
        WHERE SSUSR_Initials = :code
    )
    
    // 方法2：按姓名查询
    If SQLCODE '= 0 {
        &sql(
            SELECT SSUSR_RowId INTO :hisId 
            FROM SS_User
            WHERE SSUSR_Name = :code
        )
    }
    
    // 方法3：按身份证号查询
    If (SQLCODE '= 0) && $Data(params.idCard) {
        Set idCard = params.idCard
        &sql(
            SELECT SSUSR_RowId INTO :hisId 
            FROM SS_User
            WHERE SSUSR_ID = :idCard
        )
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveUom
/// -----------------------------------------------------
/// 单位映射
/// SA.uom → HIS.uomId
/// =====================================================
ClassMethod ResolveUom(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按描述查询（中文单位名）
    &sql(
        SELECT CTUOM_RowId INTO :hisId 
        FROM CT_UOM
        WHERE CTUOM_Desc = :code
    )
    
    // 方法2：按代码查询
    If SQLCODE '= 0 {
        &sql(
            SELECT CTUOM_RowId INTO :hisId 
            FROM CT_UOM
            WHERE CTUOM_Code = :code
        )
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveManf
/// -----------------------------------------------------
/// 生产企业映射
/// SA.manf → HIS.manfId
/// =====================================================
ClassMethod ResolveManf(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按企业代码查询
    &sql(
        SELECT PHMNF_RowId INTO :hisId 
        FROM PH_Manufacturer
        WHERE PHMNF_Code = :code
    )
    
    // 方法2：按企业名称查询
    If SQLCODE '= 0 {
        &sql(
            SELECT PHMNF_RowId INTO :hisId 
            FROM PH_Manufacturer
            WHERE PHMNF_Name = :code
        )
    }
    
    // 方法3：按GMP证书号查询
    If (SQLCODE '= 0) && $Data(params.gmpNo) {
        Set gmpNo = params.gmpNo
        &sql(
            SELECT PHMNF_RowId INTO :hisId 
            FROM PHC_Manufacturer
            WHERE PHMNF_GMPNo = :gmpNo
        )
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveDrug
/// -----------------------------------------------------
/// 药品映射
/// SA.incno → HIS.inci
/// =====================================================
ClassMethod ResolveDrug(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按代码查询（通用名代码）
    &sql(
        SELECT INCI_RowId INTO :hisId 
        FROM INC_Itm
        WHERE INCI_Code = :code
    )
    
    // 方法2：按INC_Desc查询
    If SQLCODE '= 0 {
        &sql(
            SELECT INCI_RowId INTO :hisId 
            FROM INC_Itm
            WHERE INCI_Desc = :code
        )
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveOperType
/// -----------------------------------------------------
/// 入库类型映射
/// SA.type → HIS.operType
/// 查询表：DHC_OperateType
/// 字段：IPT_RowId, IPT_Code, IPT_Desc, IPT_Type, IPT_Default
/// =====================================================
ClassMethod ResolveOperType(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 优先按代码精确查询
    &sql(
        SELECT IPT_RowId INTO :hisId 
        FROM DHC_OperateType
        WHERE IPT_Code = :code
           AND IPT_Type = 'I'  -- 入库类型
    )
    
    // 如果没找到，尝试按描述查询
    If SQLCODE '= 0 {
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE IPT_Desc = :code
              AND IPT_Type = 'I'  -- 入库类型
        )
    }
    
    // 如果还没找到，可以尝试模糊匹配常见的中文描述
    If (SQLCODE '= 0) && ($Length(code) > 2) {
        Set descPattern = "%"_code_"%"
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE (IPT_Desc LIKE :descPattern)
              AND IPT_Type = 'I'  -- 入库类型
        )
    }
    
    // 如果允许创建，创建新入库类型
    If (SQLCODE '= 0) && allowCreate {
        Set hisId = ..CreateOperType(code, createUser, .params)
    }
    
    // 如果参数中指定了默认值，并且未找到匹配项，则使用默认值
    If (hisId = "") && $IsObject(params) && params.%IsDefined("defaultOperType") {
        Set defaultCode = params.%Get("defaultOperType")
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE IPT_Code = :defaultCode
              AND IPT_Type = 'I'
        )
    }
    
    Quit hisId
}

/// =====================================================
/// CreateOperType
/// -----------------------------------------------------
/// 创建新入库类型
/// 表：DHC_OperateType
/// =====================================================
ClassMethod CreateOperType(code As %String, createUser As %String, ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 获取参数
    Set desc = $Get(params.desc, code)
    Set type = "I"  // 入库类型
    Set defaultFlag = $Get(params.defaultFlag, "N")
    
    // 检查是否已存在
    &sql(
        SELECT IPT_RowId INTO :hisId 
        FROM DHC_OperateType
        WHERE (IPT_Code = :code OR IPT_Desc = :desc)
          AND IPT_Type = 'I'
    )
    
    If SQLCODE = 0 {
        Quit hisId  // 已存在，返回现有ID
    }
    
    // 插入新记录
    Set updateDate = +$Horolog
    Set updateTime = $Piece($Horolog, ",", 2)
    
    &sql(
        INSERT INTO DHC_OperateType (
            IPT_Code,
            IPT_Desc,
            IPT_Type,
            IPT_Default
        )
        VALUES (
            :code,
            :desc,
            :type,
            :default
        )
    )
    
    If SQLCODE = 0 {
        Set hisId = %ROWID
    } ElseIf SQLCODE = -119 {  // 违反唯一约束，重新查询
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE IPT_Code = :code
              AND IPT_Type = 'I'
        )
    } Else {
        // 记录错误日志
        Set ^Temp("OperTypeError", $Horolog) = "SQLCODE: "_SQLCODE_" Message: "_%msg
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveRetOperType
/// -----------------------------------------------------
/// 退货类型映射
/// SA.type → HIS.operType
/// 查询表：DHC_OperateType
/// =====================================================
ClassMethod ResolveRetOperType(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 退货类型查询，IPT_Type = 'R' 表示退货类型
    &sql(
        SELECT IPT_RowId INTO :hisId 
        FROM DHC_OperateType
        WHERE IPT_Code = :code
           AND IPT_Type = 'R'  -- 退货类型
    )
    
    // 如果没找到，尝试按描述查询
    If SQLCODE '= 0 {
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE IPT_Desc = :code
              AND IPT_Type = 'R'  -- 退货类型
        )
    }
    
    // 如果还没找到，可以尝试模糊匹配
    If (SQLCODE '= 0) && ($Length(code) > 2) {
        Set descPattern = "%"_code_"%"
        &sql(
            SELECT IPT_RowId INTO :hisId 
            FROM DHC_OperateType
            WHERE (IPT_Desc LIKE :descPattern)
              AND IPT_Type = 'R'  -- 退货类型
        )
    }
    
    // 如果允许创建，创建新退货类型
    If (SQLCODE '= 0) && allowCreate {
        Set hisId = ..CreateRetOperType(code, createUser, .params)
    }
    
    Quit hisId
}

/// =====================================================
/// CreateRetOperType
/// -----------------------------------------------------
/// 创建新退货类型
/// 表：DHC_OperateType
/// IPT_Type = 'R' 表示退货类型
/// =====================================================
ClassMethod CreateRetOperType(code As %String, createUser As %String, ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 获取参数
    Set desc = $Get(params.desc, code)
    Set type = "R"  // 退货类型
    Set defaultFlag = $Get(params.defaultFlag, "N")
    Set stkType = $Get(params.stkType, "")  // 库存类型：G-药品，M-材料
    
    // 检查是否已存在
    &sql(
        SELECT IPT_RowId INTO :hisId 
        FROM DHC_OperateType
        WHERE (IPT_Code = :code OR IPT_Desc = :desc)
          AND IPT_Type = :type
    )
    
    If SQLCODE = 0 {
        Quit hisId  // 已存在，返回现有ID
    }
    
    Try {
        Set ^Temp("DHC_OperateType", "Retry", $Horolog) = "Retrying with basic insert"
        &sql(
            INSERT INTO DHC_OperateType (
                IPT_Code,
                IPT_Desc,
                IPT_Type,
                IPT_Default
            )
            VALUES (
                :code,
                :desc,
                :type,
                :defaultFlag
            )
        )
        
        If SQLCODE = 0 {
            Set hisId = %ROWID
        }
    }
    Catch ex {
        Set ^Temp("RetOperTypeError", $Horolog, "Retry") = ex.DisplayString()
    }
    
    Quit hisId
}

/// =====================================================
/// ResolveDosageForm
/// -----------------------------------------------------
/// 剂型映射
/// SA.dosageForm → HIS.phcdf
/// =====================================================
ClassMethod ResolveDosageForm(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    &sql(
        SELECT PHCDF_RowId INTO :hisId 
        FROM PHC_DrgForm
        WHERE PHCDF_Code = :code
           OR PHCDF_Desc1 = :code
           OR PHCDF_Desc2 = :code
    )
    
    Quit hisId
}

/// =====================================================
/// ResolveAspReason
/// -----------------------------------------------------
/// 调价原因字典映射
/// SA.reasonCode → HIS.reasonId
/// 表名：DHC_ReasonForAdjustPrice
/// 字段：REA_RowId, REA_Code, REA_Desc, REA_StkType, REA_ActiveFlag
/// =====================================================
ClassMethod ResolveAspReason(code As %String, allowCreate As %Boolean = 0, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    Set hisId = ""
    
    // 方法1：按代码精确查询（使用UPPER确保大小写不敏感）
    Set upperCode = $ZCVT(code, "U")
    &sql(
        SELECT REA_RowId INTO :hisId 
        FROM DHC_ReasonForAdjustPrice
        WHERE UPPER(REA_Code) = :upperCode
    )
    
    // 方法2：如果没找到，尝试按描述模糊查询
    If SQLCODE '= 0 {
        &sql(
            SELECT REA_RowId INTO :hisId 
            FROM DHC_ReasonForAdjustPrice
            WHERE REA_Desc = :code
               OR REA_Desc [ :code
        )
    }
    
    // 方法3：如果允许创建，创建新调价原因
    If (SQLCODE '= 0) && allowCreate {
        Set hisId = ..CreateAspReason(code, createUser, .params)
    }
    
    Quit hisId
}

/// =====================================================
/// CreateAspReason
/// -----------------------------------------------------
/// 创建新的调价原因
/// 表名：DHC_ReasonForAdjustPrice
/// =====================================================
ClassMethod CreateAspReason(code As %String, createUser As %String, ByRef params As %DynamicObject) As %String
{
	Q $$$OK
	
	/// 不允许新增
    Set hisId = ""
    Set desc = $Get(params.desc, code)
    Set stkType = $Get(params.stkType, "G")  // G-药品，M-材料，默认药品
    Set active = $Get(params.active, "Y")   // 默认激活
    
    &sql(
        INSERT INTO DHC_ReasonForAdjustPrice (
            REA_Code,
            REA_Desc,
            REA_StkType,
            REA_ActiveFlag,
            REA_UpdateDate,
            REA_UpdateTime,
            REA_UpdateUser
        )
        VALUES (
            :code,
            :desc,
            :stkType,
            :active,
            CONVERT(DATE, GETDATE()),
            CONVERT(TIME, GETDATE()),
            :createUser
        )
    )
    
    If SQLCODE = 0 {
        Set hisId = %ROWID
    } ElseIf SQLCODE = -119 {  // 违反唯一约束，重新查询
        Set upperCode = $ZCVT(code, "U")
        &sql(
            SELECT REA_RowId INTO :hisId 
            FROM DHC_ReasonForAdjustPrice
            WHERE UPPER(REA_Code) = :upperCode
        )
    } Else {
        // 记录错误日志
        Set ^Temp("AspReasonError", $Horolog) = "SQLCODE: "_SQLCODE_" Message: "_%msg
    }
    
    Quit hisId
}

/// =====================================================
/// CreateVendor
/// -----------------------------------------------------
/// 创建新供应商（如果需要）
/// =====================================================
ClassMethod CreateVendor(code As %String, createUser As %String = "", ByRef params As %DynamicObject) As %String
{
    // 这里应该是创建供应商的实际逻辑
    // 由于涉及业务逻辑复杂，这里只提供框架
    
    Set vendorName = $Get(params.vendorName, code)
    Set vendorType = $Get(params.vendorType, "N")  // N-普通
    
    /*
    // 示例代码：
    Set newVendorId = $Increment(^APC("APCVM",0))
    Set ^APC("APCVM",newVendorId) = vendorName
    Set ^APC("APCVM",newVendorId,"Code") = code
    Set ^APC("APCVM",newVendorId,"Type") = vendorType
    Set ^APC("APCVM",newVendorId,"User") = createUser
    Set ^APC("APCVM",newVendorId,"Date") = +$Horolog
    Set ^APC("APCVM",newVendorId,"Time") = $Piece($Horolog,",",2)
    
    Quit newVendorId
    */
    
    Quit ""  // 默认不创建，返回空
}

/// =====================================================
/// LogError
/// -----------------------------------------------------
/// 记录错误日志
/// =====================================================
ClassMethod LogError(method As %String, dictType As %String, value As %String, errorMsg As %String) As %Status
{
    // 记录到日志表或^CacheTemp
    Set logId = $Increment(^CacheTemp("FACE.TPS.DICT.ERROR"))
    Set ^CacheTemp("FACE.TPS.DICT.ERROR", logId) = $ZDateTime($Horolog, 3)
    Set ^CacheTemp("FACE.TPS.DICT.ERROR", logId, "Method") = method
    Set ^CacheTemp("FACE.TPS.DICT.ERROR", logId, "DictType") = dictType
    Set ^CacheTemp("FACE.TPS.DICT.ERROR", logId, "Value") = value
    Set ^CacheTemp("FACE.TPS.DICT.ERROR", logId, "Error") = errorMsg
    
    // 同时输出到控制台（开发环境）
    Write !,"[DictResolver Error] ",method,":",dictType,"=",value," -> ",errorMsg
    
    Quit $$$OK
}

/// =====================================================
/// ClearCache
/// -----------------------------------------------------
/// 清除字典缓存
/// 
/// @param dictType
///     字典类型，为空则清除所有
/// =====================================================
ClassMethod ClearCache(dictType As %String = "") As %Status
{
    If dictType = "" {
        Kill ^CacheTemp($Extract(..#CACHEPREFIX,1,*-1))  // 清除所有FACE.TPS.DICT.*
    }
    Else {
        Kill ^CacheTemp(..#CACHEPREFIX_dictType)
    }
    
    Quit $$$OK
}

/// =====================================================
/// Test
/// -----------------------------------------------------
/// 测试方法	w ##class(PHA.FACE.TPS.SA.Template.Mapping.Resolver.DictResolver).Test()
/// =====================================================
ClassMethod Test() As %Status
{
    Write !,"=== DictResolver 测试 ==="
    
    // 测试1：单位转换
    Set params = {"dictType": "HIS_UOM"}
    Write !,"盒 -> ",..Resolve("盒", params)
    Write !,"瓶 -> ",..Resolve("瓶", params)
    Write !,"未知单位 -> ",..Resolve("未知单位", params)
    
    // 测试2：入库类型
    Set params = {"dictType": "HIS_OPER_TYPE"}
    Write !,!,"正常入库 -> ",..Resolve("正常入库", params)
    Write !,"政府采购 -> ",..Resolve("政府采购", params)
    
    // 测试3：带缓存的查询
    Set params = {"dictType": "HIS_UOM", "useCache": 1}
    Write !,!,"带缓存查询盒: "
    Set start = $ZTimestamp
    For i=1:1:100 {
        Set result = ..Resolve("盒", params)
    }
    Set end = $ZTimestamp
    Write result," (耗时:",$Number((end-start)*1000,0),"ms)"
    
    // 测试4：清除缓存
    Write !,!,"清除缓存..."
    Do ..ClearCache("HIS_UOM")
    
    Quit $$$OK
}

}
