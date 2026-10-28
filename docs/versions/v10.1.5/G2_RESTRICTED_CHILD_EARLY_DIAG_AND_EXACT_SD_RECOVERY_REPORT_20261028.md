# EliteSync v10.1.5｜启动期只读取证与精确描述符恢复综合交付

日期：2026-10-28（Asia/Shanghai）。

**EARLY_STARTUP_DIAGNOSTIC_BOUNDED_NO_RELAUNCH / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE。**

两个新对象各完成一次明确变更与一次恢复，均实际取得 **0x8404→0x8004→0x8404**；flags7所返回描述符的binary、SDDL、control、ACE、owner/group、身份及内容严格匹配。这个有界方法证据不能补造旧历史原件中从未捕获的二进制描述符/SACL，也没有证明对旧非空目录的继承传播与完整回滚/引用资格。**旧18项恢复尝试0，旧失败状态保留**；不能将新样本结果当作旧18项已恢复。

限定Application Error事件查询没有同实例事件可用，具体初始化原因仍 **CHILD_INIT_ROOT_CAUSE_NOT_PROVEN**。本轮新受限/对照child启动0、工程0、G2 claim写入0，14项child访问矩阵继续NOT_RUN。始终 **RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN=FALSE / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。

## 1. Fresh authority与固定来源

