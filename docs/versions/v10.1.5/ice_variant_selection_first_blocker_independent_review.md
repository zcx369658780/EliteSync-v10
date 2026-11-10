# EliteSync v10.1.5｜环境回执纠正与首次Gradle项目变体歧义｜Astra独立审查

日期：2026-10-23（Asia/Singapore）。独立裁决者：Astra／EliteSync GPT顾问。

**LAUNCHER_CORRECTION_AND_FIRST_BLOCKER_DELIVERY_SUPPORTED_WITH_OBSERVATIONS / REAL_OFFLINE_RESOLVE_ATTEMPTED_FIRST_CONFIGURATION_FAILED / VARIANT_SELECTION_AMBIGUITY_OBSERVED_NOT_REPAIRED / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**

## 1. 实际Git对象与验收边界

- 候选Commit：`9e3333151125deb9985e86324811c1737a4fa90d`；Root Tree `34b72d5916edc2e928f28187c760a05eb64e83c6`；sole Parent `d45c0fae755fb97e1df9cbdc875965725a88d969`，GitHub compare `ahead1 / behind0`；仅新增两份docs，未修改旧报告或产品代码。
- 报告：`docs/versions/v10.1.5/ICE_ENV_RECEIPT_CORRECTION_AND_SINGLE_RESOLVE_REPORT.md` Blob `1b39ce901faa27826143ca151b370ff91e75987c`；Manifest：`ice_env_receipt_correction_and_single_resolve_manifest.json` Blob `e83f2f6992530dfa63a37fbd32fda6467b4d46a4`。
- Astra直接读取两个Git对象与GitHub commit/compare，并核候选及Parent完整子Tree：apps均为`785822ca072943c5bfefa3ccc37ede01c2af5164`，services均为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。固定产品source `1522466faf798b719ccff281de7584f043946437`、受控build.gradle.kts Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`无本轮新增差异。
- 本轮依据的唯一任务Blob `7dffebddc766abceb4b0f4e0a9e15673f6a0db0c`，前轮阻断独立复审Blob `695c6c2c4875114d2a6c8ce51f5a0dbb1d878aba`，AGP HOST独立复审Blob `fa83daeb88e55c1d549384dc970e729f0b9a9d63`。
- 审阅时live main为`9eb71821593501810623519f4c6ef1fd30570fe1`（Root `873acfc32dca651af1ff4d452de058a9e4035838`），仍为v10.1.4正式接受产品：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本候选未进入main，审查文档后继可能使main仅文档前进，运行状态不随之改变。

## 2. D1环境回执：有界通过，历史UNKNOWN保留

本轮Codex LOCAL_ONLY**一次新受控样本**中两端有效环境各50键，差异仅来自父环境继承的`CODEX_TOOL_CALL_ID`值变化。新受控观察确证这一次的Hash不等；**上一任务原actual Hash与原差异键没有被捕获，仍为UNKNOWN**，不能把本轮样本倒填历史。

Codex采取完整环境字典一次封存、规范键名与编码、验证全部50键后将同一个字典交给`Popen(env=...)`；无忽略键，未删除断言；`ANDROID_PREFS_ROOT`大小写别名和空值均拒绝，`ANDROID_USER_HOME`原已获准归属不变，固定cwd/argv/工具Hash等关键负例继续拒绝。一次新的38项Python安全fixture PASS，包含真实Python子进程对相同环境Hash读回。本轮另保留一次准备脚本误映射未复制历史init的`FileNotFoundError`及纠正。没有重跑已接受HOST/旧25项fixture。

**证据等级**：Git提交、源码树及脱敏原文为ASTRA_GITHUB_DIRECT；Python脚本/fixture/Popen实际消费、Windows原始环境及数据保护为`CODEX_REPORTED_LOCAL_ONLY`；Gradle/JVM内部没有独立环境全量回读，不得宣称已直接实核JVM全部变量。

## 3. D2唯一真实离线解析：首个项目Artifact变体歧义

- 正式运行`resolvePinnedDebugInputs`一次且仅一次，Codex回执 exit1，118.1835秒；目标真实打印`PINNED_RESOLVE_BEGIN :flutter:debugCompileClasspath`且实际进入`Configuration.resolve()`。结果`BEGIN=1 / OK=0 / NOT_RUN=29`。**不是30配置成功、也不是全部30失败**。
- 首具名生产者为`:connectivity_plus`，解析其`debugApiElements`时遇多组候选artifact variants：`android-classes-jar`、`android-lint`、`android-lint-local-aar`、`android-manifest`、`android-renderscript`、`android-symbol-with-package-name`、`jar`、`r-class-jar`。报告所示consumer要求library/compile-time/Android target/AGP8.11.1/debug/androidJvm，未明确要求`artifactType`；某些生产者候选未显示consumer相关属性，且仍有多个兼容artifact，因而无法唯一选取。
- 同一首配置错误文本另列出13个插件项目的类似变体歧义，**不是它们各自的debugCompile/debugRuntime配置已经运行**；没有观察到新缺失GAV。未加新的stacktrace，完整`Caused by`或最深异常类`NOT_PRINTED`；不能猜Gradle内部异常类型，更不能据此推断SDK损坏、Flutter官方二进制缺失或RTC产品源码必错。
- 该错误与历史HOST Preferences路径冲突、启动器环境Hash不一致不同。本次没有授权变更Gradle init/产品构建文件、依赖或缓存来修复变体选择；首阻断后没有重试。

Gradle官方文档区分依赖图的variant matching与artifact selection，artifact views可在不改变原配置的情况下请求不同artifact属性；这一概念是**后续定点调查方法**，不证明本仓适用何种`artifactType`。不得凭“第一个项目报android-classes-jar”直接对15个模块一律强制某个artifact类型、启用lenient忽略缺项、仅用graph resolution替代要求的真实`Configuration.resolve()`或为通过而修改正式业务构建源码。参考：https://docs.gradle.org/current/userguide/artifact_resolution.html ，https://docs.gradle.org/current/userguide/variant_aware_resolution.html 。

## 4. D3保护与来源等级

Codex报告本轮前置289350份具名文件初始全Hash；终检全部size/mtime与仅变化/8关键件重新hash（实9件），**不是终末第二次全量内容hash**。原502 refs、5个保护根、153项Windows长路径warning仍在；任务归属Gradle合法产生21683个派生文件及一项旧cache元数据变动，未下载新的原始modules-2二进制。原SQL/APK、密钥、备份、未授权旧part、历史失败本地原证受保护。非作者GPT-6.1 Sol/high静态复核无must-fix，仅对该范围回执支持，不是Gradle实地复测/作者接受。Astra未直接访问`C:/Users/.../.codex`文件、Windows保护原件、Gradle stderr或原始daemon，因此不将它们冒称`ASTRA_DIRECT_RUNTIME`。

## 5. 正式裁决与下一步建议

**`LAUNCHER_CORRECTION_AND_FIRST_BLOCKER_DELIVERY_SUPPORTED_WITH_OBSERVATIONS`**：本轮满足停止和可追溯交付合同；Python新回执问题在受限回执范围解决，第一次真正进入解析器且暴露一个可定位的首阻断。**但项目变体问题没有解决、正式30配置0项PASS，不能签`FUNCTION_ACCEPTED`。**

建议下一阶段只授权一次**同任务有界变体属性定点取证→必要LOCAL_ONLY解析脚本修复→一次真实30配置离线解析**。先用已保存的stderr与真实init/Gradle8.14/AGP8.11.1配置核消费者与生产者的属性、artifact-selection差异，必要时最小离线fixture演示具体修复如何保留compile/runtime语义；只有具名差异、负例和非作者复核均成立，才让Owner手动派发的后继任务消费最多一次新的正式解析预算。否则STOP、不擅改build.gradle.kts/真实依赖/工具版本/SDK，不反复复制7GB或重跑HOST。即使30项全部解析PASS，也不允许本任务自动AAR/APK、设备/RTC或产品main集成。

**最终保留：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_APK / PLAN_A_RETAINED / NO_R2 / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED`。**
