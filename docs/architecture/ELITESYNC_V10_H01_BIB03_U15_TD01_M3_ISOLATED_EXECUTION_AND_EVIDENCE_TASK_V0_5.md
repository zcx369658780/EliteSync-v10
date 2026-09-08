# EliteSync v10｜进程级 RemoteSigned、自测与条件式 M3 续行 v0.5

Status: `TASK ONLY — OWNER APPROVED PROCESS REMOTESIGNED — SELFTEST THEN CONDITIONAL OFFLINE M3 — NO PRODUCT IMPLEMENTATION`
日期：2026-09-08（Asia/Singapore）。简体中文；Owner在宿主选择模型，不改模型配置、不默认调用其他型号辅助代理。

## 1. 本次批准、目标与终点

Owner在当前会话明确批准：
> 批准下一张具名 M3 续行任务，在专用宿主自测进程和沙箱客体任务进程中使用仅进程级 RemoteSigned，限定准确脚本、哈希和进程生命周期；不改 CurrentUser／LocalMachine、组策略或信任设置，不提权、不使用 Bypass／Unrestricted、不解锁来源标记。自测通过后，在同一任务内继续已批准的离线隔离准备与一次 M3，保留原有数据、网络和写入边界。

这就是该具名任务。新增例外只限本任务的专用进程运行条件：以正常 PowerShell 启动参数指定 RemoteSigned，不改变持久策略。它明确替代旧任务对所有 Process 调整／ExecutionPolicy 参数的一概禁止；其余旧限制不变。不是对所有后续任务、整个 Codex 会话或日常终端的授权。

策略查询目标已由 A 接受并关闭：M3-POLICY-003 实测五个 scope 为 Undefined、effective 为 Restricted。无需重做诊断链、重新批准选项1或修复 Windows。003 的 Git 绑定和当次隔离证据、004 未执行自测均保留历史含义；长路径复制和离线依赖充分性仍未验证。

本轮直接完成：绑定并审阅自有脚本 → 有限生命周期的宿主自测 → 一次新 Sandbox 的策略／隔离验证及自测 → 工具准备 → 一次离线 pub → 条件满足后一次 M3 → 结果与产物证据。不得仅交付“策略已设置”或“自测计划”就停止。真实失败按阶段交付，不保证构建成功，不在此执行 M2。

## 2. 固定入口与精确项目输入

仓库 `zcx369658780/EliteSync-v10`。开始实时读取 GitHub main，要求恰为 A：
`0a7d18e762581a491bee253361cead56d49d47b0`。
FIRST 主动读取 A 中：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob `18485c95262051e43892436fb52413132c5ee626`。
随后读取启动 prompt 固定的本任务 commit/blob；唯一父 A，只新增本任务文件。旧 handoff 的 startup 不执行，已关闭的指令／策略诊断不重开。main/task/blob 失配停止依赖步骤，不自行换基线。

A 中其他项目读取只限下表，不递归跟进引用：
| 精确路径 | 要求 blob／用途 |
| --- | --- |
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`；现行规则 |
| `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | `f4a0ddca2ba12e58f88aa4f656fd0c65b9024c36`；本轮限定更新对象 |
| `docs/architecture/ELITESYNC_V10_M3_POLICY_QUERY_COLLECTOR_FIX_RESULT_V0_1.md` | `5a3d50fc4d5a27fa66a02ac7a9771a78b06f169b`；已完成策略快照 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_4.md` | `10b9cf14a78c20578c4d0f7d96340ec671565456`；004 helper 与证据来源 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_4.md` | `cb46cea5c9c5610d1771d96448c955d58c5218bb`；仅 §4–7 复制、自测、隔离、结果细节；明确差异以本任务为准 |
| `apps/android/app/build.gradle.kts` | `a7e0f7583c801e2d56afc595d6c7bed84b5ce516`；仅 direct AAR 与 defines 合同 |
| `apps/android/gradle.properties` | `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`；仅 flutterDartDefines 键 |

可读 A 接受消息。本地 `D:/EliteSync-v10` 只允许根／HEAD／origin 与 A 对象可用性元数据；必要时 fetch 声明的 main 到 `refs/elitesync/m3-iso-v02-005-input`，禁 tags／submodule 递归。源码只从 A 的 `apps/flutter_elitesync_module` Git 对象物化；HEAD仅作上下文，不要求等于远端，不 checkout/pull/reset/stash/clean/status，不读写默认 index。

