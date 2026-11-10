# EliteSync v10.1.5｜Laravel13/PHP8.4 已接受隔离运行候选的正式 main 精确安全集成综合任务

**状态：OWNER_AUTHORIZED_CONTROLLED_GITHUB_MAIN_INTEGRATION / ONE_CONSOLIDATED_TASK / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_DISPATCHED_BY_ASTRA / NO_LOCAL_DEFAULT_SWITCH / NO_OLD_ASSET_DELETION / INDEPENDENT_ASTRA_INTEGRATION_ACCEPTANCE_PENDING**

签发：2026-10-31（Asia/Singapore）。Authority仓库：`zcx369658780/EliteSync-v10`。

## 0. 明确的Owner授权与本任务成功定义

Owner在Astra对候选 `7bd840200f781466919c7946e3533585caf6f8c3` 签署 `LARAVEL13_TARGET_MAIN_ISOLATED_RUNTIME_CANDIDATE_ACCEPTED_WITH_OBSERVATIONS`，并明确询问“是否授权我下达一次 Laravel 13 安全集成到 GitHub 产品 main 的综合任务？该任务仍由 Codex 手动执行、Astra 独立验收，不删除旧版或切换本机默认环境”，回复“好的我同意，请继续”。

本任务**确实授权Codex在逐项Git来源/保护门禁通过后，按精确范围将Laravel13/PHP8.4开发技术基线集成进GitHub main产品源码**，不是重复提交静态审阅候选，也不需要每行找Owner再批准。禁止执行前跳过门禁、让已STOP任务复活、或以此放行v10.1.5整版业务。发布正式任务单的Astra只做GitHub文档写入，不自动执行Codex或本机操作；由Owner稍后手动派发此全文/准确Blob。

**成功出口**：先从fresh main作只包含下列15个指定路径的候选/预检；原生Git全部Blob和树一致，保护检查通过后，以普通non-force、线性Fast-Forward方式向main集成一个**仅15个backend路径变化的产品Commit**；必要时后接一个**仅版本报告/Manifest/状态入口的文档Commit**，从最新main回读完整Git对象、双产品Tree，再STOP等待Astra独立 `INTEGRATION_ACCEPTANCE`。Codex不能在主线声明最终Astra批准、不能把功能AC接受、生产可用或本地默认开发环境变更当成已完成。

如果任何硬门不满足，停止产品main集成，保留预集成候选与真实错误，交付一个`INTEGRATION_BLOCKED_NO_PRODUCT_MAIN_CHANGE`报告；不得因为Owner已批准“集成”而force推送或绕过合规检查。

## 1. 已核Git固定来源与fresh Parent

- 截至本任务签发前，main `ddeae8d96a43f3c816d8ff2a2c262fb2c3733090`，Root `3fee133883034cafb9b064faf1623d8e23ba7b9e`，产品正式接受为v10.1.4：**apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`**。本任务文档与其ACTIVE_STATE发布会推进main HEAD，故**研发产品集成唯一Parent是Codex开工fresh读取的真实main最新SHA/Root**，必须重核双产品Tree仍然上述已接受Tree，不能把签发前HEAD硬当最终Parent或覆盖新增文档。任何其它产品源码/非预期main同时变化=>STOP主线写入；不得force/rebase掉他人工作。
- **Astra有界接受的唯一技术来源**：候选 `7bd840200f781466919c7946e3533585caf6f8c3`，原生Commit唯一Parent `f9f9b97870c6ca482ced83ba09af82dab326f370`，Root `cd4b6ae230105c28aebf2790b704a7218cd64055`，完整apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、candidate services `e14dece6cf3eef118875f688fd303a82d34418c2`。来源Manifest Blob `77659710dc85dee31f4e65dbec838837806a7ce8`，Result Blob `89ce021b8d393acb48562801bb2066bc3bc7fba6`。
- Astra审查权威：`docs/versions/v10.1.5/7BD84020_OWNER_OCI_L13_MAIN_RUNTIME_ASTRA_INDEPENDENT_REVIEW_20261031.md`，**Review Commit `09b7ded0bfaa6bc0d1019cdb2e76f34fdfa31c1f`、Blob `8c340dd9c1270a99a730879c69cf5b9b0fa9915e`**。它是有界批准后端运行候选**作为集成输入**，不是整版v10.1.5 FUNCTION_ACCEPTED，也绝不是本次产品提交的Git Parent。此前 `f407e543...` 静态选择候选和 `9b74ca6f...` 广义后端候选也不能当本次main的Parent。
- 冻结合同：`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、`docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/workflow/ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md` Blob `b2cf29d3fbc612388d4defa7371e78ae70e00017`。开工fresh读当前`docs/workflow/ACTIVE_STATE.md`，核旧v10.1.4正式功能/集成验收以及最新7bd Astra审查；不要从旧聊天记忆猜当前main。
- `OWNER_SELECTED_LARAVEL13_PHP84_DEVELOPMENT_BASELINE`是已批准技术方向，不是 `PRODUCTION_DEPLOYED`、`LOCAL_DEFAULT_BASELINE_ACTIVE`或整版业务接受。

