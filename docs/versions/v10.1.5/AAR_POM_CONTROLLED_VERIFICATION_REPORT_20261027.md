# EliteSync v10.1.5｜受控 AAR / POM 发布图验证报告（2026-10-27）

**INVENTORY_CLOSURE=VERIFIED / GRAPH_NOT_PROVEN / A=NOT_RUN / AAR_POM_RUNTIME_NOT_PROVEN / APP_APK_BUILD=NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN。**

本报告为同版本集中验证的 Codex 交付，不是 Astra 接受或产品 main 集成。G 的实际结果、停止原因及未执行部分如下。旧 APK 预算保持 1/1 耗尽；新 G/A 是本任务独立授权，交付后不自动使用任何剩余预算。

## 1. fresh 权威、产品与源码身份

Owner 手动派发的正式任务：[固定任务分支](https://github.com/zcx369658780/EliteSync-v10/blob/abab2f6cdd44475f0c411c0b7ba56332b8ce5a3d/docs/versions/v10.1.5/V10_1_5_CONTROLLED_AAR_POM_PUBLISH_GRAPH_VERIFICATION_TASK_20261027.md)，Blob `129efb748bb5a22921e756f2f829a627ceae6880`。该分支 ACTIVE_STATE Blob `4961d3ca9a36397e94605cab277f6035f7ddc47d`；Astra方案一复核 Blob `1a39ba1ab5df7c69a0f6143b4734ba56b31cf134`，结论限于 `SOURCE_LEVEL_JAVADOC_REPAIR_ACCEPTED_WITH_OBSERVATIONS`。

| 对象 | fresh 核验身份 |
|---|---|
| live main | `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` |
| main Root | `03b0ecfcc360e38a462539dd50690c64b663a21e` |
| 方案一候选 / 本文档候选唯一 Parent | `da5ce628a499c97e916e780e2cf795353745c147` |
| 方案一候选 Parent / 实际源码 | `50d79396195ed8b4b86c218584ab59864ad600be` |
| 方案一候选 Root | `e140a196942c7b1aebf8bf90871e34afaec49501` |
| 源码 Parent / Root | `3d0c656d59e8621ffa6a935313b5cd4c860a16b1` / `d3c8e2cfbe28e3a1a4e13ac217b868f5cbb7ae20` |
| 候选/源码 apps Tree（1053文件） | `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` |
| 候选/源码 services Tree（715文件） | `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 已接受产品 v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 旧报告 / Manifest Blob，保持原件 | `2f2b025d274cb79bafb89bb9b0374b4575786b06` / `c56644a04b88f2f02bd7369724e4d6c7aff65637` |
| 冻结 plan Blob | `7d3466b3be67135dc641cfee7c7faef78937ba03` |

六份任务/状态/计划/审查/报告/Manifest经base64原字节读取，重算Git Blob及SHA256；完整源码/候选双产品Tree 1768个path/mode/type/Blob一致，并与本地连续树核对。本候选仅新增独立报告和证据索引，不修改旧报告、Manifest、冻结计划或产品源码。最终Commit/Root/两新增Blob及原字节以交付后的远端回读为准。

## 2. 新可信输入库存及边界

最终唯一执行库存 SHA256：`2fa1227a56a90a2225f35ff61306a327e23fde1a0cb5a4c3c961c48f5b4ff9fd`。它由本任务新隔离根实际枚举产生，共 **100453** 个文件；各根数量：`{"gradle": 314, "cache": 52551, "flutter": 6270, "pub": 14931, "java": 492, "android": 22178, "project": 3717}`。另绑定6项辅助输入和5个既有宿主工具身份。新库存含 `ownedAarInitContract`，六项 `REQUIRED_PROJECT_INPUTS` 在 inventory/definitions 均有当前精确Hash；Gradle 8.14 receipt来自已pin的本地distribution JAR。旧94573项库存仅作历史来源对照，未作为新闭合证明。

独立审计脚本重新枚举文件集并重算100453文件及来源Hash，校验全部祖先reparse边界、272个package引用、74个各平台插件引用及15个Android生产源码映射；结果无错误。Android插件的历史元数据原指向另一旧根，已仅在任务副本中重定位到新库存；LiveKit映射到当前方案一的受控项目源码。历史对照中测试目录和旧CMake状态差异不能直接叫生产源码漂移。包根都在库存scope内；部分仅原生/资产包无lib目录，未因此虚构缺失Dart源。

初始复制的旧native生成输出全部保留；另建不含旧 `.cxx` 的pub输入副本，未修改历史根或共享缓存。一次对任务复制品的递归删除请求被自动审批策略拒绝且未执行，随后采用新增快照方式。所有生成元数据、初始副本和失败记录留在LOCAL_ONLY。SDK Windows启动脚本中的既有自动更新/PowerShell参数仅做静态核验，其文本与本地SDK Git原对象在换行归一后相等；本报告不将静态存在写成该分支已执行或已安全验证。

库存有明确scope，不是操作系统所有文件或未来动态依赖的绝对证明。G/A执行前再次校验；不下载补缺、不修改共享SDK或全局配置。前一版辅助执行器seal在静态加固后被新版显式替代，所有前置副本保留，且此前无G/A claim。曾有seal助手局部变量覆盖导致输出文件名错误、审计退出1；普通局部修正后完成最终核验，没有启动Gradle或重置预算。该失败仅有工具回执说明，未伪造未落盘的原始stdout/stderr Hash。

## 3. 本轮隔离与静态检查

方案一37项及关联44项按本轮源码重新执行，均exit0；不是Gradle图或设备验证。

| 本轮检查 | exit | stdout SHA256 | stderr SHA256 |
|---|---:|---|---|
| owned | 0 | `317a0056618902f5d4de18524791a5667a3ab84181892c18102447db279184e7` | `ed6dd0692f663c4427daa3224c2a0dec292d9a7953a7c1d616c850a0cbd442a1` |
| associated | 0 | `12617e54d1f1c35c2b6ef450767d0e13b8216160953b0fd60010bf90d4d2845a` | `2b6b88464abfe704b555f08a1513c4dbb7a65c9955dba4f6c6b0d897e283033d` |

执行器最终17项完全mock/纯函数检查exit0，失败0；process/socket/native-DLL真实审计事件0。命令为本地Python `-B test_controlled_runner.py`，最终源码Hash `ce765a33fbae04fa0febee69ce8005dbbaec65d7a47d33f430d5c795e8861985`；stdout `0d6b910c5a50d63d1a7e10334005a2709d6dee23bc867f7927835a7aeec0b93d`，stderr `4278ced79cbf28d87cf4f45217d39237625bc1c87f6fe5fda0b8e2df65481239`。覆盖预算先claim、重入拒绝、失败不退预算、G/A隔离、图不完整/文档任务拒绝、同输入凭据绑定、Job清理及零观察拒绝。此前14项/17项中间通过记录保留，后续复验源于执行器改动，没有将它们计为多次Gradle。

Python AST静态检查exit0。非作者助手仅做有界源码静态复核，指出并复查了Job kill-on-close、终止后等空、零样本不能通过及G凭据绑定；**未执行本地测试、Windows DLL、Gradle、网络或设备操作**，不替代Astra独立验收。

## 4. 唯一 G 实际尝试与 A 门禁

G claim原子持久化在Popen之前；新预算 G 最大1、实际保留 `1`，Popen创建 `True`，剩余 `0`。真实Gradle退出 `90`，入口退出见LOCAL_ONLY回执。stopReason：`OBSERVER_OR_LAUNCH_FAILURE:OSError:PROCESS_INSTANCE_PATH_UNREADABLE`。有效运行观察样本 `36`，最终Job活跃进程 `0`。完整命令身份 SHA256 `9227a175845025bf0a74d33875af39df6d23d2467dbeb18b2d083fb3ef10a02d`，输入库存/执行器/claim均绑定在G回执中。未重试或更换入口。

对应普通R1内层合同的脱敏完整参数：

```json
[
  "<GRADLE_ROOT>\\bin\\gradle.bat",
  "-I=<PROJECT_ROOT>\\apps\\android\\scripts\\owned_flutter_aar_init\\aar_runtime.init.gradle",
  "-I=<PROJECT_ROOT>\\apps\\android\\scripts\\offline_debug.init.gradle",
  "-Pflutter-root=<FLUTTER_ROOT>",
  "-Poutput-dir=<PROJECT_ROOT>\\apps\\flutter_elitesync_module\\build\\host\\v1015-r1",
  "-Pis-plugin=false",
  "-PbuildNumber=1.0-v1015r1-8bbbaaafacb8",
  "-Ptarget=lib/main.dart",
  "-Pdart-defines=RUxJVEVTWU5DX1YxMDE1X0xPQ0FMX0JVSUxEPXRydWU=,RUxJVEVTWU5DX1YxMDE1X1IxX0xPQ0FMX0JVSUxEPXRydWU=",
  "-Ptarget-platform=android-x64,android-arm64",
  "assembleAarRelease",
  "--offline",
  "--console=plain",
  "-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime",
  "--no-daemon",
  "--max-workers=2",
  "--gradle-user-home",
  "<CACHE_ROOT>",
  "-Dorg.gradle.java.installations.auto-download=false",
  "-Porg.gradle.java.installations.auto-download=false",
  "-Porg.gradle.java.installations.auto-detect=false",
  "--dry-run"
]
```

cwd为本任务Flutter模块 `.android`；直接本地Gradle8.14，不调用Wrapper。buildNumber为 `1.0-v1015r1-8bbbaaafacb8`，由当前Kotlin相同源码输入/define顺序Hash算法推导；G与潜在A的命令仅差末尾 `--dry-run`。没有运行外层`:app:assembleDebug`。

G stdout SHA256 `b41e49a15c2161f19bc3d4f5a052b92a2efb8a3623b30359de26c733caa1bb32`；stderr `6ea041318b8559c48541b6aeafa807a88d28de5f92b4fbd1c77c50ff56df94a2`；原始process/network记录 `98dd03952e8be998f484fb7cf7295489b575e8f8626ae9732c98cd45d7b76e52`，全部LOCAL_ONLY。已解析选中任务 `0` 项；`DOKKA_TASK_SELECTED=NOT_PROVEN`。文档任务清单及必要发布任务覆盖见脱敏索引；注册任务、dry-run选中任务和真实任务动作严格区分。

stderr同时记录：模块 `settings.gradle` 第22行解析 `dev.flutter.flutter-plugin-loader` 时，初始化脚本报 `OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required`，并打印 `BUILD FAILED in 4s`。根命令确实携带了scope参数；拒绝发生的具体Gradle上下文及参数传播边未通过额外运行证明，不将其写成已完成根因修复。另一个独立强停止事实是观察器无法取得某个进程实例的image path。该异常在写最终样本前抛出，失败实例身份没有落盘，不能据前一帧推定它就是退出进程或PID复用。根退出90是Job终止后的实际回执；不能把失败文本冒充未受干预的退出1。未追加stacktrace、查询任务或修复/重试。

保留1个挂起根基线及36个运行采样。已有原证派生摘要包含110条UDP endpoint记录与46条TCP记录；它们不是唯一连接或发包次数。已保存样本未分类出非loopback TCP强停，仍不能据此证明绝对离线。观察器故障本身已足够关闭A门。

**G结论 `GRAPH_NOT_PROVEN`，A门禁 `False`。A=NOT_RUN，未claim，最大1/已用0；剩余授权不能自动滚入后继。** 没有本轮AAR/POM/Module Metadata/sources产物或runtime依赖验证PASS。未从原成功R1缓存复制品冒称本轮新产物；APP APK构建、安装、回取Hash均NOT_RUN。

监控保留下载日志、非loopback TCP、观察器/根实例故障、输入漂移、未知外部工具和越界强停。UDP仅目的不可见endpoint观察，不证明发包/未发包或绝对离线。保留根句柄创建时间及Job范围；现有观察器累计PID集合、进程/socket非原子采样和可能漏掉短事件的限制仍在，不宣称归属100%或无网络。`DOKKA_TCP_CAUSALITY=NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN`，不以本次关联倒改旧TCP事实。

## 5. 保护、资源和终态

首尾具名26784历史文件全部一致、5历史根元数据一致；新增108份近期LOCAL_ONLY原证一致；本轮开工525个local refs全部不变。与更早524 refs对照，只有此前已授权连续分支由旧基线前进至既有单次构建候选，以及新增方案一分支，本轮未改变它们，不能写成524条全等。

旧partial维持7,941,328字节、SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`；旧claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8` 不变。SQL、APK、原始失败和旧证据均保留。新库存声明的原输入来源 `100447` 文件首尾Hash一致；仅本任务副本的构建缓存/生成输出允许变化，不宣称整盘零写。

任务Job终态以上述原始回执为准；未运行全局`gradle --stop`、全局杀进程、设备/ADB、RTC、服务或DB探测。未申请管理员、改执行策略/防火墙/代理/VPN或发生新费用。隔离目录、预算claim和所有日志保留，不自动清理。

本轮证据等级：GitHub对象/Blob/原字节为 `DIRECT_GITHUB_READBACK`；实际本地检查和G尝试为 `CODEX_REPORTED_LOCAL_EXECUTION`；路径、IP/PID/socket及原始stdout/stderr/库存为 `LOCAL_ONLY_RAW`；非作者复核仅静态源码。三者不互相替代。

继续 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / AAR_POM_RUNTIME_NOT_PROVEN`。Push、AEC、最后可闻波形/native handle、实际15/30天和物理30天清理、ICE/旧guest等既有未关闭项不变；Gate2/Writer/Serializer及历史37案例/条件Sandbox SDK/Producer/libs.jar/30配置解析不运行。仅发布普通文档候选，回读后停止等待Astra；不合并产品main、不启动v10.1.6或后继任务。
