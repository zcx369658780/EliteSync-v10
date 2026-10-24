# v10.1.5｜Sandbox会话收口与条件式SDK运行结果

日期：2026-10-24。**OWNED_SANDBOX_SESSION_NOT_CONFIRMED_CLOSED / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN**。

本轮D0只读接收摘要未见Sandbox相关进程，没有发出正常关闭请求；但唯一一次既有系统guest清单查询返回`0x8037011B`，未取得可用guest列表。**不能由未见UI/RemoteSession推断关联guest已关闭，因此会话安全收口未证，立即停止。** 新SDK实例、工具版本探针、Flutter producer、真实libs.jar及30配置解析全部NOT_RUN。未重试、提权、force、换平台或改系统。

## 固定来源与实时Git核验

- 正式任务`ASTRA_SANDBOX_SESSION_CLOSE_AND_CONDITIONAL_SDK_PRODUCER_TASK_20261024.md` Blob `e30a0e1e35d5f39c6e0f77bfa9fa8e2f8d7574df`，与fresh main中的任务原文一致；Astra最新独立复审Blob `c716c8cb5f42b6ef0da019c6cfc8042fc9c5a181`，当前ACTIVE_STATE Blob `d476af928ef7c7b0c34ac4af043110e75e7effb1`。任务、复审、完整状态文件及本轮具名必要前证已读取，固定字节已核。
- sole Parent为唯一连续候选`29eced7453d876ca3d229341241b518e80b82635`；其Root `925fa111a5b81f25780b59137a9889b9d4097a82`、sole Parent `c1a6cba30f7c18ad8d0f5252436a40ea760437d6`。
- 开工live main `b3ae592ff3484609cb69fe4eb65fa17cfb2328ff`，Root `3d21256f4dc763901a16d688c633502760aa95dc`。接受产品仍为v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；完整maps1116/776条与本地Git对象逐path/mode/type/SHA相等。没有用main覆盖候选。
- v10.1.5候选完整apps `785822ca072943c5bfefa3ccc37ede01c2af5164`、services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`，完整maps1133/791条精确匹配GitHub。固定source `1522466faf798b719ccff281de7584f043946437`、app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`不变。
- 前证报告Blob `7ffae2f037509b827b734f4d0d6e213358f2048d`、Manifest Blob `6ec1483a4f4fdeb813ee90969547cba0bf3160d9`保持原字节。旧一次CloseMainWindow返回true但10秒未确认退出、旧launcher exit0等均保持历史事实，不因本轮观察改写。

## D0：当前会话状态与首阻断

本轮先用只读进程枚举检查WindowsSandbox前台/RemoteSession及具名Sandbox vmmem进程；主代理接收摘要记录相关进程0、当前token未提升。没有拿旧PID当当前身份，没有发现可作精准同源正常关闭的现存窗口，因此本轮CloseMainWindow **0/1**，没有调用任何关闭或等待退出函数。

**证据限制单列**：接收脚本中空集合管道未产出独立`sandbox-processes-intake.json`文件；不补造空JSON，不以旧快照冒充新观察，也不在首阻断后重查补证。“当前进程0”按`session-intake.json`主代理摘要分层，非作者没有独立原始空进程清单可核。该缺项进一步限制关闭结论，不影响安全STOP。

为核关联guest，只调用一次本机原有、Microsoft Windows签名Valid的`hcsdiag list`；不启动Sandbox、不提权、不修改服务。退出码 **-2143878885（0x8037011B）**；stdout0字节，stderr2字节仅CRLF，**没有可用guest清单**。不能把空输出等同“无guest”，也不根据该码猜测权限、服务、平台故障等原因。关联guest实际状态继续UNKNOWN，而不是“仍在运行”或“已自然安全退出”。

按正式任务D0“没有可判定信息即STOP”和“无法核关联guest”条款，立即停止全部运行推进。没有另查其它平台、重试HCS、重发关闭、force kill、重启系统/服务、安装功能或更改防火墙/网络。上轮独立断网探针的PASS仅继承其原实例，不补足本轮生命周期门。

## D1至D3：新预算未进入运行

