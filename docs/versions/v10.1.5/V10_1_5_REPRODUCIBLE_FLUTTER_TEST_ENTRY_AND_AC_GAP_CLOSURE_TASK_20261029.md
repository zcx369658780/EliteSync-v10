# EliteSync v10.1.5｜可复现Flutter测试入口固化＋AC01–11功能验收差距集中收口——Owner正式综合任务

**状态：OWNER_APPROVED_TOOLING_ENTRY_AND_ACCEPTANCE_GAP_CLOSURE / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NONPRODUCTION_TOOLING_IMPLEMENTATION_AUTHORIZED / NO_NEW_FLUTTER_OR_DB_RUNTIME_BUDGET / AC05_OPEN / NO_G2_GRADLE_DEVICE_PUSH / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-29（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner授权及真实交付目标

Owner阅读Astra对`5aa3fc63` Flutter Widget/unit有界验收后明确批准：**“Flutter测试工具入口固化＋v10.1.5功能验收缺口集中收口”**，要求继续。该授权属于一项综合**工具实施＋接受条件证据治理**任务，不是重复上轮环境问题的只读预检，也**不是**默认授权新的Flutter测试、数据库启动、Gradle/G2、APK、真机、真实Push或产品main集成。Owner是不可逆产品决策和高风险运行权威；Codex仅在Owner手动派发后实施并STOP等待Astra。

本轮必须完成两个可检查成果：

**A. 工具入口落地（真实代码，不只是计划）：** 在固定候选基础上实现独立、可复现、**非生产**Flutter Widget测试工具入口。它应能将一份经核来源的Flutter3.41.7、Dart3.11.5、`hooks_runner-1.0.1`、离线packages和固定源码定位成**task-owned**执行工作面；预检版本/Hash/允许的输入、禁用不明进程/共享SDK写面、约束日志与预算；并可生成/应用已审阅的**只在私有拷贝上生效**的最小Hook适配。不能把之前LOCAL_ONLY里的私人路径或完整第三方私有补丁原件直接上传GitHub，也不能靠降低守卫来声称修复。新增安全的可审源码入口及定向测试源/说明后，验证其静态行为和失败保护；只有新的Owner实际运行授权后才能执行真正Flutter工具/Widget，不能借“固化”隐式开启新的6批。

**B. 功能验收差距实际收口：** 直接对冻结`AC-10.1.5-01～11`逐项读取权威计划/代码路径/历史Astra裁决，将现有已接受、部分、外部门禁、尚缺证据全部准确绑定Git Blob/执行回执来源；形成一份**可直接供下一次Owner决策和Astra独立功能验收使用**的`AC_GAP_MATRIX`、风险优先级和最小有界后继测试/修复组合，而不是再写泛泛“尚待真机”。不得因本轮文档已写而将AC自动置PASS或关闭。

**冻结编号必须正确**：原计划F1=消息可靠性；**F2=RTC稳定性/音质**；**F3=可信登录时间、加密离线只读/清理**；**F4=通知偏好/权限/真实Push预留**；F5=具名旧资产判断。前轮软件任务某些F1/F2/F3缩写按当时场景意图引用，但不改变冻结F2/3/4定义。AC-05是**RTC保护/有界质量**的具体接受条件，同时总状态`AC05_OPEN`持续。

## 1. 固定Authority、源码身份与历史证据

