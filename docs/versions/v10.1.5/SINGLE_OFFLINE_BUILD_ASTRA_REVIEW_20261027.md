# EliteSync v10.1.5｜单次离线 Debug 构建｜Astra 独立复核

日期：2026-10-27（Asia/Singapore）

**AUTHORIZED_SINGLE_ATTEMPT_COMPLIANT_WITH_OBSERVATIONS / ACTUAL_BUILD_NOT_COMPLETED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 1. 范围与证据类别

本复核直接读取GitHub live main、候选和源码Commit元数据、完整递归候选Root Tree、源码与交付Commit差异、冻结计划、单次构建任务单、实施报告、Manifest、入口和测试源码，以及前次UDP观察器交付的报告/Manifest。

Astra没有在本轮执行本地Python测试、没有启动Gradle/Wrapper、没有构建或安装APK、没有操作设备，也没有读取LOCAL_ONLY的 `final-readback.json`、原始进程/socket日志或工具缓存。43项隔离测试、审计事件数、真实构建/进程终态、保护文件与refs核验属于Codex报告；Astra独立核验远端源码、测试定义、报告/Manifest与Git身份，不把这些说成Astra亲自运行。

## 2. 实时身份和原字节

- live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 最终普通候选：`cfddecc944a043b1d85361a954a692be0dd4ce23`，唯一Parent `12d4e284feea609935eab12c973f5fd2efbc2992`，Root `a0bdf4a3cec27a21293abad9a35f11981b0d5c48`。
- 本轮源码Commit：`12d4e284feea609935eab12c973f5fd2efbc2992`，唯一Parent `7674b5e60a219cb76aba387dd2cee85cae67bd0a`，Root `1fbd4a7a2de6dc56b42b0e3a51f7d74f712d7250`。
- 候选Root Tree递归读取6621项，未截断；apps Tree `cea01309fa9da5f99ccc9829654c6ec279c8c343`，services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 源码Commit到候选只新增/追加 `docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md` 和 `artifact_manifest.json`；产品源码变更为3个构建脚本/说明文件：`offline_debug.py`、`test_offline_debug.py`、`README.md`。观察器实现文件未改；APP Dart、LiveKit vendor、后端、token/consent、WebSocket Upgrade均未改。
- 实施报告Blob：`71e039051ba0c6205f496444bc466d71f11a6fff`；Manifest Blob：`d91a50d3653ef6304b4f45e53ddb4a242dbce284`；冻结计划Blob仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- Manifest嵌入的前次交付 `previousDelivery` 与前候选 `7674b5e6` 的原Manifest JSON逐字段深比较一致；当前报告以前次报告正文精确前缀开头。前次报告/Manifest原Blob和字节身份继续保留。
- 已接受产品仍是v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。live main未改变，没有产品main集成。

## 3. 单次授权与隔离测试

### 3.1 预算约束

本次任务确有Owner明确授权的一次真实普通Debug构建。代码将UDP endpoint单独观察设为本次授权模式下不停止，但仍保留分类和计数；下载日志、非loopback TCP、观察器故障/无效结构、工具/缓存/Manifest/定义Hash不匹配仍强制停止。

入口检查本次任务Blob `6c09cca14b120cb0eb39cc2909e84a7203d252ed`、`maxStarts=1`、隔离测试和静态检查exit0，并在真实Gradle启动前以独占创建方式保留单次claim。重复claim、退回默认模式、已有APK、模拟Popen失败后再次调用均有测试覆盖。源码注释正确承认这是本地防重放/预算保护，不是Owner身份认证机制。

### 3.2 测试

Manifest记录：
- 最终隔离测试43项，exit 0，无skip；
- 之前的RED exit 1、修正后GREEN和最终运行均保留stdout/stderr Hash；
- Python静态编译检查及 `git diff --check` 均exit 0；
- 真实进程/socket/native-DLL审计事件报告为0；
- 43项测试内Observer、Popen、run/wait/poll及网络/本地DLL交互均mock；没有真实Gradle/Wrapper、Flutter/AAR/Kotlin、APK、设备或观察器运行。

