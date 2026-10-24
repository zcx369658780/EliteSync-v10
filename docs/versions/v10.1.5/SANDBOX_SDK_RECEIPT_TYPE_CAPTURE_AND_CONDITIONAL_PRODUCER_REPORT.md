# v10.1.5 Receipt类型捕获与条件式Producer交付

2026-10-24，Asia/Shanghai。**WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN**。

本轮定点类型捕获成功；唯一完整Writer suite退出1，缺少有效子进程案例aggregate，未获完整PASS。已按门禁停止，**新Sandbox、Flutter CLI、真实Producer和正式30配置解析均0次**。保留失败源码与全部证据，不修复或重跑。普通发布仅交付本报告与Manifest，不代表writer、SDK或v10.1.5产品接受。

## 固定权限与Git起点

完整读取更正任务Blob `a0918a566bd88e47a630010757f27d9fdc970996`、正确Astra复审 `5a7d78eb4daf94ad553c51bfe9aee424f343bb8d`、ACTIVE_STATE `7b23444177765128324c2534130726f687dce8a1`、上轮报告/Manifest与具名writer/schema/fixture/原始失败。旧任务错误引用75f63bb7...未采用；Owner已手动派发更正任务，此前权限等待没有消耗类型捕获或运行预算。项目workflow与原保护边界保持。

实时main `3614bb386b6f1e2237e8d884c7d469ce29f0e0c1`，Root `02f250a7fb4587314ee71bd1daa773826ed68af9`；main仍为v10.1.4唯一接受产品，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整map1116/776条匹配原证。

唯一起点 `f3fbc2c58615095a9065afd11cc2369f7241343f`，Root `07f5e2fd381f16862bdf43eef306b23096290042`、其sole Parent `a219fbb45edd0c746dce92af2f6abf661091bab4`。候选apps `785822ca072943c5bfefa3ccc37ede01c2af5164`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`完整map1133/791条逐path/mode/type/Blob匹配；固定产品source `1522466faf798b719ccff281de7584f043946437`及app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`不变。未用main覆盖未接受候选。

## D0-A：唯一15秒定点捕获

只在本任务LOCAL_ONLY副本给拒绝位置加入字段路径传递和独立UTF8纯文本诊断，保留原拒绝规则；没有执行旧writer原件或完整旧fixture。只读加载上轮首失败回放所用的保存dart-version.result JSON，不执行Dart命令。诊断不调用Copy/ConvertTo-Json，不递归dump ErrorRecord或记录实际敏感值。

**1/1次，0.5秒，子进程已退出，未超15秒**。预期拒绝exit23，独立诊断与catch的实际异常类型吻合：

| 字段 | 本轮直接观察 |
|---|---|
| 字段路径 | `$.seconds` |
| 输入GetType().FullName | `System.Decimal` |
| 类别 | scalar |
| 预期schema | 有限JSON数值；原native source为Stopwatch.Elapsed.TotalSeconds（Double） |
| 阶段 | Copy-ReceiptValue，在Write-Receipt入口之前 |
| 拒绝异常类型 | System.Management.Automation.RuntimeException |

这是**本轮相同保存JSON重建路径的实际观察**，没有冒充上轮现场对象快照，更不能倒称2026-10-24 15:18的PSInvalidCast同因已证。历史对象类型/完整延迟机制仍UNKNOWN。

据此最小值修正为保留Decimal数值分支，不把任意对象转String。另按任务要求补显式typed schema（包括native-result.exit为integer与完整SDK actualFlutter四字段）、严格UTF8、独立primitive失败编码、正常/失败回执的schema/Hash读回后原子发布，以及无Job的整套截止。所有修改均在本任务副本，旧失败Hash不变。非作者在首次suite前只读审查最终pins后支持**仅首次37案例suite**，未签D0 PASS或Sandbox放行。

## D0-B：唯一60秒完整suite失败

计划17正例＋20负例，共37项；含全部顶层schema正例、真实identity字段类别、Decimal保存回放、SDK四字段、Unicode/Windows路径、null/数组/字典、深层/循环、缺字段/错误类型、数组/字符串/字节上限、非法Unicode/JSON、独立fallback与禁止覆盖。未使用旧Start-Job/Wait-Job/Stop-Job链，未执行Git/Flutter/Gradle/native产品命令。

本轮suite **1/1次，exit1**。监督器从启动计时，包含进程退出、读回和控制器aggregate落盘，共约**1.187秒**，未超60秒；类型捕获和suite子进程均确认退出，未发关闭/终止请求。

**首个可见终止错误**在`fixture.ps1:96`的`(New-ReceiptParser).Serialize($body)`：stderr指出序列化`System.Management.Automation.PSParameterizedProperty`时检测到循环引用，FullyQualifiedErrorId为`InvalidOperationException`。原stderr字节保留，并另存本机编码解读副本；没有保存完整异常对象/最深调用链，具体引入循环的字段或对象机制UNKNOWN，不作猜测。

`fixture-body.json`未写成。控制器已写有效**失败aggregate**，passed=false、expectedCount=37、actualCount=0、checks=[]、processExitConfirmed=true。这里0是因缺失body而未完成逐案例结果读回验证的数量，**不是实际执行0案例**，也不是案例失败数量。控制器的失败aggregate不能冒称完整suite成功。

