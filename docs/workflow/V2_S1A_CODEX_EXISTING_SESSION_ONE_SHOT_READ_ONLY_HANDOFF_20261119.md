# EliteSync V2｜S1-A交给现有本地Codex的单次只读审阅Prompt（Owner已授权）

日期：2026-11-19（Asia/Singapore）  
状态：`OWNER_S1_A_AUTHORIZED / CODEX_NOT_YET_EXECUTED_BY_WEB_ADVISOR / STRICT_READ_ONLY / ONE_REPORT_ONLY`  
Owner授权：[OWNER_V2_S1A_BOUNDED_READ_ONLY_CODEX_GAP_AUDIT_AUTHORIZATION_20261119.md](../decisions/OWNER_V2_S1A_BOUNDED_READ_ONLY_CODEX_GAP_AUDIT_AUTHORIZATION_20261119.md)。  
证据目标：[集中未来证据准备包](V2_CONSOLIDATED_FUTURE_EVIDENCE_READINESS_DOSSIER_V0_1_20261119.md)、[S1原授权草案](V2_S1_BOUNDED_READ_ONLY_GAP_AUDIT_AUTHORIZATION_PROPOSAL_20261119.md)。  
治理分支：`governance/home-matching-product-freeze-20261117`（仅文档权威，不等于当前本地工程分支）。  
**使用方式：由Owner将下面完整内容贴入当前既有EliteSync本地Codex项目会话。不要创建新的无上下文Codex会话，也不要自动开GitHub Issue/工程任务。**

---

## 可直接发给现有Codex的单次指令（以下完整复制）

### EliteSync V2｜S1-A 单次受限只读工程差距核查

Owner 已在 2026-11-19 **明确授权S1-A**，仅在现有EliteSync本地Codex项目会话中执行一次**严格只读**的真实工程结构与V2已确认产品合同差距分析。授权GitHub文档：

`docs/decisions/OWNER_V2_S1A_BOUNDED_READ_ONLY_CODEX_GAP_AUDIT_AUTHORIZATION_20261119.md`

任务目标：对本地真正活动工程工作树给出**一份**可追溯、脱敏、证据定位到文件和符号的差距报告，标`PRESENT / PARTIAL / ABSENT / UNKNOWN`。**不要修复任何代码、不要运行测试、不要实际连接服务，不要把此任务转成工程开发或下一版本。**

