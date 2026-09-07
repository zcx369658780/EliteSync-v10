# EliteSync v10｜M3 执行条件收敛决定 v0.2

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — NO EXECUTION OR IMPLEMENTATION AUTHORITY`

日期：2026-09-07。结论：**B — OWNER SCOPE DECISION REQUIRED**。

现有权限禁止读取环境、缓存、生成平台状态以及创建隔离环境，故下一张任务不能在原权限内直接收集所需事实。官方资料已足以否定“加离线选项即可安全执行”的前提，并提供可选的操作系统隔离机制；本地适用性、输入绑定及新增权限仍缺。推荐§4选项1，一个集中范围决策包；不再提出同义方法研究任务。B接受只接受决策材料，M3仍blocked。

## 1. 固定依据与新增证据

- 实时main M：`bb2027ce077b00deb2fdaa1161f357d303ef8cd0`，匹配。
- FIRST主动读取转型交接，blob `18485c95262051e43892436fb52413132c5ee626`，匹配。
- 任务T：`2c2d1dcf3d501ab1de01480238c71ef6c8ef4544`；task ref匹配，唯一父M，ahead_by=1、behind_by=0，仅新增任务单。
- 任务blob：`0da93232427233f7f9ab94524591ced7987db575`；任务tree：`c77134816a7f50378687e2daba1fc4e2d4bdd896`。
- §4项目输入均按固定blob核对：AGENTS f9ef1a7；指令接受a84337d；CURRENT_CONTEXT f917506；预检a012c61；方法46b8183；旧任务8309341；历史handoff fb48743（只采用§§2–7）。
- 指令修订关口已由固定M中的接受记录关闭；8/8本地同步仅为Owner转贴执行者报告，本轮未复测。
- 已接受预检 `Outcome B — execution remains blocked` 保持。direct Flutter AAR类别保留，但“Gradle缓存NO ACCESS”和“仅build写入”不能恢复为执行前提。
- 本次增量：固定官方Flutter revision的调用控制、pub离线写入、Gradle wrapper/bootstrap及清理行为、Windows Sandbox网络/映射机制，并把其转化为一个权限选择。

## 2. 四项必要判断

### 2.1 网络控制：开关不等于进程树隔离

| 层 | 官方依据与判断 | 未证明事项 |
| --- | --- | --- |
| Flutter runner | S2的shouldUpdateCache=true；缓存updateAll先于pub，offline取决于命令是否注册该选项，否则false。S1启用默认pub。 | 不把AAR命令宣称为支持全链离线；本地版本与此revision未核对。 |
| pub | --no-pub关闭runner的预先pub get分支；D7的pub --offline只从已有包缓存求解，仍可能写lockfile和package_config。 | --no-pub不关闭Flutter缓存更新、内部Gradle、wrapper或其他联网；它也不证明包配置可用。 |
| 内部Gradle | S3 buildGradleAar实际调用wrapper入口；所读组装路径没有确立对内部Gradle传递--offline的接口。D2的--offline禁止依赖解析联网，缺缓存则失败。 | 不把GRADLE_OPTS/JVM选项臆造为Gradle --offline透传；--offline不保证任意插件/任务/其他进程不联网。 |
| wrapper bootstrap | D3：需要时先下载声明的Gradle分发包，通常缓存于GRADLE_USER_HOME。 | Gradle依赖离线开关不证明wrapper已有分发包，也不是bootstrap网络阻断机制。 |
| 操作系统边界 | D8：Windows Sandbox配置Networking=Disable禁用沙箱网络；ReadOnly=true强制只读共享。 | 尚未检查本机支持、配置应用或所有相关进程是否在沙箱内；shell退出0不是隔离验证。 |

--no-pub可减少一条分支，不是必须盲加的修复：S1/S2显示平台工具再生成回调也受shouldRunPub影响。已有包配置或生成状态缺失时跳过pub可能直接失败。未来合同须依据冻结输入明确是否加此选项；不得本轮试错。
S3还包含失败后的Java/Gradle兼容检查以及Android provisioning参数调用。必须约束整个Flutter父子进程，而非只约束顶层命令；不追查更多源码来穷尽所有内部文件。

### 2.2 缓存与写入：以可验证边界收敛

| 状态类 | 已知读写/控制 | 推荐未来边界 |
| --- | --- | --- |
| Flutter SDK | S5：SDK bin/cache含lockfile、stamp、下载与artifacts；缓存路径依赖实际Flutter root。 | 使用专用离线SDK副本，整份副本位于隔离客体内；不能只重定向pub缓存就宣称SDK无写入。 |
| pub | D6允许PUB_CACHE重定向；D7说明包缓存、锁文件和包配置写入。 | 客体专用PUB_CACHE；模块副本内允许必要生成状态写入，原模块不写。 |
| Gradle user/daemon/wrapper | D4/D5：GRADLE_USER_HOME含配置/init、caches、daemon日志、wrapper/dists、可能的jdks；D5说明自动清理，--no-daemon仍可能前台清理。 | 专用用户目录与GRADLE_USER_HOME；不借用宿主daemon或共享可写缓存；无daemon不等于无写入。 |
| Gradle project | D5有项目.gradle缓存和清理。 | 隔离模块副本内的项目缓存；不把user-home重定向当作project缓存隔离。 |
| 模块build/.android | D1/S4说明.android是生成状态；S4可能删除再生、更新local.properties、注入wrapper；S3输出本地Maven repo。 | 将模块副本、其build/.android及其他必要工具状态纳入客体可写范围；不在原根以build/**作为完整allowlist。 |
| 其他临时/用户状态 | 本轮未取得完整清单。 | 由客体文件系统边界容纳；客体仅映射批准的输入和独立日志输出，不能读写宿主其他位置。 |

SDK/缓存路径分开只解决位置，不证明其中有兼容依赖。无网且空缓存可能失败，这是输入不足或受控尝试失败，不是集成无效。旧原地方案在不看受保护状态的条件下尚无安全写入证明；不声称原地执行理论上不可能。
专用隔离允许内部正常生成/替换临时文件，但不允许agent清理宿主、源文件、缓存或失败证据。工具固有清理只能发生在获批的客体可写范围。

### 2.3 下一次最小前置证据合同（建议，当前不执行）

当前确定：历史证据根D:\EliteSync-v10；历史方法cwd为D:\EliteSync-v10\apps\flutter_elitesync_module。这是文档绑定，不是本地存在性。
下列具名字段是待Owner提供/批准的合同字段，**不是已设置环境变量，不是可执行占位命令**：

- M3_SOURCE_SNAPSHOT：批准的不可变来源和精确输入清单；禁止用旧HEAD或全仓复制替代，排除README/FD02/旧源/受保护状态。现未取得该清单。
- M3_FLUTTER_SDK_PATH、M3_JAVA_EXE_PATH、M3_ANDROID_SDK_PATH、M3_PUB_CACHE_SEED、M3_GRADLE_HOME_SEED：Owner指定已有离线输入的绝对路径、版本/来源记录；本轮全未知，不枚举自动发现。
- M3_FULL_AAR_ARGUMENTS：原release-only命令的完整dart-define键值及其他参数；本轮许可原文只出现“既有参数”，无完整值，未搜索源码补全。
- M3_EXECUTION_EXPECTED_LOCAL_HEAD：若未来继续引用原工作树，须预先绑定新值并另授权两个Git元数据读；隔离快照则记录来源revision与manifest，不冒称原HEAD等于main。
- M3_ISOLATION_CONFIG、M3_OUTPUT_LOCATOR、M3_ATTEMPT_ID：准确配置文件、与新尝试绑定的唯一产物定位符和尝试ID，均未提供；不得用历史M1目标代替。

| 下一任务检查 | 路径/cwd/方法 | 后果、成功与停止 |
| --- | --- | --- |
| 输入声明闭合 | 先读Owner提交的上述值与精确manifest；无工具链调用 | 文档读取；无本地cache读写；任何缺值停依赖步骤，保留可用输入。 |
| 精确存在性 | 仅对manifest列明SDK/Java/Android/seed/配置绝对路径，使用直接文件元数据查询；cwd固定D:\EliteSync-v10，禁递归 | 无文件内容、无工具链执行、无网络；只报存在与类型。缺失/类型错停止，不自动安装或换路径。 |
| 控制配置 | 只读批准的单个.wsb XML及映射路径绑定；不读宿主环境变量 | 确认禁网、只读输入、唯一日志可写映射、剪贴板等重定向禁用。配置文本只证明声明；实际控制未证实时停在PRECONDITION BLOCKED。 |
| 隔离适用性 | Owner提供现有可用Sandbox能力与配置生效证据；若需本地OS查询，下一任务必须先列出那条精确查询及权限 | 不执行Flutter/doctor/version来“检查”；本轮官方预算未证明本机能力，不自动安装Windows功能。 |
| 准备与尝试入口 | 仅在§4权限获批、manifest/命令/控制验证已绑定后，于客体C:\M3\work\apps\flutter_elitesync_module | 客体工具运行有缓存/生成写及联网尝试可能，但外部网络必须被阻断；源/宿主保护不满足则不启动。 |

这些检查不能证明缓存足够、工具兼容或构建会成功。可在一张后续有界任务中合并“精确输入确认→获批隔离准备/控制验证→条件式一次生成→新鲜定点产物证据”；不是必须再拆四张治理单。缺少精确值时只能发收集缺值的有界合同，不能发伪装完整的执行命令。

### 2.4 结果语义

| 观察 | 能证明什么 | 不能证明什么 |
| --- | --- | --- |
| 路径/配置/控制检查通过 | 特定输入存在或特定控制已验证 | 缓存依赖充分、兼容性、生成成功 |
| 授权命令实际退出0 | M3 GENERATION COMMAND SUCCESS | release产物已证明、宿主依赖解析成功或app可安装 |
| 与新attempt绑定的一个定点存在性结果 | 该定位符在该次生成后命中/未命中 | 产物内容、有效性、可安装性；不得重试历史M1 |
| M2特定宿主依赖解析成功 | 仅该上下文和目标的解析结果 | 产品实现或可试用app完成 |
| 另获实现范围后的安装演示 | 该平台/样例流程的可安装演示 | U-08/U-10实证、真实内测或生产准备 |

M3内部Gradle可能解析构建依赖，这是M3工具固有行为，不等于完成宿主M2证据门。非零退出归生成命令失败；未启动归前置阻塞；超时/中断单列；证据不足归INDETERMINATE。均不推出INVALID INTEGRATION。

## 3. 官方实际读取账本

读取日期均为2026-09-07。预算：8个官方正文页面、5个成功源码文件、1个源码404尝试，按14个不同目标计，停止补读。
Flutter stable首先经公开ref API解析为不可变revision `d3b14c876900e553bc736ca19295fc09e3853e8e`；本地SDK版本及其适用性未实测。Gradle current页面展示9.7.1相关示例，不将其绑定为本地Gradle版本；其他网页无不可变发布revision可证。

| 编号 | 实际URL/章节 | 采用范围 |
| --- | --- | --- |
| D1 | https://docs.flutter.dev/add-to-app/android/project-setup — module / AAR集成 | .android生成属性、build aar、本地Maven输出类别 |
| D2 | https://docs.gradle.org/current/userguide/dependency_caching.html — Using offline mode / cache | 依赖离线、缺缓存失败 |
| D3 | https://docs.gradle.org/current/userguide/gradle_wrapper.html — Using wrapper | bootstrap下载和本地分发复用 |
| D4 | https://docs.gradle.org/current/userguide/build_environment.html — precedence / environment / properties | GRADLE_USER_HOME、JAVA_HOME并非唯一JVM来源、daemon配置 |
| D5 | https://docs.gradle.org/current/userguide/directory_layout.html — user与project状态、daemon/wrapper、自动清理 |
| D6 | https://dart.dev/tools/pub/environment-variables — PUB_CACHE | pub缓存重定向 |
| D7 | https://dart.dev/tools/pub/cmd/pub-get — cache / offline | 求解、缓存与lockfile/package_config写入 |
| D8 | https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file — Networking / Mapped folders / Clipboard | OS禁网、只读映射、重定向控制 |

以下URL均固定到上述revision：
`https://github.com/flutter/flutter/blob/d3b14c876900e553bc736ca19295fc09e3853e8e/packages/flutter_tools/lib/src/` 加表中精确后缀；不沿import递归。

