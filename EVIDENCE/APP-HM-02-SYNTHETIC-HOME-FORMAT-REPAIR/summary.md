# APP-HM-02｜Synthetic Home 候选格式修复回执

**作者候选已交付，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅对两份任务允许的 APP-HM-01 保留候选执行 Dart formatter 写入，并新增本摘要。既有 dirty/untracked 保留，APP-HM-01 的拒绝结论与旧预算不重置。

| 文件 | 本任务输入 SHA-256（已核对） | 格式化后 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `CCE29A835FBC910BEA917285FB7335BFF22DC0B3D1CA5941C1C2CC71DE859678` | `D752B012D88178B16941E7446D56A6812DF141FA238F6AE4550C36504E7C457D` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `1595DA1CEEC5A5ACDF0582E5FDC8062C3D5D8C36DFA55B6606BC48BF49C5FDDB` | `9153BB0A13FEDB3A59460D57895149A14D4B8C47599A49847BB99D8B44D117CC` |

## 范围与行为

本轮唯一源码写入命令为 `dart format`，两个目标文件各处理 1 次。差异检查显示 formatter 调整了 provider 中布尔声明的换行及目标测试文件中的长断言、回调与缩进；未手工修改逻辑或断言。APP-HM-01 的显式 synthetic Home `unknown` → unknown authority、无已判定下一决定、安全导航；`setupRequired` 旧提示、ready 主循环和非演示分支语义均保持。此格式修复不建立 APP-T12 G-08 的真实 Home 活态来源。

## 新预算验证回执

- 执行前只读核对两份输入 SHA-256 与任务单一致；`.dart_tool/package_config.json` 存在，`flutter` 与 `dart` 命令可用；未运行 `pub get` 或下载。
- `dart format` 同时写入两份允许文件：每文件 **1/1 次**，命令退出码 `0`，报告 `2 files (2 changed)`。
- 写入后 `dart format --output=none --set-exit-if-changed`：provider **1/1 次，退出码 0，0 changed**；测试文件 **1/1 次，退出码 0，0 changed**。本轮格式门 **PASS**。
- `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart`：首跑 **1/1 次，退出码 0，4/4 tests passed**（flag-off、unknown、setupRequired、原 ready 主循环）；未复跑。
- 两文件 `git diff --check`：退出码 `0`，无尾随空白错误。

未运行全套测试、模拟器/设备、网络、后端或真实数据。回退只撤销本任务对两文件的 formatter 排版差异及本摘要，保留 APP-HM-01 原候选和全部无关工作区内容；未提交、pull 或 push。作者不自接受或启动后继，停 Work LEVEL 2 `ACCEPT/REJECT`。AUTH-170、AUTH-155 Phase B、真实 CMS 认证/隔离恢复/账号回填与 Home live projection 状态均未改变。
