# EliteSync v10.1.5｜受限身份 OS 写入门禁与 SDK 写面综合报告

日期：2026-10-28（Asia/Shanghai）。

**RESTRICTED_IDENTITY_GATE_BLOCKED / G2_READY_FOR_POPEN=FALSE。**

受限 token 创建及一次原生 CreateProcessAsUser 调用成功，确实创建了非提升的微型子进程；在暂停状态核对了该进程的受限 SID 与身份来源。但子进程以 **-1073741502（unsigned 0xC0000142）** 退出，没有产生首个事件、结果或私有写入文件。读写/ACL/owner/delete/rename矩阵全部 **NOT_RUN_NO_CHILD_RECEIPT**，不能记为拒写通过。没有换入口、放宽权限或再次启动。

fixture严格SDDL恢复检查18/18未通过。后续只读规范化比较证明18/18的ACE顺序、owner/group、FileId和原有内容相同，差别在描述符控制位 **0x8404→0x8004**；没有因此降低严格断言或改成PASS，也未再次变更ACL。本轮已确认该自有子进程退出并关闭本轮Windows token/thread/process句柄。旧Seed、共享SDK、历史保护根和产品main未改；D盘副线未继续。

## 1. Fresh 权威、源基线与范围

唯一正式任务 [V10_1_5_RESTRICTED_IDENTITY_OS_WRITE_GATE_AND_SDK_SURFACES_TASK_20261028.md](https://github.com/zcx369658780/EliteSync-v10/blob/34b06e3c6dd9ae09cd767468052f1828a5a5ced0/docs/versions/v10.1.5/V10_1_5_RESTRICTED_IDENTITY_OS_WRITE_GATE_AND_SDK_SURFACES_TASK_20261028.md)，Blob **f11cef5f3b729ae20120a184fc5a4ea085d6f5e0**。本轮fresh读取全文、原字节与main Root具名路径；Owner本地手动派发授权本轮微型OS实验，不把ACTIVE_STATE历史“待派发”当作未获授权。

| 对象 | 本轮直接核验身份 |
|---|---|
| 开工live main / Root | `34b06e3c6dd9ae09cd767468052f1828a5a5ced0` / `0c54cb1201afe960fd8d8007db2f37849a44a86c` |
| main接受产品v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 来源76e / 唯一Parent | `76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7` / `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53` |
| 76e Root / apps / services | `3799152e9fa348d412cabe6468a30f81f2714598` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 76e报告 / 索引Blob | `83e9067101e60945da2db35d3829555029a74bdd` / `52f2f2956fa1d2cec16451570e10a261478a5c4b` |
| Astra 76e独立验收Blob | `fcbfcdf0b8fd5ba941ed7d0d030efb3612019fcb` |
| 6ca源级接受Blob | `6d5ee056409de7373e635cd5e75b6aed52396bbd` |
| 旧G2合同 / 冻结plan Blob | `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c` / `7d3466b3be67135dc641cfee7c7faef78937ba03` |

main/76e完整递归Root为6233/6664项、未截断；来源完整1777份产品文件身份保留。两份76e文档base64原字节与既有本地副本相等。Astra裁决仅 `76E46D99_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`，技术仍OS/输入未闭合。6ca仍SOURCE_LEVEL_ONLY；schema2七项固定输入再次核验，不改变产品源码或G2 runner锁。

本轮只建一个任务独有小目录，不建完整checkout/本地refs，不复制第二份Seed。新候选以76e为唯一Parent，只加本报告及最小索引。最终Commit/Parent/Root、两新增path/mode/Blob/原字节、完整apps/services及fresh main产品树回读保存在LOCAL_ONLY final-readback，避免文档自引用。不合main。

## 2. 机制选择、API来源和本机权限

本机Windows SDK include目录未找到；已安装pywin32 API函数docstring为None，不能假装已读本地头文件。通过只读权威资料查询核对 [CreateRestrictedToken](https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-createrestrictedtoken)、[CreateProcessAsUserW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessasuserw)、[CreateProcessWithTokenW](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createprocesswithtokenw) 的契约，并把读取结果Hash固定。这是资料读取，没有让fixture发起socket或工程网络实验，也没有下载软件。

所选机制：由调用者自身primary token创建 **DISABLE_MAX_PRIVILEGE|WRITE_RESTRICTED** token，管理员组置deny-only，并加入一个只用于本次fixture的临时限制SID。它是token中的SID标识，不是新增Windows账户、持久AppContainer或服务。只在新fixture给该SID设置有界读取/私有写入权限，不改共享ACL；未使用SANDBOX_INERT或规避系统策略。

CreateRestrictedToken有双重访问检查语义，WRITE_RESTRICTED限定其写入检查；这只是契约，不能自动推出owner/WRITE_DAC及所有祖先隔离。微软对受限应用的desktop隔离也有提示。本轮没有建立独立desktop或证明GUI/IPC隔离，只允许冻结、无GUI/无网络/无SDK的控制台文件fixture，绝不将其泛化为恶意代码沙箱。

当前调用者及实际child的elevation都为0；child的管理员组未启用，限制SID数1，剩余启用权限仅SeChangeNotifyPrivilege。真实SID、owner、完整组/privilege列表、PID、句柄及ACL仅LOCAL_ONLY。当前token列表未列SeIncreaseQuota/SeAssignPrimaryToken，但 **CreateProcessAsUser实际成功**，所以不能把文档中“通常需要”的权限或这些名字缺失当成本次异常退出的原因。CreateProcessWithToken、Logon、其它账户及提权fallback均未调用。

本机pywin32版本311。核对其[固定版本包装器源](https://github.com/mhammond/pywin32/blob/b311/win32/src/win32security.i) L3293起：SidsToDisable/SidsToRestrict要求SID_AND_ATTRIBUTES tuple序列。源码SHA256 **11716ff45ce9223837a571221dd15be0b10c163a99dd55ae97302f2753888747**。启动前审查中的bare-SID格式猜测被此primary源码排除，实际执行保留tuple格式，未执行错误格式来碰运气。

## 3. 冻结微型进程：真实发生与未发生

三个任务私有源、已存在的Python解释器及两个pywin32模块共6项Hash在启动前冻结并核验。子命令固定为该解释器的 `-I -S -B` 加单一微型文件访问脚本；关闭site/user环境注入和字节码写入，没有泛用命令参数或可直接运行G2的入口。环境仅提供必要Windows路径及任务私有profile/AppData/temp；不加载另一个用户profile。继承句柄False。

启动只选CreateProcessAsUser，CREATE_SUSPENDED / CREATE_NO_WINDOW / Unicode环境。先用返回的进程句柄读取其token并确认非提升、用户及限制SID绑定，再恢复该线程；没有基于全局PID搜索或杀进程。该子程序目标仅为新micro-fixture，路径别名负例只在该fixture内，不创建指向共享输入的链接。源、环境、matrix和命令摘要、可取得FileId、SDDL前值均留LOCAL_ONLY。

| 事项 | 实际结果 |
|---|---|
| CreateRestrictedToken | 成功，调用者primary来源 |
| 原生启动调用次数 / child是否创建 | 1 / 是 |
| 暂停状态child token绑定 | 已核对，与本次受限token来源一致 |
| child进程exit | signed **-1073741502**，unsigned **0xC0000142** |
| 原型控制脚本exit | **90**，失败保守退出 |
| child首事件 / 结果 / writable文件 | 均未产生 |
| child stdout/stderr | 没有捕获；不能把controller的stderr空文件当成child无错误输出 |
| 真正失败的DLL、desktop、profile或其它原因 | **NOT_PROVEN**；不做唯一归因 |
| 自有child退出 / 本轮句柄关闭 | 已确认signaled并取exit，token/thread/process句柄已关闭 |
| 更换入口/normal-token control/提权/再次launch | **0 / NOT_RUN** |

原程序尚未给出可核验的访问结果，不能把进程创建成功或token变弱当成OS门通过。以下均缺少child回执，没有新的Win32拒写码；历史76e的Error5也不复用成本轮证据。

| 冻结检查 | 本轮结果 | 拒绝码 |
|---|---|---|
| `read` | NOT_RUN，无子程序回执 | — |
| `write_private` | NOT_RUN，无子程序回执 | — |
| `open_write` | NOT_RUN，无子程序回执 | — |
| `write_dac_handle` | NOT_RUN，无子程序回执 | — |
| `set_dacl` | NOT_RUN，无子程序回执 | — |
| `write_owner_handle` | NOT_RUN，无子程序回执 | — |
| `set_owner` | NOT_RUN，无子程序回执 | — |
| `delete_file` | NOT_RUN，无子程序回执 | — |
| `rename_file` | NOT_RUN，无子程序回执 | — |
| `parent_delete_child` | NOT_RUN，无子程序回执 | — |
| `rename_parent` | NOT_RUN，无子程序回执 | — |
| `remove_parent_empty` | NOT_RUN，无子程序回执 | — |
| `alias_dotdot_write` | NOT_RUN，无子程序回执 | — |
| `extended_path_write` | NOT_RUN，无子程序回执 | — |

分区外、真实SDK/Seed和其它项目不做探针；没有以应用层路径策略或mock替代Windows拒写结果。

## 4. Fixture恢复与停止边界

预先保存18个新fixture对象的原描述符、FileId及文件Hash；设置ACL只限这些新对象。child退出后按预定路径尝试恢复DACL，没有权限异常被吞掉。**严格SDDL比较18/18不匹配，故原型保持BLOCKED**。

只读后查分两层保留原证：第一次用PySID对象字符串表示比较ACE，不能当可靠语义比较；后续把SID规范化后，18/18 ACE序列与multiset相同，owner/group均相同，FileId18/18相同、已有文件Hash均相同。差别是描述符control由0x8404变为0x8004，精确SDDL恢复仍不成立。原始失败、第一次派生结果与规范化补充分别保留，后者不覆盖原件，不把“看起来等价”改成恢复PASS。本轮没有再改变权限或再启动进程。

启动前非作者只读审查发现“退出未确认仍可能恢复ACL”的风险，已在运行前修正：未确认退出时直接FAIL_CLOSED，不进入权限/字节恢复。审查者没有执行API、测试或设备操作；6项输入Hash由Codex本地核对，不冒称独立现场证明。实际本轮child已退出，不存在借恢复ACL继续运行的实测事实。

残留是**本任务新fixture的描述符控制差异**，不是旧Seed/SDK或全局ACL变化。没有takeown、grant、UAC、持久用户/服务、代理/防火墙/全局策略变更，也未在异常退出后用更高权限跑一次“对照”。

## 5. SDK与插件配置期写面定点结论

所有项都是SOURCE_STATIC或UNKNOWN；本轮没有把任何SDK/Gradle工具放进这个身份执行。14个插件实际Groovy/Kotlin构建文件逐份Hash匹配，不能因没看到build.gradle就漏掉build.gradle.kts。

| 源到输出 | 分类 | 有界来源事实 |
|---|---|---|
| native plugin output directories | `CONFIG_PHASE_WRITE` | projectsLoaded then rootProject.beforeEvaluate: for nativePlugins, conditionally mkdirs project(':flutter').projectDir.parentFile/plugins_build_output/<subproject> and sets that plugin buildDirectory |
| forceNdkDownload and CMake staging | `UNKNOWN` | Configuration-phase DSL assignments choose SDK empty CMakeLists, build-relative ../.cxx and arguments; no direct filesystem write in this body. AGP/SDK manager effects unresolved |
| Flutter plugin apply and generated module input | `CONFIG_PHASE_READ` | Source locates Flutter SDK and reads properties/plugin metadata; no full configuration read closure |
| generateLockfiles wrapper command | `TASK_ACTION_ONLY` | Exec is in doLast. Registration or task selection in target graph not proven |
| JNI CMake target/cache configuration | `TASK_ACTION_ONLY` | CACHE FORCE variables and native shared target/link declarations; do not prove actual AGP configuration/stamp outputs or that target is selected |
| included tooling .gradle/compile/transform and dependency indexes | `UNKNOWN` | RO modules-2 covers only dependency layer; actual binary index/repository identity and included-build state writes not closed |
| Flutter bin/cache engine stamps, Android SDK manager NDK/CMake/license stamps | `UNKNOWN` | Tool presence and offline mode do not prove no SDK/stamp mutation. No AGP bytecode execution or javap performed |
| HOME USERPROFILE AppData GRADLE_USER_HOME PUB_CACHE ANDROID_USER_HOME TEMP TMP | `UNKNOWN` | Only microfixture HOME/USERPROFILE/AppData/TEMP/TMP mapped; SDK/Gradle/Pub not launched. Unmatched strings in inspected scripts are not proof of no native fallback |

关键新增定位是 `module_plugin_loader.gradle:22–34`：先从 `project(':flutter').projectDir.parentFile` 导出基准，在projectsLoaded/rootProject.beforeEvaluate回调中，对nativePlugins有条件执行mkdirs并设置plugin buildDirectory。未来至少要把这个**精确公式解析后的canonical目的地**放到私有写面，不能只指向Gradle user-home或project-cache-dir；本轮没有执行条件分支或证明实际目的地已隔离。

`FlutterPlugin.kt:284`在配置路径调用forceNdkDownload；`FlutterPluginUtils.kt:593–637`本体只是CMake path/staging/arguments等AGP DSL赋值，不直接mkdir或写文件。NDK下载、SDK manager、stamps/license和AGP二进制副作用仍UNKNOWN，不能用函数名、offline或source.properties在场声称“未写SDK”。JNI CMake/cache语句也不是本轮真实native编译。

Gradle二进制索引/repository身份、只读two-stage依赖层、included tooling `.gradle/buildOutputCleanup`/编译/transform、Flutter bin/cache/engine stamp、module `.android`、Pub/native plugin和环境fallback仍有未闭合路径。微型环境里的HOME/USERPROFILE/AppData/TEMP/TMP映射不证明真正工程会遵循它们，GRADLE_USER_HOME/PUB_CACHE/ANDROID_USER_HOME和所有后继进程资格也未运行。不得用局部token或静态路径矩阵打开G2。

### 14份实际插件构建源Hash

| 安全来源标签 | SHA256 |
|---|---|
| plugin/connectivity_plus/android/build.gradle | `e43e962b5f4e8975bcac35073840136ccd4a1a7a790e6f340f5863d2e110623b` |
| plugin/device_info_plus/android/build.gradle | `21a89e2e96af054d9fc95d9da5af2f8d779cf2704115c8342c51645dc2f23295` |
| plugin/flutter_plugin_android_lifecycle/android/build.gradle.kts | `dd6b424f03f08a6d91799199e89b67a95011b7122edcdc90a920acbf06be9b0f` |
| plugin/flutter_secure_storage/android/build.gradle | `fd69c260d8c1af9ed6baa65928d32ba396fff05c3071cab02b29ab81cd4ce535` |
| plugin/flutter_webrtc/android/build.gradle | `88e98751759e607c3b9e00c62732bc8e28223e837ca8d75b08e887eb1a4c63f8` |
| plugin/image_picker_android/android/build.gradle.kts | `7bdf38d4b24d0f469d9704c3eb318cda2f66d108064ea040ce9816e5b6ce9859` |
| plugin/jni/android/build.gradle | `d69d3d6ddca300453c7a222451a268bd157cc93b2de4fc385d60b94656c6e008` |
| plugin/jni_flutter/android/build.gradle | `de116770599698bb122e0b19be9bbd1ffe80291ef500660288d03eeae0d4d194` |
| plugin/livekit_client/android/build.gradle | `4dcd64394c34a8be868753e5053e2aea6d76d64e278467fbd2c5b2eef2bd1a7c` |
| plugin/package_info_plus/android/build.gradle | `10beba354a1777db5e436060e98fa1b7732f41eae1a436cad7c1faae5115b482` |
| plugin/permission_handler_android/android/build.gradle | `a7eb30be9254f9b4be2ab15d7ec4377432bf2906c65ea81ba2eb0bbda87ef967` |
| plugin/shared_preferences_android/android/build.gradle.kts | `da70c2c309867579219fcf6e9d5ed206a66e261792906271903900dc49693e78` |
| plugin/url_launcher_android/android/build.gradle.kts | `7c14db00b9b95ba783d9cc0c939467211a78695c2eee3a1360d134b3fe660c47` |
| plugin/video_player_android/android/build.gradle.kts | `b488058f52b34df7aaa074c3c2ceb1f1c43d265af837d89877f25247e37d885e` |

JNI CMake来源 `jni/src/CMakeLists.txt` SHA256 **14eb8b434dbd454ce0f9eec04875a49c28cdc501e1c74340bd9ea68fe7762063**；L15–16 CACHE FORCE变量、L32–40 shared target及后续JNI链接仅支持静态配置/任务动作分类。源码映射修正为精确child-project-parent公式，没有重跑任何工程或OS进程。

## 6. 空间、保护与预算

新增所有实物在唯一新任务根：微型源、fixture、日志、权威回读、报告与索引；没有完整checkout、新本地Git对象、第二份Seed或SDK副本。原1.3GB Seed仅只读Hash/FileId核验，不计为新拥有空间，也没有借旧2GiB额度扩展本次 **268,435,456 bytes** cap。

| 阶段 | logical bytes | FILE_STANDARD_INFO allocated bytes |
|---|---:|---:|
| intake后首次before | 8,364,329 | 8,404,992 |
| 冻结fixture准备 | 10,693,373 | 10,799,584 |
| 实验后 | 10,703,080 | 10,817,264 |
| 报告前delivery | 11,930,352 | 12,095,240 |

cap未触发；发布/回读后的最终快照留LOCAL_ONLY final receipt。测量覆盖任务文件与目录AllocationSize，排除稍后receipt、全卷MFT/journal及外部并发；before是intake后首测而非伪造零时刻，全卷free差额不冒称本任务精确物理增量。这里确实调用了文件/token/进程Windows API，不声称所有native API为0。

具名101份原证Hash/size/FileId、5保护根HEAD/branch/index/status、527旧refs、worktree注册表保持；源286仍干净。旧Seed3183份在首尾只读核验Hash/FileId，没有拒写或ACL探针。6项冻结原型输入、14份插件和5份本轮SDK锚点匹配；schema2七项按固定合同核验。不是历史26784/108/100453项全量复算，也不是D盘219目录新一轮盘点。

旧partial **7,941,328 bytes** / `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`，旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316` 均保持。旧APK/G各1/1耗尽、旧A gate closed；G2 max1、reservedStarts0/Popen0、claim absent，本轮不能使用；Gate2无授权。

实际工程Gradle/JVM/Java/Flutter/Dart/AGP/Kotlin、AAR/APK、ADB/RTC、G2 runner/observer/Job、socket/网络实验、Gate2/Writer/Serializer、DB/Push/生产均0。一次原生Python微型子进程属于本任务OS专用授权，不是工程或G2启动。没有创建通话/RTC令牌、服务或端口，也没有用全局扫描去补写“资源实测全0”。D盘清理/新筛查/移动/删除均NOT_RUN。

intake/SDK静态映射/只读派生检查和保护核验exit0只代表对应步骤完成，不把它改成OS通过；真实控制脚本exit90、child原始exit完整保留。历史25/56/140及18族广泛调查不重跑。主原型只做源级检查/非作者审查与本次真实尝试，没有编造mock绿灯；一次文档脱敏规则误把HTTPS协议尾部当盘符而退出1，保留原回执，修正盘符边界后重新检查，不称为真实泄漏或新OS试验；即时只读工具查询按工具回执/结果JSON分层，关键持久化命令stdout/stderr/exit Hash在索引，child早期输出缺失明确NOT_CAPTURED。

证据层级：前置Astra裁决为 **ASTRA_DIRECT_GITHUB_STATIC**；本轮GitHub对象及固定版本源为 **DIRECT_GITHUB_READBACK / SOURCE_STATIC**，微软公开契约仅 **SOURCE_STATIC**；本地token/launch/退出及fixture描述符观察 **OS_FIXTURE_DIRECT / CODEX_REPORTED_LOCAL_EXECUTION**；真实SID、SDDL、PID、路径和原件 **LOCAL_ONLY_RAW**；未完成访问矩阵、SDK动态写面、失败DLL/desktop因果 **NOT_PROVEN**。Astra没有现场执行这些本地实验，任何辅助审查不能替代新候选独立验收。

## 7. 最小Owner决策与STOP

本轮已经排除“当前完全不能创建受限token或原生child”的笼统假设，但没有建立可用文件隔离门。两个实际阻断是 **child无测试回执的异常退出** 和 **fixture描述符control未精确恢复**；不能把它们归因到缓存损坏、工具链冲突、缺配额权限、某个DLL或desktop权限。

若Astra验收后Owner决定继续，最窄选择是另行限定**同一无工程微型程序的启动期可观测性与精确描述符恢复资格**，先解决原证缺口和可撤销性，再决定是否允许新的受控OS验证；仍不扩大到共享ACL、提升身份或G2。当前没有自动创建或执行这种后继任务。

持续 **RESTRICTED_IDENTITY_GATE_BLOCKED / G2_READY_FOR_POPEN=FALSE / INVENTORY_RUNTIME_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。Dokka选择、AAR/POM、实际APP构建、AEC/native handle、真实15/30天与物理清理、Push等历史未决不关闭。

**普通唯一Parent候选发布、对象与原字节/完整产品树回读后STOP，等待Astra独立验收；不自动G2、AAR/APK、Gate2、D盘清理、产品main集成、扩容或v10.1.6。**
