# v10.1.5｜固定控制台角色的独立VM源验证

2026-11-02，Owner在当前接续上下文明确“请继续，我授权”。此前入口已指明下一项为结合具名控制台角色的独立VM/Flutter候选；本节点只落实其中VM源验证。该许可不补充已耗scope，不启动Flutter、Gradle或实际产包。

独立scope `v1015-vm-source-qualified-console-20261102/case01`，最多1次。实际创建尝试前独占写不可退款claim；启动失败、非零退出、STOP、无结果均耗这一次，不能重跑或换目录续额。原配置3+3+1及Dart/cache/stdio/OS库存/合成控制台的旧claim、失败和STOP保持。

精确入口为现有dartvm.exe，参数与此前固定stdio源诊断一致：两个逻辑launcher路径参数及自有stdio_stage_probe.dart。仅读取六项终端/ANSI元数据getter，前后同步JSONL标记；不读stdin内容。原SDK只读，写面仅任务私有目录/输出。网络、剪贴板、音视频和设备映射关闭；仍为90秒运行上限、15秒独立heartbeat、4GiB私有工作面/512MiB输出采样边界，保留采样非原子及UDP目的地UNKNOWN限制。

唯一已知镜像为固定VM及guest `C:\Windows\System32\conhost.exe`，后者长度1003520、SHA256 `c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac`。输入校验和首次进程绑定均用有界OS哈希/身份检查，未知镜像立即STOP；不增加通配或宽泛微软签名许可。guest kernel32版本固定10.0.26100.6713、CLR4.0.30319.42000，漂移在VM创建前拒收。

复用依据为上一合成scope的固定manifest、原始receipt和verified-result三份SHA，而非重新调用旧scope的frozen或重跑它。只接受其具名OS角色；本轮仍须验证真实VM路径。当前生成native从固定base与已审控制台生成源衍生，保存完整原文/patch/变换报告；不改旧native或claim。版本字符串及具名文件哈希不宣称完整已加载DLL闭包。

成功必须真实root0、无STOP/watchdog、精确两成员及不同PID的VM/控制台镜像样本、完整14条标记、Job空及全部句柄退出；getter异常另列，不推断唯一根因。明确的输入/环境/CreateJob/Spawn失败可封存REJECTED，不能因收集器exit0升格成功。结果仅覆盖固定VM源脚本，不覆盖Flutter snapshot、锁、BAT等价性、完整native树、Gradle、AAR或APK。

工程角色沿现行Local-first：Codex实施、检查及工程裁决；非作者Codex源码复核不称外部独立验收。手机现行一般许可保留，本scope不访问设备或媒体；AC05 OPEN、G2 false、10 PARTIAL和真实消息Push PENDING保持，不合main、不发布、不启动v10.1.6。实际结果及证据见唯一进度细表，本文件不是额度计数器。

## 继后独立Flutter私有缓存负例

上述VM源scope已成功并永久消耗1/1（退出0、14标记、精确双镜像、无STOP、完整清理），不再执行。沿本次Owner对已指明VM/Flutter候选的继续授权，下一项另立 `v1015-flutter-vm-qualified-console-20261102/case01`，同样独立max1及不可退款claim；不继承原CLI缓存失败scope余额。

目标是在刚核实的直接VM路径运行现有Flutter snapshot的固定负例：两个逻辑launcher路径参数、固定私有package_config/snapshot及 `--suppress-analytics --no-version-check --machine assemble`。原CLI/BAT不执行，原SDK/stamp不修；10份固定控制文件由现有源只读复制到任务自有fixture，进入guest私有Flutter根，锁必须由Flutter正常创建，严禁FLUTTER_ALREADY_LOCKED。此前源码顺序说明此参数组合在构建分派前拒绝；成功标准为实际exit2、固定错误句、lock0字节/nonreparse和legacy version、双镜像/无STOP/watchdog/清理完整。锁文件存在只是佐证，不冒称直接观察了锁持有。

