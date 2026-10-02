# APP-M5-01｜Android 最小开发演示的本机只读预检

状态：`ISSUED`；风险 `LEVEL 2`（平台/运行链，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查，不自动运行设备或构建。

## 唯一交付

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；保留全部既有 dirty/untracked。先读根规则、当前状态、`REVIEW_GATE.md`、当前交付路线图的 M5 与最小平台检查点、现有 Flutter app 配置及当前本地相关回执。只允许新增本目录 `plan.md`；不改源码、配置、测试或 authority 文档。

最多两轮本地只读预检：第一轮固定 Flutter 模块、构建变体、入口和明确 synthetic/dev 运行路径，区分当前已接受代码与未运行证明；第二轮仅查询当前命令解析的 `flutter`/`dart`/`adb`/`java`、Flutter package config、显式 Android SDK 环境变量或项目配置所指固定位置，以及 `adb devices -l` 的设备清单（若命令存在）。不得搜索、枚举或猜测其它磁盘路径，不运行 `flutter doctor`、依赖下载、Gradle、build/install/launch、模拟器启动、网络或 UAC。命令可能启动 adb server 时，应避免执行并记为 `NOT_CHECKED`；只读可用性不确定即停该子项。记录可验证的本机能力、缺口与一张安全有界的后继最小 Android debug 运行任务建议；没有足够条件则写 `NOT_READY`，不把静态就绪写成设备运行 PASS。

`plan.md` 记录两轮来源、关键文件/固定入口 SHA-256、实际命令及退出码的最小事实、未知项、UAC 到场门和后继建议。只读预算 2/2；不触碰真实数据、DB、备份、密钥、旧 `D:\EliteSync`、SSH、云/生产 API。不得提交、pull、push、自接受、构建 APK、安装、启动设备或派发后继。APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