## 3. 新工作区、旧证据及脚本来源

新 attempt：`M3-ISO-V02-005`。已批准父根不变。唯一新宿主工作区 W：
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005`。
先检查字面祖先无未授权 reparse／junction／symlink 跳转，W 不存在时独占创建 `input`、`scripts`、`scratch`、`evidence`；已存在则不覆盖、不清理、不换编号绕过。立即保存本轮 result.json／host.log；后续前置失败也必须有终态。

旧 001–004 与 POLICY-001–003 全部只读保留，不复跑、不复用其 input／阶段标志／不完整 guest。无需重新读取、逐项验收全部历史证据。仅核对本轮实际采用的两个来源：
- `D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-003/observation.json`，SHA-256 `E53D19BCFC78AF2A8DB2FE91D34D894C86B86BB22C662ED94A52802443FA1A56`。
- `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/scripts/copy.ps1`，SHA-256 `9177A1B3A713F1414E6846BCACAD77773CEFE19E24E5FBB81FC81E9A9C397CCD`。本轮明确允许只读审阅正文作复制器起点，不能直接执行旧文件或当成已验证实现。

来源缺失／hash不符不修改旧证据、不搜索替代；停止依赖该来源的使用并报告。本任务所用旧文件开始／结束各核对一次 hash 即可；其余历史不触碰。可只读提取上述精确脚本的 Zone.Identifier 中 ZoneId，不读取 URL 等字段；流不存在、拒绝与未知分开。不得通过复制、重写同一载荷或删 ADS 消除来源限制。

本轮可执行的自有 ps1 仅有：`W/scripts/copy.ps1`、`W/scripts/host-selftest.ps1`、`W/scripts/guest.ps1`，及后两项中 guest/copy 的精确部署副本 `W/input/runner/guest.ps1`、`W/input/runner/copy.ps1`。宿主其他编排用可审阅的普通命令，不另加未绑定的 ps1 入口。
执行者须审阅新脚本与旧起点的差异，确保仅为本任务复制、自测、阶段控制和记录；先做 PowerShell 5.1 语法校对，再记录准确路径、完整 SHA-256、长度、用途、允许进程、嵌套加载关系和原生调用。新脚本 hash 由本任务内实际生成后固定，不伪造预知 hash，也不要求 Owner 再逐个批准。每次允许的自测修复先保存原版本和错误，再绑定新 hash；不得让执行中的进程加载被替换文件。

## 4. 进程级 RemoteSigned：唯一实施方式与加载顺序

宿主与 guest 都使用各自的：
`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`
启动参数为 `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command <可审阅的短 bootstrap>`；普通用户，不 RunAs、不 NoExit，不把整个 Codex／宿主编排进程提升或设置为 RemoteSigned。此参数仅给本任务专用宿主自测进程和 guest 任务入口使用；不调用 Set-ExecutionPolicy，也不手动写策略环境键／注册表。

bootstrap 仅做以下准入和标准脚本调用，不把 helper 正文改为内联执行：
1. 记录实际 exe／PID／创建时间／PSHOME／版本、作用 host-selftest 或 guest；明确 UTF-8 输出与解码。只在本子进程设置 TEMP/TMP 为 W/scratch 下本轮临时目录或 guest 的 C:/M3/tmp；PowerShell／Add-Type 必要临时输出不得写宿主源码或 cache。
2. 正常显式 Import-Module 当前 PSHOME 下精确 `Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`，记录 Name／精确 Path 并核对。ModuleBase／Version仅记录，不加错误相等门。不得直接加载 DLL 绕过清单，不更改模块路径。
3. 同进程分别记录 Get-ExecutionPolicy -List 与有效值。要求 Process=RemoteSigned 且 effective=RemoteSigned；如管理策略、签名、应用控制或真实加载拒绝使条件不成立，则保存错误、停止脚本，不能改更低 scope、换加载器或放宽为 Bypass。该检查验证本次新进程条件，不是重开历史策略诊断链。
4. 在每个自有 ps1 正常加载前，按冻结绑定逐字节核对 SHA-256／精确路径和安全属性。bootstrap 的预期 hash 来自启动前记录的确定值，不从可随意改写的文件接受新 hash。宿主启动 host-selftest.ps1，后者仅正常加载已绑定 copy.ps1；guest 从只读映射 `C:/M3/s/in/runner/guest.ps1` 正常启动并加载同目录的绑定 copy.ps1。部署副本须与审阅版字节/hash一致，并保留任何来源标记。
5. 使用正常 `& <精确脚本>`／正常 dot-source，不 Invoke-Expression、EncodedCommand、反射或其他运行时替代；保留 RemoteSigned 的正常来源／签名检查。被拒脚本不解锁、不复制到另一位置洗掉标记、不加入信任、不忽略错误。

RemoteSigned 是进程运行条件，不是文件 hash 白名单或技术沙箱；本任务的路径/hash约束来自明确启动器和脚本加载检查，技术隔离仍由 Sandbox 完成。正常工具子进程仅限已批准工作，可能继承进程环境；必须随任务在界限内结束。不得自行给任何调用加入 Bypass／Unrestricted；遇到必须使用未批准运行条件的工具需求，报告具体冲突，不修改 SDK／系统绕过。

每次进程退出保存实际 exit 和其子进程终止状态。成功不得留下 RemoteSigned PowerShell、复制器或构建子进程继续运行。只按本任务记录的 PID、创建时间及父链管理归属；timeout 时终止本任务拥有的树，不按名字杀其他宿主会话。结束后从未被调整的宿主编排上下文启动一次不带 ExecutionPolicy 的普通查询，采用上述标准模块路径记录 scope/effective；只对照、不可“恢复”或重写系统设置。若当前普通环境值变化，只披露不能归因，不改配置；该收尾错误不把已有构建 exit 改写成构建失败。

## 5. 宿主自测、有限纠错与冻结

沿用 v0.4 §4 的 robocopy 与 Win32 Unicode 扩展路径方法，不再用旧未适配 CreateDirectory 递归复制。仅在 W/scratch 的合成样本中测试长源／长目标（绝对路径至少320字符，每组件小于100字符）、空格／中文、已知短内容/hash、不存在源的失败记录，以及返回码0/1/7/8/16分类。允许本任务 helper 中必要的 Add-Type/PInvoke；不安装工具、不改 LongPathsEnabled／系统策略。原生复制器固定当前 Windows System32/robocopy.exe。

基准参数：`/E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /MT:8 /XJ /SL /FP /BYTES /TS`，每项独立 UNILOG。不 /256、/MIR、/PURGE、/MOVE、/MOV、/B、/ZB、/REG、/MON、/MOT；不省略必要文件假装完整。>=8为原生复制失败；0–7还需看摘要失败／mismatch／extras及本次目标，不能把返回1当失败，不能用 wrapper exit覆盖 native exit。不存在源的负例被正确捕获才算测试成功。

自有 helper 逻辑／语法／序列化错误允许在同任务内最多两轮纠错，用已保存原值或新合成样本；总计最多三个专用宿主自测进程，每个最多180秒，均采用同一批准的进程条件。真实 hash／签名／权限／策略／身份拒绝不属于可绕过的代码错误。已有成功结果不重复查询来填满预算，不改其他输入。每轮先绑定新脚本/hash，上一轮进程及子进程结束后才能改自有脚本。

最后一次宿主自测必须确实通过。随后固定其 copy.ps1 版本和 guest.ps1、部署副本、启动命令、manifest、m3.wsb；记录配置/hash及加载图。启动后不得热修冻结脚本、换命令或重跑真实复制。host通过不是guest自测通过；guest须先执行一次同类小样本，失败不复制真实工具。无需在每个通过步骤后等待 Owner 再批准。

## 6. 固定输入与离线 Sandbox

仅沿用既有具名输入，作必要的安全／存在性检查，不重新发现 Git，不重查 Windows feature，不扫描 SDK/cache版本：
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

Android Studio不是输入，不复制／启动它；不回退旧默认.gradle，不改Wrapper迎合已有缓存。defines仅解析 D:/GradleHome/gradle.properties 的 flutterDartDefines、A中项目properties同名键、当前 ORG_GRADLE_PROJECT_flutterDartDefines，优先用户home→项目→环境；全部无值才EMPTY。按既有逗号／分号合同构造参数数组，不eval、不读取其他属性、不输出敏感值。

工具级源码物化严格限定 A 的模块前缀，排除 README类、FD02、旧 build/.dart_tool/.android/.ios/.gradle、Git元数据及既定保护／凭据／真实数据／日志路径；拒绝穿越、绝对路径或未批准链接。二进制按字节处理，内部manifest仅作物化记录，不分析业务源码、不用工作区或旧仓库。W/input/runner是本任务自产辅助输入，不能混记成A的源码。

只启动一次 W/m3.wsb。Networking、ClipboardRedirection、AudioInput、VideoInput、PrinterRedirection、VGpu 显式 Disable。上表8个输入映射全部 ReadOnly=true，唯一可写宿主映射 W/evidence→C:/M3/e；不能映射整个原仓库／旧仓库／用户目录／GradleHome／批准父根或旧证据。LogonCommand只启动§4中已冻结的guest bootstrap。启动前核对XML的准确路径、映射和hash，参数正确转义，不使用默认沙箱。

guest回传本轮nonce和启动标识，以客体接口／默认路由查询配合冻结配置确认无可用外部网络；不ping/DNS/HTTP、不试写宿主只读映射。005不能继承003隔离记录为实测。策略和隔离都通过后才guest自测、复制。复制器用支持长路径的原生元数据进行机械安全检查，不跟随reparse到未批准位置，/XJ或/SL不能被当作已证明没有遗漏；有无法安全处理的链接时记录具体对象，停止该输入，不默默跳过后声明完整。正常目录项仅工具为复制而读取，不形成agent源码/cache分析。

工具和cache只写guest副本。不复制宿主Gradle顶层properties/init.d/credentials/daemon状态、用户Git配置或旧生成产物。PATH仅guest系统及具名工具；FLUTTER_ROOT=C:/M3/t/f、JAVA_HOME=C:/M3/t/j、ANDROID_HOME/ANDROID_SDK_ROOT=C:/M3/t/a、PUB_CACHE=C:/M3/p、GRADLE_USER_HOME=C:/M3/h、TEMP/TMP=C:/M3/tmp。guest新Gradle属性仅daemon=false和java.home指向guest JDK；不写宿主环境。复制通过后允许客体Git --version与java -version各一次。

不复用未关闭的003窗口。若旧窗口实际阻止启动，可仅在该情况下读取A中003结果报告（精确文件名 RESULT_V0_3，blob 0a814b8ae92497f4927d6aea13cba74bec6c0d6d），及其明确的003 result.json／sandbox-launch.json并按报告hash核对；只有terminal和进程创建时间／父链确认归属后发正常关闭请求。不凭旧PID单独判断、不强杀其他会话；无法确认只报告会话冲突。旧host证据不删。

## 7. 实际执行、进度和生命周期上限

host自测通过后按以下顺序连续执行，不再审批分段：guest准入／隔离 → guest小样本 → 真实复制／工具验证 → 一次pub → 一次M3 → 导出／终止。
- Sandbox启动等待本轮nonce最多5分钟。
- guest就绪后，准入、自测、全部复制和工具验证合计最多30分钟。
- 模块cwd下 `C:/M3/t/f/bin/flutter.bat pub get --offline` 至多一次、10分钟上限。
- 仅pub成功后，同cwd `C:/M3/t/f/bin/flutter.bat build aar --no-debug --no-profile --no-pub` 加绑定defines数组，至多一次、30分钟上限；EMPTY不传占位符。
- 证据导出与进程收尾最多5分钟。全过程按这些上限合并设外层看门狗；即使guest内部卡住，也不能无限轮询。

宿主不运行Flutter/Dart/Java/Gradle；整个构建树留在禁网guest。无依赖下载、软件／Windows功能安装、系统修复或策略升级。各阶段启动前写started，防止LogonCommand重入。复制／pub／M3失败后不换命令、不热改产品源码或Wrapper、不自动重试。正常工具内部子进程不是新的顶层M3；须在本任务期限内结束。

每copy_id保存start/end、准确源/目标、原生PID/创建时间、完整参数数组、elapsed、exit、原生copied/failed/bytes摘要和错误路径；无法解析则保留原生日志与null，不造进度。自有路径操作之前记录源/目标长度及操作名。每30秒只监视本次结果／当前日志增量，必要时读自身精确PID的I/O。5分钟无可证进展记PROGRESS_UNCONFIRMED并作一次归属子进程观察，不延长总期限。只在阶段变化、错误、持续无进展时向Owner更新。

超时停止本任务拥有的进程树、保存真实阶段。guest任务控制器和其可能继承Process策略的子进程均结束后才声明运行条件生命周期结束；不要仅因父PowerShell退出就推定子进程结束。能确认归属的本轮沙箱会话可在保存证据后正常关闭，不复用；不能确认结束则如实INTERRUPTED/INDETERMINATE，不宣称完成。普通宿主编排的生命周期不受本任务RemoteSigned设置影响。

## 8. 证据、成功条件与两个候选文件

W/evidence至少保存真实发生的 result.json、host.log、host-selftest各轮结果/绑定、guest.log、script-bindings.json、冻结配置/hash、策略scope/effective、nonce/隔离控制、每项copy原生日志、原始错误和实际exit、进程归属/终止及旧文件保护摘要。未发生的阶段不伪造日志；阶段NOT_RUN、FAILED、TIMEOUT分开。路径优先盘符正斜杠，JSON序列化并round-trip，UTF-8与原始输出保留；日志/源码/cache/AAR不自动上传GitHub，敏感值只报告脱敏风险。

仅M3实际启动后，允许对本轮guest唯一定位符做一次存在性检查：
`C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。
HIT才记录size/SHA-256；未启动保持NOT_CHECKED，不记NON-HIT。不搜索替代。可工具级导出本次build/host/outputs/repo到W/evidence/maven-repo，核对同一AAR传输hash。只有M3 exit=0、exact AAR HIT、固定输入和本次控制证据俱全才记005生成证据HIT；不等于M2成功、App可安装或产品实现。

