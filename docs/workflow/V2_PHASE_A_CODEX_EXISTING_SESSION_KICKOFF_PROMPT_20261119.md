# EliteSync V2｜阶段A合并安全工程任务：现有本地Codex启动Prompt

日期：2026-11-19（Asia/Singapore）  
当前状态：`OWNER_ROADMAP_ACCEPTED / PHASE_A_IMPLEMENTATION_AUTHORIZED / LOCAL_CODEX_HANDOFF_READY / NO_EXECUTION_CONFIRMED`  
GitHub治理分支：`governance/home-matching-product-freeze-20261117`  
Owner授权及阶段A任务书的固定可读治理快照：`bc1124ae0696fb4decac936eead6ce240f65eb9f`。本文件是在该快照之后单独提交的启动说明；以分支最新治理HEAD回读为准。  
使用说明：请Owner将下方正文直接粘贴到**现有EliteSync本地Codex项目会话**。网页GPT顾问没有直接控制Windows Codex会话，不得声称本地工程已启动。

---

# EliteSync V2｜Owner授权阶段A工程执行：安全底线与旧候选版本保护

Owner正式确认S1-A后四阶段、三并行依赖的V2工程路线图，并明确指示“上述路线图审阅完毕，我认为非常完善，并且授权你开始执行”。这**是新的工程授权**，并非只读S1-A权限的延续。

**本次直接启动阶段A（A1–A4），由现有本地Codex日常自治执行与自验，不拆成十张微任务。** 阶段B/C/D属于已接受路线图的后续规划，暂不跨阶段实施；Owner将在阶段A综合审核后决定继续推进。

请只读访问固定GitHub治理快照`bc1124ae0696fb4decac936eead6ce240f65eb9f`中的以下文本作为权威；若已有本地镜像不含这些文件，不需要为了同步治理文档切换工程分支或覆盖工作树：
- `docs/decisions/OWNER_V2_ROADMAP_ACCEPTANCE_AND_PHASE_A_ENGINEERING_KICKOFF_20261119.md`
- `docs/versions/v2/V2_PHASE_A_SECURITY_BASELINE_CONSOLIDATED_EXECUTION_BRIEF_20261119.md`
- `docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md`
- `docs/workflow/V2_S1A_READ_ONLY_GAP_AUDIT_ADVISOR_ACCEPTANCE_20261119.md`
- `docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md`

固定GitHub URL格式：`https://github.com/zcx369658780/EliteSync-v10/blob/bc1124ae0696fb4decac936eead6ce240f65eb9f/<path>`。GitHub治理HEAD**不是**当前本地工程HEAD；只读获取上述治理文档足够，不自动git fetch/pull/merge治理分支。

## 1. 首先确认工程身份，保护全部现存工作

- 历史S1已确认的工程根候选：`D:\EliteSync-v10-product-v1015-20261101`；历史审阅分支`codex/ui-current-state-audit-20261116`，HEAD`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`，仅为当时快照。
- **不可操作**`D:\EliteSync-v10`原main脏工作树：历史上43项未暂存修改、213未跟踪条目；不得覆盖、清理、迁移、stash或重置。也不得清理候选根中现存未跟踪文件。
- 在现有Codex项目会话，用无副作用方式核对当前实际Git根、仓库origin、branch/HEAD、dirty/index、项目规则/活动状态，辨认当前安全的工程开发来源。不要仅凭路径名假定合法可写。如果当前根与候选不同或存在多个活跃工作树而无法唯一判断，**停止会影响未提交数据的操作并报Owner**。
- 在身份清楚、保护现存数据后，可自行选择**隔离开发分支或新工作树**承接阶段A，命名及本地提交组织由Codex按本地优先工作流管理；避免checkout覆盖未跟踪文件，不在脏main直接改码。GitHub仅可作为非main脱敏备份，不得自行合main或发布。
- 这里**允许对获准阶段A工程代码实施修改并运行隔离自动化测试**；原S1-A“严格只读”是已经结束的历史权限，不能再错误地当作阶段A禁令。

## 2. 实施范围：一张阶段A任务包含A1–A4

**A1｜身份与真实Match fail-closed**
审查`TrustedIdentityService`、资格/报名/自动参与、MatchingRound与正式Relationship相关读取/写入入口，将DEV_SYNTHETIC_VERIFIED等合成测试凭据严格隔离在合法TEST_ONLY路径。真实KYC未接入时任何正式报名、真实自动参与、候选正向公布与受真实身份前提保护的关系操作不得凭模拟结果绕过。保留合法Lifestyle和独立社交功能。后端门禁是关键，前端提示只是辅助。

