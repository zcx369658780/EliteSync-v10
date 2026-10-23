# v10.1.5 AGP AndroidDirectoryCreator异常因果取证

2026-10-23。**AGP_ONE_STACKTRACE_CAPTURED / DIRECT_CAUSE_OBSERVED / NO_FIX_PERFORMED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本轮因果取证已完成。旧日志没有下层cause；在原隔离环境中只执行一次原`:app:verifyIcePathDebug`命令增加`--stacktrace`，exit1，7.071秒。新增最深直接异常为 **`com.android.prefs.AndroidLocationsException`**：多个环境变量／系统属性给出不一致的Android Preferences目录。异常列出`ANDROID_PREFS_ROOT`和`ANDROID_USER_HOME`，并明确建议只使用`ANDROID_USER_HOME`。**本轮没有修改这两个变量、任何源码或配置，也没有修复后验证。**

## 权威、连续候选与唯一范围

| 对象 | 固定身份 |
|---|---|
| 本轮任务Blob | `df05c9684b580e994c49473b06a8ecb7465d356b` |
| 上轮Astra独立复审Blob | `4bb7d44c1e4dcba291ce0752fefb5c8ff883be1a` |
| 签发后／本轮核验main | `def08dbff21bb71ee7ea0080939488b38994aea4` |
| 唯一起点／最终docs唯一Parent | `98c2e4e9f548ee924f4e244e23e7b307fb3afe72` |
| 起点Root Tree | `bba25cedc58a57c174ae241f0a9aa1b36d26e350` |
| 上轮固定源码 | `1522466faf798b719ccff281de7584f043946437` |
| 源码Root Tree | `09a4041a7bdca9eb0ffd9e92a724fe8eeb0d17cf` |
| app构建文件Blob，未改 | `bdb8e241d3e0defd1793c90b5f730c2facd7433d` |
| 完整apps Tree，未改 | `785822ca072943c5bfefa3ccc37ede01c2af5164` |
| 完整services Tree，未改 | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |

正式任务、历史Astra复审全文已读取，独立raw字节计算的Git Blob全部匹配。当前ACTIVE_STATE及工作流亦核验；任务中的签发前main与Owner给出的签发后main分开。连续工作树从固定候选干净起点创建`codex/v10.1.5-agp-directory-cause-forensic`，只新增本报告和manifest；没有main集成、产品或构建源码变更。最终Commit/Root/两文档Blob由发布后回读回执固定，避免自引用。

证据层级：固定Git源码/Tree/公开文档可由GitHub直接核；Windows日志、运行、文件Hash和进程回执为`CODEX_REPORTED_LOCAL_ONLY`。本轮非作者只核脱敏包与权限/计数一致性，未独立执行Gradle或重算全套Hash；Astra尚未对本轮交付裁决。

## D0：真实保护与同环境身份

本轮基线按实数登记 **223496份具名文件**，其中上一任务目录68146份；499条旧refs、5历史根HEAD/branch/index/status和原153条Windows长路径warning。包括旧SQL/APK/备份、私密配置、原全局缓存、SDK、旧原证及两架构官方POM/JAR；不把上轮118721自动当本轮上限。

