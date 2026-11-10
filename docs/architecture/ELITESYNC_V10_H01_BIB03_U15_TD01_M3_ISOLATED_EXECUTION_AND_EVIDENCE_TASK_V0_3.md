# EliteSync v10｜Git定位修复、证据保留与M3隔离续行任务 v0.3

Status: `TASK ONLY — BOUNDED COLLECTOR REPAIR + CONDITIONAL ISOLATED M3 — OWNER OPTION 1 CONTINUES — NO PRODUCT IMPLEMENTATION`

日期：2026-09-07（Asia/Singapore）。使用简体中文；Owner在宿主选择GPT-6 Astra。不修改模型配置，不默认调用其他型号辅助代理。

## 1. 目标、增量与授权

002候选76486b323e03853fe6675ae22c8e545073f0ee1a已由main中的接受提交d978e9d36e32e0b12f02eb9f4e7de0690a8b7226接受为真实前置失败记录。执行脚本未保存Get-Command原始路径，安装根绑定未完成；这不是Git缺失、安装错误或构建失败的证据。六个具名工具/seed根已完成执行者报告的存在性检查，Sandbox/pub/M3均未启动。

本任务落实Owner已批准的离线隔离选项1及可逆工作自动续发约定：修复采证脚本，保留旧证据，在同一个批准宿主根内新增独立attempt工作区，条件满足后直接进入已有范围的一次隔离生成。无需再次询问是否允许选项1、重新研究整套方法或要求Owner手工找Git。

明确替换v0.2的两个局部约束：Git定位不再只能一次且只认cmd/bin；已知自有隔离根不再一概视为冲突。仅这两项及下述精确续行规则改变，不扩大外部网络、宿主安装、产品源码、用户配置或受保护状态权限。

准备脚本的修复与产品实现不同；无副作用文本处理重算也不同于pub/M3重试。接受002失败记录不代表其采证器正确、原始返回值已经找回或M3目标完成。001/002结果和旧M1均保留原始含义。

## 2. 固定main、入口和项目只读输入

仓库：zcx369658780/EliteSync-v10。先实时核验main，必须恰为：
`d978e9d36e32e0b12f02eb9f4e7de0690a8b7226`

FIRST主动读取该main中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
要求blob：`18485c95262051e43892436fb52413132c5ee626`。

随后读取启动prompt绑定的本任务commit/blob；唯一父必须为上述main，只新增本任务。历史startup不重跑；旧main不是本次入口。身份/hash/授权保护失配时停止依赖步骤，不自动换基线。

其他项目输入只限以下固定main中的文件；不沿引用继续发现：

| 精确路径 | 要求blob／用途 |
| --- | --- |
| AGENTS.md | f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1；现行规则 |
| docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md | aca04aa63dd179d27c697ed37e23bc718cbe95a2；待更新原文 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_2.md | 1b92aa1d1bc561e558955d50921c3e125912f3ea；失败、已创建证据及哈希 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_2.md | d158003332c7f3c06f689eb970b18b167dfeba96；§3–7工具物化/隔离依据；冲突以本任务明确差异为准 |
| apps/android/app/build.gradle.kts | a7e0f7583c801e2d56afc595d6c7bed84b5ce516；仅direct AAR/defines合同 |
| apps/android/gradle.properties | f0a2e55f89e383466d2c6b481c8c468a3aa0b13d；仅flutterDartDefines键 |

本地根仅D:\EliteSync-v10。允许只读Git根/HEAD/origin及固定提交对象可用性检查；必要时只fetch声明的main到refs/elitesync/m3-iso-v02-003-input，禁tags及submodule递归。HEAD只记录上下文，不要求等于main，不checkout/pull/reset/stash/clean，不默认index或git status。源码冻结为上述main的apps/flutter_elitesync_module Git对象，不使用本地工作区或旧仓库代码。

## 3. 先保留002，再创建003子工作区

已批准宿主根：`D:\EliteSync-M3-readiness-v02`。它已存在，这是本任务预期，不删除、不重新命名、不复用002输入或运行标志。

仅对下列两个已声明自有证据做安全路径检查、读取、一次SHA-256比较：
- `D:\EliteSync-M3-readiness-v02\evidence\M3-ISO-V02-002-result.json`：67067707728C779AB89047D1A6C53DA9E5DE75A06582F2A150F98B8ED1B3E2F7
- `D:\EliteSync-M3-readiness-v02\evidence\M3-ISO-V02-002-host.log`：D7ED460EB9D32C0C77D288756D44D13A18A8DD08FBDB70B39DE97E6BE31C40B5

