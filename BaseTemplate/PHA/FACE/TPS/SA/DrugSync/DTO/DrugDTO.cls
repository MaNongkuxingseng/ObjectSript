Class PHA.FACE.TPS.SA.DrugSync.DTO.DrugDTO Extends (%RegisteredObject, %XML.Adaptor)
{

/// Author: valen MPF
/// Created: 2025-11-28
/// Description:
///   DTO containing SA interface fields and HIS ARCIM/INCI JSON fields.
///   SA fields are the original incoming parameters; HIS fields named per bascidrugjson.
/// 
/// Notes:
///  - Fields are grouped and commented to avoid duplicates.
///  - Comments use Chinese short descriptions for quick reference.
/// ////////// SA interface fields (input from SA) /////////////
/// SA接口字段开始 //////////
/// 建议零售价
Property AdvsalePrice As %String;

/// 企业编号（药品字典共用，考虑新增、更新操作）
Property CompId As %String;

/// 生产企业编号
Property FactoryId As %String;

/// 生产企业描述
Property FactoryName As %String;

/// 建档日期
Property InitTime As %String;

/// 建档人
Property InitUser As %String;

/// 医保标识
Property IsInsurance As %String;

/// 最终修改人
Property LastModify As %String;

/// 最终修改时间
Property LastTime As %String;

/// 每件数量（一件 100 盒）
Property MaxQty As %String;

/// 中包装数量（一板）
Property MidQty As %String;

/// 商品单位（入库单位，盒，瓶）
Property WareUnit As %String;

/// 批零比率（商品单位与拆零单位的转化关系）
Property MinQty As %String;

/// 拆零单位（是否小单位，如片，粒）
Property MinUnit As %String;

/// 销售积分
Property Pile As %String;

/// 采购状态
Property PurStatus As %String;

/// 销售状态
Property SaleStatus As %String;

/// 销项税率
Property SaleTax As %String;

/// 启用状态（对应 his 的不可用标记）
Property Status As %String;

/// 商品助记码
Property WareAbc As %String;

/// 商品编码
Property WareCode As %String;

/// 商品完整名称
Property WareName As %String;

/// 通用名
Property WaregeneralName As %String;

/// 商品性质（1：正常商品，2：捆绑商品，3：联营商品）
Property WareKind As %String;

/// 商品规格
Property WareSpec As %String;

/// 失效天数
Property WarningDays As %String;

/// 产地编码
Property AreaCode As %String;

/// 产地描述
Property AreaName As %String;

/// 商品条码
Property BarCode As %String;

/// 外部标识
Property ExtNo As %String;

/// 批准文号
Property FileNo As %String;

/// 上市许可持有人
Property ListingHolder As %String;

/// 拆零条码
Property MinBarcode As %String;

/// 最小出库数量
Property MinOutQty As %String;

/// 备注
Property Notes As %String;

/// 小规模纳税人税率
Property PurTaxX As %String;

/// 一般纳税人税率
Property PurTaxY As %String;

/// 是否扫码
Property ScanFlag As %String;

/// 贮存条件
Property StoreReq As %String;

/// 商品大类
Property WareType As %String;

/// 化学成分
Property ChemElement As %String;

/// 化学名
Property ChemName As %String;

/// 双人验收-复核商品
Property DoubleCheck As %String;

/// 功效
Property Efficacy As %String;

/// 说明书
Property Instructions As %String;

/// 主要成份
Property MainElement As %String;

/// 养护类型
Property MaintainType As %String;

/// 药学分类代码(HIS 需要字段，海典需新增)
Property PHCCCode As %String;

/// 药学分类描述(HIS 需要字段，海典需新增)
Property PHCCCat As %String;

/// 品种通用名代码(HIS 需要字段，海典需新增)
Property HisPhisId As %String;

/// 品种通用名称(HIS 需要字段，海典需新增)
Property HisPhis As %String;

/// 处方通用名代码(HIS 需要字段，海典需新增)
Property HisChisId As %String;

/// 处方通用名(HIS 需要字段，海典需新增)
Property HisChis As %String;

/// 处方通用名别名(HIS 需要字段，海典需新增)
Property HisChisBM As %String;

/// 剂型代码(字典)
Property YPJXCode As %String;

/// 剂型描述(字典)
Property YPJXName As %String;

/// 最大量(有业务要求，海典需新增)
Property HisZDL As %String;

/// 极限用量(有业务要求，海典需新增)
Property Hisjxyl As %String;

/// 单次最大剂量(有业务要求，海典需新增)
Property Hisdczdjl As %String;

/// 每日最大剂量(有业务要求，海典需新增)
Property Hismrzdjl As %String;

/// 类组代码
Property scSGCode As %String;

/// 类组描述
Property scSGDesc As %String;

/// 库存分类代码（与类组是上下级关系），两边维护成一致
Property scSCCode As %String;

/// 库存分类描述
Property scSCDesc As %String;

/// 医嘱开始日期（yyyy-mm-dd）
Property ARCIMEffDate As %String;

/// 医嘱结束日期（yyyy-mm-dd）
Property ARCIMEffDateTo As %String;

/// 医嘱项大类，建议两边维护成一致
Property ORCATCode As %String;

/// 医嘱项子类，建议两边维护成一致
Property ARCICCode As %String;

/// 账单子类
Property ARCSGCode As %String;

/// 收费子类
Property TARSCCode As %String;

/// 住院子类
Property TARICCode As %String;

/// 门诊子类
Property TAROCCode As %String;

/// 核算子类
Property TARECCode As %String;

/// 会计子类
Property TARACCode As %String;

/// 病案子类
Property TARMCCode As %String;

/// 新病案首页子类
Property NTARMCCode As %String;

/// 基本药物标志(Y/N)
Property INFOBasicDrug As %String;

/// 进口标志(国产/进口/合资)
Property INFOImportFlag As %String;

/// 效期要求（要求/不要求）
Property YPXQ As %String;

/// 更新标识（add：新增；update：修改）
Property UpdateFlag As %String;

/// HIS INCI字段开始 //////////
/// inciArcim
Property inciArcim As %String;

/// inci
Property inci As %String;

/// inciCode
Property inciCode As %String;

/// inciDesc
Property inciDesc As %String;

/// inciBUom基本单位
Property inciBUom As %String;

/// inciPUom
Property inciPUom As %String;

/// inciPUom4TCode
Property inciPUom4TCode As %String;

/// inciOutUom
Property inciOutUom As %String;

/// inciInUom
Property inciInUom As %String;

/// inciStkCat
Property inciStkCat As %String;

/// inciBookCat
Property inciBookCat As %String;

/// inciExpReq
Property inciExpReq As %String;

/// inciExpLen
Property inciExpLen As %String;

/// inciManf
Property inciManf As %String;

/// inciSpec
Property inciSpec As %String;

/// inciOrigin
Property inciOrigin As %String;

/// inciMarkType
Property inciMarkType As %String;

/// inciRp
Property inciRp As %String;

/// inciSp
Property inciSp As %String;

/// inciMaxSp
Property inciMaxSp As %String;

/// inciPriceDate
Property inciPriceDate As %String;

/// inciPrcFile
Property inciPrcFile As %String;

/// inciPrcFileDate
Property inciPrcFileDate As %String;

/// inciBarCode
Property inciBarCode As %String;

/// inciStandardCode
Property inciStandardCode As %String;

/// inciImport
Property inciImport As %String;

/// inciComeFrom
Property inciComeFrom As %String;

/// inciQualityNo
Property inciQualityNo As %String;

/// inciQualityLev
Property inciQualityLev As %String;

/// inciInMedBasis
Property inciInMedBasis As %String;

/// inciDrugUse
Property inciDrugUse As %String;

/// inciPackUom
Property inciPackUom As %String;

/// inciPackUomFac
Property inciPackUomFac As %String;

/// inciReportingDays
Property inciReportingDays As %String;

/// inciRRReason
Property inciRRReason As %String;

/// inciPurPlanCode
Property inciPurPlanCode As %String;

/// dmDrugIdByself
Property dmDrugIdByself As %String;

/// inciRemark1
Property inciRemark1 As %String;

/// inciRemark2
Property inciRemark2 As %String;

/// inciBAFlag
Property inciBAFlag As %String;

/// inciCentralPur
Property inciCentralPur As %String;

/// inciNegoFlag
Property inciNegoFlag As %String;

/// inciInHosp
Property inciInHosp As %String;

/// inciRecFlag
Property inciRecFlag As %String;

/// inciSHCentPurFlag
Property inciSHCentPurFlag As %String;

/// inciSkinTest
Property inciSkinTest As %String;

/// inciEasyConfuse
Property inciEasyConfuse As %String;

/// inciEdible
Property inciEdible As %String;

/// inciTemPurchase
Property inciTemPurchase As %String;

/// inciHighPrice
Property inciHighPrice As %String;

/// inciWholeDispFlag
Property inciWholeDispFlag As %String;

/// incPropNoTraceCode
Property incPropNoTraceCode As %String;

/// inciOrdEdDate
Property inciOrdEdDate As %String;

/// inciNotUse
Property inciNotUse As %String;

/// inciNotUseRea
Property inciNotUseRea As %String;

/// tarCode
Property tarCode As %String;

/// tarDesc
Property tarDesc As %String;

/// tarMCCateNew
Property tarMCCateNew As %String;

/// tarMCCate
Property tarMCCate As %String;

/// tarOutpatCate
Property tarOutpatCate As %String;

/// tarInpatCate
Property tarInpatCate As %String;

/// tarEMCCate
Property tarEMCCate As %String;

/// tarAcctCate
Property tarAcctCate As %String;

/// tarSubCate
Property tarSubCate As %String;

/// tarInsuCode
Property tarInsuCode As %String;

/// tarInsuDesc
Property tarInsuDesc As %String;

/// inciPbFlag
Property inciPbFlag As %String;

/// inciPbVendor
Property inciPbVendor As %String;

/// inciPbLevel
Property inciPbLevel As %String;

/// inciPbManf
Property inciPbManf As %String;

/// inciPbList
Property inciPbList As %String;

/// inciPbCarrier
Property inciPbCarrier As %String;

/// inciPbRp
Property inciPbRp As %String;

/// HIS ARCIM字段开始 //////////
/// arci
Property arci As %String;

/// phcGene
Property phcGene As %String;

/// arcimCode
Property arcimCode As %String;

/// arcimDesc
Property arcimDesc As %String;

/// arcimOrdCat
Property arcimOrdCat As %String;

/// arcimItemCat
Property arcimItemCat As %String;

/// arcimBillGrp
Property arcimBillGrp As %String;

/// arcimBillSub
Property arcimBillSub As %String;

/// arcimPri
Property arcimPri As %String;

/// arcimNoOfCumDays
Property arcimNoOfCumDays As %String;

/// arcimMaxQty
Property arcimMaxQty As %String;

/// arcimWarnQty
Property arcimWarnQty As %String;

/// arcimMaxCumDose
Property arcimMaxCumDose As %String;

/// arcimMaxQtyDay
Property arcimMaxQtyDay As %String;

/// arcimPartialValue
Property arcimPartialValue As %String;

/// arcimOPPartialValue
Property arcimOPPartialValue As %String;

/// arcimStDate
Property arcimStDate As %String;

/// arcimEdDate
Property arcimEdDate As %String;

/// arcimOEMsg
Property arcimOEMsg As %String;

/// arcimOwn
Property arcimOwn As %String;

/// arcimWoStock
Property arcimWoStock As %String;

/// arcimFree
Property arcimFree As %String;

/// arcimOP
Property arcimOP As %String;

/// arcimEM
Property arcimEM As %String;

/// arcimIP
Property arcimIP As %String;

/// arcimHP
Property arcimHP As %String;

/// phcIPOneDay
Property phcIPOneDay As %String;

/// arcimCMAllowDecimal
Property arcimCMAllowDecimal As %String;

/// phcUom
Property phcUom As %String;

/// phcSpec
Property phcSpec As %String;

/// phcPoison
Property phcPoison As %String;

/// phcFreq
Property phcFreq As %String;

/// phcInstuc
Property phcInstuc As %String;

/// phcDura
Property phcDura As %String;

/// phcHighRisk
Property phcHighRisk As %String;

/// phcOTC
Property phcOTC As %String;

/// phcLabel21
Property phcLabel21 As %String;

/// phcLabel22
Property phcLabel22 As %String;

/// phcLabel1
Property phcLabel1 As %String;

/// phcSpeed
Property phcSpeed As %String;

/// phcWHODDD
Property phcWHODDD As %String;

/// phcWHODDDUom
Property phcWHODDDUom As %String;

/// phcDDD
Property phcDDD As %String;

/// phcWHONET
Property phcWHONET As %String;

/// phcAntiLevel
Property phcAntiLevel As %String;

/// phcCHSpec
Property phcCHSpec As %String;

/// phcGranulesFac
Property phcGranulesFac As %String;

/// phcBaseDrug
Property phcBaseDrug As %String;

/// phcBaseDrugPro
Property phcBaseDrugPro As %String;

/// phcBaseDrugCity
Property phcBaseDrugCity As %String;

/// phcBaseDrugCou
Property phcBaseDrugCou As %String;

/// phcOPOneDay
Property phcOPOneDay As %String;

/// phcOPSkin
Property phcOPSkin As %String;

/// phcIPSkin
Property phcIPSkin As %String;

/// phcCodeX
Property phcCodeX As %String;

/// phcProComm
Property phcProComm As %String;

/// phcTest
Property phcTest As %String;

/// phcTPN
Property phcTPN As %String;

/// phcAnti
Property phcAnti As %String;

/// phcCritical
Property phcCritical As %String;

/// phcMonitor
Property phcMonitor As %String;

/// phcSingle
Property phcSingle As %String;

/// phcChemotherapeutic
Property phcChemotherapeutic As %String;

/// phcDietTaboo
Property phcDietTaboo As %String;

/// phcTumble
Property phcTumble As %String;

/// phcDope
Property phcDope As %String;

/// phcAllergy
Property phcAllergy As %String;

/// phcCQZT
Property phcCQZT As %String;

/// phcONE
Property phcONE As %String;

/// phcOM
Property phcOM As %String;

/// phcFirstAid
Property phcFirstAid As %String;

/// phcNoAllergy
Property phcNoAllergy As %String;

}
