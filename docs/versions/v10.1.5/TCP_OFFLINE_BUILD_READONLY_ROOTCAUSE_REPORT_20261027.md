# EliteSync v10.1.5｜TCP构建停止只读根因报告

日期：2026-10-27（Asia/Shanghai）。性质：零构建预算、旧证只读分析、文档候选；等待Astra独立验收。

**结论：`ROOT_CAUSE_NOT_PROVEN / INSTANCE_IDENTITY_NOT_PROVEN`。** 原JSONL支持TCP owner PID在触发采样中属于可回溯到构建根的父链，且此前连续462个采样没有身份字段变化；没有发现本次实际PID复用的正面证据。既存daemon日志进一步支持该PID承担嵌套Gradle构建角色，并记录Dokka为`connectivity_plus`生成文档。但没有进程创建时间、原子进程/socket关联、远端端口、组件调用栈或共享时钟的逐任务事件，不能证明同一进程实例，更不能将该TCP连接排他归因到Dokka、特定插件、下载或合法本地IPC。

本轮实际构建、Gradle/Wrapper/Flutter/AAR/Kotlin执行、构建入口执行、测试、设备/ADB/RTC、服务、实时观察器、Gate2/Writer/Serializer均为**0**。只运行读取字节、Hash、JSON解析和Git元数据的本地分析，以及授权的GitHub文档读取/发布。原真实构建预算仍为**已耗1/1、剩余0**。

## 1. 实时权威与身份

Owner本会话手动派发本诊断任务。新任务分支不是产品main；main上的旧状态快照不代表新预算。

