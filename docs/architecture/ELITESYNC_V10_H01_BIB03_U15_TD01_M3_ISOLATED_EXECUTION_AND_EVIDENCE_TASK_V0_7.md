# EliteSync v10｜参数绑定修复、同一派发器集成与条件式 M3 v0.7

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行：Owner 在 Codex 界面选择 GPT-5.6 Sol、Medium；无模型升级例外，不改模型配置、不默认调用辅助代理。ChatGPT负责规划与独立验收。

## 1. 激活与本轮唯一目标

006候选 d7eb7bed998d11b01ec500aaefb5217ccee53df8 已由A接受为失败记录，不是runner合格：三次宿主自测/两次纠错后0/6，Sandbox、真实复制、pub/M3均未启动。CMD-001的独立合成派发结论仍有效；006接入将已验证的ArgumentList改成自动变量名args，并用易被展开的嵌套数组表达bindings/cases。此前bootstrap还出现路径表示及Host变量问题。以上是已报告实现缺陷，不是新环境调查理由；遗漏参数也不能单独解释全部无ENTERED现象，须检查实际fixture和stderr。
本任务将修复、集成验证和条件式真实执行合在一单，不另发修复规划或环境盘点。与006的差异限：固定非自动变量接口；以具名字段对象保存参数数组；host/guest只加载同一份派发实现；先验证完整调用链；以本任务有限纠错预算替代006已用尽的预算。不得重新发明已接受引号构造、复制器或权限机制。
先前RemoteSigned只限当时具名任务，本文件发布不是新激活。Owner须直接向本会话或Codex确认：
> 批准本固定v0.7任务；仅在其专用宿主自测和沙箱客体入口进程使用RemoteSigned，限定脚本路径、hash与生命周期；批准新建007工作区，在本单内修复并验证参数绑定，通过后执行一次禁网隔离准备、一次离线pub及条件式一次M3。不同意持久策略/组策略/信任/来源标记改变、提权、Bypass/Unrestricted、下载或原仓库/宿主seed写入；其余边界不变。
可把上述批准与绑定本任务commit/blob的启动prompt一次交给Codex，无需再往返审批。记录直接批准文本及可见时间。无批准只读GitHub入口并报告WAITING OWNER ACTIVATION，不开始本地步骤。此批准只适用于007，不自动开放未来任务。

## 2. 固定入口与精确只读输入

仓库 `zcx369658780/EliteSync-v10`；开始实时读取main，必须为A：
`24e51edbe81317b9c1ae5351bd580cbfc2274959`。
FIRST主动读取A中的 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob `18485c95262051e43892436fb52413132c5ee626`。旧startup不执行，不能据旧标题重开已接受关口。随后核验本任务ref/commit/blob、唯一父A、只新增本任务。身份或hash失配停止其依赖操作，不自行追随或回退main。
其余仓库输入仅限下表；可读A接受消息，不沿引用枚举：

| 精确路径 | blob及用途 |
| --- | --- |
| AGENTS.md | f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1；规则 |
| docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md | 284a24a00d371d110e6802a2da7cb256cd11594a；限定更新 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_6.md | a6ff6ffe369922a60c620fe3d77b291812da1f53；真实缺陷及脚本hash |
| docs/architecture/ELITESYNC_V10_M3_CMD_DISPATCH_REPAIR_RESULT_V0_1.md | d1b0fd080665df717b237de44ad47b6285289ace；已接受构造，不重新手写另一种 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_6.md | 1dcbc970a89b7c4b989b4c6ff4e11791ed4e55e6；仅沿用运行控制，007差异优先，不执行006 |
| docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_5.md | ee9a9a26406bb5a95059171250f552036721f06c；必要时仅§4–8的现有控制细节 |
| apps/android/app/build.gradle.kts | a7e0f7583c801e2d56afc595d6c7bed84b5ce516；仅direct AAR/defines合同 |
| apps/android/gradle.properties | f0a2e55f89e383466d2c6b481c8c468a3aa0b13d；仅flutterDartDefines |

