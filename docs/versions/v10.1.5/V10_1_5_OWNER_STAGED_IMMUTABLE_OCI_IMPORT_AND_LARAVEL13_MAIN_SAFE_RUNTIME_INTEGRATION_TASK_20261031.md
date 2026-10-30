# EliteSync v10.1.5｜Owner本地Docker官方镜像验真优先＋Laravel13目标main真实回归＋安全集成｜综合Codex任务（2026-10-31 v1.1，派发前修订）

**状态：OWNER_APPROVED_PRE_DISPATCH_REVISION / OWNER_PULLED_LOCAL_DOCKER_IMAGES_REPORTED / NEW_CONTAINERD_IMAGE_ID_SEMANTICS_ACKNOWLEDGED / AWAITING_OWNER_MANUAL_CODEX_DISPATCH / NOT_EXECUTED / ONE_CONSOLIDATED_TASK_SAME_TASK_ID / OLD_VERSION_BACKUP_RETAINED / NO_PRODUCT_MAIN_MERGE_BEFORE_ASTRA**

签发：2026-10-31 Asia/Singapore。Authority：`zcx369658780/EliteSync-v10`。

## 0. Owner单次综合授权、派发顺序与修订权威

Owner起初批准“手动下载官方镜像材料、再手动派发Codex”；现在已经亲自执行`docker pull php:8.4.27-cli-bookworm`、`docker pull mariadb:10.11.19-ubi9`，并报告`docker image inspect mariadb:10.11.19-jammy`结果。两种本地`linux/amd64`镜像来源事实已由Owner给出，但**尚未由Codex独立验证实际Registry平台Manifest、配置及diffID**。Owner明确要求“继续修改任务单”。因此本**同一尚未派发的正式任务ID**于2026-10-31进行v1.1派发前修订；旧任务Git Blob `ff6a33189984956ec39bf038cb5e7b1d4204b267`被本次新Blob正式取代，旧Git历史只供审计、不能再作为Codex启动authority。

**修订后第一输入源改为Owner已经pull、存于Docker Desktop本地containerd内容存储的指定官方镜像，不要求Owner再次下载ZIP/TAR，也不要求Downloads中必须有`owner-download-manifest.json`。** `C:\Users\zcxve\Downloads`仍是Owner仅在本地镜像无法完成可信资格核验时可选的原始OCI文件备选，绝不默认扫描该目录。下载/拉取已经由Owner在新任务派发前完成，新任务明确记为`OWNER_EXTERNAL_DOCKER_PULL`，不能将其归为新task代理的供应消耗0。

仍然严格保持：**现在只正式发布修订任务，不自动启动Codex或运行本机Docker/PHP/DB**。只有Owner稍后手动复制本任务最新SHA对应的启动Prompt后，Codex才可以先验镜像、必要时从官方注册表受控读取manifest/config元数据，资格通过后在一个新独立任务中完成Laravel13目标main的合成验证；不自动拉取、更新、删除Owner镜像或共享容器/卷。本任务不是已STOP f407任务的续跑，不能复用其余额/任务根。

**镜像Id不能等同Config Digest：** Docker Engine29 containerd image store可能把Index target digest显示为`docker image inspect .Id`。PHP本地`.Id=sha256:54b467...`与冻Index吻合，不因其与旧config`sha256:12f6...`不同判错。MariaDB本地`.Id=sha256:7db293...`与旧Index `d769e379...`不符，但官方Hub确有另一个10.11.19-jammy index候选；必须明确分辨两个immutable来源，不能按tag或Id直接PASS。

## 1. 冻结Authority、Parent与来源

