# EliteSync v10.1.5｜UDP观察器证据语义｜Astra独立复核

日期：2026-10-26（Asia/Singapore）

**UDP_OBSERVER_SEMANTICS_ACCEPTED_WITH_OBSERVATIONS / ACTUAL_BUILD_NOT_COMPLETED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 1. 审查范围与证据等级

Astra直接读取GitHub live main ref、候选和源码Commit元数据、完整递归Root Tree、源码相对前候选的差异、最终报告与Manifest、前版原报告/Manifest及新旧Manifest对象、四个改动脚本和脱敏测试/隔离记录。

Astra没有运行本地Python测试、没有调用真实观察器、没有运行Gradle/Wrapper/Flutter/AAR/Kotlin、没有生成或安装APK、没有操作Android设备，也没有读取本地 `C:/Users/zcxve/.codex/v1015-udp-observer-semantics-20261026/final-readback.json` 或原始LOCAL_ONLY证据。31项测试、audit hook计数、静态检查和进程/socket/DLL审计均属于Codex报告；Astra独立检查代码、测试定义和远端交付身份，不把这些结果说成Astra亲自执行。

## 2. 实时身份和原字节核验

- 本轮live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 最终普通追加候选：`7674b5e60a219cb76aba387dd2cee85cae67bd0a`，唯一Parent `018c0d95ef7cf79ee458448aa40c4bfd9af48bd4`，Root `66929e9c4af27a8249fa3c14776360e7ced9f4f6`。
- 实际源码Commit：`c1055f3cf5dcb80d0ec003de1846b940b5186aad`，唯一Parent `825344124313c4d88690983809a6fb95a05551f4`，Root `5684d0d5785fe9304379e5d2cf24b4e8992bcee3`。
- 最终候选apps Tree `df307a66c5d725aa9733de0746d58405e3702e3f`，services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。完整递归Root Tree有6621项，未截断；候选与源码Commit的apps/services子树完全一致。
- 最终报告Blob `978176687efa914767115c5014939c11a489a8ea`；Manifest Blob `7ab43f3cd6df3e05ba1fa6c92e92fb46bc5442f7`；冻结计划Blob仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 从源码Commit到最终候选累计只改 `IMPLEMENTATION_REPORT.md` 和 `artifact_manifest.json`；四个脚本的源码变更来自 `c1055f3c`。APP Dart、LiveKit vendor、后端、token/consent、WebSocket Upgrade均未改。
- 最终Manifest嵌入的 `previousDelivery` 与前候选 `82534412` 的原Manifest对象逐字段深比较一致。当前报告以前版报告正文为精确字符串前缀；前版原Blob和字节身份保留。首次交付 `018c0d95...` 的历史Manifest嵌入偏差及失败记录保留，最终修正是普通追加提交，不amend/force/reset。
- 已接受产品仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本轮没有产品main集成。

## 3. 观察器分类逻辑

### 3.1 UDP endpoint

Windows `GetExtendedUdpTable` 的owner-PID记录提供本地地址/端口和PID，没有远端目的地，也不证明采样时发送过数据报。新分类 `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE` 准确表达了观测边界。

重要的是，这只是证据标签修正，**没有放宽停止行为**：任意由任务PID拥有的UDP endpoint仍触发保守停止，不允许继续或自动重试。

### 3.2 TCP endpoint

`NON_LOOPBACK_TCP_ENDPOINT_OBSERVED` 表示采样到非loopback远端TCP endpoint/state，不宣称payload已传输。loopback地址继续遵循既有允许策略。该分类与实际出站数据量/请求成功明确区分。

### 3.3 下载日志和观察器故障

- 明确匹配的下载日志分类为 `DOWNLOAD_ATTEMPT_OBSERVED`，包括退出后的最终日志扫描。
- 观察器读取失败、malformed socket、根PID不可观察或能力预检失败采用 `OBSERVER_FAILED` 并fail-closed。
- `None` 只表示当前样本没有分类到信号，不等于证明绝对无网络。
- 优先级及UDP/TCP停止策略仍保守；最终日志下载标志单独记录，不将先前停止原因改写成更强的事实。