41项关键输入Hash／身份核验通过：原目标fixture、环境helper、init、宿主构建文件、可信Gradle8.14 bin/CLI/core、JDK17.0.18.8及已登记Flutter/Android组件和两个官方精确架构工件。Flutter3.41.7／Dart3.11.5／engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`／AGP8.11.1／Kotlin2.2.20保持原身份；未重新运行版本fixture或获取任何依赖。已有publisher签名未验证的边界不变。

只读复用门确认：原受控目录没有build输出／APK、任务所属工具进程为0，18个锁文件可独占只读打开并立即关闭；未清理或写入锁文件，未改变Root/Home。D2使用D4明确允许的同任务Gradle daemon与派生缓存/锁元数据正常维护；旧stdout/stderr/result、旧daemon、源码、SDK和POM/JAR均为不可改原证。保护终检列出正常元数据变化，未写成“整个目录零写入”。

## D1：旧日志先读，因果链缺失

上轮固定原件逐bytes/SHA256匹配：

| 原件 | bytes | SHA256 |
|---|---:|---|
| host-config-check.gradle | 1822 | `32adbf68a6a7d2e20880ba1c95b601b57d8d38fcfd42b9e3b508b7448ddbc9b6` |
| host-config-diag.stdout.txt | 913 | `eea59d430e3242d9e455976178f3f5c12f11838441880523f6933173a9111e8a` |
| host-config-diag.stderr.txt | 1014 | `59c8df2eb881e321015bcfb3974faed470102c966c71ed4d061e961b5ddde326` |
| host-config-diag.result.json | 2549 | `82a177f2c9ff446513078ccdbff0fb026e2d5de041bf63dbdefcf99ae346f22d` |
| 归属旧daemon-A日志，本轮新登记 | 50391 | `e63ab9444c837700b5f9bbac18865d5e3120b42cb632e54dbcf0c7df3189d0ef` |

通过旧request、工作目录、PID与11:27时窗关联daemon-A，只在已知任务目录读取；这些原始身份及机器路径LOCAL_ONLY。旧stderr及相关daemon故障段均停在provider创建层，整份归属daemon没有`Caused by:`，最深异常类/message/故障操作仍UNKNOWN，判 **CHAIN_INCOMPLETE**。未因为尾部恰有另一个异常而误称旧证足够。

旧daemon在构建已失败、执行已结束后的shutdown hook出现`IllegalStateException: Cannot start managing file contention because this handler has been closed.`，也有连接结束EOF信息。时间和上下文属于关闭阶段，不能将其当作先前AndroidDirectoryCreator失败的直接cause。

## D2：一次stacktrace，原目标与环境不改

完整原argv保留，唯一增量`--stacktrace`。以下是公开脱敏命令表示，每个property为独立argv；完整真实命令和环境快照LOCAL_ONLY：

```text
<OLD_TRUSTED_GRADLE_8_14>/bin/gradle.bat :app:verifyIcePathDebug
  -I <OLD_TASK>/host-config-check.gradle
  --offline --no-daemon --console=plain --max-workers=2
  -PrelationshipDualDeviceBuild=true
  "-PflutterDartDefines=ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true"
  -PiceDiagTaskRoot=<OLD_RUN> -PiceDiagTrustedGradleRoot=<OLD_TRUSTED_GRADLE_8_14>
  -PiceDiagGradleBin=<OLD_TRUSTED_GRADLE_8_14>/bin/gradle.bat
  -PiceDiagGradleUserHome=<OLD_RUN>/gradle-user-home -PexpectedDiag=true
  --stacktrace
