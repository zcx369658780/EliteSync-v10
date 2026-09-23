# CACHE-01｜旧私密聊天缓存读写隔离候选

Status: `WORK LEVEL 2 ACCEPT`
Risk: `LEVEL 2 / Flutter presentation privacy containment`
Baseline: local `main` HEAD `7c9990798f98982beff4579a2940adda313aa2e5`，任务入口为该提交的 `TASK_CURRENT.md`。未提交、未自接受、未备份或推送。

## 结果与范围

- ChatRoomPage 不再读取、写入或删除 `chat_draft_*`；输入仅在当前页面内存中，发送失败仍回填当前输入框。
- ConversationListPage 不再读取、写入或删除 `messages_conversation_snapshot_v1`，loading 显示普通骨架，provider error 显示错误页；不把旧快照或刷新前页面内容当成恢复结果。
- `messages_search_history` 不再从本地加载或写入；本次打开页面期间的搜索与最近搜索提示只在页面内存中工作。原有 `messagesSelectedTab` 整数 UI 偏好未改。
- 删除旧缓存的异步读取、debounce 写入和快照回调后，不存在由旧 future 在页面销毁或权限失效后重新回填、展示或写入这些私密值的页面路径。未检查或清除设备现存值。

| 允许路径 | 基线 blob | 候选工作区 blob |
|---|---|---|
| `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart` | `393d9989199e462d62284645b23a4fdb43b95781` | `3ab4879d0193e6c511dc79189768e8b7ee65905e` |
| `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart` | `6a7f332254ca662cc07031fd09f242b6236292ca` | `f809be2690935604a1104b55c5d7059f4ee50fd5` |
| `apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart` | `1879d383276c2345018a0b74c3b0a66be375ae92` | `c49afe5ecbcc477f3b503592652e1b8c0b538803` |
| `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` | `5f7c485c1587dae70453b93f6dad25f8a46344cb` | `19f060631bba29cc0a1719c5edefe1fa61cb0030` |

本文件是唯一新增路径。根目录原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保持原状。

## 验证回执

工作目录：`D:\EliteSync-v10\apps\flutter_elitesync_module`；测试使用本机已有 Flutter 工具链、`--no-pub`，未解析或下载依赖。

| 检查 | 次数 | 结果 |
|---|---:|---|
| `flutter test --no-pub test/features/chat/presentation/pages/chat_room_page_test.dart` | 1 | PASS，23 tests；旧草稿不回填、不读写，当前输入和发送失败回填通过。 |
| `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart` | 1 | PASS，16 tests；旧快照在 loading/error 不展示、不读写，旧搜索词不加载/写入，当前搜索与 provider 恢复通过。 |
| `git diff --check` | 1 | PASS，exit 0；仅有 Windows 工作区 LF/CRLF 转换提示。 |

Flutter analyze、全量测试、Android/device、HTTP/API、backend、DB 与网络检查未运行。测试输出未提供 assertion 总数。不存在测试失败或复验。

## 未解决边界

本候选只停止两个页面对已识别旧键的访问，不删除设备上的旧未加密数据，也不建立加密缓存、在线重验权威或历史只读。升级、登出及换账户时对旧键（含动态草稿前缀）的精确清除需另立任务；不得由本候选推定已完成。

## Work 独立验收（2026-09-23）

**LEVEL 2 ACCEPT — 限 Flutter 两个旧聊天页面的旧私密缓存读写与提前展示隔离。** Work 在本地 `main` HEAD `7c9990798f98982beff4579a2940adda313aa2e5` 核对允许路径、四个候选 blob 和完整差异；旧草稿读取、防抖写入及发送后删除路径，旧快照加载/保存/fallback 与旧搜索历史加载/写入路径已从两个页面移除。loading 仅呈现普通骨架，provider error 呈现错误页；当前页面输入、搜索及 provider 数据列表仍工作。两个页面不再持有这些旧存储 future，因此旧 future 在页面销毁或权限变化后不能由这两个页面重新展示或写入旧私密值。这是静态代码结论，不是设备观察。

Work 独立运行两条 `flutter test --no-pub`：`chat_room_page_test.dart` **23/23 PASS**，`conversation_list_page_test.dart` **16/16 PASS**；独立运行 `git diff --check` **exit 0**（仅 LF/CRLF 提示）。测试覆盖任务单规定的旧草稿不回填/不读写、旧快照在 loading/error 不展示/不读写、旧搜索历史不加载/写入，以及当前页交互。审查另识别：测试没有单独断言非空 provider 成功返回后快照键未写入，也没有专门构造销毁后 pending future；这一边界由移除相关调用和回调的静态差异支持，未把测试覆盖范围扩大表述。没有运行 build、analyze、设备、真实账户、API、DB 或生产检查。

旧设备值仍在，未执行清除、迁移、加密缓存或真实在线重验；后继 CACHE-02 单独处理精确清除。根目录无关未跟踪目录保持原状。接受结论不等于设备或生产就绪。
