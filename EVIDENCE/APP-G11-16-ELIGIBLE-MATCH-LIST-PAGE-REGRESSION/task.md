# APP-G11-16｜Eligible Match 缺失 ID 的列表点击失败关闭回归

状态：`ISSUED`；风险 `LEVEL 2`（Chat 列表到私密路由，test-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 目标与路径

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-G11-09/15 Work 审查，核对列表点击的 `ArgumentError` 安全提示。只允许修改 `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart`，输入 SHA-256 `9D7D5749C759F19DA44AA3D61B753F9938C78EA7250FD68CCE408C2F8387E239`；另允许新增本目录 `summary.md`。

在现有人工列表 widget/GoRouter 夹具中补明确 `eligible_match`、无 `conversationId`、可解析正 peer 但 `matchId` 缺失/0/负数的点击负例：显示既有安全提示、留在列表、不构建 Chat 目标、不传 typed extra。至少一例使用数字旧 `id` 诱导 peer fallback；保留已存 stored 正例、APP-G11-07/09 负例。只补测试，不改产品代码或其它测试，不宣称真实 Match/Conversation consent/read/send 或 actor/audience 权限。

## 新一次性预算与停点

编辑前核对目标哈希、`.dart_tool/package_config.json`、本地 `dart`/`flutter`。必要编辑后执行一次 `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart`；仅本任务夹具缺陷可修后额外复跑同一命令一次。所有必要编辑后目标文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；若为保持已接受最小差异不运行格式，摘要须明确最终格式未验证。运行目标文件 `git diff --check`。不运行全套、设备、网络、后端或真实数据验证。

`summary.md` 记录输入/最终哈希、本任务新增差异、测试/退出码、预算、格式/空白检查、局限与回退范围。回退仅本任务新增测试与摘要，保留 APP-G11-01～15 及全部无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或启动后继。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