## 2. 唯一准入的15个永久backend路径（所有100644，精确Git Blob）

如下是唯一允许进入main产品Commit的源码集合；原生Git Blob来自Astra已核实的7bd候选。任何缺失、字节变化、路径新增或不匹配都必须先分类并STOP；**不得为了集成自行改锁、补新业务或扩大文件列表**。

| 唯一路径 | mode | 目标Blob |
|---|---|---|
| `services/backend-laravel/composer.json` | `100644` | `130793decf84ff8ab93faa0300117b7fab9d1826` |
| `services/backend-laravel/composer.lock` | `100644` | `e236fbc960c1dd08c1fecb9aeed4926b4cab3933` |
| `services/backend-laravel/config/session.php` | `100644` | `dbcb582d0afbab3a0dc95576797730555ce3cd8d` |
| `services/backend-laravel/tests/Feature/Api/V2/TransportEnvelopeTest.php` | `100644` | `44ee2de7b682148ce326563976215351d35c54b7` |
| `services/backend-laravel/tests/Feature/V1006AdminWebTest.php` | `100644` | `d67921e90c4bde8a6b2644929140978016325ecf` |
| `services/backend-laravel/tests/Feature/V1007LiveConsentTest.php` | `100644` | `273fca333c2f97f0f96def9d4949e8d68c444365` |
| `services/backend-laravel/tests/Feature/V1007PrivateMediaTest.php` | `100644` | `ddd02ced9b382cf004c41f2509079599e89d4497` |
| `services/backend-laravel/tests/Feature/V1008MatchingOperationsWebTest.php` | `100644` | `edf9ad8811898bfa2d39cedf63f5cc93e274f254` |
| `services/backend-laravel/tests/Feature/V1008SessionWebTest.php` | `100644` | `80754a18a09d679a0d14309ea8b171c67ca13e65` |
| `services/backend-laravel/tests/Feature/V1009PrivateVideoTest.php` | `100644` | `ab21487cf54ebb0136cf05aa5b8cfe806f7d5500` |
| `services/backend-laravel/tests/Feature/V1014SafetyContinuityR1Test.php` | `100644` | `acbc201e312c40b9c9970867df771a64591a9e91` |
| `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php` | `100644` | `b024d4d043e57ac71d1c8562f991ea3dd6be339e` |
| `services/backend-laravel/tests/Feature/FrameworkDependencyCompatibilityTest.php` | `100644` | `7abec5fbf155f95941657b22004a63d4d4498560` |
| `services/backend-laravel/tests/Feature/FrameworkSessionCompatibilityTest.php` | `100644` | `b43bdc530389f509c1290a77e940767ed3aba2a8` |
| `services/backend-laravel/tests/Support/CreatesAcceptedMainMatch.php` | `100644` | `7a41ebb9e85705cc94ced7783b3b843c4c429fa5` |

**明确排除：**
- 7bd候选新增的2个**task-only CLI**：`services/backend-laravel/tools/verification/l13_main_runtime/http_request.php`、`.../task_fixture.php`（硬编码该一次性任务身份/私有DB），不得进入正式main；
- 7bd的8个历史任务结果、预算、Manifest、来源/私有测试回执文档由固定审阅分支保留引用，不将旧任务文档当作产品源码新变化再次拷贝；
- 9b候选未整版接受的F1/F3/F4控制器、领域服务、通知/登录/迁移/真实外部业务源码、Windows/旧task特殊检查入口、原LOCAL_ONLY敏感原证；
- **全部正式main `apps/`、`services/backend-laravel/app/`、`services/backend-laravel/routes/`、`services/backend-laravel/database/`、`services/backend-laravel/tests/TestCase.php`以及其它未列出的所有已接受源码Blob**必须原样；新版本功能AC不得因框架主线集成获得暗中接受。

因此**不得整树替换候选services Tree**：7bd完整services包含任务专用CLI，正式集成预期services Tree应为从v10.1.4 main services精确应用上表15条的**新Tree**，不是直接复用7bd services `e14dece6...`；Codex必须实际计算并原生Git回读目标Tree，不能臆造目标SHA。

