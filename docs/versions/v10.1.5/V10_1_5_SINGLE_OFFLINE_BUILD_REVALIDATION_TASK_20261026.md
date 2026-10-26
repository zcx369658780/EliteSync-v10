# EliteSync v10.1.5｜单次离线 Debug 构建重新验证｜授权任务单

状态：OWNER_EXPLICITLY_AUTHORIZED_ONE_REAL_BUILD_ATTEMPT / READY_FOR_MANUAL_CODEX_DISPATCH / SINGLE_ATTEMPT_ONLY / NO_GATE2_AUTHORIZATION / NO_PRODUCT_MAIN_INTEGRATION

日期：2026-10-26（Asia/Singapore）
Owner：最终产品方向与不可逆决策 authority
执行者：Codex，仅在Owner手动派发后执行
独立验收：Astra

## 0. 本次授权的确切范围

Owner在2026-10-26明确授权继续进行一次真实离线Debug构建重新验证。该授权仅覆盖：
1. 必要的只读状态恢复与本任务所需的最小观察器修正；
2. 本任务指定的静态/隔离测试；
3. 在满足本任务全部前置条件后，**最多一次**真实普通Debug构建尝试；
4. 若构建产物成功生成，核验APK Hash并在原已授权设备上进行安装回取Hash核验（不扩展设备/通话/媒体旅程）；
5. 集中更新报告与Manifest并普通发布候选，随后停止等待Astra。

该授权不等于授权重复试跑。真实构建只允许一次启动；一旦发现明确下载尝试、非loopback TCP endpoint、观察器失效、依赖/Hash漂移或其他本任务定义的停止条件，立即停止任务拥有的构建进程树，保留所有原始证据，不重试。即使Owner授权了一次尝试，也不得自动将一次失败转化成第二次尝试。

不授权系统网络/防火墙/执行策略修改、管理员权限升级、下载工具或依赖、真实Push/生产服务、Gate 2、产品main集成、v10.1.6或新增费用。

## 1. 开工前恢复实时状态

仓库：`zcx369658780/EliteSync-v10`

