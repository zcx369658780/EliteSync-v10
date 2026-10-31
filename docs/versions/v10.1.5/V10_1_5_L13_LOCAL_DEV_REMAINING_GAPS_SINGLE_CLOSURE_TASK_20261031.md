# EliteSync v10.1.5｜干净Laravel13本地开发入口：问卷资源挂载、合成MariaDB进程重启、手动启停脚本三缺口集中收口｜Codex正式综合任务

**STATUS：OWNER_APPROVED_SINGLE_GAP_CLOSURE_TASK / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / NO_OLD_STOP_BUDGET_REUSE / LOCAL_DEFAULT_L11_UNCHANGED / PRODUCT_MAIN_UNCHANGED / NO_OLD_ASSET_DELETION**

日期：2026-10-31（Asia/Singapore）。权威仓库：`zcx369658780/EliteSync-v10`。此任务一次完成三项剩余真实验证，不为每个小错误派发另一个任务；符合已接受2026-10-21和2026-10-25轻量版本交付与A-D任务发布闭环。授权实施者为**Owner手动派发的Codex**，验收者为Astra。

## 0. Owner授权与唯一完成定义

Astra对2026-10-31候选`bb94a6c273c436aa9a88e9313f9ae662840aa6e7`有界验收并建议“只在现存新干净Laravel13入口中对三个缺口集中收口：问卷根JSON只读挂载并复测两项失败、带数据MariaDB进程重启和逐表行哈希、手动启停脚本真实闭环”。Owner明确回复“可以我同意，请继续”。

因此本任务授权在**现有新干净Laravel13开发入口及具名合成测试资源**上执行必要只读检查、可审计的任务专属容器启停及合成测试、按需创建新任务私有测试runner/只读挂载/必要安全脚本修复。**不授权自动切换默认本地开发路径、覆盖旧Laravel11 dirty根、访问真实旧DB/实人Cookie、修改全局Docker/Windows设置、清理旧版、生产部署或整版v10.1.5 FUNCTION_ACCEPTED。**

成功须分别证明：
1. **QUESTION_BANK_MOUNT_AND_REGRESSION_PASS**：来自正式main的4份根目录`question_bank/*.json`按native Git Blob只读挂载到Laravel Seeder预期的路径，先以两项原失败用例验证，必要时完整重跑原60项（保留前次58/60原失败），真实exit0且0 errors、不可偷改/跳过原测试或变业务seed；
2. **POPULATED_SYNTHETIC_MARIADB_PROCESS_RESTART_HASH_PASS**：在确认为本任务获准复用的独立合成MariaDB数据卷/真实DB服务上，持久数据存在时**实际停止→启动MariaDB进程/容器**，前后完整逐表行数/规范化行哈希相等，启动后以合成授权读回确认；绝不能用API容器重建代替。必须留进程/容器实例ID/uptime或startup receipt、数据库server_id/schema/卷身份及哈希证据。
3. **MANUAL_START_STOP_RUNTIME_PASS**：真实通过两份既有PowerShell7手动启停脚本（原Git Blob固定）与私有`entry-config-LOCAL_ONLY.json`从全停服务启动、Windows宿主loopback健康及鉴权拒绝，然后通过stop脚本关闭所有具名服务，再读回不触碰其它容器/卷；静态parser PASS不能代替运行。

三项门**互相独立**：如任何一项安全受阻，已成功项原样保留，可交部分结果并`CLOSURE_PARTIAL`；不得为了追全绿改全局防火墙、任意重启Desktop、借用STOP预算、修改问卷题库语义或删除历史证据。

## 1. 冻结GitHub main、来源证据和已有本地入口

