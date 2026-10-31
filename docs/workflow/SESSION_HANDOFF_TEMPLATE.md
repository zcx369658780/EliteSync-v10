# Session Handoff｜轻量交接模板

本文件是模板。每次交接复制后填写，不要把模板本身当作当前状态。

```markdown
# Session Handoff｜YYYY-MM-DD

Status: [一个准确状态标签]

## 1. Current State
[当前版本/阶段/状态；ACTIVE_STATE链接]

## 2. Completed
[本会话新增完成事项及必要的接受结果/证据链接；没有则写None]

## 3. Current Objective
[下一会话唯一主要目标]

## 4. Required Sources
[仅列下一步确实需要读取的文件路径/Blob及用途；不需要的不要列]

## 5. Owner Decisions
[已明确授权、待决事项和限制；注明来源，不自行扩张]

## 6. Next Action / STOP
[下一步动作、手动派发要求和必须停止的条件]
```

## 使用规则

- 目标长度300–600字；复杂技术交接通常不超过1000字。超出时把技术细节留在GitHub专项合同/结果报告，仅引用路径和Blob。
- 只记录本会话相对上次状态的变化，不复制完整ACTIVE_STATE、冻结plan、任务单、AC、历史验收和整段日志。
- 一个时点只指定一个最新有效handoff。旧handoff保留为历史，但新会话不递归读取。
- Handoff是导航摘要，不是实时状态权威、正式任务合同或授权来源；与live ACTIVE_STATE、正式任务和Owner原始决定冲突时，回到对应权威原件核验。
- 如果本会话没有形成有价值的状态变化或下一步，不为形式而新建handoff。