重新读取：
- `docs/workflow/ACTIVE_STATE.md`
- 冻结计划 `docs/versions/v10.1.5/plan.md`
- 当前 `IMPLEMENTATION_REPORT.md` 和 `artifact_manifest.json`
- `docs/versions/v10.1.5/UDP_OBSERVER_SEMANTICS_ASTRA_REVIEW_20261026.md)
- 本任务单。

实时身份参考（开工时必须重新GET验证）：
- live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`
- 最近语义修正候选：`7674b5e60a219cb76aba387dd2cee85cae67bd0a`
- 语义修正源码：`c1055f3cf5dcb80d0ec003de1846b940b5186aad`
- 该源码Parent：`825344124313c4d88690983809a6fb95a05551f4`
- 冻结计划Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`
- 已接受产品v10.1.4 apps Tree：`3468a3dd97da7accfda2539a0f8d8f68931a6110`
- 已接受产品v10.1.4 services Tree：`0cb1f9d19659291a462488b3686fd0a07a6698ac`

不得把历史SHA当作实时HEAD，不得reset、覆盖、amend或force-push。不得将候选源码Tree冒充产品main。

## 2. 真实构建前的必需修正与验收

前次真实构建因采样到由任务Java进程拥有的UDP endpoint而停止。Windows UDP owner-PID表只提供本地endpoint地址/端口与PID，不提供远端目的地，也不证明采样时发送过数据报。语义修正候选已将它准确分类为 `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`；该状态仍触发保守停止。

这导致一次重要区分：Owner现在授权的是一次真实构建尝试，但并未授权将“存在UDP endpoint”伪称为已证明的出站传输，也没有授权不受控联网。

### 2.1 最小必要实现

在保持已有本地工具、缓存清单、Gradle 8.14和依赖Hash预检的前提下，调整观察器/入口的运行策略，使：
- `DOWNLOAD_ATTEMPT_OBSERVED`：仍立即停止；
- `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED`：仍立即停止，除非有已接受且可审计的项目内部例外证据；本任务不默认新增例外；
- `OBSERVER_FAILED`：仍立即停止并fail-closed；
- 依赖/Manifest/工具/构建定义Hash不匹配、缓存不完整或参数不安全：在启动构建前失败；
- `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`：记录为“目的地不可见的UDP endpoint观察”，不声称已证明发包；在本次单次授权构建中，该状态**单独不阻断继续执行**，但必须写入私有观察记录并汇总脱敏证据。
- 没有观察到信号仍不能声称绝对无网络。

本次单次构建不调用Wrapper、不使用下载fallback，直接调用已验证的本地Gradle 8.14，使用既有Gradle user home与已核验缓存，开启Gradle offline，关闭JVM/工具链自动下载。不得更改全局网络策略或防火墙。不得引入ETW/抓包驱动/管理员级网络工具，除非已有授权环境中已安装且无需改系统配置；本任务不要求额外安装工具。

### 2.2 为什么这不是“忽略网络风险”

UDP endpoint只证明endpoint存在；本次允许在此单一不确定信号下继续，是Owner授权一次构建且前置清单/Hash已验证、Wrapper被绕过、Gradle offline和自动下载禁用的有界试验。它不证明宿主机绝对无网络，也不证明未采样到的短时UDP数据报不存在。

如果构建日志出现下载、非loopback TCP endpoint、观察器失效、任何依赖不在预先验证的缓存/库存中，或其他既有保护条件触发，必须停止并将真实构建标记失败，不重试。不能为了得到APK而关闭所有停止条件。

## 3. 执行顺序

1. Fresh读取并绑定全部状态、源码、工具、缓存和Manifest身份。
2. 对当前观察器与入口差异进行静态审查；仅允许改动 `apps/android/scripts/offline_debug.py`、`apps/android/scripts/windows_build_observer.py`、`apps/android/scripts/test_offline_debug.py` 和必要的 `README.md`。不得改 `apps/android/app/build.gradle.kts`、APP Dart、LiveKit vendor、后端、token/consent、WebSocket Upgrade或冻结计划。
3. 增加/修正纯函数及完全mock的测试，明确验证UDP endpoint单独记录但不停止，且下载日志、非loopback TCP、观察器故障、预检失败仍fail-closed。
4. 运行隔离测试与静态检查。若任一失败，先在不运行真实构建的前提下修复并重测。
5. **只有隔离测试和静态检查通过、预检完整、真实构建授权仍有效时，才允许启动唯一一次真实构建。** 不得用真实构建来调试脚本。
6. 在同一受控进程树中执行一次普通 `:app:assembleDebug`。不启动ICE诊断、retention probe、RTC通话或其他设备旅程。
7. 若构建exit0且APK存在，记录APK字节数/SHA256；按原授权设备范围进行一次安装回取Hash核验，不做其他UI或媒体测试。若构建失败/停止，保留失败并结束。
8. 结束后核验任务拥有的构建进程已退出、令牌/会话没有新增、任务端口/ADB reverse恢复开工状态。不要停止Owner的全局Docker/ADB或其他非任务资源。
9. 集中更新报告与Manifest，普通non-force发布一个候选并完成远端身份/原字节回读，然后停止等待Astra。

## 4. 必须新增的测试

至少覆盖：
1. UDP endpoint remote=None -> `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`；本次授权模式下仅此信号不会触发停止，但会留存观察记录。
2. 非loopback TCP endpoint -> 保持立即停止，无重试。
3. loopback TCP -> 遵循原策略，不误报为外部TCP。
4. 明确下载日志 -> 立即停止。
5. 观察器异常、根进程不可观察或socket结构无效 -> fail-closed。
6. 缺缓存、Hash不匹配、Manifest错误、工具版本不符 -> 任何Gradle子进程启动前失败。
7. 同时存在UDP endpoint与下载日志/非loopback TCP时，强停止信号优先，不能因UDP弱化而放行。
8. 运行时触发强停止条件后只停止一次，不自动重试。
9. mock测试进程内真实Popen/socket/native-DLL审计事件为0；所有真实构建协作者均被mock。
10. 构建授权只消耗一次；测试失败时不能启动真实构建。

## 5. 构建结果判定

只有同时满足以下条件，才能报告“本次实际普通Debug构建通过”：
- 唯一一次真实构建启动；
- Gradle 8.14身份与依赖缓存预检通过；
- 直接调用本地Gradle，未调用Wrapper bootstrap；
- Gradle进程exit0，日志没有下载尝试；
- `:app:assembleDebug`真实执行完成并生成APK；
- APK Hash可读回；如执行安装，安装后APK Hash与构建产物一致；
- 所有保护停止事件、日志与进程终态均被记录。

若实际构建未成功，必须标记 `ACTUAL_BUILD_NOT_COMPLETED`，不生成伪成功结果，不重试。

即使实际构建通过，也只接受该构建产物，不等于v10.1.5整版接受、不关闭AC05、不证明AEC/最后可闻波形、真实15/30天、物理30天清理或真实Push。

## 6. 证据与资产保护

- 绝不删除或覆盖前次构建失败、57次采样、UDP endpoint停止记录、stdout/stderr Hash、7,941,328字节partial及SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`。
- 原始进程/socket日志、设备原证、SQL、APK及其他敏感材料继续LOCAL_ONLY；只发布最小脱敏摘要和Hash。
- 不清理历史备份、旧refs、旧候选、旧APK、SQL或LOCAL_ONLY证据。
- 不改变系统防火墙、代理、执行策略、全局环境变量、共享Gradle/Java/Flutter安装、管理员策略或Docker/ADB全局状态。
- 不接入真实Push、生产服务或真实用户，不新增费用。
- Gate 2新启动、Writer、Serializer调用必须为0；不使用Bypass。
- 任务结束后检查本任务拥有的进程、测试服务、端口与设备会话，并保留全部失败记录。

