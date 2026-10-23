# EliteSync v10.1.5｜Owner批准AGP Android Preferences诊断子进程环境单变量修复与一次宿主配置验证

日期：2026-10-23（Asia/Singapore）。

**OWNER_APPROVED_AGP_PREFS_ENV_TEST_ONLY_FIX / SINGLE_VARIABLE_INJECTION / ONE_BOUNDED_HOST_CONFIG_VERIFICATION / CODEX_MANUAL_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. 唯一Owner授权与停止上限

Owner在Astra完成AGP `AndroidLocationsBuildService.AndroidDirectoryCreator`因果取证复审、明确建议“仅在诊断子进程环境helper中移除`ANDROID_PREFS_ROOT`，保留`ANDROID_USER_HOME`，再最多一次相同轻量宿主配置验证”后，回复“好的我同意，请继续”。

本次准许在一个连续Codex长任务内：
1. 固定、只读验证上一轮`runner.py::environment`以及后续调用者的归属与精确Hash，在**本次任务独有LOCAL_ONLY工具副本**中完成极小环境注入修正：**从Gradle诊断子进程有效环境中移除`ANDROID_PREFS_ROOT`，仍以同一既有授权位置提供`ANDROID_USER_HOME`**；不能改系统全局环境变量、真正用户profile、历史原版helper或其它调用方。
2. 用不运行Android宿主/SDK构建的定向安全fixture证明：继承环境、配置注入、子进程最终effective env均**不存在`ANDROID_PREFS_ROOT`键（不是设空字符串）**，恰有`ANDROID_USER_HOME`绑定既有批准目录；没有`android.prefs.root`等其它同义冲突来源由本任务新增。必须验证旧helper原字节/Hash未被改动、旧配置可恢复、普通Flutter/APP调用不被波及。
3. 只有环境fixture PASS、旧隔离任务环境可安全复用且历史资产保护满足时，才允许**一次**与前轮一致的轻量宿主Gradle配置目标`:app:verifyIcePathDebug`（可沿用前轮`--stacktrace`以便失败时仍给完整cause），**唯一环境增量就是删除诊断子进程的`ANDROID_PREFS_ROOT`**。该测试结果无论PASS或新错误都必须停；成功也不得自动升级到依赖解析／APK构建。

**本任务不授权**修改任何Git跟踪源码/构建文件、Android Studio/Gradle/Flutter/AGP/Kotlin/JDK/SDK版本、Pub/Maven依赖、旧任务的原件、全局变量及global cache；不下载任何新依赖，不操作手机/ADB/模拟器、Laravel/API/guard/SFU/DB、`Room.connect`、麦克风/摄像头、USB reverse、防火墙/UAC、LAN/UDP/TURN。禁止`:app:assembleDebug`、Flutter`assembleAarDebug`、`resolvePinnedDebugInputs`或任何其他目标。无授权R2/P2、main产品集成或v10.1.6。**修复Gradle子进程环境≠RTC通话修复，也≠AC05通过。**

## 1. Authority、旧取证与历史保护

