# v10.1.5 新授权候选停止，默认插件门户遗漏已静态修正｜2026-11-07

**OWNER_NEW_ONE_ATTEMPT_CONSUMED / CASE02_STOP / DEFAULT_PLUGIN_PORTAL_FIXTURE_RED_GREEN / NO_NEW_APK / G2_FALSE**

Owner在依赖补齐和候选保存后明确答复“批准新输入候选再运行一次”。新范围`v1015-source-debug-host-20261107-case02`独立记录授权、合同、nonce和claim；旧case01的STOP及1/0保持，未退款、恢复或挪用旧额度。代码身份`f457877cf8eba44ec4b6e279838048581c8edad1`，apps树与源码接线提交`f4803c4a`一致，仍为`628795cf5fca95b4fb602695a295c0e987839eb4`。

## 本次实际结果

复用稳定目录，SDK复制0次；新构建前完整工作清单67406文件/7028833366字节，外部输入49707项，包含新增Kotlin补充仓库54文件。准备525.890秒。只调用既有launch一次fresh核验，没有提前重复preflight或内存查询。

| 项目 | 实际结果 |
|---|---|
| fresh可用内存 | 8575MiB，超过5120MiB门 |
| 启动时工作卷空闲 | 330762989568字节 |
| 完整launch调用 | 525.302秒，含输入/资源核验和收尾 |
| SDK / Gradle | 4.756秒 / 4秒 |
| Job记账峰值 | 751284224字节，约0.700GiB |
| 退出 | Java root1、controller32，STOP已写 |
| APK及运行 | 没有新APK；Dart/APP编译未进入；安装/运行/attach/热重载NOT_RUN |

**case02已耗1、余0；不重跑。case01也保持1/0。** 原4GiB AAR和Release-AAR Debug host各自1/0不改。内存未成为本次失败原因；失败阶段的峰值不能证明完整源码构建的峰值。

## 原因、修正与验证边界

本次失败是Codex候选配置的遗漏：在`beforeSettings`加入只允许Kotlin1.8.0的补充插件仓库，覆盖了Flutter included build原本隐式使用的Gradle Plugin Portal。该build的settings只声明依赖仓库，没有显式pluginManagement仓库，因此`kotlin-dsl5.2.0`只在过滤的补充仓库中查找并失败。case01曾在同一工具链离线完成Flutter Gradle插件的4项任务；本次不是新的工具版本下载需求。

修正仅形成未应用的下一输入文件，没有回写case02合同或已消费init：在settings求值完成后，若插件仓库为空，先恢复原默认Portal，再加入补充仓库；显式仓库存在时保持其顺序和身份。保留settings依赖仓库和buildscript classpath入口、25个固定1.8.0组件过滤，不注入project.repositories，Flutter included build的FAIL_ON_PROJECT_REPOS保持。

新增纯Groovy仓库策略fixture实际执行：原已消费配置RED，准确报“Implicit plugin portal was suppressed”；修正候选GREEN，覆盖默认Portal恢复、显式仓库保留、不重复Portal、25项固定版本过滤，以及buildscript隔离/禁止项目仓库注入。另有ELF比较器内存突变检查确认能检测可加载代码字节变化；未修改二进制。两者都不是Gradle/Flutter SDK构建或APK验收。

非作者Codex确认本次根因及修正候选未见新的可行动P1/P2；**修正后的真实离线解析和产包NOT_RETESTED**。当前没有新的SDK范围、grant或claim；若继续实际验证，需Owner另行明确一次额度，不因候选修正或保存记录自动续额。

## 保留状态

两个官方Flutter Debug组件与Kotlin25固定组件/54文件补充已完成，工具链和许可证状态未变。此轮没有继续下载、SDK重试、设备安装、后端/DB、VM、云、媒体或真实Push运行。稳定目录与所有失败/缓存原件保留；原dirty根、SDK、DB、STOP及`%SystemDrive%/`保护。

LOCAL_ONLY新原证根名`v1015-source-debug-runtime-20261107-approved-kotlin-candidate`保存授权、准备/启动输出、原错误、RED/GREEN fixture、未应用修正及最终Git回执。原case02控制目录保留冻结输入，修正候选独立存放；二进制、许可、私有原证不上GitHub。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**；不是整版接受、外部独立验收、main集成或发布，不启v10.1.6。旧VM teardown UNKNOWN，原已验证APK不变。
