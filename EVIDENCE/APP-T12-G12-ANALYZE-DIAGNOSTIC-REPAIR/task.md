# APP-T12-G12｜19 项模块静态分析诊断修复

状态：`ISSUED`；风险 `LEVEL 2`（当前 SDK/API 迁移及保留遥测/RTC 行为）；Assignee：Codex 会话 `01a0ef77-af94-75e2-8726-87c04e082018`，GPT-6.1 Sol / medium。交付后停 Work 独立 LEVEL 2 审查。

## 输入与允许路径

唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。当前 Owner 已明确恢复推进；旧会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2` 停用。先读根规则、CURRENT、PRODUCT_DECISIONS、TASK_CURRENT、REVIEW_GATE、local-workflow skill 和 APP-T12-G12-MODULE-ANALYZE 的摘要/独立审查。此前 FAIL 和 1/1 耗尽预算不改写。

仅可修改下表八个文件（路径相对于 `apps/flutter_elitesync_module`）；编辑前逐一核对输入 SHA-256，任何不符先停。保留全部既有 dirty/untracked 和各文件任务外内容。另仅可新增本任务 `summary.md`。

| 文件 | 输入 SHA-256 |
| --- | --- |
| `lib/core/network/interceptors/logging_interceptor.dart` | `4A2378EE7495B8668FC4E81E95B0BFD5C102104E38F1AB172701C09415B38145` |
| `lib/core/telemetry/app_telemetry_service.dart` | `1BEE328408A665C915AAB683B09689E89FE64D0558AB036261B8BD2D045A2B88` |
| `lib/features/profile/presentation/providers/astro_profile_provider.dart` | `546476FFCF3957A16AE4011CE3AF6EBCD1C7C97DEB581D6B67BE543C5E3859FD` |
| `lib/features/profile/presentation/widgets/standard_ziwei_grid.dart` | `006060E5BA3B0490879F472BF6304A419FF81F3FAB7C19BFCD2A5D88433CCD22` |
| `lib/features/rtc/domain/services/rtc_livekit_service.dart` | `93C81081DB081FBBB7038619AF7330C22D713F9228D03AE3DDBF84C216F85EB4` |
| `test/design_system/components/browse_scaffold_semantics_test.dart` | `A22D275650B187E7CEED40F96F0A2653C5ACF612AE98ECEEF93E13D1FE54848E` |
| `test/design_system/components/floating_dock_bottom_bar_semantics_test.dart` | `8CF92A87198BDEFC5C3C8948F963909CD91ABAEF0C8FECE4519D9F4F50F09C13` |
| `test/features/chat/data/dto/send_message_contract_dto_test.dart` | `1D5B03AC9C2DDDB31063BC706BACEB757B08BADAD3BA6771A0C40A5CB18F278B` |

## 固定实现

1. 删除 LoggingInterceptor 的三处、astro_profile_provider 的五处裸 `print`；这些消息已有相同 logger 调用。保留已有 logger 的级别、消息、调用顺序和错误传播，不新增日志、数据访问、重试或网络行为。
2. 仅删除 _OverlayBadgeRow.build 中未使用的 `final t = context.appTokens;`；不改布局或其它 token 消费。
3. 两处 telemetry 可空 map entry 与一处 DTO 测试 fixture 改用 Dart 等价 null-aware map element（例如 `'target_user_id': ?targetUserId`），保留 null 时键缺省、0/非空值保留及所有断言，不改 payload 条件/端点。
4. RTC 的三处弃用接口迁移：`room.setSpeakerOn(true, forceSpeakerOutput: true)` → `AudioManager.instance.setSpeakerOutputPreferred(true, force: true)`；Hardware 的 speakerOn/forceSpeakerOutput getter → AudioManager 的 isSpeakerOutputPreferred/isSpeakerOutputForced。先只读确认当前 package_config 指向 livekit_client-2.10.0；其 room.dart/hardware.dart 的旧实现是相应新方法直接转发。新方法保持 await、try/catch、force=true、原诊断文本。若无法证明等价则停止该实现，不猜替代 API；不运行 RTC/设备。
5. 两份设计系统测试中的四处 `containsSemantics` 替换为 `isSemantics`，全部参数与断言保持。当前 Flutter SDK matchers.dart 旧函数直接转发新函数；先核对这一来源，不弱化语义断言。

禁止 ignore/suppress lint、调整 analysis_options、SDK/依赖/锁文件、放宽失败条件或顺带功能/格式清理。

## 新预算与验证

编辑后仅对八个目标文件最多一次 dart format 写入、一次只读 format 核对及 git diff --check。一次模块目录 `flutter analyze --no-pub`，硬时限180秒、两路输出各64KiB上限；结果非零/超时/启动失败，原样记录并停，不修正复跑。分析通过后仅一次 `flutter test --no-pub test/design_system/components/browse_scaffold_semantics_test.dart test/design_system/components/floating_dock_bottom_bar_semantics_test.dart test/features/chat/data/dto/send_message_contract_dto_test.dart test/core/telemetry/frontend_telemetry_test.dart`（180秒硬时限、两路输出各64KiB上限），失败即停、不重跑。测试仅使用现有人工/假服务，不触发真实网络。工具自身本地缓存允许，不手工改缓存。没有新测试编写授权；现有验证覆盖加静态等价审查用于本次机械迁移。

summary 记录前后哈希、最小差异、两份 SDK 转发来源、实际命令/退出码/耗时/输出截断、各预算、其它非忽略路径状态变化及限制。保留首个失败；作者不得自接受、派发后继或改 authority。

不运行 pub get、构建/Android/Gradle/AAR、adb/设备、网络、UAC、真实数据/备份/密钥/SSH/生产 API；不访问旧 D:\EliteSync、不提交/pull/push。即使分析和测试通过，也不证明 M5 运行、真实账号或真实 Conversation 权限；APP-T12 G-08/G-11、AUTH-170、AUTH-155 Phase B、CMS 认证/隔离恢复及账号回填门不变。