只采用采证状态/错误等相关字段，不执行旧日志内容；确认002 terminal且pub/M3未启动。缺失、哈希变化、危险跳转或阶段矛盾时记录EVIDENCE PROVENANCE CONFLICT，停止本根续行，不搜索替代或修补旧证据。GitHub报告中的丢失分隔符路径不是执行定位符。

通过后允许在同一宿主根的字面`attempts`目录下独占创建：
`D:\EliteSync-M3-readiness-v02\attempts\M3-ISO-V02-003`
这是003唯一新工作区，记作W；新attempt ID为M3-ISO-V02-003。仅新增W\input、W\evidence、W\scripts、W\scratch、W\m3.wsb及这些位置的本任务自产文件。attempts已有时只确认目录及安全属性，不列目录；W已有时停止，不覆盖、不换名绕过。根外和002文件禁止写。

立即在W\evidence初始化M3-ISO-V02-003-result.json、host.log；默认pub_started=false、m3_started=false、exit=null、aar_result=NOT_CHECKED。所有后续失败均先flush真实异常/阶段/计数。各阶段日志append；结果JSON只更新本轮文件。不得为通过门槛删除旧证据或声称002未创建。

## 4. Git采证修复：先存原值，再推导和验证

这是本轮新增的有限定位权限，仅针对当前命中的git.exe，不扩展成磁盘/仓库/注册表搜索。

1. 在W的PowerShell上下文用精确名称Get-Command -Name git.exe -CommandType Application；不加通配符、不列全部命令、不主动切换其他Git安装。先将返回对象数量、类型及每项Name/Path/Source/Definition中的应用路径、错误信息写入W\evidence\git-discovery-1.json，再做任何结构守卫。多对象显式数组化并按命令解析优先序选择第一项，不把数组直接当路径字符串或布尔判断。空返回/非Application明确报出。
2. 用选中对象Path，缺失时Source作为单一路径。保留原值，另记录规范化值；只进行Trim、正反斜杠与Windows路径组件解析。不eval字符串，不丢失空格，不用截图/OCR。调用通过参数数组。相对路径、shim或跳转不被假装成发行根。
3. 对选中Application实际路径及祖先作定点类型/reparse检查，随后可运行该精确exe的`--version`和`--exec-path`各一次，cwd为W；保存stdout、stderr、exit及异常。它们是新增的宿主Git工具自描述查询，不是构建或源码检查。--exec-path是核心程序路径，不能单独当作完整安装根；仅在子进程环境排除GIT_EXEC_PATH覆盖，不改持久环境，不读取用户Git配置。
4. 从已保存的exe路径/exec-path组件提出至多三个有直接结构依据的发行根候选。支持cmd\git.exe、bin\git.exe、mingw64\bin\git.exe、mingw32\bin\git.exe、usr\bin\git.exe；先匹配较长后缀再匹配bin，防止把mingw64误当完整根。也允许由mingw64或mingw32下libexec\git-core回溯同一发行根。不得猜C:\Program Files\Git、任意父目录或其他安装位置；不得将盘根、用户主目录、项目根作为Git发行包复制。
5. 每个候选只查由上述结构直接导出的命中exe、cmd\git.exe、对应mingw64/mingw32\bin\git.exe、对应libexec\git-core以及usr\bin\sh.exe等具名文件/目录，不递归列目录。记录具体命中/未命中，验证执行入口、核心程序及所需运行目录落在同一有界根。缺cmd入口不能单凭这一点否定官方支持的直接mingw入口；不能把只复制git.exe当完整依赖。最终仅允许一个已绑定发行根只读映射/复制，客体自身再验证复制后Git能够执行。
6. 完成推导后记录原始入口、选择依据、候选、每项守卫值及明确失败项。若仍不能唯一安全绑定，报告GIT ROOT UNRESOLVED并保留全部新诊断；不能把未知写成安装坏了，不安装或改PATH解决。

本任务允许首次加最多两次针对已记录采证代码缺陷的定位轮次，每轮先写独立原始记录；每个轮次内自描述命令各至多一次。已有原值时优先只重算内存数据，不重查。允许在W\scratch用合成路径/对象测试空值、单值、多值、空格、正反斜杠、cmd/bin/mingw布局；不探测这些合成路径。这替代002的一次定位预算，不恢复旧调用。

