# EliteSync v10｜M3 已补齐环境输入的离线隔离执行任务 v0.2

Status: `TASK ONLY — OWNER OPTION 1 CONTINUES — NEW CONDITIONAL EXECUTION M3-ISO-V02-002 — NO HOST BUILD / NO EXTERNAL BUILD NETWORK / NO PRODUCT IMPLEMENTATION`

日期：2026-09-07（Asia/Singapore）。执行者使用简体中文；Owner在宿主选择GPT-6 Astra，不改模型配置、不默认启动其他型号辅助代理。

## 1. 新证据、授权和历史处置

Owner已批准readiness选项1，并在本轮补充：Containers-DisposableClientVM为Enabled；Android SDK为`C:\Users\zcxve\AppData\Local\Android\Sdk`；用户级GRADLE_USER_HOME为`D:\GradleHome`；cache为`D:\GradleHome\caches`；JAVA_HOME为`C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot`。机器级ANDROID_SDK_ROOT指向上述SDK。

Owner另报告Android Studio位于`D:\Program Files\Android\Android Studio`、版本2025.3，旧工程Wrapper为8.14，指定Gradle home中有8.14/9.0.0相关cache和distribution目录。以上均记为OWNER-SUPPLIED HOST EVIDENCE，不冒充本轮实测；目录/版本名称不证明包完整、兼容或已映射到客体。旧工程版本不决定本次Flutter模块的Wrapper版本；不启动Android Studio，不访问旧仓库，不额外安装或改Wrapper。

上一轮M3-ISO-V02-001结果已由`a3736a0d4790fe5fcc01d27a4a8edf06f9162917`接受：功能查询权限不足、pub/M3均未启动、AAR未检查、隔离根未创建。该结果保留，不倒写、不恢复旧任务。此v0.2是基于新增输入的一次新执行合同，不是重跑旧one-shot；也不是再研究是否允许选项1。

本轮不再执行Get-WindowsOptionalFeature或DISM，不要求Owner重复证明Enabled，不把管理员查询作为启动门。采用Owner提供的功能状态，随后用本任务自己的受控启动及客体记录核验实际执行环境。不得自动提权、启用功能、安装软件或改用另一隔离产品。

## 2. 固定入口与精确项目输入

仓库：`zcx369658780/EliteSync-v10`。先实时读取远端main，要求恰为：

`a3736a0d4790fe5fcc01d27a4a8edf06f9162917`

