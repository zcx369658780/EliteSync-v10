# EliteSync v10.1.5｜286eb20d G2 输入闭合阻断交付｜Astra 独立验收

日期：2026-10-27（Asia/Singapore）
正式裁决：**`G2_PRECHECK_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`**

本裁决仅接受G2前置库存调查中的**正确失败关闭、清晰证据分级、有限源码与保护边界、诚实预算收口**。不接受新可信构建库存完全闭合、不放行G2真实启动、不把选图视为已执行，更不接受AAR/POM、APP APK或v10.1.5整版。

## 1. Astra直接GitHub对象与正式合同审查

- live main `2da6cfe68a6b0f6d3227f52d8b860ad7ad34c330` / Root `dc8896144a4178a36ffe1d1a8135b1a3000f0b34`；完整main递归Root 6229项、未截断；已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 正式新G2任务 `docs/versions/v10.1.5/V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md` Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c` 已直接读取。该合同第2节明确：可信新库存/缓存/实际消费路径与共享写入隔离无法证明即在Gradle前STOP；G2预算仅在核准后独占claim，且即便dry-run仍可能有配置期写入与网络副作用。
- Codex受阻交付分支 `codex/v10.1.5-g2-graph-20261027` 目前HEAD `286eb20d1d6af2e76423cfbd3253880f47c9ae16`；唯一Parent `6ca09a66c0ef9619df7a3d7d4b089516f409954f`；Root `4177d75aec1eae6f33cd28ec45c88dce8496274a`。完整递归Root 6652项，`truncated=false`；apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，与6ca源码接受候选两产品Tree完全相同。
- GitHub compare `6ca...286` ahead=1、behind=0，**只新增两份文档**：`G2_SOURCE_HARDENED_GRAPH_VERIFICATION_REPORT_20261027.md` Git Blob `f4c80b4bbab70485188a31daf2e36d75d0f7c7ba`（11253 bytes）；`G2_SOURCE_HARDENED_GRAPH_EVIDENCE_INDEX_20261027.json` Git Blob `8850d02049255c6e566e2ae5e90a6eb66eb95515`（23469 bytes）。Astra已直接读取报告和解析索引，候选完整Tree中所列17项先前固定源码path/mode/Blob均逐项匹配（17/17）。未见候选源码修改或产品main更动。
- 最前置Astra对6ca的裁决仅为`SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_ONLY`，独立验收Blob `6d5ee056409de7373e635cd5e75b6aed52396bbd`。G2不能靠源级接受跃过真实库存前置门。

## 2. 技术阻断的范围内判定

**G2_NOT_RUN_INPUT_CLOSURE_BLOCKED / INPUT_CLOSURE_NOT_PROVEN / WRITE_ISOLATION_NOT_PROVEN**是正确的收口，不等于G2 Gradle构建“FAIL”或source guard实跑失败。

| 证据 | 本裁决如何解释 |
| --- | --- |
| 新schema2七项`REQUIRED_PROJECT_INPUTS`按报告在definitions/inventory两侧通过，owned init/guard/SOURCE/LICENSE/PATCH与3项tooling pins匹配 | `CODEX_REPORTED_LOCAL_EXECUTION`的局部合同验证；不推出整个Gradle运行时依赖图及缓存可写隔离已可信 |
| Codex称fresh读取历史Gradle 314、JDK 492、Flutter 6270、Pub 14931、Gradle cache 52551、Android 22178，合计96736；96734旧Hash相等，2项不同 | 只有两项`fileHashes.bin`、`file-access.bin`运行状态元数据与历史pin变化。它们在cache中，不等于生产插件源码变更，不证明缓存损坏、恶意写入或具体时间/主体，也不能重标历史输入为原封不动 |
| 历史缓存集合之外另有103个生成文件，包含旧init的Groovy编译相关缓存 | 当前历史sealed清单不能整体按旧身份复用；不自动推断文件不可信/有害，也不因单纯发现新生成缓存就建议全盘删除 |
| Flutter tooling引用根中2个未覆盖的`.gradle/buildOutputCleanup`状态文件（lock/cache.properties），报告已检查272 package引用和74 plugin引用 | 代表既有消费引用/活动状态跟踪缺口，不是生产插件源码缺失或新下载依赖的证明 |
| 新生成项目工作面复用2465个被旧pin的module `.android`文件并重新绑定local私有路径 | 允许视作准备工作，非Gradle真实配置或产物验证；Astra未取得LOCAL_ONLY generated tree或亲验路径范围 |
| 提案G2命令仍指向历史受保护Gradle user-home及共享Flutter tooling SDK写入区域；未给出完整新私有writable-home、included-build缓存/输出与既有只读输入分离合同 | 最重要的实际阻断：真实dry-run配置阶段可能写这些状态，故不得为了取得任务图而绕过写入隔离。预检能发现该风险并STOP是本次接受核心 |

上述所有本地Hash样本、检测脚本、私密路径和文件集合结论由Codex报告，**Astra不能仅凭GitHub摘要声称亲自复算96736份或验证全部写入面**。Astra对公开数字、索引/报告相互一致与17项远端源码Blob直接复核成立。没有证据支持`CACHE_CORRUPTION_PROVEN`、`VERSION_CONFLICT_PROVEN`或需要立即清除/重下全量缓存。

## 3. 原预算、运行和保护状态

- 证据索引：`G2.maxReservations=1 / reservedStarts=0 / popenCalls=0 / claimExists=false`；没有Job、observer样本、Gradle stdout/exit、命令实际Hash、已选任务图或真实runtimeStopReason。**本地claim未创建和0启动是CODEX_REPORTED_LOCAL_ONLY，不是Astra对本地磁盘直接核查**。因此`G2=0/1`尚有**条件性额度**，不是“已经批准跳过新库存门直接运行”。
- `DOKKA_TASK_SELECTED=NOT_PROVEN`；`REGISTERED=NOT_PROVEN / SELECTED=NOT_RUN / EXECUTED=NOT_RUN`（原报告逐目标）；不能填FALSE或`GRAPH_BOUNDED_SUPPORTED`。静态检查脚本exit0但返回`STATIC_CHECK_COMPLETED_GATE_BLOCKED`，不能换写为`INVENTORY_VERIFIED`。前轮140静态/mock测试只为历史复用，本G2没有再次运行。
- Codex报告定向首尾57项历史原证、五根、原有526 refs不变，旧partial 7,941,328字节/SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`，旧A claim不存在；Astra无本地完整原件访问，不扩称全盘保护通过。
- 旧APP APK预算1/1与旧G预算1/1已耗尽；旧A因失败门禁关闭。**G2未占0/1、实际AAR 0、APK 0、Gate2不授权**，不可从其它剩余字段转移额度。
- 没有真实Gradle/JVM/G2、实际AAR/POM、APP APK、ADB/RTC/Windows观察器/Job/网络探测、工具下载、缓存删除、软件版本升级或生产操作的本轮运行证据。新工作树184279228逻辑bytes，outbox6640508 bytes为Codex报告的任务自有文件，不证明宿主总物理空间。
- 持续`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`及AEC、最后可闻波形、native handle、真实15/30天与物理30天清理的原开放门禁。

