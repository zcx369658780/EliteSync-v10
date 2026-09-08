# EliteSync v10｜已验证派发接入与条件式隔离 M3 v0.6

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO EXECUTION UNTIL SECTION 1 APPROVAL`
日期：2026-09-08（Asia/Singapore）。默认主执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium。规划与独立验收由 ChatGPT 会话承担；本任务没有模型升级例外，不改模型配置、不默认调用辅助代理。

## 1. 激活条件、目标和停止点

批处理派发候选 9765e4b2e9f93445142f6538dfabcaffc894d538 已由 A 接受，结论为 `DISPATCH REPAIR VERIFIED — SYNTHETIC ONLY`。报告中有可复用代码、同一 ProcessStartInfo 边界的六组通过记录及最小补丁绑定。它不是实际 Flutter/pub、M3、AAR 或 M2 证据。005 的复制成功是历史执行证据，已关闭的客体不是可继续运行的环境。
本文件发布属于已授权任务编写；执行尚未获准。先前进程 RemoteSigned 明确只限 v0.5，不自动续期。须由 Owner 在本会话或本地 Codex 的直接指令中，明确批准本 v0.6 固定任务及下列完整范围，才可开展任何本地步骤：
> 批准执行本 v0.6 任务；仅在本任务专用宿主自测和沙箱客体入口进程使用 RemoteSigned，按冻结脚本路径、哈希和生命周期运行；不改 CurrentUser/LocalMachine、组策略、信任或来源标记，不提权、不使用 Bypass/Unrestricted。批准在既定父根中新建 006 子工作区，先接入并验证派发，再进行一次禁网隔离准备、一次离线 pub 和条件式一次 M3；其余数据、网络、宿主输入只读和产品实现边界不变。
Owner 可将绑定本任务 commit/blob 的批准与启动指令一次发给 Codex；无需先返回 ChatGPT 取得第二次相同批准。执行者记录这一直接指令的批准文本与可见时间，不伪造批准提交。没有明确批准只报告 WAITING OWNER ACTIVATION，不创建目录、不运行自测/策略进程/复制/构建；任务存在和接受前次报告都不是激活证据。
激活后一次完成修复接入、实际执行和报告；不要只交付新计划。不重开策略、Git、长路径或派发方法调查，不把普通自有脚本错误转交 Owner。确有新增权限、系统拒绝或真实依赖问题时保留准确结果。本任务既不授权 M2，也不授权 App/Backend/Database 产品实现。

## 2. 固定 main 与精确仓库输入

仓库：`zcx369658780/EliteSync-v10`。实时读取 main，必须恰为 A：`f3430901bdc06607d5506a90b69988de24ee353f`。
FIRST 主动读取 A 中 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob `18485c95262051e43892436fb52413132c5ee626`。旧 startup 不执行；自动加载与主动阅读分开。随后读取启动指令绑定的本任务 commit/blob，核验唯一父 A、只新增本任务。失配停止依赖步骤，不自行换基线。
其他仓库输入仅限 A 中下表；不递归跟进引用，可读取 A 接受提交消息：

| 精确路径 | 要求 blob / 用途 |
| --- | --- |
| AGENTS.md | f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1；现行通用规则 |
| docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md | e4b386e8cc59f42970110b34be099738a8d6f22c；指定章节更新对象 |
| docs/architecture/ELITESYNC_V10_M3_CMD_DISPATCH_REPAIR_RESULT_V0_1.md | d1b0fd080665df717b237de44ad47b6285289ace；已接受修复代码与支持域 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_5.md | f5927cc0a5672208eec457a65e89959a8bcac124；005 脚本、成功准备和派发失败来源 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_5.md | ee9a9a26406bb5a95059171250f552036721f06c；仅 §3–8 已有运行控制，明确差异以本任务为准，不复跑005 |
| apps/android/app/build.gradle.kts | a7e0f7583c801e2d56afc595d6c7bed84b5ce516；仅 direct AAR/defines 合同 |
| apps/android/gradle.properties | f0a2e55f89e383466d2c6b481c8c468a3aa0b13d；仅 flutterDartDefines 键 |

本地 D:/EliteSync-v10 仅允许 root/HEAD/origin 和 A 固定 Git 对象可用性元数据。必要时只 fetch 声明 main 至 refs/elitesync/m3-iso-v02-006-input，禁 tags/submodule 递归；对象/ref传输不授权工作区或默认 index 操作。HEAD仅记上下文，不要求等于 main；不 status、pull、checkout、switch、reset、stash、clean 或 worktree 创建。

## 3. 旧来源与新的自有工作区

批准父根仍为 `D:/EliteSync-M3-readiness-v02`。激活后独占新建 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-006`，Attempt=`M3-ISO-V02-006`；仅在 W 写 input、scripts、scratch、evidence、m3.wsb 和本任务自产文件。先定点检查字面祖先和目标无未授权跳转。W 已存在则不覆盖、不删除、不换编号规避；保留已有证据并报告冲突。立即初始化 result.json/host.log，默认真实 pub/M3 未运行、exit=null、AAR=NOT_CHECKED。
旧 001–005 和诊断全部只读保留；无需重验全部历史。仅按需要采用以下精确来源，首次及结束各核对其 SHA-256，不执行原文件：