## 3. 集成前保护证据与最小静态审查

1. 在**不碰原dirty根**的全新独立task-owned执行目录/临时干净worktree内开工，核当前远端main SHA/Root/双产品Tree，旧本地main dirty252、refs527/index/HEAD与受保护历史证据身份、旧STOP账本/11,066文件备份是否存在且未被改变。Owner备份原Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`，此前报告备份11,066文件/240,617,393 bytes及一次隔离恢复试读通过，本次按触及范围做具名**只读**核验即可，避免不必要再完整重算历史全树。备份源归属、ACL、敏感路径/私钥和原始回执均LOCAL_ONLY。
2. 构造15路径的Git对象预集成候选，逐条检查**Parent Blob、目标Git Blob、mode、路径分类**，其余main所有paths精确相同。原main业务目录Tree须byte-exact。验证`composer.json`与lock对应Laravel13.39.0、PHP8.4依赖及114包；composer lifecycle scripts/plugins保持冻结状态，不通过执行未知`composer dev`重新启动宿主；旧真正Laravel11 Cookie、宿主端口仍未证明，不编造。
3. 只做与**15文件复制和Tree差异有关**的轻量静态验证：Git tree diff/sha、完整产品双Tree、Git diff --check（Windows CRLF要区分既存行尾与新错误）、JSON/Composer锁文件静态语法、局部无新授权入口核对、source审查允许片段、无生产凭据/敏感内容/未授权task-only工具。允许非作者只读复核；**无需再次Docker下载/构建、重跑前轮166测试、另起MariaDB、或动APP/Gradle/G2**；既有166/2817/90表系已接受候选的CODEX_REPORTED_LOCAL_TEST，不改称本轮新运行。确有真实新字节或未被接受的依赖才能STOP并集中报告，不自动增加测试/网络预算。
4. 所有命令采用新task预算与PREPARE持久账本；限在授权范围内重新检查，但不读取/更改其它项目、旧task私有卷、生产库、真实用户数据。完整快照若资源不够STOP，不为了腾空间清理旧资产。

## 4. 产品 main 的有条件实际提交授权

1. 从fresh main构造**一个唯一、non-force、sole Parent等于该fresh main的产品集成候选Commit**，只含上述15条backend路径。不得以7bd review/候选Commit作为Parent，不merge/cherry-pick其全历史，也不得force push。
2. 候选提交后**在发布产品main之前**校验完整原生Git Commit/sole Parent/Root、15/15 old/new Blob+mode和完整apps/services Tree、工作树是否有超范围变更；运行被批准的最小静态检查。若出现任何未授权差异、权限/来源/保密门禁失败、并发main head变化/非fastforward/branch policy拒绝，**保持候选与报告，STOP不动main产品**。不得为了通过门禁回写旧原证、篡改快照或擅自更改branch保护。
3. 若所有静态安全门PASS，**本Owner批准在同一个正式任务内把上述精确产品Commit快进合入GitHub main**（这一权限限15个指定后端路径，不含备份/生产/设备动作）。必须确认执行瞬间远端main仍精确等于候选唯一Parent；只能使用正常non-force fast-forward，不能覆盖其它人的提交或在HEAD已变时盲重试。
4. main产品Commit成功后，**即时fresh读取GitHub实际main Git Commit、唯一Parent、Root、15个Blob/mode、apps/services全Tree**，逐个确认主线与接受输入一致。产品Tree差异只允许`services/backend-laravel`15项，apps Tree必须维持`3468a3dd97da7accfda2539a0f8d8f68931a6110`，原main其它所有源码同一Blob；计算得到的新services Tree作为该候选受控集成的实际身份。任何异常STOP并报告，不因错误自动执行reset/revert/force。
5. 确认产品commit后，同任务只允许另增**一个受控Docs-only fast-forward Commit**，记录版本集成Result、精确15文件manifest和状态入口；该文档Commit不再修改apps/services。需区分产品Commit的唯一Parent、docs Commit的唯一Parent与最终main HEAD。可在报告里给出 `MAIN_SOURCE_INTEGRATED_AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE`，**不得写INTEGRATION_ACCEPTED、FUNCTION_ACCEPTED或关闭AC05/G2**。
6. 如果无法安全发布/分支策略拒绝，交付预集成候选和`MAIN_INTEGRATION_BLOCKED`Result/Manifest，不依赖自动创建多个重复候选任务。非作者/Astra正式验收在Codex STOP后实施，验收失败则下一轮依Owner决定且不能偷偷删改历史。

## 5. 一次综合任务预算/授权边界

- 新任务ID：`V1015_L13_ACCEPTED_RUNTIME_MAIN_PRECISE_INTEGRATION_20261031`；新独立root basename：`v1015-l13-accepted-main-precise-integration-20261031`，唯一attempt-0001、新任务ledger和相互区分的Git candidate/Main commits，**不得复用7bd或任何此前STOP的磁盘/时间/服务预算**。
- 一次总单调窗口 **≤120分钟**；任务私有文件logical/allocated各≤**4GiB**，不占用旧备份作为新root，不克隆整个旧原证；git源索引/target路径身份逐项限额。主机新增下载/公网package/OCI供给请求预算**0**，Docker/WSL启停升级0，Composer solver/vendor install0，PHP/Feature/API/HTTP/DB运行0，数据库迁移/seed0、APK/Gradle/ADB0；允许GitHub权限内必需的Git读/写和已批准的task-local Git对象/报告提交（网络费用/权限与公网依赖获取不可混同），不得借“网络预算0”擅自拉OCI包或访问生产。所有本地任务额外成本/写入先`PREPARE`+`fsync`，失败、超时、publish和readback保留。
- 保护旧本机dirty工作树、11,066文件备份和旧Laravel11 vendor、原个人私有配置、11项原STOP封存、旧18/2 ACL/122原证/5根/3183 Seed、527 refs/index及其它项目文件；任何清理/删除/移动/覆盖旧资产均未授权。禁止把GitHub main源集成自动当成`LOCAL_DEFAULT_BASELINE_SWITCHED`；默认旧开发根与旧备份仍在，Owner后续明确批准才切换、必要时做回滚或清理。
- 不改Windows全局设置/证书/ACL、Docker daemon、Hyper-V/WSL、生产/真实旧DB、外部云/实人或付费供应商、真实消息/私密上传。宿主端口`HOST_PORT_FORWARDING_NOT_VERIFIED`与旧Laravel11 cookie`REAL_LEGACY_L11_COOKIE_NOT_PROVEN`继续保留；禁止Flutter、Gradle、G2/APK/ADB、RTC/AEC、真实Push及物理15/30天，并保留旧Windows`E_NOTIMPL`、`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`不改写。
- `V10.1.5_FUNCTION_ACCEPTED=false`，原AC01–11 10 PARTIAL/1 OPEN，AC05 RTC/AEC OPEN，G2 false，Push Provider待定，v10.1.6 NOT_STARTED；**本次只集成后端框架开发基线，不接受未实现业务功能或自动启动下一版**。

## 6. 唯一交付与Astra最终独立验收

- 若成功：`docs/versions/v10.1.5/LARAVEL13_TARGET_MAIN_PRECISE_INTEGRATION_RESULT_20261031.md`、`docs/versions/v10.1.5/laravel13_target_main_precise_integration_manifest_20261031.json`、`docs/versions/v10.1.5/LARAVEL13_DEVELOPMENT_BASELINE_STATUS_20261031.md`（仅记录GitHub main vs 本机默认状态）；`ACTIVE_STATE`更新为`MAIN_SOURCE_INTEGRATED_AWAITING_ASTRA_REVIEW`、精确产品/文档Commit/Root、apps/services双Tree、15条old/new/mode/Blob、旧备份状态、当前所有未闭门禁。**文档不内嵌包含自身的commit/root以制造循环SHA**，用nativeGit readback后保存最终固定对象事实。
- 若BLOCKED：单份脱敏`INTEGRATION_BLOCKED`报告/Manifest与固定Git候选，分明说明是否产品main有任何变动、缺失门禁、已有Git对象、旧备份状态；如果main写被平台拒绝不能宣称已经集成。
- 证据分层`DIRECT_GITHUB_OBJECT`（Astra可直接重读）、`CODEX_REPORTED_LOCAL_STATIC_CHECK`、`PREVIOUS_CODEX_REPORTED_LOCAL_RUNTIME`、`LOCAL_ONLY_RAW`、`NOT_RUN`、`NOT_PROVEN`。原vendor/OCI/DB/真正私有日志、绝对本机用户敏感路径/密码/token不得上传公共GitHub。GitHub源码与先前审查分支保持可追溯，不触发无授权文件删除。
- Codex提交后**STOP**并向Owner回报唯一候选、真正main和docs Commit/Parent/Root/双Tree及各路径、最终ACTIVE_STATE和预算证据，等待Astra独立签`INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`或阻断；不得自签验收、自动派新任务/进入v10.1.6。