历史VM的manifest/receipt/verified-result和先前合成OS证据均按精确SHA复用；本轮重新核完整只读SDK、10份控制源和全部映射/镜像/生成源/环境。仍仅允许固定VM/conhost双镜像及同样kernel/CLR；未知进程立即STOP。完整字节输入、原文、patch和执行回执私有保留。此单次失败或无结果同样永久耗尽，不退款、重跑或自动追加后继额度。

该负例不产AAR/APK、不执行assemble构建动作、不操作手机、媒体或供应商；真实产包claim尚未建立，G2仍false。本项支持也不证明stock BAT等价性、完整native树、实际构建/安装或整版工程验收。

### 实际拒收与静态候选

本独立Flutter scope已执行并永久耗尽1/1：root255，无supervisor STOP/watchdog，双成员及清理完整；尚未创建缓存锁，预期exit2/错误句未到达，明确REJECTED。原stderr首先报告process/src/interface/common.dart:60:49的空值断言；所选process5.0.5源码该行解引用PATHEXT，本次固定环境确实缺此键。事后CACHE_LOCK_NOT_CREATED是症状。当前证据支持缺PATHEXT是这次首异常的直接原因，不能据此承诺补齐后完整缓存路径成功。

新增纯静态候选只给私有环境字典副本加入PATHEXT=.EXE，拒其它扩展、重复Windows变量名和锁绕过，不继承宿主环境，不改已执行controller/SDK或旧claim。它没有启动能力，未接入任何新运行。现有Flutter _WindowsUtils._which源码在canRun后会调用where；where.exe尚未资格化，不能把.EXE扩展当作新的镜像许可。

### 后续具体验证提案（PROPOSED_NOT_AUTHORIZED）

需Owner对下一组有限运行另行确认，不修改上述两个已耗scope，也不自动续额。提案最多3个独立scope、每个最多1次，不是现有scope的重跑：

1. `v1015-where-image-inventory-20261102/case01`：仅在禁网guest由自有只读fixture核实固定System32/where.exe文件及Windows Catalog签名、版本、SHA、长度、句柄身份；不执行where，不映射SDK/产品/设备。固定文件结果若不完整或漂移即停止。
2. `v1015-where-execution-qualification-20261102/case01`：只有第1项支持、具体guest字节pin/完整输入/观察器固定并通过纯检查后，运行该固定where.exe的 `/Q __ELITESYNC_V1015_NEGATIVE_LOOKUP__`，期望exit1且无结果匹配。精确允许该where与已有具名conhost角色；不是宽泛系统工具白名单。具体长度/hash由第1项的immutable原证消费，未得到完整结果时不得执行。
3. `v1015-flutter-pathext-cache-recheck-20261102/case01`：前两项及现有VM角色均成立后，在本静态候选的私有环境上验证同一snapshot负例，精确加入已资格化where镜像。旧SDK/10份控制源不变，正常缓存锁，不执行stock CLI/BAT或构建分派；仍须真实exit2、固定错误句/缓存状态/精确镜像/完整清理共同满足才支持。

各scope启动前独占写max1不可退款claim，失败、无结果、STOP同样耗尽，无自动后继。每次仍90秒/15秒heartbeat、同等磁盘/只读映射/禁网/未知镜像STOP，实际准备后固定全部输入、命令、生成源与环境hash，再做非作者源码复核和适用纯检查；无法固定即NOT_RUN。签名无效、版本漂移、新映像、下载/网络或清理不完整只停止受影响分项，不重试、不放宽守卫。此次提案不含下载安装升级、AAR/APK/手机/媒体/供应商/生产/费用、main合并或发布，G2 false、AC05 OPEN保持。当前三项都未建执行claim、未运行，Owner现有一般APK/USB许可仍保留。

### 本组三项授权记录

