# v10.1.5｜Sandbox精确Git信任与条件式Producer交付

日期：2026-10-24（Asia/Shanghai）。**SANDBOX_SDK_GIT_IDENTITY_FIRST_BLOCKER / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN**。

该聚合终态的具体阻断是**SDK完成回执600秒超时，随后另有迟到的身份回执JSON序列化失败**，不是Git信任失败或旧exit128复现。本实例实际Git配置读回为唯一精准command-scope条目，HEAD命令exit0且冻结SHA匹配，后置身份比较也已通过；但Flutter CLI未进入，SDK未READY。原超时观察与晚到异常分别保留，不修复、不重跑。Producer/Jar/30配置全部NOT_RUN。

## D0：权限、固定身份与最小信任差异

完整读取任务Blob `3cfba96e62befcc495c55279967c5c2b8a3370cd`、最新Astra复审Blob `46dc2cc3633ba0f732c7decce9e74ee3a1b23e5d`、ACTIVE_STATE Blob `7106a2ee3c3b0889b10abdc9635cbdf28578950c`及具名前证。当前状态新增首段已读，之前完整正文保持同一后缀；与实际main任务路径及固定Git Blob原字节核对通过。一次connector读取发生传输故障，原错误留存，固定正文随后取得；不属于SDK/构建运行重试。

- sole Parent `dd9b4eb9df9101adf4c0d980135081fd902c656a`，其Root `57ec12b1cc0aca1aebf4eb92da6c5f3a80f65243`、sole Parent `7292a8c39cec2e0bbb611436686828263129614b`。
- 产品诊断source `1522466faf798b719ccff281de7584f043946437`；app构建Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`；候选完整apps `785822ca072943c5bfefa3ccc37ede01c2af5164`、services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`，完整maps1133/791条逐path/mode/type/SHA匹配GitHub。
- 开工live main `e225091f2043c42cfd52e653ace67fbf0e5ed97a`，Root `8e79c42614c17fb25560d4ce3f2f50388bc6dcf0`。main接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整maps1116/776条匹配；未覆盖候选。
- 前证报告Blob `5394eecac87e07fa6a19c1f26ce65f567a5960c7`、Manifest Blob `6f6c690be9bf99ebce2116dc083fa68e7ea09779`、旧未经例外Git exit128/HCS UNKNOWN/历史缺快照原件均保留，不倒填。

