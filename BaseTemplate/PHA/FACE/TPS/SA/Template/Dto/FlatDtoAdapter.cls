Class PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter Extends %RegisteredObject
{

/// 将包含一个明细数组的 DynamicObject 展开为扁平 DynamicArray
/// @param srcObj %DynamicObject 输入的原始对象
/// @param listProp %String 明细数组属性名，如 "drugList"
/// @return %DynamicArray 扁平化后的数组
/// w ##class(PHA.FACE.TPS.SA.Template.Dto.FlatDtoAdapter).FlattenWithList({"thno":"260122200100002","thloc":"ZYYX009","vendor":"YP00001","vendordesc":"初始化供应商","type":"正常退货","thuser":"0119","thDate":"2026-01-22","thTime":"10:40:57","thshuser":"0119","thshDate":"2026-01-22","thshTime":"10:41:03","drugList":[{"incno":"1000016","incdesc":"蛤蚧[饮片]","qty":"2","uom":"g","manf":"0","manfdesc":"以批次为准","rp":"2.2","sp":"2.2","rpAmt":"4.4","spAmt":"4.4","batNo":"25","expDate":"2028-09-08","Batid":"26"},{"incno":"1000017","incdesc":"蛤壳[饮片]","qty":"3","uom":"g","manf":"0","manfdesc":"以批次为准","rp":"33","sp":"33","rpAmt":"99","spAmt":"99","batNo":"25","expDate":"2028-08-09","Batid":"26"}]},"drugList")
ClassMethod FlattenWithList(srcObj As %DynamicObject, listProp As %String) As %DynamicArray
{
    Set result = []

    // -------- 1. 参数校验 --------
    If srcObj = "" {
        Quit result
    }

    If '$IsObject(srcObj.%Get(listProp)) {
        Quit result
    }

    Set detailList = srcObj.%Get(listProp)

    If detailList.%Size() = 0 {
        Quit result
    }

    // -------- 2. 提取主单字段（非数组字段） --------
    Set master = {}

    Set it = srcObj.%GetIterator()
    While it.%GetNext(.key, .value) {

        // 跳过明细数组字段
        If key = listProp {
            Continue
        }

        // 仅复制非数组字段
        If '$IsObject(value) {
            d master.%Set(key, value)
        }
    }

    // -------- 3. 展开明细数组 --------
    For i = 0 : 1 : detailList.%Size() - 1 {

        Set detail = detailList.%Get(i)
        Set row = {}

        // 3.1 复制主单字段
        Set it2 = master.%GetIterator()
        While it2.%GetNext(.mKey, .mVal) {
            d row.%Set(mKey, mVal)
        }

        // 3.2 合并当前明细字段
        Set it3 = detail.%GetIterator()
        While it3.%GetNext(.dKey, .dVal) {
            d row.%Set(dKey, dVal)
        }

        // 3.3 追加到结果数组
        Do result.%Push(row)
    }

    Quit result
}

/// ========================================
/// 从 JSON 构建 DTO
/// Author: Template
/// ========================================
ClassMethod FromJson(jsonObj As %DynamicObject, dtoClassName As %String) As %RegisteredObject
{
    Set dto = $classmethod(dtoClassName, "%New")

    // ===== 反射 DTO 类 =====
    Set cls = ##class(%Dictionary.CompiledClass).%OpenId(dtoClassName)
    If cls = "" {
        Quit dto
    }

    // ===== 遍历 JSON =====
    Set iter = jsonObj.%GetIterator()
    While iter.%GetNext(.key, .value) {
        Try {
            // 使用点语法，避免 $Property 静默失败
            Set $PROPERTY(dto, key) = value
        } Catch {
            // 模板层：吞掉异常
        }
    }

    Quit dto
}

/// ========================================
/// DTO 转 DynamicObject（安全反射）
/// Author: Template
/// ========================================
ClassMethod ToDynamicObject(dto As %RegisteredObject) As %DynamicObject
{
    Set obj = {}

    // ===== 关键修正点 1：安全获取 CompiledClass =====
    Set cls = ##class(%Dictionary.CompiledClass).%OpenId($ClassName(dto))
    If cls = "" {
        // 理论上不应该发生，但模板必须兜底
        Quit obj
    }

    // ===== 关键修正点 2：安全遍历属性 =====
    Set propCount = cls.Properties.Count()
    For i = 1 : 1 : propCount {
        Set prop = cls.Properties.GetAt(i)
        If prop = "" {
            Continue
        }

        Set propName = prop.Name
        Set value = $Property(dto, propName)

        // 模板层：不做业务裁剪
        Do obj.%Set(propName, value)
    }

    Quit obj
}

}