| 对象 | 本轮只读核验身份 |
|---|---|
| 正式任务分支HEAD | `owner/v10.1.5-tcp-static-log-rootcause-20261027` → `48e6f33215335e55c9d98a17e6db3c08e4a9dedf` |
| 正式任务 | `V10_1_5_TCP_STATIC_LOG_ROOTCAUSE_LONG_TASK_20261027.md`，Blob `a67c7c37e3cea6d779cd1fd5f5571e16c7f840db` |
| 任务分支ACTIVE_STATE | Blob `5d963f46377c1ccc0ec579e5abce4c3eec6341df` |
| live main / Root | `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / `03b0ecfcc360e38a462539dd50690c64b663a21e` |
| main的ACTIVE_STATE | Blob `8ed237355ba6c577b81f48010d62911bface74b2`；其内容是2026-10-25历史交付状态 |
| 原构建候选 / 唯一Parent / Root | `cfddecc944a043b1d85361a954a692be0dd4ce23` / `12d4e284feea609935eab12c973f5fd2efbc2992` / `a0bdf4a3cec27a21293abad9a35f11981b0d5c48` |
| 真正执行源码 / 唯一Parent / Root | `12d4e284feea609935eab12c973f5fd2efbc2992` / `7674b5e60a219cb76aba387dd2cee85cae67bd0a` / `1fbd4a7a2de6dc56b42b0e3a51f7d74f712d7250` |
| 源码及原候选apps / services | `cea01309fa9da5f99ccc9829654c6ec279c8c343` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 冻结plan | Blob `7d3466b3be67135dc641cfee7c7faef78937ba03` |
| 原实施报告 / Manifest | Blob `71e039051ba0c6205f496444bc466d71f11a6fff` / `d91a50d3653ef6304b4f45e53ddb4a242dbce284` |
| Astra既有UDP语义复核 | Blob `7dab2d315c4e9ea48fa901ed737ebefdda2c6369`；其接受范围不是本次TCP原因裁决 |
| 已接受产品v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |

GitHub分支GET及独立`ls-remote`一致；Commit/Parent/Root通过GitHub Git对象GET核验，三个Root的apps/services条目均无截断。连续本地工作树保持在原候选和原分支，干净；不切换、不提交、不移动原候选分支。本报告计划以原候选为唯一Parent，单独发布`codex/v10.1.5-tcp-readonly-rootcause-20261027`文档分支，只增加本报告。最终文档Commit/Root/Blob和原字节回读绑定本任务LOCAL_ONLY的`final-readback.json`，不在报告内部制造自引用Hash。

## 2. 原件核验和证据等级

旧根标签：`v1015-single-offline-build-20261026`。实际位置沿用原Manifest、既有`final-readback.json`和本会话已核验入口，没有搜索其它项目或凭空补造文件。

- 原Manifest的33个`localEvidenceIndex`条目，及`actualBuild`直接pin的stdout/stderr/JSONL三个文件，逐字节SHA256及适用字节数均匹配。
- 原`result.json`对象与旧LOCAL_ONLY `final-readback.actualBuild`完全一致。与公开Manifest比较时，仅排除既有脱敏的命令/本地claim路径/PID列表和替代PID计数字段，其余字段完全一致，PID计数相等；没有把脱敏摘要误称为原始JSON全字节一致。
- 本轮扩展只读Hash索引共52个旧根文件。无历史pin的回执仅标“本次读取时的Hash”，不追称它们在上轮已获独立签名或全量原字节pin。
- 两个daemon日志按原调用的任务专用Gradle user home定位，只在该目录读取既存`daemon/8.14/daemon-*.out.log`。它们未被原候选按最终日志Hash pin；本轮新算Hash用于后续复核，证据强度低于原候选pin的JSONL。没有重建日志，也没有新增daemon。

核心最小Hash索引如下。`ordinary-debug-run/`记为`RUN/`；`DAEMON_INNER/OUTER`为本轮脱敏别名，不是实际文件名。完整52项索引及PID别名映射仅LOCAL_ONLY。

| 标签 | 字节数 | SHA256 | 历史pin |
|---|---:|---|---|
| RUN/stdout.txt | 9145 | `0fbc2c233ab87dd83f152c23e23f7ed58ddf59ee79481a3f2f7822d47fe346d5` | 原Manifest直接pin |
| RUN/stderr.txt | 102 | `6d3b8ee7dc564a062738d52cd5a473391565b56f664e9528daa54201b0fff5aa` | 原Manifest直接pin |
| RUN/process-network-private.jsonl | 1377453 | `19222dde39878d8a8f755db0f7d22b6903bb671d74c7b9d2e7e7dae6d5d5f0cd` | 原Manifest直接pin |
| RUN/result.json | 3138 | `7e75050b9e91f122a00c256a293df5e1295dc7ea6b330121367fdf858f18a512` | 本轮Hash；对象交叉核对如上 |
| RUN/process.json | 14 | `d8103c810a15336b9d6e346dedcb8500ebc9b16e075abbb2d9104ffad7088079` | 本轮Hash |
| RUN/invocation.json | 2067 | `f15798e35581b886905d5b04a718fabcb842c18f625e51a7c7365ddf066b4637` | 本轮Hash |
| RUN/stop.stdout.txt | 672 | `5071f8f3328bd40d6f45d2be54efd94aeda658e471ea2089aead7332102ad198` | 原Manifest索引pin |
| runtime-final.json | 949 | `e8e7e0b747167b1bebe61d2ace9cd2432ca11e2dfb88f6ab116a15689b11c88d` | 本轮Hash；原交付摘要交叉核对 |
| 原final-readback.json | 17972 | `236cf5bc0a5e72c95c6d02328e7859462b1dd69a9d5643969dde004dedf7eff3` | 本轮Hash |
| trusted-build-inventory.json | 22056229 | `3eafdc458ee7a0dd06b3a5e47fb1d26396aa30faac950732e82fd20c26f1c0c6` | 原候选库存pin一致 |
| DAEMON_INNER（TCP_OWNER） | 33629 | `448b268e7718101c1cca5ceb070467917a4dd746ade7ea3f95775f7f68434cef` | 仅本轮Hash |
| DAEMON_OUTER（P11） | 39782 | `20717ccf823c38fbf45cdb2a04331a9d7cb6b72f141284acdd678a4b51574677` | 仅本轮Hash |

旧claim SHA256仍为`07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`；`entry-dispatch.once.json` SHA256为`e320733499f3a5fd212d03b20f21a36991156c0100b634a8fedcf71169333e56`。不移除或改写两者。

## 3. 可重建的时间线与不能给出的误差界

以下序号均为原JSONL一基行号，时间为原`hostMonotonic`采样开始值，单位秒。

| 事件 | 原件位置 | 有界事实 |
|---|---|---|
| root Popen及pid记录 | `process.json`、`offline_debug.py:215-226` | pid在循环前记录；该JSON没有进程创建时间或Popen单调时间戳，不能重建精确启动时刻 |
| 首次样本 | JSONL #1，630313.062 | ROOT出现在进程快照；首末样本开始间隔87.813秒 |
| 外层daemon PID首次出现 | JSONL #54 | 别名P11，此后到#734连续出现 |
| 嵌套命令链出现 | JSONL #267 | P6（cmd）及P2（java）首次出现，此后连续出现 |
| TCP_OWNER首次出现 | JSONL #273，630345.484 | java.exe，此后到#734共462个连续样本；不是TCP首次出现时刻 |
| 最后一个未触发强停的样本 | JSONL #733，630400.734 | 主分类仅UDP观察，没有非回环TCP记录 |
| 唯一强停样本 | JSONL #734，630400.875 | TCP_OWNER的IPv4 TCP state5、public-or-other远端类别；同一样本仍有8条UDP端点行 |
| 保护停止、进程退出 | stop stdout/stderr、result、entry-exit、runtime-final | 旧入口exit90、Gradle child exit1；elapsed92.375秒；15个具名入口/构建PID在旧终态回执中已不存在 |

733个相邻采样开始间隔最小0.109秒、中位0.125秒、最大0.141秒，没有超过0.2秒的开始间隔。这是**采样开始间隔**，不是socket事件起点误差、检测延迟保证或每次采样耗时。进程快照、路径查询、四张网络表和日志读取不是原子操作，且没有各步骤结束时间；即使#733未记录TCP，也不能声称连接一定在两个开始时间之间建立。

总回执92.375秒覆盖Popen前计时到wait及结果整理附近，和87.813秒样本跨度的差不能全归为停止耗时。源码支持触发后离开循环并执行taskkill，但没有精确stop开始/结束单调时刻；`taskkill.returncode`未保存，stop stderr为空也不能补出该退出码。保留原stop输出与旧资源关闭回执，不宣称本轮重新查询了进程终态。

stdout共147行，解析出91个任务输出行，其中有重复任务标题；这些数字不是已完成独立任务数。stdout没有逐行统一时间戳。daemon的带时间戳启动记录使用墙钟，但原JSONL没有墙钟—单调时钟映射或误差界，因此不将daemon墙钟、文件mtime或末行顺序换算成TCP时刻的精确任务状态。

## 4. TCP PID关联与实例归属

为避免公开机器进程标识，以下只用本轮固定别名；原PID映射留在LOCAL_ONLY。

触发样本的同一次Toolhelp进程快照中，完整父链为：

`TCP_OWNER(java) → P2(java) → P6(cmd) → P11(java) → P1(java) → ROOT(cmd)`。

ROOT与TCP_OWNER均存在，链上每个节点都有可读取的imagePath。TCP_OWNER在#273～734的父PID、镜像名、镜像路径三元组只有一种取值，没有缺席后重新出现；其路径与原库存指定JDK的`bin/java.exe`一致，该可执行文件SHA256仍与库存pin一致。全部14个被采样PID各自的三元组也未见变化或在首次至末次出现区间内的缺席再入。

这支持`PID_LEVEL_BUILD_TREE_ASSOCIATION_SUPPORTED`，也使“本次仅因历史known中残留一个已不在触发进程快照的PID而命中”这一**具体解释**与触发样本不符。但它不能排除采样间或采样内部极短的退出/复用，更不能把路径相同等同于进程实例相同。

静态源码证据（执行源码固定于`12d4e284...`）：

- `windows_build_observer.py:55,86-93,109`：`known`只增不删；socket按历史PID集合筛选，没有创建时间或代际身份。理论上可把已退出PID之后的新实例或其后代纳入。
- `:67-120`：先Toolhelp快照，再逐PID打开/关闭路径查询句柄，再顺序读取TCP4/TCP6/UDP4/UDP6；进程列表与socket表并非同一时刻。OpenProcess或路径读取成功只支持路径查询时点，句柄未保持到socket关联完成。
- `:21-29,119-120`：原TCP结构有端口，实际输出只保留pid/protocol/remote/state。历史无创建时间、命令行、local/remote port、组件栈；不能事后恢复。`REMOTE_PORT_NOT_CAPTURED`。

既存DAEMON_INNER日志中，4处self-pid字段与TCP_OWNER数字相同，#152-155/#163/#168的构建目录属于任务Flutter模块`.android`，#173记录执行构建，#182记录Dokka为`connectivity_plus`生成文档。DAEMON_OUTER自报PID对应P11，构建目录为外层Android项目。这加强了角色关联，却没有补齐Windows进程创建时间；而且两个daemon日志只有本轮新Hash，不能提升到已被旧候选pin的实例证明。

因此：**`INSTANCE_IDENTITY_NOT_PROVEN`；没有证据支持本次已经发生PID复用，也没有足够证据彻底排除它。** 本轮没有通过当前系统进程查询冒充历史时点证明。

## 5. Gradle阶段、Dokka与网络归因

原调用是本地Gradle8.14的普通`:app:assembleDebug --offline --console=plain --no-daemon --max-workers=2`，工具链自动下载禁用。源码`apps/android/app/build.gradle.kts:245-272,302-303`表明`preBuild → syncFlutterAar`；普通R1分支直接调用本地Gradle，加载Flutter AAR init及本项目offline init，执行`assembleAarRelease`。外层Debug与内层Release AAR并不矛盾；这一分支不走Flutter CLI/Wrapper。

原stdout的有界阶段证据：

| stdout行号 | 可证实阶段 |
|---|---|
| #25 | 外层`:app:syncFlutterAar`输出 |
| #32 | 嵌套构建工具的`:gradle:compileKotlin`输出；不是整个APK编译完成证明 |
| #42及后续 | 多个插件的AAR/资源/编译/发布准备任务输出 |
| #94、#101；#95-107 | `:connectivity_plus:javaDocReleaseGeneration`及Dokka文档模型、页面和渲染进度，证明文档路径实际执行过 |
| #109及后续 | `device_info_plus`编译和相关任务输出 |
| #146-147 | `:flutter:assembleAarRelease`及`:flutter:cleanMergeReleaseAssets`显示UP-TO-DATE；不能据此声称整体AAR发布或APK完成 |

现有`offline_debug.init.gradle:5-12`仅检查nested offline并移除MavenPublication中classifier为javadoc的artifact；它没有禁用所有文档任务或所有网络访问。**该方法在这次运行中没有阻止上述Dokka任务执行**，这是日志支持的具体限制。不能将“artifact已移除”写成“Javadoc路径完全未运行”。但当前证据没有证明是某条发布依赖边导致该任务进入图，或哪个组件打开了目标连接。

额外只读核对既有库存中的Flutter `aar_init_script.gradle`（SHA256 `b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`）：#87-105创建AAR任务/发布并挂`finalizedBy publish`；#176-187配置插件AAR依赖。这解释了嵌套AAR含发布任务的静态机制，**不补造完整运行任务依赖图**。没有执行任务图命令。

JSONL只观察到一个非回环TCP state5 endpoint，地址归类为public-or-other、非RFC1918/loopback；不公开具体地址。该地址字面量未见于所读stdout和两个daemon日志。没有端口、HTTP请求、URL对应、TLS/调用栈或payload，不能做DNS/远端服务猜测，也没有发起任何探测。公开网页链接或仓库声明本身不等于本次网络访问。

`downloadLogObserved=false`只表示旧规则未匹配；stderr的原Java registry-key WARN保留。Dokka进度与TCP出现在同一次构建中，仅构成候选调查方向，不构成因果归因；并行任务及无逐行时间戳进一步限制了时序解释。

## 6. 假设对照与结论等级

| 独立结论类别 | 等级 | 支持/反证和缺口 |
|---|---|---|
| `PID_REUSE_MISATTRIBUTION` | POSSIBLE；本次发生UNVERIFIED | known累积且无创建时间构成静态风险；但JSONL #273-734连续、三元组不变，#734当前父链完整，没有实际重用正面证据 |
| “目标PID只剩旧known残留，触发快照已无该进程” | CONTRADICTED（仅这个具体版本） | #734包含TCP_OWNER及其完整当前快照父链；不排除快照之后退出的race |
| `GRADLE_PLUGIN_OR_TOOL_NETWORK_BEHAVIOR` | POSSIBLE；具体组件UNVERIFIED | daemon自报身份、目录及Dokka进度提供嵌套构建上下文；无连接调用栈/端口/统一任务时钟，不能指认Dokka或插件 |
| `OTHER_OBSERVED_CONNECTION` | SUPPORTED（端点表事实）；用途UNVERIFIED | #734捕获非回环IPv4 state5 owner PID；没有证据表明是payload/下载或可接受的内部例外 |
| “该捕获endpoint只是loopback daemon IPC” | CONTRADICTED（针对该行地址类别） | 该行不是loopback；不能把其它合法本地连接解释套用到此行，亦不据地址类别证明payload |
| `ROOT_CAUSE_NOT_PROVEN` | SUPPORTED | 实例身份、组件调用、端口和任务同步缺口仍在；没有足够证据选择唯一原因 |

## 7. 最小后续选项——仅建议，未实施

1. 若Owner另行授权源码修正，观察器可按`(PID, creationTime)`维护活动实例、历史实例和经核验的父实例；采样前后核对身份、保留必要句柄，并区分进程已退出与观测失败。不要简单清空旧PID就宣称解决问题，那可能丢失合法孤儿后代。该修正有静态依据，但不能倒改本次历史归属结论。
2. 若Owner另行授权增强观测，LOCAL_ONLY记录进程/socket读取各自起止单调时间、必要命令行、实例创建时间和端口，以及与Gradle任务事件同一时基的关联；敏感字段不进入公开报告。未知归属仍fail-closed，不能新增TCP白名单或削弱强停止。
3. 文档任务路径若另获修复授权，优先调查为什么已移除javadoc artifact后仍执行`javaDocReleaseGeneration`，据真实依赖关系限定可排除的文档生成/外部文档解析路径；保留运行AAR/POM和完整必要产物。**当前只提出方向，没有足够证据交付某个确定补丁，更不能声称该方向会消除本次TCP。**

以上均不授权新运行。实现、隔离测试、任务图验证或任何真实构建都必须由Owner后续另行明确派发；本报告不创建后继任务、不请求自动预算、不安排重试。

## 8. 保护、检查性质与证据来源

本轮读Hash核验26784份具名历史保护文件、5个历史Git根（包括受保护dirty根）、524个开工refs中的既有保护项一致；另核52个旧根证据文件及旧claim。范围是具名清单和根状态/索引摘要，不是整盘审计，不是本轮重做运行终态普查。两份既有实施报告/Manifest原字节不改，原候选、源码、冻结计划、所有历史失败/SQL/APK/LOCAL_ONLY保留；7,941,328字节partial及其SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`继续保留。