先核可信SDK源码仓库：真实root/.git为目录、非worktree指针，无不可控重解析/commondir/alternates；170份固定.git文件原字节匹配，源配置无动态include/worktree/hooksPath/fsmonitor/sshCommand指令。现存本机源Git读回root/gitDir及framework HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`一致；不fetch/clone，不改owner/ACL/.git。

为让Flutter后代Git继承，仅在任务创建的子进程字典追加三项：GIT_CONFIG_COUNT=1、GIT_CONFIG_KEY_0=safe.directory、GIT_CONFIG_VALUE_0=已核单一规范绝对framework根（真实值仅LOCAL_ONLY）。原50键原值无删除/替换，含ANDROID_USER_HOME批准归属；任意大小写ANDROID_PREFS_ROOT键不存在。base canonical SHA256为`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`，运行53键明确改为`6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`，不再虚称运行环境仍是原50键全字节。

10项静态范围负例拒绝通配、空/相对/父子/别repo、错误key/count及额外entry；不是10次真实未知repo Git执行。本机Git2.53.0读回实际command条目，证明该版本支持此runtime来源；另有3条既有宿主global条目未改动，不能把本机探针当guest唯一信任范围PASS。新guest必须自己读回所有safe.directory行并严格只有一条精准command来源；没有全局/系统/repo配置写入或通配例外。

## D1：唯一新实例与实际Git成功

当前独立原始进程快照保留命令、时点和数组，未发现命名Sandbox占用；不归属、不终止通用后台进程，不再查询故障HCS。**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS**保持，不签旧guest关闭PASS。启动前即时进程守卫PASS。

本轮新SDK Sandbox **1/1次**。22映射的历史源全只读，宿主可写仅本轮新根；复用既有输入，在guest私有盘复制17898文件/1630967264字节并核Hash，没有宿主重复制SDK。当前实例父子进程各做IPv4/IPv6字面TCP负例，四次均10051，无Up网卡、非loopback连接或默认路由，无DNS/HTTP/TLS/应用数据；只支持当前实例，不代替旧guest或宿主全网证明。

guest实际验证规范root/owner、预期只读.git映射及170份Git字节。53键ProcessStartInfo环境实际保持base50原值，配置读回严格只有1行command/command line:/精准root，无其它scope/泛根。**SCOPED_GIT_TRUST_READBACK_PASS**成立。原始Git HEAD调用一次exit0、stderr0B，stdout三行root/gitDir/冻结HEAD独立匹配；末尾目录斜杠按既定规则处理。后置比较不符时源码会先throw，而晚到栈已进入其后的身份回执写入点，所以可支持比较通过，但不能虚构缺失的JSON。

| 实际检查 | 结果 |
|---|---|
| JDK/Dart/Gradle版本 | 各1次exit0，17.0.18+8 / 3.11.5 / 8.14 |
| guest safe.directory读回 | 1次exit0，仅1条精确command来源 |
| guest framework HEAD | 1次exit0，冻结SHA匹配 |
| framework-identity.json | 未写成 |
| Flutter CLI版本 | 0次，未进入 |
| SDK READY | 未通过 |

五个native launcher均记录53键/新canonical Hash；不扩大成每个工具内部后代环境完全逐键一致。AGP8.11.1/KGP2.2.20为缓存artifact身份，不声称项目加载；Gradle内嵌Kotlin2.0.21不是项目KGP漂移。

## 必须分开的超时、迟到异常与收口证据

1. 原600秒窗口结束于**15:13:39.026（+08）**，elapsed600.111897秒；控制器未收到framework-identity、SDK完成、Flutter启动或guest失败回执，记录SDK_PREFLIGHT_NOT_RECEIVED_WITHIN_600_SECONDS并停止后续放行。launcher exit0不等于SDK成功或guest driver终止。这个截止观察不覆盖、不重写。
2. 后来取得`session-failure.json`：guest记录**15:18:08.116（+08）**，文件创建/修改15:18:08.136，晚于截止约269秒。phase=scoped_git_identity，System.Management.Automation.PSInvalidCastException，消息为`Cannot convert value to type System.String.`，栈在Write-Receipt的ConvertTo-Json，调用点为写framework-identity。它证明身份回执序列化失败，不能写Git命令失败、HEAD错误或SDK损坏。具体转换机制、完整停顿原因没有复现验证；本轮没有修复/重跑。
3. 正常退出记录先因可执行签名核验门不足未发关闭；该结果不证明微软Appx不可信。补核当前微软Windows包身份后，只读UI返回画面与Sandbox目标不符，**没有任何点击、输入或关闭操作**，不把该画面当Sandbox原证，更不公开截图。
4. Owner直接反馈看见超时提示窗口并已关闭。**15:25:10只读后查**相关Sandbox进程0、本WSB匹配0；未HCS查询/重启/force。Owner关闭的精确时间与该异常因果未证，不能因首次后查取得晚证就称Owner关闭造成异常。当前客户端关闭为Owner回执加进程观察，全部guest/历史旧guest关闭仍未独立证明。

截至600秒时Flutter0是观察层事实；晚失败与固定catch/finally源码再支持本driver未进入后续Flutter/producer/resolve。正常shutdown为catch后的既定路径，单独guest退出完成回执未捕获，不能用控制器停止或launcher0冒充全部资源退出。

## D2与D3：没有放行

Producer `:flutter:packJniLibsflutterBuildDebug`及compile依赖 **0/1**；没有真实libs.jar，来源/Hash/ZIP/CRC/JNI/双ABI验收全部NOT_RUN。为条件成功场景准备了官方两来源*.so映射、完整条目集合、逐项唯一源字节与ELF ABI校验，但本轮没有执行这些产物检查，更没有空Jar或历史替代。

正式`resolvePinnedDebugInputs` **0/1**，Configuration.resolve()实际调用0，15模块×2配置 **BEGIN0 / OK0 / FAIL0 / NOT_RUN30**；producer/resolve授权请求从未写出。严格init SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不改；旧DAG/GPU/HOST/历史fixture未重跑。

**ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**持续，原lib/main.dart/dartDefines=null不因Git或版本命令改变。宿主APK、额外AAR、设备/ADB、RTC/SFU、DB/API、主线集成全部NOT_RUN。

## D4：单次非作者、保护及公开边界

一次GPT-6.1 Sol/high非作者有界复核覆盖D0精确scope、最终脚本、当前实例实际读回、截止与晚证、Owner收口及最终文档/保护；没有执行guest命令、替代Astra验收或扩展预算。首次启动前收紧了config读取的明确仓库上下文及Jar完整集合检查，原稿留存，不是运行失败后修复。

保护终检PASS：1319份具名原件和20268份prepared/只读来源内容Hash均保持，两集合可能重叠不相加为全盘唯一数；510条开工refs（含历史509）及五历史root的HEAD/branch/index/status和旧warning保持，三份init源不变。24组原相关环境和21组宿主Git配置环境摘要保持；宿主user/system Git config具名原字节无变化，宿主相关Java/Dart进程0，adapter/route解析结构与回执内stateSha256一致；完整raw网络回执文件Hash不同，两原件均保留，不称raw文件字节相同。保护为触及的具名范围，不是全盘/活DB或完整guest派生盘审计。

guest私有seed/cache/版本工具的合法派生不称零写入；没有写共享SDK/.git/ACL/全局Git或网络设置。历史SQL/APK、恢复备份、私密日志/环境、未授权part及全部旧失败原位保留。原始PID/SID/Git owner、绝对路径、config值、WSB、完整日志、UI画面与SDK/JAR/APK仅LOCAL_ONLY；公开仅去敏状态/Hash索引。

Git从固定Parent只新增本报告与`sandbox_scoped_git_trust_and_conditional_producer_manifest.json`，不改产品、旧docs、AGENTS或ACTIVE_STATE。普通nonforce发布后须完整回读Commit/sole Parent/Root、两Blob和UTF-8 raw字节、完整apps/services maps；实际发布身份在提交后的LOCAL_ONLY回执与Owner交付中提供，避免文档自指或提前称远端通过。

GitHub固定对象为GITHUB_DIRECT；本机执行为CODEX_REPORTED_LOCAL_ONLY；截止观察、晚到guest异常、Owner手动回执和不匹配的只读UI观察各自分层。实际Git信任推进受支持，SDK回执/Flutter运行门仍未完成，不签整版接受。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

交付回读后立即停止，等待Astra独立审查。本轮不修观察器、不重试SDK/Flutter或派发下一任务。
