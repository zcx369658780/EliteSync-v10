# v10.1.5 Aggregate primitive投影与条件式SDK交付

2026-10-24，Asia/Shanghai。**AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN**。

唯一对象图诊断在约0.641秒内完成并确认子进程退出，但没有证明目标循环路径。按D0-A门禁立即停止，**未实施primitive投影，未运行定点正负例、完整37案例suite、Sandbox、Flutter CLI、Producer或正式30配置解析**。本报告记录有界未证结果，不签修复、writer PASS或产品接受。

## 固定权限与产品起点

完整读取正式任务Blob `8292d6ae1281852bb6dedd46d602456d40e45ab1`、Astra复审 `0bea4cea935de96c8471997142df3ce31eb0d999`、ACTIVE_STATE `f2fc2ea7f7ae0f0d62004579f8ed67e1f0ac73e1`、上一报告/Manifest及具名固定writer/schema/fixture/监督器、stderr和失败aggregate。错误旧引用75f63bb7...未采用；Decimal保存回放发现保持继承，不重新捕获或修正。

实时main `531ec9c22f471fecd030380120551e4bd3bc8f73`，Root `94df5664928cb6b82dee9bc830dd3adfd9a32d2e`。main仍为v10.1.4唯一接受产品：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整map1116/776条与固定原证匹配。

唯一连续起点 `d0c1a00218ca68b92c6acf3338e292f956b023cf`，Root `7fa7fc58b6b6ef3e6939f6111f6f23607b195f59`，其sole Parent `f3fbc2c58615095a9065afd11cc2369f7241343f`。待验apps `785822ca072943c5bfefa3ccc37ede01c2af5164`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`完整map1133/791条逐path/mode/type/Blob匹配。固定source `1522466faf798b719ccff281de7584f043946437`与app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`保持；没有用main覆盖候选。

## D0-A：原对象缺失、同源最小合成诊断

原`fixture-body.json`与`fixture-body.tmp`均不存在，controller失败aggregate不含逐例body或原活对象图。因此明确标记 **ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED**。检查只限具名现场来源，不声称全盘没有任何副本；历史38份JSON和stderr保持原字节。

只读核原第95行ordered body构造和第96行Serialize调用。任务副本以相同ordered body／List[object].ToArray容器构造一个最小合成case，保留完整body字段、expected37/actual1/passedfalse用于诊断，**不是原37案例对象或原异常重现**。没有人为注入自引用或任意运行时对象来制造循环。

诊断不调用JSON serializer、Write-Receipt、Copy-ReceiptValue或对象ToString。只读类型、受控容器元素与受限实例FieldInfo，不读取未知property getter；PSParameterizedProperty、ScriptProperty、ErrorRecord、Job等仅记录类型、不得下降。采用ReferenceEquals/RuntimeHelpers引用身份、active祖先集与finished集区分循环和共享引用；最大深度14、非primitive节点384、数组128、字典64，内部7秒守卫、监督器整体15秒含启动/读回/进程退出/结果落盘。

非作者前置审查只支持这一次受限诊断，并要求任意内部循环或共享祖先不能自动等同于目标链路。结果字段将运行机制完成与目标证明分开，没有自动放行逻辑。

**1/1次，约0.641秒，未超15秒，PowerShell子进程exit31且已退出**。exit31表示允许遍历范围未观察到raw循环；监督器exit0只表示界内完成机制，不是目标PASS。实际安全元数据：

| 观察 | 本轮结果 |
|---|---|
| 非primitive访问节点 | 8 |
| 观察到的循环闭环 | 0 |
| PSParameterizedProperty目标EDGE | 0 |
| 未知类型截断 | 3 |
| wrapper路径 | `$.started`、`$.finished`，类型PSObject |
| wrapper的已读取底层字段类型 | 两者`#immediateBaseObject`为System.String |
| 共享引用 | 两个时间字段共享_typeTable id5，记SHARED，不是CYCLE |
| 截断位置 | started的_typeTable、started/finished的lockObject |

三处未知类型均没有继续调用getter或展开未知property。**0个已观察循环只说明这一受限最小合成子图，不能证明完整运行时图无循环**；String wrapper观察也不能被写成原Serialize故障的已证原因。未定位PSParameterizedProperty进入链路和循环闭环，`diagnosticTargetPathProven=false`。

同一非作者逐边复核支持 **AGGREGATE_CYCLE_PATH_NOT_PROVEN**。原对象缺失、图遍历截断与原失败因果UNKNOWN分别保留；没有放宽访问规则、追加诊断或重跑。

## D0-B/C及D1–D3：未放行