## 7. 集中交付

集中更新同一份 `IMPLEMENTATION_REPORT.md` 与一个 `artifact_manifest.json`，保留历史内容原字节/前缀，不覆盖旧失败章节。交付绑定：
- 实时main/Root；
- 本任务源码Commit/Parent/Root；
- 候选Commit/Parent/Root；
- apps/services Tree；
- 报告与Manifest Blob/原字节；
- 每个改动文件的Git Blob与SHA256；
- 隔离测试命令/退出码/stdout/stderr Hash；
- 唯一真实构建命令、启动次数、Gradle版本、缓存清单Hash、日志Hash、观察信号、停止/退出结果；
- APK Hash与安装回取Hash（仅当真实生成/安装）；
- 任务进程/端口/ADB reverse终态；
- 保护文件、历史根与refs只读核验范围；
- 明确证据类别：Codex报告、真实本地运行、远端源码/文档回读、LOCAL_ONLY原证；
- 非作者复核的真实范围；不得声称审阅者执行了构建或设备操作。

最终状态继续为 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。如实际构建通过，更新 `ACTUAL_BUILD_COMPLETED_WITH_HASH`；若失败，更新 `ACTUAL_BUILD_NOT_COMPLETED`。无论结果如何，候选交付后停止等待Astra集中独立验收。

## 8. 明确禁止

- 不得第二次启动真实构建；本任务真实构建启动预算为1。
- 不得在真实构建失败后自动重试或通过重启/换入口绕过失败。
- 不得调用Gradle Wrapper或下载工具/依赖。
- 不得使用Gate 2、Bypass、Writer或Serializer。
- 不得合并产品main、启动v10.1.6、接入真实Push/生产服务、产生未经授权费用或清理历史证据。

## 9. 派发方式

本任务单已记录Owner对一次真实构建重新验证的明确授权，但文档创建不等于Codex已开始执行。Owner手动将本任务单交给Codex后，Codex按上述顺序执行；真实构建最多一次。完成集中候选交付后停止，等待Astra验收。
