# APP-HM-05｜Home 未建立 Conversation 状态码失败关闭修复

状态：`ISSUED`；风险 `LEVEL 2`（仅 synthetic Home 摘要）；派发既有 Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。APP-HM-04 因 Home 透出内部默认 `CV_LOCKED` 而被 Work 拒绝为完整切片，旧预算耗尽且不得重用。本任务有独立新预算；交付后停 Work 独立审查。

## 精确范围

唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，保留全部既有工作区。先读 `TASK_CURRENT.md`、APP-HM-04 的 task/summary/work-review、本地 workflow/runtime 技能，核对两文件基线哈希。

只允许修改：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，输入 SHA-256 `18338B3D5EDF4EDA86AAB9C3B19DAC68FD8CFB65726EE9D73518D028475580F3`；
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，输入 SHA-256 `3D3DFD34D1009A8AB6D88BD496D6377F151A23B8632956800256482AF94F9640`；
- 新增本目录 `summary.md`。

仅在 Home 投影的 Conversation 摘要中，无 synthetic development 状态时 `stateCode=null`；保留 `authority=notYetEstablished` 和既有安全导航。已知 synthetic `CV_LOCKED`/`CV_ACTIVE` 仍公开其演示状态码。不要修改 `ConversationAccessSnapshot.notYetEstablished()` 内部安全默认，也不要改变 Connection、Match、ready、真实权威或路由。补 APP-HM-04 缺失来源用例对 `stateCode=null` 的负向断言，并保留 ready 主循环中已知 `CV_LOCKED` 与 `CV_ACTIVE` 断言；原八例继续通过。

## 新一次性验证预算

执行前只读核对输入哈希、`.dart_tool/package_config.json` 和本机 `dart`/`flutter` 可用；不运行 `pub get`、下载或设备。两文件各最多一次 `dart format` 写入，写入后各最多一次 `dart format --output=none --set-exit-if-changed` 只读复核，退出 0 才可报格式 PASS。运行 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑一次；仅可归因于本次编辑缺陷的失败可修后额外复跑一次。对两文件运行 `git diff --check`。不运行全套、模拟器、网络、后端或真实数据。

`summary.md` 记录输入/输出哈希、未建立与已知 Conversation 摘要区别、退出码/用例数和未证实权威。回退只撤销本任务新增差异及摘要，保留 APP-HM-01～04 与所有无关状态。不得访问旧 `D:\EliteSync`、SSH、云/生产 API、真实 DB/备份/密钥；不得提交、pull、push、自验收或派发后继。会话当前 30 个实际 turn；完成后 Work 复核 30 条阈值再决定交接。
