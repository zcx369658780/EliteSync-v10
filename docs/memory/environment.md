---
title: environment
type: note
permalink: elitesync-v10-local/environment
---

## 2026-10-12 迁移补充（当前生效）
当前管理/执行方式由 [新工作流](../workflow/CURRENT_WORKFLOW.md) 和 [动态总目录](../../DOC_INDEX_CURRENT.md) 指定：网页Astra规划/最终独立验收/复盘，Codex自主实现，Owner方向决定。下方涉及旧Work/单次预算/新Work指定的描述是原归档时点知识，不是当前流程门；科学产品语义、历史接受/拒绝及旧预算冻结仍保留。当前状态见 [CURRENT_STATE](../../CURRENT_STATE.md)。
原始session、EVIDENCE原始证据和本地检索数据库均LOCAL_ONLY；以下本机位置仅供Owner/本地Codex准确定位，网页正文已提供安全摘要，不能假定原件已发布或可直接访问。已有被发布正式文档可按总目录寻找；未发布原证请Owner脱敏提供，不建立指回本地路径的网页访问链。


# EliteSync-v10 开发环境记忆
核验：2026-10-12（Asia/Shanghai）。本地路径用于定位，不是执行 grant。USERPROFILE/ProgramFiles 是安全占位符；当前本机 USERPROFILE 由宿主解析。原始绝对路径在具名本地证据中可回读，不归档私钥/密码/Token。

## 当前检测、历史记录、项目要求分列
|组件|准确入口/根（本机）|2026-10-12 本轮只读结果|历史/要求与证据|
|---|---|---|---|
|Flutter|D:/flutter/bin/flutter.bat；bin/cache/flutter.version.json|版本元数据 3.41.7 stable；未运行 flutter wrapper|2026-09-13历史观测3.41.7，framework cc0734ac71 / engine59aa584fdf；T1第22–27行|
|Dart|D:/flutter/bin/cache/dart-sdk/bin/dart.exe；历史wrapper bin/dart.bat|直接 --version：3.11.5 stable windows_x64|apps/flutter_elitesync_module/pubspec.yaml 第20–21行 sdk ^3.11.3；约束不等于安装版本|
|Java|ProgramFiles/Eclipse Adoptium/jdk-17.0.18.8-hotspot/bin/java.exe|直接 -version：17.0.18，Temurin17.0.18+8|2026-09-10精确一次stderr见T2第54–63行；不等于Android兼容完整通过|
|Android SDK/adb|USERPROFILE/AppData/Local/Android/Sdk/platform-tools/adb.exe|adb version：1.0.41 / 37.0.0-14910828；不启动adb server/设备|2026-10-06原日志第67行同版本；SDK包、许可、NDK未核|
|Gradle|D:/GradleHome/wrapper/dists/gradle-8.14-all/c2qonpi39x1mddn7hk5gh9iqj/gradle-8.14/bin/gradle.bat|入口存在；未运行Gradle/JVM构建/daemon|2026-10-06实际 --offline --version回执Gradle8.14，Groovy3.0.24，Java17.0.18，exit0；T3|
|PHP|C:/tools/php85/php.exe|直接 -n -v：8.5.3 CLI NTS Visual C++2022 x64；-n不加载php.ini|历史8.5.3见T4第3–14行；本轮不启动Laravel或查询DB|
|Composer|ProgramData/ComposerSetup/bin/composer.bat|Get-Command 定位启动器；本轮未运行Composer|历史2.9.5见T4；当时绝对入口未记录，不能反写历史已知|
|CPython|USERPROFILE/AppData/Local/Programs/Python/Python311/python.exe|--version：3.11.9；已用于本轮文档检索|T5汇总第157行；不证明业务FFI/Job|
|Git|ProgramFiles/Git/cmd/git.exe|2.53.0.windows.1|本轮仅本地只读，不fetch/commit/push|
|Node.js|ProgramFiles/nodejs/node.exe|v24.14.0|本轮仅版本与QMD工具宿主；不推应用需要Node|
|Android Studio|准确安装目录未建立|标准 ProgramFiles/Android/Android Studio/product-info.json 不存在，PATH无studio64|只说明这两个 locator 未命中；不能声称未安装|
|PowerShell|本轮当前宿主|未单独版本查询|历史7.6.6/Core见T5第151行；本轮不冒当前已重测|