Owner针对上述具名问题明确答复“授权按提案执行这三个独立单次验证”。上文PROPOSED_NOT_AUTHORIZED与未建claim是授权前的原时点状态；现允许按顺序准备和执行这三个各max1范围。前项不支持则后项NOT_RUN，不退款、重置、借旧余额或追加后继。实际执行以各任务根永久claim/原证为准；本授权不含产包、手机、媒体、供应商、生产、费用或main合并。

### 本组三项实际执行结果

三项均按顺序执行，各1/1永久已耗、剩0，无追加scope或后继claim。共用新runner源码固定`c650f86b27b4311e0e963e21a5483466896b1b0c`，首项冻结后没有修改其代码或helpers；未改任何旧controller/claim。

- 文件库存支持：仅4份probe/122469源字节，无SDK/产品/设备映射；root0、29样本/1成员/10扫描，Windows Catalog签名Valid、身份稳定。guest where.exe为10.0.26100.8875、65536字节、SHA f51fab8041e5023d7290b540a2106f051ef0bd2bc3443c9daf318628b560fa29。只读库存不直接授执行。
- 固定用途支持：2份host probe/98643字节+where/conhost两项guest OS pin，共4项；真实where根执行固定/Q负例，预期root1、3样本/1成员/4扫描，stdout/stderr原始字节均空，严格限定此用途，不扩展其它命令或程序。
- 缓存复验拒收：1011份host输入/627214169字节+两OS pin，共1013项；仅私有PATHEXT=.EXE变更，SDK/10控制源仍与前案逐条相同。真实root2、固定--machine错误已观察，6样本/4成员包含VM、conhost及两个where，无STOP/watchdog且清理完整；但观察器随后要求旧版root/version文件，FileNotFound、cache_state=null，因此仍REJECTED，不能把collector exit0或预期负例单独当整项通过。

225项Python组合通过，三份生成观察器各168项纯C#保护断言、库存fixture17项、缓存环境9项通过。首次host preflight因生成fixture换行分隔符被拒，在0claim/0launch时仅规范新副本LF后精确删除synthetic入口；旧源保持。纯测试首次误把历史注释当入口，限定Main后通过，原工具输出保留。非作者Codex只读复核P2已修，非外部独立验收。

静态核对发现当前Flutter源码把omitLegacyVersionFile定义为fullyEnabled，_ensureLegacyVersionFile可早退；featuresConfig仍可覆盖，本次没有直接采集实际flag。4份本地源码raw SHA固定且CRLF归一后与SDK local HEAD对应Git Blob一致；这不等于远端独立核验或snapshot消费证明。root2/固定错误与源码中lock→informative update→ensureVersionFile→负例→构建分派的顺序一致。观察器沿用旧版文件必存假设是本轮验证设计错误，**旧拒收与冻结条件保持**。

后续纯观察策略候选分别验证预置JSON的版本身份/raw SHA、真实锁字段及legacy缺失预期，结果明确NOT_RUN、实际flag/锁持有未直接观察，不输出PASS或工具资格；6项新纯测试通过。JSON本来就是只读控制输入，不能称本轮新生成或由其存在/hash推断工具消费；锁存在不能证明持有，legacy缺失不能反推flag。候选未接任何执行器，真实collector适配及新运行均未进行，不自动新建预算/claim。原40份具名记录、原根255/index、SDK/备份/数据库及STOP保持；手机/媒体0，G2 false、AC05 OPEN、10 PARTIAL、真实消息Push PENDING保持。

## 当前版本观察器适配与独立单次复验登记

Owner在上一节点明确列出“适配实际观察器，再安排独立复验”后回复“可以请继续”。沿本次继续授权，Codex先完成实际采集器/分类器适配与适用纯检查，再为此不同观察策略注册独立 `v1015-flutter-json-cache-observer-20261102/case01`，**max1由Codex作为本范围的保守执行上限**。不把Owner原话冒称具名次数答复，不恢复旧三项或任何旧余额；此次是有新Owner输入后的具名工程接续，不是无人批准的自动后继。权限仍仅当前已知VM/where/conhost及禁网私有缓存诊断，无新增系统工具或设备/媒体/供应商权限。

