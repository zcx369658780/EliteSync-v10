# APP-G11-15｜明确 eligible Match 不退化为旧 peer 身份

状态：`ISSUED`；风险 `LEVEL 2`（Chat 列表身份类别）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，保留全部既有 dirty/untracked。先读根规则、当前状态、APP-G11-06/08 的 Work 审查，并核对 `ChatRouteState.fromConversation` 与列表安全提示。只允许修改：

| 文件 | 输入 SHA-256 |
| --- | --- |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `6433BB886773453D049C6A1F8A78D1CECC54011A90AD7CE31C772B14B90D91EA` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `1A41E93C1F39C3B94F14127C1825145F65AE62EAC8E7DFA5A6721AAFBFEE0F31` |

另允许新增本目录 `summary.md`。只对**明确 `entryKind == 'eligible_match'`** 的 `ConversationEntity` 要求正的 `matchId`，缺失/0/负数即抛 `ArgumentError`，不得退化为 legacy peer，即使 `peerUserId` 或旧数字 `id` 有效。正 `matchId` 的 eligible 正例、明确 stored 的 APP-G11-06/08 规则、无明确 eligible/stored 且无会话 ID 的旧 peer fallback 保留；有 conversation ID 的非 stored 矛盾项继续失败关闭。不修改 DTO、列表 UI、router、后端或真实权限。

测试用人工 Entity 覆盖 eligible 缺失/无效 match ID 且有效 peer（含数字 `id` 诱导）、eligible 正例、旧 peer fallback 和 stored 正例。只证明本地路由身份形状，不证明真实 Match/Conversation consent/read/send 或 actor/audience。

## 新一次性预算与停点

编辑前只读核对两文件哈希、`.dart_tool/package_config.json` 和本地 `dart`/`flutter`。必要编辑后运行一次 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart`；仅本任务两文件的夹具/实现缺陷可修后额外复跑同一命令一次。所有必要编辑后两文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；若排版写入未改语义，无需复测。两文件运行 `git diff --check`。不运行全套、页面、设备、网络、后端或真实数据验证。

`summary.md` 记录前后哈希、差异、实测用例/退出码、预算、格式/空白检查、限制和回退范围。回退仅本任务两文件新增差异及摘要，保留 APP-G11-01～14 和全部无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或自行启动后继。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