FIRST主动读取该提交中的`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob `18485c95262051e43892436fb52413132c5ee626`。然后读取启动prompt绑定的本任务commit/blob，核验sole parent为上述main且只新增本任务路径。历史startup和旧基线不是本轮执行要求；自动加载与主动读取分开。

其余项目内容仅限下列固定main中的精确对象；按需要读取，不递归跟进引用：

| 路径 | 要求blob及用途 |
| --- | --- |
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`；现行工作规则 |
| `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | `ca1dba577e447a652173f2f3f35c1587fdc0b074`；待更新原文 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_1.md` | `57f4c975d439f9d4b0d53c56c5cb6e1b6f0a1d17`；上一轮实际边界和输入 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md` | `9466dba2800e12bf1f17414606e34af452134741`；已接受方法，不重做全套研究 |
| `apps/android/app/build.gradle.kts` | `a7e0f7583c801e2d56afc595d6c7bed84b5ce516`；仅direct AAR及defines解析合同 |
| `apps/android/gradle.properties` | `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`；仅flutterDartDefines键 |

本地根仅`D:\EliteSync-v10`。允许Git根/HEAD/origin元数据、精确固定提交可用性，以及必要时只fetch已声明main到显式任务ref；不checkout，不触碰默认index。源码输入固定为上述main的`apps/flutter_elitesync_module` Git对象快照，不从工作区、旧HEAD或旧仓库复制。本地HEAD只记录上下文，无须等于远端。

固定main、task或要求blob失配则停止其依赖步骤；保留已完成的合法结果，不自行换基线。

## 3. 直接绑定输入：不走旧的发现流程

| 输入 | 本轮字面宿主位置 | 证据和允许动作 |
| --- | --- | --- |
| Flutter SDK | `D:\flutter` | 上一轮执行者已定位；目录及`bin\flutter.bat`、`bin\cache\dart-sdk\bin\dart.exe`定点检查 |
| Android SDK | `C:\Users\zcxve\AppData\Local\Android\Sdk` | Owner本轮提供；只读目录检查及工具级复制 |
| JDK | `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot` | Owner本轮提供；目录及`bin\java.exe`定点检查；宿主不运行java |
| pub seed | `C:\Users\zcxve\AppData\Local\Pub\Cache` | 将上一轮LOCALAPPDATA默认来源按已明确用户路径展开；必须检查，不声称Owner本轮实测此字面路径 |
| Gradle cache seed | `D:\GradleHome\caches` | Owner本轮提供；只读目录检查及工具级复制 |
| Wrapper seed | `D:\GradleHome\wrapper\dists` | Owner给出的两个distribution目录的明确共同父路径；只读目录检查及工具级复制 |

不再检查或回退至`C:\Users\zcxve\.gradle`。不扫描cache版本/磁盘，不把8.14或9.0.0设成“必定兼容”。本轮工具/seed来源由上表固定，即使运行中的Codex尚未继承用户/机器环境变量也不重新判为路径UNKNOWN；只设置客体进程环境，不setx、不修改宿主变量。

允许一次定位当前正在使用的`git.exe`（Get-Command仅返回应用程序路径），用于Git对象物化和客体Flutter所需的Git工具。仅从该可执行文件的`cmd\git.exe`或`bin\git.exe`结构确定同一现有Git安装根，并定点确认；不搜索其他安装、不安装Git、不复制用户Git配置或凭据。结构不能明确则记录缺口，不猜根。此工具可只读映射并复制到客体，与其他离线工具一样不得联网。

所有输入和宿主输出根沿字面祖先检查reparse/symlink/junction；不跟随指向未授权位置的跳转。工具内部为复制读取目录项不是agent文件搜索授权；不输出SDK/cache/模块的全量路径清单，不分析其中业务内容。复制遇到无法安全处理的链接、锁定或读取失败，记录准确前置失败，不终止宿主已有daemon、不清理cache。

参数仍按已声明Gradle解析来源定点确定，但修正用户home：只读`D:\GradleHome\gradle.properties`中的flutterDartDefines键、固定项目blob的同名键，以及当前进程`ORG_GRADLE_PROJECT_flutterDartDefines`变量。无显式-P输入；同名冲突采用用户home属性、项目属性、环境变量的优先次序。三者均无值才按.orEmpty()得到EMPTY。仅按现有分号/逗号规则构造参数数组，不eval命令文本；不读其余属性、旧默认配置、shell/IDE历史。GitHub只记录来源/项数/非敏感键名，不输出敏感值。

## 4. 自有证据先落盘，源码输入不混入旧产物

Attempt ID：`M3-ISO-V02-002`。宿主专用根继续使用已批准的`D:\EliteSync-M3-readiness-v02`；guest根`C:\M3`。

在身份门通过后，先对专用根做精确存在性及安全路径检查。若已存在，停止物化/启动，不查看、覆盖、删除或换名绕过，报告ROOT CONFLICT。若不存在，可用独占创建语义建立根及`input`、`evidence`，立即写本任务自有`M3-ISO-V02-002-result.json`和`M3-ISO-V02-002-host.log`。这是对v0.1创建顺序的明确修订：后续任何前置失败也保留本地记录；根冲突或无法创建时只在GitHub报告中保留结构化结果。

允许在专用根编写本任务的manifest、m3.wsb、host/guest辅助脚本并作必要语法校对；它们不是产品实现，不写入原仓库。记录本次生成文件的哈希、完整调用数组、固定源码提交及输入映射；启动后不修改运行合同。

工具级物化只使用§2固定Git对象的精确模块前缀。机械过滤发生在材料进入输入副本前：排除模块内README类文件、FD02及已声明保护对象；排除旧build、.dart_tool、.android、.ios、.gradle、Git元数据、凭据/真实数据/运行日志。允许为这次复制/排除生成内部manifest，禁止借机搜索或总结源码、读取默认index或其他目录。无法保持排除则停止，不把复制权限当排除豁免。二进制归档必须按字节处理，不经PowerShell文本管道转码；不允许路径穿越或绝对路径解包。

输入副本不含旧build/AAR，因此后续命中不会仅仅来自复制来的旧产物。构建仍以过滤后的固定快照为范围，不声称其内容等同未过滤的全仓。模块自身缺源码或依赖指向未批准的外部目录时，报告输入缺口，不自行扩展。

## 5. 一次受控Sandbox启动与客体准备

m3.wsb必须显式设置Networking、ClipboardRedirection、AudioInput、VideoInput、PrinterRedirection为Disable；不使用默认联网配置。vGPU可设Disable；不变更宿主安全/虚拟化配置。

只读映射仅有：专用input、§3六个工具/seed根及明确解析的Git安装根。全部映射到`C:\M3\seed`下各自具名子目录；唯一可写宿主映射是`D:\EliteSync-M3-readiness-v02\evidence`→`C:\M3\evidence`。不映射整个D盘、原仓库、用户主目录、D:\GradleHome根、旧仓库或真实数据目录。

启动前定点解析自有XML并核对准确映射、只读属性和禁网项，记录配置哈希。用该文件的系统关联/当前Windows Sandbox启动入口启动一次；不使用RunAs，不先运行需提升的功能查询。启动失败就记录真实错误，不默认归因于功能Disabled，不启动默认Sandbox替代。

LogonCommand仅运行自有guest脚本。脚本先回传本attempt标识/启动nonce和客体就绪记录；通过客体只读网络接口/默认路由状态查询确认没有可用的外部网络接口/默认路由，不ping、DNS或HTTP探测。配置核验与同次启动的客体结果共同作为控制证据；Owner Enabled本身不是该证据。控制不符或无法确认则不运行工具。不得通过对只读宿主映射试写来验证权限。

输入通过后将模块复制到`C:\M3\work\apps\flutter_elitesync_module`；Flutter/Android/JDK/Git复制到`C:\M3\tools`下独立目录；pub复制到`C:\M3\pub-cache`；仅caches和wrapper\dists复制到`C:\M3\gradle-home`。不要复制Gradle顶层properties/init.d/credentials/daemon状态或宿主用户Git配置。工具发行内容和必要Flutter SDK元数据仅供工具固有读取，不用于agent分析。

客体环境显式绑定：FLUTTER_ROOT=`C:\M3\tools\flutter`、JAVA_HOME=`C:\M3\tools\jdk`、ANDROID_HOME及ANDROID_SDK_ROOT=`C:\M3\tools\android-sdk`、PUB_CACHE=`C:\M3\pub-cache`、GRADLE_USER_HOME=`C:\M3\gradle-home`、TEMP/TMP=`C:\M3\temp`；PATH只用客体系统目录及这次具名工具。允许在客体新建最小Gradle属性org.gradle.daemon=false及org.gradle.java.home指向客体JDK；不导入宿主配置。Flutter使用客体SDK而非宿主绝对路径，不改原local.properties。

专用客体内允许工具必要的cache、生成平台状态、临时文件和用户状态读写；宿主seed始终只读。启动Windows Sandbox自身可能产生Windows运行时状态，不声称全宿主绝对零写入；不得因此修改项目或seed。

## 6. 准备与构建合为一次工作，不在每步重新审批

客体内可执行一次`C:\M3\tools\jdk\bin\java.exe -version`记录实际版本，不能由目录名代替实测。其他宿主/客体doctor、升级、安装、预下载、额外测试均不运行。

前置采用一次Flutter-aware离线准备，替代v0.1的裸dart pub get：

`C:\M3\tools\flutter\bin\flutter.bat pub get --offline`

cwd=`C:\M3\work\apps\flutter_elitesync_module`，超时上限10分钟。该步骤允许在客体生成.dart_tool和模块.android状态，避免只解析Dart包却漏掉Flutter平台生成。它不是全进程禁网保证，外部网络仍由Sandbox阻断。SDK bootstrap或依赖需要下载时不得放行；失败/超时后不改用dart或另一条pub命令重试。

pub成功后，只有工具副本、客体控制及本次manifest全部就绪才运行唯一M3：

`C:\M3\tools\flutter\bin\flutter.bat build aar --no-debug --no-profile --no-pub [按§3绑定的参数数组]`

相同cwd；顶层生成上限30分钟。参数数组为EMPTY时不追加defines，不把方括号占位符当字面参数。不得篡改项目Wrapper/源码以迎合8.14或9.0.0，不调用syncFlutterAar或宿主Gradle。不得在宿主运行Flutter/Dart/Java/Gradle，或借宿主daemon/代理联网。

guest脚本在每个阶段启动前写started标志，防止LogonCommand重入使同阶段重复运行。pub及M3各至多一次；允许工具内部正常子进程，但不允许agent换命令或改代码重试。超时应终止本任务拥有的客体进程树并记录，不按名字杀宿主进程。用该任务的有限监视/日志读取收尾，不留无限后台等待；无终态时报告TIMEOUT/INTERRUPTED/INDETERMINATE。

任何复制/初始化/权限/缺包错误按其真实阶段报告；wrapper可能因离线缺分发包失败，即使名称相近的目录存在也不能宣称充分。预备脚本返回0不等于子命令成功，必须保存实际exit code和异常。

## 7. 新鲜产物与完整失败记录

所有记录留在`D:\EliteSync-M3-readiness-v02\evidence`，以M3-ISO-V02-002区分：result.json、host.log、guest.log、manifest/配置哈希及阶段结果。初始化时pub_started/m3_started=false、exit=null、aar_result=NOT_CHECKED；每阶段按真实结果更新。仅轮询自身结果标志不计作AAR探测，也不授权扫描其他目录。

只有M3实际启动后，允许对以下唯一guest定位符做一次存在性检查：

`C:\M3\work\apps\flutter_elitesync_module\build\host\outputs\repo\com\elitesync\flutter_elitesync_module\flutter_release\1.0\flutter_release-1.0.aar`

命中才记录size/SHA-256。未运行M3时不探测、保持NOT_CHECKED；未命中不能扩展路径寻找替代。可将本次生成的`build\host\outputs\repo`工具级复制到`evidence\maven-repo`；不浏览其余生成文件，允许校验复制出的同一AAR哈希以确认传输。该复制品是后续M2候选输入，不是M2执行或证明。

只有M3 exit=0且exact AAR HIT，同时有固定输入和本次控制证据，才报告`M3 GENERATION + RELEASE-AAR PRODUCTION EVIDENCE = HIT FOR M3-ISO-V02-002`。AAR哈希不证明它可安装或集成正确；旧M1证据根和耗尽lane不变。

失败也保存本任务已有日志，不清理宿主根/cache，不擅自导出全部客体。关闭临时客体前先保存许可证据；未保存状态可能消失，不能宣称可恢复。敏感值不得进入GitHub报告，日志/AAR不自动上传；发现意外secret只报告风险和脱敏摘要。

## 8. 两个候选文件与一次验收

只允许：

1. 新增`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_2.md`。
2. 更新`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`页首、§1、§4、§5及本attempt状态；§2/§3/§6/§7保持原文。分开记录001已接受的历史失败、Owner本轮补充、002实际结果；历史保护文字用明确本次授权说明，不倒写历史。

输出标记`PROPOSED — AWAITING INDEPENDENT REVIEW — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`。报告先给真实结果，再给来源层级、环境绑定、隔离证据、命令/exit/异常、AAR/复制证据、剩余最小问题及未执行事项。未查证的model ID、完整加载链、cleanliness不补写。

候选分支：`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-2`；subject：`docs: record M3 isolation attempt with supplied environment inputs`。一个候选commit，唯一父为本任务commit，只改上述两个路径。用GitHub Git Database/连接器发布，不操作本地index。分支/新产物冲突不覆盖或换名绕过。

发表前核验main和task ref仍为绑定值；变化则保留证据和草稿，不发布过期候选、不自行重定基线。发表后一次检查父子关系/两个路径/两个blob，内容或实际差异有问题才定点复查。执行者发表后停止，不自我接受、不更新main、不发M2、不更新项目源。

后续独立ChatGPT验收可沿用既有精简约定，以同tree单父接受commit记录候选/两个blob/证据限制；main仍匹配时非强制快进，不另外生成closeout。只有证据和既有权限支持时才在同轮续发下一任务；下载、安装、新产品实现及其他特殊范围不从成功结果自动推导。

## 9. 官方依据与未改变的边界

作者于2026-09-07定点核验下列官方主题，执行者仅在解决本合同具体问题时使用，不重新研究全部方法，不运行网页示例的安装或升级命令：

- https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file ：自定义.wsb、禁网、只读映射和LogonCommand；默认配置联网，不能用默认启动替代。
- https://docs.flutter.dev/add-to-app/android/project-setup ：Flutter模块.android由Flutter pub get/build生成，本次只允许客体生成；AAR输出不是完整App。
- https://dart.dev/tools/pub/cmd/pub-get ：offline依赖已有缓存，仍可能写lock/package配置。
- https://docs.gradle.org/current/userguide/directory_layout.html ：GRADLE_USER_HOME及cache/wrapper状态；配置位置不证明兼容。
- https://docs.flutter.dev/install/manual ：Windows Flutter工具依赖现有Git；本任务不安装Git。

本文在Owner已批准的隔离证据范围内修正输入和准备步骤，不选择新的产品架构。README预算耗尽、FD02永久排除、无旧仓库访问/全仓枚举；受保护无关staged state不得检查、修改、引用、总结或使用。物化/复制仅是明确范围的工具固有操作，不授权额外agent源码分析。

原D:\EliteSync-v10内容、宿主SDK/cache、用户配置不写；允许的Git对象/ref传输与GitHub报告发表是宿主文档/固定输入通道，不是客体构建联网授权。所有构建/包解析仅在禁网客体内进行；无依赖下载、软件/系统功能启用、凭据/生产访问或真实用户数据活动。

D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、PUI deferred/PUI-PREREQ-12=0、accepted legal/Safety/no-processing不变；LC-03/LC-04/Phase36及产品实现未授权。M2继续deferred，001不重跑，002完成即停止。
