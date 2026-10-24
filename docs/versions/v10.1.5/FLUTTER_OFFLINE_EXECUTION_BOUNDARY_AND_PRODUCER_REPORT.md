# v10.1.5｜真实离线边界与条件式Flutter Producer交付

日期：2026-10-24。终态：**ISOLATED_SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK**。

现成Windows Sandbox的独立断网负例通过；本轮新增任务自有SDK必要输入已准备，但新SDK映射实例没有启动，不能称SDK READY。首个阻断是已完成D0实例的自有RemoteSession界面一次正常关闭后未在有界等待内确认退出。此后停止所有运行，不重试、不force、不换平台。没有真实libs.jar，也没有执行30配置解析。

## 固定权限与Git身份

- 正式任务Blob `f02853ee72d65ac36674f9fb8d6071a3d0bfbb0b`；最新Astra审查Blob `b34db972b2db6ea65bd196d0c93195acdde5b133`。已完整读取任务、最新审查、ACTIVE_STATE及具名前置任务/报告/Manifest/旧审查。旧FAIL保留，GPU来源和Gradle DAG本轮均未重跑。
- sole Parent `c1a6cba30f7c18ad8d0f5252436a40ea760437d6`，其Parent `df2bf34302fd65d0f69c0ea34a269eba03dc6a67`、Root `e30e58438b8e6b78fa33a62fa5d9cf9b96eef19c`。
- 候选完整apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。GitHub完整maps分别1133/791条，与本地逐path/mode/type/SHA一致，不只核顶层Tree SHA。
- 固定产品源码 `1522466faf798b719ccff281de7584f043946437`；app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`，产品源码与锁文件不修改。
- 开工及续接fresh live main `bda789155505fcdb071e6a359d930fe5abc6429e`，Root `8b3b78142340a87119eee6467ce1efda435713d7`；其接受产品仍为v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。没有用main覆盖连续候选。
- 交付分支 `codex/v10.1.5-offline-execution-boundary-conditional-producer`；只新增本报告和同名Manifest。作者/提交者沿用仓库固定Git身份。最终Commit/Root/两Blob在提交后的LOCAL_ONLY回读与Owner交付消息中记录，避免文档自指。

## D0：既有隔离边界 PASS，范围明确

只读发现设备原已安装且当前用户可用的Windows Sandbox，微软签名有效，无新功能安装、启用、提权或宿主安全/网络配置更改。Hyper-V只读查询返回异常，不能据此宣称没有VM；未启动Docker/WSL或换平台。

任务私有WSB设Networking Disable，并关闭vGPU、音视频、打印及剪贴板重定向。首次独立安全负例只映射无凭据探针与空结果目录，不映射SDK、产品、用户根或真实凭据。父进程和其创建的一个子进程分别向字面IPv4 `1.1.1.1:443`、IPv6 `2606:4700:4700::1111:443`执行最小TCP连接测试；不做DNS、HTTP、TLS，不发送应用数据。四次都即时返回10051 NetworkUnreachable，未出现connected或timeout。两进程均无Up网卡、无Connected非loopback接口、无默认路由，脚本/config Hash、runId、父子PID绑定一致。

独立Sandbox启动1次，87.148909807秒，launcher exit0、child exit0。原Get-NetAdapter错误可能被误当零网卡的问题在首次启动前收紧为ErrorAction Stop，原稿保留。隔离保证来自已验证实例的虚拟网络禁用配置与拓扑，TCP负例不是所有协议的逐一穷举。该结果不能放行宿主Flutter，亦不能自动转移到尚未启动的SDK映射实例；后者设计为先重新验证同实例边界。

探针末尾请求关闭自己的guest，launcher确实exit0，但不等于所有关联界面进程退出。后续发现其RemoteSession UI仍在，见D1；不据UI残留推断guest当前仍在运行，也不反推D0拒绝测试失败。

## D1：独立SDK输入准备完成，运行前置阻断

仅在D0 PASS后，于本任务自有目录定点复制已批准本机来源：共17907次文件复制、1630986306字节；SDK操作3302次，包含5个真实metadata覆盖，最终3297个不同SDK目标文件，复制操作字节1419495807。已接受34个flutter_gpu文件和5份metadata原样接入，没有重做GPU Git来源审计、制造stamp或修改旧Stage。其余为必要Windows launcher/internal、Dart SDK、工具snapshot、framework/tools、universal/Windows缓存、AndroidGenSnapshot输入和两份固定flutter.jar。没有重复制7.3GB整SDK，没有复制整Android SDK/JDK/Gradle发行包。

新host目录不是自包含可运行SDK。计划22条无重叠guest映射：新任务bin/packages/project/Pub及写入目录提供自有backing；既有真实SDK .git、JDK、Gradle、Android SDK、exact Maven库和旧Gradle artifact库只读。2149份既有artifact、1358424834字节已Hash，计划在guest内复制到私有可写cache，没有实际启动该步骤。真实SDK .git 170份文件、408182086字节另作只读源保护，没有伪造Git metadata。

冻结Flutter3.41.7/Dart3.11.5/engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、framework HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`、Gradle8.14/JDK17.0.18.8/AGP8.11.1/Kotlin2.2.20。launcher与真实Git Blob只差CRLF；未修改固定工具。上述为来源与静态身份，隔离内实际版本及运行兼容性均NOT_RUN。

