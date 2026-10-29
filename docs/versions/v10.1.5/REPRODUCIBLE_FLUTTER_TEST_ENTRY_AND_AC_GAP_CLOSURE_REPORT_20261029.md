# v10.1.5 可复现Flutter测试入口与AC差距集中交付

结果：**DELIVERED_PARTIAL_WITH_EXPLICIT_REPRODUCTION_OR_EVIDENCE_GAPS / AWAITING_ASTRA**。交付真实非生产工具源码及38项纯合成检查；未启动Flutter/Dart、数据库或API。入口当前严格合同锁阻断，不能声明已具备标准Flutter运行资格。AC01–11均未整项闭合，AC05明确OPEN；没有整版接受或产品main集成。

## Authority与来源

正式任务Blob `0854b37fdc9f11c55088ed2d2f93816a27bc2fa9`；开工fresh main `bbac0d177fa1db5962bf2f08325731fa4bbfb72d`，Root `a53db9f1da1a6a5503079df416eaf92e2a5df6f9`，ACTIVE_STATE `6df2081a71af333334d41f6fabda849330fecb25`。接续时重新读main仍相同。已读协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`、Astra最新裁决 `715bc340042675df86a0c791c49eb1852bb9b5ce` 及前轮MariaDB/Widget报告与索引。摘要没有代替合同。

唯一候选Parent `5aa3fc631dd7b450888c794182a1a8b35d57ec0a`，Parent Root `2db8c8c509ffebb3b02169c23b99b34261f0424a`。仅新增tools/docs，**apps `798049a15eb33fec16acdd37d83a07af0ed181b5`（729 blobs）与services `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 blobs）完整保留**。开工已接受main产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。未接受候选不自动成为产品main。

## 实际工具与补丁资格

`tools/v1015/flutter_widget_test_entry/`包含entry/core/runtime源码、固定locks、安全空配置、38项合成测试、README和脱敏回执模板。默认inspect无输出文件/子进程；plan核hash/路径/完整app树和resolver闭包；prepare源逻辑要求新任务授权及预算、独占目标、严格复制与单文件差异、逐项flush+Hash回读；recover绑定同一根/任务、校验链和已准备字节，拒绝复制根和不确定启动重试；execute只实现未来接口并明确关闭本次任务授权。

固定Flutter3.41.7/framework cc0734ac716fbb8b90f3f9db8020958b1553afa7、Dart3.11.5、Hook1.0.1，程序Hash列locks/manifest。**合同原Hook Hash只有62位**：`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`。前轮Astra与具名本地原件完整64位为 `f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`。本轮没有静默修正合同，保留 `CONTRACT_SOURCE_HASH_MALFORMED / PATCH_REPRODUCTION_BLOCKED`。新published authority和独立复核前prepare/execute闭门。

历史diff原字节CRLF Hash `a8f471db65209c3125943834f96d7c74ab736d96b1b727b820e4db93e51ec9bd`（旧公开索引localRawArtifacts已记录），显式LF canonical Hash `9d7f7883e34bbe451d364b89b03d4acab6c30d00d1f4d9081f562708b6e7f119`。二者不同，不把原字节冒称同Hash。具名旧源+LF canonical差异在内存严格应用，目标 `7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc` 与已核目标原字节一致，级别仅 **IN_MEMORY_REFERENCE_BYTES_REPRODUCED_ONLY**。没有在新SDK应用真实补丁，没有上传完整LOCAL_ONLY差异或私人路径。外部操作者无原件时必须 `PRIVATE_PATCH_SOURCE_NOT_AVAILABLE`，不得编造等效补丁。

Windows adapter未真实运行；其Job/映像采样不是通用OS隔离，不能排除所有瞬时进程。`hook_arguments`是独立纯校验器，未拦截真实子进程argv；真实Hook白名单依赖已核私有补丁和未来qualification。`complete_offline_manifest`、本地grant/qualification JSON都是可信操作者一致性约束，不是密码学Owner身份或恶意配置隔离。未来execute的exit0仅 `PROCESS_EXIT_ZERO_TEST_RESULTS_UNVERIFIED`；需按真实JSON事件/具名用例另行验收，不可拿空输出exit0称Widget通过。

## 本轮检查与失败

Python3.11纯逻辑/AST检查：**38 executed / 38 passed / 0 failed / 0 skipped，exit0**。检查进程中Popen、system/startfile和socket被拒绝stub替换；合成exe均惯性字节，正向runtime使用注入fake。覆盖版本/Hash/多文件或错误上下文补丁、路径穿越/reparse/hardlink/UNC/device namespace、重复prepare、复制根恢复、ledger损坏/过期授权/预算、shell/argv注入、未授权execute、非零fake退出和uncertain不退款。不是实际Windows/Flutter通过。

