# EliteSync v10.1.5｜15b23d8c 便携MariaDB与私有Flutter运行验证｜Astra独立验收

日期：2026-10-29（Asia/Singapore）。

**正式裁决：`15B23D8C_BOUNDED_MARIADB_RUNTIME_ACCEPTED_FLUTTER_ANALYZE_ACCEPTED_WIDGET_BLOCKED_WITH_OBSERVATIONS`。**

接受：本轮真实私有MariaDB环境及有界F1/F2/F3 Laravel Feature/HTTP/并发运行的**Codex有源执行证据**，新增私有MariaDB资格守卫的固定Git源码，Flutter私有工具链analyze运行证据，以及受阻Widget测试的保守停止和全部保留失败。**不**接受：Flutter Widget/unit用例通过、物理15/30天与设备密文清理、真实Push/RTC/设备APP、系统shell启动批次已完全隔离、v10.1.5整版功能接受、AC05关闭或产品main集成。

## 一、冻结权威与GitHub完整身份

- 正式Owner授权：`docs/versions/v10.1.5/V10_1_5_PORTABLE_MARIADB_PRIVATE_FLUTTER_ENV_RECOVERY_AND_SCOPED_VALIDATION_TASK_20261029.md`，Blob **`48d3670ac26b1959c1b59ffb4871109cef09a4c8`**。此合同一次性允许可信官方MariaDB Windows ZIP、私有Flutter SDK及离线依赖、真实合成MariaDB与定向Flutter测试；同时绝对禁止旧ACL、G2/Gradle/设备、历史SQL/共享SDK写面、服务全局安装和产品main集成。
- 开审fresh main **`b35047ad13865ccc18d6b479b9c21bba5b0f6fc3`** / Root **`358f7eccd4be73c0819ccee098d5bf99a5ee499c`**；`ACTIVE_STATE` Blob `12dbffb1de1de010a1255cdbee57f01b907a5049`。main唯一正式已接受产品v10.1.4 apps **`3468a3dd97da7accfda2539a0f8d8f68931a6110`**、services **`0cb1f9d19659291a462488b3686fd0a07a6698ac`**。
- Codex唯一候选 `15b23d8cacfa1429f6f77b8d57a86fff6b827673`，sole Parent **`955307d8c1cd95897e5af0f19a347c6fa4e77ff1`**，Root **`025af603a46550721d863d354246e76d9bd072b0`**。GitHub compare 955→15b：**ahead1/behind0**，9源码/测试/配置和2文档，共**11路径**，没有无关产品大合并。完整递归Root **6272项**、`truncated=false`；候选apps `29c3274654a03db7dbe2a53eb02a07686281266b`（729 Blob）、services `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 Blob），各自递归未截断。与main接受的产品双Tree必须严格区分。
- 综合报告 `docs/versions/v10.1.5/PORTABLE_TOOLCHAIN_RECOVERY_AND_SCOPED_VALIDATION_REPORT_20261029.md`，Git Blob **`5ec34d508f0e28c887b7527edc166aaf085d530b`**；脱敏索引 `docs/versions/v10.1.5/portable_toolchain_scoped_validation_evidence_index_20261029.json`，Git Blob **`cc534ec2d621e7e6e40ca957b65dab6b1d255fec`**。两文件从固定候选按路径读回，索引可解析；本轮`sourceProvenance`9项candidate Blob与真实Git递归Tree 9/9相等。Astra直接阅读了关键PHP资格守卫、测试入口、场景执行脚本、Dart局部变更对应文件，但**没有**亲自读取所有本地原始SQL日志、GPG验证文件或Windows运行进程。
- 本轮公开索引包含**225条executionTimeline条目**和37份LOCAL_ONLY原始材料摘要/Hash；ledger`56ddcc0283d48caee14ae42b5cfe3f17fe49c9d718b8f810d73ed51b7950dfdb`仅为**发布前checkpoint**（非终态完整账本），后续发布/终回读需以本机完成回执核查。Astra独立验证的是公开Git对象和叙述内一致性，不把Codex本地记录升级为独立OS观察。

## 二、官方来源与隔离MariaDB真实运行

Codex报告官方Windows x64 MariaDB Community Server **10.11.19** ZIP `93557290` bytes，SHA256 `398ea30e5036010bbebe01d2b1804280424dcc2626e36d8e95155c04d25a0490`；GPG detached ZIP/清单签名均匹配指纹 `177F4010FE56CA3336300305F1656F24C74CD1D8`；官方DLM经`storage.googleapis.com` CDN。Astra公开复核：MariaDB官方2026-08-24公告列有10.11.19；MariaDB官方GPG文档确列上述指纹；**Astra未取得ZIP、独立验证其SHA或GPG签名，也未取到CDN最终私有临时URL**，后二者属于`CODEX_REPORTED_LOCAL_EXECUTION`，不可标为`ASTRA_DIRECT_BINARY_VERIFIED`。

报告和索引记录：唯一新datadir初始化一次，真实查询`10.11.19-MariaDB` / `127.0.0.1:43329` / task私有datadir / server ID / DB`elitesync_v1015_verify_20261029`，初始0表；HTTP API只在`127.0.0.1:43339`。在此**新实例**中先发现vendor bootstrap把`test`与`test\\_%`权限授权给PUBLIC，记录失败后仅从此新实例撤销，并固定task用户只能修改当前合成schema；不是修改旧数据库或系统权限。正式资格守卫会在迁移/请求前核对有效配置、可信task proof SHA、实际连接的版本/port/datadir/server_id、当前用户及SHOW GRANTS；源码确实增加强制测试前核验及独立反例，但**该运行期资格hash是task runner一致性门，不是对拥有进程环境与文件写权攻击者的密码学安全认证**。

运行边界与已证事实（限本次）：
- `23`条Laravel Feature、`152`断言：Codex记录exit0，具名F1/Messaging、F2/TrustedLogin、F3/Notification Delivery的测试矩阵记录为PASS；
- `27`个最终纯资格/反例测试、`43`断言：exit0，**无PDO/DB使用**，不得叠加计算为23条数据库Feature；
- 另外有前序混合批次`47`项/`176`断言，含此前版本的24项纯guard，不是新增47条数据库Feature；保留2项vendor弃用提示；
- HTTP回环同键重试200、异payload409，Block/MC/CN撤权后404，旧token401、通知最低披露与偏好/注销负例；三组“丢响应”是**收到但丢弃应用层响应**的合成场景，不是实际物理网线中断；
- 两个独立MariaDB连接/进程在同key竞态后得到同一个message ID，消息与通知各增加1，事务已提交；**实际lock-wait观测未证明**，不得把源码`lockForUpdate`存在或processlist Sleep归类成已捕获锁等待；
- 真实数据库中的成功登录T0、refresh不续期、会话撤权和合成15日边界/旧凭据拒绝，以及TEST_ONLY设备/通知状态已获得新的有界服务端业务测试证据。实际15/30日经过、设备Keystore/物理清理与真实Push依旧NOT_PROVEN。
- 两个task-owned服务均报告已安全停止，原SQL/HTTP trace/JUnit/数据库快照只保存在LOCAL_ONLY；GitHub本身不能独立证明实时监听器确实关闭。

## 三、Flutter真实analyze通过，但Widget仍为0个测试用例

Codex报告Flutter3.41.7/Dart3.11.5：在task私有目录形成一套18,000文件/3,277,475,095 bytes的SDK完整镜像、170项APP解析和102项工具解析、266份必要离线包副本；`dart pub get --offline --enforce-lockfile --no-precompile`成功且无依赖网络下载，当前候选经task私有`flutter_tools.snapshot`定向analyze最终`exit0 / No issues found`。对此Astra接受**有源CodeX本地analyze运行证据**；未现场重跑命令，不断言整个APP全量编译/Android构建PASS。

Widget/unit的真实状态：
- 11个具名测试文件存在、实际执行到断言的**用例数0**。前有缺package_graph阻断，补齐后`hooks_runner-1.0.1`在Windows以`runInShell`调用系统`System32\\cmd.exe`；任务进程守卫终止了报告中的3个观测批次。既有`COMSPEC/WINDIR`私有路由不能消除系统shell路径；不能放松守卫或把尝试启动当成测试PASS。
- 由Codex报告的Flutter SDK/引擎/私有Pub包首尾Hash一致性是本地证据；系统shell批次的完整进程/写入闭包仍`NOT_PROVEN`，未捕获所有瞬时命令行和潜在副作用。不要把`0测试用例`错写成`0次测试启动尝试`，也不要把失败归为“APP有11个失败测试”。
- 这次阻断已具体定位到一个task私有运行器依赖的Windows shell启动路径，**不是**需要重做Flutter SDK镜像、再下载MariaDB或重新准备整个环境。

## 四、9个源码/测试/配置变更的限定审阅

`SOURCE_PROVENANCE` 9/9对应Git对象：
- Flutter两个Dart文件 `notification_center_page.dart`、`session_provider.dart`只有限定mounted/结构性检查，源码侧未发现对用户权限刻意放宽；由于Widget未运行，异步生命周期/布局效果仍不能验收。
- Laravel `LiveConsentService.php`在`testing`环境下增加**仅带task资格环境标记时**可调用的MariaDB测试入口；原local环境固定已接受数据库白名单没有变成通用生产MariaDB开关。新`app/Support/PrivateMariaDbQualification.php`验证配置、实例与权限，`tests/TestCase.php`在执行migration前二选一：task MariaDB完整qualification，否则仅原SQLite in-memory许可。私有phpunit XML、对应负面守卫单测、场景脚本都按固定task运行，不能误用成产品长期生产DB身份基础。
- 设计观察：`assertGrants`按SHOW GRANTS文本模式限制task schema，足以作为本轮限定回执的辅助保护，但不应将其当成通用SQL授权安全证明；其可信性依赖当前MariaDB privilege表现和task runner真实身份。日后若推广，必须按DB权限模型重新设计。
- 运行成功不证明候选整体业务无缺陷；本轮只有这9个文件的变化获得限定源码审阅，既有全部Flutter/后端功能并没有因此自动升级成整版AC。

## 五、预算与历史保留

索引汇总同一task及attempt：
`ZIP_DOWNLOAD 1/1`、`SDK_MIRROR 1/1`、`SOURCE_IMPORT 1/1`、`DB_INIT 1/1`、`MARIADB_SERVER 2/2`（保守包含初始化mysqld bootstrap与正常服务进程）、`PHP_API 1/2`。不能把剩余API启动1次视为后继任务自动授权，MariaDB没有本任务新的启动余额。出现SDK镜像超时后按同一预留/同一目录续接，没有第二镜像或任务预算退款。数据库默认PUBLIC授权风险已在**本任务私有实例**修正；不修改全局用户/服务。

task-owned当前报告最大已观测logical `4565932463`、allocated `4671977360` bytes，分别低于8GiB；本轮**并无全程连续峰值采样**，报告不能声称已证明任何时刻均不超预算。ZIP/私有镜像/两服务/测试原失败、私有日志由本地ledger记录，Astra只验GitHub公开索引和计数内部一致性。旧955受阻ledger只读留存，旧两ACL实验树、18旧对象、122原证/五保护根/527refs/3183 Seed、历史失败和claim不被修改或清理，当前轮没有再对旧18逐项做全量OS重验。旧ACL跨尝试超额`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`按Owner决定继续封存，不因本轮数据库成绩退款或变成合规。

持续`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。Gradle/G2/Android/设备RTC/真实Push均未获本轮运行许可。

