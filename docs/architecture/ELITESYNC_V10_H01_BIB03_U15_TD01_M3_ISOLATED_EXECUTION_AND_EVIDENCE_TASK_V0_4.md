# EliteSync v10｜长路径复制修复与有时限的M3隔离执行 v0.4

Status: `TASK ONLY — OWNER OPTION 1 CONTINUES — COPY REPAIR + CONDITIONAL M3 — NO PRODUCT IMPLEMENTATION`
日期：2026-09-07（Asia/Singapore）。简体中文；Owner选择实际模型，不改模型配置、不默认调用其他型号辅助代理。

## 1. 目标与已完成事实

003候选99730a363a44c2010ed5fd4361cced0484d9a45d已由89d1f091d45b472bd286628942181d7a3647d0c2接受，接受的是有限执行记录，不是复制器正确或构建成功。宿主Git根已绑定；003固定输入与当次隔离控制有执行者证据；自有CopySafe/CreateDirectory出现长路径异常，具体失败源/目标和seed未知。pub/M3各0次，AAR未检查。

本任务依据Owner选项1及可逆工作自动续发授权，修复自有复制/日志实现，在同一批准宿主根新增004工作区，条件满足即继续一次离线pub和一次M3。不再研究是否批准选项1，不重找Git、不要求Owner修改系统。不复跑003、不复用其客体局部副本。当前任务明确替换旧的CopySafe实现、准备阶段无具体时限及路径输出方式；不扩大宿主源/cache写入、网络、产品实现或数据权限。

## 2. 固定入口与读取范围

仓库zcx369658780/EliteSync-v10。先实时读取main，必须为89d1f091d45b472bd286628942181d7a3647d0c2（下称A）。FIRST主动读取A中的转型交接：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob 18485c95262051e43892436fb52413132c5ee626。
随后读取启动prompt绑定的本任务commit/blob，验证唯一父A和单一路径新增。失配停止依赖操作，不自行换基线或回退历史main。

A中其余项目输入仅限：
| 精确路径 | blob与用途 |
| --- | --- |
| AGENTS.md | f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1；规则 |
| docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md | 4cc13077cae6cfc0e87f6b68306ff08618b2d1c5；限定更新对象 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_3.md | 0a814b8ae92497f4927d6aea13cba74bec6c0d6d；003事实和本地证据哈希 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_3.md | 01dc74cb1b4cfd6d11b79a61a00e1a44b52f7d75；§3历史保护、§6–7既有隔离范围，本合同差异优先 |
| apps/android/app/build.gradle.kts | a7e0f7583c801e2d56afc595d6c7bed84b5ce516；只解析direct AAR/defines合同 |
| apps/android/gradle.properties | f0a2e55f89e383466d2c6b481c8c468a3aa0b13d；仅flutterDartDefines键 |

本地D:/EliteSync-v10只允许根/HEAD/origin元数据和A固定对象确认；必要时fetch声明main到refs/elitesync/m3-iso-v02-004-input，--no-tags/--no-recurse-submodules。HEAD只记上下文；不status/index/checkout/pull/reset/stash/clean。构建输入仅为A的apps/flutter_elitesync_module Git对象，按003相同排除规则机械物化，不分析业务源码。宿主GitHub/固定对象传输是发布与输入通道，不是构建联网许可。

## 3. 保留旧证据，直接绑定输入

批准父根D:/EliteSync-M3-readiness-v02。003的W3=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-003。004的唯一新工作区W4=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004，attempt为M3-ISO-V02-004。

先安全检查字面祖先并只读核对W3/evidence中M3-ISO-V02-003-result.json、guest.log、git-binding.json、frozen-contract.json、isolation-control.json、sandbox-launch.json；哈希必须与003报告各项一致。可依据已核验frozen-contract中的精确路径/hash读取003自产guest复制helper，只用于修复实现；不猜文件名、不列目录。上述非terminal/哈希冲突停止其依赖续行，不改旧证据。002的两份证据按v0.3 §3既定定位符/hash在开始和结束各核对一次；所有002/003文件不写。003日志缺失的错误路径不得编造恢复。