开工必须fresh读GitHub live main/Root/`docs/workflow/ACTIVE_STATE.md`、本正式任务全文及真实Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/workflow/CURRENT_WORKFLOW.md`及冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。签发前main `519672942e3697d8b3c7918d95619600feed658a`、Root `3b06491b8c1d95ba1be9dd5e2151a16d51fb816f`仅为时间锚，签发后以实时回读为准。

- 本轮唯一普通non-force**开发候选Parent**固定`5aa3fc631dd7b450888c794182a1a8b35d57ec0a`，Root `2db8c8c509ffebb3b02169c23b99b34261f0424a`，apps `798049a15eb33fec16acdd37d83a07af0ed181b5`（729 Blob），services `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 Blob）。这是**有界交付被Astra接受**、未合main的候选，不是主线整版产品。
- 最新Astra独立审查报告：`astra/v10.1.5-5aa3fc63-flutter-private-widget-review-20261029:docs/versions/v10.1.5/5AA3FC63_FLUTTER_WIDGET_PRIVATE_PATCHED_RUNNER_ASTRA_REVIEW_20261029.md`，Blob **`715bc340042675df86a0c791c49eb1852bb9b5ce`**，审查分支HEAD `1c98998f575254187cec30663ba1137b3af0a476`。上轮Codex报告 `docs/versions/v10.1.5/FLUTTER_WINDOWS_HOOK_SAFE_WIDGET_RECOVERY_REPORT_20261029.md` Blob **`f85cddc77ec32c60ffd4726e59bb1e4dc6de1530`**，索引 `flutter_windows_hook_safe_widget_evidence_index_20261029.json` Blob **`657deb5e748a7d0d216b5b1c589ed3b86254734f`**。
- 服务端有界证据来自`15b23d8cacfa1429f6f77b8d57a86fff6b827673`及Astra报告Blob`dc5a6d21e9c22f8e28b81cec7317aa740c9bd8db`：MariaDB10.11.19 **23 Feature/152断言**、两连接同键及HTTP权限负例（Codex本地执行回执）；Flutter analyze exit0。客户端来自`5aa3`：**11文件77/77 Widget/unit**，测试在**任务私有补丁Runner**下通过，Astra未在Windows现场复跑。其前一任务6/6批已耗尽。
- 现行main唯一已接受v10.1.4产品apps Tree **`3468a3dd97da7accfda2539a0f8d8f68931a6110`**、services Tree **`0cb1f9d19659291a462488b3686fd0a07a6698ac`**。所有文档源和终态均须正确区分main产品与尚未接受v10.1.5候选。
- 老事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`永久封存；旧18件、两ACL实验根、122原证、五根、527refs、3183 Seed、历史失败/旧账本/dirty worktree不可清理、改写、误用作测试夹具。旧APK/G各1/1耗尽，旧A关闭；G2历史条件余额不构成许可。

## 2. 非生产可复现Flutter测试入口：必须有真正工具成果

在固定`5aa3`产品源码基础上新增一组明确归属的**repo tracked 非生产测试工具**，建议放在`tools/v1015/flutter_widget_test_entry/`（如已有同名路径则先核对再决定唯一实际目录；不得覆盖历史）。只允许工具源码、最小公开配置schema、任务私有patch生成/校验代码、单元/合成fixture、操作说明；不得提交`vendor`、缓存、SDK、源私有绝对路径、凭据、真实USER环境、未经审核第三方完整源码副本或历史LOCAL_ONLY raw。

最小交付合同：
1. **受控输入**：固定Flutter3.41.7/framework `cc0734ac716fbb8b90f3f9db8020958b1553afa7`、Dart3.11.5、`hooks_runner 1.0.1`、已经核过的原/补丁SHA256 `f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9` → `7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc`，diff SHA256 `9d7f7883e34bbe451d364b89b03d4acab6c30d00d1f4d9081f562708b6e7f119`。输入是本地已有可信**只读**来源或以内容Hash锁定的新私有副本，不能自动下载/联网pub get/升级。源Hash不匹配或补丁不可复现必须fail-closed，标`PATCH_REPRODUCTION_BLOCKED`，**不能猜测源码/自行编造与原Hash不一致的新补丁却标成原已验证**。
2. **纯私有输出**：每次可创建task-owned新的唯一目标根，其logical/allocated必须受调用时明确授予的预算控制；默认`DRY_RUN_ONLY`、`EXECUTE_DISABLED`。不得写原Flutter SDK/旧私有SDK、原Pub缓存、旧workspace、旧Git refs、任何系统目录；检查canonical路径与reparse/hardlink穿透；调用者只能将既有源**复制**为新的安全目标，不能借绝对路径指向保护目录直接运行。
3. **Hook直启策略**：明确Windows`runInShell:false`只对具名绝对、真实私有`.exe`安全评估；`.bat/.cmd`即使false仍可能走shell；拒绝`cmd.exe`、PowerShell、未知PATH解析与配置中隐式执行；验证调用的`compile kernel`和`kernel --config`等准确参数模式、工作目录、环境键规范化、输出/depfile、JSON绝对URI、stdout/stderr/exit/错误传播。不能禁用native assets hooks、改业务断言或把系统shell放白名单求PASS。
4. **最小可复制补丁**：优先提供**不含私人路径**的确定性patch recipe/差异应用器，并锁原/目标Hash及策略版本；补丁只落在调用时新建的task私有Pub包目录。以前补丁全文LOCAL_ONLY且未上传GitHub，Codex若不能根据原本地可验证内容以完全一致Hash安全再现，就应保留`PRIVATE_PATCH_SOURCE_NOT_AVAILABLE`，提供受控手动输入/复审入口而不是生成一个“看起来等效”的假原补丁。不得把patch应用到正式`pubspec.lock`、生产SDK或共享插件。
5. **前置守卫**：提供两阶段使用体验：`inspect/plan`默认**无任何Flutter/Dart子进程**；`prepare`只在任务具名私有根且明确提供预算/授权时复制和补丁，仍不运行Flutter；`execute`必须检查**新的明确Owner测试执行授权**、独立持久ledger和剩余批次后才可能激活。本轮仅实现、校验`inspect/prepare`的源逻辑（见第4节），不得运行真实execute。必须给出示例CLI、输入配置、预计写入范围、失败状态/退出码、恢复时不双重复制/启动和脱敏示例回执。
6. **回归保护**：独立的fake filesystem/字符串/临时合成输入测试源必须覆盖源/版本Hash失配、绝对目标与上穿、链接/硬链接、重复执行/断裂ledger、过期预算、未授权execute、shell/批处理拒绝、参数注入、旧路径交叉、残留原patch、非预期Hook缺失。不得声称此类静态/合成测试证明真实系统沙箱或者原版工具已修复。
7. **可持续适用**：本工具入口应能由后续同版任务重复引用，绑定明确版本和源证身份；任何不同Flutter/hook依赖版本都需重新核hash/审查，不要将临时私有补丁全局化或永久潜入产品运行时。非生产工具可随候选提交用于Astra审阅，但**不自动纳入main产品apps/services或标准SDK**。维护“已复现源/需要LOCAL_ONLY补丁/已具备真实运行授权”三种可区分状态。

## 3. 冻结AC逐项证据映射与收口矩阵

生成**完整的AC01～AC11**矩阵，行至少包含：
`ac_id`、冻结AC原文可观察终点、F模块归属、当前源/代码路径、直接Git Blob/Commit、已接受Astra报告及实际`CODEX_REPORTED_LOCAL_TEST`类型、是否在本轮实际重测、`DIRECT_GITHUB_OBJECT / LOCAL_ONLY_RAW / NOT_RUN / NOT_PROVEN`分级、达到的子合同、尚缺真实行为、风险严重度及隐私/授权影响、是否受外部真实设备/供应商门、**最小下一合法验证**与预算/依赖/Owner决策、当前`PARTIAL/OPEN/OUT_OF_SCOPE`。不把测试通过数换算AC完成百分比，不因某个AC只有外部Push就偷偷关闭其余客户端软件部分。

特别强制分清：
- AC01 main/旧证保护与新候选身份/数据库资格：已存在的合成库证据不是最终生产DB/设备；
- AC02–03 消息端到端、重放、Block/MC/CN、旧媒体与多账号晚响应：MariaDB+Flutter Mock分别有据，**APP→真实API→DB**同场景及丢包/回读仍不足；已取两连接不等于锁等待可观察事实；
- AC04 真实图片/短视频200/206、附件状态、失败/撤权：仅当前代码和有限后端证据不意味着真实Android APP媒体链通过；
- **AC05 RTC/AEC**必须标`OPEN`：无已批准真实设备下的通话保护/音质，不可用上一轮“F2离线测试”替代RTC；冻结计划对5秒media stop要求仍在；
- AC06–07 登录T0/15/30与私有密文：真实服务端合成时间/Flutter Mock已经存在，但物理15/30天、跨进程Device Keystore、实际清理和离线重启用户路径不能推为已证；
- AC08–09 通知隐私/权限与Push：真实私有API与Flutter mock各有测试，OS权限/锁屏后台送达/物理设备绑定仍未证，`REAL_PUSH_PROVIDER_PENDING`必须保留；
- AC10 同一APK/后端/持久库、重启以及构建/安装/版本制品仍未闭合，旧G2/Gradle不能越级；
- AC11 报告/manifest、独立审查与未来集成分开，当前候选不是最终版功能ACCEPTED或safe main merge；
- F5 “语音留言旧附件/地图地点”只做具名来源/范围对照，UNKNOWN或OUT_OF_SCOPE要如实保留，不重造功能。

允许同任务撰写**下一门最小有界验证方案**：先按已有证据消重，区分无需再测的已接受子合同、需要新客户端/服务端整体运行的子合同、必须Owner另批真实设备/系统/供应商/构建/G2的子合同。标注关键依赖与总风险、推荐次序，不替Owner决定放行或修改原AC。最终矩阵须让Owner一眼知道“软件层证据已达到哪里、真正阻断版接受的是什么、下一步授权具体买到什么证据”。

## 4. 本任务可执行与绝对不允许

**本轮为工具源码实施与证据治理，不授予新的Flutter/analyze/test批次或MariaDB/API Popen。** 上轮`V1015_WINDOWS_HOOKS_WIDGET_RECOVERY_20261029` Flutter6/6耗尽、独立MariaDB原任务Popen2/2耗尽、API原任务1/2（剩1但本任务未授权）。不得退款、继承未用API作为新许可或重复上一轮真实77测试。旧Gradle/APK/G、旧A关闭，G2 Popen/claim本任务0，原18/ACL/new fixture/受限child/14矩阵也0。
- 可以在**新的task-owned独立源码工作面**撰写非生产入口源码、脱敏配置/文档和合成输入单测源码，运行完全不需要Flutter/Dart/DB/HTTP、只针对任务自有字符串/临时合成fixture的**纯检查**（如静态语法、可见目录/Hash/manifest一致性），但不得创建/启动真实系统shell、任意未知外部可执行、系统级服务或网络下载；任何可能调用外部进程的“测试”先STOP或仅静态展示命令待授权。即使工具纯逻辑通过，也标`STATIC_OR_PURE_SELFTEST_ONLY`而非`FLUTTER_STANDARD_RUNNER_VALIDATED`。单任务新产物logical及allocated各≤**256MiB**（268435456 bytes），超过不得删除旧原证或私有SDK腾空间。
- 私有任务开始前建立唯一task_id/根/`execution_ledger`，关键写入先持久PREPARE并flush，记录每个文件的实际前后Hash、task-owned路径/边界、读/写次数、错误、大小。允许只读核上轮已知Hash及必要路径；不修改上轮私有SDK/包、LOCAL_ONLY completion receipt、旧受保护Git工作树/refs或生产源码。
- 不允许新增或升级第三方Flutter/SDK/plugin、全局配置/系统ACL/系统时钟/Windows账号/防火墙、真实用户/生产DB、App Store/APK/设备、RTC/PUSH供应商/真实服务、公开上传密钥/个人LOCAL_ONLY。不可为复现补丁而从旧保护原始日志中复制用户名、路径或私密字节到GitHub。
- 范围内普通工具脚本/矩阵差错可在单一任务自主修正，无需发多个回合微任务；若私有补丁源不可再现或发现会需要再次启动Flutter，则在本任务将该子项停为`REQUIRES_NEW_OWNER_TEST_AUTHORIZATION`，其它安全内容继续完成，不伪造PASS。

## 5. 唯一可审候选与出口

以`5aa3fc631dd7b450888c794182a1a8b35d57ec0a`唯一Parent发布一份普通non-force候选，只包含**非生产工具源码/合成守卫测试**和本任务报告、矩阵、索引；不修改v10.1.5已实现生产Flutter/Laravel行为、不改既有test断言或冻结AC。不向main合并。建议三份可审文档：
- `docs/versions/v10.1.5/REPRODUCIBLE_FLUTTER_TEST_ENTRY_AND_AC_GAP_CLOSURE_REPORT_20261029.md`
- `docs/versions/v10.1.5/ac01_11_gap_matrix_20261029.json`
- `docs/versions/v10.1.5/flutter_test_entry_artifact_manifest_20261029.json`
其中矩阵须同时有便于Owner阅读的Markdown总表和机器可查JSON行、引用不可变历史Blob与原冻结AC，且清楚标证据来自何处。
- 工具交付包含入口路径/命令`inspect`/`prepare`/`execute`（此轮execute必须守门不可实际运行）、安全默认配置、固定补丁校验与失效回执、审阅用最小fake fixtures/纯测试源码、非生产使用说明和权限/预算输入协议。
- 报告说明实际变更列表、来源Provenance/Tree、纯逻辑检查和未运行项、工具能力边界、短期与长期风险、下一次最小授权候选、冻结AC保持OPEN的原因。原始失败/日志只LOCAL_ONLY。没有可信源/补丁能重放时允许工具作为`INSPECT_ONLY_OR_PATCH_INPUT_REQUIRED`交付，但不称已验证可执行。
- 最后GitHub按候选Commit/sole Parent/Root、路径/mode/Blob、完整apps/services Tree（主产品仍v10.1.4）、报告/矩阵/manifest原字节回读；Astra独立验收后仍由Owner决定任何真实工具执行/设备/构建和产品main集成。
- **成功状态**`V10.1.5_REPRODUCIBLE_TEST_ENTRY_AND_AC_GAP_CANDIDATE_DELIVERED_AWAITING_ASTRA`；受阻`DELIVERED_PARTIAL_WITH_EXPLICIT_REPRODUCTION_OR_EVIDENCE_GAPS`；无论何者，**STOP等待Astra**。持续`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。禁止自主进入下一版本/新任务/生产或安全集成。
