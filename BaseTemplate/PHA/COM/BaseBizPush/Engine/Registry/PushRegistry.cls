Class PHA.COM.BaseBizPush.Engine.Registry.PushRegistry Extends %RegisteredObject
{

/*
 测试查询方法兼容性
do ##class(PHA.COM.BaseBizPush.Engine.Registry.PushRegistry).TestQueryMethods()

// 最终测试
do ##class(PHA.COM.BaseBizPush.Engine.Registry.PushRegistry).FinalTestScan()

// 简单测试
do ##class(PHA.COM.BaseBizPush.Engine.Registry.PushRegistry).SimpleTest()

// 获取入口列表
write ##class(PHA.COM.BaseBizPush.Engine.Registry.PushRegistry).GetPushEntriesList().%ToJSON()

// 扫描所有入口（修复版）
write ##class(PHA.COM.BaseBizPush.Engine.Registry.PushRegistry).ScanAllEntries().%ToJSON()
*/
/// 业务推送声明扫描与统计注册表。
/// 获取所有子类（兼容不同版本）
ClassMethod GetAllSubclasses(className As %String) As %List
{
    set resultList = ##class(%ListOfDataTypes).%New()
    
    try {
        // 方法1：使用%Dictionary.ClassDefinition.SubclassOf()方法
        set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")
        do rs.Execute(className)
        
        while rs.Next() {
            do resultList.Insert(rs.Get("Name"))
        }
        do rs.Close()
        
    } catch ex1 {
        try {
            // 方法2：使用%Dictionary.ClassDefinitionQuery.SubclassOf查询
            set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinitionQuery:SubclassOf")
            do rs.Execute(className)
            
            while rs.Next() {
                do resultList.Insert(rs.Get("Name"))
            }
            do rs.Close()
            
        } catch ex2 {
            try {
                // 方法3：使用SQL查询
                set rs = ##class(%ResultSet).%New()
                set sql = "SELECT Name FROM %Dictionary.ClassDefinition WHERE Super [ ?"
                set sc = rs.Prepare(sql)
                if $$$ISOK(sc) {
                    set sc = rs.Execute("*"_className_"*")
                    if $$$ISOK(sc) {
                        while rs.Next() {
                            do resultList.Insert(rs.Get("Name"))
                        }
                    }
                }
                do rs.Close()
                
            } catch ex3 {
                // 方法4：使用%Library.ResultSet直接查询
                set rs = ##class(%Library.ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")
                if rs {
                    do rs.Execute(className)
                    while rs.Next() {
                        do resultList.Insert(rs.Get("Name"))
                    }
                    do rs.Close()
                }
            }
        }
    }
    
    return resultList
}

/// 安全的类实例化方法
ClassMethod SafeNewObject(className As %String) As %RegisteredObject [ Private ]
{
    try {
        // 检查类是否存在
        if '##class(%Dictionary.ClassDefinition).%ExistsId(className) {
            return ""
        }
        
        // 检查是否是抽象类
        set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        if '$isobject(classDef) || classDef.Abstract {
            return ""
        }
        
        // 尝试创建实例
        set obj = $classmethod(className, "%New")
        if '$isobject(obj) {
            return ""
        }
        
        return obj
    } catch ex {
        return ""
    }
}

