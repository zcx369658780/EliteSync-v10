# EliteSync v10.1.5｜AGP AndroidDirectoryCreator 偏好目录冲突因果取证 Astra独立复审

日期：2026-10-23（Asia/Singapore）。Authority：Astra，EliteSync独立技术/产品顾问。

**INDEPENDENT_REVIEW_COMPLETE / AGP_CAUSAL_FORENSIC_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / DIRECT_ANDROID_LOCATIONS_EXCEPTION_SUPPORTED_BY_CODEX_TRACE_RECEIPTS / NO_REPAIR_PERFORMED / NO_DIAGNOSTIC_APK / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / PLAN_A_RETAINED / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本审查接收的只是本次授权范围内的**直接异常因果取证与诚实停止**，不接受或关闭Gradle修复、诊断APK、真实ICE路径、RTC四媒体硬门。Astra本身无Owner Windows本地文件系统、stacktrace完整原文或原证原始字节访问；分清直接GitHub读回与Codex LOCAL_ONLY陈述，绝不冒充Astra亲自执行了Gradle。

## 1. 精确GitHub对象与授权

- 执行前后 `main` = **`def08dbff21bb71ee7ea0080939488b38994aea4`**（Astra本轮审查时直接读取），仍为v10.1.4已接受产品+顾问治理文档。
- 唯一Owner正式任务：`docs/versions/v10.1.5/OWNER_APPROVED_AGP_ANDROID_DIRECTORY_CREATOR_CAUSE_FORENSIC_TASK_20261023.md`，Git Blob **`df05c9684b580e994c49473b06a8ecb7465d356b`**；上一轮Astra独立审查`flutter_pinned_arch_debug_build_env_independent_review.md` Blob **`4bb7d44c1e4dcba291ce0752fefb5c8ff883be1a`**。本轮原唯一授权为**读旧日志，只有不足时做一次相同host配置命令加`--stacktrace`，不实施修复**。
- Codex固定本轮候选Commit **`a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`**；Root Tree **`163134efa6e96b8bd53914ef41f2196ea87dfb21`**；唯一Parent **`98c2e4e9f548ee924f4e244e23e7b307fb3afe72`**，其Root **`bba25cedc58a57c174ae241f0a9aa1b36d26e350`**。
- GitHub Compare对Parent ahead1/behind0，仅新增`docs/versions/v10.1.5/AGP_ANDROID_DIRECTORY_CREATOR_CAUSE_FORENSIC_REPORT.md` Git Blob **`31dd6c1476d86a1144a441e11c470864769127b2`**及`agp_android_directory_creator_cause_forensic_manifest.json` Git Blob **`f437248382098ceeb3ae611c169b22affbe2bef3`**。Astra直接读取两份正文/JSON和两个Root；apps Tree双方均为**`785822ca072943c5bfefa3ccc37ede01c2af5164`**，services双方均为**`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**，只有docs子Tree不同。**`SOURCE_UNCHANGED / PRODUCT_CODE_NOT_INTEGRATED`属GitHub直接独立确认**。
- 当前v10.1.5受控源码Commit仍是`1522466faf798b719ccff281de7584f043946437`，`apps/android/app/build.gradle.kts` Blob **`bdb8e241d3e0defd1793c90b5f730c2facd7433d`**。本轮没有新诊断源码候选。

## 2. D1原日志不足、D2仅一次取证：证据归属

**旧证据先读**：Codex报告逐字节核旧`host-config-check.gradle`（1822B / SHA256 `32adbf68a6a7d2e20880ba1c95b601b57d8d38fcfd42b9e3b508b7448ddbc9b6`）、`host-config-diag.stdout.txt`（913B / `eea59d430e3242d9e455976178f3f5c12f11838441880523f6933173a9111e8a`）、`host-config-diag.stderr.txt`（1014B / `59c8df2eb881e321015bcfb3974faed470102c966c71ed4d061e961b5ddde326`）、result和旧daemon文件。旧相关daemon按项目PID、请求、cwd、时窗归属，未出现`Caused by:`；原可证深度止于`AndroidDirectoryCreator` provider，结论`OLD_LOG_CHAIN_INCOMPLETE`。失败后shutdown hook中的`IllegalStateException: Cannot start managing file contention because this handler has been closed`是关闭阶段现象，不应倒置为先前service创建的底层因果。

**有界一次Stacktrace**：Codex回执称原`:app:verifyIcePathDebug`命令与任务SDK、Gradle8.14、隔离home、环境helper和三个诊断标志原样复用，仅新增`--stacktrace`，运行**1/1**、exit1、7.071秒。新stdout913B/Hash与旧相同，新stderr**30,548B**、SHA256 **`68c08bcdf33a8a0c4ef5c985eaaef08bd89f8850109e66632fdf23a5e21393cd`**；完整stdout/stderr/daemon和路径均`LOCAL_ONLY`，没有发布到GitHub。Astra只看到报告/manifest结构化脱敏最深堆栈摘要，**无法独立逐行核raw stacktrace**。本轮非作者GPT-6.1 Sol/high复核同样是脱敏回执的静态审阅，不是第二次运行，也没有独立读取raw堆栈。

本轮没有更改Gradle目标、正式依赖图、构建flags、Flutter/Android SDK或网络；没有新增依赖下载、Flutter AAR编译、APK assemble、设备/DB/SFU/RTC。记录的6个Gradle缓存/锁元数据变化和一个归属daemon新增属于任务运行的正常写入，不能声称受保护的**整个任务目录零写入**。

## 3. 直接异常原因与不可越界的推断

从Codex结构化本地`--stacktrace`回执按外→内顺序：

1. `PluginApplicationException`，`com.android.internal.application`应用失败；
2. `ServiceLifecycleException`，`AndroidLocationsBuildService`创建失败；
3. `ObjectInstantiationException`，相关服务对象实例化失败；
4. `GradleException`，`AndroidDirectoryCreator` value-source provider无法创建；
5. **`com.android.prefs.AndroidLocationsException`**，message：
   `Several environment variables and/or system properties contain different paths to the Android Preferences folder.`

异常还要求只用一种方式指定该偏好目录，并**推荐`ANDROID_USER_HOME`，指出其它方式已弃用**。对应最深库调用位置为`PathLocator.singlePathOf(AbstractAndroidLocations.kt:311)`、`AbstractAndroidLocations.computeAndroidFolder(AbstractAndroidLocations.kt:145)`和`AndroidLocationsBuildService.kt:77–78`。可以据此判定：**当前一次实际宿主配置的最深直接失败与多种Android偏好目录注入方式的冲突有关**，而不是已观察到文件系统`mkdir`权限异常、AGP版本真实为null、Gradle8.14不兼容、SDK损坏或RTC媒体故障。

Codex回执还报告其上轮LOCAL_ONLY `runner.py::environment` helper**同时设置`ANDROID_PREFS_ROOT`和`ANDROID_USER_HOME`**。结构化表中这两个变量的**原始字符串同为匿名`<RUN>/android-user-home`**，而Android SDK仍因“different paths”抛错。**不能从变量原始字符串相同就宣称展开后的最终路径必相同，也不能由当前材料反推其具体展开算法或真实绝对路径**；原异常没有打印最终展开路径。本轮不要将“两个变量存在”无条件提升为所有机器的充分故障根因，只能判定**在本次特定环境下由其冲突触发的最深直接异常已被观察**。

新trace在已知的插件→service→对象→provider四个外层与旧运行一致，但旧运行当时未捕获`AndroidLocationsException`原文；不许倒填旧运行本就看见最深原因。此轮没有修改变量或再次启动来确认移除后的行为；所以**定位因果与证明修复有效是两道独立门**。

## 4. 修复候选建议（未授权实施）

**`PROPOSAL_NOT_AUTHORIZED`**：若Owner下轮批准，只在具名**诊断test-only子进程环境注入helper**范围内移除已弃用的`ANDROID_PREFS_ROOT`，保留`ANDROID_USER_HOME`，保证仅修改本地隔离会话环境、不改系统全局用户变量、不改生产Android与SDK源码、不触碰所有其它用户项目。应先核此helper是否被其他项目共享；如存在调用方则明确隔离。

实施前固定旧helper原字节/Hash和环境字典可回滚；进行具名安全负例（只用一个变量、两个变量冲突应拒绝）后最多一次同一个`:app:verifyIcePathDebug --offline --stacktrace`轻量宿主配置。结果需保留实际exit/最深cause、目标是否真的运行以及是否遇到新的不同阻断。**即使宿主配置通过，也不自动授权同任务的正式30项依赖解析或assembleDebug**。还须后续Owner专门批准这些新运行预算。无真实验证前不能承诺修复后整体Gradle或诊断APK成功。

## 5. 保护与产品判定

Codex报告本轮有效注册基线**223,496份不同文件**；原223497个路径标签有一处Windows字体大小写别名重复（`Roboto-Regular.ttf`和`roboto-regular.ttf`），去重后文件字节并未丢失；旧失败的终检报告与纠正回执均保留，不能说原审计没有误报。前任务68146份不删除、五历史根HEAD/branch/index/status不变、旧499 refs不移动、原153条Windows long-path warning不表示未登记目录也被覆盖。旧未经批准的`gradle-8.14-all.zip.part`仍38302288B，SHA256`f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`，未作为工具输入。上述均依赖**Codex LOCAL_ONLY保护结果**，Astra只直接证明GitHub产品apps/services Tree未变化。

实际阶段为：`HOST_STACKTRACE=1/1_EXIT1`；`validateIceDiagnosticGradle=NOT_REACHED`；`verifyIcePathDebug task action=NOT_REACHED`；`formal 30 target resolution=NOT_AUTHORIZED/NOT_RUN`；`syncFlutterAar/assembleDebug=NOT_AUTHORIZED/NOT_RUN`；`NO_DIAGNOSTIC_APK / NO_PHONE_RUNTIME`。

**本次因果取证交付独立裁决：`AGP_ANDROID_PREFERENCES_LOCATION_CONFLICT_DIRECT_CAUSE_OBSERVED_WITH_CODEX_LOCAL_TRACE_SUPPORT / FORENSIC_DELIVERY_ACCEPTED_WITH_EVIDENCE_LIMITS / NO_FIX / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

冻结`AC-10.1.5-05`四项真实媒体硬门（双独立APP双向流动音频、same-call媒体重连、旧RTC JWT首入及重入拒绝、撤权COMMIT后正在流动媒体≤5s停止）仍全部OPEN/NOT_RUN。方案A保留，v10.1.4仍是唯一main已接受产品。此轮Astra只做GitHub复审及docs状态归档，**没有执行本地环境修复、Gradle重试、APK构建、手机/网络操作、产品源代码合并或新任务派发**。
