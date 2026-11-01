# v10.1.5 当前产品离线配置诊断提案

日期：2026-11-01（Asia/Shanghai）。状态：**OWNER_AUTHORIZED_MAX_3_OFFLINE_CONFIG_DIAGNOSTICS / ORIGINAL_3_OF_3_CONSUMED / NEXT_SCOPE_PROPOSED_NOT_AUTHORIZED / G2_FALSE**。

Owner已通过当前会话的具名问题明确答复“授权上述独立3次诊断范围”。这是独立于旧G2的新配置诊断授权；不恢复网页派单或网页验收，技术前置仍须成立。Codex负责实现、调试、测试与工程裁决。Owner此前对v10.1.5、USB及现有Docker/WSL的授权保留；本提案只处理旧特殊构建额度不能迁移到当前产品的问题。

## 需要Owner决定的差异

[旧G2合同](../versions/v10.1.5/V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md) Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`明确固定6ca源码、一次真实Gradle dry-run，禁止用该额度探索未闭合输入，不允许改原guard。当前产品源码及apps Tree不同；旧guard要求included tooling与stock flutter-root派生路径完全相同，私有tooling真实路径不同，虽然快照内容相同。不能拿旧额度直接验证当前产品、删guard或把当前source假标成6ca。

提议**另立当前产品离线配置诊断范围与独立最多3次真实Gradle启动额度**，允许在只读输入/隔离写面中诊断现有依赖索引和配置缺项，以及实现专用guard以固定stock SDK与分置private tooling两个精确根。原guard、原G2源码、旧额度和STOP账本全部保持；新结果不记为旧G2通过。

## 固定输入及允许工程改动

- 产品source `84a94c9177ce832040146cff9968569762300307`；apps `ed24852975baebeadc66f007dfb75ff9e31a97d4`；services `7634b4755a41f08641e00948f684c06efb12d8fe`。后续工具/文档提交可变，但这两棵产品树不得静默替换；需变更产品行为则先另记原因及受影响检查。
- 仅使用已有Flutter3.41.7、JDK17.0.18、Gradle8.14、Android SDK及现有Pub/Gradle缓存；禁止下载安装升级、修改共享输入或全局安全设置。版本标签不能替代源码/二进制身份，实际入口及依赖须在claim前固定到manifest。
- 新任务私有目录内可生成必要路径适配：local.properties、package/plugin引用、settings included tooling、专用配置guard/init及输出路由。逐文件保留原文/差异/hash/来源，不覆盖stock SDK、Pub、旧Seed或产品工作面。旧6ca guard仅作固定合同对照，不修改或部署为已通过入口。
- guard同时固定模块根、stock SDK根、private tooling根、源码树、tooling源字节与许可证、唯一任务/参数/init顺序、included child来源；不接受任意目录白名单、junction、符号链接或非规范路径。private tooling源快照与其可写build/cache分列。
- 诊断允许“现有缓存不能离线命中”成为运行结果，而不要求在第一次启动前已证明该命中；但已知输入来源、可读范围、输出隔离和执行器/观察器安全条件必须先成立。不能把诊断许可解释成未知外部工具或任意宿主读写许可。

## 唯一运行类型与有限重试

拟在禁网Windows Sandbox中使用已有Gradle8.14 CLI，通过JDK原生进程启动；不运行wrapper、Flutter CLI、外层Android app或任何实际AAR/APK任务。逻辑命令合同为：

```text
<existing-java> <fixed-JVM-options> -jar <readonly-gradle>/lib/gradle-gradle-cli-main-8.14.jar
  -I <current-product-config-guard-and-routing.init.gradle>
  -I <pinned-AAR-registration.init.gradle>
  -Pflutter-root=C:\Inputs\Flutter
  -PelitesyncDiagnosticToolingRoot=C:\BuildWork\Tooling\packages\flutter_tools\gradle
  -PelitesyncDiagnosticProjectRoot=C:\BuildWork\Project
  -PelitesyncDiagnosticScope=v10.1.5-current-product-config-20261101
  <fixed ordinary module target/lib-main, arm64, build-number, encoded v1015+v1014 defines and owned output properties>
  --offline --console=plain --no-daemon --max-workers=2
  --gradle-user-home C:\BuildWork\GradleHome
  --project-cache-dir C:\BuildWork\state\project-cache
  --dry-run assembleAarRelease
