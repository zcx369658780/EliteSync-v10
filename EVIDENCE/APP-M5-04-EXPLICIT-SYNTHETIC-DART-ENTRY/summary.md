# APP-M5-04｜显式 synthetic Dart 入口候选

状态：Codex source-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。本地仓库 `D:\EliteSync-v10`、分支 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。唯一源码差异为 `apps/flutter_elitesync_module/lib/main.dart`，另仅新增本摘要。

## 差异与输入

`main.dart` 修改前 SHA-256：`CB356264EBEEFF5F75CFCFA8195E59ED8218F19752895EEDA226DDDED698C60A`，与任务固定输入一致；修改后 SHA-256：`F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54`。模块 `.dart_tool/package_config.json` 存在；本地 `dart`、`flutter` 均从 `D:\flutter\bin` 解析。未执行版本、doctor、pub 或其它环境检查。

入口增加 `const bool.fromEnvironment('ELITESYNC_SYNTHETIC_DEMO')` 分支：仅编译期布尔值为 true 时调用现有 `main_demo.dart` 的 `main()` 并返回；缺失、拼错或非 true 值继续调用原 `main_prod.dart` 的 `main()`。没有 runtime 字符串或远端配置选择入口；未修改 demo/prod 的行为、host Gradle、MainActivity、端点、存储或权限。

## 本次验证与预算

| 命令（模块目录内，空白检查在仓库根） | 次数 | 退出码与结果 |
| --- | ---: | --- |
| `dart format lib/main.dart` | 写入 1/1 | 0；Formatted 1 file，0 changed |
| `dart format --output=none --set-exit-if-changed lib/main.dart` | 只读 1/1 | 0；0 changed |
| `flutter analyze --no-pub lib/main.dart` | 1/1 | 0；No issues found |
| `git diff --check -- apps/flutter_elitesync_module/lib/main.dart` | 完成 | 0；无空白错误（Git 仅提示未来可能转换行尾） |

额外同一 analyze 复核 **0/1，未使用**；未运行测试套件、Flutter app、Gradle/AAR/build、设备、adb、网络、UAC 或安装。作者检查只证明此文件静态分派和定向分析通过，未证明 AAR 产物实际采用该标记。

## 限制、回退与停点

Android host 尚未把该标记与端点隔离绑定，旧预制 AAR 的身份也未核实；本候选不形成可安全安装的 synthetic host，M5 运行仍 `NOT_READY`，设备仍 `UNKNOWN`。后继须由 Work 另立任务处理 host 端点、产物身份与受控运行门；本任务不派发后继。若 Work 拒绝，仅撤销本任务 `main.dart` 的五行差异与本摘要，保留其它工作区内容。

APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。无提交、pull、push；停 Work 独立 LEVEL 2 审查。
