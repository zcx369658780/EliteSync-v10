# EliteSync v10.1.5｜Owner已备下载材料验真＋固定OCI离线导入＋Laravel13目标main真实回归＋安全集成｜综合Codex任务

**状态：OWNER_APPROVED_FORMAL_TASK_PUBLICATION / AWAITING_OWNER_DOWNLOAD_BEFORE_MANUAL_CODEX_DISPATCH / NOT_EXECUTED / ONE_COMPREHENSIVE_TASK / OLD_VERSION_BACKUP_RETAINED / NO_PRODUCT_MAIN_MERGE_BEFORE_ASTRA**

签发：2026-10-31 Asia/Singapore。Authority：`zcx369658780/EliteSync-v10`。

## 0. Owner单次综合授权与派发顺序

Owner明确批准下一阶段手动官方下载材料与离线验真路线：“可以我同意，我会将下载的文件放在`C:\Users\zcxve\Downloads`，并且下载好后才给Codex启动prompt。请你下达任务单。”

因此本任务**现在只正式发布，不等于下载已经完成，不等于派发Codex或启动Docker**。Owner先下载、暂存在Downloads；待Owner确信文件已完成，再亲自把最新本任务的精准Blob与唯一启动Prompt交给Codex。Codex不可在Owner手动派发前预执行，Astra不替Owner操作Windows。

范围是**一次**：Owner staged官方immutable OCI文件 → 新task-owned隔离验真/导入 → 在**选择性main产品源码候选**完成真实PHP8.4+Laravel13+Composer锁/vendor+独立空MariaDB/HTTP和权限正反例 → 单一候选交付 → Astra独立安全集成验收。若正常框架兼容问题出现，Codex在本任务内集中修；不得另行发布十多个微任务。产品main、默认本地开发入口、旧版/备份均维持不动，直至Astra后续独立接受并确定集成授权。

## 1. 冻结Authority、Parent与来源

- 现有GitHub正式main版本仅v10.1.4接受并产品集成：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本任务发布前main文档HEAD `3a17241baec6cd41a4f1d67f36cfae624192ecbd`；它由前main `9b9a4b8ec7364f112fa039cb4d45575b6152ba9f`仅新增手动下载指南。任务及ACTIVE_STATE追加后main文档HEAD会更新。**研发安全集成候选的唯一Parent应是Codex开工时fresh HEAD of main，且双产品Tree必须仍为上述接受基线**。新候选不得以任何Astra审查分支或f407原候选作为Git Parent，不force、不直接向main推送产品源码。
- 已通过Astra限定接受的选择性Laravel13静态集成候选（**源码输入，不是已运行通过**）：`f407e543e1d6bcd3f9f7f341d876d97dc7228ac1`，Root `976bde38f80720bb9ac44c1a5808e6cc62c686e1`，sole Parent `7a4595c60ac2fced957cd3bffd132daa23b4db74`，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0d1a1e9b1c1064e7746051fb1e939e63c2b70891`。 18项差异只包含10个后端兼容路径与8个文档，源码选择锁定在`docs/versions/v10.1.5/LARAVEL13_SOURCE_SELECTION_AND_DIFF_MAP_20261030.md`（候选Blob `0845d8594de13d5f668bcb784bf336fda0843c4b`）。
- 以前运行过真实Linux Laravel13/DB回归的较宽候选 `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`，Root`3b9690c1cdd6313d8f192c0ca4105352b8b40188`，Astra仅有界合成接受；其中F1/F3/F4未正式整版接受业务源码不可整树合并。新的目标是**f407的main选定代码**与当前冻结v10.1.4业务，不准借旧9b的258测试/3071断言直接宣称新候选已验证。
- 最新Astra f407独立审查：`docs/versions/v10.1.5/F407E543_LOCAL_BACKUP_STATIC_L13_INTEGRATION_ASTRA_REVIEW_20261030.md` 在Review Commit`347423ee36e5c719827df784826fb400a2892269`，Blob`f6b816e4839b491abb68a3478b5406afd4f94aa6`，裁决`STATIC_SELECTION_ACCEPTED_WITH_OBSERVATIONS / BACKUP_VERIFIED_CODEX_REPORTED / DYNAMIC_SUPPLY_BLOCKED`。
- 正式先行任务`V10_1_5_L13_PHP84_BASELINE_SAFE_INTEGRATION_AND_PREMIGRATION_LOCAL_BACKUP_TASK_20261030.md` Blob`63712dba26ec1c24539bec7082dd4f0c557df583`永久STOP；不得续其旧账本/预算和OCI task tag。
- 新手动下载权威指南：`docs/versions/v10.1.5/OWNER_MANUAL_OFFICIAL_OCI_DOWNLOAD_GUIDE_20261031.md`，Blob`47aad6d1ad89f9c6e680af53cd42623874060c47`。Owner Downloads取件是预备操作，任何LOCAL_ONLY配置、完整供应体、个人下载目录内容不上传公开仓库。
- 新任务开工必须fresh读取main/Root/ACTIVE_STATE/CURRENT_WORKFLOW Blob`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`/TASK_DISPATCH_CLOSURE_PROTOCOL Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结v10.1.5 plan Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`、AC01–11及既有15场景和所有历史事故门禁。任何不一致先分类而不猜测/覆盖。

