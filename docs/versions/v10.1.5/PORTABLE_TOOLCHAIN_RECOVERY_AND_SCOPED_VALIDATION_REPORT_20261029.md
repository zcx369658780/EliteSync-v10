# v10.1.5 官方便携环境恢复与定向真实验证报告（2026-10-29）

结论：MariaDB官方来源与私有真实测试链已闭合；Flutter私有复制、锁定离线解析与定向analyze完成，widget/unit批次在用例开始前被进程守卫终止。本候选为**PARTIAL，等待Astra独立验收**，不代表整版接受或产品main集成。

## 1. 固定身份与来源

唯一合同Blob `48d3670ac26b1959c1b59ffb4871109cef09a4c8`，开工及交付前fresh main `b35047ad13865ccc18d6b479b9c21bba5b0f6fc3`，Root `358f7eccd4be73c0819ccee098d5bf99a5ee499c`，ACTIVE_STATE `12dbffb1de1de010a1255cdbee57f01b907a5049`，协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`。读取955报告 `56eb994c71df95077e1c74b74371f7d75d070184`、索引 `e290ba53e472c87c0538de0c550d43b64fdcf648`、Astra裁决 `7975c844f496aa4151e10c3f2d13da6b004c18aa`。

唯一Parent `955307d8c1cd95897e5af0f19a347c6fa4e77ff1`；完整固定归档重建Root `10ea9f401291983ac7abc45e7497411471bb4c32`（5315个文件），导入产品apps `61c0dd9a70fcd56af00053f1d055884cecf052f0`、services `cc61686579f4a89ac092f3f557ba1f8191471528`。没有整树合并到main。main已接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。authority与源对象为 **DIRECT_GITHUB_OBJECT**；本机执行结果为 **CODEX_REPORTED_LOCAL_TEST**，原始敏感证据为 **LOCAL_ONLY_RAW**。

## 2. 官方MariaDB与独立实例

按官方Windows ZIP文档与官方受控DLM目录选择Community Server **10.11.19 / winx64 ZIP**；没有MySQL替代。公开入口：

- ZIP：https://dlm.mariadb.com/4800088/MariaDB/mariadb-10.11.19/winx64-packages/mariadb-10.11.19-winx64.zip
- SHA256清单：https://dlm.mariadb.com/4800090/MariaDB/mariadb-10.11.19/winx64-packages/sha256sums.txt
- ZIP签名：`https://dlm.mariadb.com/4800092/MariaDB/mariadb-10.11.19/winx64-packages/mariadb-10.11.19-winx64.zip.asc`
- 清单签名：`https://dlm.mariadb.com/4800081/MariaDB/mariadb-10.11.19/winx64-packages/sha256sums.txt.asc`
- 公钥：`https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY`；独立官方指纹文档：`https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/installing-mariadb/binary-packages/gpg`

实际ZIP **93,557,290 bytes**，SHA256 **`398ea30e5036010bbebe01d2b1804280424dcc2626e36d8e95155c04d25a0490`**。ZIP与checksum detached signatures均验证到官方文档指纹 **`177F4010FE56CA3336300305F1656F24C74CD1D8`**。实际TLS跳转为官方DLM至`storage.googleapis.com/downloads-cdn.mariadb.com`；带签名的完整临时URL只留本地。先检查ZIP条目路径/链接/覆盖，再私有解包；没有全局安装、注册服务或改PATH。

唯一空datadir初始化一次。真实SQL确认`10.11.19-MariaDB`、127.0.0.1:43329、私有datadir、server_id与监听PID吻合；新库`elitesync_v1015_verify_20261029`初始0表。仅使用本任务新建用户。守卫真实发现vendor bootstrap对PUBLIC的`test`、`test\_%`默认授权，先保存原失败，再只在本任务新实例撤销这两项。任务用户仅此合成schema的DDL/DML（RefreshDatabase所需），没有全局/其它schema授权及GRANT OPTION。没有放宽守卫以接受PUBLIC。

Laravel vendor为现存来源的私有副本，所有包版本核对composer.lock，无composer下载。PHP 8.5.3私有exe/DLL/ext、无共享ini；open_basedir/TEMP/缓存/日志/存储均任务内，外部操作函数禁用，mail/push/provider为本地或关闭。PHP API固定127.0.0.1:43339，直接私有php -S，无自动重启。每个请求经资格文件一致性、实例活身份及grants核对。资格哈希是可信任务runner的一致性约束，**不是**对同时控制文件和进程环境攻击者的独立签名授权。