## 5. 有界脚本修复与已知输入

主机采证/编排helper在Sandbox启动前允许最多两轮针对真实语法、序列化、路径处理缺陷的修复；只改W中的自产脚本，先写错误再改，用已保存输入或合成测试验证。跨语言传参不拼接未转义长字符串。脚本解析/纯文本计算失败不消耗pub/M3预算；不得重跑整张任务、重建W、跳过安全守卫或扩大输入。每轮修复须有具体缺陷和结果，非无限试错。

具名工具/seed沿用002，仅作必要的定点安全/可读性复核，不重新发现或要求Owner补相同信息：
- Flutter：D:\flutter；入口bin\flutter.bat、bin\cache\dart-sdk\bin\dart.exe。
- Android SDK：C:\Users\zcxve\AppData\Local\Android\Sdk。
- JDK：C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot；bin\java.exe。
- pub：C:\Users\zcxve\AppData\Local\Pub\Cache。
- Gradle caches：D:\GradleHome\caches；wrapper seed：D:\GradleHome\wrapper\dists。

不得回退旧默认.gradle、扫cache版本、启动Android Studio或强改Wrapper迎合已有分发包。Owner已提供Sandbox Enabled；不重跑Get-WindowsOptionalFeature/DISM，不RunAs、不启用功能。未有当次客体证据前不声称隔离通过。

defines仅解析D:\GradleHome\gradle.properties的flutterDartDefines键、§2固定项目blob的同名键、当前ORG_GRADLE_PROJECT_flutterDartDefines变量，优先用户home→项目→环境；均无值才EMPTY。不读其他属性/历史，不setx，不输出secret；按分号/逗号合同构造参数数组，不执行参数文字。

## 6. 绑定成功后直接继续隔离准备和一次生成

沿用v0.2 §4–7的过滤物化、工具副本、网络控制及结果语义，但本次所有宿主input/evidence/scripts/config均替换为W下相应目录，不能映射002旧证据。源码固定§2main的模块Git对象。排除旧build/.dart_tool/.android/.ios/.gradle、Git元数据、README类、FD02及受保护/凭据/真实数据/运行日志；机械过滤在进入输入副本前发生。不得全仓复制或agent源码分析。二进制归档按字节处理，拒绝路径穿越/外部链接；无法安全物化就停止。

客体根仍C:\M3；W\input及本轮具名工具/seed（包括已绑定Git发行根）只读映射至C:\M3\seed相应子目录；唯一可写宿主映射为W\evidence→C:\M3\evidence。禁止映射整个原仓库、旧仓库、用户主目录、D:\GradleHome或批准宿主根的全部内容。

m3.wsb显式禁用Networking、ClipboardRedirection、AudioInput、VideoInput、PrinterRedirection；vGPU可禁用。启动前解析自产XML、绑定映射及配置哈希；LogonCommand只运行本次冻结guest脚本。仅启动一次指定配置的Sandbox，不启动默认配置。验证同次nonce、客体接口/默认路由状态，不ping/DNS/HTTP探测，不对只读宿主映射试写。控制无法验证则不启动构建，不绕过。

复制模块到C:\M3\work\apps\flutter_elitesync_module；工具到C:\M3\tools下各自目录；pub到C:\M3\pub-cache；Gradle caches及wrapper/dists到C:\M3\gradle-home。工具内部读取目录项用于复制是已有物化权限，不是agent枚举权限。不要复制宿主Gradle properties/init.d/credentials/daemon或用户Git配置。SDK/Git发行自身必要元数据只供工具使用；所有seed只读，副本可写。

PATH、FLUTTER_ROOT、JAVA_HOME、ANDROID_HOME/ANDROID_SDK_ROOT、PUB_CACHE、GRADLE_USER_HOME、TEMP/TMP仅绑定客体工具/系统目录。客体新Gradle属性限daemon=false及java.home指向客体JDK。客体允许一次具名Git --version与JDK java.exe -version，并保存实际返回；宿主不运行Java/Flutter/Dart/Gradle。

准备成功后连续完成，不再等待一次人工审批：
1. 客体模块cwd内一次`C:\M3\tools\flutter\bin\flutter.bat pub get --offline`，上限10分钟。
2. 仅pub成功及控制通过后，一次`C:\M3\tools\flutter\bin\flutter.bat build aar --no-debug --no-profile --no-pub`加已绑定参数数组，上限30分钟。

