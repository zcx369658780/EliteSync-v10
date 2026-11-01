# Local-first｜旧任务发布协议适用性

**SUPERSEDED_WORKFLOW：A–D、网页派单与网页终验不再是普通工程前置门槛。**

当前执行规则见[AGENTS](../../AGENTS.md)、[CURRENT_WORKFLOW](CURRENT_WORKFLOW.md)和[Owner 决定](../decisions/OWNER_LOCAL_FIRST_CODEX_20261101.md)。Codex 在已批准目标和权限内自主工作；原八字段可按需参考，不强制另制任务单、发布到 main 或等网页验收。

下方协议是历史原文，不作为当前派发命令。其明确授权、冻结标准、隐私、供应商/设备权限、特殊预算与 STOP 资产约束继续有效；原始消耗和失败不得倒改或复活。需要咨询时由 Owner 发起，不假设自动消息转发。

---

# Task Dispatch Closure Protocol｜精简任务发布闭环

生效：2026-11-01。适用于Astra向Owner交付Codex正式任务的场景。

**原则：一份冻结plan、一份综合长任务、一个持久账本、一个候选、一次集中独立验收。Owner手动派发；发布不等于派发，派发不等于执行。**

## 1. 任务单最小结构

正式任务单只保留八项，按本任务需要填写，不复制项目历史：

1. **Objective**：一个明确、可观察的目标。
2. **Baseline**：fresh main/Root、必要候选和源码Tree/Blob。
3. **Scope**：允许修改的模块、路径、环境和数据范围。
4. **References**：当前冻结plan及本任务真正相关的专项合同/证据链接。
5. **Acceptance**：必须交付的结果、证据和独立验收标准。
6. **Budget**：总预算、一次性额度、硬上限和计账方式。
7. **Restrictions**：禁止事项、Owner授权边界、失败与STOP条件。
8. **Delivery**：一个候选、结果报告、manifest/必要证据、最终状态。

不适用字段写明N/A，不为填满模板引入额外范围。历史背景只引用原件，不复制全文。

## 2. A–D发布闭环

### A｜授权与基线
核对Owner明确授权、当前ACTIVE_STATE、live main/Root、相关候选、冻结plan/合同、预算/claim、受保护资产和停止门禁。授权明确不重复询问；未明确或出现新的高风险行为才询问。

### B｜唯一任务
在`zcx369658780/EliteSync-v10`的main创建一份正式任务单。取得Blob SHA后立即按路径读回，核对正文、目标、预算和STOP。不得创建重复微任务、issue或Prompt中转链。

### C｜状态同步
更新ACTIVE_STATE的CURRENT ENTRY，记录任务路径/Blob、状态、授权边界和下一停止点。fresh回读live main、Root、任务正文/Blob及ACTIVE_STATE/Blob；按需核对产品Tree。任何失败如实报告部分完成，不盲目重复创建。

### D｜一次性交付
同一条回复简洁交付：任务链接、任务Blob、最终main/Root、ACTIVE_STATE Blob、发布状态、STOP条件，以及一个可复制启动Prompt。明确`PUBLISHED / OWNER_MANUAL_DISPATCH_REQUIRED`。

A–D是发布质量闭环，不是Codex执行期间逐步骤审批。Codex在正式任务明确授权范围内自主实现、测试、调试和修复普通失败；范围外或高风险动作暂停请求Owner。

## 3. 启动Prompt规范

Prompt短于任务单，目标约100–200字；只提供：
- 正式任务路径和Blob SHA；
- fresh读取live main/Root、ACTIVE_STATE当前首段、正式任务全文的要求；
- 仅在任务引用时读取冻结plan/专项合同；
- 遵守任务范围、预算、保护和STOP；
- 交付一个候选及证据后停止等待Astra验收。

**Prompt不重复任务正文，不添加任务单之外的授权。**

示例：

```text
执行正式任务：[路径]（Blob：[SHA]）。
开始前fresh读取live main/Root、ACTIVE_STATE最新首段及任务全文；仅补读任务引用的合同。
以任务单为唯一合同，在授权范围内自主完成、修复和测试。遵守预算、保护及STOP条件。
交付一个候选和必要证据后永久STOP，等待Astra独立验收；不得自动合main或启动后继版本。
```

## 4. 部分完成与失败状态

| 情况 | 状态 |
|---|---|
| 授权不明确 | `WAITING_FOR_OWNER_CLARIFICATION` |
| 任务创建失败 | `TASK_NOT_PUBLISHED` |
| 任务已创建但正文未读回 | `TASK_CREATED_READBACK_PENDING` |
| 状态同步失败 | `TASK_PUBLISHED_STATE_SYNC_INCOMPLETE` |
| 最终HEAD/Blob读回失败 | `PUBLISHED_READBACK_UNVERIFIED` |
| 完整发布 | `PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED` |

不得猜测链接/Blob，不得把部分完成声称为完整发布，不得盲目重复创建。

## 5. 验收后停止

Codex交付一个候选后永久STOP，等待Astra独立验收。Astra按冻结AC和受影响证据集中裁决；普通范围内缺陷可形成一次集中返修。不得自动合main、自动派发后继或越级启动下一Gate/版本。

一次性预算/硬上限不重置、不退款、不重试。环境拒绝如实记录，不伪造PASS、不将NOT_RUN写成FAIL、不规避安全策略。真实用户/生产数据、敏感外传、真实费用、系统安全设置、供应商/实人和不可逆动作必须有具体Owner授权。

## 6. 长期规则同步

Owner要求工作流成为长期规则时，同步更新AGENTS、CURRENT_WORKFLOW、本协议、Project Sources瘦身规则、Session Handoff模板及必要导航。Project Sources采用日期化完整替换包、SHA256 manifest和独立镜像说明；Owner手动替换附件。GitHub、Project附件和账户Memory分别记账。
