# APP-M5-03｜Android host synthetic 入口与端点静态合同

状态：`ISSUED`；风险 `LEVEL 2`（平台/运行链与端点，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-M5-01/02 `work-review.md` 与准确来源。唯一允许新增本目录 `plan.md`；不改源码、Gradle、配置、测试或 authority 文档。

最多两轮只读静态核对。第一轮定点读 `apps/android/settings.gradle.kts`、`apps/android/app/build.gradle.kts`、当前 host 的 Flutter bridge/应用入口直接文件及模块 `lib/main.dart`、`lib/main_demo.dart`，区分 AAR 目标、host debug/release 端点和 synthetic 会话写入。第二轮只读 `D:\flutter\packages\flutter_tools\lib\src\commands\build_aar.dart` 这一 **APP-M5-02 已固定 SDK 命令来源的准确文件**，若不存在只记 `UNAVAILABLE`；并仅追踪第一轮直接调用的本仓文件。不得搜索 SDK 或其它目录，也不执行 Flutter/Gradle/adb/网络。确认当前本机 Flutter AAR 构建是否支持精确 Dart target，现有 Gradle 是否可通过受控参数选择 `main_demo.dart` 且与 host 端点/本地 synthetic 数据边界一致。给出**一张**最小可审的配置候选任务（允许路径、负向检查、回退），或明确 `NOT_FIXED`。不要据代码字符串推断运行时无网络或 APK 可安装。

`plan.md` 记录两轮准确来源、关键文件 SHA-256、可证的构建目标/端点选择、未证项与后继建议。只读预算 2/2；不读取 local.properties 内容、凭据或密钥，不触碰真实 DB/备份、旧 `D:\EliteSync`、SSH、云/生产 API，不运行构建、设备、UAC 或安装。不得提交、pull、push、自接受或派发后继。M5 设备仍 `UNKNOWN`；APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