- 签发前fresh main `4fbaaf8d6e7f1955abd3f182a85a04dc35687fa6`、Root `2848134d085e3c4a559f1fd48204fdc2d044365a`。本次发布及状态同步会使main **仅文档前进**。开工必须再次fresh读取真正live main HEAD、Root、ACTIVE_STATE和本任务Blob；拒绝按旧sha覆盖其它人提交。已独立接受的产品双Tree不可变：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `049a8676cc90b3b830e32a524c172720e800fa37`。
- Laravel13/PHP8.4框架GitHub集成已由Astra独立接受：产品Commit `7e1e107ca0faed840e1ce06418694e3590e3b3ae`、最终docs `b101a8f8d955a624d34a98ce340a97abb576d0ca`、Review Commit `71afd7e2da6d1ad56bb53664ec347fe0aa5364ba`、Review Blob `542a34926fddf2e53917a1e362ebded8e8dc43ce`；main composer.lock `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`（Laravel13.39.0、114锁包）、PHP8.4方向不变。
- 最近已停止的独立本地dev入口候选：`bb94a6c273c436aa9a88e9313f9ae662840aa6e7`，唯一Parent `310456834fd653229b27748e44912de5ba9df66f`，Root `b4ae308d5e186bd1e36342a46c74116a566d7c11`，5份docs/脚本而无产品源码变化，Manifest Blob `c740da37cbda07b102ee5eb09e7c976b8a056f9d`、Result Blob `48f21c3c663184ce3707d8cb95da4dee6426af0a`、Handoff Blob `f5cf82bcd2d2e7e5c61dd964bab9324731d879b3`。
- Astra已独立审查：Review Commit `12072468f6a3f18b84ee508b2d9a0e03a6c33a6a`、Blob `b19eacb9ad0577faa30512750c89217e9bdc9fe9`。裁决新本地源码/vendor可用、Windows宿主127.0.0.1回环PASS与**实际Laravel11.48二进制合成**session七项PASS，但原混合回归`60 tests/284 assertions/58 passed/2 errors`、填充后DB进程重启NOT_RUN、两份启停脚本runtime NOT_RUN。**不要重复下载114个包、重造旧合成session或重复全套供应闭包**。
- Owner新开发入口已经存在`C:\Users\zcxve\EliteSyncDev\Laravel13-20261031`（别名 `CLEAN_L13_DEV_20261031`；LOCAL_ONLY原生FileID/Volume和精确配置以此前本地回执为准）。该入口拥有先前新建的114包vendor、新合成MariaDB90表卷、独立Docker镜像/容器和私有配置；全部服务当前STOP，默认旧Laravel11不变。只能在本任务的新ledger下由任务拥有权限对**已确认归属的现有L13合成资源**启动/验证，不得复用旧任务ledger、进程预算、认证凭据日志或模仿原STOP“继续attempt”。
- 既有手动脚本：
  `docs/versions/v10.1.5/clean_local_l13_dev/start-existing-dev.ps1` Blob `38582fd4fe145961a30e3c74a0644bbaa41fb7c2`；
  `docs/versions/v10.1.5/clean_local_l13_dev/stop-existing-dev.ps1` Blob `f0bb6e41121b0efb912bdd5d51346be4f5aa0dcf`；
  Handoff明确此前**只做parser，未真实启停**。复验前必须重新审查冻结参数、命名容器、Docker签名/身份和`entry-config-LOCAL_ONLY.json`归属，不能盲目运行未知脚本。
