# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-01-LEGACY-PRIVATE-READ-WRITE-CONTAINMENT`

Risk Level: `LEVEL 2`（私密聊天缓存和重启前展示；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。Owner 已选择按账户加密缓存、在线重验前锁定，并授权旧未加密聊天缓存清除，接受未发送草稿可能丢失。本任务先阻断旧读写；清除旧值另立任务。本任务只交付候选，不自接受或派发后继。

## Objective / allowed paths

在 Flutter 旧聊天页面停止对 `SharedPreferences` 私密缓存的读取、写入和提前展示：`chat_draft_*` 文字草稿、`messages_conversation_snapshot_v1` 会话快照/名称/预览/未读、`messages_search_history` 搜索词。现有本次打开页面期间的输入框、搜索交互和在线/模拟 provider 列表可继续在内存中工作，但不得把旧缓存或刷新 loading/error 当作已核验的恢复内容。仅允许修改：

- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart`
- 对应既有 `apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart` 与 `conversation_list_page_test.dart`
- 新增 `EVIDENCE/CACHE-01-LEGACY-PRIVATE-READ-WRITE-CONTAINMENT/summary.md`

不新增加密缓存、真实在线权威来源或历史只读；不触碰账户、Token、其他缓存、存储服务、登录/登出与启动入口。不得读取设备现存值或清除真实设备数据。

## Acceptance criteria / verification budget

负向测试至少覆盖：预置旧草稿时不回填、不再写草稿；预置旧会话快照且 provider loading/error 时不显示旧名称/预览；搜索历史不从旧键加载、不向旧键写入。覆盖当前页面内合理交互未被意外破坏。注意异步回调与页面销毁/权限失效：不得因旧 future 完成后重新展示或写入私密值。已有期待旧快照 fallback 的测试应改为符合新决定的负向断言，不得简单删掉而不验证。运行这两个页面的 targeted Flutter tests 各一次，及一次 `git diff --check`；测试失败先定位，必要时按具体风险补一次受限复验。可运行有界 analyze，但不做全量 Flutter/Android、设备、HTTP/API、DB 或网络。回执记录精确基线、改动路径/blob、实际检查、失败及未运行项。

## Stop conditions / review

如果旧缓存与当前页面功能无法安全切开，停止并报告具体调用路径；不得用新的持久键重建等价未加密缓存。保留无关 untracked 目录；不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。候选停在 Work LEVEL 2 独立验收门。后继任务处理升级及登出/换账户时精确清除旧值，包括动态草稿前缀，不得用 `SharedPreferences.clear()` 或扩大到其他类别。
