# EliteSync-v10｜v10.0.7 Astra 独立审查 R1 定点返修意见

2026-10-15。分类：**NOT_ACCEPTED_PENDING_TARGETED_R1 / FREEZE_UNCHANGED / NO_MAIN_INTEGRATION / NO_V10_0_8_DISPATCH**。

本文件是针对初始候选的非作者、独立 GitHub 证据审查结果，**不是新版计划或新增AC，不重写原始执行报告和失败**。验收仍按 [固定v10.0.7 plan](https://github.com/zcx369658780/EliteSync-v10/blob/ef1bf4d07f5d7b84a38fb0f59f2efbe951ff4307/docs/versions/v10.0.7/plan.md)（Blob `151d75b67238826841467fa93c140825ebf61282`）之AC-07-01～08。

## 固定事实与独立访问边界

- 固定实施起点：`0989812c141ce892915b67c14e9291d34e3c7053` / Tree `c2dd89f3a0726bff6cd18fb8fe0008c2f347aadf`。
- 初始候选：`69b3f26c6ed28a7306e4ba6b902aac2475bfe103` / Tree `09982c2349fb47c276018ff24aa30ac2f267dc34`，远端 `codex/v10.0.7-app-restoration` HEAD一致。相对起点 ahead2/behind0，merge-base精确为起点。
- 产品/构建源码锚：`7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f` / Tree `754b9a65b41ac9393687417836e380effc81c09b`。后续仅文档/安全证据；最终候选的 apps/services Git Tree 与该锚一致。核两棵子树相对起点：apps共43项、services共34项变更；GitHub compare单次最多显示300文件，不能据截断列表误报零后端修改。
- 实际读取候选 [EXECUTION_REPORT](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/EXECUTION_REPORT.md)、[TEST_RESULTS](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/TEST_RESULTS.md)、[manifest](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/manifest.json)、具名PHP/Dart源码和测试、原始安全receipt/stdout/stderr、跨账户DB/API/权限及相关APP/Blade原始截图。Windows实际运行来自Codex报告，Astra并未重启本地服务/AVD或下载物理APK/AAR、重算其物理SHA。
- 交付报告记录本地专用库 `elitesync_v1007_dev`、127.0.0.1:43317、8个虚构开发用户、157题去重/137启用、58项迁移、Match4、CN/MC及图片/通知等可核对象。实际GitHub原证支持APP真实匹配/Connection/MC、Bob/Alice消息及图片、禁用/撤销/拉黑拒绝、服务/DB重启，不能把这些成果归零或要求重做所有功能。
- PHP相关139项/1162断言exit0，另5项/34断言exit0；产品lib分析无问题；build-07及安装回执exit0，AAR/APK物理sha由Codex记录，LOCAL_ONLY。

## 实质性定点发现

### R1-01｜私密消息通知的API出参/落库泄漏绕过消息撤销边界（关联AC-07-05、07-07）

在初始候选源码中：
- `services/backend-laravel/app/Services/ConversationAtomicSendService.php` 用实际消息 `notificationBody()` 返回最多90字消息文本，再作为 `AppNotificationItem.body` 持久保存，同时title/route_args含发送者名称。
- `services/backend-laravel/app/Http/Controllers/Api/V1/NotificationController.php::index/shapeNotification` 对已登录用户直接回传持久的 `body/title/payload/route_args`，**没有就消息的当前Connection/MC read gate重新校验或脱敏**。
- Astra实际读取初始候选 `evidence/final-before-revoke-notifications.json`：响应内含明文 `V1007 Alice APP reply final 01` 和发送者姓名；`db-final-business-02.stdout`中消息内容是密文而通知 `body`为明文。APP的 `NotificationPrivacyContract.inAppPreviewFor` 虽会显示通用文案，**并不代替服务端API/持久数据隐私控制**。
- 初始证据只证明撤销后 `messages` / `media/content` 404，没有给出**撤销后的通知API反例**。由当前代码可确定该字段返回路径缺少MC门；需要实际负例核实并消除，不可因为前端掩码而视为权限完整。

**同版定点修复**：为本版live message通知采用最小信息原则，原始消息正文和不必要的对方身份不得在消息通知API中暴露；优先不将明文消息正文作为新通知永久入库，已有记录在读取层也须在撤销、block、disabled/未知权限时fail-closed或返回安全泛化投影。保证已授权场景的站内事件、未读计数、已读操作仍可用；不能以清空所有通知绕过测试。验证实际MC_ACTIVE→REVOKED、block及用户失效前后，API回包不泄露消息文本/敏感身份；消息及媒体撤权测试保持。仅处理本版相关消息通知，不扩成Push/RTC或新后台系统。

### R1-02｜全量Flutter实际6项失败：其中聊天mock断言在本轮被改动且不成立（关联AC-07-08）

独立读取 `evidence/flutter-full-final-03.json/.stdout`：792通过6失败，exit1。六项分别为：
1. `test/features/chat/data/datasource/chat_remote_data_source_send_test.dart` 新/改断言期望mock `serverMessageId=1`，实际 `990000499`；该测试Blob本轮已变，`ChatRemoteDataSource.dart`旧/新Blob却相同，当前代码确实固定返回990000499。属本版实际不一致，须确认类型契约、修正真实错误/有误断言并验证，不得为迎合测试改变真实消息ID的权限/幂等语义。
2. `conversation_access_gate_test.dart` 要求既有“拉黑与举报是两个独立控制”文案，当前既有Widget无此文本；测试与Widget相对固定起点Blob均未改变。
3. `match_round_contract_view_test.dart` 要求reveal不显示给定headline，当前旧Widget渲染该文本；测试/Widget本轮均未改变。须判断是否是“Match自动授权聊天”的真实错误，而非只修文案掩盖权限。
4–5. `qualification_diagnostic_preview_test.dart` 与 `qualification_diagnostic_test.dart` setUpAll缺同次PHP JSON fixture；两测试Blob、依赖清单均相对固定起点未变。不可将普通 `flutter test` 无fixture失败谎报已验证的产品回归。
6. `synthetic_main_loop_recovery_baseline_test.dart`期望 `/progress/match`，实际 `/progress`；该测试及`calm_home_projection_provider.dart`本轮Blob未变，需定点判别受路由变动影响与否。

**同版定点修复/归因**：优先修本版变更的聊天typed mock断言，并在必要时修引入的路由/会话授权语义。其余每项允许借助**固定实施起点的源对象/必要同条件定点基线复测**归因；如果确属原先已存在的legacy/fixture缺陷，不强制改变冻结范围或伪造全绿，但须有可读证据证明与本版实现无关，隔离说明如何运行必须同次PHP fixture的诊断套件。不得删测试、减断言、silent skip、将exit1当exit0。实际本版修改引入的失败应修复重测。

### R1-03｜全范围Dart分析exit1的3条info需准确分级（关联AC-07-08）

原始 `dart-analyze-final-02` 显示3条info（两个qualification diagnostics测试直接import未申明crypto、一条字符串插值建议）；对应测试与pubspec.yaml在固定起点与候选Blob相同，产品lib另有独立No issues found! exit0。可通过有证据的继承性归因并登记为**既存测试info**，或在不改变既有锁/生产依赖的范围内定点清理；不得声称原全仓analyze已通过。

## 逐条初始验收状态

| 固定AC | 初始审查 | 依据与下一步 |
|---|---|---|
| AC-07-01 | 功能证据支持，待最终终验 | 基线/隔离/题库/工具与受保护资产有回执；本地身份属Codex报告 |
| AC-07-02 | 功能证据支持，待最终终验 | 资料、20题、持久草稿和重启API/DB/APP证据一致 |
| AC-07-03 | 功能证据支持，待最终终验 | consumer运行、Match4、解释权重和失败恢复留有原证 |
| AC-07-04 | 功能证据支持，待最终终验 | CN/MC独立revision、双方操作与撤回及权限拒绝已具名核查 |
| AC-07-05 | **R1** | 消息/图片双端主链已有原证；通知字段旁路存疑，需服务端最小信息与撤销后否定证据 |
| AC-07-06 | 功能证据支持，待最终终验 | 八字/MBTI/降级解释有APP/API/DB证据，保留未核西占紫微 |
| AC-07-07 | **R1** | 动态和站内通知/本地设置有功能证据；message通知的原始API隐私投影需修正 |
| AC-07-08 | **R1** | 包和PHP有原证；Flutter6项及全范围analyze3 info尚未可接受地归因/修复 |

结论：**TARGETED_R1_REQUIRED — NO_FINAL_ACCEPTANCE**。保留初始候选、构建包和成功业务证据；只要求本版原AC范围内定点修复、必要差异回归与安全证据，避免重复K08、全量算法/RTC/旧历史树核验。原冻结plan与AC字节不动，不合并main、不派发0.8。Owner按现行工作流手动把本审查结果转交Codex，在同一v10.0.7版本返修后提供新固定候选，由Astra重点复核R1和受影响回归。
