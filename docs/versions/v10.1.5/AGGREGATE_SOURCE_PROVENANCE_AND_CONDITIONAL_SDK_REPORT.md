# v10.1.5 Aggregate来源追踪与条件式SDK交付

2026-10-24，Asia/Shanghai。**SOURCE_PROVENANCE_INSUFFICIENT / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN**。

本轮完成具名源码的静态字段来源追踪，但不足以证明PSParameterizedProperty创建/发现点到aggregate的闭合赋值链。已在D0-A停止；**没有构造新复现对象、实施投影、运行任何fixture、Sandbox、Flutter CLI、Producer或正式解析**。30配置全部NOT_RUN。源码可见的primitive/容器形状不能代替原现场运行时对象，未知来源不靠猜测补齐。

## 固定权限和产品身份

完整读取正式任务Blob `9bf4c9d1ee603a58ab8f9f029050aff4d4d89e81`、Astra复审 `daa51c855078bed5f97b7a9c1839d926fbb38e43`、ACTIVE_STATE `b6234b369122d503a0ad1dc3e46bf888e257ecfb`、上一报告/Manifest与具名失败源码/证据；错误旧复审引用75f63bb7...未采用。沿用项目版本执行工作流，保护与单次门禁以本正式任务为准。

实时main `d3fe0afddef6d58ea35a5b95489bcbaa7766b71c`，Root `5acf1b884b5ecd8b4daf9e94203f3529dc060d43`。唯一接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整map1116/776条与固定原证一致。

唯一研发起点 `0ef15686104e0260c3abb34071b8c731f577094a`，Root `89e21c47f10451b63883ea68ea9e11fc62578dee`、其sole Parent `d0c1a00218ca68b92c6acf3338e292f956b023cf`。待验apps `785822ca072943c5bfefa3ccc37ede01c2af5164`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`完整map1133/791条逐path/mode/type/Blob匹配。固定source `1522466faf798b719ccff281de7584f043946437`与app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`保持；没有用main覆盖候选。

## D0-A：静态来源追踪

只读完整原fixture100行、writer122行、具名plan/schema及前次图元数据。原`fixture-body.json`和`fixture-body.tmp`仍不存在，controller失败aggregate不含原case body，继续标记 **ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED**。没有执行原代码、serializer、getter、ToString、对象图遍历或新的PowerShell对象采样；本地处理只做文本、已存JSON及Hash核对。

原body不是独立helper生成，而在`fixture.ps1:95`直接建立ordered字典；第96行直接调用`(New-ReceiptParser).Serialize($body)`。第97–99行落盘/读回/Move在Serialize之后。writer第32–34行只明确建立JavaScriptSerializer、设置长度/深度并return；aggregate没有先经过Copy-ReceiptValue或Write-Receipt。该调用结构可证，**不能据此确定具体目标runtime property从哪个字段生成**。

以下行号均对应固定LOCAL_ONLY原件`fixture.ps1` SHA256 `146d2e159dcac6bc773fffe4571d6ec5ec5729ad365e3e4118a2f4e4cea86c61`；表内类型是源码/API声明可推断的值类别，**不是原失败现场GetType快照**。完整赋值链、先前合成观察与投影限制逐行记录在Manifest。

| Body字段 | 第95行源表达式 | 生产者 | 源码行 | 源码预期值类型 |
|---|---|---|---|---|
| `$.runId` | `$RunId` | typed script parameter | 1,95 | System.String |
| `$.passed` | `$passed` | literal false, then true only after case-set check | 40,91,92,93,94,95 | System.Boolean |
| `$.expectedCount` | `$expected.count` | trusted fixture-plan JSON parsed by ConvertFrom-Json | 9,95 | JSON integer property |
| `$.actualCount` | `$cases.Count` | List[object] count | 9,29,38,55,78,84,90,95 | System.Int32 |
| `$.cases` | `$cases.ToArray()` | List[object] of explicit ordered result summaries | 9,29,38,55,78,84,90,95 | System.Object[] of OrderedDictionary summaries |
| `$.started` | `$started` | Get-Date -Format o result | 2,95 | formatted string output |
| `$.finished` | `(Get-Date -Format o)` | Get-Date at body construction | 95 | formatted string output |
| `$.childElapsedSeconds` | `$suiteClock.Elapsed.TotalSeconds` | Stopwatch property chain | 2,95 | System.Double |
| `$.currentCase` | `$script:currentCase` | Fresh([string]$name) | 10,12,26,32,52,73,79,85,95 | System.String or null if no case began |
| `$.failureType` | `$failureType` | null init or Exception.GetType().FullName | 40,94,95 | null or System.String |
| `$.failureCode` | `$failureCode` | null init or Exception.Message | 40,94,95 | null or System.String |
| `$.runtimeProcessesStarted` | `0` | integer literal | 95 | System.Int32 |
| `$.jobsStarted` | `0` | integer literal | 95 | System.Int32 |