W4不存在时独占创建input、scripts、scratch、evidence及初始化result.json/host.log；已存在就停止，不覆盖、不换编号规避。所有宿主新写入限W4；旧根其他内容不读。日志仅append，命令开始标志防重入；前置失败也落盘。

直接使用已绑定根，不重跑Get-Command或全局发现：
| 宿主只读输入 | 客体映射 | 客体可写工具副本 |
| --- | --- | --- |
| W4/input | C:/M3/s/in | 模块C:/M3/w/apps/flutter_elitesync_module |
| D:/flutter | C:/M3/s/f | C:/M3/t/f |
| C:/Users/zcxve/AppData/Local/Android/Sdk | C:/M3/s/a | C:/M3/t/a |
| C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot | C:/M3/s/j | C:/M3/t/j |
| C:/Program Files/Git | C:/M3/s/g | C:/M3/t/g |
| C:/Users/zcxve/AppData/Local/Pub/Cache | C:/M3/s/p | C:/M3/p |
| D:/GradleHome/caches | C:/M3/s/h | C:/M3/h/caches |
| D:/GradleHome/wrapper/dists | C:/M3/s/d | C:/M3/h/wrapper/dists |

仅作必要的字面路径/祖先安全与可读性检查；不扫cache版本。Git以003原始绑定作来源，客体副本随后自验。Android Studio不是输入，不复制/启动它。不给旧默认.gradle或旧仓库fallback。
defines仍只机械读取D:/GradleHome/gradle.properties同名键、A项目properties同名键、当前ORG_GRADLE_PROJECT_flutterDartDefines，优先用户home→项目→环境，均无值才EMPTY；不读取其他配置或secret。以数组传参，禁止eval拼接。

## 4. 先验证复制器，再复制真实工具

不再用旧CopySafe的未适配System.IO.CreateDirectory递归逐文件复制。以现有Windows系统robocopy.exe为批量复制器；本任务授权它在下面的合成自测和客体具名复制中使用，不下载、不改注册表/LongPathsEnabled、不全局git config、不提权、不改宿主或客体系统策略。

基准复制选项：/E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /MT:8 /XJ /SL /FP /BYTES /TS，每个copy_id独立/UNILOG文件。不得/256、/MIR、/PURGE、/MOVE、/MOV、/B、/ZB、/REG、/MON、/MOT，不使用长时自动重试。不得给真实seed加截断层数/按大小省略文件等规则来假装复制成功。参数数组必须保存，处理带空格路径。

robocopy返回1不能被泛化为失败；>=8属于复制失败，0–7仍需结合job摘要、失败数、mismatch/extras及预期新目标检查。新空目标的异常extras/mismatch不能无条件忽略。测试允许同时覆盖纯函数分类0/1/7/8/16，不把任何包装脚本exit当子进程exit。

安全链接处理属于复制器职责：/XJ和/SL防止默认穿越链接；复制前/过程中仅用支持长路径的native元数据操作识别reparse，不进入目标。发现需跟随的链接或无法安全处理的对象应记录具体相对路径并停止该输入；不能默默跳过必要链接后宣称完整。复制后的链接不得交给构建工具跟随。机械遍历仅用于本次具名复制与安全检查，不形成agent源码/cache清单或分析；正常文件列表留本地原生copy日志，不粘贴全量路径到聊天/GitHub。

Sandbox启动前在W4/scratch使用纯合成小文件测试，源和目的均为自有目录：总绝对路径>=320字符、各组件<100字符，覆盖长源、长目标、空格/中文、不存在源的失败记录。合成创建/校验使用支持扩展绝对路径的Win32 Unicode文件API；不把同一个会失败的旧CreateDirectory当自测生成器。只编写本任务helper（可用PowerShell Add-Type/PInvoke），不安装运行库、不触碰真实seed。校验已知短内容/哈希和实际复制exit，故意不存在源不得误报PASS。合成对象保留，不全盘搜索或清理。该自测不计为pub/M3尝试。

