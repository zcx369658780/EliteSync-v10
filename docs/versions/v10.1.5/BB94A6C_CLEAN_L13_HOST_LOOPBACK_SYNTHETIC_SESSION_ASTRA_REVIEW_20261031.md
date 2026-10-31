# EliteSync v10.1.5｜bb94a6c 新干净Laravel13本地开发入口、Windows宿主回环API及合成旧会话｜Astra独立验收（2026-10-31）

**正式裁决：`BB94A6C_LOCAL_L13_SOURCE_AND_VENDOR_READY_WITH_OBSERVATIONS / WINDOWS_HOST_LOOPBACK_API_PASS_CODEX_REPORTED / L11_BINARY_TO_L13_SYNTHETIC_SESSION_PASS_CODEX_REPORTED / REGRESSION_PARTIAL_58_OF_60_TWO_ENVIRONMENT_ERRORS / POPULATED_MARIADB_PROCESS_RESTART_NOT_RUN / MANUAL_START_STOP_NOT_RUNTIME_VERIFIED / FULL_LOCAL_DEV_BASELINE_NOT_ACCEPTED / MAIN_PRODUCT_UNCHANGED`。**

这是**有限、分项的真实进展验收**，不是`LOCAL_L13_FULLY_ACCEPTED`，更不是`V10.1.5_FUNCTION_ACCEPTED`。Astra直接读取GitHub原生Commit/Tree/Blob、源码、官方已有question_bank资产及公开Result/Manifest/PowerShell脚本；**不具Owner本机Windows、Docker或LOCAL_ONLY账本/原始测试字节的执行权限**。全部PHP/Composer/宿主HTTP/旧框架Cookie/备份验证只能按Codex本地运行回执分级，不能冒充Astra亲自执行。

## 1. GitHub唯一候选、范围、完整身份

- 正式任务 `docs/versions/v10.1.5/V10_1_5_LARAVEL13_CLEAN_LOCAL_DEV_BASELINE_HOST_API_AND_LEGACY_SESSION_TASK_20261031.md` 固定Git Blob `bd5aa7ee6fc4682ece9136d3b025e6b5d421ef80`，Owner已授权，Codex手动派发，任务ID`V1015_CLEAN_LOCAL_L13_DEV_ENTRY_HOST_API_LEGACY_SESSION_20261031`，唯一root/attempt-0001并已经永久STOP。不要复活任何已封存任务或复用其剩余预算。
- 候选Commit **`bb94a6c273c436aa9a88e9313f9ae662840aa6e7`**，GitHub native **sole Parent `310456834fd653229b27748e44912de5ba9df66f`**，Root **`b4ae308d5e186bd1e36342a46c74116a566d7c11`**，Parent Root `058fee5d498f98e381920c85d83300ec59b9ebaf`。compare ahead1/behind0且恰好5条新增docs路径，没有提交产品代码、session密钥、DB和vendor，也未合并main。
- 完整递归Tree原生Git：candidate 6276、Parent 6270 entries，二者`truncated=false`；其中Manifest所列4项非自身文件的Blob/mode/size **4/4匹配**，Manifest自身Git Blob `c740da37cbda07b102ee5eb09e7c976b8a056f9d`绑定同一Root，故**5/5**路径/mode/Blob闭合，无额外文件。本轮新增Result Blob `48f21c3c663184ce3707d8cb95da4dee6426af0a`、Handoff Blob `f5cf82bcd2d2e7e5c61dd964bab9324731d879b3`，另有`start-existing-dev.ps1` Blob `38582fd4fe145961a30e3c74a0644bbaa41fb7c2`和`stop-existing-dev.ps1` Blob `f0bb6e41121b0efb912bdd5d51346be4f5aa0dcf`。Manifest不伪造其自身所在Commit/Root。
- 候选及Parent **apps Tree均`3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree均`049a8676cc90b3b830e32a524c172720e800fa37`**，保持此前独立接受的Laravel13/PHP8.4 GitHub main开发框架源码基线；没有将f407或9b较宽未接受业务、task-only工具推入产品main。审查后状态文档如有新增main docs Commit也不得改变这两个产品Tree。

## 2. 新本地源、官方供给与vendor（Codex本机回执，有界接受）

- Codex报告新独立`CLEAN_L13_DEV_20261031`入口位于Owner只在本机可见的`C:\Users\zcxve\EliteSyncDev\Laravel13-20261031`，来源是开工fresh main精确Git内容：5,322文件、141,638,016 bytes，Git状态clean；记录本机FileID/Volume与逐项Hash/树，未替换旧默认Laravel11工作根。该本机字节身份、物理目录归属不是Astra远端直接检查结果。
- Codex回执显示现有Docker Desktop 4.97.0/Engine29.9.2 linux/amd64复核；Owner官方PHP8.4.27 Bookworm与MariaDB10.11.19 Jammy固定Index/amd64 Manifest/Config/RootFS闭环；offline构建新task-own image，加pdo_mysql与受官方签名核验的unzip；Composer2.11.1、固定`composer.lock` Blob `e236fbc960c1dd08c1fecb9aeed4926b4cab3933` 的114份锁定包在新入口独立供应，最后真实validate/platform/vendor install成功，solver0且不忽略平台需求。初次vendor因只读缓存配置未设失败，保留原错误；最后第二次install PASS。两个现有PSR-4 fixture warnings保留，不自动清零。
- 新数据库和容器归属按Codex本机资格回执为新任务专属空MariaDB schema/volume。该隔离合成数据不等于旧/生产数据库迁移或恢复。

## 3. Windows宿主loopback：限定PASS、未扩称公网或OS安全

- Codex报告实际Windows Python客户端**在Windows宿主进程**对`http://127.0.0.1:<任务私有高位端口>`发起受计量请求，成功取得health 200、匿名401、非法bearer401、错误密码422、合成登录200、授权token200及终态health200；不是仅由容器内curl访问自己。先前host connection refused和MariaDB IPv6-only阻断、任务自有API/DB容器重建修复均有原始失败回执，不能倒填“首次即成功”。
- 源报告写明Docker实际published binding为仅`127.0.0.1`，容器前端桥接禁masquerade、DB未开放宿主端口，Docker Desktop/WSL和Windows防火墙/全局ACL未更改。Host CIM未发现匹配监听器这一冲突观察被保留。故认可`WINDOWS_HOST_LOOPBACK_API_REACHABILITY_PASS_CODEX_REPORTED`，但**不签LAN/公网可达、Windows OS-wide egress/exposure enforcement、APP/Android设备HTTP入口通过**。真实服务现已全部停止，并非持续正在监听。
- 新空库90表与1个虚构用户、4个token在**API容器重建**前后仍可读；MariaDB进程/卷**有数据后重启并核再读**完全`NOT_RUN_RESTART_BUDGET_EXHAUSTED`，不能偷换为数据库进程重启恢复PASS，也不能宣称`DB_RECOVERY_ACCEPTED`。

