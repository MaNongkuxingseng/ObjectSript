/// 映射规则-枚举类型映射
Class PHA.FACE.TPS.SA.Template.Mapping.Resolver.EnumResolver Extends %RegisteredObject
{

ClassMethod Resolve(value As %String, params As %DynamicObject) As %Status
{
    Set enumType = params.enumType

    If enumType = "InRecType" {
        Quit ..MapInRecType(value)
    }

    Throw ##class(%Exception.General).%New(
        "Unknown EnumType: "_enumType
    )
}

/// 入库类型映射
ClassMethod MapInRecType(value As %String) As %String
{
    If value = "正常入库" Quit "5"
    If value = "政府采购" Quit "7"
    If value = "特殊入库" Quit "9"
    If value = "临购药品" Quit "11"
    If value = "调价换票" Quit "13"

    Throw ##class(%Exception.General).%New(
        "Unknown InRecType: "_value
    )
}

}