- 仓库`zcx369658780/EliteSync-v10`；任务发布前live main **`ba3bb1ab05f6a07896322111f9df85114c2ebdbb`**，只包含已接受的v10.1.4产品及顾问docs，**不是**v10.1.5代码集成authority。开工重新核验main，但不可用main产品覆盖待验候选。
- 唯一v10.1.5连续候选起点：**`a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`**，Root Tree **`163134efa6e96b8bd53914ef41f2196ea87dfb21`**，唯一Parent `98c2e4e9f548ee924f4e244e23e7b307fb3afe72`。本版固定Gradle候选source **`1522466faf798b719ccff281de7584f043946437`**，其已审核构建源码`apps/android/app/build.gradle.kts` Blob **`bdb8e241d3e0defd1793c90b5f730c2facd7433d`**。要求本轮完整apps Tree始终 **`785822ca072943c5bfefa3ccc37ede01c2af5164`**、services Tree **`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**。
- 最新AGP因果取证原报告`docs/versions/v10.1.5/AGP_ANDROID_DIRECTORY_CREATOR_CAUSE_FORENSIC_REPORT.md` Git Blob **`31dd6c1476d86a1144a441e11c470864769127b2`**，manifest `agp_android_directory_creator_cause_forensic_manifest.json` Blob **`f437248382098ceeb3ae611c169b22affbe2bef3`**。Astra独立复审`docs/versions/v10.1.5/agp_android_directory_creator_independent_review.md` Blob **`1a1fdb8b18854ccd3b1c37358b2f85bae8e2dab1`**。任务开始前应逐一读取固定对象，按已有证据基线工作。
- 前轮**一次且仅一次**诊断`:app:verifyIcePathDebug --stacktrace`，exit1；LOCAL_ONLY stacktrace stderr 30,548 B SHA256 **`68c08bcdf33a8a0c4ef5c985eaaef08bd89f8850109e66632fdf23a5e21393cd`**。最深明确`com.android.prefs.AndroidLocationsException`：`Several environment variables and/or system properties contain different paths to the Android Preferences folder.`；SDK建议只使用`ANDROID_USER_HOME`，其他方式弃用。该堆栈有`PathLocator.singlePathOf(AbstractAndroidLocations.kt:311)`、`AbstractAndroidLocations.computeAndroidFolder(:145)`、`AndroidLocationsBuildService.kt:77–78`。请注意前轮两环境变量公开原始字符串**相同**但SDK仍判定不同目录注入，**不擅自杜撰展开后的路径**。
- 上轮受控helper（LOCAL_ONLY）`runner.py::environment` Hash **`4a40266ae988fbeaa079892aa0654f3555f62f415391463f5d13e3cebd846a8a`**，旧回执指出在environment第18行同时给子进程环境注入`ANDROID_PREFS_ROOT`与`ANDROID_USER_HOME`；必须重新核真值，不得凭文档推测文件字节或机器路径。**在新任务单独复制helper后修复，不修改旧历史文件本身**；如果还有其它AGP偏好目录注入变量/系统属性，先定性并STOP，不能擅改。
- Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`，Gradle8.14／JDK17.0.18.8／AGP8.11.1／项目Kotlin2.2.20均冻结。Gradle可信bin SHA256 **`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`**，后续仍用旧任务归属的可信分发与隔离SDK，不重建或重下。
- 上轮具名基线去除Windows大小写重复别名后为**223496个唯一受保护文件**，前任务目录原**68146**唯一文件；old refs **499**、五保护根、第一根原153条Windows长路径warning。旧未经授权下载的`gradle-8.14-all.zip.part` **38,302,288 B** SHA256 **`f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`**，只保留禁用。每次重新按现存真实对象取新保护基线，不能把旧数字当所有缓存总量。
- 原报告列出前轮一次Gradle运行对旧任务内6个缓存/锁metadata的已允许变动和1份新daemon日志，这些是**合法归属缓存变更原证**；本轮若复用相同Gradle user home，Gradle自己的新daemon/cache元数据可能再变化，必须逐项记录，不能伪称旧task目录完全零写入，也不得清除旧stdout/daemon/原始Hash。

## 2. 唯一执行D0–D5

### D0｜保护基线与旧环境归属，只读优先