现场留有37个案例目录、38份同一合成run的JSON，其中20份failure JSON。交付只读盘点可解析这些JSON，核其run绑定及失败metadata Hash；它们只支持对应文件已生成，**不构成37/37 PASS**。完整SDK模板、Decimal回放与fallback均为合成材料，不是guest运行或SDK READY。因为此前try/catch里的failureCode也可能被未落盘body吞没，现证**不能排除更早的案例断言失败**，不能写“仅聚合一处错误，其他全部通过”。

首阻断后未修改writer/schema/suite/监督器、未重跑，非作者支持保持`WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN`。后续门全部关闭。

## D1–D3：没有放行

| 项目 | 本轮真实结果 |
|---|---|
| 新Sandbox/断网父子实测 | 0/1，NOT_RUN |
| 新guest精确Git信任、冻结HEAD | NOT_RUN |
| Flutter CLI、SDK READY | 0次、未READY |
| packJniLibs及compile依赖 | 0/1 |
| 本轮真实libs.jar、来源/Hash/ZIP/CRC/JNI/双ABI | 未生成、NOT_RUN |
| 正式resolvePinnedDebugInputs、Configuration.resolve() | 0/1、0调用 |
| 15模块×2配置 | BEGIN0／OK0／FAIL0／NOT_RUN30 |
| APK、设备/ADB、RTC/SFU、DB/API、main集成 | NOT_RUN |

只准备22条任务独立映射，历史源只读、宿主可写限本任务，没有启动或重新复制整套SDK。原50键有效值不变；仅预备进程级GIT_CONFIG_COUNT/KEY_0/VALUE_0三键，base50 canonical `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`与runtime53 `6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`分别核对。任何大小写ANDROID_PREFS_ROOT键缺失、ANDROID_USER_HOME归属不变；**仅静态准备审计，不是实际SDK子进程PASS**。

Flutter3.41.7/Dart3.11.5/engine59aa584...、Gradle8.14/JDK17.0.18.8/AGP8.11.1/KGP2.2.20保持固定。严格resolver init `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`与artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`原字节不变；旧DAG/HOST/GPU/历史fixture均未重跑。

## 历史证据与剩余产品门禁

历史SDK截止**15:13:39.026 +08、600.111897秒**时无SDK完成回执；迟到异常另记**15:18:08.1167661 +08，晚约269.09055秒**，PSInvalidCast发生于framework-identity的Write-Receipt/ConvertTo-Json。历史Git单仓trust与HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`实际成功保留。本轮没有使用新SDK600秒窗口；Decimal拒绝捕获与本轮aggregate循环引用不能倒填历史原因或截止PASS。

旧guest的HCS状态仍UNKNOWN，未操作未知VM/进程、未重查故障HCS；没有以未见窗口或普通Debug合成回执宣称安全退出、ICE诊断APK或RTC安全完成。`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`、`V10.1.5_PARTIAL_NOT_ACCEPTED`与`AC05_OPEN`保持。

## D4：保护、复核与普通发布

保护终检PASS：**21,820份去重具名原件Hash/字节全部保持**，包括继承21,704原件与本轮读取的上轮证据；512条开工引用及五历史根HEAD/branch/index/dirty/warning保持。数量不是全盘或活DB审计。SQL/APK/数据库备份/私密日志/未授权part/SDK和全部旧失败原位保留；三init源一致，运行源码与审阅pins未变。

24组相关环境和21组Git环境在完整suite前至失败后保持；类型捕获发生在这组快照之前，不能冒称全D0开始前快照。静态源未见全局环境写入。宿主网络**解析结构相同，回执内stateHash不同，raw文件Hash也不同**，三者不混淆；两个原始回执均保留。宿主相关Java/Dart进程0，无网络/全局Git/ACL/owner修改、下载或历史清理。

同一位GPT-6.1 Sol/high完成一次有界非作者复核，覆盖捕获、首次suite前置与失败原证、保护及最终文档；仅只读文件/Hash工具，未运行fixture或SDK，不代替Astra终验。公开只有脱敏类型、计数和证据Hash；原始脚本、WSB、PID/runID/绝对路径、完整日志、环境和JSON产物均LOCAL_ONLY。

Git从唯一Parent `f3fbc2c58615095a9065afd11cc2369f7241343f` 建分支`codex/v10.1.5-receipt-type-capture-conditional-producer`，只新增本报告和`sandbox_sdk_receipt_type_capture_and_conditional_producer_manifest.json`。author/committer `zcx369658780 <zcxvegeta@126.com>`。普通nonforce发布后完整回读Commit/sole Parent/Root、两Blob、原UTF8字节和完整产品双Tree；提交后精确身份及实际回读保存在LOCAL_ONLY delivery-git-identity/final-readback回执和Owner交付，避免正文自引用或预先声称远端通过。

GitHub固定对象属GITHUB_DIRECT；本机捕获/失败suite/保护属CODEX_REPORTED_LOCAL_ONLY；非作者审查单列；历史晚到guest异常单列LATE_GUEST_EVIDENCE；新SDK/Producer/解析与产品门禁明确NOT_RUN。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

普通发布与完整回读后立即停止，等待Astra独立验收；不自动修复、重跑suite、启动Sandbox或后继任务。