| 编号/后缀 | blob / 章节 |
| --- | --- |
| S1 commands/build_aar.dart | 67561f9ce1049e2777e962f0316af7c246de8708；构造器、runCommand |
| S2 runner/flutter_command.dart | 1671d157bcc4615a261d4fd38fe10f1bdf472a45；usesPubOption、_updateCacheAndRunPubGet、再生成回调 |
| S3 android/gradle.dart | 2160418c15eea130b84c22799c6d370d5a858827；buildAar/buildGradleAar |
| S4 project.dart | 1c4e753d531ce46f7b3e48cf9b14b4b77c72e3de；AndroidProject host root/再生成 |
| S5 cache.dart | ec17a559048ae758dbdf1d7b9fb17267a1b7ca46；lock、getRoot、updateAll |
| 未取得 runner/options/common_options.dart | 固定revision返回404；不换路径搜索。pub默认值由S2直接取得；不依赖旧版本选项文件推断新版本接口。 |

## 4. 一个最小Owner范围决策包

**推荐选项1：批准“无外部网络的隔离证据范围”，同时补齐§2.3精确绑定；不直接批准在原工作树运行。**

| 选择 | 新增范围及后果 |
| --- | --- |
| 1（推荐）离线隔离证据 | 批准下一合同对Owner具名输入作精确元数据读，并在条件闭合后准备隔离副本；可把一次M3及新定点产物证据纳入同一明确执行授权。无下载、无真实数据、无原仓库写入。 |
| 2 保持现有范围 | 无新增环境读取、写入、网络或隔离；保留本报告和同一blocked条目，M3/M2无新证据，不反复下达同义研究。 |