唯一正式任务 [V10_1_5_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_FIXTURE_SD_RECOVERY_TASK_20261028.md](https://github.com/zcx369658780/EliteSync-v10/blob/5dc7e1752e62454acd0d9e4bfdec58c25e602e19/docs/versions/v10.1.5/V10_1_5_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_FIXTURE_SD_RECOVERY_TASK_20261028.md)，Blob **19a25f1446e08ff875d1533f78b8cf2726c2d795**。已读取全文、原字节和main Root具名路径；Owner本地手动派发覆盖本任务，ACTIVE_STATE历史“待派发”不是本地未获授权。

| 对象 | 本轮直接读取身份 |
|---|---|
| 开工live main / Root | `5dc7e1752e62454acd0d9e4bfdec58c25e602e19` / `611f05ab3312b5a639b8144f51ee3fc2ce24abf4` |
| main接受产品v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 来源8186 / 唯一Parent | `8186cebc94661bcdc229ee5b62b31871dc784a4c` / `76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7` |
| 8186 Root / apps / services | `1d9ec83dbfe6c211d95f713d5aa4ab93f69d8bf7` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 8186报告 / 索引Blob | `e773c0139dc4c0d6c91abad7553508382975d4e0` / `0cfc46b50f092b5c1c10df7ea4e065af3141144a` |
| Astra 8186审查Blob | `a6a01ad4d56633cf2ab0aeed66658067c2fc42ed` |
| 6ca源级接受Blob | `6d5ee056409de7373e635cd5e75b6aed52396bbd` |
| 旧G2合同 / 冻结plan Blob | `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c` / `7d3466b3be67135dc641cfee7c7faef78937ba03` |

main/8186完整递归Root为6234/6666项、未截断；候选完整1777份产品文件身份保持。Astra仅有界接受 `8186_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_REQUIRED_OBSERVATIONS`，没有接受OS门或18项恢复。原报告/索引已base64原字节核对，旧描述符原件/受限身份原件与8186索引Hash绑定。

本轮仅一个新任务根，不建完整checkout或本地refs。唯一普通候选以8186为sole Parent，新增本报告、索引及一个纯诊断设计mock源；没有产品源码或main变更。最终Commit/Parent/Root、全部新Blob/原字节、完整apps/services与fresh main产品树回读留LOCAL_ONLY final-readback，避免文档自引用。

## 2. 既有启动原件：已证与缺失

既有原件仍记录：CreateRestrictedToken及CreateProcessAsUser成功；暂停时读取child token并核对，随后Resume；controller exit90、child signed -1073741502 / unsigned **0xC0000142**，该child退出已确认、当时句柄关闭。实际启动参数、固定解释器/源Hash、`-I -S -B`、inheritHandles=False、STARTUPINFO默认、任务私有profile/AppData/temp以及创建前后源码已核对。没有运行这些源，也没有创建任何新token/child。

原捕获缺口不能回填：没有原生进程creation FILETIME、单调创建/Resume时间回执、启动期child stdout/stderr、首事件或loader轨迹。函数控制流能说明计划步骤，不能代替当时缺失的逐步原生返回帧。标准句柄没有继承，不能把controller stderr空文件当成child无错误。14项访问检查依旧没有回执；旧前置任务Error5也不属于8186 child。

0xC0000142仅支持初始化失败错误类别，不证明具体DLL、desktop、profile、quota或工具链兼容问题。当前没有同实例调用栈/模块初始化证据，不改系统策略、不运行普通token对照、不安装调试器、不启用新ETW provider。

## 3. 有界被动事件读取

只读取现有Application channel，服务端过滤 **Application Error / EventID1000 / 已知child PID / 固定AppPath / UTC时窗**；不读取无关应用/用户事件正文，不扫描进程或D盘。时窗来自Hash/FileId已核验的原启动receipt与结果文件的**当前文件mtime**前后各2秒，共 **4.027047秒**，不是补录的API时间或同步误差界。

本轮1次查询、最多8条/每条128KiB，结果 **0条**；query句柄已关闭，无权限拒绝、无重试/放宽条件。结论 **NO_CORRELATED_EVENT_AVAILABLE（仅此过滤范围）**。没有据此宣称整个系统没有其它事件；未扩大读取没有可确认PID/AppPath的WER/Popup正文。

即使同PID+路径+窄时窗出现事件，没有历史creation时间/唯一attempt关联，也只能按候选分级，不能自动证明同一次进程实例。此次不存在可提升为实例绑定的事件，因此 **CHILD_INIT_ROOT_CAUSE_NOT_PROVEN**。

## 4. 未来早期取证设计及纯mock

只交付设计，不实现/运行新launcher：

1. 启动前先持久化并flush唯一attempt、源/命令/环境政策Hash、诊断输出目的地、UTC与monotonic时标及其局限；失败即不得启动。
2. 原生创建调用返回即记录成功/失败域，失败才读GetLastError；从返回句柄采集真实creation FILETIME、PID、token限定和Resume结果，防止PID复用误归属。
3. 将可继承句柄限制为任务私有stdio白名单；不能退回全量继承。父端持续有界排空并flush，区分空、缺失、未捕获与截断。没有在本轮创建pipe或调用STARTUPINFOEX执行路径。
4. 明示边界：loader在Python/C运行时进入前失败时未必能发stderr；捕获stdio也不保证知道失败DLL。仅关联已经存在的被动事件，不启用provider/网络/调试器。
5. 若将来真正进入child，最早最小frame先flush，再导入大模块；仅在确认自有进程退出后恢复fixture权限，identity/flush/cleanup不闭合仍FAIL_CLOSED。

新纯mock **10项exit0、0失败/错误/skip**，禁止ctypes/socket/subprocess等审计事件0；验证native失败与child退出分层、stale LastError拒绝、缺首帧不变访问PASS、stderr不能单独证明原因、PID复用拒绝、creation缺失仅候选、实例绑定也不等于根因。使用合成值；不是14项OS访问测试或新受限进程。纯mock源随候选供只读审查。

## 5. 旧18项只读登记与来源边界

全部18项被限制在8186的具名micro-fixture根；FileId/Volume、link=1、无reparse、内容、owner/group、顺序ACE及当前已捕获状态与上轮原证匹配；祖先身份已只读记录。没有实际父目录delete/rename探针，没有遍历其它任务找PID或断言全局不存在引用。

原始SDDL JSON及原捕获源码Hash已由8186不可变索引绑定，**O/G/D SDDL本身可信且可比较**，不是声称原件伪造。但原源码明确 flags7=OWNER|GROUP|DACL；原始self-relative二进制、SACL及其完整可见性从未捕获。无S段不能写成“不存在SACL”，本轮也没有请求SACL或测试其可读权限。现在补读不能追溯证明当时未捕获的值相同；从SDDL重建的二进制不能冒称原历史原字节。

当前的flags7二进制视图是本轮只读新登记，不回填到旧捕获。0x0400是descriptor control，不是ACE INHERITED/OI/CI flag；ACE相同不能替代control/SDDL严格验证。原始/当前control仍 **0x8404 / 0x8004**。

## 6. 新fixture：同一方法各一轮，严格捕获视图恢复

真实操作前冻结同一方法，最多2个新对象（文件和空目录），旧写入口不存在。每件先记录flags7返回的binary原字节/SDDL/control/revision、DACL存在性/revision/顺序ACE、owner/group、Hash、FileId/Volume/link/属性和祖先，再用SetFileSecurity DACL-only一次复现，最后以持有的目标句柄调用 **SetSecurityInfo(DACL_SECURITY_INFORMATION | UNPROTECTED_DACL_SECURITY_INFORMATION, originalDacl, owner/group/sacl=None)** 一次恢复。mask **0x20000004**；不写owner/group/SACL。句柄禁止delete sharing，前后FileId再核验，finally关闭。

现有固定pywin32 b311源1412–1433支持SetSecurityInfo参数直接透传，1492–1513为named形式，2120–2134为旧SetFileSecurity透传；源码本身不证明OS会恢复AI。**以下是本轮实际新对象证据**，不是由源码推断：

| 新对象类别 | 实际control路径 | 变更 / 恢复调用 | 严格捕获视图匹配 |
|---|---|---:|---|
| N01 / file | 0x8404→0x8004→0x8404 | 1 / 1 | 是，flags7捕获视图 |
| N02 / directory | 0x8404→0x8004→0x8404 | 1 / 1 | 是，flags7捕获视图 |

两个对象的binary原字节、SDDL原文、control/revision、DACL revision/顺序ACE、owner/group、FileId、内容与其余捕获字段均相同；没有改比较标准，API成功未把stale LastError记为0。两件各1轮、句柄关闭，无权限拒绝、无失败后改另一设置再试。

准确结果为 **NEW_FIXTURE_FLAGS7_CAPTURED_VIEW_EXACT_RECOVERY_SUPPORTED（2/2）**。SACL状态仍“未请求/未捕获”；不升级为完整审计SACL、历史binary或整套OS写入隔离已经证明。空目录成功也没有测试旧非空目录的继承传播。

## 7. 为什么旧18项未写入，以及逐项结果

旧18项恢复是有条件授权。本轮新方法证明了可取得视图，但仍缺历史完整descriptor/binary/SACL证据、非空目录继承传播/回滚的有界证据，以及完整独立引用排除。SetSecurityInfo的继承效果不能仅凭两个无子对象样本假定无其它影响，也不能为了尝试成功对旧树连续施加设置。**完整条件没有同时成立，未触发旧对象写入许可**。这不是说可信O/G/D SDDL不能被比较，而是不以较窄视图冒充合同中的完整历史精确恢复。

原始及本轮前后快照都保留，未删除/移动/重建旧fixture，也未对旧对象作“再恢复一次”。每项结果如下：

| 旧对象匿名标签 | 原control | 本轮前后control | 本轮恢复尝试 | 结果 |
|---|---|---|---:|---|
| F001 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F002 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F003 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F004 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F005 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F006 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F007 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F008 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F009 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F010 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F011 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F012 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F013 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F014 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F015 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F016 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F017 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |
| F018 | 0x8404 | 0x8004 | 0 | NOT_RUN，前置门未闭 |

**OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE**。旧严格恢复0/18未关闭；新样本成功不能替代旧恢复结果。18项现有二进制视图/SDDL/FileId/内容在本轮前后保持。

## 8. 原始失败、空间与保护

两次只读登记辅助失败如实保留：第一版使用当前pywin32不存在的便利getter，改为已验证的buffer `bytes(sd)`；续接摘要缺少本地变量，已从保存的登记重建摘要。没有ACL调用发生在这些修正前，没有新child。原stdout/stderr/exit1不覆盖，另一个即时只读方法查询失败只记工具回执，不伪造成raw文件。后续完成登记不把原失败抹成成功。

关键持久化命令/退出码/stdout/stderr Hash见索引；只读补核exit0不是重跑8186子程序通过。新ACL两轮、事件读取与mock分别分级，不拼成权限矩阵PASS。

| 任务空间阶段 | logical bytes | FILE_STANDARD_INFO allocated bytes |
|---|---:|---:|
| intake后首测 | 8,231,524 | 8,273,920 |
| 两新fixture结束 | 11,392,210 | 11,510,272 |
| 报告前delivery | 11,432,498 | 11,573,072 |

硬上限 **67,108,864 bytes**，未触发；所有新实物在唯一新任务根，无checkout、第二份Seed或SDK副本。发布后最终快照另存LOCAL_ONLY receipt。逐文件/目录allocation不包括后续receipt或全卷MFT/journal，卷free包含外部并发，不冒称精确全卷瞬时峰值。

既有101件具名保护保持，另加21件8186原件只读保护，合122件；没有改旧清单或刷新旧Hash。五保护根HEAD/branch/index/status、527refs、worktree注册表、源286干净状态、旧Seed3183件Hash/FileId首尾保持。旧18项当前视图及所有原始失败另有只读登记。不是26784/108/100453全量复算，D盘219目录副线没有新盘点/清理。

旧partial **7,941,328 bytes** / `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`；旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316` 保持。旧APK/G各1/1耗尽，旧A门禁关闭，G2 max1/reserved0/Popen0/claim absent，本轮没有使用或改写claim/ledger。新fixture操作回执只是任务实验记录，不是G2预算入口。

新受限/普通对照child、Gradle/JVM/Flutter/Dart/AGP/Kotlin、G2、AAR/APK、设备/RTC、工程observer/Job/socket、Gate2/Writer/Serializer、生产/数据库、新网络实验均0；未下载升级、提权、改共享SDK/cache/Seed或全局ACL/策略。实际发生的是允许的旧原证只读、被动Event Log查询及两个新对象的有限ACL操作。没有把文件metadata/API调用称为“所有native API为0”。

## 9. 证据等级、最小下一门与STOP

GitHub对象原字节为 **DIRECT_GITHUB_READBACK**；前置裁决 **ASTRA_DIRECT_GITHUB_STATIC**；本地旧原件/当前登记和Hash为 **CODEX_REPORTED_LOCAL_EXECUTION / LOCAL_ONLY_RAW**；新fixture实际调用及读回为 **OS_FIXTURE_DIRECT**；版本API来源与未来设计/mock为 **SOURCE_STATIC / MOCK_ONLY**；原child初始化原因、未捕获SACL/历史binary、旧树传播及完整运行资格为 **NOT_PROVEN**。Astra未现场执行本轮实验，非作者辅助只做静态技术审查。

最小Owner后续选择应先明确能以可信已捕获O/G/DACL+control恢复哪些字段、哪些历史完整字节永远没有来源，并单独闭合非空目录传播与限次回滚资格；不能通过改“精确恢复”定义来获得PASS。启动诊断如继续，也须另授权带真正creation identity和早期可观测性的微型尝试；本轮没有创建这种后继任务或发起新launch。

无论样本结果，保持 **RESTRICTED_IDENTITY_GATE_BLOCKED / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / G2_READY_FOR_POPEN=FALSE / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。SDK动态写入、Dokka选择、AAR/POM/实际APP、AEC/native handle、真实elapsed/物理清理和Push未决不关闭。

**一次普通候选发布并回读后STOP，等待Astra独立验收。不得自动新child、G2、实际构建、D盘清理、预算扩容、产品main集成或v10.1.6。**
