# APP-M5-06｜旧仓库 Maven 探测移除候选

状态：SOURCE-ONLY CANDIDATE；待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 D:\EliteSync-v10，main，HEAD cf8bfaa4a03b8c9a682105617b185141904413be。

唯一修改现有文件：apps/android/settings.gradle.kts。输入 SHA-256 核对通过：A976B7F3D9C4F8446F7AE32A5817188CF4F11A021DD854152CB327A28277D88C；输出 SHA-256：781C2CDBD80B6F0ADD4ACE7A67CD84EDC7B49071238C21399BD6B8AB131438C1。

一次编辑删除两个完全相同的10行 localWindowsMaven 块：输入第16–25行（pluginManagement.repositories）、第54–63行（dependencyResolutionManagement.repositories）。移除旧路径 File 构造、osName 读取、exists 探测及该本地 Maven 注册；没有访问字面量所指旧目录，也没有引入替代路径或新仓库。

预算：输入哈希核对后编辑1/1；最终定点检查1/1 PASS，目标旧路径/localWindowsMaven/osName均已消失，输出字节严格等于输入仅删除两个已定位块后的结果；git diff --check目标文件1/1，退出0、无输出；最终哈希/目标状态检查1/1完成。所有其它 repositories 内容、顺序、content过滤、Flutter当前模块repo、plugin映射、rootProject.name/include及其它字节原样保留，无其它格式整理。

summary写入前状态条目从149到150；新增状态[' M apps/android/settings.gradle.kts']，移除状态[]，变化仅限目标settings文件。全部既有dirty/untracked状态保留；本摘要是本轮唯一新增交付文件。状态比较仅建立非忽略路径状态事实。

依赖解析 NOT_CHECKED；未运行 Gradle/Kotlin/Flutter、测试或构建，未读取任何 local.properties/.android/local.properties或凭据；没有旧仓库、真实数据/备份/密钥/SSH/网络/设备/UAC访问，无提交/pull/push、authority更新、自接受或后继派发。

这仅消除目标源码中的两处旧仓库探测，不证明Gradle可运行、依赖完整、AAR身份或APK安全。M5运行 NOT_READY，标记/端点/AAR守卫 NOT_FIXED；旧G12 FAIL和耗尽预算、现有G12 PASS证据各自保留，真实权限和恢复门不变。停止等待Work独立LEVEL 2审查。
