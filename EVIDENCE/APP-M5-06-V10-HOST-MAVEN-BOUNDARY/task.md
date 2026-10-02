# APP-M5-06｜移除当前 Android host 的旧仓库 Maven 探测

状态 `ISSUED`；LEVEL 2（构建配置/依赖来源边界）；派发最新Codex `01a0ef77-af94-75e2-8726-87c04e082018`，Sol/medium，交付后停Work独立审查。

唯一仓库D:\EliteSync-v10，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，保留全部既存修改。先读根规则、CURRENT/TASK_CURRENT/PRODUCT_DECISIONS/REVIEW_GATE与APP-M5-05 plan/work-review。唯一可改现有文件 `apps/android/settings.gradle.kts`，输入SHA-256 `A976B7F3D9C4F8446F7AE32A5817188CF4F11A021DD854152CB327A28277D88C`；另仅新增本目录summary.md。

当前settings的pluginManagement与dependencyResolutionManagement各有一个完全相同的localWindowsMaven块：对旧D:/EliteSync/gradle-local-m2构建File、读取osName、exists()探测后注册maven repo。本任务仅删除这两个完整块；保留全部其它repositories的内容、顺序、content过滤、Flutter当前模块repo、plugin映射、rootProject.name/include。不得换成另一猜测缓存路径，不访问/枚举/检查旧目录，不引入新repo、依赖、下载或认证，不把源码中的旧字面量当访问授权。只删除仓内当前代码的明确旧引用，不进行全仓Legacy清理。

新静态预算：输入哈希核对后编辑一次；最终定点检查1次（目标file里旧路径与localWindowsMaven/osName均不再存在，除两个已定位块以外的文本与输入保留），git diff --check目标file一次、最终哈希/目标状态一次。无Gradle/Kotlin/Flutter运行、测试或构建预算；不得读取local.properties、.android/local.properties或凭据。不加入抑制配置或其它格式改动。

summary写前后哈希、两块准确位置/移除事实、静态/空白结果、其它路径保留及依赖解析仍NOT_CHECKED。这是消除旧仓库访问路径的source-only候选；不证明Gradle可运行、依赖完整、AAR身份或APK安全。M5仍NOT_READY，标记/端点/AAR守卫仍NOT_FIXED。旧G12 FAIL/预算以及现有PASS证据各自保留，真实权限/恢复门不变。

无旧仓库、真实数据/备份/密钥/SSH/网络/设备/UAC访问；不提交/pull/push、自接受或派发后继。若输入/范围不符则停止，不扩大路径。