1. 固定本地候选HEAD、root、所有原历史五root的HEAD/branch/index/status、旧refs/原dirty与untracked、原SQL/APK/volume恢复点／私密env、全局SDK/Pub/Maven/Gradle缓存、已有官方POM/JAR和所有登记日志Hash。不得`git reset/clean/stash/prune/rebase/force`，不得删除任何历史工具目录、缓存、锁、旧part或未知文件。
2. 确认唯一可运行的诊断旧task环境里当前无活动旧进程/锁、没有受保护产物会在本轮被覆盖，且已有SDK、Gradle、配置和项目工程副本仍与旧运行同一固定身份。只要无法证明可以**无损地**运行轻量Gradle任务，则`RUNTIME_PRECONDITION_BLOCKED`；本轮只做静态env修复文档、不运行Gradle。
3. 逐byte核旧helper Hash及它的全部可能调用者是否属于本版同一个test-only runner；如果共享到其它项目／普通R1或存在隐性调用路径，必须给新任务专属无副作用副本/单独entry，只将其用于本版AGP host configuration，而不修改/覆盖原helper。若无法保证新副本实际被本次子进程消费，就STOP，而非“修了但运行旧helper”。
4. 核实际process environment（不发布所有环境值），包括可能已继承的`ANDROID_PREFS_ROOT`，`ANDROID_USER_HOME`和与Preferences位置相关的已登记JVM system properties。**新子进程必须在最终合并继承与覆盖后，显式`pop`已弃用键，而不只是删掉赋值语句。** 不允许打印完整`environ`到公开文档。未知的其它Prefs注入源导致多来源冲突时报告而非偷改。

### D1｜仅test-only本地helper修正与环境fixture

1. 在本任务LOCAL_ONLY独立目录保留旧helper的只读原字节与Hash，新建**独立诊断运行环境helper副本**；保持全部已批准的Gradle/JDK/Flutter/Android SDK、Pub、file URI依赖断网、GRADLE_USER_HOME、任务cwd与CLI argument同旧运行，仅修改环境字典最终生成路径：`env.pop("ANDROID_PREFS_ROOT", None)`效果（可采用安全等价实现）及保留原先`ANDROID_USER_HOME`目录；**不得将已弃用键留为空值、映射到别名或以代理值代替**。不写`setx`/系统或用户级变量，不改变父进程`os.environ`、全局SDK/AGP脚本、不对历史task副本原地修改。
2. 用低成本、**不启动Gradle或Android插件**的环境fixture验证：
   - inherited parent已有`ANDROID_PREFS_ROOT`且helper已组装好时，最终传给子进程`env`中**键不存在**；
   - `ANDROID_USER_HOME`仍存在，值为既有归属`<OLD_RUN>/android-user-home`且该目录身份未变，不能默认创建另一个目录；
   - 原本三诊断flags、Gradle8.14 bin/path/root/home、子进程cwd和旧argv除`--stacktrace`保留与旧runner的等价；未触碰普通APP调用链；
   - 禁止重复别名/未知Prefs sysprops的静态输入，若发现可疑来源则STOP，不延展为多个环境变量修复；
   - 旧helper原字节未改，修复可按旧Hash回滚。
3. 若fixture无法证明**实际会使用新helper**或不满足上述差分，`CHILD_ENV_FIXTURE_BLOCKED`停止，不擅自运行正式Gradle；不能将“Python单测通过”代替宿主环境真实修复。

### D2｜仅一次原Host轻量配置验证