50键sealed环境canonical SHA256 `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`。纯静态语义fixture在未启动native进程的ProcessStartInfo中实际Clear/Add字典，50键摘要与原Python一致，ANDROID_PREFS_ROOT键不存在；ANDROID_USER_HOME计划保留原批准逻辑路径、新任务自有physical backing。不能把该静态字典PASS扩大成BAT、Flutter或所有后代环境的实测一致。

启动前只修正本任务runner副本的两个问题并保留原稿：PowerShell临时变量误占自动变量HOME，改任务专有名；启动门显式拒绝预存producer/resolve授权文件与重复实例启动marker。一位非作者在同一次审查中核脚本、22条映射、分阶段请求、边界重验、固定pins和停止guard。静态支持仅在自有D0残留正常关闭并确认退出后才准SDK预检，未提前放行producer。

**实际首阻断**：自有D0 RemoteSession PID/父launcher PID、精确任务WSB启动路径、创建时间均再次匹配。仅尝试一次非force CloseMainWindow：有窗口、调用返回true，但WaitForExit(10000)返回false；随后只读仍见同一进程。原始回执 `owned-boundary-ui-close.json`明确passed=false，关闭请求被接收不能写成退出成功。没有桌面/UI观察，真实未退出原因UNKNOWN，不能猜测弹窗、VM故障或SDK不兼容。

此时终止D1推进：SDK映射实例0次、Java/Dart/Flutter版本命令0次，两个stage授权请求均未写，实际工具环境/缓存闭包未证明。没有重试关闭、force停止、系统更改、重启或切换隔离平台。该残留最后观测存在，状态如实保留；本轮不自动处置。

## D2与D3：均NOT_RUN

| 门禁 | 本轮真实结果 |
|---|---|
| 无凭据独立断网实例 | 1次，PASS；仅限该实例 |
| SDK映射实例与实际SDK READY | 0次，BLOCKED / NOT_READY |
| 已接受Gradle DAG重跑 | 0次；只继承既有证据 |
| :flutter:packJniLibsflutterBuildDebug及compile依赖 | 0/1，NOT_RUN |
| 本轮真实libs.jar | 未生成，Hash/CRC/entry/内容/ABI核验NOT_RUN |
| resolvePinnedDebugInputs | 0/1；Configuration.resolve()没有调用 |
| 15模块×2配置 | BEGIN0 / OK0 / FAIL0 / NOT_RUN30 |
| ICE诊断入口与Dart defines | ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN |
| 宿主APK/AAR、安装、设备、RTC/SFU、DB/API | 全部NOT_RUN |

普通Debug类库是允许的先行物，但本轮连真实producer都未运行。既有DAG的lib/main.dart、dartDefines=null不能当ICE诊断参数消费成功。严格resolver SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、selection policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`原样保留，没有放宽、lenient或替代文件解析。

## D4：非作者、保护与交付层次

一位GPT-6.1 Sol/high非作者沿同一次有界审查核前置脚本、D0实际回执和D1关闭阻断，支持立即STOP。审查者只读，不运行网络/Flutter/Gradle、不亲自观察guest，也不自签Astra接受。其静态支持不等于SDK启动或产品验收；最终文档/保护在同次审查中核计数。

保护终检PASS：990份具名关键原件全部重新Hash不变；20226份去重复制来源/只读原件全部不变（覆盖复制来源、真实.git和artifact源，不与990简单相加声称唯一总量）；47个固定原工具/输入pins不变；旧SDK index不变。507旧refs仍同SHA，五历史根HEAD/branch/index/status不变；原长路径warning保留。相关Process/User/Machine环境24组摘要相同、宿主相关Java/Dart进程0；宿主adapter/default-route快照摘要相同。无产品/main/ACTIVE_STATE写入、无共享SDK/cache或网络/全局环境变更。此为具名触及对象和继承关键原件有界核验，不宣称全盘或活DB内容逐字节审计。

真实二进制、SDK、完整日志、环境值、映射/真实私有路径全部LOCAL_ONLY。Manifest只列白名单摘要与证据Hash。GitHub直接核验层为任务/审查/状态/Git对象/完整产品maps；Windows运行与Hash属于CODEX_REPORTED_LOCAL_ONLY；非作者为LOCAL_STATIC_REVIEW；前轮GPU/DAG为INHERITED_NOT_RERUN；未运行项单列。普通nonforce提交发布后，须回读远端Commit/sole Parent/Root、两文档Blob/raw字节及完整产品双Tree，实际回执和最终Git身份在Owner交付中给出，不在未完成时预称远端通过。

**ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

交付后停止。设备已有且实测可用的隔离机制，不能写成缺失/需安装新平台；当前卡在新实例启动前的自有旧界面退出确认，不凭此要求扩大防火墙或联网权限。Owner/Astra下一步需先审定该具名会话的状态和是否另授后续处理；本轮不自动重启、清理、再次关闭或展开后继。