**A2｜旧候选绑定原有合法形象版本**
修正`SlowDatingService::projectLocked`读取当前发布版导致旧候选被动升版的风险。将匹配候选/提案与当时**合法可见**发布快照安全绑定；新发布只默认影响未来新合法候选，旧候选仅在当前受众/Block/业务许可仍允许时读取原版。历史版不可证则保守隐藏，不回填新版/不虚构旧记录；迁移设计须可追溯且只在隔离测试库执行。

**A3｜UNKNOWN先查询权威结果再决定**
修正`LifestyleController::load`存在pending即自动`retry()`的风险。对请求超时、回包丢失、重登/重启、账号切换先有权只读核原请求及业务版本；若已成功正确回显，若未成功且具备幂等/权限前提才提示用户选择安全重试，仍UNKNOWN则维持UNKNOWN，不自动重发高影响动作。检查本阶段覆盖的提案/连接/消息许可/发布有无同类高危模式，必要时统一修正，但勿扩大为全面重写。

**A4｜旧受众/缓存/深链保守保护**
本阶段仅做与A1–A3有关的必要失权、防泄漏与旧受众安全阻断回归。历史第三方受众未知时不能推定可读，不开放新PUBLIC_AUTHENTICATED域。完整首页/评论树与对象删除功能留阶段B/C。

## 3. 实际实施与安全测试权限

允许：阶段A相关Flutter、Laravel/API、schema**定义文件**与安全迁移、已有和新增自动化测试、PHP/Flutter静态分析、测试环境内的单元/Widget/隔离服务级联测；Codex自治选择安全任务拆解、写本地代码/提交和脱敏结果，必要时对GitHub非main分支做安全备份。

禁止：真实身份/Push/RTC供应商连接或采购、生产/共享数据库迁移、使用真实个人身份资料与真实聊天或Safety案卷、真机/模拟器、生产服务、main合并/发布、正式A6会议、越过阶段A去做B/C/D全面功能、NEW-PC-04/05新产品权利。阶段A没有真实KYC成功联测权限或条件；不得为了测试伪造“真实认证已通过”。
若必要的隔离测试配置不存在或环境身份未知，先停止相关高风险测试，记`ENVIRONMENT_UNAVAILABLE`，不借助生产资源补齐。

## 4. 合并AC：不要逐个向Owner申请

至少提供A1真实性与非生产例外、A2旧候选仍绑定旧合法版/失权隐藏、A3丢回包或UNKNOWN绝不自动重复提交/身份变化阻断、A4旧受众/媒体/旧深链/Block安全拒绝的**正向、反向、未知**证明；同时保护现有Lifestyle、SlowDating、Connection、Messaging Consent与社交功能回归。

每项测试必须记录执行环境、真实命令、代码/测试身份、结果和失败/未运行内容；`PASS/FAIL/PARTIAL/UNKNOWN/NOT_RUN`准确分开。不能因TEST_ONLY通过就将正式KYC或G01–G10整体标PASS；没有设备实测则设备专项保持NOT_RUN。可在隔离测试数据/库中执行安全迁移验证，严禁任何真实业务库操作。

## 5. 唯一综合交付与停止点

完成阶段A后，在本**同一个Codex会话**交付一份中文综合报告，包含：
- 实际根/工作分支/HEAD、原有数据与工作树保护方式、代码提交和必要diff；
- A1–A4每组已完成内容与源文件/具体符号、具名Owner规则引用、独立安全门禁；
- 真实自动化测试命令/结果/失败/未运行场景及隐私安全脱敏证据；
- 真实外部/法律/设备/43 PNG及历史BUG/UNKNOWN阻断，尤其正式KYC和真Push继续未接入；
- 一份`PHASE_A_PASS / PARTIAL / FAIL / UNKNOWN`工程自验建议，阶段A剩余风险及后续建议。

**阶段A报告交付后停止自动转入阶段B。** 本轮无需每项微任务回报Owner确认；Owner将集中转交网页GPT进行阶段性验收，随后决定是否继续下一阶段。GitHub是备份而不是派单中心，正式产品发布/main合并绝不由本任务自动发生。

Authority：`OWNER_ROADMAP_ACCEPTED / PHASE_A_ENGINEERING_AUTHORIZED / PHASE_B_C_D_PLANNED_NOT_STARTED / A6_MEETING_DEFERRED / PRODUCTION_RELEASE_NOT_AUTHORIZED`。

---