/// 扫描所有业务入口类
ClassMethod ScanAllEntries() As %DynamicObject
{
    set result = []
    
    try {
        // 获取所有子类
        set subclasses = ..GetAllSubclasses("PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate")
        
        for i = 1:1:subclasses.Count() {
            set cls = subclasses.GetAt(i)
            
            // 跳过BasePushTemplate自身
            if cls = "PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate" continue
            
            set entry = ..SafeNewObject(cls)
            
            if '$isobject(entry) {
                // 无法实例化
                set errorObj = {}
                set errorObj.className = cls
                set errorObj.error = "无法实例化"
                do result.%Push(errorObj)
                continue
            }
            
            try {
                set obj = {}
                set obj.actionCode = entry.ActionCode()
                set obj.actionName = entry.ActionName()
                set obj.entryClass = cls
                set obj.registrations = []
                
                // 获取注册信息
                set regs = entry.Registrations()
                if $isobject(regs) {
                    for j = 1:1:regs.Count() {
                        set reg = regs.GetAt(j)
                        if '$isobject(reg) continue
                        
                        set ro = {}
                        set ro.hospId = reg.HospId
                        set ro.deptCode = reg.DeptCode
                        set ro.targets = []
                        
                        // 收集目标类信息
                        if $isobject(reg.TargetClasses) {
                            for k = 1:1:reg.TargetClasses.Count() {
                                set targetCls = reg.TargetClasses.GetAt(k)
                                
                                set targetInfo = {}
                                set targetInfo.className = targetCls
                                
                                set targetInst = ..SafeNewObject(targetCls)
                                if $isobject(targetInst) {
                                    set targetInfo.code = targetInst.GetCode()
                                    set targetInfo.name = targetInst.GetName()
                                    set targetInfo.desc = targetInst.GetDesc()
                                    set targetInfo.isAsync = targetInst.IsAsync()
                                    
                                    // 检查过滤器
                                    set filter = targetInst.GetDataFilter()
                                    set targetInfo.hasFilter = $isobject(filter)
                                    if $isobject(filter) {
                                        set targetInfo.filterType = $classname(filter)
                                    }
                                }
                                
                                do ro.targets.%Push(targetInfo)
                            }
                        }
                        
                        do obj.registrations.%Push(ro)
                    }
                }
                
                do result.%Push(obj)
                
            } catch innerEx {
                set errorObj = {}
                set errorObj.className = cls
                set errorObj.error = "业务错误: " _ innerEx.DisplayString()
                do result.%Push(errorObj)
            }
        }
        
    } catch ex {
        set errorObj = {}
        set errorObj.error = "扫描失败: " _ ex.DisplayString()
        do result.%Push(errorObj)
    }
    
    return result
}

/// 简化的测试方法
ClassMethod SimpleTest()
{
    write "测试开始...", !!
    
    // 测试具体的已知类
    set testClasses = $listbuild(
        "PHA.COM.BaseBizPush.Business.AfterDispenPush"
    )
    
    for i = 1:1:$listlength(testClasses) {
        set cls = $listget(testClasses, i)
        write "测试类: ", cls, !
        
        if '##class(%Dictionary.ClassDefinition).%ExistsId(cls) {
            write "  类不存在", !!
            continue
        }
        
        set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(cls)
        if classDef.Abstract {
            write "  抽象类，跳过", !!
            continue
        }
        
        try {
            set obj = $classmethod(cls, "%New")
            if $isobject(obj) {
                write "  实例化成功", !
                
                try {
                    set code = obj.ActionCode()
                    write "  ActionCode: ", code, !
                } catch codeEx {
                    write "  ActionCode错误: ", codeEx.DisplayString(), !
                }
                
                try {
                    set name = obj.ActionName()
                    write "  ActionName: ", name, !
                } catch nameEx {
                    write "  ActionName错误: ", nameEx.DisplayString(), !
                }
                
                try {
                    set desc = obj.ActionDesc()
                    write "  ActionDesc: ", desc, !
                } catch descEx {
                    write "  ActionDesc错误: ", descEx.DisplayString(), !
                }
                
                try {
                    set regs = obj.Registrations()
                    write "  注册数: ", regs.Count(), !
                    
                    for j = 1:1:regs.Count() {
                        set reg = regs.GetAt(j)
                        write "    院区: ", reg.HospId, ", 科室: ", reg.DeptCode, !
                        if $isobject(reg.TargetClasses) {
                            write "    目标类: ", !
                            for k = 1:1:reg.TargetClasses.Count() {
                                write "      - ", reg.TargetClasses.GetAt(k), !
                            }
                        }
                    }
                } catch regEx {
                    write "  Registrations错误: ", regEx.DisplayString(), !
                }
                
            } else {
                write "  实例化失败: 返回空对象", !
            }
        } catch ex {
            write "  异常: ", ex.DisplayString(), !
        }
        
        write !!
    }
}

/// 测试查询方法
ClassMethod TestQueryMethods()
{
    write "测试查询方法兼容性...", !!
    
    // 测试不同的查询方式
    set queries = $listbuild(
        "%Dictionary.ClassDefinition:SubclassOf",
        "%Dictionary.ClassDefinitionQuery:SubclassOf",
        "%Dictionary.ClassDefinitionQuery.SubclassOf",
        "%Dictionary.ClassDefinition_SubclassOf"
    )
    
    for i = 1:1:$listlength(queries) {
        set query = $listget(queries, i)
        write "测试查询: ", query, !
        
        try {
            set rs = ##class(%ResultSet).%New(query)
            if $isobject(rs) {
                do rs.Execute("PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate")
                set count = 0
                while rs.Next() {
                    set count = count + 1
                }
                write "  成功，找到 ", count, " 个子类", !
                do rs.Close()
            } else {
                write "  失败: 无法创建ResultSet", !
            }
        } catch ex {
            write "  异常: ", ex.DisplayString(), !
        }
        write !
    }
}

