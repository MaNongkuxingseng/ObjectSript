Class PHA.FACE.TPS.SA.DrugSync.Repository.DictResult Extends %RegisteredObject
{

/// 0=成功,1=失败
Property code As %Integer;

Property msg As %String;

Property data As PHA.FACE.TPS.SA.DrugSync.Repository.DictData;

/// 内部构造方法（统一结构）
/// 不对外使用，外部统一调用 SuccessXXX 或 Error
ClassMethod Build(code As %Integer, msg As %String, id As %String = "", action As %String = "") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    s obj = ..%New()
    s obj.code = code
    s obj.msg = msg

    // data 对象
    s d = ##class(PHA.FACE.TPS.SA.DrugSync.Repository.DictData).%New()
    s d.id = id
    s d.action = action
    s obj.data = d

    Quit obj
}

/// ======== 成功类构造方法 =========
/// 新增 insert 成功
ClassMethod SuccessInsert(id As %String, msg As %String = "插入成功") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    Quit ..Build(0, msg, id, "insert")
}

/// 更新 update 成功
ClassMethod SuccessUpdate(id As %String, msg As %String = "更新成功") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    Quit ..Build(0, msg, id, "update")
}

/// 无需更新 none
ClassMethod SuccessNoChange(id As %String, msg As %String = "无需更新") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    Quit ..Build(0, msg, id, "none")
}

/// ========== 失败构造方法 =============
ClassMethod Error(msg As %String = "失败", id As %String = "") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    Quit ..Build(-1, msg, id, "")
}

ClassMethod FromSaveRet(saveRet As %String, id As %String = "", successMsg As %String = "更新成功") As PHA.FACE.TPS.SA.DrugSync.Repository.DictResult
{
    /*
    saveRet: 格式为 "code^msg"
       - code < 0 表示失败
       - code >= 0 表示成功（一般为更新）

    id:     最终字典 ID
    successMsg: 更新成功时的消息（默认 “更新成功”）
    */

    s code = +$piece(saveRet, "^", 1)   ; 保存结果代码
    s msg = $piece(saveRet, "^", 2)     ; 保存结果消息
    
    // 失败：返回 Error
    If code < 0 {
        Quit ..Error(msg, id)
    }
    s:id="" id = code
    
    // 成功：返回 SuccessUpdate
    Quit ..SuccessUpdate(id, successMsg)
}

/// DynamicObject
Method ToObject() As %DynamicObject
{
    s obj = {
        "code": (..code),
        "msg": (..msg),
        "data": (..data.ToObject())
    }
    Quit obj
}

}