## 3. Flutter私有面及明确阻点

既存Flutter3.41.7 / revision `cc0734ac716fbb8b90f3f9db8020958b1553afa7`完整镜像一套：18,000文件、3,277,475,095 bytes，逐文件校验。第一次复制工具超时保留；同一预留操作、同一目录按原manifest续完，没有第二镜像或退款。Dart运行身份3.11.5。app169锁依赖＋自身=170条resolver，tools101锁依赖＋自身=102条，实际266份所需已校验离线包副本。所有runtime package paths私有；锁文件未改。`dart pub get --offline --enforce-lockfile --no-precompile`实际成功，补全package_graph，控制台“Downloading packages”是工具固定措辞，本次解析强制offline，无依赖网络获取。

运行私有dart＋私有flutter_tools.snapshot，HOME/TEMP/PUB_CACHE/SDK/cache/lock/config均任务内；定向analyze覆盖network/storage/auth/chat/notification/session，首次2项lint infos，修复后**exit0 / No issues found**。

11个具名widget/unit文件未执行用例：先因缺package_graph终止；离线解析补齐后，原生资产planner需Windows程序目录环境，已私有路由；其`hooks_runner-1.0.1/lib/src/utils/run_process.dart:62`对Windows设置runInShell，启动`System32 cmd.exe`。私有COMSPEC/WINDIR路由未改变此实际系统shell路径，守卫保留并立即终止3个观测批次。实际Dart、snapshot、packages和测试engine均私有，但这些中断hook批次的**完整写入闭包NOT_PROVEN**；未放宽守卫、未改vendor/SDK源或取消测试断言求PASS。

具体下一人工决策：在当前冻结工具链下需要官方支持的无系统shell hook运行方式，或另行批准仅任务私有的hooks_runner适配及独立校验；本轮不自动做该后继变更。不能再把问题描述为“缺SDK/共享cache不能用”。objective_c9.5.0 hook只支持iOS/macOS，Windows路径应空返回，但仍须先安全启动hook，不能据此伪造widget PASS。

## 4. 真实验证矩阵

| 分项 | 实际执行与结果 | 结论边界 |
|---|---|---|
| F1/F2/F3 Laravel | 23 Feature，152断言；修复环境入口后exit0 | 真实MariaDB；不等于真实APP/设备E2E |
| Feature＋初版guard | 47项、176断言，exit0；2项依赖弃用提示保留 | 23 Feature＋24纯guard，不能全部称DB用例 |
| 最终guard反例 | 27纯测试、43断言，exit0 | 假Application/假连接，无PDO/DB；补缺失hash、路径、live identity、grants反例 |
| PHP语法 | 6个本轮PHP文件exit0 | 源码语法 |
| F1并发 | 两独立PHP/Laravel进程、不同CONNECTION_ID、pair锁＋go屏障、显式commit；同key同payload各200，同一id，message及notification各＋1 | 真实两连接并发；瞬时processlist见索引，未断言锁等待，lock-wait观测NOT_PROVEN |
| F1重放/冲突 | 回环HTTP同key200、不同payload409；3组提交后丢弃应用响应再同键读回，各仅1条消息/通知 | 丢弃本地已收到响应是合成“响应不可用”，不是物理网络断链证明 |
| F1撤权/附件 | Block、MC revoke、CN close后重放/读取404；附件ready→failed仍可正确重放，关联及通知唯一 | 当前服务端事实优先；不伪造发送成功 |
| F2 | 真实DB成功登录T0、失败/注册无锚、refresh不续期、family撤销、精确15日合成边界/前后秒/未来锚/旧token拒绝 | 合成时钟；物理15/30天NOT_PROVEN |
| F3 | HTTP通知偏好、TEST_ONLY最小payload/去重、类别关闭、权限拒绝、旧owner404、旧token401、登出；Feature另含设备重绑/跨owner撤销约束/到期/会话绑定 | 无真实Push送达、OS权限或设备证明 |
| Flutter | 运行身份与analyze PASS；11文件0测试事件 | widget/unit **NOT_RUN_ENV_GATE_CLOSED**；客户端异步、密文与30日清理真实测试未闭合 |
| 真实设备/RTC/Gradle/G2 | 0启动 | NOT_RUN，既有门禁不变 |