新profile命令、SDK/10控制文件、镜像及资源边界与前一缓存负例相同；prepare/frozen内固定旧失败manifest raw SHA，逐项比较SDK/FlutterControls完整guest路径/hash及原source_pins，拒漂移。前置where库存/固定用途资格须按原代码、环境与范围重新核身份，旧缓存manifest/receipt/verified三份固定SHA仍要求REJECTED/cache_state null，不改写原失败。完整输入、生成源/patch、helper、命令和环境在创建前冻结；source授权开关只作用此唯一新case，未授权状态先于claim/子进程拒绝。

新原生观察器只替换后置ReadCacheState：持FileShare.Read双文件句柄核lock0字节/非reparse/单链接及前后FileID-size-mtime-link；版本JSON有界1..32768字节、严格UTF8、原始SHA及3.41.7/cc0734ac716fbb8b90f3f9db8020958b1553afa7/Dart3.11.5身份；独立记录legacy文件存在与否。本profile明确要求legacy缺失，适用源码默认省略策略；它不声称已直接采集有效feature flag。host分类器必须同时核真实exit2/固定错误句、全部已绑定成员的精确镜像及完整清理、真实guest观察字段和预置JSON来源，才能给本profile限定支持。JSON原始输入/hash不证明本轮生成或工具消费；退出后稳定身份不证明工具运行时曾持锁。

新单次在任何实际启动尝试前独占写不可退款claim，启动失败/非零或未知结果/STOP同样耗这一次，不能再跑或改目录续额。运行前实际执行器/输入不合格则相关项NOT_RUN，不以纯检查或历史成功放行；运行仍90秒hard/15秒heartbeat、2GiB guest内存、4GiB私有工作面/512MiB输出采样边界、网络/剪贴板/音视频/打印/vGPU关闭、未知映像立即STOP、只清理自有Job。旧46份保护记录、原根255/index、SDK/数据库/备份/worktrees/STOP全部保留。新产包/设备/外部服务/生产/费用/main合并与发布均不在本profile中，G2 false、AC05 OPEN及整版10 PARTIAL保持。首次实际创建前完成审查/纯检查并记录具体执行决定；最终事实以独占claim和唯一进度细表为准。

### 当前版本观察器实际结果

执行源码`935464a73f4fa4a7d532796f88a16c5c8d198488`；249项Python组合通过，授权绑定后最终19项定向通过（未授权False/整数1均先于claim/Popen拒绝），当前生成源168项观察器/9项环境/31项JSON文件形状与身份纯C#断言通过。新增profile独立prepare/frozen并逐项核复用SDK/control与固定旧失败manifest相同，未改旧helper或任何拒收结果。

已实际完成并限定支持 `FLUTTER_JSON_CACHE_NEGATIVE_OBSERVATION_SUPPORTED`：1013项guest输入（1011份host/627220406源字节+2 guest-only OS pin），root2及固定错误句，6成功样本/6成员/4扫描（实际角色为1 VM、3 conhost、2 where），无STOP/watchdog、Job空和全部句柄退出。真实post-exit观察返回锁存在/0字节/nonreparse/前后身份稳定、legacy文件不存在、预置版本JSON559字节/SHA f170ed630dcc291fe6f632656d976bf09de59ab940160c67a314344eec842c1e及固定三项版本身份；实际flag、运行时持锁、元数据生成/消费仍未直接证明，producer/G2仍false，不是完整Flutter/BAT/native链或产包资格。

