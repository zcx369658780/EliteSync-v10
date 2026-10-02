# APP-M5-04｜固定 AAR main.dart 的显式 synthetic 分派

状态：`ISSUED`；风险 `LEVEL 2`（运行入口/环境隔离，source-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-M5-03 `plan.md`/`work-review.md` 及当前 `main.dart`、`main_demo.dart`、`main_prod.dart`。唯一允许修改的现有文件 `apps/flutter_elitesync_module/lib/main.dart`，输入 SHA-256 `CB356264EBEEFF5F75CFCFA8195E59ED8218F19752895EEDA226DDDED698C60A`；另允许新增本目录 `summary.md`。

只在固定 AAR `lib/main.dart` 增加编译期**显式、默认关闭**的 `ELITESYNC_SYNTHETIC_DEMO` 布尔分派：为 true 时调用现有 `main_demo.dart` 的入口，否则仍调用现有 `main_prod.dart`。不改这两个入口的行为、host Gradle、MainActivity、端点、存储或权限；拼错/缺失标记不得进入 demo。不得让 runtime 字符串或远端配置切换此入口。本任务仅准备 Dart 入口，**不形成可安全安装的 synthetic host**；host 端点与产物身份须后继独立处理。

## 新一次性预算与停点

编辑前核对唯一输入哈希、package config 与本地 Dart/Flutter。必要编辑后对目标文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`，并执行一次 `flutter analyze --no-pub lib/main.dart`；仅本文件实现缺陷可修后额外复核同一 analyze 命令一次。目标文件运行 `git diff --check`。不运行 Flutter app、测试套件、Gradle/AAR/build、设备、网络、UAC 或真实数据。若 analyzer 因任务外环境或既有问题失败，原样记录并停，不扩路径或重置旧预算。

`summary.md` 记录前后哈希、精确分派、命令/退出码、预算、格式/空白检查及局限和回退。回退只撤销本任务 `main.dart` 差异与摘要，保留全部其它工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或派发后继。设备仍 `UNKNOWN`、M5 运行 `NOT_READY`；APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
