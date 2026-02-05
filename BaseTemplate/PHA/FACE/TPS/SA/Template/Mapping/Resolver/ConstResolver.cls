Class PHA.FACE.TPS.SA.Template.Mapping.Resolver.ConstResolver Extends %RegisteredObject
{

/// =====================================================
/// Resolve
/// -----------------------------------------------------
/// 常量映射 Resolver
/// - 忽略传入 value
/// - 直接返回 Params.value
/// - 若未配置 value，返回空字符串
/// 
/// @param value  原始值（可忽略）
/// @param params 映射参数，必须包含 value
/// @return %String
/// =====================================================
ClassMethod Resolve(value, params As %DynamicObject) As %String
{
    // ---------- 参数校验 ----------
    If '$IsObject(params) {
        Quit ""
    }

    // ---------- 常量取值 ----------
    If params.%IsDefined("value") {
        Quit params.value
    }

    // ---------- 未配置常量 ----------
    Quit ""
}

}
