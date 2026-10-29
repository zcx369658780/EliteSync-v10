# EliteSync v10.1.5｜0d28 主线交付同版 R1：E2E PHP桥接依赖资格与fail-closed接线｜Owner正式任务

**状态：OWNER_APPROVED_BOUNDED_R1 / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / SOURCE_AND_PURE_CONTRACT_CORRECTION_ONLY / NO_REAL_PHP_LARAVEL_DB_FLUTTER_APP_RUNTIME / PRODUCT_MAIN_NOT_INTEGRATED**

签发：2026-10-29（Asia/Singapore）。Authority仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner批准的唯一目标

Owner已收到Astra对主线候选`0d28e89f`的独立有界验收，明确同意继续发布**一次同版定点R1修正**。不得重发10月29日原主线综合任务，也不得以修一个PHP资格问题重新开启旧Hook Hash、Flutter SDK、MariaDB安装、ACL/G2/Gradle治理循环。

唯一必须修正的问题 `R1-01`：`tools/v1015/mainline_e2e/run.py` 当前PHP桥接命令以`php.exe -n`忽略php.ini，显式仅加载`pdo_mysql`与`openssl`；但真实桥接将启动本仓Laravel（`composer.json`要求`laravel/framework ^11.31`），现有会话路径的`DeviceSessions::issue`调用`mb_substr`。当前纯PHP模拟资格14项、语法5文件不能证明该启动链所需扩展与DLL闭包已被加载，未来可能在实际seed/登录前失败。**这是一处源码合同与未来运行资格缺口，不是已经实测到的故障。**

本次目标：让E2E驱动/测试PHP bootstrap在未来获得独立Owner运行授权后，能够基于冻结且可核Hash的私有PHP二进制、扩展、配置与受控闭包**先资格化、失败即STOP**，并保证CLI桥接与未来PHP API服务使用一致、可验证的依赖。不能通过放弃`-n`或默认继承全局php.ini、宽松搜索系统DLL、SDK/全局升级、跳过Laravel真实需求、关闭测试守卫等方式“修复”。如需要对是否实际可加载的判断，作为未来受控运行门列`NOT_RUN_GATE_CLOSED`，而非本轮调用PHP/Laravel/API/DB实际运行。

## 1. 固定对象与裁决