Astra核对了测试定义，包括UDP仅观察策略、UDP不能掩盖TCP/下载信号、观察器故障fail-closed、预检失败不启动子进程、单次claim不可重复及模拟spawn失败保留claim。以上执行结果属于Codex报告，不是Astra亲自运行。

## 4. 唯一真实构建的结果

预检通过后唯一真实构建确实启动一次。记录如下：

| 项目 | 结果 |
|---|---|
| 入口启动次数 | 1 |
| 单次预算 | 1/1已耗尽，剩余0 |
| Gradle | 本地8.14，直接调用，无Wrapper fallback |
| 运行时间 | 92.375秒 |
| 采样数 | 734 |
| UDP endpoint | 682个样本、4478条endpoint行观察；不是数据报数或发包数 |
| 最终强停止 | `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED` |
| 外层入口退出码 | 90 |
| Gradle子进程退出码 | 1 |
| 下载日志匹配 | false（仅说明未匹配规则，不证明绝对无下载） |
| 新APK/安装 | 未生成、未安装 |

最后一个强停止样本中，任务java.exe拥有非loopback IPv4 TCP endpoint，state 5。按照任务单约定，非loopback TCP endpoint仍是强停止条件；因此入口停止任务拥有的进程树，没有重试。真实日志到达Kotlin DSL及嵌套AAR相关阶段，但嵌套Gradle的独立进程身份未被充分单独记录，不能据此宣称完整构建通过。

endpoint/state行不证明payload已传输，不证明发生下载，也不识别具体远端服务。原始远端地址和进程/socket日志保持LOCAL_ONLY。采样观察也不能证明绝对无网络。

Gradle stdout SHA256：`0fbc2c233ab87dd83f152c23e23f7ed58ddf59ee79481a3f2f7822d47fe346d5`；stderr SHA256：`6d3b8ee7dc564a062738d52cd5a473391565b56f664e9528daa54201b0fff5aa`；观察记录SHA256：`19222dde39878d8a8f755db0f7d22b6903bb671d74c7b9d2e7e7dae6d5d5f0cd`。入口和Gradle子进程的退出码/日志通道分别保留。

## 5. 资源、保护与禁止项

Codex报告称停止后15个具名任务/构建进程均不存在；27084项声明为不可变的SDK/JDK/Gradle、缓存模块和Flutter/Dart运行输入无漂移，1046项tracked apps源码无漂移；任务端口没有listener。26784份具名保护文件、5个历史根及524个受保护旧refs保持一致。该范围是具名对象与指定输入的核验，不是整盘字节审计。

没有新APK、安装、设备、RTC、后端、数据库或认证会话操作；因此不宣称完成新设备Hash回读或本轮DB快照。原7,941,328字节Gradle下载partial及Hash、前次UDP停止原证、旧APK、SQL、历史refs和LOCAL_ONLY证据均保留。

Gate 2新启动/Writer/Serializer为0；两次历史启动预算仍已消费。37案例suite、条件Sandbox SDK、Producer、`libs.jar`和30项`Configuration.resolve`继续`NOT_RUN`。AEC、最后可闻波形、完整native资源清理、真实15/30天与物理30天清理、真实Push仍未闭合。

## 6. 最终裁决

**接受本次单次构建授权的遵循情况与失败证据交付：**

`AUTHORIZED_SINGLE_ATTEMPT_COMPLIANT_WITH_OBSERVATIONS`

依据：
- 单次预算确实只启动一次，停止后没有重试；
- UDP endpoint按未知目的地观察记录，不再误称已证实发包；
- 非loopback TCP仍按任务合同触发强停止；
- 43项隔离测试、静态检查、历史失败和保护对象核验有完整报告身份；
- 远端候选/源码身份、完整Root Tree、报告/Manifest和历史对象绑定已核验。

**不接受实际构建成功。** 当前必须继续保持：

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED`

本次授权已耗尽，不得自动创建或派发第二次真实构建任务。任何下一次真实构建都必须由Owner重新明确授权并指定新的预算。禁止合并产品main、启动v10.1.6、运行未授权Gate 2、接入真实Push/生产服务或清理历史证据。