- WORKFLOW `docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、v10.1.5 plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；不得修改原冻结Owner/AC。全部历史STOP持久保护。

## 2. 问卷资源缺口：只读原生Git文件与有界针对性重跑

- Astra直接从集成前/当前main原生Git验证了`QuestionnaireQuestionSeeder.php` Blob `9108ca9802b8b6fb9b0ffe48f34b6bc5f1ae86a2`：`loadQuestionBanks()`用`base_path('../..')`读取仓库根`question_bank/question_bank_*.json`；原任务只挂载后端目录，故两项`AuthQuestionnaireApiTest`在Seeder读取时出错；这是**源码支持的环境挂载解释**，不是现已实际修好。
- **四份正式main问卷输入的原生Blob**（mode `100644`）：
  `question_bank/question_bank_core_v1.json`→`02611e93fcb50cbe35126381cc4a79b178b2d423`；
  `question_bank/question_bank_docx_scored_v2.json`→`6d3fb19242734dd6938979f3846e9837518be175`；
  `question_bank/question_bank_extended_v1.json`→`d18a585139e7b179c670f84e9ca1f8734fa0398b`；
  `question_bank/question_bank_research_v1.json`→`086cceddba59704b0085e21d7e3fead8a01f7495`。兼容fallback原仓库根`dating_question_bank_v_1.json` Blob `34817351b92c5b9cf1f7e363af52541f1e76aa22`保留，但四份分库存在时不能悄悄降级为旧单文件。
- 在**本轮新任务拥有的独立测试runner或安全验证过的已授权dev容器**里，先校这四份原生Blob、JSON schema/size/路径、命名mount、`ReadOnly=true`及宿主fs FileID，不允许把整个个人工作目录或旧备份重新挂载到容器；只读映射到Seeder实际按`base_path('../..')`解析的目标层级，不能修改Seeder/base_path来让用例变绿。
- 确认SQLite`:memory:`测试与新已授权合成MariaDB严格隔离（`APP_DB_CONNECTION`优先于`DB_CONNECTION`；不能误导Seeder擦写现存已填充卷）。先运行两项原`AuthQuestionnaireApiTest`失败用例和必要权限反例，若PASS且预算许可，再一次跑原60项同范围回归；若`58/60`意外变成新失败保留原始stderr/junit/exit/hash，不通过删测试、mockSeeder或改问卷有效选项代替。两项失败仍未实测变绿时必须保持`QUESTIONNAIRE_REGRESSION_NOT_CLOSED`。
- 如果需要将root question_bank只读映射固化为将来手动启动的一部分，只能新增**task-owned测试run配置或修订待审的公开脚本副本**，不能直接破坏原bb候选已冻结的Docker容器身份/历史Result/脚本；所有改动具名、可审、只读源Hash不变。

## 3. 真正的带数据MariaDB进程重启与恢复

- **明确允许复用唯一新干净L13入口的具名合成开发卷/容器来测试真实MariaDB进程重启**；这是Owner同意本轮缺口收口的具体授权，**不代表允许复用bb94 STOP的ledger/余额、读取其它旧任务卷或生产数据库**。必要时在本轮独立根对该合成卷做**新任务私有、只读来源的前置逻辑快照/可恢复副本**，核schema、server_id、container/volume Label+FileID、内部网络、无宿主DB端口、当前/旧任务保护；若发现身份漂移、卷已被他人用或不是原合成专属，STOP该项。
- 必须确认DB在进程重启前**已有非空数据**（至少已报告1个虚构user、4个token），且`INFORMATION_SCHEMA`表清单及逐表count、规范化全行hash摘要已写入本任务LOCAL_ONLY原始回执。执行具名进程停止、记录实际PID/container/state变化、进程重新启动、持久卷复用不变、MariaDB版本10.11.19、server_id、schema/权限再次检查，重新逐表读回全行count/hash；至少90表全部逐表与restart前一致。不能仅通过`docker inspect`看到容器ID未变/vol保留或重新启动**API**便声称DB真正重启PASS。
- 负面门禁：旧用户账号不能进入测试、原seed/DB不能执行未批准的`migrate:fresh`或清空；不对旧受保护数据库跑任何重启/备份/DELETE。真实旧/生产DB恢复不是本轮目标。若证据不充分，按`POPULATED_DB_PROCESS_RESTART_NOT_PROVEN`报告，保留已有API容器重建保留数据这一较小成果，不自动扩大源权限。
- 如果脚本启动/停止会影响MariaDB验证的时序，先制定可审的单一序列并记录每次服务动作，将**脚本runtime**与**DB真实重启**分别给出归属和计数，不能用同一次API重建充两项PASS。结束所有新任务允许触及的服务后验证确实STOP，原合成卷保留不删除。

## 4. 两份手动脚本实际启停闭环

- 只用既有PowerShell7、`start-existing-dev.ps1`/`stop-existing-dev.ps1`，从明确无服务运行状态开始，核本地脚本字节等于上述Git Blob或本任务新可审修订版/新LOCAL_ONLY测试副本，`entry-config-LOCAL_ONLY.json`只存新任务私有根而不公开。事前对既有脚本直接做源码审查，注意`FrozenContainers`枚举顺序/PowerShell JSON shape、Docker CLI签名及哈希、`desktop-linux`既有Engine、task Label、只读root、UID、cap-drop、no-new-privileges、仅127.0.0.1 API发布、DB不发布宿主port、前端`enable_ip_masquerade=false`、source Git HEAD/clean状态。
- **不批准更改Windows全局ExecutionPolicy、Firewall、Desktop/WSL/Hyper-V、Docker context默认值、用户PATH或安装服务**。任何脚本引发其它项目容器启动/停止、非127.0.0.1绑定、受保护image/volume操作立即停止；必要时只在新root中精确修复脚本与其任务内测试配置，保留原失败/old Blob、提交新脚本作为待Astra审查的**文档/脚本候选**，原已接受main产品源码不得改变。
- 实际从停止态调用脚本启动DB/API，确认所有权/读写挂载约束和Windows宿主loopback真实健康响应（建议至少200/401），然后脚本停DB/API并复查进程全停、未删除新卷、未触及旧资源。脚本如果只能静态parser PASS或因身份/网络配置改变不能启动，必须`MANUAL_SCRIPT_RUNTIME_NOT_VERIFIED`，不得绕过FrozenIdentity等安全门仅为PASS。

## 5. 一次独立预算与不可变禁止事项

- 新任务ID `V1015_L13_DEV_3_GAPS_CLOSURE_20261031`、唯一新task-owned root `v1015-l13-dev-three-gaps-closure-20261031`、attempt-0001、持久PREPARE+fsync ledger；旧bb候选及此前所有STOP的残余额度永不复用。Owner允许新任务**受限使用已有干净dev入口及其具名合成DB卷**，但原始历史raw/封存账本/原交付源码/备份只读，不能覆盖旧文件、运行未知命令或复制旧私密token。
- 硬上限：单调总窗口 **≤180分钟**；本轮新任务及其派生临时副本logical/allocated各 **≤8GiB**（已有dev入口/已有Docker镜像/已有合成卷仅作保留存量，不作为新分配成本洗白；本轮新增写入/逻辑备份/服务日志及容器副本全部计量）；受控**新增公网供应 0 bytes/0 requests**，Docker image pull/build 0，Composer solver/vendor install 0，系统/Windows/Docker Desktop/WSL全局升级/启动/重启 0；任务自有服务组≤**2**，DB实际进程重启≤**2**，API受控重启≤**2**，手动脚本启动/停止闭环≤**2轮**，PHP CLI≤**80**，Feature批次≤**3**（两项定向、原60项全套、一次必要范围内修复复跑），宿主实际HTTP≤**30**，内部API HTTP≤**30**，SQLite测试迁移≤**3**、Seed批次≤**3**；**现存MariaDB填充卷迁移/seed/drop=0**，任何测试SQLite子迁移/seed必须在父测试批次PREPARE之前有上界预留，不事后补造子调用PREPARE。失败/超时/重试照计，总服务事件必须与日志核对且不能靠拆子进程不记账。
- 磁盘/端口冲突不以删除旧根/旧vendor/旧Docker images/v10.1.5候选及历史证据来腾资源；既有Docker Desktop Linux Engine必须已在运行且签名/身份合格，否则STOP。无新增依赖下载、无真实Push/RTC/AEC/真实用户/供应商/生产DB/外部费用、无Flutter/Gradle/ADB/APK、无全局防火墙/ACL修改、无物理15/30日演练。旧Laravel11 默认本地工作树 `HEAD 4bebc8f394248e254c1368a06fbdee5d2c883301`，dirty252、refs527、vendor、旧11,066件备份/240,617,393bytes、Manifest `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`以及旧18/两ACL/122原证/3183Seed/五根/13旧STOP全部保留，按触及范围只读核，不做每轮高成本全盘复扫。
- v10.1.5功能仍`10 PARTIAL/1 OPEN`，AC05 RTC/AEC OPEN、G2_READY_FOR_POPEN_FALSE、REAL_PUSH_PROVIDER_PENDING、v10.1.6 NOT_STARTED；`REAL_LEGACY_L11_USER_COOKIE_NOT_PROVEN`和`OS_ENFORCEMENT_NOT_PROVEN`及Windows E_NOTIMPL、历史四事故/`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`不可被本轮闭3项提升。合成session7项旧验证本轮不要求重跑，HOST_LOOPBACK_PASS只在已回执的限定Windows loopback范围内成立。

## 6. 唯一结果、提交与Astra独立验收

- 成功或有界阻断均交付**唯一普通non-force研发候选**，其sole Git Parent为开工时fresh main，包含最小不含私钥/real cookie/真实本地路径/volume数据的：
  `docs/versions/v10.1.5/L13_DEV_THREE_GAPS_CLOSURE_RESULT_20261031.md`、
  `docs/versions/v10.1.5/l13_dev_three_gaps_closure_manifest_20261031.json`、
  `docs/versions/v10.1.5/L13_DEV_BASELINE_THREE_GAPS_HANDOFF_20261031.md`；
  如手动脚本必须安全修复，可额外提交`docs/versions/v10.1.5/clean_local_l13_dev/`下的任务所属**有界新脚本候选**及可审修订映射、保留旧Blob；不得改Laravel13产品源码、apps/services、生产routes、Seeder/题库数据、上版本原签验收/失败回执。私有真实`entry-config-LOCAL_ONLY.json`、Docker/DB dump、行Hash原始序列、密码/会话token、Local FileIDs、旧敏感路径与完整运行logs永远LOCAL_ONLY。
- 结果逐门写`QUESTIONNAIRE_REGRESSION_PASS|PARTIAL|NOT_RUN`、`POPULATED_DB_PROCESS_RESTART_PASS|NOT_PROVEN`、`MANUAL_SCRIPT_START_STOP_RUNTIME_PASS|NOT_VERIFIED`，并列出旧54? **不使用任何无证据的新测试统计**；前次58/60保留，若本轮完整跑60项则使用本轮真实exit/JUnit测试数与断言、两旧失败是否确已转PASS；Oracle响应/权限否定必须保留。总状态最多可向Astra提出`CLEAN_LOCAL_L13_DEV_BASELINE_CLOSURE_CANDIDATE_AWAITING_ASTRA_REVIEW`，不得自签`FULL_LOCAL_L13_BASELINE_ACCEPTED`、`V10.1.5_FUNCTION_ACCEPTED`或`G2_READY_FOR_POPEN`。
- Codex必须核GitHub候选Commit/sole Parent/Root，全部变更path/mode/Blob与Manifest匹配、apps/services全Tree与当前已接受main一致、main HEAD未被擅自更新，封存新ledger并永久STOP待Astra独立验收。若候选未能发布，准确报已完成哪些本地门和Git阻断，不伪造Commit。不得自动合main、切默认旧开发路径、清理旧版本、自动启动v10.1.5新业务或v10.1.6。

**正式任务发布不触发后台执行。Owner手动派发后Codex才能以该最新Blob为authority执行。**