| 精确本地来源 | SHA-256 |
| --- | --- |
| D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005/scripts/guest.ps1 | 701405E5B5FF33E542FB539C1EA7D6AC5D5F30B40B97EC2C998F0FF288BA52CB |
| D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005/scripts/copy.ps1 | C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC |
| D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005/scripts/host-selftest.ps1 | 4907E638B03A1717D215546621603BDA11DD78A28CEA11094403A7F3162AA8A8 |
| D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005/evidence/result.json | 04578F2DFD5294992E586CDB6F6A5185C94749A11D2F27000960C4FBD99DC928 |
| D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001/draft/dispatcher-snippet.txt | 9CC6B72536D21119B01E2AEBA925DAD9A60D96C6DF97A931BDFCEFCD5485A894 |
| D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001/draft/dispatch-repair.patch | 4F0532B9A632B2747E90F6E80FC26C2F85AF5F884FB5C0DA8964DE8FE009350A |
| D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001/evidence/test-results.json | 8E9BE24817C722F6FC54E3F162F75D526DCFA4C2A398EBE5AA7E986BCC3BBC5A |

本轮明确允许审阅这些自产脚本/补丁，限派发接入、copy/Job/期限/策略控制和日志，不扩大产品源码分析。缺失/不符停止依赖该来源的复用并说明，不搜索替代、不改旧证据。若仅本地snippet/patch缺失，可从A中已接受报告的完整代码构造新修订，须披露未采用该本地字节版本；005基本脚本来源无法绑定则不假称原控制已保留。
新可执行 ps1 只限 W/scripts/copy.ps1、host-selftest.ps1、guest.ps1，和必要时独立的 dispatch.ps1；guest/copy/dispatch 的部署副本只在 W/input/runner 下同名。可创建 W/scratch 中只回显参数/cwd/nonce及返回码的 .cmd/.bat 假目标。不执行旧 helper，不复制重写被标记载荷以消除来源约束；精确脚本的 Zone.Identifier 仅提取 ZoneId，缺流/被拒分别记录，不读 URL、不删标记。

## 4. 接入已验证修复，先验证集成边界