选项1的具体边界建议（全部待批准；本轮未创建）：
- 宿主专用根建议D:\EliteSync-M3-readiness-v02，输入D:\EliteSync-M3-readiness-v02\input只读映射；日志D:\EliteSync-M3-readiness-v02\evidence是唯一客体可写宿主映射；配置为该专用根内m3.wsb。这些位置是提出的新授权，不是已存在事实；存在未知内容则停止，不覆盖。
- 不映射D:\EliteSync-v10或用户主目录。由Owner提供无保护内容的精确manifest输入；任何由执行者物化/复制的来源和路径须在同一授权中列清。不全仓clone、打包或读取默认index；不包含README、FD02、旧仓库或其他受保护来源。
- 客体建议C:\M3\work作为新执行证据根，C:\M3\tools为已有离线工具副本，C:\M3\pub-cache、C:\M3\gradle-home、C:\M3\temp为专用可写状态；客体用户状态也属隔离写范围。只读输入复制至客体后工具方可写；不得将宿主SDK/cache直接可写映射。
- 外部网络授权为零：Networking=Disable；所有Flutter/pub/Gradle/wrapper及后续进程必须在客体内；禁用剪贴板、音视频/打印等无关重定向，不能用宿主daemon/代理绕过。没有控制生效证据就不运行；不以联网探测替代。
- 新证据根只证明该隔离快照，不能回填原D:\EliteSync-v10的M1结果。旧M1 lane不动；最终产物定位符和一次存在性方法必须与新attempt一起明确批准。
- 允许的工具固有读取限manifest模块/工具/seed副本及必要客体系统文件；允许内部Gradle/pub行为不增加agent源码阅读、M2宿主解析或实现权限。缺离线输入时停，不自动联网补齐。
- 条件式M3若获明确批准：最多一次顶层生成，30分钟上限，无agent重试；整个进程树受控，超范围要求/失去隔离立即停止。精确命令未绑定前禁止启动。
- 日志在运行时写到专用evidence；失败/超时保留日志和客体局部状态，不执行清理。关闭临时沙箱前，必要证据须已按批准清单保存；未保存的客体状态不宣称可恢复，不擅自全量导出。
- 需Owner一次确认的是新增精确读取、隔离位置/写范围及证据根变化，并提供缺失输入。若只批准元数据读，则在元数据报告处停止；后续生成仍需明确命令授权，不能借“选1”隐含补全未知命令。
- 本地Sandbox支持、离线工具/依赖输入、完整参数及实际隔离均未证实。无下载选项可能无法生成；这是可保留的结果，不是批准联网的隐含条件。