- 现有GitHub正式main版本仅v10.1.4接受并产品集成：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本任务发布前main文档HEAD `3a17241baec6cd41a4f1d67f36cfae624192ecbd`；它由前main `9b9a4b8ec7364f112fa039cb4d45575b6152ba9f`仅新增手动下载指南。任务及ACTIVE_STATE追加后main文档HEAD会更新。**研发安全集成候选的唯一Parent应是Codex开工时fresh HEAD of main，且双产品Tree必须仍为上述接受基线**。新候选不得以任何Astra审查分支或f407原候选作为Git Parent，不force、不直接向main推送产品源码。
- 已通过Astra限定接受的选择性Laravel13静态集成候选（**源码输入，不是已运行通过**）：`f407e543e1d6bcd3f9f7f341d876d97dc7228ac1`，Root `976bde38f80720bb9ac44c1a5808e6cc62c686e1`，sole Parent `7a4595c60ac2fced957cd3bffd132daa23b4db74`，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0d1a1e9b1c1064e7746051fb1e939e63c2b70891`。 18项差异只包含10个后端兼容路径与8个文档，源码选择锁定在`docs/versions/v10.1.5/LARAVEL13_SOURCE_SELECTION_AND_DIFF_MAP_20261030.md`（候选Blob `0845d8594de13d5f668bcb784bf336fda0843c4b`）。
- 以前运行过真实Linux Laravel13/DB回归的较宽候选 `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`，Root`3b9690c1cdd6313d8f192c0ca4105352b8b40188`，Astra仅有界合成接受；其中F1/F3/F4未正式整版接受业务源码不可整树合并。新的目标是**f407的main选定代码**与当前冻结v10.1.4业务，不准借旧9b的258测试/3071断言直接宣称新候选已验证。
- 最新Astra f407独立审查：`docs/versions/v10.1.5/F407E543_LOCAL_BACKUP_STATIC_L13_INTEGRATION_ASTRA_REVIEW_20261030.md` 在Review Commit`347423ee36e5c719827df784826fb400a2892269`，Blob`f6b816e4839b491abb68a3478b5406afd4f94aa6`，裁决`STATIC_SELECTION_ACCEPTED_WITH_OBSERVATIONS / BACKUP_VERIFIED_CODEX_REPORTED / DYNAMIC_SUPPLY_BLOCKED`。
- 正式先行任务`V10_1_5_L13_PHP84_BASELINE_SAFE_INTEGRATION_AND_PREMIGRATION_LOCAL_BACKUP_TASK_20261030.md` Blob`63712dba26ec1c24539bec7082dd4f0c557df583`永久STOP；不得续其旧账本/预算和OCI task tag。
- 新手动下载权威指南：`docs/versions/v10.1.5/OWNER_MANUAL_OFFICIAL_OCI_DOWNLOAD_GUIDE_20261031.md`，Blob`7722a26ede33b7af0c8b4b39d112f4d0805a9645`。Owner Downloads取件是预备操作，任何LOCAL_ONLY配置、完整供应体、个人下载目录内容不上传公开仓库。
- 新任务开工必须fresh读取main/Root/ACTIVE_STATE/CURRENT_WORKFLOW Blob`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`/TASK_DISPATCH_CLOSURE_PROTOCOL Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结v10.1.5 plan Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`、AC01–11及既有15场景和所有历史事故门禁。任何不一致先分类而不猜测/覆盖。

## 2. Owner已拉取Docker本地镜像的核验优先；Downloads为非强制备选

### 2.1 已观察内容、官方候选与禁止误判

Owner在新任务派发前报告：
- PHP `php:8.4.27-cli-bookworm`：pull显示Index`sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`、inspect `linux/amd64`和相同`.Id`；原任务冻结该Index、平台Manifest`sha256:dd0e2b902f1edfb6ca02fbcb391c28b1554c7d35a4e36e5925876b90aa804851`与Config`sha256:12f6d2ea136f247580f3dc42bda86b27af080fa8f04ea5ec9b581238702093ff`。Tag不是身份，仍须核平台Manifest与Config、diffIDs。
- MariaDB `mariadb:10.11.19-jammy`：inspect `linux/amd64`、`.Id=sha256:7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`。原冻结Index为`sha256:d769e37960821dfdcf096954f6e7ac89f747e116c1bba98e48edd265dfc7deae`、amd64 Manifest`sha256:6c65a843396dc6c78dd0da19eccaa0a91d25d9d26a4c2afcb75010ac3f59f5ea`、Config`sha256:72b6ab51626b71b6118295b90c9408e537ff1cfdaa0b35c9930e8c2ee49a47bf`。
- **获Owner本次修订允许核查的MariaDB备选官方Index为`sha256:7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`，Docker Hub显示对应`linux/amd64` Manifest`sha256:dc9dd57be7f46ad6f350c598a331d64f295899c4abac3ec5652eff831fc38a6c`**。它与旧冻结Manifest不同，新Config/DiffIDs只能从该官方Registry固定Manifest关联的原字节取得并重新验证，不能借用旧MariaDB config hash或一口咬定等价。
- Owner另已`docker pull mariadb:10.11.19-ubi9`，其index`sha256:045945c5dbc95ee4ec84429f594682f66c50145423ace36ee293cbff805c0a49`，这不是本任务允许的MariaDB Jammy基础源；**不运行、不修改、不删除，也不拿来替补**。

