# EliteSync v10.1.5｜fd0da9cc G/A受控验证交付｜Astra独立验收

日期：2026-10-27（Asia/Singapore）  
审阅者：Astra（独立Product Advisor / Reviewer）  
**裁决：`FD0DA9CC_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`；仅接受诚实、来源可追溯的有界失败交付和停止门禁，不接受真实G发布图、AAR/POM运行、APP APK、v10.1.5整版。**

继续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / A_NOT_RUN / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

## 1. 直接独立核验的GitHub对象

- 本次先完整读取独立交接分支 `handoff/v1015-20261027` 的 `SESSION_HANDOFF_20261027_V1015_G_BLOCKED_FD0DA9CC.md`（Blob `079f4c22a3d2080af676cd630b445d6a627e877d`）和 `ACTIVE_STATE.md`（Blob `dba1b6c2cd3b85887cbcd296fb9f65b3869a1b5f`）；交接分支HEAD `b945d2f6c4f9490a0295a2a81d14cadffb2fdfeb`。此交接独立分支不是产品main。
- Fresh GitHub main HEAD `4df2e7f0f36cc7b80258faa73e80dad682cff6c5`、Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；已接受v10.1.4完整apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。不把旧main ACTIVE_STATE（2026-10-25时点）视为最新交接状态。
- Fresh候选分支 `codex/v10.1.5-controlled-aar-pom-verification-20261027` HEAD为 `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`；直接读取Git commit对象得到唯一Parent `da5ce628a499c97e916e780e2cf795353745c147`、Root `b1f6fd9de8083f017e342fe82149874a66ff815a`。
- 直接获取Root递归Tree：`6633`条、`truncated=false`。apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab`，其递归`1525`条（1053 blob/472 tree）；services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，递归`792`条（715 blob/77 tree），均未截断。方案一Parent两产品Tree逐SHA一致。
- GitHub compare `da5ce628...fd0da9cc`：ahead=1/behind=0，唯一变更为两份新增脱敏文档；未发现本候选变更产品源码或main。正式报告Blob `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80`，索引Blob `38b20500d0e42218976a9f675607b7a5b259a7b1`，直接取回全文/各索引分段。
- Owner正式任务Blob `129efb748bb5a22921e756f2f829a627ceae6880` 已读全文；前置Astra方案一复核Blob `1a39ba1ab5df7c69a0f6143b4734ba56b31cf134` 已读全文。后者仅接受源码级有界Javadoc修正。

## 2. 库存及37+44+17的证据等级

- 新库存 `100453`项、SHA256 `2fa1227a56a90a2225f35ff61306a327e23fde1a0cb5a4c3c961c48f5b4ff9fd`、各根计数 `314+52551+6270+14931+492+22178+3717`，合计一致。六项REQUIRED_PROJECT_INPUTS、272 package引用、74插件引用、15 Android生产源码映射及单独的新快照、先行审计均由Codex报告。公开索引的`inventoryClosure.status=VERIFIED`是**Codex结果**，Astra并未从LOCAL_ONLY读取并重哈希100453文件，故只能写 `CODEX_REPORTED_BOUNDED_INVENTORY_CLOSURE`，不能写 `ASTRA_DIRECT_LOCAL_INVENTORY_VERIFIED` 或绝对闭合所有动态依赖。
- 直接解析候选索引JSON：85条具名本地证据，85个标签互异、SHA256字段格式有效、字节数非负；分类43 `LOCAL_ONLY_RAW`、31 `CODEX_REPORTED_LOCAL_EXECUTION`、11 `DIRECT_GITHUB_READBACK`。索引的Hash并不等于本次已获取对应原始本地文件。
- 方案一37项与原入口44项源码定义可在GitHub直接阅读：主要为Python Hash/字节、静态提取与完全mock的观察器/Popen测试。Codex报告本轮两组exit0；Astra并未执行。
- 新runner 17项、执行器 `ce765a33fbae04fa0febee69ce8005dbbaec65d7a47d33f430d5c795e8861985` 和隔离审计0事件由Codex报告；runner和LOCAL_ONLY测试完整原件不在公开两份文档中，不能宣称Astra实际阅读17项测试源码或执行。它们不验证真实Gradle settings/plugin-loader上下文、真实进程路径可读性、任务图或Javadoc/Dokka运行。

## 3. G预算、失败原因及A阻断

- 正式任务授权独立的G最多一次 `assembleAarRelease --dry-run`；A最多一次实际内层AAR，但**必须先有完整G通过**。旧外层APK预算1/1消耗完毕，完全不能复活。本轮索引/报告一致记载：G在Popen前claimed=1，PopenCreated=true，remaining=0；实际直接Gradle8.14与`--offline`、两条`-I`、ordinary R1参数、显式`-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`及`--dry-run`。
- Codex报告G实际4.829秒/36个有效运行观察样本，入口exit90，监测stopReason `OBSERVER_OR_LAUNCH_FAILURE:OSError:PROCESS_INSTANCE_PATH_UNREADABLE`；此时Gradle配置输出另显示在Flutter plugin-loader的settings.gradle第22行遇到 `OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required` 和 `BUILD FAILED in 4s`。不得将BUILD FAILED当作未被强停止时的全部自然退出证据。
- 直接复核项目自有init源码Blob `7654d90a8b2cc3fd31fafcb18fe589624486a3a2`：脚本开头确实通过 `gradle.startParameter.projectProperties['elitesyncOwnedAarInit']` 严格等值守卫，失败即抛出同文案异常；受控源码仍只移除flavor/no-flavor两处Javadoc请求并保留sources。直接读取Kotlin `app/build.gradle.kts` Blob `92a2147843756f3ff2c9217250e04cdb2856b9cd`，其ordinary R1传参表达式存在。**能证明代码检查条件与报告错误对应，不能证明scope为何未到达该Gradle/settings/plugin-loader上下文**。复合构建/初始化语境下属性传播是有界假设，不是已证明单一根因。
- `PROCESS_INSTANCE_PATH_UNREADABLE`是一项独立观察器强停止理由。原始异常前没有完整落盘的失败实例，不能用前一采样断言已退出/PID复用、实例身份或真实网络发包。按任务必须fail-closed。仅36个有效样本及历史UDP/TCP派生记录不证明绝对离线或没有短时事件。
- G `selectedTasks=[]`、必要publication coverage全部false，**`GRAPH_NOT_PROVEN`、`DOKKA_TASK_SELECTED=NOT_PROVEN`**，绝不解释成“未选择Dokka”。A的claimed=0，remaining=1，gateOpen=false，`A=NOT_RUN`，没有新AAR/POM/metadata/Flutter artifact，也没有APP APK。
- 以上本地启动次数、Job活跃进程归零、没有重试和保护资产状态属`CODEX_REPORTED_LOCAL_EXECUTION`；GitHub两文档没有让Astra直接读取Popen、Job、stdout/stderr和全套原始进程日志。因此只能说在已审范围**未发现未授权重试/构建/安全放宽的交付证据**，不能作全本地进程历史的绝对阴性证明。

## 4. 历史原证与安全边界

Codex报告核对26784份具名历史保护文件、五个历史根、近期108份LOCAL_ONLY证据及开工525个refs首尾一致。此前524与本轮525来源不同，不能按数量直接宣布历史漂移。原7,941,328字节Gradle partial SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧单次预算claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8` 仍报告不变。所有原始LOCAL_ONLY/SQL/APK/socket/PID/路径/凭据不因验收而上传公开GitHub或被删除。

