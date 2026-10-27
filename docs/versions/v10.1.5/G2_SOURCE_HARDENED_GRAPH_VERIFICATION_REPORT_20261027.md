# EliteSync v10.1.5｜源码加固后 G2 发布图验证交付（2026-10-27）

**G2_NOT_RUN_INPUT_CLOSURE_BLOCKED / G2_GRAPH_NOT_PROVEN / G2 reservedStarts=0 / Gradle Popen=0。**

本轮执行了真实权威核验、隔离工作面准备、schema2 七项输入验证、历史工具/缓存字节复核及消费路径审计；没有建立可放行的完整可信库存，按正式任务第2节前置 STOP 收口。没有占用 G2 claim，没有启动 Gradle、真实 observer 或 Job。这里交付的是**受阻预检结果**，不是发布图成功，也不是已完成一套运行调度器。等待 Astra 独立验收。

## 1. 权威和固定源码

唯一合同 `V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md`，fresh GitHub 原字节 Blob **796c9ad2d5d91b3d375cea6c079e9e6121e0be4c**。Owner本会话明确派发；ACTIVE_STATE旧“尚未派发”是派发前时点。冻结 plan Blob **7d3466b3be67135dc641cfee7c7faef78937ba03** 未改。

| 对象 | fresh 核验身份 |
|---|---|
| main Commit / Root | `2da6cfe68a6b0f6d3227f52d8b860ad7ad34c330` / `dc8896144a4178a36ffe1d1a8135b1a3000f0b34` |
| main 已接受 v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 6ca Commit / 唯一 Parent | `6ca09a66c0ef9619df7a3d7d4b089516f409954f` / `71ab58533270dd8b3a1270a3452a82b4f426e361` |
| 6ca Root | `3bf735ab1c8e394844db80be35d86d2250390c82` |
| 6ca 完整 apps / services | `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 实际源码 Parent / Root | `ba77a3c840c36550a7ec3aa5a6475b69d874004f` / `275cd2664444532c759d688ba4b262576ad065a4` |
| 6ca 报告 / 索引 Blob | `ed802bb3a72d6e52e3fd926d4905b456e16bfd65` / `8d5a379a351960b3cb391fd2fd074908872719ab` |
| Astra 6ca 验收 Blob | `6d5ee056409de7373e635cd5e75b6aed52396bbd` |

已完整读取任务、plan、6ca报告/索引、Astra验收、旧G/A任务及失败报告/索引。Astra前置裁决仅 **SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_ONLY**。fresh main递归Tree 6229项、6ca递归Tree 6650项，均未截断；远端path/mode/Blob与本地规范Git字节的17项受影响源码身份一致。源码没有进入产品main。

本轮从6ca创建唯一新隔离工作树和 `codex/v10.1.5-g2-graph-20261027` 分支；只准备任务拥有的忽略目录下生成输入及新交付文档，未修改6ca产品源码。Windows新checkout工作字节可能含Git配置产生的行尾转换；规范Blob与工作Hash分层，未将两者混称。

## 2. 新库存：七项合同通过，整体闭合未通过

本轮从新源码调用 `owned_aar_init.inventory_contract()`，并由另一个只读审计入口独立核对schema2、七项明确必需路径在definitions/inventory两侧与实际文件一致。owned init、guard、SOURCE、patch、原SDK init及LICENSE、三个tooling pin匹配。Kotlin消费者和真实命令构造参考仍来自6ca，没有删scope或更改SDK。

准备了任务自有模块生成输入：2465份历史库存内的 `.android` 文件按原Hash复制到新工作面，并对本地package/plugin项目URI及local.properties作任务私有路径绑定。它们是**历史生成输入复用**，不构成本轮生成AAR/APK或新运行成功。未复制整个SDK或Pub/Gradle缓存。

对历史清单指向的实际工具/缓存路径重新读取并计算SHA256：

| root | 本轮fresh复核文件数 | 与历史pin相等 | 不相等 |
|---|---:|---:|---:|
| Gradle distribution | 314 | 314 | 0 |
| JDK | 492 | 492 | 0 |
| Flutter | 6270 | 6270 | 0 |
| Pub | 14931 | 14931 | 0 |
| Gradle cache | 52551 | 52549 | 2 |
| Android tools | 22178 | 22178 | 0 |
| 合计 | **96736** | **96734** | **2** |

Gradle JAR内部版本receipt为8.14；JDK release、Flutter缓存版本元数据和真实launcher字节身份均保留LOCAL_ONLY。版本来自具名文件读取，没有运行版本命令。这不是把旧100453项库存复制重命名为新库存；旧项目3717项不计入上述96736，本轮新项目七项和17个规范源码Blob另行核验。

**实际缺口与停止依据：**

1. 历史 `fileHashes.bin` 与 `file-access.bin` 两份**运行状态元数据**现值不同于旧G启动前库存；当前缓存文件集合另有103个未列入旧清单的文件，其中可见旧init的Groovy编译缓存。不能用“曾通过旧库存”宣称当前继承完全相同。
2. fresh检查272个package引用、74个平台plugin引用；`flutter_tools` 引用根中有两份旧清单未收录的 `.gradle/buildOutputCleanup` 运行状态文件（lock和cache.properties）。**这不是缺少生产插件源码或缺少下载依赖的证明**；它显示旧“引用根全部文件均已覆盖”的判定不能直接复用。
3. 拟定命令仍把Gradle user-home放在历史受保护工作面；Flutter included build也指向历史SDK tooling根。本轮没有建立并独立验证新任务私有可写home、included-build缓存/输出与既有只读输入的完整分离方案。不能让真实配置阶段写回历史输入，也不能只凭source Hash把这些目录当成只读。
4. 因此只生成了明确标记 `globalTrusted=false` 的**schema2部分清单**，没有签发完整trusted runtime inventory。命令仅是提案，未形成可执行环境策略Hash。若直接启动一次dry-run来探索这些未知点，会违反合同“不能以一次dry-run探索尚未闭合输入”的前置门。

两份状态文件变化、103个生成缓存文件及两份cleanup状态文件**不证明缓存损坏、工具链冲突、下载或恶意改写**，也不证明发生时间/写入主体。它们可能来自既往正常运行，但该解释仍未作唯一归因。本报告不声称环境不可修复、磁盘不足，或任何可行复制/只读缓存方案在所有条件下都不可能；本轮事实是尚未交付该闭合证明。没有通过刷新pin、删缓存、批量复制整个SDK/cache或修改共享输入来消除此门。

## 3. G-only调度与实际任务图

原 `controlled_runner_hardened.py` 的正式main和历史参考入口仍立即拒绝 `NO_RUNTIME_AUTHORIZATION`，未修改。静态核对了本轮若要运行所需的专有TASK/单G2阶段绑定、claim先占、持续诊断sink先于首次sample、Job kill-on-close、精确命令/cwd/env身份及输入漂移/下载/TCP/observer强停要求。

**由于A库存门未通过，没有制作或放行运行入口，没有进行真实API/observer/Job预检；B运行安全资格=NOT_RUN，不声称完整调度器已通过mock验收。** 两个辅助只读助手只做具名路径映射和runner源码核对，未执行代码、测试、native API或设备操作；它们不承担授权或Astra验收。

命令参考为已验证本地Gradle8.14二进制、两条固定init、普通R1 `-P` 参数、offline、单 `assembleAarRelease --dry-run`。提案中的版本摘要按新工作副本字节计算，提案Hash见索引；**真实命令Hash、真实环境Hash、Gradle退出码和运行stopReason均为null/NOT_RUN**，不能把提案Hash当作执行回执。

| 项目 | 本轮实际结果 |
|---|---|
| G2上限 / reservedStarts / Popen | 1 / **0** / **0** |
| G2.claim | **未创建** |
| 根进程身份 / Job / observer样本 | 未创建 / 未创建 / 0 |
| 实际selected任务输出 | **NOT_RUN**，没有stdout任务图 |
| Flutter及14个native plugin的AAR/POM/module metadata/sources/publish | REGISTERED=NOT_PROVEN；SELECTED=NOT_RUN；EXECUTED=NOT_RUN |
| Javadoc/Dokka/JavadocJar | REGISTERED=NOT_PROVEN；SELECTED=NOT_PROVEN；EXECUTED=NOT_RUN |
| G2图结论 | **GRAPH_NOT_PROVEN** |
| AAR/POM/metadata/APK build/install Hash | **NOT_RUN / 无新产物** |

未见图不能写“没有选中Dokka”；没有Gradle启动不能写exit0。G2_GRAPH_BOUNDED_SUPPORTED与G2_GRAPH_SELECTS_DOCUMENTATION_TASK本轮都没有证据。未启动Job，因此Job清空不冒称“实测0”，仅记录NOT_APPLICABLE。没有运行全局进程/网络/设备扫描来补写资源状态。

## 4. 新检查与历史复用分层

本轮 `python -X utf8 -B` 执行了 `intake.py`、`verify_inherited.py`、`prepare_project_inputs.py`、`audit_input_graph.py`、`check_delivery_inputs.py`。这些是字节/文件集合/路径和交付保护检查，均正常退出0；其中审计结果明确为**BLOCKED**，脚本正常退出不能改称库存通过。末次stdout/stderr原件及Hash在索引；早先工具返回输出不伪造成同名完整raw日志。

没有新运行140项历史mock suite，没有Groovy/Kotlin编译、Gradle配置或新runner/mock运行；6ca的140项结果仅**历史复用**。静态检查通过七项合同不证明实际Gradle对象关系、API时序或任务图。

证据等级：GitHub对象/文档为 **DIRECT_GITHUB_READBACK**；本地Hash/路径、保护与空间为 **CODEX_REPORTED_LOCAL_EXECUTION**，原件 **LOCAL_ONLY_RAW**；前置6ca裁决为 **ASTRA_DIRECT_GITHUB_STATIC**。后者不替代本候选未来独立验收。

## 5. 保护、预算、交付与停止

首尾定向核验57份关键原件、五个历史根的HEAD/branch/index/status、526个既有refs保持；只新增当前授权候选ref。原6ca工作树仍干净且HEAD不变。本轮确实fresh复核上述96736项，但不冒称重算原26784份保护集合、108份附证或旧100453库存的全部项目/出处链。

以下原件在具名保护范围中首尾Hash一致：

- 旧partial：**7,941,328 bytes**，SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`。
- 旧APK claim：`07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`。
- 旧G claim：`0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`；旧A claim仍不存在。