## 4. 旧Laravel11→13合成框架二进制Session：分级PASS

- Codex报告从确认归属的**旧vendor非敏感PHP依赖副本**在本轮新私有root内形成Laravel11.48.0框架可执行闭包，使用虚构user、全新测试APP_KEY/新session file handler，实际SessionGuard/EncryptCookies生成旧框架wire bytes，再由Laravel13.39.0同一测试密钥/handler判断，7项正反例：正常登录、错误密钥、篡改、provider撤权、logout、logout后旧cookie replay、过期文件均符合预期。
- 报告保留一次Harness把`SessionGuard.id()!=null`误视为authenticated的错误，最后修为真正`check()`再重跑7项；过期只是更改**虚构session file的mtime**，不是现实等待120分钟。因此签`L11_BINARY_TO_L13_SYNTHETIC_SESSION_COMPATIBILITY_PASS_CODEX_REPORTED`，较先前仅PHP`serialize()`夹具进了一步。
- **现实用户的Laravel11旧session/cookie密钥、生产session存储、真实旧数据库、用户登录保持及业务级迁移均未验证**。始终保留`REAL_LEGACY_L11_USER_COOKIE_NOT_PROVEN`，不通过访问真实敏感资料来补齐。

## 5. 58/60问卷回归缺口不是全部通过

- 当前合成Feature/Unit混合批次**60 tests / 284 assertions / 58 passed / 2 errors**，错误均在`AuthQuestionnaireApiTest`调用`QuestionnaireQuestionSeeder`时出现。Astra直接从接受main GitHub递归Tree定位**官方仓库根目录**`question_bank/question_bank_core_v1.json`、`question_bank_docx_scored_v2.json`、`question_bank_extended_v1.json`、`question_bank_research_v1.json`以及根`dating_question_bank_v_1.json`，且直接读取`services/backend-laravel/database/seeders/QuestionnaireQuestionSeeder.php` Blob `9108ca9802b8b6fb9b0ffe48f34b6bc5f1ae86a2`：`loadQuestionBanks()`按`base_path('../..')`寻找仓库根`question_bank/`，回退根单文件。故**“backend-only runtime mount缺root question_bank”的运行解释与已核源码、接受文件存在性一致**，当前可归类`TEST_ENVIRONMENT_ASSET_MOUNT_GAP_SUPPORTED`，但未在新修复环境重跑前，不可声称两个用例已经真实PASS或排除其它失败。
- 本轮既有migration/seed预算2/2耗尽；按实际一次父PHPUnit命令补归属子操作消耗，而没有假造事前PREPARE。**不得重启已STOP root或结转剩余额度进行补测**，也不建议为2项测试重建整个Laravel/OCI供应链；后续新授权可在既有干净入口只增加受控只读资源mount，运行特定失败用例并适量真实DB进程重启验证。

## 6. 手动启动/停止脚本与剩余操作风险