### 2.2 在现有引擎做只读源码资格闭环

1. 在新task-owned root / attempt-0001 / ledger与保护快照建立后，使用**已在运行、固定本机Docker Desktop Linux endpoint**读取CLI/Engine/context、许可、版本、签名/Host身份；不得启动/重启/升级Docker Desktop或WSL，不读取/控制任何非任务的容器或共享卷。
2. 只对明确允许的`php:8.4.27-cli-bookworm`和`mariadb:10.11.19-jammy`调用有界只读`docker image inspect --platform linux/amd64`、`RepoDigests`、`Descriptor`、`RootFS.Layers`、平台、大小/本地存储ID等。**不得把`.Id`与config SHA直接相等作为独立验收判据，也不能把显示tag作为原生官方真实性证明。**
3. 优先使用已存在、受控的官方Registry固定index/amd64 manifest元数据。如果必须联网读取，使用正式任务的可信 HTTPS allowlist/单独计量，计入所有失败/redirect/真实response bytes且PREPARE+fsync。按绑定registry来源→index→唯一amd64 manifest→config digest→layers descriptor形成闭环。**如果Owner本地MariaDB当前index`7db...`与官方确切平台Manifest`dc9dd...`匹配且实际config/diff-id也和官方源一致，可分类`QUALIFIED_OFFICIAL_ALTERNATE_MARIADB_10_11_19_JAMMY`，但不可倒写成旧`d769...`的原镜像，也不可声称已经校验原compressed layers全部raw。**
4. 如需从本机镜像存储取得静态可检查文件，可使用只读源的`docker image save --platform linux/amd64 --output <new_task_private_path>`，仅导出上面两个具名镜像到新根的受预算控制目录，核export tar/manifest/config bytes的SHA256、`rootfs.diff_ids`链、platform和官方config要求；**Docker save重打包后的uncompressed layer tar SHA不能冒称原Registry gzip层SHA**。不对Owner镜像做tag/rm/prune/pull/push/重新下载，不改变共享内容存储设置；只有证明对应版本身份和任务私有运行边界后，才能创建具名自有新容器/镜像和空数据库开展测试。
5. 仅凭`RepoDigests`或`Descriptor`也不够，缺官方源侧manifest/config联系、config/RootFS匹配或任务私有目录隔离证据时STOP，具名列出断点，不运行。测试实际MariaDB binary报告真实`10.11.19`patch，否则不能说补丁版合格。
6. Owner先前手动拉取属于`OWNER_EXTERNAL_DOCKER_PULL`，不算新Codex任务代理下载请求，但**必须单列真实已知Index、平台、源和Owner提供的总量或`UNKNOWN_EXTERNAL_BYTES/REQUESTS`**，不能写“所有供给0”。任何新task网络供应（Composer2 PHAR、114包dist/apt等）须独立受控计量；不得以Owner本机镜像为由绕过供应安全检查。
7. `C:\Users\zcxve\Downloads`中的原始OCI文件仅是**备选**：只有上述本地镜像验证失败且Owner另明确交付具名文件与Manifest后才读取。禁止整目录扫描、运行下载器脚本、触碰其它个人文件，也不强制再下载一套镜像。若确无合格来源证据，本任务集中BLOCKED而非暗中改用UBI9、旧STOP卷或其它镜像。

