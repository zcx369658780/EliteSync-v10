# v10.1.5 门户修正实际通过，默认JAR缺口补齐，case03停止｜2026-11-07

**PLUGIN_PORTAL_LOOKUP_RECOVERED / CASE03_STOP_SPENT_1_REMAINING_0 / CANONICAL_JARS_COMPLETED_STATICALLY / NO_APK / G2_FALSE**

Owner对待答的“门户修正候选另授一次真实构建”请求回复“请继续”；Codex按该一次上下文执行case03，不扩为连续重试或设备授权。源码身份`7ff9ccc163e76b0779de5c3322fa3b12748d2326`，apps树仍`628795cf5fca95b4fb602695a295c0e987839eb4`，与原接线`f4803c4a`一致；产品源码没有变化。

## 实际运行及停止

新范围`v1015-source-debug-host-20261107-case03`使用已RED/GREEN验证的门户保留init，复用稳定目录、SDK复制0次。完整清单67456文件/7029037236字节，外部49707项，未重复追加54项依赖；准备507.968秒。仅调用既有launch一次fresh核验，没有提前重复preflight或内存查询。

| 项目 | 本次结果 |
|---|---|
| fresh可用内存 | 11888MiB，超过5120MiB门 |
| 启动时工作卷空闲 | 332526243840字节 |
| 完整launch | 573.943秒，含输入/资源核验与收尾 |
| SDK / Gradle | 9.383秒 / 8秒 |
| 任务 | Flutter Gradle插件4项均up-to-date |
| Job记账峰值 | 755503104字节，约0.704GiB |
| 退出 | root1/controller32，STOP已写 |

默认插件门户遗漏已实际越过：`kotlin-dsl5.2.0`不再报找不到，Flutter Gradle插件构建项目的4项任务得以完成。随后`:flutter` classpath明确请求两个无classifier的默认文件`kotlin-gradle-plugin-api-1.8.0.jar`、`kotlin-gradle-plugin-model-1.8.0.jar`，现仓库只有对应Gradle变体JAR，因而失败。此前Codex只按选中变体补齐，遗漏默认JAR覆盖；这不是APP源码配置或编译通过。

**case03已耗1、余0，不重跑；case01/02各1/0和原4GiB AAR/host各1/0保持。** 未进入Dart/APP编译，没有新APK，安装/运行/attach/热重载NOT_RUN。峰值仅代表此失败阶段，不是完整源码构建内存结论。

## 补齐与未应用下一输入

按既有缺失Debug依赖补齐许可，逐项检查25个固定Kotlin组件的默认JAR，另发现主`kotlin-gradle-plugin-1.8.0.jar`也未包含。新独立私有仓库复制原54个已验文件，并从Maven Central补3个真正的默认JAR原件；没有把变体文件改名替代默认文件。

新仓库共**25组件、57文件、90324883字节**，保持原选中变体，3个新件核对发布SHA1、记录SHA256并通过ZIP CRC。静态核对25/25默认JAR存在，并检查默认及Gradle8.14最大兼容JVM元数据中的13个文件引用/哈希。未覆盖或声称覆盖所有较旧Gradle变体，不下载文档/源码/test-fixtures，不升级工具或接受新许可。

新init候选只把补充仓库URL指向这份完整快照，门户保留、显式仓库顺序、25项固定1.8.0过滤、buildscript隔离及FAIL_ON_PROJECT_REPOS保护不变；纯Groovy仓库策略fixture再次GREEN。原已消费的控制init、合同、nonce、claim、STOP及旧依赖仓库均不回写。没有新SDK scope/grant/claim。

非作者Codex确认实际缺少的两个默认文件与补齐对象相符，未见新可行动P1/P2；**57文件的静态检查不等于完整离线解析通过，补齐后真实解析/产包NOT_RETESTED**。本次没有SDK重试；若实际验证下一输入，须Owner明确新的那一次额度，原范围不恢复、不换目录续额。

LOCAL_ONLY新原证根名`v1015-source-debug-runtime-20261107-portal-preserved-candidate`；依赖根`v1015-source-debug-dependencies-20261107`内新增完整JVM仓库及校验回执。稳定目录保留，未重拷SDK；私有原证、二进制、许可不上GitHub。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。原已验证APK和旧功能证据不变；无设备、后端/DB、VM、云、媒体或真实Push运行，旧VM teardown UNKNOWN。不合main、不发布、不启v10.1.6；原dirty根/SDK/DB/备份/STOP及`%SystemDrive%/`保护。
