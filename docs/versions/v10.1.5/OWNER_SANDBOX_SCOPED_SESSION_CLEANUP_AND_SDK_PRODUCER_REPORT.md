# v10.1.5｜Owner有界Sandbox收口、新隔离SDK与条件式Producer报告

日期：2026-10-24。**ISOLATED_SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN**。

本轮在Owner新授权下完成原始进程快照和独立新实例准入，实际启动SDK Sandbox **1/1次、75.142164秒**。**新实例自身断网验证PASS**，17898份guest私有输入复制Hash通过，JDK/Dart/Gradle实际版本通过；随后Git读取Flutter仓库HEAD因`dubious ownership`安全校验**exit128**，SDK未READY。首新阻断即停，Flutter CLI、Producer、真实libs.jar和30配置解析均NOT_RUN；未修复、重试或执行日志建议的全局Git设置。

## D0：权限、固定Git与旧guest状态

完整读取正式任务Blob `ce270b0ffe1e95eb5f63a628eb9429fefd66c081`、最新Astra复审Blob `c9bcb7f019acfcba9a5f7c468323da2100d47dcd`、ACTIVE_STATE Blob `385b7dec9129b97c21d4e5132dfda1f7b7d799a0`及必要具名前证。任务与fresh main路径原字节相等。当前状态在相同标题后新增Owner授权/前轮裁决两段，之前已读完整正文后缀不变；初版把标题也纳入后缀比较的辅助assert失败及定点纠正留LOCAL_ONLY，没有改状态文件或重跑guest查询。

- 本轮sole Parent `7292a8c39cec2e0bbb611436686828263129614b`，其Root `270adcd0c7934b974be7f820f1fd063a52e63285`、sole Parent `29eced7453d876ca3d229341241b518e80b82635`。
- 候选完整apps `785822ca072943c5bfefa3ccc37ede01c2af5164`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`，GitHub完整maps1133/791条逐path/mode/type/SHA精确匹配本地。固定诊断source `1522466faf798b719ccff281de7584f043946437`、app构建Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`不修改。
- 开工live main `9e69b78aff49f1712a0184e65d82f2eab31e391f`，Root `e738c45e3b1eae8f9aedd0c3216b5b3924500714`。其接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整maps1116/776条匹配；没有用main覆盖待接受候选。
- 固定前证报告Blob `8a0c00e8bab4e2eed85df5a824e8e2ea185b9ba2`、Manifest Blob `0698c26e0bad31900eab7e224a59c28c50e7153b`原字节保留，旧HCS失败、空快照缺失和旧CloseMainWindow未确认退出均不倒填。

本轮独立原始快照实际落盘，保存查询时间、命令/范围、原始数组及PID/创建时间/路径/签名可取得字段，即使空结果也能保存。快照有两条通用虚拟化后台记录，未见Sandbox前台/RemoteSession命名匹配或旧任务WSB来源匹配。两通用记录路径/CommandLine不可取得，不能认定它们与旧guest无关、也不能以泛名认作旧guest并终止。**正常关闭0次，精准单进程终止0次**，未使用历史PID盲操作。

辅助HCS guest查询只1次，签名Valid、未提权，返回`0x8037011B`，stdout0字节、stderr仅CRLF2字节，仍无可用清单。保留 **OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS**，不签OLD_GUEST_CLOSED_PASS、不解释错误码根因。Owner本轮明确允许在无当前已知活跃重叠且新写根隔离时考虑新实例，因此未沿用上一任务的“必须先取得guest关闭证明”硬阻断。

静态资源准入为 **NEW_INSTANCE_ISOLATION_PRECONDITION_PASS**：新runId/WSB/结果根唯一，旧准备源只读，guest私有写入不与历史根共享；源字节可读取、未发现已知任务归属占用，不删除旧lock。启动前还进行一次即时进程守卫，原始空数组实际保存、PASS；它只防启动时出现新命名冲突，没有再查HCS或关闭任何进程。通用后台归属及旧guest最终状态继续UNKNOWN。

## D1：新实例实测及首阻断

**没有在宿主重新复制整套SDK。** 复用已准备的本地输入，22条映射中历史SDK/.git/JDK/Gradle/Android/Pub/project/cache源全部只读；宿主可写映射只在本轮新证据根，静态init亦为本轮三份小副本。运行时在新guest私有盘构成冻结逻辑路径的可写视图，既有输入无回写。复制17898件、1630967264字节，包含必要SDK/项目/Pub及cache metadata，每件Hash匹配；既有artifact store2149项随后按严格循环复制/hash，未单独导出逐项完成回执，后续进入tool_identity说明该循环及pins/根检查未抛错。不能把此过程称SDK已READY。

首次启动前发现必要逻辑路径最长超过260字符，只在本轮runner改用显式扩展路径的.NET文件复制/流Hash/长度读取，cache metadata亦逐文件按清单处理；不改registry或系统策略。Windows PowerShell5.1对331/325/325字符三份既有原件只读校验通过，完整脚本语法通过。272个package root先作静态来源映射检查，均有真实pubspec；新实例仍实际重复自身路径/Hash安全门。未重做GPU来源、旧DAG、旧独立无凭据探针或历史25/38/11 fixtures。

本实例Networking Disable实测：父进程及其一个子进程分别对批准的字面IPv4/IPv6 TCP443做最小连接负例，四次均即时10051 NetworkUnreachable，无DNS/HTTP/TLS/应用数据；无Up适配器、无Connected非loopback接口、无默认路由，runId/WSB/child源码Hash/父子PID绑定通过。**仅证明本轮实例，不能倒证旧guest关闭或宣称宿主全网隔离。**