本scope1/1永久已耗、剩0；旧46份具名记录逐份保持，加入本次claim/verified后固定48份。原活动根255项状态及index、SDK/数据库/备份/STOP保持，四类Sandbox宿主进程已缺席，手机/媒体0。实际AAR/APK预算/claim仍未建；后续仅在原已授权目标中准备完整生产读集/私有Flutter根、完整native工具树及真实AAR→host交接，不自动复跑本scope或增加后继额度。真实结果/证据hash见唯一进度细表。

## 会话封存：Owner决定与后续边界

2026-11-02，Owner要求“当前会话太长，请立即在github端文档、本地文档中保存当前会话的任务进度、Owner决策等信息，然后给我当前会话的交接prompt”。本节点只进行文档保存、只读保护/身份核对和普通Git同步；不新增工程/测试/构建/数据库/设备，不自动续跑或安排关机。新会话按本次交接及既有授权继续，不重做治理迁移、不恢复网页流程、不另造CURRENT/MEMORY/HANDOFF或ZIP。

既有Owner决定按原会话记录继承，以下为汇总而非新增授权：

- **分工与范围**：顾问GPT只下达项目计划/路线，Codex负责工程拆解、实现、调试、测试、代码审查、工程验收、Git和进度；Owner保留方向、重大取舍/架构、具体保护权限、费用与正式发布。普通已授权实现与修复自主完成；自查/非作者Codex复核不冒称外部独立审查，不为每项工程恢复网页派单或验收。
- **产品工程与环境**：Owner已同意独立产品分支精确接续已接受软件源，已授权v10.1.5剩余范围内工程及一般新Debug APK/USB；并针对环境问题明确“授权启动现有环境，不升级或安装工具链”，仅现有Docker Desktop/WSL用于隔离开发/测试。一般许可不重复询问；服务是否运行、设备当前绑定/空闲状态和实际资格仍须当时增量核实，不能把曾经USB连接/历史资格当当前合格。
- **有限预算**：两组各3次配置诊断及独立1次复验、后续具名where三项等均按各自明确授权/claim封存；最近JSON观察单次为Owner继续已明述下一步后由Codex保守注册的独立max1，不伪称Owner原话给出数字。旧3+3+1及所有已耗scope不退款、不重置、不重跑、不借STOP余额或换目录续额。当前RUNTIME_AUTHORIZED=True只绑定已耗唯一case，不是新许可；为收尾改开关/旧helper会破坏冻结身份，不做此变更。
- **工程结论**：软件接续与受控JSON缓存负例观察已完成；真实AAR/APK尚未生成，实际产包预算/claim未创建。完整生产输入、私有完整Flutter根/native资格/AAR→host真实交接仍待工程闭合；缓存观察通过不能放行producer或G2，旧legacy观察器拒收不改判，预置JSON及持锁/flag/消费的证据限制保留。
- **真实保护边界**：不安装升级工具链，不绕守卫/改全局安全；未获新的具体保留权限时不擅自增加设备、音视频、供应商、外部服务、真实用户/生产数据、费用或不可逆操作；UAC仍需当前Owner“我在”与具体授权。既有APK/USB许可不等于所有媒体/供应商权限。原dirty/index、旧L11/L13、11,066文件备份、SDK、DB、worktrees、LOCAL_ONLY和STOP保留；不pull/reset/rebase/stash/clean/prune/force，不合main、不关闭AC05、不放行G2、不启动v10.1.6。
- **记录与同步**：继续唯一ACTIVE_STATE短入口、唯一进度细表及必要decisions；只提交本轮已审查内容，普通non-force后回读远端HEAD/关键文档。失败记PENDING_SYNC，不换身份绕过；真实消息Push PENDING与Git同步分开。禁止上传凭据/私密SQL/真实用户资料/敏感设备日志/受限APK或LOCAL_ONLY原证。

封存前本地/远端产品分支d8543689f3b85b0575a4fa429ff819dd7b8fc8a2，原活动根仍main@4bebc8f394248e254c1368a06fbdee5d2c883301/255项及原index，48份保护记录一致；最终保存提交以本节点提交后的本地和远端核实为准。当前整体10 PARTIAL、AC05 OPEN、G2 false、真实消息Push PENDING保持，下一会话从实际产包准备接续，不重复已完成的94映射导入或Laravel13兼容迁移。