## 4. 下一步判断和不授权操作

**正式裁决：`G2_PRECHECK_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`。** 接受阻断处理的诚实性和符合此前Owner许可的安全STOP；**不接受库存已闭合、G2已成功执行或任何构建新制品**。

建议的唯一下一门是**具名且磁盘敏感的input/write-isolation closure任务**：不重新进行整套产品功能规划，而是确定历史可读已pin缓存的受控消费方式，隔离新的私有可写Gradle user-home与Flutter tooling included-build缓存/输出，映射必要的`.gradle` state/lock及103个历史外生成项，以静态证据、hash/路径/source pin和完全mock的方法证明写入不会碰历史保护路径。重点区分正常生成可变元数据与真实共享不可变输入，做最小复制或可回滚的私有覆盖策略；前置容量/峰值预算明确且禁止盲目复制10GB缓存或整套SDK。若在受控条件下安全方案不可成立，保留阻断，不放宽隔离策略。

**不建议**因为2个state-file漂移就删除/重下Gradle缓存或升级Flutter/Gradle/JDK；Owner条件性缓存/软件维护授权仍在，但缺损坏和具体版本冲突证据，不触发。任何后续独立运行须重新确认**原G2合同、最新本地claim=absent、其余输入、监测与预算**，新G2不得被视作自然已执行；不自动新增运行预算或发后继任务。

本Astra裁决仅归档于**独立文档审查分支**，并在该分支同步最新状态；不修改产品main、未接受候选源码、历史refs/dirty原证，不执行Gradle、不清理缓存、不自动派发Codex或启动v10.1.6。完成后STOP，等待Owner。
