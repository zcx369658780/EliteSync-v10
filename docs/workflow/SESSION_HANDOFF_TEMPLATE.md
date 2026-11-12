# Session Handoff｜轻量交接模板

本文件是模板。每次交接复制后填写，不要把模板本身当作当前状态。

2026-11-12更新。默认沿实际本地工程和当前授权分支恢复，依据 [AGENTS](../../AGENTS.md)、[CURRENT_WORKFLOW](CURRENT_WORKFLOW.md)及Owner最新决定执行。

```markdown
# Session Handoff｜YYYY-MM-DD

状态为[一个准确状态标签]

## 1. Current State
[实际本地根、remote、分支、HEAD、工作区/index；当前版本/阶段及ACTIVE_STATE链接]
[涉及运行时，区分最近具名资源快照与当前实查结果；未核实写UNKNOWN]

## 2. Completed
[本会话新增完成事项、实际检查、代码/包身份及必要证据；区分工程验收、顾问复核和Owner接受]

## 3. Current Objective
[当前授权范围内下一会话主要目标及仍待完成/未验事项]

## 4. Required Sources
[首读AGENTS、ACTIVE_STATE顶部有效入口、CURRENT_WORKFLOW；按目标补充最新具名交接及必要源码/证据路径和身份]

## 5. Owner Decisions
[已明确授权、待决事项和限制；注明来源，不自行扩张]

## 6. Next Action / STOP
[下一步授权动作、实际未完成项及适用停止条件；普通工程持续执行，Owner停止后保存交接]
[本地保存提交、当前授权分支同步结果；失败写PENDING_SYNC]
```

## 使用规则

- 目标长度300–600字；复杂技术交接通常不超过1000字。技术细节引用具名结果报告或私有原证，注明路径、提交/Blob及适用范围。私有原件由Owner本机保管。
- 只记录本会话相对上次状态的变化，不复制完整ACTIVE_STATE、冻结plan、任务单、AC、历史验收和整段日志。
- 一个时点只指定一个最新有效handoff。旧handoff保留为历史，但新会话不递归读取。
- Handoff提供导航。工程身份以实际本地Git与运行实查为据，当前进度以本地ACTIVE_STATE有效入口和具名证据核验，授权以Owner原始决定为据。GitHub保存状态单独记录，项目源摘要较旧时依据当前工程与最新证据更新。
- 普通工程沿现有有效授权继续，GitHub按需核对。保护dirty/index、私有原证、冻结判定、旧STOP和已耗预算，具体设备及受保护动作遵循Owner授权与连接安排。
- 如果本会话没有形成有价值的状态变化或下一步，不为形式而新建handoff。


## 新会话启动Prompt（复制即可）

接续EliteSync当前授权目标。先核实际本地根[路径]、remote、分支[名称]、HEAD[保存提交]和工作区/index，再读该工程AGENTS、ACTIVE_STATE顶部有效入口及CURRENT_WORKFLOW，按本次目标补读最新具名交接[路径]和必要材料。核对最新Owner决定、权限及未完成项，在有效授权内持续执行并做受影响验证。GitHub按需核对，保留实际本地进度、冻结判定、旧STOP和已耗记录。运行或设备动作前核实际资源与具体授权。节点正常提交同步当前授权分支，失败记PENDING_SYNC，Owner要求停止时保存交接。