37案例结果按固定source分支累加到`List[object]`，其联合摘要字段如下，不代表本轮或前轮37项终态已获验证：

| 摘要字段 | 生产者 | fixture源码行 | 源码预期值类型 |
|---|---|---|---|
| `$.cases[*].case` | typed Positive/Negative parameter or inline literal | 25,29,31,38,55,78,84,90 | String |
| `$.cases[*].kind` | literal | 29,38,55,78,84,90 | String |
| `$.cases[*].passed` | literal after assertions | 29,38,55,78,84,90 | Boolean |
| `$.cases[*].receipt` | typed parameter, selected file name, or literal | 25,29,31,34,38,55,76,78,82,84,88,90 | String |
| `$.cases[*].sha256` | SHA256 of receipt bytes, helper returns hex text | 27,29,36,38,55,78,84,90 | String |
| `$.cases[*].bytes` | byte array length | 27,29,36,38,55,78,84,90 | Int32/Int64 |
| `$.cases[*].readyDenied` | literal after negative assertions | 38,78,84,90 | Boolean |
| `$.cases[*].independentFailureValid` | literal after failure receipt schema/hash checks | 38,78,84,90 | Boolean |
| `$.cases[*].originalHash` | Receipt-Hash of first valid receipt | 85,87,90 | String |

具体赋值边界：Positive在25–30行、Negative在31–39行，及55/78/84/90行内联分支，均将显式ordered摘要Add到cases，再由95行ToArray进入body。第59–62行的runtime对象/scriptblock/深层与自引用是**负例输入**，在局部$value/$v/$x路径交给writer；摘要没有直接插入这些原输入、parsed对象或完整ErrorRecord。这里只能证明**可见literal没有直接赋该引用**，不能排除未保存的运行时包装或间接引用泄漏。

前次最小合成图在started/finished观察到PSObject包裹String；原日期生产者为Get-Date -Format o，源码链可追溯至2/95行。但前次对象只是合成输入，metadata创建/发现路径及原37案例body均未保存；不能因此判定日期字段就是PSParameterizedProperty或循环的根因。

## 来源门为何仍不足

在这两个固定具名源码中，没有PSParameterizedProperty显式创建或赋值表达式。New-ReceiptParser只是外部.NET serializer factory，已给源码没有提供该serializer的property-discovery与PowerShell适配内部路径。要证明目标链，尚缺少：**目标property创建/发现点→具体父对象→进入哪个body字段→序列化失败路径**的源级闭链或获准的同源实际观测。

没有该类型字面量并不证明原运行时绝不包含该类型；发现PSObject包装也不证明它产生了该目标。原stderr的类型名称、缺失的活对象图和前次0观察循环，都不能补上这一缺口。没有扩大到未知getter、通用遍历、DLL反编译或任意body序列化来猜测。**SOURCE_PROVENANCE_INSUFFICIENT**因此成立，停止而不进入复现/投影。

同一非作者只读复核了100/100行fixture和122/122行writer及13个body/9个case联合字段，支持该停止；其结论不是缺陷已定位或不存在间接泄漏。

## 条件式阶段：全部未放行