自测失败允许在W4内最多两轮针对具体缺陷修复后重测自有样本；通过才冻结脚本/配置。一次Sandbox内先运行同类小样本自测，客体失败则在真实工具复制前结束。不能因宿主自测通过就宣称客体必然支持。启动后不热改冻结脚本，不换实现重跑真实复制。

## 5. 准备进度、错误路径与明确时限

每个copy_id必须落盘start和end、源根、目的根、当前阶段、原生命令PID/创建时间、完整调用数组、elapsed、exit、原生摘要中的copied/failed/bytes。无法取得某项写null并说明，不编百分比。异常记录原始exception/HResult/Win32错误及工具输出；自有守卫在调用前保存具体源/目标、字符串长度和当前操作。原生日志使用完整路径，诊断失败时仅抽取错误相关行，不只返回COPY或泛化异常。若工具仍未返回具体路径，如实保留未知，禁止扫描全seed倒推。

监视每30秒读取自身状态与当前copy日志增量；必要时读取本任务精确PID的I/O计数。心跳只表示控制器存活，不是复制推进。向Owner只在阶段变化、错误或持续无进展时更新，避免几十次重复“仍在COPY”。原生日志和计数无增量5分钟则标记PROGRESS_UNCONFIRMED并作一次精确子进程观察，不延长总时限。

明确上限：新Sandbox启动等待nonce最多5分钟；从guest就绪起，合成自测+所有真实复制+工具验证总计最多30分钟；pub最多10分钟；M3最多30分钟；证据导出收尾最多5分钟。达到本阶段上限，终止仅本任务拥有的客体子进程树并flush结果；准备超时=PREPARATION TIMEOUT，不是M3生成失败。不能因pub/M3尚未计时就无限等待COPY。不得按名字杀宿主其他进程。

## 6. 一次新Sandbox与条件式生成

只启动一次W4/m3.wsb。Networking/ClipboardRedirection/AudioInput/VideoInput/PrinterRedirection/VGpu显式Disable；上表8个输入ReadOnly=true，唯一可写宿主映射W4/evidence→C:/M3/e。XML、路径、参数、脚本hash在启动前冻结；新nonce和客体接口/默认路由记录必须对应004，不继承003控制结果为004实测。不ping/DNS/HTTP探测、不试写只读宿主seed，不使用默认Sandbox配置，不重查Windows feature或启用功能。

003脚本已终态不等于窗口已关闭。本任务不复用003 guest、不改其脚本/输入。如旧窗口阻止新会话，只有利用已核验003启动记录与同次进程创建时间/父链确认归属且terminal=true后，才允许向该确证旧会话发正常关闭请求；PID数字本身不足，不强杀/全局按名关闭。不能确认则报告具体会话冲突，不修改旧证据。关闭仅丢弃未承诺持久化的临时guest副本，不能删除宿主003 evidence。

模块只从A固定Git对象过滤物化；排除旧build/.dart_tool/.android/.ios/.gradle/Git元数据、README类、FD02、已声明保护/凭据/真实数据/日志对象，拒绝路径穿越。二进制按字节处理；不自行扩大到邻目录、旧仓库或工作区。无旧AAR输入才能将新命中与本次尝试关联。

guest先控制验证→小样本复制自测→按表复制（每个根一次，原生/R:0）→C:/M3/t/g/cmd/git.exe --version和C:/M3/t/j/bin/java.exe -version各一次。工具根/可执行检查仍不证明所有依赖充分。不得复制宿主Gradle顶层properties/init.d/credentials/daemon或用户Git配置。可写状态只在guest；复制器、链接守卫及日志统一支持长路径，不能仅把复制命令换掉而保留会失败的长路径前置遍历。