raw HTTP status/headers/body、DB前后计数、SQL/事务/错误域、Junit、进程回执均LOCAL_ONLY；合成DB逻辑快照160,378 bytes，SHA256 `a1331129c0269bc18eccdc0ab4ffa7c9f3992cbc8fdfedc2432c60efcbaf67df`，物理datadir及日志保留。API与MariaDB现均安全停止。

## 5. 实际修复、失败与审查

本轮9份源码/测试/配置改动详见索引SOURCE_PROVENANCE，逐文件列Parent源Blob与候选Blob。两个Dart修复只加mounted显式检查和花括号。LiveConsent测试入口只允许原SQLite或经过本任务完整资格核验的MariaDB；TestCase在迁移前先核配置、hash、真实实例与grants，普通测试默认SQLite :memory:保护未删。新增私有任务XML、守卫反例和真实并发/合成情景脚本，不改变业务Block、MC、Connection、account或Safety裁决。apps Tree `29c3274654a03db7dbe2a53eb02a07686281266b`（729 blobs）；services Tree `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 blobs）。

原失败没有删改：GPG Windows路径首次失败；SDK复制超时；lock解析/asset-only包校验误判；Flutter两项lint；package_graph缺失、PROGRAMFILES缺失、系统shell守卫中止；Laravel绝对Windows cache路径被二次拼接、SQLite-only入口、PUBLIC授权阻断；PHP8.5 vendor弃用提示污染HTTP JSON。修正task-only cache路径、将诊断保留到私有日志后HTTP JSON通过，没有降低open_basedir或隐藏业务失败。第一份污染响应正文在JSON解析前未保存，是明确证据缺口；server200 trace和异常保留，随后污染raw及修复后HTTP原件均保留。一项并行辅助启动在账本文件锁阶段失败、未Popen；不退款，不并行重开根。

独立Sol/high只读源码审查未发现业务鉴权削弱或负例删除；指出的严格端口、单次proof读取、空grants/跨库拒绝及资格反例已修补并定向测试。该辅助审查不替代Astra验收。

## 6. 预算、保护与交付

task_id `V1015_PORTABLE_TOOLCHAIN_RECOVERY_20261029`，attempt `attempt-0001`，唯一任务根及完整execution_ledger为LOCAL_ONLY。副作用Popen/下载/复制等先PREPARE并flush；同根续接不重置。ZIP1/1、SDK1套/1、source1/1、DB初始化1/1；MariaDB **2/2**（保守将供应方初始化mysqld bootstrap子进程计第1次，正常监听实例第2次），PHP API **1/2**；现不再启动。remaining预算不等于后继授权。

空间上限logical与allocated各8,589,934,592 bytes。索引列可溯检查点最大值与预留；**未连续监控每一瞬时峰值**。最终精确空间与ledger Hash由同根completion-receipt/budget-terminal回执保存，未把未测连续峰值声称为已证。

原SDK18,000文件和具名共享Pub266包/23549文件的原字节首尾一致，源FileId/Volume核对；955旧ledger只读Hash封存。保护dirty根没有write/reset/clean/ref修改；旧18、A/B树、Seed3183、122原证、五保护根、527refs、旧失败/claims/预算沿用保护，**未重跑其ACL/完整身份矩阵，不将no-touch声称为新一轮全量审计**。上述旧证状态不改PASS。

只提交本轮9份源码/测试/配置和本报告/脱敏索引；vendor、SDK、缓存、生成package/plugin配置、token、数据库、私人绝对路径与原始日志不上传。Commit、sole Parent、Root、11个变更Blob/mode、完整产品双Tree在发布后执行GitHub最终回读；最终身份及原字节回读结果另存同任务final-readback与完成回执，并在交付消息提供。不自签接受，不改main。

保持：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED`。

**V10.1.5_TOOLCHAIN_RECOVERY_AND_SCOPED_TEST_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW；STOP，等待Astra。** 不自动创建后继、合main、放行G2、修复旧18或进入v10.1.6。