| 门禁 | 本轮状态 |
|---|---|
| 旧RemoteSession/前台进程 | 摘要未见；缺独立原始空列表 |
| 关联guest安全收口 | UNKNOWN / NOT_CONFIRMED |
| 本轮正常关闭 | 0/1，未发现当前同源窗口 |
| SDK映射Sandbox启动 | 0/1，NOT_RUN；SDK_NOT_READY |
| 新实例父子IPv4/IPv6拒绝测试 | NOT_RUN |
| Flutter/Dart/JDK/Gradle实际版本与cache READY | NOT_RUN |
| :flutter:packJniLibsflutterBuildDebug及compile依赖 | 0/1，NOT_RUN |
| 本轮libs.jar来源/Hash/CRC/结构/内容/ABI | 未生成，全部NOT_RUN |
| resolvePinnedDebugInputs / Configuration.resolve() | 0/1；没有实际调用 |
| 15模块×2配置 | BEGIN0 / OK0 / FAIL0 / NOT_RUN30 |
| 宿主APK、额外AAR、安装、ADB、RTC/SFU、DB/API | 全部NOT_RUN |

前轮17907件SDK必要输入与22条映射原样保留，本轮没有新复制、修SDK或启动其旧runner。Flutter3.41.7/Dart3.11.5/engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、Gradle8.14/JDK17.0.18.8/AGP8.11.1/Kotlin2.2.20仅为继承固定工具身份，不称隔离内版本运行已通过。

50键sealed环境canonical SHA256 `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`、ANDROID_PREFS_ROOT键移除及ANDROID_USER_HOME原批准归属保持继承；本轮无工具子进程，不能虚称实际SDK子进程env已验证。严格resolver init SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不变。未重跑独立无凭据探针、GPU来源、已接受DAG或历史fixture。

**ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**持续。既有DAG `targetPath=lib/main.dart`、`dartDefines=null`属于普通Debug类库来源；本轮无新产物，不冒称ICE诊断APK或RTC安全功能完成。

## D4：一次非作者审阅、保护与交付

一位GPT-6.1 Sol/high非作者仅在本任务一次有界复核中读取D0关键原证、前轮关闭事实和D4文档/保护回执；支持guest收口未证即停，指出独立空进程快照缺失并要求诚实分层。没有自行运行guest查询/Flutter/Gradle、扩展调查或代签Astra运行验收。

具名保护终检PASS：本轮1115份具名文件before/after逐内容Hash不变，含原990关键原件、直接前轮证据/控制与两份旧交付文档。508条开工refs及其中507条旧refs原SHA保留；五历史根HEAD/branch/index/status摘要不变，历史长路径warning保持。本轮只读系统诊断工具Hash不变；相关24组环境摘要在D4保护窗口不变，相关Java/Dart进程0；宿主网络快照前后相同，亦与前轮终检相同。

前轮20226份复制及只读来源的Hash保护**作为继承证据保留**；本轮未新复制或映射SDK，未执行SDK/构建/版本工具，但确实执行过一次hcsdiag，1115份具名保护Hash也可能读取SDK关键文件。未重新整体Hash这20226份来源。不能写成本轮又对全部SDK/缓存或全盘/活DB逐字节审计。全部历史dirty成果、SQL/APK、备份、私密日志、旧.zip.part及原始失败保护，不清理或覆盖。

Git仅从固定连续Parent新增本报告和`sandbox_session_close_and_sdk_runtime_manifest.json`；不改apps/services、锁文件、AGENTS、ACTIVE_STATE或旧报告。普通nonforce发布后须回读Commit/sole Parent/Root、两文档Blob/raw原字节与完整产品双Tree。最终提交身份与实际回读回执在LOCAL_ONLY及Owner交付消息记录，避免文档自指或提前声明发布成功。

公开仅裁决摘要和Hash。真实进程标识、WSB绝对路径、映射、完整stdout/stderr、私密env和SDK/JAR/APK都LOCAL_ONLY。GitHub固定对象/正文为GITHUB_DIRECT；Windows观察及Hash为CODEX_REPORTED_LOCAL_ONLY；缺失的独立进程快照明确列MISSING_RAW_EVIDENCE；旧probe/GPU/DAG/SDK保护为INHERITED_NOT_RERUN，不能混成Astra现场验证。

## 需要Owner本人处理的一项会话问题

请Owner在本机亲自核实：**上轮唯一无凭据Windows Sandbox探针会话及其关联guest是否均已安全结束**。目前没有可由Codex精准正常关闭的现存同源窗口，原会话标识与WSB来源保留于LOCAL_ONLY。若Owner仍看到该具名沙盒，请本人正常关闭并确认guest收口；不将此建议视为Codex获准force、提权、重启、改服务/网络或自动再查。后续由Owner/Astra据人工事实另行裁定，本轮不自动继续。

**NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。交付并回读后立即停止。