## 六、最终裁决、下一窄门及STOP

**`15B23D8C_BOUNDED_MARIADB_RUNTIME_ACCEPTED_FLUTTER_ANALYZE_ACCEPTED_WIDGET_BLOCKED_WITH_OBSERVATIONS`**：接受基于准确Git对象、明确分层的真实合成MariaDB/Laravel Feature/HTTP并发与撤权证据，以及离线私有Flutter工具链analyze证据；保留Widget/unit运行0用例、OS shell hook完整闭包不证、物理离线与真实Push等全部限制。这个判定不是我直接复测本机环境，也不是`V10.1.5_FUNCTION_ACCEPTED`。

**唯一下一建议**：不再重复MariaDB下载/Flutter镜像或耗费已用尽的MariaDB server预算；由Owner明确一次**只修测试Hook Windows system shell启动行为的私有工具适配/隔离**的有界授权，先取得可信的任务私有hook runner来源/改造方案和零共享写入证明，再让已存在的11个Flutter测试在安全私有环境运行。若需在新会话重新启动旧服务、修改第三方vendor/SDK或动用新预算，必须另行审批，旧task ledger不可重置。避免把此目标变成泛化G2/Gradle恢复调查。

**STOP等待Owner方向；不自动发布下一正式任务、不自动重启MariaDB/API、不合main、不释放G2、不清理历史或进入v10.1.6。**
