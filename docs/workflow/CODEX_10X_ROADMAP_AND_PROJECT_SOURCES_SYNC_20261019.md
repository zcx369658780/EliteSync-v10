# EliteSync 10.x｜路线图、Owner决定与项目源一次性同步任务

日期：2026-10-19。任务类型：**DOCS_ONLY / OWNER_AUTHORIZED_SYNC / NO_PRODUCT_IMPLEMENTATION**。

Owner已经要求生成后续路线并由Codex同步。将本任务及配套文件转交当前EliteSync-v10 Codex，即授权本次文档范围执行；不需要再次询问是否同意路线准备，不自动生成下一功能版plan或执行功能代码。

## 1. 目标

将Astra本次产出的路线、Owner产品决定与12份项目源安全落入当前本地EliteSync-v10和GitHub。必要入口更新为同一条最新方向，保留历史正文、原冻结计划与验收、旧未完成项。只完成一次集中同步和回报，不发后续微任务。

本次文件包以本地实际附件/解压位置为准。不要假设ChatGPT的`/mnt/data`存在于Windows，也不要把本文建议的目标路径当作源文件已落地。先在Owner给定附件或当前任务目录读取；确实找不到只请求这份包的位置，不扫描全盘/其他项目/全会话记录。

## 2. 输入与身份

- `repository_payload/docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md`：规划正文。
- `repository_payload/docs/decisions/OWNER_PRODUCT_DECISIONS_20261019_LONG_TERM_RELATIONSHIP_V1_0.md`：Owner决定补充。
- `repository_payload/docs/workflow/CODEX_10X_ROADMAP_AND_PROJECT_SOURCES_SYNC_20261019.md`：本任务。
- `project_sources/`：12份上传项目源，其中06/07及旧竞品研究附件是原件。
- `MANIFEST.json`：每个输入相对路径、字节数、SHA-256；校验实际内容，不以文件名代替身份。

编制时实际main=`d58729c461f22b5281fc5a8a08d038ac3d49ca60`，Tree=`498e1acfe26d15b33124bf5e2774981b5bf6153a`；apps=`fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7`；services=`29cedff599411c7c246ba32e62d53b5d63e28f3f`。执行前重读实时main。若main前进，保留并发内容，不退回旧SHA；以本轮真实基线产品子树未变为证据，不机械用历史SHA覆盖后继产品。

## 3. 执行方式与保护

读取实际AGENTS、CURRENT_WORKFLOW、PRODUCT_DECISIONS、CURRENT_STATE和DOC_INDEX_CURRENT。核验现有专用工作树与三个受保护根的身份，在安全干净的docs-only基线上接续；不要在原D:/EliteSync-v10或旧D:/EliteSync的dirty根做pull/reset/rebase/stash/clean。已有v10.1.0候选也不切换/覆盖。

只对实际触及的文档、HEAD/index/status保留必要前后记录；不为本次强制创建完整worktree、不全量重算历史资产。允许正常读取/获取Git对象与一次普通docs提交/非强制发布；不强推、不删除分支或重写Git历史。

## 4. 精确新增范围

A. 原样接入三份正文：
- `docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md`
- `docs/decisions/OWNER_PRODUCT_DECISIONS_20261019_LONG_TERM_RELATIONSHIP_V1_0.md`
- `docs/workflow/CODEX_10X_ROADMAP_AND_PROJECT_SOURCES_SYNC_20261019.md`

B. 将`project_sources/`中的12份文件原样镜像到：
`docs/gpt-project-sources/20261019_10x/`

其中06/07和旧研究原件必须逐字节相同，不能格式化、改行尾或把旧正文改成新版口吻。08/09是本次新增决定/路线的镜像，与A中正文保持相同SHA-256。它们是快照，不为填自身commit反复改写。

C. 唯一完成回执：
`docs/workflow/10X_ROADMAP_SYNC_RESULT_20261019.md`

## 5. 精确允许的既有文档更新