环境仅绑定guest：FLUTTER_ROOT=C:/M3/t/f，JAVA_HOME=C:/M3/t/j，ANDROID_HOME/ANDROID_SDK_ROOT=C:/M3/t/a，PUB_CACHE=C:/M3/p，GRADLE_USER_HOME=C:/M3/h，TEMP/TMP=C:/M3/tmp，PATH仅guest系统与具名工具。guest新Gradle属性仅daemon=false和java.home指向guest JDK。不改Wrapper或源文件迎合已有cache。

准备通过后连续执行，无中间审批：
1. C:/M3/t/f/bin/flutter.bat pub get --offline；cwd C:/M3/w/apps/flutter_elitesync_module；至多一次。
2. 仅pub成功后，C:/M3/t/f/bin/flutter.bat build aar --no-debug --no-profile --no-pub，加冻结defines参数数组；同cwd；至多一次。

所有Flutter/Dart/Gradle/wrapper在禁网guest内；不联网补包、不安装/升级、不宿主构建、不M2。每阶段写started防重入，实际子进程exit单独保存。准备失败不运行pub；pub失败不运行M3。失败不热修产品源码、不换命令或重启guest继续。

## 7. 结果、产物与报告质量

W4/evidence保存result.json、host.log、guest.log、分copy_id原生日志、自测结果、输入manifest、冻结合同/配置hash、004控制记录和旧证据保护摘要。pub/m3未启动默认exit=null，aar_result=NOT_CHECKED。本地日志/源码/cache/AAR不自动上传GitHub，secret只做脱敏风险说明。

仅M3实际启动后一次检查：C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar。HIT才size/SHA-256；不搜其他路径。允许工具级导出本次build/host/outputs/repo至W4/evidence/maven-repo，并核对同一AAR传输hash，不扩大读取生成输出。只有exit=0+HIT+本次控制证据才报告004生成证据HIT，不等于M2成功或App可安装。旧M1不重试。

所有Markdown路径优先用带盘符的正斜杠形式并验证绝对路径；JSON必须用序列化器，发布前round-trip检查路径值，不能再因多层字符串转义丢失反斜杠。旧报告错误不倒写；新报告不将未选Git原始路径猜测复原。末尾定点核对已读取002/003证据hash不变；不清理任一host证据根。无法取得终态时如实INTERRUPTED/INDETERMINATE，不宣称后台已停止。

## 8. 唯一候选与结束

一个候选commit，唯一父为本任务commit；分支review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-4；subject为docs: record long-path copy repair and isolated M3 result。只新增docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_4.md，并更新CURRENT_CONTEXT页首/§1/§4/§5；§2/§3/§6/§7原文保留。报告必须区分003已接受历史、004自测与真实执行，不用文件数表示产品进度。

GitHub Git Database发布，不本地commit/index。发布前核验main/task未变；发布后一次parent/两路径/blob回读。分支/新报告冲突保留草稿，不覆盖。执行者发布即停止，不自我接受、不推进main、不M2、不更新ChatGPT项目源。后续验收沿用同tree接受commit，不另建closeout。

若复制已修复但仍在离线输入/工具初始化受阻，交付明确失败对象与证据；不得自动再发仅改编号的全量复制任务，也不为追求成功开放网络。需要新的持久环境、宿主写入、下载或产品实现时集中提出一次范围决定。

## 9. 官方依据和不变边界

本次定点核验（2026-09-07）：https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy 支持长路径（/256会关闭该支持）、/MT、/R、/W、日志及退出码；https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation 区分扩展路径、组件限制、应用manifest与系统策略。它们不能证明本机所有组件可复制；以小样本和本次结果为准。执行者仅按需读这两个主题及v0.3已列隔离/Flutter主题，不重开广泛研究。

README/FD02排除、禁止旧仓库/全仓agent枚举、受保护暂存状态、D-02/U-14/U-12/TP、Backend 0/10、Database 0/8、PUI、legal/Safety/no-processing全部保持。宿主SDK/cache/用户配置/原仓库内容不写；无安装、系统策略改变、外部构建网络、真实数据或生产访问。LC-03/LC-04/Phase36及产品实现未授权，M2仍deferred。当前改变是自有复制器、有限准备自测/诊断与deadline，不是架构重写。