首轮29项有1失败+1错误：多diff错误码分类及测试stub替换Popen为函数破坏mock导入。改正测试基础设施及明确错误码后32通过；只读Sol/high审查提出根绑定、无字节码默认、UNC与CLI读取绕过、锁文件异常回执，定点修复后36/38项通过。全部失败原日志保留LOCAL_ONLY，未删负向断言。非作者助手只读复核不替Astra；明确披露真实argv守卫和Windows执行仍未资格化。

## 证据分层与AC

详见 `AC01_11_GAP_MATRIX_20261029.md` 与 `ac01_11_gap_matrix_20261029.json`；每行保留冻结原文、模块、当前Blob、已接受子合同、风险、缺口与下一最小授权。F1消息、F2 RTC、F3离线、F4通知、F5旧资产，未沿用前轮场景缩写误换编号。所有行 this_task_retested=false。

| 层次 | 本轮/既有事实 | 限制 |
|---|---|---|
| DIRECT_GITHUB_OBJECT | Authority、固定源码/Blob与Astra报告直接读取；最终候选再回读 | Git对象不是本机运行独立见证 |
| CODEX_REPORTED_LOCAL_TEST（本轮） | 38项纯合成/静态，exit0 | 无Flutter/Dart/DB/HTTP |
| CODEX_REPORTED_LOCAL_TEST（前轮） | MariaDB23 Feature/152断言；两连接/HTTP；Astra有界接受 | 非APP E2E，锁等待NOT_PROVEN，响应丢弃非物理断网 |
| CODEX_REPORTED_LOCAL_TEST（前轮） | 私有补丁Runner11文件77/77 Widget；analyze exit0 | 非原版标准Runner、真实API、Keystore或设备 |
| 历史RTC真实设备 | call4/5与旧token403有界接受 | 不同源码/APK；call3失败、10.125秒非5秒PASS，AEC仍OPEN |
| LOCAL_ONLY_RAW | 原日志/ledger/私有patch与失败/路径 | 不上传；Astra未现场重跑 |
| NOT_RUN / NOT_PROVEN | 本轮所有真实工具/服务/设备；物理15/30天、实际清理、Push | 不以Mock/文档关闭 |

F5仅冻结具名语音留言/旧附件/地图地点来源对照，缺乏已接受来源的能力为UNKNOWN_OR_OUT_OF_SCOPE；没有扩搜或自动恢复。下一授权建议先修Authority Hash并独立资格化入口，再安排同源APP/API/DB消息/撤权/媒体/通知旅程；设备密文/实际清理、RTC/AEC及Push分别明确预算。这里只提供建议，没有创建后继任务。

## 预算与保护

同一task_id `V1015_REPRODUCIBLE_ENTRY_AC_CLOSURE_20261029` / attempt-0001，一棵新task-owned根与持久execution ledger；续接同根，关键写入/Python纯检查先PREPARE并flush。部分人工源码修订按一个已flush的有界批次登记，没有逐次保留每个中间编辑前像Hash；最终文件Hash完整、检查失败日志保留，不能把该记录缺口称为逐字节全编辑审计。文档生成逐文件写前登记并回读。新增logical/allocated各限268435456 bytes；纯检查后约1.5MiB，精确末值和ledger Hash保存同根terminal receipt，离散检查不是连续峰值证明。

本轮Flutter/analyze/test、Dart、DB启动/连接、PHP API、SDK/Pub镜像与下载均0；历史Flutter6/6、MariaDB2/2耗尽，API历史1/2的剩余1不构成授权。ACL/DACL/SACL、新真实fixture、restricted child、14项OS矩阵、G2/claim、Gradle/JVM/APK/ADB/RTC设备/真实Push均0。纯合成临时文件不是旧Windows ACL fixture；仅清理该合成测试自有文件。

dirty根、旧18、两ACL实验树、122原证、五根、527refs、Seed3183、历史失败/claims/预算均no-touch。本轮不重跑其完整OS身份/ACL矩阵，不把no-touch称为新全量保护PASS。具名旧任务账本/完成回执/patch关键原件只读Hash核对另存本地。事故 `PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`永久保留，绝不退款或倒改。

## 交付与停止

制品manifest列每个新增工具/矩阵/报告路径、模式、Git Blob、SHA256、字节数与来源。自引用manifest不伪造自身Hash，最终其Blob由远端回读回执确认。唯一普通non-force分支候选以固定Parent发布；最终Commit、Root、全部变更原字节和完整双产品树回读后记录独立terminal receipt。未修改既有生产源码、测试断言、pubspec.lock、SDK、共享cache或旧工作面。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。

**一次集中候选后STOP，等待Astra独立验收。** 不自动合main、放行G2、关闭AC05或派发后继。