### 会话文档保存的连接失败与独立镜像

首次保存commit e4f0ac863652af928ee9dfdf88126d7d988f5373的普通SSH推送及一次已披露的同身份/同协议重试均被连接关闭（exit1），不把连接关闭归因为已证实鉴权拒绝，也不把失败写成同步成功；两次原文私有保留。原产品分支PENDING_SYNC，不改SSH/凭据或强推，不持续盲重试。

Owner当前已明确要求GitHub端保存文档；现有连接器身份核实为仓库Owner zcx369658780。为完成这一文档保存事项，使用该既有账号在独立codex/session-save-20261102分支保存已审三文档，以原远端d8543689为parent，不修改原产品分支或main，不作为SSH修复或原分支推送成功。快照只包含三文档差异，产品apps/services及其它Tree保持；最终以远端branch/commit、三文档Blob和整体Tree回读为准。本地与镜像Git commit身份不同必须明示；镜像不是研发Parent，不自动合回。原产品分支待连接恢复、核整个待推范围后普通non-force同步，勿pull/reset/rebase来“对齐”镜像。

## 2026-11-03 Owner交接后停止决定

Owner本轮明确授权接续v10.1.5实际产包准备，上一轮“只保存文档”属于已结束保存轮，不阻止本轮已授权工程，也不恢复旧预算。只读核对与接线定位期间，Owner随后要求：“你好，交接完成后请停下，明天继续”。Codex据此仅完成现有文档中的本轮交接保存，然后停止；不自动安排唤醒或后续工程，不操作系统关机。后续由Owner发起继续。

停止时尚未修改任何工程源码，未运行测试、构建、数据库、SDK工具、设备或媒体，也未创建任何新预算或claim。一般工程/新Debug APK及USB/仅现有Docker Desktop与WSL启动许可仍按既有范围保留，实际执行器、完整输入、独立预算/claim和设备当时资格不因此成立；旧已耗scope及原helper/开关继续冻结。

本轮只读发现拟议AAR版本与host固定1.0接线尚未闭合、CI目录exists并非真实工件证明；完整目录库存和真实POM/AAR hash/坐标交接未实现。具名48保护记录、原根main/HEAD/默认255项/index均保持。产品Git同步仍PENDING_SYNC，本轮不重试SSH、不重建镜像；最终保存身份以产品分支实际Git HEAD为准。详见唯一进度细表2026-11-03节点，整版仍10 PARTIAL、AC05 OPEN、G2 false、真实消息Push PENDING。

## 2026-11-03 Owner恢复工程与产包源码准备节点

Owner在上述交接停止后明确“请继续”，据此恢复既有v10.1.5剩余范围内普通工程；此前“明天继续”不再构成当前等待指令，实际日期仍按本轮Asia/Shanghai记录。原一般Debug APK/USB、仅现有Docker Desktop/WSL许可继续有效，不重问笼统许可；本答复不新增次数、独立产包预算、具体执行器或设备资格，不恢复任何已耗scope。

Codex本轮实现完整声明树库存、AAR仓库校验/私有复制及私有host源码渲染，实际准备274根完整内容库存、任务私有完整Flutter根与Project/生成Android控制/包插件路径接线。原apps/services、SDK、旧helper/开关未改；无SDK工具、构建、DB、设备或媒体执行，无新预算/claim。真实产包前仍须完整执行器/客体映射/native资格/offline依赖及具名独立预算成立，真实AAR来源与host Kotlin/Gradle消费不由fixture替代。自测/非作者Codex复核与外部独立验收、Owner接受、发布继续分开。

