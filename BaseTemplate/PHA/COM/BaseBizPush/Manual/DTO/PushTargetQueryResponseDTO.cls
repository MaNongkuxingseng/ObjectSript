/// 人工重推目标查询响应 DTO
/// Author: Valen MPF
Class PHA.COM.BaseBizPush.Manual.DTO.PushTargetQueryResponseDTO Extends %SerialObject
{

/// 查询是否成功
Property Success As %Boolean;

/// 响应消息
Property Message As %String;

/// 可选目标列表
Property Targets As %ListOfObjects;

/// hisui 关键字列表（与 Targets 对齐）
Property Keywords As %ListOfDataTypes;

/// 数量
Property Total As %Integer;

/// 转换为前端可用动态对象
Method ToDynamicObject() As %Library.DynamicObject
{
    set targets = []
    if $isobject(..Targets) {
        for i=1:1:..Targets.Count() {
            set item = ..Targets.GetAt(i)
            continue:'$isobject(item)
            do targets.%Push(item.ToDynamicObject())
        }
    }

    set keywords = []
    if $isobject(..Keywords) {
        for j=1:1:..Keywords.Count() {
            do keywords.%Push(..Keywords.GetAt(j))
        }
    }

    // 兜底：若 Keywords 未装载，则从 Targets 反推，保证前端可用
    if keywords.%Size()=0 {
        for k=0:1:targets.%Size()-1 {
            set t = targets.%Get(k)
            if t.%IsDefined("keyword") {
                do keywords.%Push(t.keyword)
            }
        }
    }

    quit {
        "success": (..Success),
        "message": (..Message),
        "total": (..Total),
        "keywords": (keywords),
        "targets": (targets)
    }
}

}
