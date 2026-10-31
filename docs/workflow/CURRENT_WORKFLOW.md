# EliteSync-v10 当前工作流

生效：2026-11-01。本文规定会话恢复、按需取证、任务执行和状态交接；不替代产品决定、冻结AC或具体运行授权。

## 1. 会话恢复：三项首读

1. Fresh读取live GitHub main。
2. 读取`AGENTS.md`全文。
3. 读取`ACTIVE_STATE.md`最新CURRENT ENTRY及其指向的最新具名handoff；ACTIVE_STATE只读当前首块，handoff只读一份。

到此停止。旧handoff、历史状态、冻结plan、Owner决定、历史报告和Project Sources其他文件均不默认加载。

## 2. 按需取证

先确定当前唯一目标，再按目标补读：

- 已有正式任务：任务全文 → 任务引用的当前冻结plan → 本次真正相关的专项合同/证据。
- 需要决策：先写清待决问题和决策影响，再读取直接相关的Owner决定、原始设计、技术合同、源码或验收证据。
- 证据复用：核对Tree/Blob、环境、适用测试与失效条件；没有相关变化就不重复全量审计。
- 来源缺失或冲突：报告具体缺口和最小所需材料，不用一般知识填补项目事实，不递归扫描历史。

## 3. 角色与任务规模

Owner保留产品方向、重大不可逆决策、具体运行/设备权限、真实数据与费用的最终authority。Astra负责Product Advisor、Planner、Reviewer、Orchestrator和Current-state Manager。Codex仅在Owner手动派发正式任务后执行。

默认一份冻结计划、一份综合长任务、一个持久账本、一个候选、一次集中独立验收。Codex在明确授权范围内自主调查、实现、构建、测试、调试和修复普通失败；不为普通代码修改、测试失败或范围内返修拆微任务。

## 4. 任务发布与执行

正式任务遵循`TASK_DISPATCH_CLOSURE_PROTOCOL.md`。A–D确保授权、唯一任务、状态和最终读回完整，不构成执行期间逐命令审批。任务单必须明确目标、基线、范围、引用、验收、预算、禁止事项和STOP条件。

Owner手动派发。Codex在任务范围内自主推进；超范围、方向性选择、生产/真实用户数据、敏感外传、真实费用、系统/全局安全设置、供应商/实人或不可逆动作暂停请求Owner。环境拒绝如实记录，不伪造PASS、不规避策略、不扩大权限。

## 5. 证据与独立验收

严格区分源码候选、Astra功能接受、main集成、本地代码基线、实际运行和外部供应商门禁。CODEX_REPORTED、LOCAL_ONLY、NOT_RUN、PENDING不可替代Astra直接核验或PASS。

已接受证据只有在源码Tree/Blob、环境、合同和适用范围仍有效时才复用；只对本次变更及受影响门禁做增量复核。保留原AC、失败记录和历史候选，不倒改历史。Codex交付一个候选后STOP，Astra集中独立验收；必要时在原范围内进行一次集中返修。

## 6. 集成、状态与交接

接受、GitHub产品集成、本地可用基线、原dirty root是否吸收、目标基线实际运行分别记录。不得自动合并产品main、自动派发后继或启动下一版本；是否重跑按集成差异确定。

`ACTIVE_STATE.md`只维护简短CURRENT ENTRY和必要历史记录；在正式任务发布、候选交付、接受/集成或阶段改变时更新，不为每个微步骤重复写状态。旧状态段落保留为历史，首读只读最新CURRENT ENTRY。

Session Handoff只作导航，不复制ACTIVE_STATE或任务单。使用`SESSION_HANDOFF_TEMPLATE.md`六字段模板，目标300–600字，通常不超过1000字；只保留状态差异、下一目标、必要源文件、Owner决定和STOP。旧handoff不递归读取。

## 7. 保护边界

保持dirty根、未提交成果、worktrees、数据库/卷、备份、refs、密钥及LOCAL_ONLY原证。不得盲pull/reset/rebase/stash/clean/prune/force。生产数据覆盖/外传、原始备份删除、真实第三方付费、系统安全策略修改和未授权设备操作均需具体Owner授权。私密SQL、真实用户资料、JWT/密钥、设备原始日志和LOCAL_ONLY APK不进入公开GitHub或Project Sources。

## 8. 项目源

Project Sources是按需参考库，不是启动时全量阅读清单。完整替换包和SHA256 manifest按日期化目录保存；旧快照不删除。Owner手动替换Project附件；GitHub、Project附件和账户Memory分别记账。