首次私有Project准备因未含ignored生成.android目录而停止，保留部分输出及首次caller，补齐实际20控制文件后完成，未重开SDK/构建范围或重置旧预算。48保护记录、原根main/255/index保持。一次fresh SSH只读核对成功后，审整个待推范围并尝试唯一普通non-force推送，仍被Connection closed/exit128关闭；PENDING_SYNC保留，不继续重试、不改身份/SSH、不用镜像作Parent。详见唯一进度细表本次节点；整版10 PARTIAL、AC05 OPEN、G2 false、真实消息Push PENDING均保持。

## 2026-11-04 映射scope实测STOP与新的独立生命周期复验提案

Owner本轮再次“请继续”，Codex在已列明下一步映射资格与既有v10.1.5工程范围内，保守登记独立max1 mapping-only fixture；次数为Codex限制，不伪称Owner原话数字。该v1015-full-input-mapping-qualification-20261104已执行1/1、剩0，275样本/2457权限拒绝/2owned写读删成功，但宿主后台未在观察窗内退出，最终STOP；SDK/Gradle/产包/设备/媒体0，原STOP/claim冻结不退款不重跑。主代理在STOP后以精确配置、父/生时链、fresh身份及持有handles，只结束两个本次拥有的宿主实例，另存receipt，未改判原scope通过。

以下为**新的明确提案，PROPOSED_NOT_AUTHORIZED**，不是本轮“继续”自动增加的额度：

- 固定scope：`v1015-full-input-mapping-lifecycle-recheck-20261104`，独立最多1次，不可退款、不自动后继；Owner须明确批准这个新范围后才创建claim。旧scope保持1/1已耗、剩0。
- 同一完整候选布局：273只读根、两个已拥有的私有写面；仅275个小样本读取、2457个只试开权限句柄拒绝及nonce写面测试。RO无实际写删改ACL；不执行SDK/Gradle/Flutter/AAR/APK、DB、设备或媒体，不新增供应商、外部服务、费用或系统权限。
- 收尾修复：客体回执后，精确Windows参数token+父PID/创建时间+原新快照+持有handles绑定且无其他会话时，只清理本次宿主后台，再作原严格退出检查。主体2GiB/guest90秒，host观察/清理/收集传剩余180秒时限，失败STOP，不换目录续额或改旧helper。
- 候选已准备/编译/冻结：固定e344基线生成副本仅换scope literal，另加独立核验生成源码闭包、隔离helper及固定11项pins的driver；原执行源码不修改。23项定向Python、编译、AST解析及非作者Codex复核有界支持，真实新生命周期未运行。manifest/binary及原始输入见唯一进度细表和LOCAL_ONLY候选原证，不上传原件。

本提案只等待这一次新范围的Owner决定，不重问既有Debug APK/USB或普通工程许可；尚无新claim。更后的真实产包预算/claim仍UNKNOWN_NOT_CREATED，资源/完整native/BAT/offline/AAR→host门各自保留。整版10 PARTIAL、AC05 OPEN、G2 false及真实消息Push PENDING不变。

同节点原产品Git同步已恢复：审全待推9提交/16路径后，既有origin/身份普通non-force推送至dd349a19253a72f26bfe00d8c191a953dd3b8dba成功并回读一致，main仍8a9e97a1；历史失败不重写，镜像不作Parent。此同步不授予新的运行余额，也不改变真实消息Push PENDING；同步记录最终提交以实际Git HEAD/远端核实为准。

## 2026-11-04 Owner明确授权单次复验及执行结束

Owner对上一个明确“新的独立最多1次生命周期复验”问题直接答复“我授权，请继续”。该决定已单独绑定v1015-full-input-mapping-lifecycle-recheck-20261104及原候选身份，不修改冻结历史提案合同/旧Source开关，不扩至SDK/Gradle/产包、DB、设备/媒体或新的运行范围。一般v10.1.5工程/Debug APK/USB既有许可保留，各实际资格与独立预算仍须成立。