```

这是范围合同，**尚无可执行runner**；尖括号必须在实际运行前落实为唯一参数向量并绑定hash，禁止直接复制上述占位文本运行。cwd固定`C:/BuildWork/Project/apps/flutter_elitesync_module/.android`；JDK自动下载关闭，GRADLE_RO_DEP_CACHE指向只读Seed base。允许注册任务的init必须固定来源/字节/完整差异，不能借“registration”执行任务动作；私有输出/CMake staging在DSL定型前显式路由并收集消费证据。

- 最多3次，使用单一新任务账本，逐次在任何真实Gradle创建尝试前原子占用对应序号；Popen失败、非零退出、强停及诊断无结果均计数，不退款、不换目录绕过。新账本与四份旧G2账本完全分开。前置未过不占启动次数。
- 每次最多1200秒。普通配置/缓存错误可由Codex在上述私有适配范围内修复并使用下一次剩余额度；每次先封存原输入与失败，再绑定新版本/hash。额度耗尽即停止动态分项，不另开新task续额。
- 观察器失效、未知进程/镜像、输入漂移、网络/下载信号、越界写或无法可靠收证属于安全停止：仅终止自有Job并保留原证；**不得原样自动重跑**。先暂停动态分项，完成静态定位、修复、定向检查与原因报告；只有原因已明确、修复未扩大权限、新输入manifest及全部安全前置重新成立时，Codex才可决定使用本任务剩余额度接续。原因不明或条件未闭合则保持NOT_RUN；涉及Owner保留权限须针对性授权，禁止减少监测、放宽身份判定或换task补额度。

## 技术前置与保护

现有装配28拒写/6096哈希/19私有写读通过，仅为有界FS证据；现有观察器只验证自身synthetic镜像。授权本提案不自动让runner/完整Gradle树观察器合格。

Codex须先完成并检查：精确映射/源与执行镜像库存、清理仅子进程的注入环境、root挂起先归入kill-on-close Job、进程句柄/创建时间/镜像/Job归属绑定、所有实际子镜像的精确身份、持续TCP/UDP与下载信号观察、可flush原始诊断、硬时限、输入前后验证、只终止自有Job及退出确认。采样非原子与UDP目的UNKNOWN保留，禁止宣称无任何瞬时活动。没有这些前置则NOT_RUN，不能以“诊断”绕过守卫。

网络/剪贴板/音视频/打印/vGPU关闭，宿主输入只读、仅新回执输出宿主可写；构建缓存/生成输出位于客体本地。每次启动前要求客体可用空间至少8GiB，客体自有工作面上限4GiB、宿主新源/诊断材料上限512MiB；超限/无法观测则停止自有Job，保留必要回执，不删除旧资产。预算不是许可占用整个磁盘，禁止复制完整SDK/旧Seed到多份任务目录。

## 接受标准及明确范围

记录真实启动数/各次source与adapter身份、退出码、stdout/stderr、首个实际失败点、实际缓存读取与命中证据（如有）、任务图、路由消费、stop reason、Job/原进程句柄退出、输入及保护锚点保持。只有真实配置/选图证据齐全才记该诊断范围支持；BUILD SUCCESSFUL单行不能代表整版接受。缺缓存如实记OFFLINE_INPUT_MISSING，不联网补包。

**本提案不含实际AAR/APK产出、安装/升级/手机操作、音视频通话/采集、供应商/真实Push、数据库/生产动作、merge main、正式发布或v10.1.6。** 后续已授权设备目标仍需真实构建输入/独立预算/claim及设备资格满足，不能用本项配置次数替代。G2 false、AC05 OPEN、10 PARTIAL及真实Push PENDING保持，直至各自有真实证据。

Owner决定：2026-11-01，明确答复“授权上述独立3次诊断范围”，对应问题包括最多3次禁网配置诊断、任务私有guard适配、仅用现有工具依赖、无下载升级/实际AAR或APK/手机安装，旧G2保持。运行次数以新任务的永久独占claim账本为准，本文件不是计数器；当前授权登记时为0。所有技术前置继续适用。

## Owner停止决定

Owner在本次第2次诊断结束后要求立即停止并关机、明天继续。已占用2/3，剩1/3，第三次未启动；最终实际状态见ACTIVE_STATE及唯一细表。授权仍有效，但先遵守本次停止要求，不自动继续运行。

Owner最新补充：“关机我自己来，你准备好停下即可”。本次停止保持，关机由Owner自行执行；Codex未发出或安排系统关机命令。

## 2026-11-02 追加独立诊断范围提案（未授权）

Owner“请继续”已解除11月1日停止，关机仍由Owner自行决定。原独立任务`v1015-current-product-config-20261101`的3次现全部永久消耗，第3次在600样本/130次扫描后因conhost停止；磁盘竞态修复已有真实证据。旧3个reservation/outcome、旧G2及所有STOP不退款、不重置或转移。

**PROPOSED_NOT_AUTHORIZED**：请求另立`v1015-inprocess-config-20261102`预算范围，最多3次真实Gradle root创建尝试，用于验证已提交静态候选`6ecb5d13`并诊断同一当前产品的离线配置/任务图。产品source84a94c91、apps ed248529、services7634b475保持。候选只扩展任务私有compiler属性、编译动作前策略检查及--info日志；conhost唯一归因仍UNKNOWN，不以新额度保证成功。

如Owner同意：先实现明确独立的预算调度并fresh资格化新控制器/相同native源码，完整验证来源/输入/命令/监测；**不得改旧max=3或旧账本绕过上限**。新任务每次Popen尝试前原子独占预约，失败/未创建进程/配置错误/强停均不退款；普通私有配置缺陷可在剩余新额度内静态修复/检查后接续，安全STOP须具名原因及证据/明确Codex接续决定，停止原因或前置条件未查明时不重跑。次数用完即停止动态分项，不自动开后继。

其余保护沿原已批准范围：禁网Sandbox、固定Gradle8.14/JDK17/Flutter3.41.7及现有依赖、精确known images/自有Job/watchdog、只读输入/私有写面、每次1200s、同等磁盘边界。仅assembleAarRelease --dry-run配置诊断；不得下载安装升级、实际AAR/APK、手机安装/设备/音视频、真实Push/供应商/生产/费用、main合并、正式发布或v10.1.6。原3次及所有旧资产保持，新的许可不放行G2或关闭AC05。

当前没有新账本或新调度入口，额外Gradle0；收到Owner对此具体新增范围的明确答复后才开始，日常软件工程不恢复网页派单或网页验收。