| 阶段 | 本轮真实结果 |
|---|---|
| 15秒同源最小复现、primitive投影 | 0轮、未实施 |
| 15秒定点aggregate正负例 | 0/1，NOT_RUN |
| 60秒完整37案例suite | 0/1，无本轮case终态或suite PASS |
| 新Sandbox／断网、Git HEAD、工具、SDK/cache | 0/1、NOT_RUN |
| Flutter CLI、SDK READY、新600秒窗口 | 0次、未READY、未使用 |
| packJniLibs与compile依赖 | 0/1 |
| 本轮真实libs.jar及来源/Hash/ZIP/CRC/JNI/双ABI | 未生成、NOT_RUN |
| resolvePinnedDebugInputs／Configuration.resolve() | 0/1、0调用 |
| 15模块×2配置 | BEGIN0／OK0／FAIL0／NOT_RUN30 |
| APK、设备/ADB、RTC/SFU、DB/API、main集成 | NOT_RUN |

固定Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、framework HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`、Gradle8.14/JDK17.0.18.8/AGP8.11.1/KGP2.2.20均保留继承身份，本轮未执行版本/信任验证或改工具。base50 `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`与runtime53 `6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`分别继承，不混称；ANDROID_PREFS_ROOT缺失和ANDROID_USER_HOME归属按批准原证保持，不冒称新SDK环境PASS。

严格resolver init `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`及artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`原字节不变；未重做Decimal、Git trust、GPU、DAG、HOST、旧fixture或600秒任务。

## 历史证据与保护

前次受限合成图8节点/0循环/0目标边/3截断，不证明原图无循环。原完整suite的37目录/38 JSON（20failure）和controller expected37/actual0/checks[]仍保持：0是无body可验证的数量，不是实际0例或37/37 PASS。历史SDK15:13:39.026 +08截止、600.111897秒与15:18:08.1167661 +08晚约269秒PSInvalidCast独立保留；Decimal保存回放、aggregate异常、受限合成图和本次静态追踪不推断同因。旧guest仍UNKNOWN，ICE flags与AC05仍OPEN。

保护终检PASS：**22,094份去重具名原件、514条开工引用及五历史根保持**；覆盖继承21,999原件及本轮读取的前次证据、原dirty/SQL/APK/备份/私密日志/SDK/未授权part/历史失败。五根HEAD/branch/index/status/warning、原writer/诊断pins和三init未漂移，38份旧JSON原位保留。该范围不是全盘或活DB审计。

24组相关环境与21组Git环境在D4两快照间相同；快照均在静态来源判定之后，不冒称D0开始前快照。宿主网络解析结构相同，recorded stateHash相同=true，raw文件Hash相同=false；原回执均保留。相关Java/Dart进程0。没有系统网络/全局Git/ACL/owner变更、下载、未知guest/进程处置或历史清理。

## 集中交付

同一GPT-6.1 Sol/high完成一次有界非作者源码/保护/最终文档只读复核，没有运行原脚本、fixture或SDK，不代替Astra终验。公开仅变量源表达式、非敏感字段/类型、行号、计数与Hash；原始绝对路径、PID/runID、完整脚本/日志、环境、SDK/JAR/APK仍LOCAL_ONLY。

Git从唯一Parent `0ef15686104e0260c3abb34071b8c731f577094a` 建安全后继分支`codex/v10.1.5-aggregate-source-provenance-conditional-sdk`，只新增本报告和`aggregate_source_provenance_and_conditional_sdk_manifest.json`。author/committer为`zcx369658780 <zcxvegeta@126.com>`。普通nonforce发布后完整回读Commit/Parent/Root、两Blob、原UTF8字节和完整产品双Tree；提交后精确身份与实际回读保存在LOCAL_ONLY delivery-git-identity/final-readback及Owner交付，避免正文自指或预先宣称发布PASS。

GitHub固定对象为GITHUB_DIRECT；本轮静态来源/保护为CODEX_REPORTED_LOCAL_ONLY；前次受限图为HISTORICAL_SYNTHETIC_GRAPH；非作者复核单列；晚到guest错误单列LATE_GUEST_EVIDENCE；所有条件式运行明确NOT_RUN。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

普通发布与完整回读后立即停止，等待Astra独立验收；不在源级证据不足时运行复现、投影或后继任务。
