# Long-task Mode Rules｜Owner-approved 2026-10-25

## Default execution model

EliteSync v10.x默认采用“一份冻结计划、一份综合长任务、一次集中候选与独立验收”。Codex在Owner冻结的功能范围、已授权本地环境和预算内，可自主调查、实现、集成、构建、测试、调试并修复普通失败。目标是在APP尚未上线测试前尽快完成各功能模块设计与构建。

## Do not over-fragment

普通代码修复、普通测试失败、内部文件变更和范围内返修，不要求逐次重新派单或等待Owner；不把静态审查默认设置为每个普通测试动作前的审批门。A-D Task Dispatch Closure只保证任务发布完整，不是运行中的逐步骤审批流程。

## Stop only for real authority boundaries

方向性/超范围决策、真实用户或生产数据、敏感外传、真实费用、系统或全局安全设置、供应商/实人操作、不可逆资产，以及Owner明确保留的事项，才应暂停请求Owner。

## Environment refusals and budgets

真实环境策略拒绝必须如实记录，不伪造PASS、不把NOT_RUN标为FAIL、不直接修改安全策略或规避限制。若同一长任务授权内存在已批准且合法的执行方式，可以自主采用；否则集中报告阻断。Owner明确规定的一次性尝试、硬时限和稀缺资源预算仍须遵守，失败后不自动重试或重置。

## Delivery and review

一份综合任务单应一次写明目标、范围、最终验收、允许自主修复/重试事项、预算、真正的STOP边界和交付物。Astra在综合交付后集中独立验收；必要时对原范围一次集中返修。不自动派发后继任务、不自动合并产品、不越级放行下一Gate。

## Current Gate 2 status snapshot

2026-10-25唯一一次PowerShell入口启动被ExecutionPolicy拒绝，`SecurityError / UnauthorizedAccess`，exit 1、退出已确认、监督耗时0.375秒。正例、负例、Writer、Serializer、fallback均NOT_RUN，无receipt；一次性启动预算已消费。不得自行重试或修改策略。此阻断不是Writer运行FAIL。