此新scope已执行1/1、剩0：guest275/2457/2完成，但宿主直接CIM序列化的告警污染JSON，冻结driver返回STOP。后续generic清理模板变量错误也在任何终止前拒收；主代理保留错误脚本，仅修两处私有变量、严格绑定后结束两个本次拥有的后台实例，无其他进程操作。新宿主helper经5项无VM互操作及只读复核；仅对现有回执作恢复验证，不再启动VM、不创建canonical PASS、不改判原STOP或退款。

原先PROPOSED_NOT_AUTHORIZED块保留为当时提案；本块与独立授权/claim/outcome是当前已批准且已耗尽的事实。没有新的继任scope或下一次额度。任何新的VM资格复验须另有明确独立范围；其余普通源码准备可继续，真实产包预算/claim仍UNKNOWN_NOT_CREATED。APK NOT_RUN、AC05 OPEN、G2 false、10 PARTIAL、真实消息Push PENDING不变，细项/原证见唯一进度细表最新节点。

## 2026-11-04 普通源码接续与新互操作候选（未获新VM授权）

Owner随后“可以请继续”用于普通源码和产包输入准备，不自动成为上一已耗单次的退款或第三次VM许可。新full_input_mapping_interop与固定scope `v1015-full-input-mapping-interop-recheck-20261104` 已具体准备，默认launch拒绝；manifest SHAc605ff5b03b8163408ad664120cdfe591ca8ff581bceb339cf8f98006233ff74、binary SHA8c59908fc2b6d2ad6a7bcf1d8d257be35cdabe0c32ae773cbad7aedcc40d6ac2。13项无VM/stub互操作通过，实际全链NOT_RUN，无新授权文件或claim。旧helper/合同/STOP不修改，不重新prepare或换目录续额。

如Owner另行明确同意，本候选仅提议独立最多1次mapping-only复验：273只读根/2已拥有写面、275读取/2457权限拒绝、guest2GiB/90秒、host观察/收尾/收集共享180秒剩余时限，含精确owned宿主收尾；不运行SDK/Gradle/Flutter产包、数据库、设备、媒体或外部服务。启动前仍fresh核源/输入/当前环境，不借旧额度；当前状态SOURCE_READY_NOT_AUTHORIZED。

普通准备另完成32文件fresh身份与新私有Gradle资源候选，不修改旧-Xmx8G项目文件；拟生产guest6GiB+宿主reserve4GiB，快照可用4474MiB，余量不足。此候选不是上项2GiB映射检查，也不是实际产包授权/资格。guest OS/native/DLL/offline/AAR→host及实际产包独立预算仍待闭合；不结束用户应用、不安装升级工具链。细项及LOCAL_ONLY原证见唯一进度细表最新节点。

## 2026-11-04 Owner明确授权独立1次映射复验：已执行并耗尽

Owner直接选择“授权这独立 1 次复验”，对应上述固定interop候选及原问题所列273RO/2owned、guest2GiB/90秒和host观察/收尾/收集180秒范围。独立grant保存原问题、原答复、source95cad6ce及manifest/binary，原SOURCE_READY_NOT_AUTHORIZED候选合同保留为历史；本决定不扩至SDK、Gradle、产包、DB、设备、媒体或下一VM。

本次实际启动1次，50.734秒完成，275读取/2457拒绝/2私有写面及精确owned宿主收尾通过；当前Sandbox进程缺席，canonical verified-result生成，状态INTEROP_MAPPING_LIFECYCLE_BOUNDED_SUPPORTED。**本次1/1已耗、剩0**；旧STOP及已耗helper身份不动，不退款/重跑/换目录续额。后台VM完全teardown仍UNKNOWN，完整native/DLL/offline/资源和生产读集仍未证明；G2不因此放行，真实AAR/APK未生成，实际产包预算/claim UNKNOWN_NOT_CREATED。最新保护记录59份，原证与唯一细表按本节点保存，不上传LOCAL_ONLY。
