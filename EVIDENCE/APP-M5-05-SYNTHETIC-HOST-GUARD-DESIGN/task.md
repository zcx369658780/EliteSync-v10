# APP-M5-05｜Android synthetic host 标记与端点守卫设计

状态：`ISSUED`；风险 `LEVEL 2`（平台/端点/构建链，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-M5-02～04 Work 审查。只允许新增本目录 `plan.md`；不修改源码、Gradle、测试、配置或 authority。

最多两轮本地静态核对。第一轮定点读 `apps/android/app/build.gradle.kts`、`apps/android/settings.gradle.kts`、`MainActivity.kt`、Manifest、`apps/flutter_elitesync_module/lib/main.dart` 和 `main_demo.dart`，明确当前 AAR 命令、prod/debug BuildConfig 端点、Intent/本地 bootstrap 覆盖和 demo 的本地写入。第二轮仅读这些直接调用的当前文件与固定的 Gradle task/variant 直接定义，确定最小的**实现前合同**：synthetic 标记必须只在受控 debug 路径显式生效；AAR 与 host 标记一致且不能复用 CI 旧 release AAR；synthetic 的 API/WS 只能为 loopback/无可达真实端点，Intent 与本地 bootstrap 不能覆盖为非 loopback；缺失/拼错标记保持现有 prod 行为，release 不得误进 demo。若当前 Kotlin/Gradle 结构不能以有界修改达成，明确 `NOT_FIXED` 而不发明可运行命令。

`plan.md` 记录两轮准确来源、关键文件 SHA-256、当前与建议的参数/变体/端点关系、负向用例、唯一最小实现任务的允许路径与回退，以及仍待证明的设备/构建条件。预算 2/2，只读不运行 Gradle、Flutter、adb、构建、网络、设备、UAC；不读 local.properties 内容或凭据，不访问旧 `D:\EliteSync`、真实数据/备份/密钥/SSH/云/生产 API。不得提交、pull、push、自接受或派发后继。M5 设备 `UNKNOWN`、运行 `NOT_READY`；APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
