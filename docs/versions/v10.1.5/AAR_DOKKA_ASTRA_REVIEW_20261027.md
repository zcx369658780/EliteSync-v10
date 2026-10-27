# EliteSync v10.1.5｜AAR / Dokka 静态依赖调查｜Astra 独立验收

日期：2026-10-27（Asia/Singapore）

**STATIC_DEPENDENCY_REVIEW_ACCEPTED_WITH_LIMITATIONS / STATIC_MECHANISM_SUPPORTED_WITH_SOURCE_BOUNDARY / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN**

## 1. 验收对象与方法

验收文档候选 `3d0c656d59e8621ffa6a935313b5cd4c860a16b1`，新增报告 `docs/versions/v10.1.5/AAR_DOKKA_STATIC_DEPENDENCY_REVIEW_20261027.md`，Git Blob `96b7bc41e10eeed1ce385c218b4038ca280bf5c2`。

Astra本轮直接从GitHub读取提交与唯一Parent、完整递归Root Tree、候选差异、冻结计划、前轮原报告/Manifest、项目 `apps/android/app/build.gradle.kts` 和 `apps/android/scripts/offline_debug.init.gradle`。Astra**没有独立打开本地Flutter SDK、缓存AGP/Gradle/Dokka Jar、生成的 .android 脚本、LOCAL_ONLY构建日志或本地Hash索引，也没有在本轮运行Gradle、测试或设备**。本报告对于缓存ClassFile细节、实际旧日志和具名保护文件计数仅依据Codex发布的脱敏报告作有界审阅，不能将其称为Astra亲自从原件复算。

## 2. 远端身份和源码边界

- live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，产品接受基线仍v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 候选 `3d0c656d59e8621ffa6a935313b5cd4c860a16b1`，唯一Parent `7abea213feacc52a1e43c6ed58a40c83009c74df`，Root `5f0dbe066ba64b1b8ab05c1698a9c48c19fb9553`。
- 远端 `codex/v10.1.5-aar-dokka-static-investigation-20261027` HEAD与候选一致。与Parent比较 ahead=1、behind=0；仅新增上述文档，186行，没有其他源码改动。
- 完整Root Tree 6623项、未截断；apps `cea01309fa9da5f99ccc9829654c6ec279c8c343`，services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，与Parent相同。
- 冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；原报告Blob `71e039051ba0c6205f496444bc466d71f11a6fff`、Manifest Blob `d91a50d3653ef6304b4f45e53ddb4a242dbce284`；既有TCP只读报告Blob `72975510872fbe3251caf1b8ddbd687761165d88` 均保留原字节。

## 3. 静态机制的可接受结论

### 3.1 Astra直接核验的仓库声明

固定 `apps/android/app/build.gradle.kts` 通过 `preBuild.dependsOn(syncFlutterAar)`，后者在普通v10.1.5 R1构建分支调用本地Gradle执行嵌套 `assembleAarRelease --offline`，并加载SDK `aar_init_script.gradle` 和项目 `offline_debug.init.gradle`。**前者是同一构建内的任务依赖，后者是新Gradle进程的Exec，不可混为一条同图依赖边**。

当前项目 `offline_debug.init.gradle` 在projectsEvaluated后，仅对MavenPublication的artifacts集合移除classifier=`javadoc`的artifact。它不直接关闭AGP的 `withJavadocJar()` 发布选项，不清除SoftwareComponent的全部变体，也不显式disable `javaDocReleaseGeneration` 或Dokka任务。因此，“移除Maven发布artifact足以消除所有文档相关任务”在源码层面不成立。

### 3.2 Codex报告的本地只读类字节发现