只改 cmd 派发构造、准确错误分类和必要的006路径/日志标识。保留005的正常 exe 分支、ProcessStartInfo、原始输出重定向、期限、Job/StopChildren和关闭控制；不要重写复制器、策略bootstrap或全部runner。修复代码从接受报告/绑定补丁取得，不凭记忆重造转义器。
批处理使用固定 cmd.exe 与 `/d /s /v:off /c`，路径及每项参数独立引用、再加单层外部引号，整体直接赋给 ProcessStartInfo.Arguments；不能再次经过普通exe逐项引号序列化。记录 FileName、最终 Arguments、cwd和调用状态。已支持域之外的引号/换行/NUL/百分号或shell控制字符在进程创建前拒绝，不能删除字符、丢defines或换构造偷偷执行。非空准确batch路径必须绑定；EMPTY defines 为零个追加参数，不生成空占位参数。存在性布尔值、wrapper exit和原生工具输出各自保留。
在真实工具复制前，用新runner将实际采用的同一 RunNative/RunBatch 构造与ProcessStartInfo边界执行最小集成测试：pub形状、M3形状、空格路径/cwd、单个含空格合成define、目标exit37和不存在目标；通过标准仍为精确参数/返回码，负例被正确记录即PASS，不误抛成整项失败。危险字符只内存测试，不执行注入。已接受六组不要求重做研究，这一遍用于验证补丁确实接入本轮runner，而非只在独立测试器中通过。
宿主集成测试在专用RemoteSigned自测进程、W/scratch假目标中运行；不运行真实工具。新host-selftest正常加载同一绑定copy/dispatch函数及本次受限进程适配，不能在宿主调用guest主流程。guest准入后先用冻结的同一派发器执行pub/M3形状的假目标冒烟，必须在复制SDK前通过。假ENTERED永不写成真实Flutter/pub启动。
复制算法未改变时引用005长路径自测结果，不重新开发或重跑全套长路径矩阵；若接入确实改到了复制路径处理，则在同一任务合成样本中作受影响回归。只为W路径/attempt配置作参数化，不回写005。
宿主准备可对具体自产逻辑/语法/序列化缺陷最多纠错两轮；先保存版本/原值，上一轮进程与子进程结束后再修改并固定新hash。每个自测进程至多180秒、最多三个；每个假目标10秒。已通过且不受改动影响的测试不重跑；真实策略/签名/hash/身份拒绝不能作为脚本bug绕过。guest启动后不热改冻结文件、不换命令重试。

## 5. 脚本绑定与有限进程策略

本节仅在§1获批后生效。沿用已验证v0.5过程：各自System32/WindowsPowerShell/v1.0/powershell.exe，普通调用，`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command <短bootstrap>`。仅专用宿主自测与guest任务入口使用，不设置整个Codex/普通编排环境，不调用Set-ExecutionPolicy、不手动改策略环境键。
bootstrap正常显式导入当前PSHOME下精确Microsoft.PowerShell.Security.psd1，只核对Name/精确Path；ModuleBase/Version只记录，不增加错误相等守卫。同进程保存scope/effective，要求Process及effective=RemoteSigned。此为新进程控制确认，不是再次开展策略调查。真实管理/签名/应用控制拒绝即停止，不改低scope、换运行时、直接DLL或升级到Bypass。
每个新脚本先进行PowerShell 5.1语法校对和必要差异审阅，记录绝对路径/SHA-256/长度/角色/嵌套加载与原生命令图。预期hash来自启动前冻结的值；每次加载前核对准确文件/hash/安全属性，正常 & 或dot-source，部署副本字节一致并保留来源标记。哈希由实际生成后固定，不伪造预知值，不要求Owner逐个重批。
不得加入Bypass/Unrestricted、Unblock、NoExit、RunAs，不修改CurrentUser/LocalMachine/组策略/信任/LongPathsEnabled/安全软件或模块路径。遇到工具需要未批准运行条件，仅报告具体冲突，不改SDK或放宽策略解决。RemoteSigned不是每文件白名单，不是技术沙箱；所有可能继承环境的任务子进程必须在期限内退出。
宿主临时输出限W/scratch/tmp；只在专用子进程设置TEMP/TMP。允许已有Add-Type/PInvoke用于本任务自测/Job，不安装库。结束后从未调整的宿主编排上下文作一次无ExecutionPolicy参数的正常scope/effective对照，仅记录，不通过重写设置“恢复”。收尾采证失败不覆盖已发生的真实构建exit。

## 6. 固定输入、一次禁网客体与有时限准备

源码仅为A的apps/flutter_elitesync_module Git对象的过滤快照：排除README类、FD02、旧build/.dart_tool/.android/.ios/.gradle、Git元数据和既定保护/凭据/真实数据/日志对象；机械物化按字节、拒绝路径穿越/未授权链接，不分析业务源码、不用工作区或旧仓库。新runner是自产辅助输入，不混称为A源码。文件数不设额外成功门。
具名输入和映射如下；只做必要路径/祖先安全与可读性复核，不搜索磁盘或SDK/cache版本：

