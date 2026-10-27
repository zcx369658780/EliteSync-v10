# EliteSync v10.1.5｜AAR/POM受控发布图验证｜Astra独立验收

日期：2026-10-27（Asia/Singapore）

**INVENTORY_CLOSURE_BOUNDED_ACCEPTED / G_CONSUMED_FAILED_GRAPH_NOT_PROVEN / A_NOT_RUN_CORRECT_STOP / CONTROLLED_VERIFICATION_PARTIAL_NOT_ACCEPTED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED**

## 1. 独立复核对象与证据等级

Astra直接通过GitHub连接器读取文档候选 `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`、原始Git Commit与Parent、完整递归Root Tree、相对Parent的差异、交付报告 `AAR_POM_CONTROLLED_VERIFICATION_REPORT_20261027.md`（Blob `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80`）、脱敏索引 `AAR_POM_CONTROLLED_EVIDENCE_INDEX_20261027.json`（Blob `38b20500d0e42218976a9f675607b7a5b259a7b1`）、Owner固定任务、冻结计划、前一方案一Manifest与相关源码门禁。Astra没有在当前会话直接读取原Windows LOCAL_ONLY库存、原Gradle stdout/stderr或网络JSONL；没有亲自执行Python、Gradle、AAR、设备、Gate2、观察器或资源普查。

因此：
- `ASTRA_DIRECT_GITHUB`：Git对象身份、仓库文件/代码、文档公开内容、候选变更范围、产品双Tree。
- `CODEX_REPORTED_LOCAL_EXECUTION`：100453项库存Hash、37+44+17项测试退出码与审计0、G实际运行和失败记录、任务Job/保护核验。
- `LOCAL_ONLY_RAW`：原始Gradle输出、网络进程采样、完整库存与文件路径、进程标识、claim及回执。此层未由Astra独立复算。

本轮审查仅接受证据所支持的部分，不推断未执行的AARR/POM或完整APK结果。

## 2. Commit、Tree和只读交付

- 本轮单独GET的产品main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，产品已接受基线仍是v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 候选 `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`，唯一Parent `da5ce628a499c97e916e780e2cf795353745c147`，Root `b1f6fd9de8083f017e342fe82149874a66ff815a`。
- 远端候选分支 `codex/v10.1.5-controlled-aar-pom-verification-20261027` HEAD与候选一致。对Parent的GitHub compare ahead1/behind0，仅新增报告与脱敏索引两个文件；没有产品源码、旧实施报告/Manifest、冻结计划改动。
- 完整递归Root Tree 6633项、未截断；apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，仍与前候选一致。
- 冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；前方案一Manifest `c56644a04b88f2f02bd7369724e4d6c7aff65637` 及实施报告 `2f2b025d274cb79bafb89bb9b0374b4575786b06` 仍是原件。

没有合并产品main或启动v10.1.6。

## 3. 可信库存及隔离检查

本轮Codex报告新隔离根枚举 `100453` 文件、来自Gradle/cache/Flutter/pub/Java/Android/project七类根。新库存SHA256 `2fa1227a56a90a2225f35ff61306a327e23fde1a0cb5a4c3c961c48f5b4ff9fd`，独立枚举和Hash复核、272处包路径引用、74处插件引用和生产源码对照无缺口，且包含方案一的 `ownedAarInitContract` 与六个新输入。旧库存仅为对照，没有重新标记成新版本通过。

`INVENTORY_CLOSURE_BOUNDED_ACCEPTED`：这是**声明的输入集合和当前既存缓存路径**的有界闭合，不等于任意未来动态Gradle配置/插件依赖图、运行时网络和产物闭合。Astra仅检查报告与索引的内部一致性，未亲自执行100453文件Hash。

Codex报告方案一37项、关联44项、执行器17项隔离Python测试exit0，审计真实process/socket/native-DLL事件0。相关测试验证预算claim、G/A门禁、输入身份、fail-closed与模拟Job清理；它们**不能作为Gradle配置、发布图或Dokka未被选择的测试结果**。

## 4. G阶段独立裁决：失败且不重试

任务授予G至多一次受监控的真实内层Gradle `assembleAarRelease --dry-run`、A至多一次**只有G成功时**执行的实际内层AAR发布。旧外层APK预算1/1已耗尽、剩余0，是不同授权，不能通过G/A预算恢复。

