# EliteSync v10.1.5｜Gradle离线入口与APP RTC清理｜Astra独立复核

日期：2026-10-26（Asia/Singapore）

**FOCUSED_TASK_PARTIAL / CHANGES_REQUIRED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 1. 审查范围与证据等级

本复核直接读取GitHub live main ref、候选Commit元数据、完整候选Root Tree、源码父提交与交付提交的差异、冻结计划、当前实施报告、Manifest、七个新增/修改构建脚本/Gradle文件及脱敏审阅材料。

Astra未在本轮执行本地Python测试、未运行Gradle、未安装或操作Android设备，也未读取本地 `C:/Users/zcxve/.codex/v1015-build-app-cleanup-focused-20261026/final-readback.json` 或原始LOCAL_ONLY日志。15项测试、UDP采样、手机RTP/UI挂断和进程关闭均为Codex报告；Astra直接核验其公开代码和脱敏摘要，不将其写成Astra亲自运行。

## 2. 实时身份

- 本轮live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`。
- 候选：`825344124313c4d88690983809a6fb95a05551f4`，唯一Parent `02fac2b20da52e56b373f6ae8ae2da838fd51901`，Root `a13bb45df8d01dffacfce6395b5ae34ef68fafb5`。
- 源码Commit：`02fac2b20da52e56b373f6ae8ae2da838fd51901`，唯一Parent `d45cd08f939f6dfc6b4efe2420f4a117efc99e68`，Root `2b975e3b90d6844d51500726ebee1516cefaf5b2`。
- 源码apps Tree：`81a86b9dc9c2fc68edecb60a742b911539c68f3c`；services Tree：`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 实施报告Blob：`1639609a27cd25ee6a2a02d510110660023b287a`；Manifest Blob：`c0a7338316c4f4210579881249fe2bd7545fcc2f`；冻结计划仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 完整候选Root Tree递归读取661?项并未截断；GitHub tree API返回完整计数为6621，apps/services子树与Manifest源码身份一致。源码差异仅为7个构建入口/观察/测试/说明文件，及 `apps/android/app/build.gradle.kts`；APP Dart、LiveKit vendor和后端没有改动。
- 候选相对源码提交只追加实施报告与Manifest。产品接受基线仍为v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；没有产品main集成。

## 3. A：Gradle离线入口——代码与守卫有界接受，实际构建未通过

### 3.1 有依据的部分

直接源码显示，`offline_debug.py`不调用Gradle Wrapper，而是执行经预检的本地Gradle 8.14；校验调用方提供的Manifest SHA、7类root scope、清单文件Hash、构建定义Hash、指定Gradle版本receipt及固定Gradle bin Hash。缺少清单声明文件、错误Manifest Hash的两个CLI负例报告exit 2，且 `buildProcessesStarted=0`。15项最终单元检查报告exit 0。入口在观测器不可用或检测到触发条件时尝试停止自己拥有的构建进程树，不自动重试。

项目build.gradle.kts增加R1普通离线构建的本地Gradle路径与版本/部分运行时Hash检查；嵌套Flutter AAR调用也直接使用本地Gradle路径，并传入offline及禁用工具链自动下载的参数。项目init脚本尝试移除私有AAR发布的Javadoc classifier以避免Dokka外链解析路径。上述源码/单测和文档本身具备合理的fail-closed设计方向。

### 3.2 阻断：唯一真实构建没有完成

Manifest明确记录：
- 实际构建入口exit 90，停止原因为 `NETWORK_ATTEMPT_OBSERVED`；
- Gradle子进程exit 1；
- 57次采样后停止；
- 没有重试；
- 新APK未生成、未安装；
- 嵌套AAR阶段未到达；
- Kotlin DSL实际编译尚未证明；
- Wrapper trap未触发，但由于未到达嵌套阶段，不能据此宣称整条构建链通过。

因此，15项测试通过只能证明脚本守卫的部分单元行为；不能代替普通debug APK实际构建通过。任务A当前为 `INCOMPLETE_ACTUAL_DEBUG_BUILD_STOPPED_NO_RETRY`。

### 3.3 需要修正的证据语义：UDP endpoint不等于已观测到UDP网络尝试

`windows_build_observer.py`使用Windows `GetExtendedUdpTable` 的 owner-PID表。当前代码为UDP行只读取本地地址、本地端口和PID；结构中没有远端地址或目标端口。随后 `offline_debug.py`将**任意被采样到的任务UDP endpoint**直接分类为 `NETWORK_ATTEMPT_OBSERVED`并停止构建。

这是一条保守停止策略，但现有观测只证明该任务进程持有一个UDP endpoint；它没有证明实际发送了UDP数据报，也无法从该表识别目的地址。故当前 `UNKNOWN_DESTINATION` / `NETWORK_ATTEMPT_OBSERVED` 是超出底层证据能力的标签。不能据此断言发生了外联，也不能反过来宣称没有网络访问。

建议的修正方向是保留fail-closed安全边界，同时将观测状态准确区分为：
- `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`（只观测到endpoint，未证明发包）；
- `OUTBOUND_NETWORK_ATTEMPT_OBSERVED`（需要具有实际出站目的/流量证据的观测器支持）；
- `OBSERVER_FAILURE`（无法读取或关联进程/网络状态）。