| 阶段 | 本轮真实结果 |
|---|---|
| Primitive-only投影实现 | 未实施，循环路径门未过 |
| 15秒aggregate专用正负例 | 0/1，NOT_RUN |
| 60秒完整37案例suite | 0/1，无本轮case终态或suite PASS |
| 新Sandbox、断网/精确Git/冻结HEAD实测 | 0/1，NOT_RUN |
| Flutter CLI、SDK READY、新600秒窗口 | 0次、未READY、未使用 |
| 真实packJniLibs及compile依赖 | 0/1 |
| 本轮真实libs.jar、来源/Hash/ZIP/CRC/JNI/双ABI | 未生成、NOT_RUN |
| 正式resolvePinnedDebugInputs、Configuration.resolve() | 0/1、0调用 |
| 15模块×2配置 | BEGIN0／OK0／FAIL0／NOT_RUN30 |
| 宿主APK、设备/ADB、RTC/SFU、DB/API、main集成 | NOT_RUN |

没有复制或准备新SDK stage。冻结Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、framework HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`、Gradle8.14、JDK17.0.18.8、AGP8.11.1、KGP2.2.20保持继承身份，本轮没有执行新工具版本/Git trust/cache验证。

继承base50环境Hash `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`与增加三个精确Git进程键后的runtime53 `6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`不混同。ANDROID_PREFS_ROOT缺失及ANDROID_USER_HOME归属保持批准的输入原证；不声称本轮实际SDK子进程环境PASS。严格resolver init `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`与artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`原字节不变；未重做Decimal、DAG、HOST、GPU、历史fixture或SDK600秒诊断。

## 历史证据和剩余门禁

上一轮完整suite的`expected37/actual0/checks[]`仍表示没有逐例body可读回验证，不是实际0例或37/37 PASS；37目录／38 JSON／20 failure不能替代案例终态。原第96行PSParameterizedProperty循环引用stderr、失败aggregate、所有JSON与源码保持不变。

历史SDK截止**15:13:39.026 +08、600.111897秒**，迟到异常另记**15:18:08.1167661 +08、晚约269秒**，PSInvalidCast发生于framework-identity的Write-Receipt/ConvertTo-Json。与Decimal保存回放观察、本次合成图是独立证据，不能倒填截止PASS或主张同因。旧guest仍 **OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS**，未查询/操作未知HCS/VM或结束进程；普通Debug与ICE诊断/AC05真实RTC门保持区分。

## D4：保护、非作者复核和普通发布

保护终检PASS：开工实际 **21,999份去重具名原件、513条引用及五历史根**保持；范围含继承21,820原件、上轮失败脚本/日志/38 JSON及选定只读SDK/cache资产，不是全盘或活DB审计。五根HEAD/branch/index/dirty/warning未漂移；旧SQL/APK、数据库备份、私密日志、未授权part和所有失败保留。原writer/Decimal分支及三init源、诊断源码pins均未变。

24组相关环境与21组Git环境快照相同，但**两次快照均在本轮唯一诊断之后的D4期间**，不得冒称覆盖D0起点或诊断全程。诊断源码静态复核未见全局环境写入。宿主网络解析结构相同；recorded stateHash相同=true，raw文件Hash相同=false，不混称原始字节相同。相关Java/Dart进程0，没有系统/网络/全局Git/ACL/owner变更、下载、强制结束或历史清理。

同一位GPT-6.1 Sol/high完成本任务一次有界非作者复核（前置源码、实际逐边图、保护与最终文档），只用只读文件/Hash工具，未执行诊断、serializer、fixture或SDK。支持如实停止交付，不代替Astra终验。

Git从 `d0c1a00218ca68b92c6acf3338e292f956b023cf` 建安全后继分支`codex/v10.1.5-aggregate-primitive-projection-conditional-producer`，只新增本报告和`aggregate_primitive_projection_and_conditional_sdk_producer_manifest.json`，不改产品、旧文档、ACTIVE_STATE或AGENTS。author/committer为`zcx369658780 <zcxvegeta@126.com>`；普通nonforce发布后完整回读Commit/sole Parent/Root、两Blob、原UTF8字节和完整产品双Tree。提交后精确身份及实际远端回读保存在LOCAL_ONLY delivery-git-identity/final-readback回执及Owner交付，避免文档自指或预先声称发布PASS。

GitHub固定对象属GITHUB_DIRECT；本机同源最小合成诊断及保护属CODEX_REPORTED_LOCAL_ONLY；非作者只读复核单列；历史迟到异常属LATE_GUEST_EVIDENCE；投影和后续所有未运行门明确NOT_RUN。完整图、runID/PID、源码/日志、路径、环境和SDK/JAR/APK仅LOCAL_ONLY，公开只含非敏感字段/类型/计数和Hash。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

发布与完整回读后立即停止，等待Astra独立验收；不扩展getter访问、不重试诊断、不实施投影或自动启动下一任务。