Codex回执明确：G先原子claim，Popen已创建；G已消费 `1/1`、剩余0。观察器有效采样36个，G停止原因 `OBSERVER_OR_LAUNCH_FAILURE:OSError:PROCESS_INSTANCE_PATH_UNREADABLE`，exit90；任务Job最终活跃进程0。GitHub脱敏索引与报告记录G stdout `b41e49a15c2161f19bc3d4f5a052b92a2efb8a3623b30359de26c733caa1bb32`、stderr `6ea041318b8559c48541b6aeafa807a88d28de5f92b4fbd1c77c50ff56df94a2`、网络JSONL `98dd03952e8be998f484fb7cf7295489b575e8f8626ae9732c98cd45d7b76e52`，原字节仍LOCAL_ONLY，未供Astra直接读取。

另外，Codex报告G stderr在解析Flutter `dev.flutter.flutter-plugin-loader`、模块settings.gradle约22行时，项目自有init拒绝：
`OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required`。
但报告展示的同一G命令含 `-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`。这两者构成**真实的配置上下文/参数可见性问题线索**，不能直接写成“命令忘记传-P”或已确定哪个included-build/脚本作用域。项目仓库中此前确有init里读取 `gradle.startParameter.projectProperties['elitesyncOwnedAarInit']` 的源码门禁；Astra没有独立Gradle运行来定位哪个初始化上下文不满足门禁，故 `INIT_SCOPE_FAILURE_CONTEXT_NOT_PROVEN`。

观察器路径不可读属于另一条**独立强停止**。原诊断中已发现进程实例/非原子采样边界；这次无法从未落盘的失败实例补出PID创建时间或确认是退出竞态/权限问题。因此 `OBSERVER_PROCESS_PATH_UNREADABLE_CAUSE_NOT_PROVEN`，不授权擅自将无法读取视为安全通过，也不允许放宽非回环TCP或下载保护。

无法确认完整已解析任务图：脱敏索引selectedTasks为空且必需发布任务coverage均False，代表 `NOT_PROVEN`，**不是Dokka被证明不存在或被移除**。G=`GRAPH_NOT_PROVEN`，没有发表任何Gradle发布图PASS结果。旧方案一源码修复的有界接受仍有效，但未被这次失败证明运行成功，也未被证明已解决原Dokka/TCP。

## 5. A门禁处理正确

由于G在Gradle配置/观察器故障中止，A未claim、未启动，`A=NOT_RUN` 是**符合Owner授权的正确停止行为**。A原申请最多1次的潜在余量不能自动滚入任何后继任务或视为默许的独立未来构建预算。

没有本轮Flutter/plugin AAR、POM、Gradle Module Metadata、sources/runtime依赖、Dokka实际未执行或未联网的验证。完整APK、设备、RTC、Gate2/Writer/Serializer均不得由G/A的部分执行结果转为通过。

## 6. 保护、限制与下一步

Codex报告26784份具名历史文件、5历史根、旧claim/partial/SQL/APK及新旧refs保护不变；原7,941,328字节partial的Hash `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4` 保留。它区分525个本次开工local refs与524条旧baseline，未混淆新ref创建和旧ref漂移。这是Codex本地范围声明，不是Astra整盘审计或Windows实时普查。

Gate2新启动/Writer/Serializer为0，历史37案例、Sandbox SDK、Producer/libs.jar/30配置解析均NOT_RUN。AEC、最后可闻波形、完整native handles、真实15/30天/物理30天清理、真实Push及AC05仍开放。

后续建议先在Owner另行授权下，对**现有失败证据和已发布源码作零Gradle的门禁上下文审计**：静态追踪项目自有init的scope参数如何被读取、Flutter plugin-loader的settings/included-build作用域、Runner观察器在ProcessInstancePathUnreadable时的身份/句柄处理逻辑；仅提出最小修订及隔离测试计划，不启动新的Gradle图探测或AAR执行。原因未证实时维持fail-closed，不因再次失败自动提供新预算。

**最终裁决：`CONTROLLED_VERIFICATION_PARTIAL_NOT_ACCEPTED / INVENTORY_CLOSURE_BOUNDED_ACCEPTED / G_CONSUMED_GRAPH_NOT_PROVEN / A_NOT_RUN_CORRECT_STOP`**。

最终状态继续 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / OLD_APK_BUDGET_EXHAUSTED_1_OF_1 / G_BUDGET_EXHAUSTED_1_OF_1 / A_NOT_RUN / GATE2_NOT_AUTHORIZED`。

不创建/派发后继任务，不自动新授权、重跑G、运行A或完整APK，不放宽网络观察强停，不合产品main、不启动v10.1.6、生产Push或收费操作。等待Owner进一步决定。