### 2.3 前置硬门

不得用`docker pull`再次下载、不得全局Docker cache/镜像清理、不得改变用户当前镜像tag、不得创建对外网络或生产DB连接。所有新镜像/容器/卷只允许任务专属标签、UID与独立隔离新空库；Docker命令allowlist与防host network、privileged、Docker socket mount原门禁持续有效。旧版备份和原本main业务状态参照第3节以下原冻结约束。

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
- **总窗口≤240分钟**，当前任务根逻辑/分配空间各≤**16GiB**（Owner Downloads外部文件是原Owner分区，task-owned新副本与后续解压/构建计入任务空间；原旧11,066备份不可抵扣）。供给受控响应≤**2GiB/500次请求**；使用2份已由Owner拉取且合格的官方镜像（PHP固定Index和MariaDB旧Index或受限新版Index；Distinct受控身份Digest≤8，不把原外部pull暗计入新任务）；offline Docker build≤**2**；Composer solver **0**、vendor install≤**2**；task服务组≤**3**；PHP CLI≤**150**；Feature/Unit≤**5批**；HTTP合成业务≤**180**；MariaDB迁移≤**2**、seed≤**2**；本轮Desktop/WSL启动/重启/升级/安装额度**0**。失败、超时、重试照计，外部Owner下载字节以独立栏记录，不能混算内部额度。服务内存/磁盘资源不足STOP，无权释放旧资产。
- 如无法建立有效供应计数、可信镜像层、合格空DB隔离、old backup保护、预算时限，必须集中BLOCKED报告，保留原始失败与partial，**不擅自重试或使用未核镜像**。
- 默认直接对Owner已有本机Docker content store进行具名只读核验，不以Downloads完整OCI文件为必要前置；如Owner另交原始文件只读取明确相对路径清单，不执行任何脚本，不扫描其它Downloads文件。

## 6. 单一候选与验收交付

- 冻结**一份普通non-force研发分支候选**，其唯一Git Parent是开工fresh主线文档HEAD（须保持v10.1.4被接受产品双Tree），差异不含旧风险分支完整合并。Codex不能直接把候选合到main；即使合成测试全部PASS亦不能自签`INTEGRATION_ACCEPTED`、`V10.1.5_FUNCTION_ACCEPTED`、`G2_READY_FOR_POPEN`或`AC05_CLOSED`。
- 必交`docs/versions/v10.1.5/OWNER_STAGED_OCI_LARAVEL13_MAIN_RUNTIME_INTEGRATION_RESULT_20261031.md`、`docs/versions/v10.1.5/owner_staged_oci_laravel13_main_runtime_integration_manifest_20261031.json`；如需要附新工具/测试/精确来源包与原差异图、备份/rollback只读复核摘要、Owner-pulled本机镜像RepoDigests/Descriptor/官方平台Config校验、必要时task-owned导出证据与临时URL/token不留存证明、Composer的新供应回执、HTTP/DB和安全负例/预算/终态报告。所有个人Downloads绝对路径、CLI环境敏感变量、原token/cookie、用户资料/私有DB/完整vendor/OCI压缩体/日志`LOCAL_ONLY`，公开仅脱敏Hash/状态。
- 发布后用fresh GitHub回读候选Commit唯一Parent、Root、每条变更path/mode/Blob、完整apps/services Tree、live main/ACTIVE_STATE；封存唯一ledger并STOP等待Astra独立验收。无资格就只交`BLOCKED_... / NO_PRODUCT_INTEGRATION`，原旧版本/备份与历史保护保持不变。
- 当前永恒门禁：v10.1.5仍`10_PARTIAL_1_OPEN`、AC05 RTC/AEC OPEN、REAL_PUSH_PROVIDER_PENDING、G2_FALSE、OS_ENFORCEMENT_NOT_PROVEN、v10.1.6 NOT_STARTED；Owner正式选Laravel13/PHP8.4是开发方向，不等于生产部署。除非后续Owner按明确清理对象再授权，本任务**禁止删除旧版或原备份**。
