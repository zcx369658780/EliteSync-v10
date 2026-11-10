# EliteSync-v10 Project Source Increment｜Long-task Mode Restoration｜2026-10-25

Owner重申并批准：v10.x从规划开始就采用长任务单+中途无监督模式。此前Gate 2诊断因一次PowerShell执行策略拒绝而启动阻断；本增量记录阻断事实并修正工作流，防止将防御性逐步审批误当成项目默认模式。

## 权威GitHub来源

- [Astra Gate 2 execution-policy block review](../../versions/v10.1.5/D0_C_GATE2_EXECUTION_POLICY_BLOCKED_ASTRA_REVIEW_20261025.md)
- [ACTIVE_STATE](../../workflow/ACTIVE_STATE.md)
- [CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)
- [TASK_DISPATCH_CLOSURE_PROTOCOL](../../workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)
- [AGENTS](../../../AGENTS.md)
- [Memory navigation](../../memory/navigation.md)

## 核心原则

1. 每个功能版本默认一份冻结计划、一份综合长任务、一次集中候选与独立验收。
2. Codex在Owner冻结的范围、授权环境和预算内自主调查、实现、集成、构建、测试、调试和修复普通失败。
3. 普通代码修复、测试失败和范围内返修不要求逐次重新派单或等待Owner。
4. 只在方向性决策、超范围、真实用户/生产数据、敏感外传、真实费用、系统级安全设置、供应商/实人或不可逆风险处暂停。
5. 真实执行策略拒绝如实记录；不伪造PASS、不绕过限制、不擅改策略。没有已批准的合法执行方式时，集中报告阻断。
6. A-D任务下达闭环是发布质量协议，不是运行中逐步审批。
7. 本次Gate 2启动尝试已消费一次性预算，正负例仍NOT_RUN；本增量不授权重试。

这是日期化增量快照，不覆盖历史项目源，不包含LOCAL_ONLY原始日志或产品源码。Project Sources附件需Owner手动上传。