# EliteSync v10.1.5｜Windows hooks_runner 私有安全启动与 Flutter Widget/unit 定向验证——Owner正式综合任务

**状态：OWNER_APPROVED / FORMAL_TASK_PUBLISHED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_MAIN_PRODUCT_INTEGRATION / G2_AND_GRADLE_NOT_AUTHORIZED**

日期：2026-10-29（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。

## 1. 授权、目标与权威输入

Owner在Astra接受候选 `15b23d8c` 的有界MariaDB运行与Flutter analyze证据后，明确同意继续解决Flutter开发组件的剩余问题。授权一份完整的客户端测试恢复和必要同版修复任务，**不是**再次下载MariaDB/Flutter、重启已耗尽的数据库预算或执行Gradle/G2。

Codex开工必须fresh读取实时GitHub main、Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文和实际Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`（Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`）。签发前main HEAD为`b35047ad13865ccc18d6b479b9c21bba5b0f6fc3`、Root为`358f7eccd4be73c0819ccee098d5bf99a5ee499c`，仅是发布前锚；不得作为开工实时状态。

本轮**唯一研发候选Parent**为`15b23d8cacfa1429f6f77b8d57a86fff6b827673`、Root `025af603a46550721d863d354246e76d9bd072b0`；其apps Tree `29c3274654a03db7dbe2a53eb02a07686281266b`、services Tree `9bba2938aa41ad3eaee501ef88bfeecdee797591`。此前Astra有界运行验收报告在`astra/v10.1.5-15b23d8c-portable-runtime-review-20261029`，Blob `dc5a6d21e9c22f8e28b81cec7317aa740c9bd8db`；上轮Codex报告及索引Blob分别`5ec34d508f0e28c887b7527edc166aaf085d530b`、`cc534ec2d621e7e6e40ca957b65dab6b1d255fec`。必须读取这些完整来源。

main唯一已接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，不得将未接受v10.1.5整树合main。

上轮已经取得Flutter 3.41.7/Dart 3.11.5任务私有SDK、离线依赖闭合以及analyze PASS；MariaDB 10.11.19合成测试23项Feature/152断言及消息并发、重试、撤权获得有界证据。**11个Widget/unit测试文件实际执行用例仍为0。** 报告中的具体阻断是`hooks_runner-1.0.1/lib/src/utils/run_process.dart`的Windows系统shell启动路径受到进程守卫拒绝。三个受阻启动批次及完整写入闭合未证保留，不能称为Flutter整体恢复。

## 2. 唯一新私有工作面、持久账本与预算

只可建立一棵task-owned新根，logical和allocated字节分别最多 **8GiB（8,589,934,592）**；至多一套从上轮固定Hash只读来源复制而来的完整**新任务私有可写**Flutter SDK及必要私有Pub依赖，和一套以`15b23d8c`固定Git Tree重建的源码。不得在旧受保护任务根中补丁写入，不得用硬链接/可穿透符号链接，也不得重新下载SDK、Pub包、MariaDB或用户数据。

在任何复制、修改私有工具、测试启动前持久写入`execution_ledger.jsonl`：task_id、唯一根、attempt、输入/工具Hash、操作PREPARE与flush、实际子进程/结果/exit、空间与累计预算。会话恢复必须先读同一ledger和存活进程，不能因模型生成中断创建新根或重置执行次数。

**Flutter test/analyze有副作用的实际启动最多6批累计**（包括失败、超时、守卫中止；同批可含多个文件；修复后的复测也消耗次数）。不做无界全工程测试。MariaDB服务、PHP API服务、合成DB连接与迁移、本轮新数据库预算一律0；上轮MariaDB 2/2、PHP API 1/2保留原账，不重新消耗、退款或视作新授权。Gradle/G2/JVM/Android构建/APK/ADB/RTC/真机/真实Push/生产环境全部0。

此前Owner封存的`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`保留。旧18件ACL及两棵实验树、122原证、五保护根、527refs、3183旧Seed、旧账本与失败/dirty根不允许写入、移动、删除、clean/reset/prune、系统策略变更或复做实验。若发现保护资产漂移或无法解释的进程副作用，立即停止相应动作，记录证据并交Owner处理。

