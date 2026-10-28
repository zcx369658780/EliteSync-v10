# EliteSync v10.1.5｜76e46d99 单Seed OS资格与D盘清理盘点｜Astra独立验收

日期：2026-10-28（Asia/Singapore）

**正式裁决：`76E46D99_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`。**  
范围只接受**一份已有sealed输入独立复制的具名证据、局部fixture ACL实验、磁盘测量方法、D盘只读盘点的审慎分类与正确的强停交付**。全局技术终态保持：

`SINGLE_SEED_OR_OS_QUALIFICATION_BLOCKED / SINGLE_SEED_SNAPSHOT_CREATED_AND_PINNED_CODEX_REPORTED / TASK_OWNED_FIXTURE_ACCESS_TESTED_CODEX_REPORTED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。

## 一、GitHub直接身份与合约核验

- 本轮fresh main `dfa1e7828a46284617876bbd729e8b884649039e` / Root `e8e30f90f5a7351666a01e3b06081afb8b5ffac8`，接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 正式任务 `docs/versions/v10.1.5/V10_1_5_G2_SINGLE_SEED_2GIB_OS_ISOLATION_AND_D_DRIVE_INVENTORY_TASK_20261028.md`，Git Blob `722f24d7a2ea1c3aee1e0adea7b9fa0c0a955762`，已直接读取；仅允许**最多2GiB单Seed/task-owned OS资格与D盘根目录只读盘点**，Gradle/JVM/Flutter、G2 Popen和claim、AAR/APK、设备、Gate2等均为0。
- 实施候选 `76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7`，唯一Parent `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53`，Root `3799152e9fa348d412cabe6468a30f81f2714598`，递归6664项、`truncated=false`；完整apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`与ba7精确相等（仍**未接受产品候选**）。
- compare ba7→76e `ahead=1, behind=0`，只新增两文档：`G2_SINGLE_SEED_2GIB_OS_QUALIFICATION_AND_D_DRIVE_INVENTORY_REPORT_20261028.md` Blob `83e9067101e60945da2db35d3829555029a74bdd`（16613 bytes）及`G2_SINGLE_SEED_2GIB_OS_QUALIFICATION_AND_D_DRIVE_INVENTORY_EVIDENCE_INDEX_20261028.json` Blob `52f2f2956fa1d2cec16451570e10a261478a5c4b`（111067 bytes），均直接读取，与GitHub完整Root Tree path/mode/Blob/size一致；branch `codex/v10.1.5-single-seed-os-inventory-20261028` HEAD与候选相同。产品main没有变更。
- 前置Astra裁决`BA7DF19A_BOUNDED_STATIC_DECISION_ACCEPTED_WITH_OBSERVATIONS`报告Blob `fd7e7ed3162143bfe257383566563501e2131b25`，仅接受静态决策包，不证明Gradle resolver、索引迁移或OS隔离。

## 二、Seed复制：接受字节/身份主张的来源，不接受运行闭合

- Codex报告3183个历史sealed `modules-2`文件，逻辑长度`1,362,106,905 bytes`，独立复制到单个任务拥有`readonly-dependency-cache/modules-2`中；首尾源Hash及目标Hash、目标link=1/无reparse/非clone、不同FileId均逐件核验。保留源码打开句柄以及源祖先反删除句柄直至复制完成；没有复制mutable`fileHashes.bin`/`file-access.bin`、103个Groovy衍生项或tooling cleanup状态，旧源不作运行时RO seed使用。
- 上述3183个原始目标文件及保护路径是`CODEX_REPORTED_LOCAL_EXECUTION / LOCAL_ONLY_RAW`，**Astra没有访问本地3183对文件的原始字节或Windows file-id来亲自复核**。GitHub报告/索引、Gradle固定布局的静态出处及相互一致性已查证。此有界交付可记`SINGLE_SEED_SNAPSHOT_CREATED_AND_PINNED_CODEX_REPORTED`，不能记`GRADLE_INDEX_REPOSITORY_IDENTITY_VERIFIED`、`OFFLINE_VARIANT_RESOLUTION_PROVEN`或真实完整依赖闭合。单纯复制有效Gradle目录结构不能证明新只读层在真实启动中可命中。

## 三、OS权限：关键阻断未通过

- Codex在**仅任务拥有一次性fixture**上设置DACL显式写拒绝，真实写句柄打开被拒绝（Win32低字错误5），另一私有writable文件可写/flush/回读，fixture DACL恢复旧SDDL；seed/shared SDK/历史目录的ACL没有被修改。这支持`TASK_OWNED_FIXTURE_ACCESS_TESTED`，不支持整个OS sandbox已经安全。
- 真实资格审查报告当前执行身份仍可获取Seed`WRITE_DAC`，任务私有Seed父目录有`DELETE/FILE_DELETE_CHILD`或rename替换途径；owner/token/ancestor/TOCTOU隔离未闭合。**不能依赖同一账户简单DACL/文件只读属性抵御该账户自己更改ACL、父目录换名或路径别名**。未建立restricted identity或强制限制机制，按任务要求停止而非提权或修改共享安全策略。结论严格`OS_ENFORCEMENT_NOT_PROVEN`；G2不得启动。
- Gradle`GRADLE_RO_DEP_CACHE`只涵盖依赖读层；tooling included-build`.gradle`/scripts、Flutter/Android SDK/NDK、Pub、第三方plugin、profile/temp隐式写入及Gradle二进制索引/仓库身份均未真实闭合。此轮不接受`INPUT_CLOSURE_VERIFIED`或`G2_READY_FOR_POPEN`。