静态源码与测试定义支持上述分类与停止语义一致，未发现新的阻断问题。

## 4. 隔离测试和静态检查

Manifest记录最终 `python -B apps/android/scripts/test_offline_debug.py` **31项通过，exit 0**；静态编译检查与 `git diff --check` 均exit 0。原始RED运行exit1、GREEN运行及最终运行的stdout/stderr Hash均保留；最终stdout SHA256 `069dcc56ced8c4863327cca60204d2a361e7f2e1c91af7b9b2edcf2d6082aeb0`，stderr SHA256 `9115881c08e325df27ae213618862afb6c33dcb5cfc316a88f6ae5498029a9e7`。

测试结构包括纯分类函数测试、临时字节/ZIP预检夹具和完全mock的execute生命周期。测试进程内的audit hook拒绝真实Popen、os.system/exec/spawn/startfile、socket.*与ctypes.dlopen；最终记录真实进程/socket/native-DLL审计事件0。Mock PID、命令字符串及buildProcessesStarted值均是夹具数据，不是实际构建证据。

31项覆盖UDP remote不可见、非loopback TCP不同state、IPv4/IPv6 loopback、下载日志、无信号、观察器失败、malformed endpoint、endpoint与loopback并存、endpoint触发后只停止一次、无重试、根进程不可观察、启动前能力失败、退出后下载日志，以及缺缓存/错误Manifest的预检拒绝。

本轮没有真实构建、Gradle/Wrapper、Flutter/AAR/Kotlin、APK生成/安装、设备动作或真实socket/观察器调用。GitHub读写和远端回读属于单独授权的治理网络活动，不应混同为本地测试网络事件。

## 5. 前次真实构建失败仍有效

前一候选唯一真实debug构建因观察到任务PID拥有UDP endpoint而停止：外层exit90、Gradle子进程exit1、57次采样、无重试、无新APK、未到达嵌套AAR，Kotlin DSL编译仍未证明。

前次日志Hash和7,941,328字节Gradle下载partial及其SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4` 保留。此次修正证明“分类标签不再声称已证实发包”，不证明当时没有实际网络访问，也不证明当前构建能够成功。

因此本任务不授权、也没有执行真实构建重跑；构建状态必须保持 `ACTUAL_BUILD_NOT_COMPLETED`。

## 6. 保护与其他门禁

Manifest记录26688份具名保护文件、5个历史根及524个受保护旧refs无漂移。该范围是具名对象核验，不是整盘字节审计。原始partial、APK、SQL、设备日志和LOCAL_ONLY证据没有因本任务被清理。

Gate 2新启动、Writer、Serializer调用均为0；两次历史启动预算仍已消费。37案例suite、条件Sandbox SDK、Producer、`libs.jar`和30项`Configuration.resolve`继续`NOT_RUN`。AEC、最后可闻波形、实际15/30天与物理30天清理、真实Push、ICE诊断旗标及旧guest/HCS状态仍未闭合。

## 7. 最终裁决

**接受窄范围UDP观察器语义修正与隔离测试交付：**

`UDP_OBSERVER_SEMANTICS_ACCEPTED_WITH_OBSERVATIONS`

接受范围仅为：
- UDP/TCP/下载日志/观察器故障分类的语义修正；
- endpoint仍保守停止、无自动重试；
- 31项隔离测试及静态检查的Codex报告证据；
- 普通追加交付、历史Manifest嵌入修正与远端身份/原字节回读。

**不接受或不推断：**
- 实际Gradle/APK构建通过；
- 绝对无网络；
- UDP实际发包或未发包；
- AEC、最后可闻波形或完整native资源清理通过；
- v10.1.5整版接受。

最终项目状态继续为：

**`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED**。

本复核不创建或派发后继任务。不得自动重跑真实构建、合并产品main、启动v10.1.6、运行未授权Gate 2、接入真实Push/生产服务或清理历史证据。后续真实构建需要Owner另行明确授权。
