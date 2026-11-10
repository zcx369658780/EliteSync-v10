# APP-G11-16｜Eligible Match 列表点击失败关闭回归候选

状态：Codex test-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；全部既有 dirty/untracked 保留，无提交、pull、push。

唯一允许的既有文件 `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` 编辑前 SHA-256 为 `9D7D5749C759F19DA44AA3D61B753F9938C78EA7250FD68CCE408C2F8387E239`，与任务单一致；最终 SHA-256 为 `2E90DAA7A8A667A0FE9CB37F56A1E087749ABC554E3021B70F0387850F573B37`。编辑前 `.dart_tool/package_config.json` 与本地 `dart`/`flutter` 可用。

本任务仅在现有人工列表 widget/GoRouter 夹具中新增三例：明确 `eligible_match`、无 `conversationId`、正 peer 可解析而 `matchId` 为 null、0、-1。0 的案例用旧数字 `id='23'` 在显式 `peerUserId` 缺失时诱导 peer fallback；另两例使用显式正 peer。点击均断言既有安全提示、URI 仍为列表根路径、Chat 目标没有构建、typed extra 未传入、列表项仍可见。原 stored 导航正例及 APP-G11-07/09 负例保留；未修改产品代码、其它测试或真实权限。

| 本任务验证 | 结果 | 一次性预算 |
| --- | --- | --- |
| `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart` | 首跑退出 0；**26 个用例全部通过**，未复跑 | 1/1 |
| 目标文件 `git diff --check` | 退出 0，无空白错误；仅有 Git 将来 LF→CRLF 转换提示 | 1/1 |
| `dart format` 写入和只读复核 | 均未运行，以保留已接受测试的最小差异；**最终格式状态未验证** | 0/1、0/1 |

人工 widget 输入只证明本地列表点击的导航失败关闭，不证明真实 Match/Conversation consent、read/send、actor/audience 或线上兼容。回退仅移除本任务新增三例及本摘要，保留 APP-G11-01～15 与全部其它工作区。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