## 3. 精确修复Windows hook启动阻断

在原始已验证版本基础上查明hook真正启动的程序、参数、cwd、环境、平台分支、生成输出和当前守卫拒绝的进程路径；保留源Hash、调用链和原错误。**优先采用官方支持的安全、任务私有、无系统shell的直接执行方式。** 若确实需要修改运行器，Owner仅授权在**当前新任务私有副本**里对`hooks_runner 1.0.1`作最小必要适配，并保留清楚的前后diff/Hash、测试来源与行为一致性回执；不能更改共享SDK、历史镜像、Git产品`pubspec.lock`或新增未经许可依赖。

进程必须受限于具名可验证的任务私有可执行程序及任务私有写路径；不得使用系统`cmd.exe`/PowerShell或其他未知shell，不能通过绕开进程守卫、批量关闭native hooks、跳过必要代码或修改业务测试负向断言取得PASS。简单修改`runInShell`参数并不自动证明Windows实际启动链安全。用任务自有的无害测试输入检查真实runner输出/exit/错误传播及拒绝越界情形；安全前提未闭合则标`FLUTTER_WIDGET_SHELL_GATE_BLOCKED`并STOP该测试分支。

仅私有工具适配不应进GitHub产品源码；若只有私有补丁运行通过，最终表述必须为`TEST_PASSED_UNDER_TASK_PRIVATE_PATCHED_RUNNER`，不得冒称未经修改的原版Flutter工具链自动通过。

## 4. 实际Flutter测试范围和修复权限

在`apps/flutter_elitesync_module/`下针对以下**11个现存文件**进行真实Widget/unit执行，逐文件记录found/executed/passed/failed/skipped、exit与输出Hash：

- `test/core/storage/private_cache_service_test.dart`
- `test/features/auth/data/datasource/auth_local_data_source_test.dart`
- `test/features/auth/data/datasource/auth_private_storage_test.dart`
- `test/core/network/v1015_late_response_test.dart`
- `test/features/chat/data/datasource/v1015_socket_contract_test.dart`
- `test/features/chat/presentation/pages/v1015_live_chat_reliability_test.dart`
- `test/features/chat/presentation/pages/conversation_private_cache_test.dart`
- `test/features/chat/presentation/pages/live_conversation_private_cache_test.dart`
- `test/features/notification/presentation/pages/notification_center_page_test.dart`
- `test/features/notification/presentation/pages/platform_notification_navigation_test.dart`
- `test/session_rejection_test.dart`

验证F1消息同键/晚响应/WS撤权，F2按账号设备密文隔离、可信T0、合成15/30天与退出凭据竞态，F3通知过期/权限撤销/旧点击及异步换号。测试确实发现的业务问题可在本任务内有界修改相应Dart/测试并有限复测，所有失败证据保留。0个实际执行用例必须标`NOT_RUN`，不以analyze或文件存在冒测试通过。真实Keystore、物理15/30天和真机网络仍不在本次验收范围。

## 5. 唯一候选交付与STOP

以`15b23d8cacfa1429f6f77b8d57a86fff6b827673`为唯一Parent发布普通non-force候选，只包含必要的业务Dart/测试修改（若有）以及：
`docs/versions/v10.1.5/FLUTTER_WINDOWS_HOOK_SAFE_WIDGET_RECOVERY_REPORT_20261029.md`；
`docs/versions/v10.1.5/flutter_windows_hook_safe_widget_evidence_index_20261029.json`。

说明私有runner补丁前后Hash与必要差异摘要、进程/写入资格、测试真实数量和结果、失败/环境阻断、代码修改身份、跨恢复账本和完整预算、旧原证保护状态。敏感本地绝对路径、完整私有tool/vendor/cache、凭据或原始日志留LOCAL_ONLY，不上传GitHub。

最终fresh核验候选commit/sole Parent/Root、全部变更Blob/mode、完整apps/services Tree、报告/索引及main未集成。无论通过或阻断都**一次集中交付后STOP等待Astra独立验收**，不自签`V10.1.5_FUNCTION_ACCEPTED`，不合main、不开G2、不关闭`AC05_OPEN`、不启动v10.1.6或自动发布后继。
