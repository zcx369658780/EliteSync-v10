# APP-G11-09｜Stored 列表缺失 peer 的页面失败关闭回归

状态：`ISSUED`；风险 `LEVEL 2`（Chat 列表到私密路由，test-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 全部保留。先读根本地规则和当前状态、APP-G11-08 的 `work-review.md`、APP-G11-07 的 `work-review.md`，再核对列表入口和测试夹具。Codex 会话派发前观察为 14 个实际 turn、idle，低于 30 条阈值。

唯一允许修改的产品仓库文件：`apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart`；输入 SHA-256 `2D4D2664C4A97571FEBC87E1CCCACF68FA298408DE52C55DA48AB95F36B89935`。另允许新增本目录 `summary.md`。不得改产品代码、其它测试、DTO、router、后端或文档 authority。

目标：沿现有人工列表 widget/GoRouter 夹具，验证明确 `stored_conversation`、正 `conversationId`、数字旧 `id`，但 `peerUserId` 缺失/0/负数时，点击后显示既有安全提示，仍停列表，不构建私密 Chat 目标、不传 typed extra。保留并核对已有显式正 peer 的 stored 导航正例。只测页面行为；不把路由状态当作真实 consent、read/send 或 actor/audience 权限，不扩大到真实数据。

## 本任务新一次性预算与停点

编辑前只读核对目标哈希、`.dart_tool/package_config.json` 和本地 `dart`/`flutter`。编辑后执行一次 `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart`；仅本任务测试夹具缺陷可修后额外复跑同一命令一次。所有必要编辑后，目标文件最多一次 `dart format` 写入及一次只读 `dart format --output=none --set-exit-if-changed`；格式写入仅改排版时无需复测。运行针对目标文件的 `git diff --check`。不运行全套、设备、网络、后端或真实数据验证。

`summary.md` 记录输入/最终哈希、差异范围、实测用例与退出码、预算、格式/空白检查、局限和回退范围。若预算内无法保留 stored 正例或出现非夹具失败，原样记录并停，不扩路径或自接受。回退仅撤销本任务测试新增差异与摘要，保留 APP-G11-01～08 和全部无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或自行启动后继。APP-T12 G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填仍未放行。