| 当前实例检查 | 真实结果 |
|---|---|
| Java --version | 1次，exit0，Temurin17.0.18+8 |
| Dart --version | 1次，exit0，3.11.5 |
| Gradle --version --offline | 1次，exit0，8.14 |
| Git读取framework HEAD | 1次，exit128，HEAD未取得 |
| Flutter --version | 0次，NOT_RUN |
| SDK READY | NOT_PASS |

四个native launcher实际ProcessStartInfo传入字典均50键，canonical SHA256 `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；ANDROID_PREFS_ROOT任意大小写键不存在，ANDROID_USER_HOME原批准逻辑路径保留、backing为新guest私有目录。此结论不扩大成每个工具内部后代环境逐键实测一致。AGP8.11.1/KGP2.2.20只核缓存JAR字节pins，尚未项目加载；Gradle版本输出内嵌Kotlin2.0.21不等同项目KGP版本漂移。

**首个新阻断**是guest内Git安全校验。`framework-head`原stderr明确`fatal: detected dubious ownership in repository`，guest视角仓库owner为SYSTEM、当前为WDAGUtilityAccount；命令exit128、约0.405秒，没有获得HEAD。SDK阶段记录phase=tool_identity、NATIVE_STAGE_FAILED:framework-head（外层PowerShell RuntimeException）。这是可观察的guest仓库归属差异，不能写SDK损坏、HEAD不符、产品代码错误或推断宿主owner已改变。日志建议的全局safe.directory命令未执行，未改全局/用户Git配置或ACL，未再尝试Git/Flutter/SDK。

launcher exit0只说明启动器结束，不覆盖preflight passed=false。失败后driver的已核guest上下文finally配置为正常shutdown路径；没有独立shutdown退出回执。D4只读观察未见相关Sandbox前台进程，但仍不以进程未见证明全部guest资源退出，不追加HCS查询或关闭动作。

## D2与D3：未放行、未执行

- `:flutter:packJniLibsflutterBuildDebug`及compile依赖 **0/1**；已接受DAG本轮未重跑。两个阶段授权请求从未写出。
- 本轮没有真实libs.jar，Hash/JAR结构/CRC/JNI内容/双ABI验收均NOT_RUN。SDK READY后的guest Jar不存在检查尚未到达；初始只读project seed无目标Jar且producer没有运行，不能伪造产物或补空Jar。
- `resolvePinnedDebugInputs` **0/1**，Configuration.resolve()实际调用0；15模块×2配置 **BEGIN0 / OK0 / FAIL0 / NOT_RUN30**。Gradle --version1次不等于项目解析，亦不能笼统写Gradle完全未运行。
- 严格init SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不变，未放宽选择或跳过文件解析。
- **ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**保持；原实际DAG lib/main.dart/dartDefines=null只支持普通Debug类库来源。本轮无Flutter CLI、无类库产物，更无ICE诊断APK或RTC成功。

## D4：保护、非作者与交付

一次GPT-6.1 Sol/high非作者有界审查贯穿D0归属/新实例准入、最终runner/只读映射、当前实例真实阻断及最终两文档保护核对；只读source/receipt，没有亲自运行guest/工具、扩查或代签Astra接受。前置只放行SDK预检，未预先放行producer/resolve；实际Git阻断后支持停止。

保护终检PASS：1189份具名原件、20268份选定prepared/只读来源文件内容Hash全部不变（两集合可能重叠，不相加为唯一总数）；509旧refs同SHA，五历史根HEAD/branch/index/status及历史warning保持，三份本轮init source不变。24组相关环境摘要不变、宿主相关Java/Dart进程0。宿主网络前后原始序列化Hash不同，但解析后的adapter/route结构完全相同，原回执均保留，并按稳定结构比较；没有改宿主网络配置。此为具名有限保护，不宣称全盘或活DB逐字节审计。原SQL/APK、备份、私密日志、未授权part和所有旧FAIL保留。

guest私有复制/cache/版本工具可能有正常派生写入，未导出整个guest最终盘点，不称guest目录零变化；旧host SDK/cache等为只读映射且before/after字节保护。宿主本轮新增仅自有脚本/控制/完整日志/回执与临时Python派生，不复用未授权历史工件，不清理历史。

Git从唯一固定Parent建立后继，仅新增本报告和`owner_sandbox_scoped_session_cleanup_and_sdk_producer_manifest.json`。普通nonforce发布后完整回读Commit/sole Parent/Root、两Blob/raw字节、完整apps/services映射；最终Git身份与实际发布回执在LOCAL_ONLY和Owner交付消息记录，避免文档自指或提前称远端通过。原始PID/SID/VM标识、绝对私密路径、WSB映射/环境、完整stdout/stderr、SDK/JAR/APK全部LOCAL_ONLY；公开仅裁决摘要与Hash。

GitHub固定对象/正文为GITHUB_DIRECT；Windows网络/版本/错误及Hash为CODEX_REPORTED_LOCAL_ONLY；非作者为STATIC_RECEIPT_REVIEW；GPU/DAG/旧探针为INHERITED_NOT_RERUN。保留当前Git归属门、Flutter CLI/SDK READY、真实producer/Jar、30解析、APK/ICE/RTC各独立未完成门，不把一项推进当整版接受。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

交付后立即停止，等待Astra独立审查。新观察的guest Git信任/归属差异仅作为后续待审门，本轮不执行stderr修复建议、不自动更改safe.directory/owner、重试或启动下一任务。