本轮分析读取器曾因错误假定“脱敏Manifest与原始result对象完全相等”触发AssertionError/exit1；检查字段后确认差异限于既有脱敏字段，改为比较原LOCAL_ONLY回执及未脱敏公共字段，解析完成。补充索引检查还曾因历史清单含另一同名partial而触发唯一匹配AssertionError/exit1，随后以本任务指定字节数及Hash精确定位并核对，两个原件均未触碰。另一个本地批量`git show`无法读取本地未存储的main对象，保留fatal记录后改用GitHub只读对象GET核验。这些均为本轮分析工具的检查/调用问题，不是重跑构建、产品测试失败或原证Hash漂移；本轮没有运行任何测试来替代诊断。

证据类别严格分开：

- `ASTRA_DIRECT_GITHUB`：既有UDP语义接受记录和本任务中列出的Astra初步静态发现；不声称Astra读取了Windows原始日志或已接受本报告。
- `CODEX_REPORTED_LOCAL_READ_ONLY`：本轮Hash、JSONL统计、父链/时间线、daemon角色和源码读取结论；本报告由Codex负责解释，Astra仍需独立验收。
- `LOCAL_ONLY_RAW`：原始stdout/stderr、socket/进程行、绝对路径、PID映射、daemon原日志及本轮完整索引；公开仅有脱敏事实、相对标签和Hash。
- 外部技术文档：Microsoft的[MIB_TCPROW_OWNER_PID](https://learn.microsoft.com/en-us/windows/win32/api/tcpmib/ns-tcpmib-mib_tcprow_owner_pid)说明state5为ESTABLISHED及owner PID字段；[进程句柄与标识](https://learn.microsoft.com/en-us/windows/win32/procthread/process-handles-and-identifiers)限定PID有效期。Gradle[Dependency Caching / offline](https://docs.gradle.org/current/userguide/dependency_caching.html#sec:offline-mode)明确讨论依赖解析缓存；所读current页为9.8.2，仅用于范围解释，不冒充本次8.14运行原证，8.14文档URL本次工具不可读。上述文档不证明本次传输了payload，也不把offline解释为进程级防火墙。

非作者GPT-6.1 Sol/high只读复核了四个指定源码文件，确认PID实例/非原子采样/端口缺失及嵌套Release AAR的静态边界；未读取LOCAL_ONLY原日志、未运行测试/构建/设备、未形成Astra裁决。最终报告再经有界事实/措辞交叉检查；执行与独立验收保持分离。

最终保持：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED / ROOT_CAUSE_NOT_PROVEN`。

仅交付本报告及其中Hash索引。普通文档候选发布、Commit/Parent/Root/Blob及原字节回读完成后停止，等待Astra独立验收；不合并产品main，不启动v10.1.6。
