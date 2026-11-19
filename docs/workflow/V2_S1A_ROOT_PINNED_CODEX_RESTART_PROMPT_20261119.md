# EliteSync V2｜S1-A 已定唯一根与远端治理只读访问：Codex重新启动任务单Prompt

日期：2026-11-19（Asia/Singapore）  
状态：`OWNER_ROOT_AND_GOVERNANCE_READ_CONFIRMED / S1_A_READY_FOR_OWNER_TO_HAND_TO_EXISTING_CODEX / STRICT_READ_ONLY / NOT_YET_EXECUTED`  
仓库：`zcx369658780/EliteSync-v10`；治理分支：`governance/home-matching-product-freeze-20261117`  
本次**固定Owner补充授权证据提交**：`6af426b14cf6571c2de1d24281b03ca24e03c634`。此提交已包含早先S1-A授权文件、证据包与新补充授权；**产品治理提交不等于本地工程提交**。

## 向现有EliteSync本地Codex项目会话完整粘贴以下指令

---

# EliteSync V2｜S1-A 只读工程差距审计——从IDENTITY_UNRESOLVED恢复

Owner现在**明确确认并授权**：
1. 本次R1–R5唯一工程审阅根：`D:\EliteSync-v10-product-v1015-20261101`。
2. 允许通过现有GitHub连接器或受控HTTP GET，**只读**获取`zcx369658780/EliteSync-v10`治理分支**固定提交`6af426b14cf6571c2de1d24281b03ca24e03c634`**内的指定文本文档（不执行`git fetch/pull/clone`、不写入本地、不改变Git状态）。

这是之前已确认的**S1-A一次性只读审计**所需身份和文档来源补充，**不是**新版本开发或测试授权。请在**当前现有EliteSync Codex会话**内完成，不新开会话，不派子任务，不开启多个独立审批或工程Issue。

## A｜先做目标工作树静态身份核对（不要再以原会话CWD选根）

前次只读核对已发现：
- 原会话目录`D:\EliteSync-v10`：`main` / `4bebc8f394248e254c1368a06fbdee5d2c883301`，43项未暂存、213未跟踪；**明确排除为本次R1–R5审阅根**，不编辑、清理或扫描其业务文件。
- **Owner指定目标**`D:\EliteSync-v10-product-v1015-20261101`：当时`codex/ui-current-state-audit-20261116` / `1d8b485bf4f314d42431bb62a293a3fef9e9c8af`，暂存区空、1个未跟踪；两工作树origin当时均为`zcx369658780/EliteSync-v10`。

请在**指定目标绝对路径**使用无副作用只读方式确认：目标存在，`git -C <target> rev-parse --show-toplevel`、`git -C <target> rev-parse HEAD`、`git -C <target> branch --show-current`、去敏`git -C <target> remote get-url origin`、`git -C <target> status --porcelain`（如可用，关闭可选Git锁并避免产生任何缓存写入）。记录实际分支/HEAD/dirty/index，不将前次数据假装当前数据。**仅凭目标目录dirty或未跟踪存在不能自动否定Owner指定**；不能读写或清理这些未提交材料。

若工作树根不同于Owner指定路径、remote仓库身份不符、路径不存在或存在无法解释的工程身份冲突，立即停为`S1_PAUSED_IDENTITY_DRIFT`；若HEAD/branch与前次不一致，列差异并判断能否只读追溯合法活动树，无法确认则停止，不自行切回旧提交。

**不要**遍历D盘、checkout/chdir切业务工作树、创建worktree、stash、fetch、pull、reset、merge、clone或改变任何本地/远端仓库状态。可在不改变会话目录的情况下使用`git -C`和指定目标绝对路径进行**静态只读定位**。

## B｜先读GitHub固定治理来源（不能要求本地工程分支中存在这些文件）

治理仓库：`zcx369658780/EliteSync-v10`；固定Owner授权快照commit：`6af426b14cf6571c2de1d24281b03ca24e03c634`。

优先只读以下五个GitHub**文字**路径（可通过GitHub连接器或受控GitHub GET，禁止写本地）：

1. `docs/decisions/OWNER_V2_S1A_ROOT_AND_REMOTE_GOVERNANCE_READ_SUPPLEMENT_20261119.md` — **本次唯一根+远端只读新授权**。
2. `docs/decisions/OWNER_V2_S1A_BOUNDED_READ_ONLY_CODEX_GAP_AUDIT_AUTHORIZATION_20261119.md` — **原S1-A一次性只读授权边界**。
3. `docs/workflow/V2_CONSOLIDATED_FUTURE_EVIDENCE_READINESS_DOSSIER_V0_1_20261119.md` — **G01–G10未来证据与保守阻断矩阵**。
4. `docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md` — **具名Owner产品合同索引**，必要时从固定提交内按需读取具名Owner决定，不递归下载全部历史。
5. `docs/workflow/V2_S1A_CODEX_EXISTING_SESSION_ONE_SHOT_READ_ONLY_HANDOFF_20261119.md` — **前序R1–R5一次性核查详细范围**。

