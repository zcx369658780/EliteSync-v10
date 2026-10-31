# EliteSync-v10 项目启动指导

生效：2026-10-31。Owner为最终产品方向、具体运行权限及不可逆操作authority；Astra负责Product Advisor、Planner、Orchestrator、Current-state Manager与独立验收；Codex仅在Owner手动派发正式任务后执行。

## 当前权威入口

1. **实时状态：** `docs/workflow/ACTIVE_STATE.md`，只以live main顶部最新状态为准；文件中的旧段落是历史，不可当作当前状态。
2. **当前会话交接：** 读取最新具名handoff，不递归加载旧handoff。
3. **当前冻结范围：** 读取本次实际工作的版本plan及相关专项合同；不默认加载全部历史plan、任务单或证据。
4. **稳定规则：** `docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`、`docs/workflow/PROJECT_SOURCE_COMPACTION_POLICY.md`。
5. **产品决定：** `PRODUCT_DECISIONS.md`及具名Owner增量决定；历史设计原件/接受记录按需读取。

## 角色与任务模式

- Owner手动派发Codex；GitHub任务发布、启动Prompt或Astra规划不等于派发/执行。
- 默认一份冻结计划、一份综合长任务、一个持久账本、一次集中候选和独立验收。Codex在已授权范围内自主调查、实现、构建、测试、调试和修复普通失败。
- A-D任务下达闭环是发布质量保证，不是逐步骤审批：核授权/状态/基线/预算；创建唯一任务并读回；更新状态并回读live main/Root/Blob；同一回复交付链接、Blob、停止门禁及单一启动Prompt。
- 仅超范围、方向性/不可逆决策、真实用户/生产数据、敏感外传、真实费用、系统/全局安全设置、供应商/实人或其他未授权高风险动作暂停请求Owner。
- 普通失败在任务范围内修复；一次性预算/硬上限不重置、不退款、不重试。环境拒绝如实报告，不伪造PASS、不规避安全策略、不扩大权限。

## 证据与验收

- 严格区分源码候选、Astra功能接受、main产品集成、当地代码基线、运行状态、外部供应商门禁。
- 证据标签按来源写明：Astra直接核验、CODEX_REPORTED、LOCAL_ONLY、NOT_RUN、PENDING不可互相替代。
- 已接受证据按源码Tree/Blob、适用范围和失效条件复用；仅对本次改动或受影响门禁做增量核验，不重复已接受的全量审计。
- 原冻结AC、失败记录、历史候选、原始证据和备份不倒改、不删除；不得自动合并产品main或启动后续版本。
- 真实Push供应商/费用、外部下载/依赖、驱动安装、系统安全策略或全局权限修改，均须符合对应具体授权；不得从“继续推进”推断未明确授予的权限。

## Project Sources

遵循 `docs/workflow/PROJECT_SOURCE_COMPACTION_POLICY.md`。Project Sources只保留短首读索引、当前状态摘要、稳定边界、Owner决定/路线摘要和必要的原始设计材料；大型历史研究、旧交接、过期状态快照与重复别名留在GitHub具名原路径/归档索引，不删除原件。不得把完整ACTIVE_STATE、TASK_CURRENT、CURRENT或全量日志复制进Project Sources。ZIP生成后由Owner手动替换Project Sources；GitHub、Project附件和模型记忆不自动同步。

## 保护边界

保持原dirty根、未提交成果、worktrees、数据库、卷、备份、候选refs、密钥和LOCAL_ONLY原证。不得盲目pull/reset/rebase/stash/clean/prune/force；不得把私密SQL、真实用户数据、JWT/密钥、设备原始日志、LOCAL_ONLY APK/证据上传公开GitHub或Project Sources。只在正式任务明确授权的范围内操作。

## 当前版本提醒（2026-10-31快照；开工仍须fresh核验）

v10.1.5整版仍PARTIAL/NOT_ACCEPTED，AC05 OPEN，G2 false，真实Push PENDING；当前交接记录中G2一次dry-run和新Debug APK+USB ADB安装已由Owner分别授权，但具体任务尚未发布/派发/执行。执行前必须fresh核验冻结合同、ledger/claim、输入资格与权限范围。不得自动合main或启动v10.1.6。