## 2. Owner预下载文件与严格验真入口

- 固定本机 Owner 文件输入根：`C:\Users\zcxve\Downloads`；建议清晰子目录 `C:\Users\zcxve\Downloads\EliteSync-v1015-OCI-20261031`，下有`php/`、`mariadb/`与`owner-download-manifest.json`。也允许文件直接放Downloads根，但必须提供**明确相对路径清单**，以固定Digest/安全规范识别，禁止Codex全目录递归枚举或接触其它用户下载文件。若Owner只提供部分文件/Manifest或文件过期，不自行回收旧task资产补位，集中BLOCKED报告。
- **Owner 下载源**只允许官方 Docker Hub/OCI Registry，固定`library/php`官方 PHP 8.4.27 CLI bookworm 与`library/mariadb`10.11当时已冻结的index/platform manifest。PHP index `sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`、linux/amd64 manifest `sha256:dd0e2b902f1edfb6ca02fbcb391c28b1554c7d35a4e36e5925876b90aa804851`、config `sha256:12f6d2ea136f247580f3dc42bda86b27af080fa8f04ea5ec9b581238702093ff`。MariaDB index `sha256:d769e37960821dfdcf096954f6e7ac89f747e116c1bba98e48edd265dfc7deae`、linux/amd64 manifest `sha256:6c65a843396dc6c78dd0da19eccaa0a91d25d9d26a4c2afcb75010ac3f59f5ea`、config `sha256:72b6ab51626b71b6118295b90c9408e537ff1cfdaa0b35c9930e8c2ee49a47bf`。总完整 layer 列表以**已核固定manifest原文**为准；标签只做展示不可动态漂移。MariaDB实际patch通过已校验镜像内部版本输出再确定，不能仅凭10.11标签冒充10.11.19。
- Owner可从会话提供可选本地下载辅助脚本`EliteSync_Owner_Official_OCI_Download_20261031.py`（SHA256 `12e6b6e0fa10b3542f245162e2fb1ac8def93d4346f5961b44d3a7d899e2afde`）下载，只需Owner主动运行；该脚本不是由Astra在Owner电脑执行，也未作Windows端实时运行证明。无需强制使用它；其它官方工具产生相同不可变文件和清单亦可。Codex**绝不执行来自Downloads的未知脚本或命令**；下载原文件是数据输入，不是代码许可。
- Codex**先在新的唯一任务根**对Owner明确交付的每一文件重新验证：源文件identity/ACL、no symlink/reparse/hardlink转义、上限与大小；对OCI index、manifest、config、全部Layer分别SHA256字节回读及Descriptor size、OS/ARCH、平台选取；解压后逐layer diff-id、tar路径/links/special file安全拒绝，组成任务私有OCI/Docker image import包，审查导入后实际image config、RootFS diff-id和task-only tag。无法严格符合即STOP，不能删/改Owner原下载文件或用其文件名/可变tag代替签名链。
- **供应计费分离而非绕过**：Owner独立下载在Codex任务开工之前发生，须记`OWNER_EXTERNAL_SUPPLY_INPUT_BYTES_AND_DIGESTS`、来源依据与`EXTERNAL_REQUEST_COUNT_NOT_METERED_BY_CODEX`；不能虚写“所有网络请求=0”或用Owner行为充值/绕开本任务配额。Codex后续自己的网络供给（例如Composer包）必须走另行PREPARE+fsync/响应与重定向字节硬预算；不允许直接不受控`docker pull`、外部镜像tag替换、原STOP任务task标签/卷/数据库复用。Owner下载的东西不能自动视为无条件可信。
- **无需Owner再下载PHP/MariaDB以外的包作为预派发条件**。Composer2官方PHAR、锁定包的114份dist或必要Debian依赖若合格环境/已校验私有存储不足，Codex在**本次新任务**根据冻结lock真实供给并计量。若合法计量/网络闭包不可完成则一次集中BLOCKED，不擅自要求Owner安装全局软件或上传账号token。