只新增一段简短当前指针或维护明确当前部分，不覆盖旧长文：
- `PRODUCT_DECISIONS.md`：链接新决定，简记长期关系/独立搭子、隐私上限、内部风险不公开、AI非终裁、请求非直私信、未来条件收费/活动方向。
- `CURRENT_STATE.md`、`DOC_INDEX_CURRENT.md`：路线已同步；v10.1.0原PARTIAL/AC08保持；下一功能包只有PLANNED，尚未冻结/实施。
- `docs/versions/README.md`：登记1.1～1.7及条件10.2.x为PLANNED/CONDITIONAL，不批量新建版本目录/plan。
- `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`：顶部明确新规划入口，保留下方旧五包/D6原文与日期。
- `docs/architecture/RESTORATION_CAPABILITY_MATRIX.md`：只新增“恢复欠账→新规划归属”摘要，不把待办行从PARTIAL/UNKNOWN改成PASS，不删A03/A08/A09。
- `docs/gpt-project-sources/PROJECT_SOURCE_INDEX_ELITESYNC_V10.md`（存在时）：短链接至新版本化项目源索引，旧正文不批量重写。
- `AGENTS.md`或`docs/workflow/CURRENT_WORKFLOW.md`：仅在确有旧路线入口需要接续时添加指针；不改角色、权限/运行授权、不恢复Work/dot。

不修改其他无关文档，不重新发布历史研究报告或附件原图；原matrix候选仍按固定提交引用，不为了读到它盲合研究/产品分支。

## 6. 关键语义检查

- 新Owner方向是确认过的；Astra的版本拆分是规划，不是已完成/已冻结/已获逐版运行授权。
- 明确1.0 PARTIAL并不阻塞未来一切研发；可在首功能版以新冻结合同验证有用的候选适配，但本同步不合任何产品。
- 本次没有将14领域/24候选都直接批准。搭子已确定独立；费用/认证供应商/请求额度/活动字段等仍待版前。
- 明确陌生人请求≠消息同意，好友≠恋爱；正常拒绝/取消/拉黑≠违规；内部记录不公开；AI不能终裁。
- 没有将debug核验/模拟Push/支付/人员账户当真实服务；详细解释/员工服务是条件阶段，不会当前收款/招募/招聘。
- 本地数据库备份不入Git，与保留既有云端运行库并不冲突。
- 06/07历史设计原件与新08/09增量分开；旧文件中的M5/Work/阶段候选等是历史，不覆盖新入口。
- 如发现旧记录SHA抄录不一致，当前回执使用实际Git对象，另记观察；不要趁本次改写旧验收或重开算法审计。

## 7. 最小验证及普通发布

完成Markdown链接/相对路径/UTF-8/代码框完整性、文件manifest、原件hash、文档diff允许范围检查；仅新文档行尾/格式问题可修，已接受原件字节不改。处理少量文本/路径错误并留原始退出结果，不把首次格式失败升级成新的整套审查。

明确产品文件零变化：apps/services/题库/依赖/测试/构建/运行脚本/数据库结构不变。确认未增加secret、证件、生辰、私聊、数据库、APK实体或原始设备证据。

优先使用现有安全docs基线，必要时分支`codex/docs-10x-roadmap-sync-20261019`，普通non-force提交和推送本次文档至main。若并发需要PR，依仓库现行保护完成，不以force或绕规则处理。发布后直接回读最终Commit/Tree、三份正文Blob、源包原件与产品子树。完成回执保存本次基线和校验结果；包含回执的最终commit在集中回复给出，不把文件自身hash写回自己导致循环提交。

## 8. 明确不做

不修改/运行产品代码或测试、不构建安装APK、不启动/关闭云端8服务或本地隧道、不查询/迁移/恢复数据库、不改公网/443/证书/备案、不调用身份/信用/支付/AI供应商、不发邮件、不新建提醒/监控、不清理旧原证/临时审阅分支、不自动启动v10.1.1或其它功能版本。

## 9. 唯一集中交付

回报：实际读到的包身份、前后main/Tree、变更文档清单、关键Blob/SHA、原件保留检查、apps/services/题库未变、原dirty保护范围、本地同步目录/分支、普通发布及回读、全部NOT_RUN、仍未执行的下一功能版。

完整完成出口：`DOC_SYNC_COMPLETE / ROADMAP_AND_PROJECT_SOURCES_ALIGNED / PRODUCT_TREES_UNCHANGED / NEXT_FEATURE_VERSION_NOT_STARTED`。
只有本地完成而远端失败则报`LOCAL_SYNC_COMPLETE / REMOTE_SYNC_BLOCKED`，不得说GitHub已同步。没有真实新增差异则`ALREADY_COMPLETE / NO_CHANGE`并复用已有有效回执。完成后停止，等待Owner/Astra继续，不生成下一张功能任务单。