本地D:/EliteSync-v10只允许root/HEAD/origin及A固定对象元数据；必要时以已绑定C:/Program Files/Git/cmd/git.exe fetch声明main到refs/elitesync/m3-iso-v02-007-input，禁tags和submodule递归。HEAD仅上下文，不要求相等，不status/index/pull/checkout/switch/reset/stash/clean/worktree。源码只物化A的apps/flutter_elitesync_module Git对象，不用工作区或旧仓库。

## 3. 保留历史，只在新工作区修复

激活后，安全检查字面祖先，在已批准父根内独占创建W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-007`；Attempt=`M3-ISO-V02-007`。仅W/input、scripts、scratch、evidence和W/m3.wsb可新写。W冲突不覆盖、不清理、不换名绕过。立即初始化result.json和host.log，真实pub/M3未运行、exit=null、AAR=NOT_CHECKED。
旧全部attempt/diagnostics不改。仅实际采用下列006来源，读取前定点安全检查及hash验证，结束复核同一集合，不重验全部历史：

| D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-006/下来源 | SHA-256 |
| --- | --- |
| scripts/copy.ps1 | C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC |
| scripts/dispatch.ps1 | 65004B90BB332CF33AEDFAA957849C3B4C07E336DEAB90E8D244778CFC172A13 |
| scripts/host-selftest.ps1 | A724E7375C42B8C127E184909C78F6B89E4F5AC8DEAB9EFCD7C6A5F45B7CED04 |
| scripts/guest.ps1 | AB7A2B5A8A22EB705EAD31AE4372ADFFA1AB764C8ED6B520E222E7309208FC83 |

明确允许只读审阅这四份自产脚本：用于修复调用、fixture、bootstrap和记录并保留Job/期限/复制控制；不执行原006文件。hash不符不修补或搜索替代，停止其来源复用并记录。CMD-001代码直接取A已接受报告；不依赖新找旧文件。
007可执行自有ps1仅W/scripts/copy.ps1、dispatch.ps1、host-selftest.ps1、guest.ps1；guest/copy/dispatch部署副本只在W/input/runner同名。fixtures只在W/scratch及guest的C:/M3/tmp/selftest下。每份先静态审阅/5.1语法解析，保存差异、精确路径、完整hash、角色和加载关系；新hash在本任务生成后冻结，不伪造预知hash。可读这些精确文件的Zone.Identifier并仅提取ZoneId；保留来源限制，不Unblock、删ADS或以重写同载荷洗掉标记。

## 4. 修复规则：复用代码，不改变已验证接口

只在已绑定源码中确认并修复以下项，保留原始错误和最小diff：
1. 将RunBatch及相关封装的参数保留/统一为ArgumentList或BatchArgumentList，不声明/赋值args、Host、PID、input等自动变量作为业务形参/局部状态。变量名大小写不提供区分。不要把AST语法解析成功当作没有这类语义问题。
2. Script bindings使用具名Path/Sha256字段对象；六组cases使用Id/BatchPath/ArgumentList/WorkingDirectory/ExpectedExit/ExpectedEntered字段，ArgumentList明确为string[]。不用按索引拆嵌套(path,hash)或(case,path,args,cwd)数组，不依赖管道保留嵌套形状。
3. 从CMD-001接受片段保留Assert-CmdAtom、Quote-CmdAtom、New-BatchArguments构造；禁止把最终cmd字符串再次交给普通exe逐项引用。仅修正接口接入和相关错误分类，不写另一个转义算法。非空batch路径及支持域检查必须保留；EMPTY defines是零项，不是空字符串占位。
4. RunBatch在所有生产和测试调用点均使用命名实参或具名hashtable splatting；RunNative也必须保留明确参数序列。先在函数入口保存实际接收到的参数数量/逐项值，再保存最终ProcessStartInfo.FileName/Arguments/cwd，禁止只记录调用者计划传入的数组。
5. host和guest必须正常加载同一份dispatch.ps1，部署副本逐字/hash一致；其中包含本轮实际RunBatch和同一RunNative调用边界，不在host测试器复制一个相似实现。guest的pub/M3调用与host假目标使用同一个函数入口。保留原始输出重定向、期限、Job/StopChildren和exit传播。
6. 复用既有bootstrap步骤，做一次正确Windows路径归一及Name/精确Path绑定；ModuleBase/Version只记值，hash局部变量使用scriptHash等非自动变量，不重写正常策略机制。

下面仅固定数据形状及调用方式，不是替代完整实现或已实测声明；在最终实际接口上对齐参数名一次：
```powershell
# RunBatch的具名形参固定为Id, BatchPath, ArgumentList, Limit, WorkingDirectory。
$caseRows = @(
    [pscustomobject]@{
        Id='pub'; BatchPath=$fixturePath
        ArgumentList=[string[]]@('pub','get','--offline')
        WorkingDirectory=$fixtureDirectory
        ExpectedExit=0; ExpectedEntered=$true
    }
)
foreach ($caseRow in $caseRows) {
    $batchCall = @{
        Id=[string]$caseRow.Id
        BatchPath=[string]$caseRow.BatchPath
        ArgumentList=[string[]]$caseRow.ArgumentList
        Limit=$caseDeadline
        WorkingDirectory=[string]$caseRow.WorkingDirectory
    }
    $nativeExit = RunBatch @batchCall
}
```
在开始首个自测进程前，用纯内存检查确认六个具名对象、目标/cwd字段未错位，pub参数3项、M3参数5项、含空格define为1项、EMPTY defines为0项；只检查本次四脚本，不全仓lint或安装分析器。

## 5. 一次任务内完成集成修复，禁止假PASS

通过§1激活后，宿主自测只用各自System32 WindowsPowerShell/v1.0/powershell.exe，普通用户、-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command及可审阅短bootstrap。按006§5正常导入精确系统Security manifest、只核对Name/Path，记录Process和effective均RemoteSigned，核对绑定脚本hash后正常加载host-selftest/copy/dispatch。真实策略/签名/身份/hash拒绝停止，不改系统或换加载器。
所有host集成测试只运行W/scratch自有无害cmd目标，不能运行guest主流程或宿主真实工具。fixture在读取参数前无条件输出本轮nonce的ENTERED；逐项输出真实%~1等参数及%CD%，不使用错误的%%~1/%%CD%%；exit37目标无条件exit /b 37，不以收到某个参数作为返回37前提。不存在目标为一个精确未创建文件，而不是已有目录。stdout/stderr原始字节与完整命令行按组保存，missing目标和预期非零为负例，不因正确报错把整套测试提前终止。
六组必须在本轮实际runner边界取得PASS：pub三参数；M3五参数；目标/cwd含空格；一个含空格的合成define；ENTERED且exit37原样传播；不存在目标无ENTERED且实际派发失败。危险控制字符仅纯内存拒绝测试。case输入、函数实际参数和最终OS字符串三层须一致。任何0/6或仅序列化成功不得放行。不得只改报告标签或把原合成PASS冒充本轮集成PASS。
本地宿主修复/自测总墙钟上限10分钟；单个自测进程最多180秒、每个假目标最多10秒、总计最多5个实际自测进程。预算内可以修正有具体证据的本任务代码错误，先保存该轮版本/原始结果，结束所属进程后再改并重新绑定hash；已成功且未受变化影响的组不重跑。这个007预算不重开006；不为普通错误逐个要求Owner审批，也不绕过真实系统拒绝。预算用尽则保留准确终态，不继续后台工作。
最终6/6后，冻结通过测试的同一dispatch/copy和guest部署副本、命令/配置，禁止为了“接入guest”再次改名或重写派发器。冻结前以静态调用点比对确认guest用同一具名接口；guest准入后、复制前用同一派发器做pub/M3形状及exit37的最小冒烟。复制算法未变引用005长路径证据，不重做长路径矩阵；新文件hash本身不表示冻结成功。

## 6. 通过后沿用既有隔离执行，不能停在修复计划

007才是本轮新输入/日志/nonce，不复用006或005客体。运行控制沿用006§5–7，所有本轮路径及标识替换为W/007；其旧main、旧激活、旧预算、结果路径不执行。以下明确保留：

| 宿主只读输入 | guest只读映射 | guest可写副本 |
| --- | --- | --- |
| W/input | C:/M3/s/in | C:/M3/w/apps/flutter_elitesync_module及runner输入 |
| D:/flutter | C:/M3/s/f | C:/M3/t/f |
| C:/Users/zcxve/AppData/Local/Android/Sdk | C:/M3/s/a | C:/M3/t/a |
| C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot | C:/M3/s/j | C:/M3/t/j |
| C:/Program Files/Git | C:/M3/s/g | C:/M3/t/g |
| C:/Users/zcxve/AppData/Local/Pub/Cache | C:/M3/s/p | C:/M3/p |
| D:/GradleHome/caches | C:/M3/s/h | C:/M3/h/caches |
| D:/GradleHome/wrapper/dists | C:/M3/s/d | C:/M3/h/wrapper/dists |

只作必要字面安全/存在检查，不重新发现Git/查Windows feature/枚举cache版本，不复制或启动Android Studio。只从固定A模块Git对象机械过滤物化，排除README类、FD02、旧build/.dart_tool/.android/.ios/.gradle、Git元数据及既定保护/凭据/真实数据/日志路径，拒绝穿越/链接，不分析产品源码。defines仍只解析D:/GradleHome/gradle.properties的flutterDartDefines、A项目同名键、当前ORG_GRADLE_PROJECT_flutterDartDefines，优先用户home→项目→环境。非支持参数在复制前报告，不丢值或擅改配置。
只启动一次W/m3.wsb。八输入只读，唯一可写宿主映射W/evidence→C:/M3/e；Networking/ClipboardRedirection/AudioInput/VideoInput/PrinterRedirection/VGpu均Disable。冻结XML、映射、完整bootstrap、加载hash。guest入口同为仅进程RemoteSigned并正常核验策略/脚本；新nonce与本次接口/默认路由验证禁网，不ping/DNS/HTTP或试写宿主seed。旧隔离成功不替代新实测。不映射整个原仓库、旧仓库、用户目录、GradleHome、父根或旧证据。
通过guest冒烟才复制一次各具名根；保留005已验证copy.ps1及robocopy /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /MT:8 /XJ /SL /FP /BYTES /TS和独立UNILOG，正常机械安全检查不跟随未批准reparse。0–7仍看摘要failed/mismatch/extras，>=8失败；不使用/256、删除/移动/提权/自动重试参数，不默默省略必要文件。不复制Gradle顶层properties/init.d/credentials/daemon或用户Git配置。
仅guest设置既有PATH/FLUTTER_ROOT/JAVA_HOME/ANDROID_HOME/ANDROID_SDK_ROOT/PUB_CACHE/GRADLE_USER_HOME/TEMP/TMP指向上表副本及C:/M3/tmp；新Gradle属性仅daemon=false和guest java.home。复制后guest Git --version、java -version各一次。宿主原仓库、SDK/cache、用户配置不写。
实际pub/M3均由通过集成测试的同一RunBatch具名调用：guest cwd为C:/M3/w/apps/flutter_elitesync_module，batch为C:/M3/t/f/bin/flutter.bat；pub参数为pub/get/--offline；仅真实pub成功后用build/aar/--no-debug/--no-profile/--no-pub加准确defines。各最多一次派发，不联网补包、不改SDK/Wrapper/产品源码、不热修已启动guest、不重试真实工具。
时限：nonce等待5分钟；guest就绪到准入/冒烟/复制/工具验证合计30分钟；pub10分钟；M3 30分钟；证据导出/收尾5分钟。保留外层看门狗及Job归属控制，每30秒只读自有状态/日志增量，持续5分钟无可证进展按原合同记录并一次定点观察，不延长总时限。只在阶段变化/错误/无进展更新，不重复刷屏。
保存每项真实exit和原始输出，区分dispatch调用、工具body入口证据、命令失败、入口不明与超时。缺包分类必须有实际依赖诊断；模拟ENTERED不能赋给真实Flutter，0退出也不单独证明构建完成。只有本轮M3实际启动后，才一次检查C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar；未启动NOT_CHECKED，HIT才size/hash。可导出本次Maven repo并校验同一AAR传输hash，不搜索替代。M3 exit0+exact HIT+固定输入/隔离证据才是本attempt生成HIT，不是M2或App完成。
任务进程树/可能继承策略的子进程均在期限内结束；按PID/创建时间/父链管理，不按名全局杀进程。可在证据落盘后正常关闭确证本次Sandbox；无法确认终止如实INDETERMINATE。普通宿主收尾按006正常不带ExecutionPolicy查询对照，不“恢复”或改策略；不由对照失败倒写构建结果。旧证据和本次失败证据不清理，不声称临时guest可持久复用。

## 7. 交付与复用：只维护一份实际派发实现

本地W/evidence保存激活、准确脚本/部署hash、最小diff、各轮case对象/函数实际参数/最终命令/原始输出/exit、策略/nonce/复制/工具阶段、终态与生命周期及旧来源保护。新写文本用UTF-8及JSON序列化/反解析，路径优先盘符正斜杠；不能从hash表推断实际未通过的冻结/部署。未发生阶段不伪造日志，不上传私密配置、SDK/cache、产品源码、二进制或全量日志。
报告必须包含修复后RunBatch/参数构造的完整可复用片段、具名case形状与host/guest调用点，及实际使用这些字节的hash。不只指向本地文件；不在报告中另写“等价简化版”让下轮再翻译。保持一份dispatch实现在测试与实际调用中共享，这是本轮与再次独立合成测试的区别。既有Job/复制等无关源码不整段上传。
GitHub只一个候选commit，唯一父为本任务commit；分支 `review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-7`，subject `docs: record binding-corrected runner and bounded M3 continuation`。恰好两个目标：
- 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md`。
- 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`页首/§1/§4/§5的当前证据与近期状态；§2/§3/§6/§7逐字保留。已接受的历史005/CMD-001不倒写，006记录已接受不等于目标通过。除状态/修复事实，不借本次重写路线图或删减未来范围限制。
发布用GitHub Git Database/连接器，不本地index/commit。发布前一次核验main/task，失配保留证据/草稿不自行换基线；发布后一次核验父/两路径/blob，不自我接受、不更新main、不执行M2、不另发任务。独立审查沿用同tree接受，无额外closeout。AGENTS与ChatGPT项目源不修改、不重传。

## 8. 依据和不变边界

官方机制仅用于确认语言规则，不是本机结果或完成保证：
- https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/about/about_automatic_variables?view=powershell-5.1 ：args/Host等由PowerShell维护，不作为本任务业务变量。
- https://devblogs.microsoft.com/powershell/array-literals-in-powershell/ ：数组构造与输出枚举需区别；不是断言一切嵌套数组都无效。本任务改用具名字段避免脆弱位置绑定。
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmd ：已有/c命令字符串规则；不重新研究转义。
作者核验日期2026-09-09。执行者仅对实际缺陷定点核对官方资料，不开展广泛研究。
RemoteSigned仅§1激活后的本任务专用入口，不改CurrentUser/LocalMachine/组策略/信任/签名/来源标记/模块路径/LongPathsEnabled或安全产品；不Set-ExecutionPolicy、Bypass/Unrestricted、Unblock、提权、替代加载器绕行，不安装/下载。正常系统加载/Sandbox可有系统运行记录，不声称全宿主零写入。
README耗尽、FD02永久排除、旧D:/EliteSync及zcx369658780/EliteSync/全仓agent枚举禁止，受保护无关staged/index不检查/修改/引用/总结。M1历史lane不重试；D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12、TP-SOURCE-CLASS-01/TP-TARGET-01、Backend0/10、Database0/8、PUI deferred/PUI-PREREQ-12=0、legal/Safety/no-processing保持。LC-03/LC-04/Phase36和产品实现未授权，M2 deferred。失败只报告真实受影响范围；未获授权的下载/持久环境/宿主写入/实现不能因试错或备份被推定允许。