固定只读文件URL形式为：`https://github.com/zcx369658780/EliteSync-v10/blob/6af426b14cf6571c2de1d24281b03ca24e03c634/<上述path>`；也可用连接器读取相同`ref`。**不要将固定治理commit当成本地审计HEAD**。

若目标GitHub文档访问不可用，**不要**通过`git fetch/pull`、切分支、将文档下载到当前工作树或扩大网络权限来规避；记录`GOVERNANCE_SOURCE_UNAVAILABLE`及具体失败，无法确认合同的部分标`CONTRACT_SOURCE_NOT_CHECKED`，如无法可信地执行比对则停。旧本地AGENTS或ACTIVE_STATE的`CODEX_NOT_AUTHORIZED`仅代表S1授权前或本次S1以外的工程权限；本次有限Owner具名文件优先，但仍严禁工程执行。

## C｜R1–R5合并静态核查（无需拆成十个任务）

按当前目标工作树只读审阅**非敏感**源码、接口声明、数据库schema/迁移**定义文件**、现有测试源码、必要架构说明；不读取真实数据库或运行日志。每组输出实际源码路径+符号/行号、静态证据与限制：

- **R1 / G01、G09部分**：Lifestyle、真实身份核验接入状态、匹配报名资格；Match提案→双方Connection→双方Messaging Consent→Conversation/Relationship各自独立和拒绝/撤回/待处理规则。
- **R2 / G02、G03、G08部分**：官方访客/用户登录内容域、SELF/FRIENDS/PUBLIC_AUTHENTICATED、Block、历史评论原受众与当前作品读权、评论撤回/作品作者隐藏/独立回复、媒体/引用/深链/缓存。
- **R3 / G04、G05、G06**：SOURCE/PURPOSE/AUDIENCE/SNAPSHOT、用途许可与撤销、受影响派生结果需核查、本人预览与外发版本、新匹配版默认只影响未来有权候选及旧版现权。
- **R4 / G07、G08、G09部分**：本人作品/评论删除申请与真正受理/完成回执是否不同、UNKNOWN时的只读结果核验和幂等、跨账号迟到回包/失权防泄露。
- **R5 / G09、G10静态部分**：已读与待办分离、失效通知/合法返回、真实Push接入的源码结构线索；原43 PNG资产**仅查静态路径清单**，不校验二进制真实性或宣称上传完成。

每项静态结论只可为`PRESENT / PARTIAL / ABSENT / UNKNOWN`。缺少访问权限/静态证据时用UNKNOWN；不能把找到类型或注释等于运行时PASS，也不能把未读工程层判ABSENT。

## D｜严格停止与隐私边界

**本次允许的唯一外部访问是GitHub上述固定文档的只读读取。** 禁止真实身份核验/Push/RTC/其他外部API或生产系统请求；禁止项目代码执行、测试、构建、依赖安装、迁移、数据库读取/写入、模拟器/手机/APK、Git状态变更/提交、代码和配置修改、报告落盘或上传GitHub。

不读取或输出.env/secret/token/SSH key/真实身份证明/私聊或第三方敏感记录；如无法安全判断，跳过并记`SENSITIVE_ACCESS_REQUIRED / UNKNOWN`。不要改变`D:\EliteSync-v10`中43项未暂存和213个未跟踪，也不要改变审计目标中的任何未跟踪/脏状态。

动态G01–G10均维持`NOT_RUN`；真实核验与Push供应商、法律依据、43 PNG远端真实性及旧`10.1.18-dev / 1011804`历史`UNKNOWN/NOT_RUN`不得被本次静态审计改判。

## E｜唯一交付：当前Codex会话回复一份中文综合报告

报告一次性包含：
1. 固定Owner授权及治理commit、实际**目标**root/branch/HEAD/remote/dirty与前次快照对比（脱敏）。
2. R1–R5静态证据矩阵：`G编号 / Owner合同 / PRESENT|PARTIAL|ABSENT|UNKNOWN / 真实源码文件+符号/行号 / 可证实事项 / 未证实事项 / 保守阻断`。
3. 聚合后的工程差距、外部/法律证据缺口；最多5项最高风险与建议，禁止自行执行修复。
4. 逐项声明哪些G或真实动态QA未运行；不能把源码静态存在叫做APP/API/设备PASS。
5. 若任何步骤被阻断，说明停点、最小待Owner裁决事项；不要自动升级权限。

只在**原有Codex对话**返回完整中文Markdown报告，**不创建本地报告文件、不commit/push、不在GitHub发Issue**。完成即停，Owner会把报告交网页GPT顾问复核。

最终Authority：`S1_A_OWNER_AUTHORIZED / ROOT_PINNED / GITHUB_GOVERNANCE_READ_ONLY_AUTHORIZED / V2_IMPLEMENTATION_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。

---

## 顾问存证说明

本文件是准备给Owner手动转交的启动文本。网页GPT并未直接调用Owner Windows Codex会话或审阅真实工程；即使本文写入了GitHub，仍是`S1_RESTART_PROMPT_PREPARED / CODEX_NOT_YET_RESUMED`，不得冒充R1–R5结果。