## 5. 历史处置、发布和停止

新任务T取代旧任务8b640576822b01ae00bb04b9b5deaa75db53365c的未来用途；旧任务只作合同比较，保持未执行，不恢复其发布或执行指令。报告是作者候选，非独立ACCEPT。
两个输出只新增本报告及限定CURRENT_CONTEXT页首/§1/§4/§5/新增§7；§2、§3、§6原文原样保留。§6末句是旧修订历史时序，由新§1说明已接受状态，不篡改受保护原文。

M3 blocked，M2 deferred；M1 False / WORKTREE-STATE NON-HIT ONLY且冻结lane耗尽。D-02/D02-DURABLE-UNKNOWN-01、U-14、U-12、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、deferred PUI、PUI-PREREQ-12=0、legal/Safety/no-processing、implementation/LC-03/LC-04/Phase36边界保持。
本轮只有固定项目文档、官方正文及Git元数据读取与两文件GitHub候选发布；未运行任何工具链、前置诊断、环境/cache/生成输出检查、artifact probe、M1重试、隔离创建、下载依赖、技术设计或实现；未操作本地index/工作树。
Owner声明宿主选择GPT-6 Astra；可见宿主身份为基于GPT-6的Codex，未独立读取model ID或完整加载链，未改配置、未调用其他模型或辅助代理，不宣称当前会话重载或整仓clean。
发表后停止；不自我接受、不更新main、不另发任务、不更新或上传ChatGPT项目源。