报告以任务库存pin为基础，用Python标准库只读ZIP/ClassFile定位Flutter SDK、AGP8.11.1/8.12.1、Gradle8.14、Dokka1.4.32中的方法和字节偏移，给出：
- Flutter AAR init在受条件限制的singleVariant路径请求 `withJavadocJar()`；同时发布模型包含 `from component` 与AAR发布finalizer。
- AGP文档生成/Jar任务经 `ComponentPublishingInfo.getWithJavadocJar()` 路径注册，并由provider关联文档输出与发布变体。
- Gradle的 `GenerateModuleMetadata` 对SoftwareComponent usages及其artifact构建依赖的处理，不等同于只从已经过滤过的Maven主artifact集合取输入。

这些内容具有具体文件Hash、版本、类、方法、偏移与来源行号，**足以有界接受“静态实现允许元数据路径继续保留文档任务依赖”这一候选机制**。但Astra未直接反汇编/复算Jar，因此应标 `CODEX_REPORTED_LOCAL_STATIC`，不称 `ASTRA_DIRECT_CACHE_VERIFIED`。

报告同时区别AGP版本的声明与实际加载实例，且没有将“任务被注册”伪装成“当次具体依赖边被选中”；此限定合理。

### 3.3 原日志与Dokka/TCP分离

报告复用旧stdout中 `:connectivity_plus:javaDocReleaseGeneration` 与Dokka进度，说明旧运行确实出现文档任务；本次未运行构建。已读取的daemon文件只是前轮新增Hash，不是原构建交付时已pin的日志。缺少历史完整resolved task graph、加载Jar实例、统一任务时间基、TCP调用栈/端口，故：
- `DOC_TASK_EXECUTION_REUSED_LOG`：有界保留；
- `EDGE_NOT_PROVEN`：没有证据锁定当次确切调度边；
- `DOKKA_TCP_CAUSALITY_NOT_PROVEN`：不能把某个文档任务定为非回环TCP的发起者；
- `ROOT_CAUSE_NOT_PROVEN`：原构建停止根因仍开放。

报告中关于Dokka默认offlineMode与外部文档链接的类字节说明，是值得继续核实的配置风险线索，而不是本次下载/外联已被证明。

## 4. 两个未实施方案的界限

方案一：在任务拥有、来源与Hash独立受控的AAR init副本中，有条件取消 `withJavadocJar()` 请求，保留必要runtime AAR、plugin依赖、publish和POM/元数据。这是从源头减少文档发布变体的建议，不是当前获准修改，更没有实际产物验收。

方案二：在SoftwareComponent发布变体层有界过滤仅文档variant，保留API/runtime与必要sources/POM。实施正确性依赖具体Gradle/AGP版本、真实component与配置时点；不能直接“关闭 `GenerateModuleMetadata`”或粗暴禁用Dokka后留下缺失artifact引用。

两方案均会改变构建定义及缓存/输入身份，需Owner另行授权最小源码修复与受控验证。二者都**不构成TCP根因修复保证**，也不得被借口用于关闭全部网络监控。

## 5. 保护与最终结论

本轮仅发布文档；未改代码、旧manifest、旧实施报告、冻结计划或产品main。Codex报告本轮真实构建、Gradle查询、测试、设备/RTC、实时观察器、Gate2/Writer/Serializer调用为0；Astra没有独立监控本地进程。其报告所述26784具名保护文件、5历史根与524旧refs无漂移属于Codex本地只读审计范围，不是Astra亲自执行的整盘证明。

原真实构建预算1/1耗尽、剩余0，旧partial 7941328字节及原始Hash、SQL、APK、refs、LOCAL_ONLY证据继续保留。Gate2未授权；真实Push、AEC、最后可闻波形、原15/30天真实经过与物理清理等仍未关闭。

**最终裁决：`STATIC_DEPENDENCY_REVIEW_ACCEPTED_WITH_LIMITATIONS`。**

接受报告清晰呈现的静态候选机制、两条未实施且保留运行时产物边界的建议，以及对具体边和TCP因果仍未证明的承认。不接受“已经确认Dokka造成TCP”“已经修复构建”或“v10.1.5整版接受”。

继续保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。

本次不创建或派发后继任务，不授权代码更改、真实构建、Gate2、生产服务、main合并或v10.1.6。等待Owner明确下一步。