```

原`runner.py::environment`函数按其固定Hash复用，只创建同样的子进程环境字典；未导入而在旧目录生成新Python缓存，未编辑旧helper。原GRADLE_USER_HOME、SDK、Pub、Android和临时路径及CI/BOT/禁止遥测设置保持，SDK/Pub的file URI失败关闭机制不改。Gradle构建阶段完全离线，未调用Wrapper、额外debug/scan、refresh、任何解析／构建目标。

一次调用exit1，7.071秒，stdout 913B／SHA256 `eea59d430e3242d9e455976178f3f5c12f11838441880523f6933173a9111e8a`；stderr完整stacktrace 30548B／SHA256 `68c08bcdf33a8a0c4ef5c985eaaef08bd89f8850109e66632fdf23a5e21393cd`，完整raw及归属新daemon-B均LOCAL_ONLY。没有自动重试、扫描上传、依赖/SDK下载、权限提升或新设备/网络操作。无本任务Java/Dart后台遗留；没有全局stop。

## D3：观察到的直接原因与匿名因果树

| 层级 | 实际异常／操作 |
|---|---|
| 插件应用 | 应用`com.android.application`／内部application插件时失败 |
| Gradle service | `ServiceLifecycleException`：创建AndroidLocationsBuildService失败 |
| 对象实例化 | `ObjectInstantiationException`：无法实例化该AGP服务 |
| value-source | `GradleException`：无法创建AndroidDirectoryCreator provider |
| 最深直接cause | **AndroidLocationsException**：多来源Android Preferences目录冲突 |

最深message为：`Several environment variables and/or system properties contain different paths to the Android Preferences folder.` 后续明确要求`Please correct and use only one way to inject the preference location.`，并推荐`ANDROID_USER_HOME`，其它方式已弃用。

可定位调用处：`PathLocator.singlePathOf(AbstractAndroidLocations.kt:311)` → `AbstractAndroidLocations.computeAndroidFolder(...:145)` → `AndroidLocationsBuildService.kt:77–78`。最早可定位故障操作是**解析并校验Android偏好目录的多个注入来源**；链中没有给出目录创建系统调用或权限拒绝异常，不能只按类名猜成mkdir失败。

原LOCAL_ONLY helper在`environment()`第18行同时设置`ANDROID_PREFS_ROOT`与`ANDROID_USER_HOME`，两者配置字符串及本次异常打印的原始值均为匿名`<RUN>/android-user-home`。**SDK仍将它们判为不同的有效位置；错误消息没有直接打印展开后的路径，本轮不虚构`.android`展开关系或断言SDK路径算法缺陷。** 这一直接阻断与本地诊断环境目录注入有关，完整外部责任和修复后能否继续通过均未验证。

与旧日志的连续性为 **EXACT_SAME_FAILURE_CHAIN_AT_PREVIOUSLY_OBSERVED_LAYERS**：插件→service→实例化→provider四个既有层级再次出现；新trace补充此前缺失的直接cause。旧记录没有这条底层cause的原文，不追溯伪称旧运行已直接观察到。`gradle:null`仍仅是原包装错误展示，不能据此声称AGP真为null、SDK损坏、JDK/Gradle不兼容或RTC代码缺陷。

本轮分析草稿曾将异常列出的原始路径误当展开路径；对原字节核对后已删除该假设，原草稿保留LOCAL_ONLY，没有为纠正分析再次调用Gradle。公开摘要只保留有日志支持的事实。

### 唯一后续候选建议，未经本轮授权

**PROPOSAL_NOT_AUTHORIZED**：在具名test-only子进程环境注入helper中，仅保留`ANDROID_USER_HOME`，移除已弃用的`ANDROID_PREFS_ROOT`，遵循本次SDK异常给出的建议。

- 必要Owner权限：限定修改本地诊断helper的子进程环境，另给一次原轻量离线宿主配置验证；本轮未实施。
- 普通APP风险：不直接改普通R1/release/profile源码或全局环境；如其它诊断脚本共享该helper，需在后续授权中隔离调用面。
- 回滚：恢复已归档的精确旧helper Hash及环境字典；保留全部原失败，不清理缓存或原目录。
- 最小未来测试：获新授权后一次原`verifyIcePathDebug`轻量配置，保留完整trace；出现不同阻断即停。没有依据保证该建议会让整个构建链、30配置或APK通过。

## 阶段边界与一次非作者复核

| 阶段 | 本轮结果 |
|---|---|
| 条件stacktrace配置调用 | **1/1，exit1** |
| verifyIcePathDebug任务action | NOT_REACHED |
| validateIceDiagnosticGradle | NOT_REACHED，插件先失败 |
| 正式30目标配置解析 | **NOT_AUTHORIZED / NOT_RUN** |
| syncFlutterAar／assembleDebug | **NOT_AUTHORIZED / NOT_RUN** |
| APK／安装／手机／ADB／DB／SFU／Room.connect | **NO_APK / NOT_RUN** |

非作者GPT-6.1 Sol/high仅复核脱敏因果摘要、日志归属/Hash、执行计数与保护摘要；没有执行第二次Gradle或访问设备，不代替Astra验收。其回执与范围限制见manifest。

## D4：保护终检与收口

223496份基线文件完成终检；不可变旧原证／源码／SDK／官方工件没有Hash漂移，五历史根HEAD/branch/index/status一致，499旧refs保留，原153条warning保留。前任务目录无删除；本次Gradle正常变更6份任务内派生缓存/锁元数据，新增1份归属daemon/缓存文件，逐项bytes／before-after Hash在manifest列出。这些是D4所说的任务自有正常新增或变化，不冒称整磁盘或整个旧目录零写入。没有修改旧stdout/stderr/result、旧daemon或依赖二进制。

原始目录集合终检曾把Windows大小写别名`Roboto-Regular.ttf`／实际目录项`roboto-regular.ttf`误报为删除；文件实际一直存在且bytes/Hash匹配，原223497个路径标签含同一字体的一个重复别名。保留原失败终检及基线，按已证实的Windows文件身份去重后，实际唯一文件数为223496、上一任务目录唯一68146份；未重新复制／修复SDK或再运行Gradle，补充纠正回执与最终口径分开保存。

未经授权旧gradle-8.14-all.zip.part仍原位38302288B、SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`，未作为输入、未复制/执行/解压。保护范围是具名集合、固定工具输入及五历史根，未声称全盘、手机或运行数据库现场验证。新stacktrace及daemon快照完整保留LOCAL_ONLY；公开只含白名单类/message、库源码行引用、相对别名、计数与Hash。

## D5：docs-only候选及停止

仅新增本报告和`agp_android_directory_creator_cause_forensic_manifest.json`，最终唯一Parent固定为`98c2e4e9f548ee924f4e244e23e7b307fb3afe72`；普通nonforce发布后回读Git Commit/Root/文档Blob、完整apps/services递归映射及独立raw文档字节。没有改ACTIVE_STATE、冻结AC、旧报告或Astra复审。

**AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / DIAGNOSTIC_APK_NOT_BUILT / TARGET_RESOLUTION_NOT_RUN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。本次直接cause取证完成即停，没有实施修复或下一测试。等待Owner将集中交付转交Astra独立复审。