- 首先fresh获取live `main`/Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文与Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/workflow/CURRENT_WORKFLOW.md`及冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 本次**唯一研发Parent**：`0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`；Parent Root `c6898b86dd1e286967b952b2ac9cb764f4b0ff6d`；Parent apps `03ba3602a7dc807bf963264e24f33eed01c231c8`；services `32229dce88cf497fea43904fea3dbb69a9410b8f`。Parent sole Parent=`0577f030f6e3bbecae611433daa226719a7cc4b0`。审查分支绝非研发Parent。
- Astra正式独立审查在`astra/v10.1.5-0d28e89f-mainline-e2e-independent-review-20261029:docs/versions/v10.1.5/0D28E89F_MAINLINE_SOURCE_AND_E2E_HARNESS_ASTRA_INDEPENDENT_REVIEW_20261029.md`，审查Blob `0483e621b2f233cee26a151d01536af8911b7bb2`，审查HEAD `1c94cd15549c34d5a46d139319312817df448116`。裁决：`0D28E89F_BOUNDED_F1_SOURCE_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / E2E_HARNESS_RUNTIME_ENTRY_CHANGES_REQUIRED`。
- 原主线合同 `docs/versions/v10.1.5/V10_1_5_APP_API_DB_MAINLINE_PRODUCT_INTEGRATION_AND_E2E_HARNESS_TASK_20261029.md` Blob `1db7fc7eaadcea172cc52016904836bd71a0b90d`。原候选实施报告、manifest、15场景、`SOURCE_TO_E2E_CONTRACT_MATRIX`、`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`均须只读引用而不覆盖其历史原件。
- 当前main唯一已接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本R1不得合main或升格整版。

## 2. 实施范围（在单一R1里完成普通修复与纯回归）

1. 在固定Parent精确审查：`tools/v1015/mainline_e2e/run.py`的`Runner.php()`、`contracts.py`、`test_contracts.py`、`config.example.json`、`README.md`；`services/backend-laravel/tests/E2E/MainlineEnvironment.php`、`bridge.php`、`server.php`及`composer.json`、`composer.lock`、现有Laravel与PHP的调用需求。明确区分composer要求、源码中实际使用函数与尚未具名验证的原生模块，不能把理论列表当作Windows现场可加载证据。
2. 采用明确/最小的**私有PHP运行依赖Manifest与资格逻辑**：所选PHP exe、扩展源（需要时包含依赖DLL）、扩展名/路径及哈希、版本与架构、已核private root和允许的启动配置；启动前缺项、路径逃逸、Hash变化、API/CLI闭包不一致、扩展缺失/功能不可用须fail-closed。不读取全局php.ini作为成功条件，不隐式下载/拷贝全局DLL；明确保留`-n`模式。若安全与兼容性需要调整参数写法，必须证明不会放宽路径、环境和业务资格。
3. 将必要的检查接入未来的PHP CLI桥接和API test router，使真实`Laravel bootstrap/seed`开始前拒绝不合格依赖。Python层做不启动网络/服务的前置静态资格检查，PHP层必要的能力检查在**未来授权启动**时执行；当前不能宣称已实装扩展动态加载成功。不得因此添加面向真实用户的测试路由、控制器开关或改写业务授权。
4. 增补**合成且纯逻辑**正/负例：缺`mbstring`、未声明扩展/依赖DLL、扩展或exe hash不符、不同CLI/API闭包、逃逸/符号链接、配置未授权、旧task与非本版候选等应STOP；合法冻结Manifest只能达到`STATIC_PRECONDITION_OK / LIVE_MODULE_LOAD_NOT_RUN`，不得被计作运行PASS。可根据源审修复直接相关的普通缺陷，但必须解释必要性，最小改动且同任务集中完成。
5. 维护原主线15场景清单、消息不可变retry修复、3个新增Widget测试及AC01–11原状态，不因E2E入口修复重新编造业务Bug。相关结果与后续Owner许可建议可出R1增量报告/manifest，但不得覆盖原Codex/Owner/Astra冻结正文。测试入口`inspect`默认无副作用、`execute`没有新Owner许可继续拒绝；原ledger在原根保留，不通过新任务名称清零。
6. 建议改动仅在`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`的必要非生产测试工具和新R1报告/manifest；`composer.json/lock`仅只读依据。除非发现与本问题不可分的实际缺陷并在报告充分证明，本轮不改`apps/`、`services/backend-laravel/app/`、`routes/`、生产配置、实际业务权限或原数据迁移。任何意外跨界先STOP该项并集中报告，不扩成新功能包。

## 3. 执行预算、保护与不可变硬门

本R1允许**单一新task-owned源码/纯契约私有工作面**，新增logical与native allocated各≤**256MiB（268435456 bytes）**，任务内唯一持久ledger和原始失败/Hash记录；中断同根继续，不用复制完整SDK、vendor、DB datadir或旧证据来挤占任务。允许可信现有Python纯AST/JSON/合成契约、PHP纯语法（lint）与无需PDO/Laravel/vendor/bootstrap/真实扩展加载的纯资格负例；所执行命令/退出码/次数/源码Hash均按真实记录，不预报结果。重复原版Flutter77、MariaDB23/152或Hook42无必要。

**本R1绝不授权**：
- 新Flutter/Dart/analyze/widget实际执行（历史6/6耗尽）；MariaDB服务器/迁移/事务（历史2/2耗尽）；Laravel vendor/bootstrap/HTTP API/回环服务（历史PHP API1/2剩余数不是许可）；PHP真实E2E启动/连接；
- G2/Gradle/JVM/APK构建安装/ADB/AVD/真机/RTC/SFU/摄麦音质/真实WS/Push；
- 下载、扩展安装、系统php.ini/环境变量/ACL/组策略/防火墙修改、共享SDK或全局PHP修改、受保护资产清理、外网/云/生产/真实用户数据或费用。

历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`继续保留。旧18、两ACL树、122原证、五根、527refs、3183 Seed、旧失败/账本/claims、dirty根及所有历史候选不得写入/删除/prune/reset/stash/force。实际所需DLL/安全闭包/私有原始日志留LOCAL_ONLY，不上传GitHub。

## 4. R1集中交付与验收

- 一份新R1测试工具/源码修复候选（sole Parent**精确为`0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`**），普通non-force候选分支；不得用Astra审查分支、main或原`0577`替代。
- `docs/versions/v10.1.5/0D28E89F_PHP_E2E_BOOTSTRAP_QUALIFICATION_R1_REPORT_20261029.md`与配套`0d28_php_bootstrap_r1_manifest_20261029.json`：逐项R1-01前后证据，精确变更文件及Parent/final Blob、纯测试的真实exit/stdout/失败列表、依赖闭包明细的安全摘要、尚未验证的模块加载/进程路径、原15场景/APP观察复用、受限预算与Owner下一真实运行条件。具名源码与原始失败不得删改。
- 纯契约PASS只说明资格逻辑满足新边界，**`PHP_LARAVEL_BOOTSTRAP_NOT_RUN / ACTUAL_EXTENSION_LOAD_NOT_RUN / E2E_NOT_RUN_GATE_CLOSED / FLUTTER_WIDGET_NOT_RUN_GATE_CLOSED`**；不得称整链或APP实际通过。
- 提交候选后fresh GitHub回读Commit、唯一Parent、Root、全部变更path/mode/Blob和完整apps/services Tree，复查main产品仍v10.1.4。交付状态最多`V10.1.5_R1_E2E_PHP_ENTRY_SOURCE_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW`，有界阻断则`R1_DELIVERED_PARTIAL_WITH_EXPLICIT_RUNTIME_GATES`。
- 最后**STOP等待Astra独立验收**。不自行`FUNCTION_ACCEPTED`、不合main、不批准新运行、不重新发布微任务、不自动启动v10.1.6。原`AC01–11=10 PARTIAL/1 OPEN (AC05 RTC)`、`V10.1.5_PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN`持续有效。

**任务创建≠Owner手动派发≠Codex执行；只有本文件在GitHub main正式发布并完成A–D回读之后，Owner才能按单一短Prompt手动派发。**