不授权重新运行G、不以A绕开G、不重置旧/新预算、不改变observer的nonloopback TCP与异常强停止、不修改网络/防火墙/代理/PowerShell策略/共享SDK、不跑Gate2、Writer、Serializer或设备/RTC、不新建后续开发任务、不合并main、不启动v10.1.6。

## 5. 裁决与Owner的最小后续选择

**`FD0DA9CC_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`**：接受本候选两份纯文档的完整性、失败如实披露和A门禁正确关闭的受限交付；拒绝升级 `INVENTORY_VERIFIED_BY_ASTRA`、`GRAPH_BOUNDED_SUPPORTED`、`DOKKA_NOT_SELECTED`、`AAR_POM_RUNTIME_PASS`、`TCP_ROOT_CAUSE_FIXED`、`AC05_CLOSED` 或整版接受。

建议Owner**如愿继续**时另行明确批准一次**零Gradle、零修复的定点只读根因审查**，范围仅Flutter settings/plugin-loader是否创建另一Gradle scope、参数守卫的上下文、runner进程实例路径不可读的触发及fail-closed证据，优先使用既有LOCAL_ONLY日志与源码，不为问题反复全仓审计。审查完成如确需修复，再独立获批最小改动和可能的新运行预算；不得把未使用A=1转给后继或补回已耗G。

本次审阅本身没有运行本地Python/Gradle/设备，也没有修改v10.1.5源码或产品main。审阅归档仅存在独立文档审查分支，**不等于产品candidate合并**。结束后等待Owner决定。
