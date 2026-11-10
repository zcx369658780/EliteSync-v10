# APP-HM-02｜Synthetic Home 候选格式修复与定向回归

状态：`ISSUED`；风险 `LEVEL 2`（APP-HM-01 候选收口）；派发既有 Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。APP-HM-01 因两份格式检查失败被 Work 拒绝为完整切片，旧预算耗尽且不得复用；本任务是独立新预算。完成后停 Work 独立审查。

## 精确允许路径与行为

唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。先读当前 `TASK_CURRENT.md`、APP-HM-01 的 task/summary/work-review、本地 workflow/runtime 技能，核对本任务基线哈希。仅允许修改：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，当前 SHA-256 `CCE29A835FBC910BEA917285FB7335BFF22DC0B3D1CA5941C1C2CC71DE859678`；
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，当前 SHA-256 `1595DA1CEEC5A5ACDF0582E5FDC8062C3D5D8C36DFA55B6606BC48BF49C5FDDB`；
- 新增本目录 `summary.md`。

只修 Dart 格式，不改 APP-HM-01 已审语义、测试断言或其它产品逻辑。可在上述两文件运行一次 `dart format` 写入格式；核对格式差异只涉及排版。若格式化引入无法说明的语义差异或扩大到其他文件，停 Work 审查，不自行修其它路径。

## 新一次性预算与停点

核对 `.dart_tool/package_config.json` 存在与 `flutter`、`dart` 可用，不执行 `pub get`、下载或设备动作。两文件各最多一次格式写入命令；写入后各最多一次只读 `dart format --output=none --set-exit-if-changed`，需退出 0 才可报告格式 PASS。`flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑一次；仅本次排版失误导致失败可修正并对该文件最多复跑一次。对两文件运行 `git diff --check`。不跑全套、模拟器、网络、后端、真实数据或恢复。

`summary.md` 记录输入/输出哈希、格式差异、检查退出码、测试数及语义保持边界。不得提交、pull、push；不得访问旧 `D:\EliteSync`、SSH、云/生产、真实 DB/备份/密钥。作者停 Work LEVEL 2 ACCEPT/REJECT，不自接受或启动后继。回退仅撤销本任务两文件中的格式差异与摘要，保留 APP-HM-01 候选和全部无关工作区。
