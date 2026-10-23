# v10.1.5 Android Preferences诊断子进程单变量修复

2026-10-23。**AGP_PREFS_TEST_ONLY_ENV_FIX_VALIDATED / HOST_LIGHT_CONFIG_PASS / NO_APK**。

本轮只在本任务独立LOCAL_ONLY helper副本中移除`ANDROID_PREFS_ROOT`配置注入，并在继承/覆盖合并后按Windows键名大小写语义彻底删除该键。`ANDROID_USER_HOME`仍指向原有批准目录，所有其它有效子进程环境值与旧helper一致。旧helper、普通APP、系统/用户环境及产品源码未修改。实际HOST只运行一次，exit **0**，17.112秒；最深异常：无异常（exit0）。运行结果已经停止，不重试、不自动解析依赖或构建。

## 固定身份与D0

任务Blob `8afbe615e7c3be2322917bf6d2fa30a986db0fe7`；上轮Astra复审Blob `1a1fdb8b18854ccd3b1c37358b2f85bae8e2dab1`。签发后/本次核验main `60a19ded09de5df8f84bffcb4808e84ca5729b3d`；任务正文签发前main `ba3bb1ab05f6a07896322111f9df85114c2ebdbb`单独保留，未用main覆盖候选。唯一Parent `a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`，其Root `163134efa6e96b8bd53914ef41f2196ea87dfb21`；固定source `1522466faf798b719ccff281de7584f043946437`，app构建Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`未改。

完整apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`，前后不变。本轮重新按现存文件登记 **223580** 个Windows大小写去重的唯一基线文件，含旧构建任务 **68147**、取证任务 **81** 件；**500** 个old refs、5历史root与原153条长路径warning，旧499 refs全部保持。没有把前轮223496自动当本轮总量。

固定任务/复审/历史两文档raw字节Git Blob核对通过；前轮manifest登记36项LOCAL_ONLY证据按bytes/SHA256核对通过。其公开daemon匿名别名与实际本地文件名不同，具名目录中唯一文件按81187B和固定SHA256对应，未复制回填不存在的匿名路径。一次SSH读ref连接关闭保留LOCAL_ONLY，未重试该读取；正式任务固定raw字节核对及本轮之前成功的live ref读取分别记录。没有将接收工具问题冒称产品失败或消费HOST预算。

## D1：独立副本与定向fixture

旧`runner.py` SHA256 `4a40266ae988fbeaa079892aa0654f3555f62f415391463f5d13e3cebd846a8a`，原字节副本可恢复。新helper SHA256 `1be8f3bbf89fe6d9f2d4fc1168afb85bef286af8d30648c79daff3399a0f013d`，仅删除旧赋值并在最终环境字典移除所有大小写对应的弃用键。它保持原有常量与路径；专属HOST entry只调用这个副本的`environment()`，不调用历史runner的执行/输出函数，不把新副本接入普通APP。

4类fixture（实际继承、冲突继承值、空值、大小写别名）共25项检查PASS；旧实现的键存在负例先被确认，实际Python子进程也确认最终环境无该键且USER_HOME归属不变。最初24项fixture后补充真实Python子进程与非恒真父字典比较，初版回执保留；最终25项在HOST前完成。无Gradle/Android插件fixture运行，无全局变量写入。

调用者检查限于具名旧构建/取证任务直接脚本及跟踪apps/services的精确路径引用，没有全盘搜索或声称穷尽所有外部调用者。历史helper即使存在未知调用者也不被改写；新entry独占副本，实际消费的Hash与fixture一致。已消费环境/JVM配置未发现其它偏好位置注入；未知其它来源不由本任务擅改。

## D2：唯一轻量HOST结果

冻结Gradle8.14、Flutter3.41.7/Dart3.11.5/engine固定、JDK17.0.18.8、AGP8.11.1/Kotlin2.2.20；41项工具输入Hash通过，未重新启动版本命令或下载。原隔离工程、SDK、Gradle bin/root/home、cwd、`-I`和三诊断flags及四iceDiag属性保持。命令逐argv与上轮stacktrace一致：原`:app:verifyIcePathDebug --offline --no-daemon --console=plain --max-workers=2 ... --stacktrace`；唯一有效环境差分为移除弃用键。