## 四、空间：报告阶段数字有意义，不能声明全卷瞬时峰值

- 硬上限为`2,147,483,648 bytes`。报告中复制前计划`1,999,664,808 bytes`（包含假设性的私有写预留和metadata余量，非实物或严格最大值）。任务拥有目录的FILE_STANDARD_INFO allocated测量：intake后`8,511,496`、postcopy`1,389,804,848`、delivery前`1,395,169,224 bytes`（约1.30GiB）；均未超过2GiB。
- 单Seed稳定后文件allocated总和`1,367,920,208`，复制中不同时间的preclose值简单相加`1,635,970,640`**并非同一时刻的真实峰值**。报告专门订正过该误读，必须保留此区别。真实全卷MFT/journal及并发宿主影响、离散snapshot间瞬时峰值、发布后最后receipt，不能从GitHub直接复测。本轮以`CODEX_REPORTED_LOCAL_EXECUTION`有界接受容量控制，没有把它写为全卷毫无漏项的精确计量。
- 旧源未删除、没有第二份Seed，也没有清理历史来腾空间；本阶段2GiB许可仅供这一次任务，**不等于长期G2容量自动开放**。

## 五、D盘：219项分类与零可安全删除判断

- Codex报告D盘根总目录348，只筛`EliteSync-v10*`219项，未递归无关129根；219项包括文件749691件，逻辑总`40,888,539,333 bytes`，文件+目录分配总`42,315,631,544 bytes`（约39.4GiB），并注明两轮扫描非原子/共享文件系统元数据未全计。D盘真实逐目录列表与文件路径均LOCAL_ONLY；Astra直接解析公开匿名219条，**各分类数量与总byte求和一致**。
- `KEEP_ACTIVE_OR_REFERENCED=214`、`KEEP_PROTECTED_OR_EVIDENCE=2`、`UNKNOWN_MORE_EVIDENCE_REQUIRED=3`、`CLEANUP_CANDIDATE_NEEDS_OWNER_APPROVAL=0`。其中215个注册Git worktree证明至少有引用关系，**不证明所有214都有活跃进程或永久需要保留**。未建立dirty/untracked、SQL/APK、唯一原证、refs的完整恢复链，Git HEAD不能代表完整备份。3个未知目录尚不满足删除许可。
- 因此从安全资格角度有证据支持的回收范围`0–0 bytes`，**不是认为整批39.4GiB都不可回收，更不是已有安全候选可以删**。Codex报告实际删除/移动/重命名0；无任务范围内的清理动作。未来需另行批准**先对3个UNKNOWN和少量可选registered worktree核对dirty/untracked/唯一原证/完全恢复来源，再定可回收量**；不得凭名称、9月时间戳或仅Git HEAD判断。
- D盘报告包括138类ledger、42 SQL、10 APK、88 log及大量report的**文件名类别统计**，不是对每份内容或唯一性直接审阅，不能反向认定所有这些文件均唯一或均冗余。

## 六、预算、保护、裁决与后继边界

- Codex报告具名91历史保护原件/五根/527旧refs/worktree注册表不变，旧partial 7,941,328 bytes SHA256`b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim SHA256`07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`，旧G claim SHA256`0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`；不是Astra直接本地验证或旧26784历史原证全量复算。
- 旧APK/G预算各1/1耗尽，旧A因为旧G门禁失败继续锁闭。Codex回报G2`max=1/reserved=0/Popen=0/claim absent`，是**本地报告的有条件未消耗额度**，不是Astra直接readback本地claim。无本轮Gradle/JVM/Flutter、G2、实际AAR/POM/APK、ADB/RTC/真实observer/Job/网络构建/Gate2/生产。报告明确承认读本机token/文件元数据和fixture真实ACL属于有限非工程操作，不能笼统称所有native API=0。
- v10.1.5仍`PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`；AEC、最后可闻波形、native handle、真实15/30天/物理清理原缺口继续。
- **`76E46D99_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`，同时`SINGLE_SEED_OR_OS_QUALIFICATION_BLOCKED`。** 当前不建议再把D盘注册工作树直接批量删除或恢复G2。下一有意义的决策是选择经单独Owner批准、对象明确的独立身份/OS写隔离方式，并完成Flutter/Android/plugin残留写面闭合；D盘若需空间回收则独立做可恢复性/refs/dirty分类。上述均为下一阶段**建议**，本审查未发布新任务、未新增运行预算、未修改main或旧候选、未触碰D盘真实内容。完成审查文档归档后STOP等待Owner。