| 宿主只读输入 | guest只读映射 | guest可写副本 |
| --- | --- | --- |
| W/input | C:/M3/s/in | 模块 C:/M3/w/apps/flutter_elitesync_module |
| D:/flutter | C:/M3/s/f | C:/M3/t/f |
| C:/Users/zcxve/AppData/Local/Android/Sdk | C:/M3/s/a | C:/M3/t/a |
| C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot | C:/M3/s/j | C:/M3/t/j |
| C:/Program Files/Git | C:/M3/s/g | C:/M3/t/g |
| C:/Users/zcxve/AppData/Local/Pub/Cache | C:/M3/s/p | C:/M3/p |
| D:/GradleHome/caches | C:/M3/s/h | C:/M3/h/caches |
| D:/GradleHome/wrapper/dists | C:/M3/s/d | C:/M3/h/wrapper/dists |

Android Studio不在输入内。不得重新发现Git、查询Windows feature、回退旧.gradle/旧仓库或为了缓存改Wrapper。defines仅读取D:/GradleHome/gradle.properties的flutterDartDefines键、固定项目同名键、当前ORG_GRADLE_PROJECT_flutterDartDefines；沿用用户home→项目→环境优先序和已记录分号/逗号解析。只处理该键，不读其他属性，不输出secret。不支持的实际参数先报告UNSUPPORTED_ARGUMENT，不能等复制后才发现或擅自丢值。
W/m3.wsb仅启动一次：Networking/ClipboardRedirection/AudioInput/VideoInput/PrinterRedirection/VGpu显式Disable，表中八输入ReadOnly=true，唯一可写宿主映射W/evidence→C:/M3/e。XML/映射/runner/hash/完整命令先冻结。新nonce、客体接口/默认路由记录与本次启动对应；不继承005控制为006实测，不ping/DNS/HTTP、不试写宿主只读映射。不映射整仓、整个用户目录/GradleHome/父根/旧证据。
策略及隔离通过后先进行§4派发冒烟，再执行已验证复制方法。按v0.5固定robocopy基准参数 /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /MT:8 /XJ /SL /FP /BYTES /TS，每个根一次及独立UNILOG；不使用删除/移动/提权/自动重试选项。不跟随未授权reparse、默默跳过必要链接或省略文件后宣称完整。0–7结合copied/failed/mismatch/extras解释，>=8真实复制失败；不把1当失败。不导入宿主Gradle顶层properties/init.d/credentials/daemon、用户Git配置或旧产物。
只在guest设置PATH为系统及本次工具（含C:/M3/t/g/cmd和C:/M3/t/f/bin），FLUTTER_ROOT=C:/M3/t/f、JAVA_HOME=C:/M3/t/j、ANDROID_HOME/ANDROID_SDK_ROOT=C:/M3/t/a、PUB_CACHE=C:/M3/p、GRADLE_USER_HOME=C:/M3/h、TEMP/TMP=C:/M3/tmp。guest Gradle新属性仅daemon=false及java.home指向该JDK；不写宿主环境/cache。复制后guest Git --version及java -version各一次。
005已报告正常关闭，不尝试恢复临时副本、不因窗口历史做全局进程扫描。实际新会话冲突如实报告，不关闭无法证明归属的其他窗口。
就绪nonce等待最多5分钟；guest就绪后的准入、冒烟、复制及工具验证合计30分钟；每30秒只监视本次阶段/日志增量，5分钟无可证进展记PROGRESS_UNCONFIRMED并作一次已归属进程观察，不延长总时限。不刷重复消息，不以pub/M3未计时无限等待。

## 7. 真正的pub和M3：一次执行，真实分类