GitHub候选仅：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_5.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5和本轮状态；§2/§3/§6/§7原文保留。说明策略诊断已接受关闭、Owner本轮批准和005实际结果；旧禁止文字以本任务精确例外说明，不倒写历史、不改AGENTS。

分支 `review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-5`；subject `docs: record process-scoped RemoteSigned and isolated M3 result`。一个候选commit，唯一父本任务commit，恰好两路径。GitHub Git Database/连接器发布，不本地index/commit；发布前核验main/task仍匹配，变化保留证据不自行rebase；发布后一次核对父、两路径与blob。分支或文件冲突不覆盖。不自我接受、不推进main、不执行M2、不更新／上传项目源。

最终先给结果，再列实际策略、每份执行脚本hash、host/guest自测、复制／pub／M3/AAR、进程结束与证据限制。因政策参数获准不代表准备必成功。若又有真实依赖缺口或环境问题，交付具体错误对象；不要默认再发仅改编号的全量复制或同义策略诊断。后续独立审查可按既有同tree接受提交收尾，无额外closeout；只有已有权限足够才自动续发。

## 9. 官方机制与不可改变边界

作者2026-09-08核验的外部机制，不是本机运行保证：
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/About/about_PowerShell_exe.md ：-ExecutionPolicy只设置当前会话，不改注册表策略。
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/About/about_Execution_Policies.md ：Process生命周期及子进程、RemoteSigned、管理策略优先；不是安全边界或每文件白名单。
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy ：长路径、/R、/W、/SL、日志与退出码。
- https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file ：显式禁网、只读映射、LogonCommand。
执行者只按本任务实际问题定点核对，不重新开展广泛研究。

精确例外之外，禁止CurrentUser/LocalMachine、组策略、信任／签名／证书、LongPathsEnabled、应用控制、安全产品或模块路径修改；禁止Bypass/Unrestricted、Unblock、提权和其他加载器绕行。标准系统加载／Sandbox本身可能产生系统运行时记录，不声称全宿主绝对零写入；项目／seed／用户配置始终不写。
README预算耗尽、FD02永久排除、旧仓库／全仓agent枚举禁止；受保护无关staged state不得检查、修改、引用、总结或使用。M1历史耗尽lane不重试；D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、deferred PUI/PUI-PREREQ-12=0、legal/Safety/no-processing保持。LC-03/LC-04/Phase36及产品实现未授权，M2 deferred。此次只落实Owner批准的有限运行条件与已有M3技术证据范围。