## 3. 强制旧版本备份保护门

- 前轮旧本机备份已由Codex报告：`C:\Users\zcxve\EliteSyncBackups\20261030-main-7a4595c60ac2fced-local-4bebc8f3`（Owner提供精确路径）、11,066文件、240,617,393 bytes、逐文件SHA回读与隔离恢复试读，备份Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。**这不是公开可下载文件**，不得上传其raw/ACL/敏感配置或误认为真实数据库/物理异盘灾备。
- 本轮须对原备份/原dirty工作根/旧vendor/历史LOCAL_ONLY证据**具名只读保护check**，不必每轮再复制11,066件来凑人工活动，但需确认备份目录仍在、Manifest与必要抽样或全量hash（由预算允许的范围）无异常、原始旧目录/dirty 252项/527 refs/index、旧18/两ACL/122原证/五根/3183 Seed、历史旧task STOP/ledger事故状态未变。任何用户私有资料仍LOCAL_ONLY。
- 无权移走、覆盖或删除旧版、原备份、旧PHP/vendor、历史索引/根/数据、其它项目Docker volume，任何磁盘空间不足先STOP而不是清理。Owner说“新版本迁移成功后再删除”是未来按精确目标**再次单独授权**的可能清理，不属于本任务。整个项目仍无完整旧生产DB回滚验收。

## 4. 一次隔离真实迁移/验证：目标是f407的已接受main业务，而非9b全分支

1. 从开工fresh main完整创建**新task-owned干净集成工作树**，从f407候选只导入此前静态已接受10条后端兼容路径（包括Laravel13 composer.json Blob `130793decf84ff8ab93faa0300117b7fab9d1826`、composer.lock Blob `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`、session.php Blob `dbcb582d0afbab3a0dc95576797730555ce3cd8d`、7项精确测试适配）；差异由Git Blob/mode/主树逐项约束。原v10.1.4的应用业务app Controller/Routes/Middleware/Model/Service、SQLite TestCase等全保留main；不直接覆盖候选services Tree，不偷渡尚未整版接受的F1/F3/F4新增业务与迁移/通知/可信T0。
2. **先确保输入包/Runtime真实合格**：PHP8.4、所有必要扩展、Composer稳定2.x、Laravel13锁v13.39.0、MariaDB10.11实际patch；新容器资源最小权限、独立私有空MariaDB数据库与新synthetic身份，独立PORT/UID/私有network、禁止host network、privileged、socket mount、旧43349/43359、宿主已有3306、生产/其它Docker项目。所有credential、vendor、真实OCI bytes、DB卷和HTTP原始回执`LOCAL_ONLY`。不得安装/更新/重启Docker Desktop/WSL/Windows功能、UAC、系统PATH/全局许可、更改旧ACL、系统服务或生产SSH。
3. 使用真实Composer `validate --strict` 和原freeze lock，`install --no-scripts --no-plugins --no-interaction`到**全新任务私有vendor/cache**、核真实PHP平台扩展和全部package dist SHA/source，不伪造config.platform或`--ignore-platform-reqs`、不手改content-hash。**本任务默认真实solver预算=0**，即保留已签新composer.lock精确identity；如真实锁无法安装，应报告`LOCK_INPUT_INCOMPATIBLE`而不是偷偷重解锁/降Laravel12。
4. 已注意固定composer.json清空scripts/plugins（包括package:discover/旧composer dev入口）：实际对合格Laravel13目标main执行**经提前源码审查的明确包发现/已接受路由命令**及必要自举验证，成本预算内；不得自动运行任意后安装脚本、不把`composer dev`直接起多个无计量进程。Guzzle7→8、Workerman5.1→5.2、lunar-php1.4.0→1.4.7也要有针对性静态/真实使用路径兼容证据。
5. 合成回归必须**运行本轮目标main选择性集成代码**而不是以前9b广义F1/F3/F4版本；至少PHP`-v/-m`、PHP lint、Laravel13真正框架引导、相关Feature/Unit负例（账号/管理员/CSRF/原v10.1.4授权与Block/Media安全、消息幂等边界）及回环HTTP→Laravel→独立空MariaDB migration/seed、重启后的持久读取与否权测试。旧Laravel11生成的真实Cookie不在本轮被验证的情况下必须标`REAL_LEGACY_L11_COOKIE_NOT_PROVEN`；合成PHP序列化fixture只能算合成。H264 video206、真机RTC/AEC、真实Push/物理15/30天仍NOT_RUN。
6. 本轮允许Codex在已冻结兼容/安全范围内自主修复普通Laravel13冲突，**不准默默引入未接受业务代码以修绿色**。若源f407/main因历史分叉而无法只靠框架兼容实现，可在本任务内提交可审计`INTEGRATION_SCOPE_CONFLICT`集中报告并停止正式合main，而非要求Owner逐行审批。最后有界测试可合格时交付候选`LARAVEL13_TARGET_MAIN_RUNTIME_CANDIDATE_PASS_AWAITING_ASTRA`；仍由Astra后续独立验收，不由Codex自签全版。

