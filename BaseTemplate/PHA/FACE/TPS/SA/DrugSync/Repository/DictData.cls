Class PHA.FACE.TPS.SA.DrugSync.Repository.DictData Extends %RegisteredObject
{

Property id As %String;

Property action As %String;

// insert | update | none

/// 转 %DynamicObject
Method ToObject() As %DynamicObject
{
    Quit {
        "id": (..id),
        "action": (..action)
    }
}

}