guest启动前冻结脚本与命令合同；各阶段写started防重入。不得在运行后修脚本/源码换命令重试；不联网补包、不安装、升级或改Wrapper。超时只终止本任务拥有的客体进程树并保存状态，不杀宿主进程、不无限等待。实际子命令exit/exception和包装脚本exit分开；失败按其真实阶段报告。003是一个受当前合同授权的续行attempt，002不会被改写为成功或重新执行。

## 7. 新鲜证据与历史保护

只有003的M3实际启动后才允许对唯一客体定位符做一次存在性检查：
`C:\M3\work\apps\flutter_elitesync_module\build\host\outputs\repo\com\elitesync\flutter_elitesync_module\flutter_release\1.0\flutter_release-1.0.aar`

HIT时记录size/SHA-256；未启动保持NOT_CHECKED而非NON-HIT。可工具级导出本次build\host\outputs\repo到W\evidence\maven-repo，并比较导出同一AAR的哈希确认传输；不搜索替代产物。只有exit=0、exact HIT及固定输入/控制证据同时满足才报告本attempt生成证据HIT；不证明App可安装或M2成功。

W\evidence保存result.json、host.log、git-discovery各轮原始记录、guest.log及已发生阶段的manifest/配置哈希；未产生的文件明确未产生。路径用JSON序列化/代码标记保存，不再丢失反斜杠。只轮询自有结果标志，不算AAR重复探测。敏感值不上传GitHub，源码/cache/AAR/本地日志不自动上传。失败证据不清理；未导出的guest状态可能随关闭丢失，如实记录。

002两个文件只读保留；任务结束定点复核其哈希未改变。旧root的其他内容不读不改，不重用旧input/flags。003自有脚本修复不能触碰002或原仓库。真实权限/边界错误仍必须停止，不能把继续执行误解为忽视保护。

## 8. 唯一候选与验收终点

GitHub候选仅：
1. 新增`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_3.md`。
2. 更新`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`页首/§1/§4/§5的本次状态；§2/§3/§6/§7保持原文。001/002历史与003实际结果分开，旧标题不触发重复接受。不要把旧失败的安装错误猜测写成事实。

候选分支：`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-3`；subject：`docs: record Git-binding repair and isolated M3 continuation`。唯一父为本任务提交，一个候选commit，只改两个目标；GitHub Git Database发布，不本地commit、不操作默认index。分支/新报告冲突不覆盖。

结果先报真实终态；必须包括Git原始路径/对象形态/选定根/具体守卫值或缺口、采证修复轮次、002文件保护、003隔离/命令/AAR阶段、日志保存、剩余具体障碍。未实测的运行model ID/完整加载链/整仓cleanliness不补写。

发布前一次核验main/task绑定未变；发布后一次核验自身parent/两路径/两个blob。无新变化不重复整套检查。执行者不自我接受、不更新main、不执行M2、不另发任务、不更新ChatGPT项目源。完成后停止。

独立ChatGPT验收沿用同tree单父接受commit，不另写closeout；通过且已有权限足够时同轮续发。需要安装/下载/新产品实现等特殊变化时集中给一次具体决策，而非重开同义方法研究。

## 9. 本轮官方定点依据与不变边界

作者于2026-09-07核验：
- https://gitforwindows.org/git-wrapper.html ：cmd入口与实际mingw/usr程序布局不同；仅作支持解析结构的依据，不证明本机安装位置。
- https://git-scm.com/docs/git ：--version与--exec-path；后者返回核心程序位置并可能受GIT_EXEC_PATH影响，不是完整发行根证明。
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command ：Application对象、Path/命令解析及多同名命令语义；默认命中不等于安装完备。

执行者只在这些主题及v0.2已列官方隔离/Flutter主题内按需核对，不追加广泛研究。采证修复规则是本次有界合同，不修改全局AGENTS或永久一切重试政策。

README预算耗尽、FD02永久排除、无旧仓库访问/全仓枚举；受保护无关暂存状态不得检查、修改、引用、总结或使用。原D:\EliteSync-v10内容、宿主SDK/cache/用户配置不写。GitHub与固定Git对象传输只是已授权宿主发布/输入通道；客体构建外部网络为零。

D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、PUI deferred/PUI-PREREQ-12=0、legal/Safety/no-processing保持；LC-03/LC-04/Phase36、产品实现仍未授权。M2仍deferred；不得从一次M3尝试推断整体重构进度。