- 本轮附带两份PowerShell7脚本经Astra直接源码审阅：启动要求`-ConfigPath`私有配置，核已签名Docker CLI、hash、Linux engine、源Git HEAD/clean、已冻结两具名container身份/只读/UID/网络/mount/ports，拒绝旧资源/非loopback并启用既有任务私有DB/API，健康超时会停自有服务；停止脚本比对冻结container形状及task标签，只停具名容器、不删除资源。脚本没有`docker pull`、docker rm/prune、Windows Firewall或默认目录修改操作。
- 但脚本**只通过PowerShell parser静态检查，并未在最终STOP之后再实际启动/停止**：受限restart预算用尽。故脚本只能标`MANUAL_START_STOP_SCRIPTS_STATIC_REVIEW_ONLY / RUNTIME_NOT_VERIFIED`。**Owner不应把其视为经过Astra实际启动验证的一键可用环境；要手动使用须在后续许可中先检查私有ConfigPath、镜像/容器静态身份、可用配额与执行门禁**，不自行重开封存ledger或改变系统策略。

## 7. 保护、预算、STOP和不可变门

- Codex报告旧默认Laravel11.48.0、旧HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、dirty252、refs527、index/HEAD不变；11,066件本地旧备份/240,617,393 bytes、Manifest SHA `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`，本轮身份/尺寸全部检查、160份SHA抽检；旧18/两ACL/122原证/3183 Seed/五根、13旧STOP sealed ledger均保持。本轮没有删除/覆盖/移动原件；**这些均是本机Codex报告而非Astra自己访问C/D盘**。禁旧数据库、真实用户/APP_KEY、生产、全局系统与其它项目资源。
- Manifest预算快照时长1602.187秒，资源logical398,787,599 /allocated450,310,000 bytes，另对新daemon额外保守上界4GiB、总限16GiB。供给报告133个请求/103,825,408 bytes（Owner最终汇报135个/103,923,712 bytes），offline build1、vendor install2/2、服务组3/3、container restart2/2、migration2/2、seed2/2、Feature1/4、host HTTP9/100、CLI42/150、solver0。Owner最终封存耗时36.50分钟低于240分钟；**最终terminal/completion原件仅LOCAL_ONLY，Astra不能独立重算真实封存最高计数**，公开动态快照与Owner最终计数差异明确保留，而不是悄悄取同一数值。
- 四个任务容器均报告退出，保留新源/新vendor/镜像/合成DB卷和原失败。所有旧STOP预算与本轮任务余额均**不得恢复、重置或跨attempt结转**。

## 8. 最终限定出口与下一集中工作

**有界接受：** `LOCAL_L13_NEW_CLEAN_SOURCE_AND_VENDOR_READY_WITH_OBSERVATIONS`、`WINDOWS_HOST_LOOPBACK_API_REACHABILITY_PASS_CODEX_REPORTED`、`L11_BINARY_TO_L13_SYNTHETIC_SESSION_COMPATIBILITY_PASS_CODEX_REPORTED`。认可源代码/依赖入口已建和宿主API、合成旧框架session两项有辨识度的实测进展，作为未来开发接续的候选基础。

**绝不能签：** `LOCAL_L13_FULL_BASELINE_ACCEPTED`、`REGRESSION_60_OF_60_PASS`、`POPULATED_MARIADB_PROCESS_RESTART_AND_RECOVERY_PASS`、`MANUAL_START_STOP_RUNTIME_VERIFIED`、`REAL_LEGACY_L11_USER_COOKIE_MIGRATION_PROVEN`、`OS_ENFORCEMENT_PROVEN`、`MAIN_PRODUCT_NEW_SOURCE_MERGED`、`V10.1.5_FUNCTION_ACCEPTED`。v10.1.5保持`10 PARTIAL/1 OPEN`、AC05 RTC/AEC OPEN、G2 false、真Push Pending、v10.1.6 NOT_STARTED；Windows E_NOTIMPL、既有四事故和`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`原样。

**建议的单一下步：** 待Owner明确授权，制定**一份限定收口任务**，不重做114份供应/框架兼容：只在现存新干净入口受控增添仓库根question_bank的只读挂载、复跑两项失败的AuthQuestionnaireApiTest及其安全负例，使用新的独立预算执行**同一新合成MariaDB数据卷的带数据进程停止/启动/行hash前后对比**，并有界实际验证两份手动脚本的启停闭环（前提是新的任务配置/资源复核合格）。复用已有接受的代码/源码身份但**不借用旧STOP的计量/私有ledger/测试凭据**，不能清理旧备份或改变本地默认入口。完成后Astra再对这几个剩余门独立验收。**本次只发布验收，不自动发布后继**。

验收主体：Astra／EliteSync GPT顾问。分级：`DIRECT_GITHUB_OBJECT`、`CODEX_REPORTED_LOCAL_RUNTIME`、`LOCAL_ONLY_RAW`、`NOT_RUN`、`NOT_PROVEN`。
