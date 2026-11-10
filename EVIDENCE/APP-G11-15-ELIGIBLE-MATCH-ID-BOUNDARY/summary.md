# APP-G11-15｜明确 eligible Match 的 ID 边界候选

状态：Codex 本地候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；全部既有 dirty/untracked 保留，无提交、pull、push。

| 允许文件 | 输入 SHA-256（与 task.md 一致） | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `6433BB886773453D049C6A1F8A78D1CECC54011A90AD7CE31C772B14B90D91EA` | `8E764F99E20BC5A5E0A878F014D28FADC5E225112A715A9AAAC3588883233758` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `1A41E93C1F39C3B94F14127C1825145F65AE62EAC8E7DFA5A6721AAFBFEE0F31` | `E8B4608B87D233E4F8B80C13D6B259F041A86698ED2D6106D9072360674BA8D9` |

目标差异：`ChatRouteState.fromConversation` 对明确 `entryKind == 'eligible_match'` 的项要求 `matchId` 为正；缺失、0、负数均抛 `ArgumentError`，即使显式 peer 或旧数字 `id` 可解析，也不退化为 legacy peer。新增人工 Entity 负例覆盖这三种 match ID 与两种 peer 来源。原有正 match ID 的 eligible、stored 类别/ID 与显式 peer 规则、无明确类别且无会话 ID 的旧 peer fallback、非 stored 携带会话 ID 的拒绝规则均保留。列表 UI、DTO、router、后端和权限未改。

编辑前两文件哈希吻合；`.dart_tool/package_config.json`、本地 `dart`/`flutter` 可用。必要编辑后对两文件各进行一次 `dart format` 写入（命令报告 2 文件中 1 文件改变排版）；目标测试在最终格式后的首跑退出 0，**21 个用例全部通过**，未复跑。随后两文件各一次 `dart format --output=none --set-exit-if-changed` 均退出 0、0 changed；两文件 `git diff --check` 退出 0，仅有 Git 的 LF→CRLF 将来转换提示，无空白错误。新预算分别为测试 1/1、格式写入各 1/1、只读格式复核各 1/1、空白检查 1/1；旧任务预算未重用。

本结果只证明人工本地路由身份形状，不证明真实 Match/Conversation consent、read/send、actor/audience 或 live 兼容。回退只撤销本任务两文件新增差异及本摘要，保留 APP-G11-01～14 和全部其它工作区。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