guest cwd固定 `C:/M3/w/apps/flutter_elitesync_module`。使用§4已通过接入的RunBatch和同一ProcessStartInfo边界，不另造生产调用字符串：
1. 精确batch `C:/M3/t/f/bin/flutter.bat`，参数数组 `@('pub','get','--offline')`，最多一次派发，最多10分钟。
2. 仅真实pub成功后，同batch，`@('build','aar','--no-debug','--no-profile','--no-pub')`加已绑定defines数组，最多一次派发，最多30分钟。宿主不运行Flutter/Dart/Java/Gradle。
在实际调用前记录最终exe/Arguments/cwd、dispatch_started及固定脚本版本；真实工具entry单列CONFIRMED/NOT_ESTABLISHED及依据。wrapper退出0本身不证明依赖解析或M3成功。保留工具原始stdout/stderr字节、实际exit及初始化/依赖诊断，不向真实SDK添加假ENTERED标记，不改产品源码或SDK来凑证据。
分类必须区分：DISPATCH_FAILURE（Process.Start/目标/引用错误）、COMMAND_FAILED（已有工具入口证据后的非零返回）、ENTRY_INDETERMINATE（入口证据不足）、TIMEOUT；只有真实缺包/解析诊断支持时才标OFFLINE_PUB_INSUFFICIENT。宿主评注和原始日志分开，不倒写原始异常名称。不得因非零返回自动安装/联网/补包/修系统或重试。派发预算不是自动恢复规则，005失败不倒写成真实pub执行。
仅本次M3实际启动后允许一次精确AAR检查：`C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。未启动保持NOT_CHECKED；HIT记录size/SHA-256，NON-HIT只解释该次定位符，不找替代。可将本次build/host/outputs/repo工具级导出到W/evidence/maven-repo并核对同一AAR传输hash。只有M3 exit=0、exact HIT、固定输入和本次隔离证据齐全，才记006生成证据HIT；仍不等于M2或App可安装。
保持已有Job/进程树期限控制；timeout只结束任务拥有的树，不按进程名杀其他会话。导出与收尾最多5分钟；保存任务子进程均结束证据，确认本次Sandbox创建时间/父链后可正常关闭。不能确认结束则如实INDETERMINATE，不宣称策略生命周期结束。保留host证据，不承诺未导出guest副本持久存在。

## 8. 交付、一次验收与下一决定

本地W/evidence保存实际发生的授权激活、脚本/部署hash与差异、集成冒烟、策略/nonce/隔离、每项复制摘要与原生日志、最终OS命令字符串、工具原始字节/exit/entry判据、AAR和进程关闭、旧来源保护。日志只追加，结果JSON用序列化/反解析，路径优先盘符正斜杠，结构化文本UTF-8；其他编码保留原字节并声明解码方法。敏感defines不进入GitHub；不上传SDK/cache/源码/二进制或全部本地日志。未发生阶段不伪造文件。
GitHub仅一个候选commit，唯一父为本任务commit，分支 `review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-6`，subject `docs: record dispatcher-integrated offline M3 attempt`。恰好两个目标：
- 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_6.md`。
- 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7原文保持。用当前状态段注明默认GPT-5.6 Sol Medium及ChatGPT规划/验收分工，不为该规则改写保护章节或AGENTS。分开记录005、合成修复已接受、Owner006激活和006实测。
使用GitHub Git Database/连接器，不本地commit/index。发布前一次核验main/task仍匹配；变化保留本地证据及草稿，不自行rebase。发布后一次核对单父/两路径/blob；不因无变化反复验。完成后不自我接受、不更新main、不M2、不另发任务、不更新项目源。独立接受可同tree单父提交，不新增closeout。
成功则下一项围绕新增AAR准备独立M2合同；失败只汇总当前真实阻塞和需要的精确改变，不自动再次发布仅改编号的全量复制任务，不把开发推进等同文档数量。持久环境、宿主构建/cache写入、下载或产品实现仍属额外范围决定。

## 9. 外部机制和不变边界

作者2026-09-08定点核验 https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmd 及 https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.processstartinfo.arguments?view=netframework-4.8.1 ；它们支持cmd引号与单字符串参数机制，不证明本机工具运行成功。其他已有隔离/RemoteSigned/复制机制以v0.5已列官方来源为限按具体问题核对，不重新开展广泛研究。报告中的源码、合成测试、外部机制和未验证推断须分开。
除§1批准后生效的本任务专用运行条件外，不改系统策略/信任/模块路径/安全产品，不解锁或绕过来源签名，不安装/联网下载、不真实数据或生产访问。标准系统加载/Sandbox运行可能产生系统运行记录，不宣称全宿主绝对零写入；原仓库内容、宿主SDK/cache与用户配置不写。
README预算耗尽、FD02永久排除、旧D:/EliteSync及zcx369658780/EliteSync不访问；不仓库/目录agent枚举，受保护无关index/staged state不检查/修改/引用/总结。M1历史lane耗尽，不重试。D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、PUI deferred/PUI-PREREQ-12=0、legal/Safety/no-processing保持；LC-03/LC-04/Phase36及产品实现未授权。M2 deferred，AGENTS与ChatGPT项目源不修改。