在没有可靠流量证据前，不得将未知UDP endpoint当作已证实外联；但也不得因分类修正而自动继续/重试本次构建。当前任务已执行过一次真实构建，且原任务明确要求触发保护后不重试。任何下一次真实构建都必须等待Owner明确授权，不能由Astra或Codex自行重跑。

本轮观察器每100ms采样一次，代码与README也承认可能漏掉采样间短暂事件。因此它不能证明绝对无网络。UDP目的不可见是当前停止原因的关键证据缺口；同时也没有到达嵌套AAR阶段，故内层Gradle调用、Kotlin DSL编译、Javadoc classifier处理及完整APK生成仍未验证。

## 4. B：APP侧RTC清理——有界调查接受，根因仍未完全闭合

### 4.1 有依据的部分

本轮源码差异确认没有修改APP Dart、LiveKit vendor、后端或token/consent/Upgrade逻辑。Codex报告在原R1 APK（SHA256 `30ca72ab1e53c55ff324ee2763d84ceab7867a7c54617e5b76bcbaa83c966a12`）上完成新call，同一PID的四方向RTP计数增长、视频decode 70→148，随后真实APP UI挂断；renderer cancel、disconnect、dispose、leave及指定native停止事件均有新事件记录。该次call没有改变R1源码，也未产生新APK。

报告记录挂断后camera raw code4/code5共7条W日志、trackDispose-null共5条D日志。它没有将不同call或不同APK的旧日志拼成新结果，也保留原始证据和边界。基于本轮源码和脱敏证据，没有足够依据证明一个新的APP-owned重复关闭缺陷；不修改APP代码是合理的有界选择。

### 4.2 未闭合的根因

- `trackDispose-null`的一个可能解释是现有Track.stop/LocalTrack.stop路径对同一media track执行幂等二次停止；但报告明确承认，这不是对每一条null日志的排他归因。
- camera code4/5的设备日志级别与所参考的Android源码日志级别不一致，且没有设备固件字节匹配或数字常量映射；不能把code4/5直接映射为某个Android CameraDevice/Service状态。
- 因此，不能认定这些警告是APP缺陷，也不能认定它们已证明是无害的正常平台关闭。当前应保留为 `SDK_FRAMEWORK_CLOSE_WINDOW_UNRESOLVED` / 观察项。

我接受“在当前证据下不做无依据APP修复”的判断及这次新call的有界诊断结果；但不接受“清理警告根因已完全归因”或“RTC清理全通过”的表述。AEC、最后可闻波形和完整native handle census仍未证明。

## 5. 保护、资源与其他门禁

Codex报告的具名保护文件、五个历史根、受保护refs、资源关闭和工作树干净状态已作为远端脱敏摘要读取；这不是Astra亲自检查本地磁盘或所有进程，也不是整盘字节审计。真实构建停止后未重试，未生成新APK。R1原有APK/partial和LOCAL_ONLY原证必须继续保留。

Gate 2新启动、Writer和Serializer调用保持0；两次历史启动预算仍已消费。37案例suite、条件Sandbox SDK、Producer、`libs.jar`及30项`Configuration.resolve`继续`NOT_RUN`。实际15/30天、物理30天清理、AEC/最后可闻波形和真实Push仍开放。不得合并产品main或启动v10.1.6。

## 6. AC与本聚焦任务裁决

| 范围 | Astra裁决 | 依据/限制 |
|---|---|---|
| 构建入口的15项guard测试 | `SUPPORTED_BOUNDED` | 代码和Manifest记录通过；Astra未运行测试 |
| 缺缓存/错误Manifest拒绝 | `SUPPORTED_BOUNDED` | 记录为exit2且构建子进程数0 |
| 普通debug实际构建 | `NOT_ACCEPTED / INCOMPLETE` | UDP endpoint触发停止，exit90/child1，无APK，嵌套AAR未到达 |
| 网络观察器结论 | `CHANGES_REQUIRED` | UDP owner-PID表没有远端字段；endpoint不能证明发包，停止标签过强 |
| RTC同call媒体与UI挂断 | `SUPPORTED_BOUNDED_CODEX_REPORTED` | 有新call/同PID证据，但非Astra亲自运行 |
| camera code4/5与trackDispose-null归因 | `PARTIAL / UNRESOLVED` | 有限日志与静态路径提供可能解释，不足以排他归因 |
| APP源码修复 | `NO_CHANGE_JUSTIFIED_WITH_LIMITS` | 未发现足以支持最小APP修复的证据；不能等同根因已解决 |
| 整体聚焦任务 | `CHANGES_REQUIRED / PARTIAL` | A的真实构建验收未完成，观察器错误分类需修正；B为有界调查 |

## 7. 最终状态与下一步边界

本候选不获整个聚焦任务的完成接受，裁决为：

**`FOCUSED_TASK_PARTIAL / CHANGES_REQUIRED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`**

建议下一步仅针对观察器证据语义与真实构建授权设计一个窄范围后续动作：修正UDP endpoint与实际出站流量的分类，添加明确回归测试和可审计观测；在获得Owner明确授权前不重跑真实构建。RTC侧继续保留警告与不确定性，除非有新证据证明APP自身缺陷，否则不改APP或vendor。

本记录仅是Astra独立审查文档，不自动创建或派发下一任务。禁止合并产品main、启动v10.1.6、启动未授权Gate 2、接入真实Push/生产服务或清理历史证据。