交付前新工作树184,279,228字节，outbox约6.64MB；为任务拥有文件的逻辑长度，不是物理allocated blocks或共享Git对象空间。合计低于512MiB；本轮没有真实Gradle临时写盘，没有新增/删除缓存副本。所有私密路径、真实宿主工具明细、原日志、SQL/APK及旧证据保持LOCAL_ONLY，不上传。

旧APK **1/1耗尽**、旧G **1/1耗尽**，旧A仍**门禁关闭**；本轮G2 **0/1未占用**仅描述账本，不授权交付后自动使用。实际AAR/POM、APK、Gate2、Writer/Serializer、设备/ADB/RTC、真实Push/生产、下载升级/缓存删除/系统安全策略改变均0。

本候选只在6ca上追加本报告和脱敏索引，唯一Parent为6ca，完整apps/services与6ca相同。最终Commit/Parent/Root、两文档Blob/原字节、完整产品Tree及live main产品树的发布后回读保存于本轮LOCAL_ONLY final-readback；报告自身不能包含其自引用最终Commit/Blob。

继续 **AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。AEC、最后可闻波形/native handle、真实15/30天和物理30天清理观察不关闭。未合产品main，未启动v10.1.6。

**普通文档候选发布及回读后STOP，等待Astra独立验收；不创建后继、不自动申请或运行下一次Gradle/A/APK/Gate2。**