/// 使用SQL查询子类
ClassMethod GetSubclassesBySQL(className As %String) As %List
{
    set resultList = ##class(%ListOfDataTypes).%New()
    
    &sql(DECLARE C1 CURSOR FOR
         SELECT Name 
         INTO :name
         FROM %Dictionary.ClassDefinition
         WHERE Super LIKE '%' || :className || '%'
         ORDER BY Name)
    
    &sql(OPEN C1)
    if SQLCODE = 0 {
        for {
            &sql(FETCH C1)
            quit:SQLCODE
            do resultList.Insert(name)
        }
        &sql(CLOSE C1)
    }
    
    return resultList
}

/// 最终的测试扫描方法
ClassMethod FinalTestScan()
{
    write "最终版本测试扫描...", !!
    
    // 直接测试已知的具体实现类
    set cls = "PHA.COM.BaseBizPush.Business.AfterDispenPush"
    
    write "测试类: ", cls, !!
    
    // 检查类定义
    if '##class(%Dictionary.ClassDefinition).%ExistsId(cls) {
        write "错误: 类不存在", !
        return
    }
    
    set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(cls)
    write "类定义信息:", !
    write "  名称: ", classDef.Name, !
    write "  父类: ", classDef.Super, !
    write "  描述: ", $extract(classDef.Description, 1, 50), "...", !
    write "  抽象: ", classDef.Abstract, !
    
    if classDef.Abstract {
        write "警告: 抽象类无法实例化", !
        return
    }
    
    // 实例化
    write !!, "尝试实例化...", !
    try {
        set obj = $classmethod(cls, "%New")
        
        if $isobject(obj) {
            write "成功创建实例", !
            
            // 测试必需方法
            write !!, "测试必需方法:", !
            
            set code = obj.ActionCode()
            write "ActionCode(): ", code, !
            
            set name = obj.ActionName()
            write "ActionName(): ", name, !
            
            // 测试可选方法
            write !!, "测试可选方法:", !
            
            try {
                set desc = obj.ActionDesc()
                write "ActionDesc(): ", desc, !
            } catch {
                write "ActionDesc(): 方法不存在或错误", !
            }
            
            // 测试关键方法
            write !!, "测试Registrations():", !
            set regs = obj.Registrations()
            
            if $isobject(regs) {
                write "返回对象类型: ", $classname(regs), !
                write "数量: ", regs.Count(), !
                
                for i = 1:1:regs.Count() {
                    write !, "注册信息 ", i, ":", !
                    set reg = regs.GetAt(i)
                    
                    if $isobject(reg) {
                        write "  院区: ", reg.HospId, !
                        write "  科室: ", reg.DeptCode, !
                        
                        if $isobject(reg.TargetClasses) {
                            write "  目标类数量: ", reg.TargetClasses.Count(), !
                            for j = 1:1:reg.TargetClasses.Count() {
                                set targetCls = reg.TargetClasses.GetAt(j)
                                write "    - ", targetCls, !
                            }
                        }
                    }
                }
            } else {
                write "错误: Registrations()返回空", !
            }
            
        } else {
            write "错误: 实例化返回空对象", !
        }
        
    } catch ex {
        write "异常: ", ex.DisplayString(), !
        write "位置: ", ex.Location, !
        write "$ZERROR: ", $ZERROR, !
    }
    
    write !!, "测试完成", !
}

/// 获取所有推送入口的简单列表
ClassMethod GetPushEntriesList() As %DynamicObject
{
    set result = {}
    set result.entries = []
    
    // 手动添加已知的入口类
    set knownEntries = $listbuild(
        $listbuild("PHA.COM.BaseBizPush.Business.AfterDispenPush", "AFTER_DISPENSE", "发药后推送")
    )
    
    for i = 1:1:$listlength(knownEntries) {
        set entryInfo = $listget(knownEntries, i)
        set entryClass = $listget(entryInfo, 1)
        set entryCode = $listget(entryInfo, 2)
        set entryName = $listget(entryInfo, 3)
        
        set entryObj = {}
        set entryObj.className = entryClass
        set entryObj.actionCode = entryCode
        set entryObj.actionName = entryName
        
        // 尝试获取更多信息
        if ##class(%Dictionary.ClassDefinition).%ExistsId(entryClass) {
            set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(entryClass)
            set entryObj.description = classDef.Description
            set entryObj.abstract = classDef.Abstract
        }
        
        do result.entries.%Push(entryObj)
    }
    
    set result.total = result.entries.%Size()
    set result.timestamp = $zdt($now(), 3)
    
    return result
}

}