1. 只有D0/D1全部门PASS才允许**一次**复现前轮原`:app:verifyIcePathDebug`目标；项目、Gradle8.14直接`bin/gradle.bat`与旧`-I host-config-check.gradle`、`--offline --no-daemon --console=plain --max-workers=2`、`-PrelationshipDualDeviceBuild=true`、原三项`ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true`、旧四`iceDiag*`属性的绝对**实际**值、固定现成SDK/JDK、同旧工作目录/Gradle home都不变。可沿用已授权取证的`--stacktrace`以便显示最新原因。**唯一有意义的环境差分是`ANDROID_PREFS_ROOT`最终键缺失；不为了让build成功调整其他位置、工作目录或CLI参数。**
2. 真实运行前后只读记录子进程环境**键是否存在/值是否归属旧位置**，再标记实际Gradle结果：是否越过`AndroidLocationsBuildService.AndroidDirectoryCreator`；是否到了`validateIceDiagnosticGradle`；是否执行了预先注册的`verifyIcePathDebug`轻量target action；实际exit0/exit1和最深异常class。**如果走到新的不同问题**，立即停且记录`NEW_BLOCKER_OBSERVED`；即使exit0，也只可`AGP_PREFS_CONFLICT_REMOVED_HOST_CONFIG_PASS`，不能自动继续解析或APK build。
3. 运行预算**严格1/1**。不得加新target、执行`resolvePinnedDebugInputs`、`syncFlutterAar`、`assembleDebug`或`flutter pub get`、联网/SDK自动下载、修改Gradle配置、改test-only源代码、调用Wrapper；不得为失败“再试一下”或换新Root重新执行。发现新下载／版本漂移/路径异常直接按归属停止。
4. 原stdout/stderr、完整stacktrace与对应daemon只LOCAL_ONLY归档；GitHub发布仅匿名异常类、与前因对照、调用计数／Hash和轻量是否通过，不能公开私密绝对路径、完整环境字典、设备ID、JWT、SDK凭据或raw日志。

### D3｜非作者有界审查

一次非作者静态复审旧helper vs 新helper精确差分、环境fixture的继承覆盖负例、同目标旧/新退出与异常层级、完整受保护原证与公开摘要的口径一致性；可给出**一个**最小下阶段建议，但不能把它当Owner已批准的下一任务。如果已过Host，下一步应是另行请求**新的Owner权限**运行15模块×2依赖解析；如果新错误，先据新证决定精确修复，不可预先承诺诊断APK。
 
### D4｜保护与进程收口

归属的新脚本/日志全部任务自有。原helper及旧stdout/stderr/daemon/已经校验的依赖、SDK、旧Gradle任务目录的受保护原件不可覆盖；Gradle受管cache/daemon/lock合法写入按前后bytes/hash/数量如实列举。五历史root和全部old refs、原global SDK/Pub/Maven、旧SQL/APK/备份／私密配置及未授权`.zip.part`必须保护，保留原153条长路径warning并注明未登记资产覆盖限制。只结束本次亲自启动的任务进程，不执行全局kill Docker/Gradle/ADB/WSL，不能自动清理old cache。

### D5｜唯一Git交付与终态

仅新增两份交付文档：
- `docs/versions/v10.1.5/AGP_ANDROID_PREFS_ENV_SINGLE_VARIABLE_FIX_REPORT.md`
- `docs/versions/v10.1.5/agp_android_prefs_env_single_variable_fix_manifest.json`

不修改旧AGP取证文档、前轮Astra review、原RTC源码或`ACTIVE_STATE.md`。在`a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`单一干净连续候选上提交仅两份docs，普通非force发布，远端回读sole parent/root/两个Git Blob，完整apps Tree必须仍为`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree仍为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。原helpers／真实stderr/daemon/env文件仅LOCAL_ONLY，不上传GitHub，报告列Hash与归属，不写入自己尚未确定的commit SHA。

**最终分类**只能依原事实：
- `AGP_PREFS_TEST_ONLY_ENV_FIX_VALIDATED / HOST_LIGHT_CONFIG_PASS / NO_APK`；
- `AGP_PREFS_ENV_FIXTURE_PASS / HOST_NEW_BLOCKER_OBSERVED / NO_APK`；
- `AGP_PREFS_CONFLICT_PERSISTS_AFTER_ONE_RUN / NO_APK`；
- `CHILD_ENV_FIXTURE_OR_HOST_RUNTIME_PRECONDITION_BLOCKED / HOST_NOT_RUN / NO_APK`。

统一保留`AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / DIAGNOSTIC_APK_NOT_BUILT / FORMAL_RESOLUTION_NOT_RUN / PLAN_A_RETAINED / NO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。**完成后必须停止；不能因轻量配置PASS自行开始依赖解析／APK构建或真实手机/RTC测试。**
