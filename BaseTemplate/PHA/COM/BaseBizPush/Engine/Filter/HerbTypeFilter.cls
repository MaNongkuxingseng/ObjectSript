/// 草药类型过滤器。
/// 根据发药ID判断是否为草药类型。
///   
Class PHA.COM.BaseBizPush.Engine.Filter.HerbTypeFilter Extends %RegisteredObject
{

/// 过滤编码
Property FilterCode As %String [ InitialExpression = "FILTER_HERB_TYPE" ];

/// 需要的草药类型（如：CHINESE_HERB, WESTERN_MEDICINE）
Property RequiredHerbType As %String;

Method ShouldFilter(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %Boolean
{
#;        s dispenseId = $get(bizData.dispenseId)
        if ('bizData.%IsDefined("dispenseId")||(bizData.dispenseId="")) {
            // 没有发药ID，记录日志但不过滤（可以根据需求调整）
            q 0
        }
        s dispenseId = bizData.dispenseId
        // 查询发药类型
        s actualHerbType = ..QueryHerbType(dispenseId)
        
        // 判断是否符合要求
        if (..RequiredHerbType '= "") && (actualHerbType '= ..RequiredHerbType) {
            q 1  // 类型不匹配，需要过滤
        }
        
        q 0  // 不需要过滤
}

Method GetFilterMessage(bizData As %DynamicObject, ctx As PHA.COM.BaseBizPush.Engine.Context.PushContext) As %String
{
        s dispenseId = bizData.dispenseId
        s herbType = ..QueryHerbType(dispenseId)
        q "发药单"_dispenseId_"的类型为"_herbType_"，不符合要求类型："_..RequiredHerbType
}

Method QueryHerbType(dispenseId As %String) As %String
{
        // 实际业务中需要查询数据库
        // 这里使用简化逻辑
        
        // 示例：根据发药ID前缀判断
        if ($extract(dispenseId,1,2) = "CH") {
            q "CHINESE_HERB"
        } elseif ($extract(dispenseId,1,2) = "WM") {
            q "WESTERN_MEDICINE"
        } else {
            q "UNKNOWN"
        }
}

}
