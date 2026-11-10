# Current State Snapshot｜Long-task Mode Restoration｜2026-10-25

本快照不替代GitHub实时ACTIVE_STATE。

- Gate 2：`D0_C_GATE2_TARGETED_BLOCKED / BUDGET_CONSUMPTION_REPORTED / FULL_37_CASE_SUITE_NOT_RUN / AWAITING_OWNER_DIRECTION`。
- 一次PowerShell入口启动因`SecurityError / UnauthorizedAccess`被执行策略拒绝，exit1且退出已确认，监督耗时0.375秒；正负例、Writer、Serializer、fallback均NOT_RUN，无receipt。
- 候选Commit `f9d281d03d1f9ad7a3f7b0b3f3e85582c8580dff`，唯一Parent `7b8b9959c9e53994ec5c52736d1fb3ca00ba4239`，Root `d42fcdecb26cea24e65648a6d747329785132109`。
- 报告Blob `a18904743a412f82e5a5a358246eafe9295071d6`，Manifest Blob `e004f9928a9e5ae3eaa7d955c6b16a7c0e88c340`。
- Astra独立复核Blob：`398610e8d482097d2098f2185af05ae307c4249a`。
- 一次性启动预算已消费；不重试、不修改执行策略、不换入口。后续需要Owner明确授权新的合规执行方案。
- 产品仍v10.1.4 accepted；v10.1.5 `PARTIAL_NOT_ACCEPTED`，AC05 `OPEN`；无main产品集成，v10.1.6未启动。
- 当前默认工作流恢复为长任务单+中途无监督模式；A-D为任务发布闭环，不是逐步审批。