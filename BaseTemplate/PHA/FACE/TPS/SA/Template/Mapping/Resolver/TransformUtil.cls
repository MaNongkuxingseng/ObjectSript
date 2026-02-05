Class PHA.FACE.TPS.SA.Template.Mapping.Resolver.TransformUtil Extends %RegisteredObject
{

/// <summary>
/// 时间戳 → 日期时间字符串
/// </summary>
ClassMethod FormatDate(value, args As %DynamicObject) As %String
{
    Set fmt = $Get(args.format, "yyyy-MM-dd HH:mm:ss")

    // 假设 value 为 Unix Timestamp
    Set dt = $ZDATETIME(value, 3)

    Quit $ZDATETIME(dt, fmt)
}

/// <summary>
/// 字符串去空格
/// </summary>
ClassMethod Trim(value, args As %DynamicObject) As %String
{
    Quit $ZSTRIP(value, "<>W")
}

/// <summary>
/// 字符串转大写
/// </summary>
ClassMethod Upper(value, args As %DynamicObject) As %String
{
    Quit $ZCONVERT(value, "U")
}

}
