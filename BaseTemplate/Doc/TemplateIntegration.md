# 药房药库
# BaseBizPush Template 对接说明文档

| 项目 | 内容 |
| --- | --- |
| 文件标识 | 药房药库 BaseBizPush Template 对接说明文档 |
| 产品版本 | iMedical Total HIS 8.5 |
| 文档版本 | V1.0 |
| 作    者 | （待补充） |
| 完成日期 | （待补充） |

东华医为科技有限公司  
药房药库产品组  
（日期待补充）

## 版本历史

| 版本 | 作者 | 参与者 | 发布日期 | 修改摘要 |
| --- | --- | --- | --- | --- |
| V1.0 | （待补充） |  |  | 初版 |

Copyright © 2018 DHC MediWay Technology Co., Ltd. All rights reserved  
请不要给第三方传阅

---

## 目录

1. [概要](#1-概要)
2. [整体设计](#2-整体设计)
3. [流程说明](#3-流程说明)
4. [核心类与职责](#4-核心类与职责)
5. [对外接口说明](#5-对外接口说明)
6. [配置说明](#6-配置说明)
7. [日志与重推](#7-日志与重推)
8. [待补充内容](#8-待补充内容)

---

## 1. 概要

本文档用于说明 BaseBizPush Template 体系的对接方式与落地原则，覆盖整体设计、执行流程、核心类职责、对外接口参数与出参含义、配置要点及日志/重推联动要求，便于各业务系统在统一模型下接入推送能力并保持可维护性。

**落地原则**：
- **统一入口**：所有业务推送均从 Template 层进入，确保日志与异常处理一致。
- **上下文完整**：PushContext 必须包含入口、院区/科室、业务主信息与明细数据。
- **平台适配**：平台调用/解析逻辑封装在 Adapter 层，Template 仅处理通用流程。
- **结果可追溯**：PushResult/PushSummary 统一记录，并写入日志用于追踪与重推。

---

## 2. 整体设计

系统按“业务模板（Template）→ 目标（Target）→ 平台调用（Platform/Adapter）”分层。

- **Template 层**：业务模板执行调度，统一过滤、异常处理、汇总结果。
- **Target 层**：定义单个推送目标的业务规则、负载构建、响应解析与成功判定。
- **Platform/Adapter 层**：承接平台协议差异、方法签名、返回格式预处理。
- **Result/Log 层**：记录执行结果与上下文，提供可重推的日志入口。

---

## 3. 流程说明

典型同步推送流程如下：

1. **入口触发**：业务调用 `BasePushTemplate.Execute(ctx)`。
2. **注册匹配**：匹配注册表中的入口与目标集合。
3. **过滤判定**：执行数据过滤器与自定义过滤方法。
4. **平台调用**：构造 `PlatformInvokeContext` → Adapter 调用平台 → 预处理返回。
5. **结果解析**：优先使用适配器预处理结果，兜底解析原始响应。
6. **结果记录**：生成 `PushResult` → 通过 `PushSummary.AddResult` 写日志。

---

## 4. 核心类与职责

### 4.1 Template
- **`PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate`**
  - 统一执行入口，组织注册匹配、过滤、调用、结果汇总。
  - 调用 `DoInvoke` 时优先使用平台适配器，并在适配器成功后触发预处理。

### 4.2 Context
- **`PHA.COM.BaseBizPush.Engine.Context.PushContext`**
  - 输入上下文：入口编码、院区、科室、业务主信息/明细数据、手工重推目标白名单。

- **`PHA.COM.BaseBizPush.Engine.Platform.Context.PlatformInvokeContext`**
  - 平台上下文：平台代码/类/方法、平台业务数据、Payload、RawResponse。
  - 预处理字段：`Result`（规范化结果）与 `IsSuccess`（成功标记）。

### 4.3 Target
- **`PHA.COM.BaseBizPush.Engine.Target.ITarget`**
  - 负责 `BuildPayload`、`ParseResponse`、`IsSuccess`、`BuildResultMessage`。
  - 目标级过滤：`GetDataFilter` 与 `CustomFilter`。

### 4.4 Platform Adapter
- **`PHA.COM.BaseBizPush.Engine.Platform.Adapter.PlatformAdapter`**
  - `Invoke`：执行平台调用。
  - `PreprocessResult`：对平台返回进行标准化预处理（默认不处理）。

- **示例：`PHA.FACE.TPS.SA.HIS2SA.Platforms.Adapter.PUB0005Soap`**
  - 解析 `resultCode/resultContent/list` 标准 JSON 返回，并设置 `Result`/`IsSuccess`。

### 4.5 Result & Log
- **`PHA.COM.BaseBizPush.Engine.Result.PushResult`**
  - 单目标执行结果，包含业务/目标/平台信息与结果信息。

- **`PHA.COM.BaseBizPush.Engine.Result.PushSummary`**
  - 汇总多个 `PushResult`，统一写日志。

- **`PHA.COM.BaseBizPush.Engine.Result.PushResultLogService`**
  - 结果日志写入入口，记录执行结果与上下文（含重推参数）。

---

## 5. 对外接口说明

### 5.1 执行入口

**接口**：`PHA.COM.BaseBizPush.Engine.Template.BasePushTemplate.Execute(ctx)`  
**入参**：`ctx`（`PushContext`）

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| TriggerCode | %String | 入口编码（Entry Code） |
| HospId | %String | 医院/院区ID |
| DeptCode | %String | 科室ID |
| Biz | PushBizContextDTO | 业务上下文（Info/Data） |
| TriggerMode | %String | 触发模式（AUTO/MANUAL） |
| AllowedTargetClasses | %DynamicObject | 手工模式下允许执行的目标类白名单 |

**出参**：`PushSummary`

| 字段 | 说明 |
| --- | --- |
| Results | `PushResult` 列表 |
| successCount/failureCount/totalCount | 统计信息（前端 DTO） |
| summary | 汇总描述 |

### 5.2 手工重推（ExecuteByDynamic）

**接口**：`PHA.COM.BaseBizPush.Manual.Facade.PushManualFacade.ExecuteByDynamic(reqDyn)`  
**入参**：`reqDyn`（%DynamicObject）

| 参数 | 说明 |
| --- | --- |
| entryCode | 入口编码 |
| hospId | 医院/院区ID |
| deptCode | 科室ID |
| bizInfo | 业务主信息（DTO） |
| targetClasses | 目标类列表 |

**出参**：同 `Execute` 的响应结构（结果 DTO）。

---

## 6. 配置说明

### 6.1 平台适配器映射
- 平台适配器类由 `PlatformInvokeContext.getPlatformAdapter()` 解析。
- 字典维护规则：`PlatformClass_MethodName` → 适配器类名。

### 6.2 目标注册
- 注册项包含 `TargetClass`、平台类/方法/平台数据（`PlatformData`）。
- `PlatformData` 建议使用 JSON 结构化字段，确保适配器可读。

### 6.3 日志与重推
- 结果日志在 `PushSummary.AddResult` 时写入。
- 日志中包含 `context` 和 `manualRequest` 用于重推。

---

## 7. 日志与重推

### 7.1 日志写入内容（示例）
- `context`：触发入口、院区/科室、业务主信息/明细、触发模式、白名单。
- `manualRequest`：`entryCode/hospId/deptCode/bizInfo/targetClasses`。

### 7.2 重推流程建议
1. 从日志中读取 `manualRequest`。
2. 直接传入 `ExecuteByDynamic` 实现重推。

---

## 8. 待补充内容

以下内容需要进一步补充或确认后补写：

- **业务入口注册维护界面**（菜单与 csp 路径）。
- **平台适配器字典维护的详细流程与字段说明**。
- **日志查询界面**（字段含义、筛选条件、重推入口）。
- **异常场景与重试策略规范**（重试次数/并发控制）。
- **Target 设计规范模板与字段约束**（按业务类型细化）。