## 5. 单根新预算与STOP

- task_id `V1015_OWNER_STAGED_OCI_L13_MAIN_RUNTIME_INTEGRATION_20261031`；唯一新root basename `v1015-owner-staged-oci-l13-main-integration-20261031`、attempt-0001、独立持久ledger、单调计时开端。所有成本/命令/HTTP在预写`PREPARE`+`fsync`后消耗；无同任务第二root、无过期重启/余额刷新、不得继续任何历史STOP。
- **总窗口≤240分钟**，当前任务根逻辑/分配空间各≤**16GiB**（Owner Downloads外部文件是原Owner分区，task-owned新副本与后续解压/构建计入任务空间；原旧11,066备份不可抵扣）。供给受控响应≤**2GiB/500次请求**；通过固定OCI引入2份官方镜像（index+manifest各2，Task distinct Digest计≤8）；offline Docker build≤**2**；Composer solver **0**、vendor install≤**2**；task服务组≤**3**；PHP CLI≤**150**；Feature/Unit≤**5批**；HTTP合成业务≤**180**；MariaDB迁移≤**2**、seed≤**2**；本轮Desktop/WSL启动/重启/升级/安装额度**0**。失败、超时、重试照计，外部Owner下载字节以独立栏记录，不能混算内部额度。服务内存/磁盘资源不足STOP，无权释放旧资产。
- 如无法建立有效供应计数、可信镜像层、合格空DB隔离、old backup保护、预算时限，必须集中BLOCKED报告，保留原始失败与partial，**不擅自重试或使用未核镜像**。
- 首次从owner-staged文件读取时，不执行脚本、不触碰Downloads其它文件，不写owner下载目录。只引用用户已提供的固定子目录并使用明确清单。

## 6. 单一候选与验收交付

- 冻结**一份普通non-force研发分支候选**，其唯一Git Parent是开工fresh主线文档HEAD（须保持v10.1.4被接受产品双Tree），差异不含旧风险分支完整合并。Codex不能直接把候选合到main；即使合成测试全部PASS亦不能自签`INTEGRATION_ACCEPTED`、`V10.1.5_FUNCTION_ACCEPTED`、`G2_READY_FOR_POPEN`或`AC05_CLOSED`。
- 必交`docs/versions/v10.1.5/OWNER_STAGED_OCI_LARAVEL13_MAIN_RUNTIME_INTEGRATION_RESULT_20261031.md`、`docs/versions/v10.1.5/owner_staged_oci_laravel13_main_runtime_integration_manifest_20261031.json`；如需要附新工具/测试/精确来源包与原差异图、备份/rollback只读复核摘要、Owner staging ingestion digest与CDN token不留存证明、Composer的新供应回执、HTTP/DB和安全负例/预算/终态报告。所有个人Downloads绝对路径、CLI环境敏感变量、原token/cookie、用户资料/私有DB/完整vendor/OCI压缩体/日志`LOCAL_ONLY`，公开仅脱敏Hash/状态。
- 发布后用fresh GitHub回读候选Commit唯一Parent、Root、每条变更path/mode/Blob、完整apps/services Tree、live main/ACTIVE_STATE；封存唯一ledger并STOP等待Astra独立验收。无资格就只交`BLOCKED_... / NO_PRODUCT_INTEGRATION`，原旧版本/备份与历史保护保持不变。
- 当前永恒门禁：v10.1.5仍`10_PARTIAL_1_OPEN`、AC05 RTC/AEC OPEN、REAL_PUSH_PROVIDER_PENDING、G2_FALSE、OS_ENFORCEMENT_NOT_PROVEN、v10.1.6 NOT_STARTED；Owner正式选Laravel13/PHP8.4是开发方向，不等于生产部署。除非后续Owner按明确清理对象再授权，本任务**禁止删除旧版或原备份**。
