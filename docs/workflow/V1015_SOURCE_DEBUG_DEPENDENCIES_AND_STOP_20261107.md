# v10.1.5 Debug依赖已补齐，首次源码构建STOP｜2026-11-07

**DEBUG_DEPENDENCIES_SUPPLEMENTED / FIRST_SOURCE_DEBUG_BUILD_FAILED / SCOPE_SPENT_1_REMAINING_0 / NO_NEW_APK / G2_FALSE**

Owner已答复“允许补齐缺失 Debug 依赖”，限定不升级工具、不接受新许可，构建仍离线。接续源码`f4803c4a42820f9a380ea748f1451220eeb718b0`，apps树`628795cf5fca95b4fb602695a295c0e987839eb4`；本节点没有改变产品源码、版本或原AAR路线。

## 实际结果

新独立范围`v1015-source-debug-host-20261107-case01`仅调用现有launch一次；完整输入/资源核验后创建唯一claim并实际启动SDK。**本范围已耗1、余0，STOP关闭，不重跑、不换目录续额。** 既有4GiB AAR和Release-AAR Debug host仍各耗1余0，原合同/nonce/claim/STOP不改。

| 项目 | 本次实测 |
|---|---|
| fresh启动可用内存 | 12443MiB，超过5120MiB门；不是未来资源快照 |
| 启动时工作卷空闲 | 332481634304字节 |
| 完整launch调用 | 472.734秒，含输入/资源核验及调用收尾 |
| SDK / Gradle | 53.656秒 / 52秒 |
| 已完成任务 | 仅Flutter Gradle插件的4项任务，4项执行 |
| Job记账峰值 | 1830834176字节，约1.705GiB；本次失败阶段的峰值 |
| 退出 | Java root1、controller32；持有controller PID事后不存在 |

失败位于官方module loader触发的`:flutter`配置阶段：Flutter Gradle插件声明的Kotlin1.8.0 classpath缺少10项传递依赖。实际日志为离线缓存缺失，未见OOM/超时原因。**未进入Dart/APP编译，没有新APK，安装/运行/attach/热重载均NOT_RUN。** 此阶段未达到4GiB不保证完整源码构建都能在4GiB内完成。

## 已完成的依赖与稳定目录准备

- 从Flutter官方Google Storage取得当前引擎`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`的Debug embedding及ARM64 Debug两个组件，2份JAR共172438878字节，另有2份POM。核对服务器ETag/MD5及长度、记录SHA256、检查ZIP与ARM64 ELF；原生包自带Vulkan验证层，现有APP打包规则继续排除它。
- 首次SDK失败后，依同一依赖补齐许可，将实际10项Kotlin缺口及该插件原声明KGP1.8.0的静态JVM运行依赖闭包补入独立私有仓库：**25个固定组件、54文件、76825868字节**。逐项核对Maven Central发布SHA1并记录SHA256。不下载源码/javadoc/test-fixtures，不切换APP Kotlin版本、不安装升级工具或接受新许可。
- Kotlin补充仓库与已STOP范围的原Maven输入仓库分开；未应用到旧合同、未创建后继SDK scope/grant/claim。缓存中复用依赖的目录存在检查不等于完整Gradle离线解析；**补齐后的解析与构建NOT_RETESTED**。
- 稳定私有工作目录`EliteSyncDev/v1015-source-debug-workspace`已准备完整清单：63036文件/6283649033字节。SDK只复制一次，完成副本在准备修复后复用；未移动或改写原SDK/原证。
- 旧私有Flutter SDK原来绑定旧AAR根及Release模式，已在新副本仅适配根路径、Debug guard与Flutter-tools package URI，保留直接Dart snapshot、localEngine限制和ALREADY_LOCKED限制，保存原文及前后hash。私有APP沿用已安装NDK28.2.13676358的显式pin。15项Android插件清单中实际14项native、1项Dart实现，注册源保留14项。
- 旧SDK生成的Gradle缓存已被先前SDK运行更新/删除，不能把旧准备清单当现状；本次不复用这些生成缓存，已复制的缓存保留在本轮原证，最终实际工作树仍完整清单。准备阶段发生的校验/配置写入修复均在同一scope、claim前，没有退款、继任scope或SDK重试。

终结生成清单阶段330.578秒，不包含此前复制/准备修复的完整耗时；总准备耗时未完整计时，不作性能提升或本机profiling结论。此前34项策略检查、17项Python和8项Groovy配置fixture保持原证，本轮没有重跑或冒充新测。

## 下一候选及边界

已形成未应用的固定init候选，将Kotlin补充仓库同时接入pluginManagement、buildscript classpath、settings依赖仓库和Flutter Gradle included-build运行依赖，按组件/版本精确过滤；只加APP运行依赖仓库不足以处理本次失败。候选及补充清单可在Owner新运行决定前审阅，尚未执行验证。

现范围已STOP耗尽。依据Owner“不重试、不换目录续额”，本次补依赖不自动产生下一次运行额度。后续若明确批准新输入候选的一次运行，仍为Job4GiB/启动5120MiB/串行/64进程、SDK1800秒/host2100秒/收尾45秒、8GiB工作预算/2GiB输出采样、离线、不重试；由既有launch一次fresh核验，资源不足/preclaim阻断保留余额、不轮询自动启动。设备资格及安装/运行另核，不因USB偏好扩权。

非作者Codex确认了本次失败原因、余额和旧scope关闭；自测/非作者复核不是外部独立验收。LOCAL_ONLY根名`v1015-source-debug-dependencies-20261107`及`v1015-source-debug-runtime-20261107`保存下载/校验、私有适配、失败原始日志、下一候选和最终Git回执；二进制、许可证、私有原证不上GitHub。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。原验证APK及既有功能证据保持；原dirty根/SDK/DB/备份/STOP及无关`%SystemDrive%/`保护。无设备、后端/DB、VM、媒体/真实Push或云端运行；旧VM teardown UNKNOWN，不合main、不发布、不启v10.1.6。
