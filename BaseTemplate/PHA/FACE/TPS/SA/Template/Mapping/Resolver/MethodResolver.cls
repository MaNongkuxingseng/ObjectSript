Class PHA.FACE.TPS.SA.Template.Mapping.Resolver.MethodResolver Extends %RegisteredObject
{

/// =================================================
/// Resolve
/// 通过自定义类方法进行值转换
/// params:
/// {
///   "class":  "My.Util",
///   "method": "Convert",
///   "args":   {...}   // 可选
/// }
/// =================================================
ClassMethod Resolve(value, params As %DynamicObject) As %String
{
    If value = "" Quit ""

    If '$IsObject(params) {
        Throw ##class(%Exception.General).%New(
            "MethodResolver params is required"
        )
    }

    Set utilClass = params.utilClass
    Set method    = params.method
    Set args      = params.args

    If (utilClass = "") || (method = "") {
        Throw ##class(%Exception.General).%New(
            "MethodResolver requires class and method"
        )
    }

    // =========================
    // 正确的 ObjectScript 调用方式
    // =========================
    If $IsObject(args) {
        Set result = $ClassMethod(utilClass, method, value, args)
    }
    Else {
        Set result = $ClassMethod(utilClass, method, value)
    }

    Quit result
}

}