**Authority：`S1_READ_ONLY_AUDIT_AUTHORIZED / V2_IMPLEMENTATION_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。**

#### A. 首先只读确认唯一实际工作树身份

1. **只使用你所在的现有EliteSync项目会话及其当前工作目录**。通过安全只读本地命令确认真实Git根、仓库身份（去敏remote）、当前分支、HEAD和工作区/index是否有未提交变更；不checkout/切分支、不fetch/pull、不创建/复制工作树、不改变任何文件。允许使用`pwd`、`git rev-parse`、`git branch --show-current`、`GIT_OPTIONAL_LOCKS=0 git status --porcelain`、`rg`和获准源码文件的静态读取等**非执行项目的只读命令**。
2. 历史稳定根候选`D:\EliteSync-v10-product-v1015-20261101`仅供辅助定位，**不是**当前工作树身份证明。当前工作树可能属于该仓库的另一独立worktree；以当前已有会话中真实Git根、当前项目规则和本地仓库身份为准。不要遍历磁盘搜寻“最新”工程，不能因名称相似自行切换到另一目录。
3. 若存在多个可能的活动根、repo身份不符、会话工作目录无法定位，**到此停止**，回复`IDENTITY_UNRESOLVED`及去敏证据；要求Owner确定当前根，不继续R1–R5。
4. 先读确认根目录下当前AGENTS及ACTIVE_STATE顶部和任务必需规范，按需读CURRENT_WORKFLOW，不递归历史文件。Owner现在已单独批准**S1只读这个例外**；它覆盖历史文本中“禁止全部V2工程审计”的旧状态，但不解除任何运行/修改禁令。
5. 网页GPT保存的GitHub产品治理文件不代表当前本地代码与Git同步。如果已具本地静态材料，可核已接受Owner合同；**禁止为了读取而做fetch/pull等网络或状态更改**。必要的核心规则已在下文直接写明，缺少具体源文件时标`SOURCE_NOT_LOCALLY_AVAILABLE`，不要补猜。

#### B. 明确禁止操作——比一般Codex工程长期授权更窄

- 不修改、新建、删除、格式化任何工程工作区文件；不写GitHub、不commit/push、不生成本地测试或报告文件。**最终仅在该Codex聊天回复一份完整报告**。
- 不运行项目代码、测试、Gradle/Flutter/PHP/SQL或任何构建/依赖/代码生成/迁移脚本，不启动APP/API/Web、Docker、DB、模拟器、手机、APK。
- 不连接供应商、真实身份/Push/RTC服务、外部API或生产数据库；不浏览私密用户记录、真实证件、私聊、Safety案卷。
- 不执行`git checkout/fetch/pull/push/reset/rebase/stash/clean/prune/merge`，不新建worktree，不复制项目，不更新remote，不申请系统提权。
- 不打开/输出私密配置值、密钥、JWT/token、SSH私钥、生产连接串、`.env`值、未脱敏日志。仅检查非敏感**配置键名、类型和接口**；若必须读敏感值才能确认，跳过并标`SENSITIVE_ACCESS_REQUIRED / UNKNOWN`。
- 不把源码片段、私密路径和敏感资料上传公开GitHub。报告仅包含去敏路径/符号/行范围和必要事实。

#### C. 合并核查R1–R5，不要拆成十个任务

**R1｜身份核验与关系状态（G01、G09部分）：** Lifestyle进度与报名必要条件；真实身份核验接入状态；Match提案→双方Connection→双方Messaging Consent→Conversation及Relationship是否独立、有权威确认与拒绝路径。没有真实身份核验服务就不能宣称正式Match报名可用。

**R2｜首页、受众和内容媒体（G02/G03/G08部分）：** 访客官方正文 vs 登录站内用户作品、SELF/FRIENDS/PUBLIC_AUTHENTICATED、Block；历史评论原受众∩当前作品读权；评论作者撤回、作品作者隐藏、合法独立回复与中性状态；媒体缩略图、深链、引用和缓存。若不可核受众应标缺口，不假定“已隔离”。

**R3｜来源、具名用途、派生与外显版本（G04/G05/G06）：** SOURCE/PURPOSE/AUDIENCE/SNAPSHOT独立；合法用途复用与撤销；真正受事实纠错影响的派生结果“需核查”及新发布门禁；本人预览与对外版本分离、新版仅未来合法候选、旧版当前权限。

**R4｜删除、UNKNOWN及账号隔离（G07/G08/G09部分）：** 本人作品/评论对象级删除请求规划与实际接收接口；“撤权≠受理≠完成”；高影响写入UNKNOWN先只读核验/幂等；Block/切号/迟到回包、旧缓存和失权安全返回。只读，不真正删除或提交请求。

**R5｜通知与资产静态线索（G09/G10结构）：** 通知已读≠待办完成、失效历史、双向消息许可、是否存在真实Push相关接口结构；只列已有视觉原始文件/版本记录的静态线索，**不作原43 PNG逐份二进制回读或任何动态无障碍QA**。

产品原则引用当前GitHub治理分支内具名Owner决定；关键规则索引可从`docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md`获取。若本地无该治理文件，使用本段规则作为已确认范围的**摘要**，对无法独立核实的精确规则标`CONTRACT_SOURCE_NOT_CHECKED`，不可自造新增Owner批准。

#### D. 报告必须具备的内容（一次交付）

1. **S1身份**：实际根、分支、HEAD、去敏仓库身份、dirty/index保留情况、所读层、未读层及与历史`10.1.18-dev / 1011804`不同的当前实际版本事实。
2. **R1–R5一张矩阵**：每行至少`gate_ids / Owner合同或产品概念 / 静态状态(PRESENT|PARTIAL|ABSENT|UNKNOWN) / 真实本地源码路径+符号/行号 / 静态能证实的内容 / 不能证实的内容 / 最小安全默认 / 阻断类别`。
3. **缺口聚合**：按`ENGINEERING_GAP / PRODUCT_DETAIL_OPEN / EXTERNAL_DEPENDENCY_OPEN / LEGAL_OR_EXTERNAL_FACT_OPEN`四类归并；不按每个小功能新建Issue或单独请Owner批准。
4. **重点风险与下一步建议**：列最多5项真实阻断或UNKNOWN，明确未来要什么外部、法律或动态证据；**不设计或执行修复**。
5. **证据状态**：G01–G10新运行时一律`NOT_RUN`；无设备QA/供应商回执/删除真实链则不报PASS。旧历史失败和`UNKNOWN`不自动改判。
6. **证据与敏感信息**：只返回脱敏静态证据；如果根不确定、不可避免接触秘密或遇到权限越界，则停止对应部分并明确说明。

**汇报格式**：一个可复制的中文Markdown综合报告。不要承诺随后异步执行；本次输出后停止，等待Owner把报告转交网页GPT作审阅。**不向GitHub或本地工程写报告文件**，也不自动升级权限。

#### E. 立即终止条件

身份无法唯一确认；需要访问项目外文件/生产敏感资料才能继续；只读命令试图写入代码或锁状态；相关目录不能安全定位；出现非本次授权的测试、运行、构建、网络请求或改码需求。立即停止，报告`S1_PAUSED_IDENTITY_OR_SCOPE`，只由Owner决定下一步。

**S1不是开发，授权结束即止。A6仍DEFERRED，供应商/运行时/开发/发布仍未授权。**

---

## 本交接材料状态

本文件由网页GPT保存到治理分支；**没有直连用户的Windows Codex会话，因此不能声称本地Codex已经执行或收到该Prompt**。Owner须在**现有项目Codex会话**中转交上面的单次指令；不要新建独立会话。

当Codex真正返回静态报告之后，网页顾问才能基于其具体版本身份、行号证据作后续复核；未收到前，`S1_AUTHORIZED_BUT_NOT_EXECUTED`、G01–G10动态`NOT_RUN`、外部/法律证据`OPEN`维持。