## 项目配置（声明，不是运行状态）
- Android host：apps/android/build.gradle.kts 第1–3行：AGP8.11.1、Kotlin2.2.20。
- Wrapper：apps/android/gradle/wrapper/gradle-wrapper.properties 第3行声明 gradle-8.14-all.zip；本轮不触发wrapper下载。
- Flutter canonical module：apps/flutter_elitesync_module；Android host apps/android；backend services/backend-laravel，见仓库README第23–26行。
- Laravel/依赖的历史汇总：T5第160–161行记录 lock Laravel v11.48.0 / PHPUnit11.5.55。本轮未重新逐包读 lock，标历史待现时核验；不是服务运行或依赖当前已恢复。
- 不读 .env/凭据，不读取全局 Gradle properties/init scripts，不连接SSH/DB/API/Redis，不测试设备、不构建APK/AAR。

## 分发用途与临时补丁
Android M5 lane 的 c2q...具名分发见 knowledge.md K07。compile/Groovy lane 的另一个 locator：
D:/GradleHome/wrapper/dists/gradle-8.14-all/dq61qkzrdg407zji6bwf6hwt7/gradle-8.14/lib。
本轮该lib根存在，但未逐jar核身份或运行；T5第184–190行对应准确发行定位。多个8.14/9.0.0缓存存在不能证明互换权或项目升级。
M3的 C:/M3R4/t/f 等是当期隔离副本/预算上下文，不能作为宿主Flutter安装迁移依据。历史 direct snapshot/AAR失败仍保留，不能把新文档恢复当修复成功。
旧 local DB 环境字段纠正见T6：APP_DB_CONNECTION作为selector保留，连接详情读 DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD。它是 archive/runtime-history 历史，不是当前 .env 的读取或DB配置批准。
没有通用安全“启动全部软件”步骤；后续运行须按新准确任务和Owner保护门。定位/版本查询方法不能直接扩成build或业务验证。

## 原文来源
- T1：../architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md，2026-09-13，第5、22–27行。
- T2：../architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_JDK_IDENTITY_CAPTURE_AND_REMAINING_A_REESTABLISHMENT_RESULT_V0_1.md，第54–73行。
- T3：../../EVIDENCE/WORK-STAGE-M5-ANDROID-SYNTHETIC-PLATFORM-PROOF-20261006/executor/platform-v3/receipts/027-gradle-version.stdout 第13–26行；027-gradle-version.json 第2–15行提供exe/argv/cwd/开始时间/exit0。
- T4：../archive/runtime-history/ELITESYNC_V10_BACKEND_DEPENDENCY_PREPARATION_REPORT.md，第3–14行；其来源是历史报告，未据此重验完整Laravel。
- T5：../migration/ELITESYNC_V10_DOT_MIGRATION_REPORT_20261002.md，第145–190行；汇总明确区分历史/当时实测/配置/UNKNOWN，不作为独立重复证据。
- T6：../archive/runtime-history/ELITESYNC_V10_LOCAL_ENVIRONMENT_CONTRACT_CORRECTION_REPORT.md 第21–42行及“Database Identity Preserved”；只保存变量名/原因，秘密值不复制。
- 当前原始输出：USERPROFILE/.codex/sessions/2026/10/11/rollout-2026-10-11T22-09-40-01a12b4c-43b8-73a0-bcec-2675f5b21a2d.jsonl 第220行（路径/Flutter metadata，chunk f2a90c）、第229行（版本输出，chunk d04c17），2026-10-12T00:22:22.291Z / 00:22:35.315Z。性质：本轮真实工具观测，非新行为/产品验收。
- 2026-10-06 adb历史原文：USERPROFILE/.codex/sessions/2026/10/06/rollout-2026-10-06T12-15-17-01a10f6c-47f5-70a2-91d3-8990e8838f3f.jsonl 第1行cwd归属、第67行custom_tool_call_output，2026-10-06T04:17:33.894Z。