运行前任务进程0，18个锁仅独占只读打开并关闭；旧工程无build/APK输出可被覆盖。实际次数 **1/1**，exit **0**；`verifyIcePathDebug` action：**EXECUTED_PASS**；诊断guard：**PASSED_BY_SUCCESSFUL_DIAGNOSTIC_TASK**。最深异常仅按本次新trace，不倒填到旧运行；完整异常层级见manifest。旧Preferences异常是否再次出现：**False**。HOST通过标记：**True**。仅此结果不能扩大成完整诊断APK/RTC修复。

新stdout 3933B / SHA256 `fab183b85d0c62669e7e9234abc916e1b4f6c78347b20cd0f40ab92651fd5af2`；新stderr 0B / SHA256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`。完整日志与归属daemon仅LOCAL_ONLY，公开不含命令真实路径、完整环境、设备或凭据。正式30配置解析、`resolvePinnedDebugInputs`、Flutter AAR、`assembleDebug`、APK安装、手机/ADB、DB/API/SFU/RTC、网络配置均 **NOT_AUTHORIZED / NOT_RUN**；**NO_APK**。

## D3–D4：非作者复核与保护收口

非作者GPT-6.1 Sol/high一次有界静态复核完成；范围与限制在manifest，不能代替Astra最终验收、独立重跑或全量保护Hash复算。本轮全量保护终检：223580件、5历史root、500旧refs、SDK/依赖/旧日志/helper及历史SQL/APK/备份/私密配置的具名基线保持。Gradle正常变化 **7** 件已有缓存/锁元数据，正常新增 **820** 件派生缓存/daemon；逐项before-after bytes/Hash在manifest，不宣称整个旧目录零写入。未授权旧part原位未用，文件身份由基线覆盖；原失败及大小写纠正证据全部保留。

初版保护终检因新文件分类器只接受元数据后缀，把815件新Kotlin DSL派生class/source/module缓存及1件22B空ZIP占位`FakeDependency.jar`列为未分类，故exit1；原失败`protection-after.json`完整保留。只读核对两个具名Gradle8.14 Kotlin DSL缓存目录、class魔数与生成源码，并从现有固定AGP8.11.1 class核查FakeDependency占位文件创建逻辑；再对这816件新文件逐项核bytes/Hash，未把任何旧不可变漂移重新归类，也没有重跑223580基线或Gradle。最终820件正常新增包括817件Kotlin DSL缓存（815生成物+2元数据）、1件AGP空ZIP占位、1件新daemon与1件任务锁；占位Jar没有代码内容，不是新下载依赖或APK。纠正分类与最终回执单列，不能声称初版终检直接PASS。

任务工具进程收口与Process/User/Machine相关环境值Hash比较通过；不执行全局kill/stop，不删除缓存。保护仅覆盖具名集合，原153条warning及未登记资产范围限制保持。Windows执行和Hash属于CODEX_REPORTED_LOCAL_ONLY，公开Git对象另由发布回读证明。

## D5：仅两份文档交付并停止

仅新增本报告和`agp_android_prefs_env_single_variable_fix_manifest.json`，唯一Parent固定，普通非force发布后回读Commit/Root/两Blob及完整apps/services映射、raw文档字节；最终身份保留在发布后LOCAL_ONLY回执，避免自引用。本报告不签署v10.1.5整版接受，不修改ACTIVE_STATE、旧报告或Astra裁决，不集成产品main。

唯一下一阶段建议：**如Owner另行授权，再运行15模块×2正式依赖解析；本轮不执行。**

**AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / DIAGNOSTIC_APK_NOT_BUILT / FORMAL_RESOLUTION_NOT_RUN / PLAN_A_RETAINED / NO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。完成即停，等待Astra独立复审。
