# EliteSync v10.1.5｜单份 2GiB Seed、OS 资格与 D 盘历史目录只读盘点

日期：2026-10-28（Asia/Shanghai）。

**综合出口：SINGLE_SEED_OR_OS_QUALIFICATION_BLOCKED。**

单份已知 sealed 文件快照确实创建并逐文件核验：`SINGLE_SEED_SNAPSHOT_CREATED_AND_PINNED`。有限一次性文件访问测试完成：`TASK_OWNED_FIXTURE_ACCESS_TESTED`。但当前账户仍可修改 Seed ACL，私有父目录存在删除/重命名权限风险，故 **OS_ENFORCEMENT_NOT_PROVEN**，没有把副本改称有效不可回写的运行输入。D 盘盘点独立交付 `D_DRIVE_ELITESYNC_INVENTORY_DELIVERED_READONLY`；目前没有充分证据列出安全清理候选，实际删除/移动/重命名0。

始终 **G2_READY_FOR_POPEN=FALSE / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / GRADLE_RESOLUTION_RUNTIME_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。本轮真实工程运行预算0。

## 1. Fresh 权威、来源与候选边界

唯一正式任务 `V10_1_5_G2_SINGLE_SEED_2GIB_OS_ISOLATION_AND_D_DRIVE_INVENTORY_TASK_20261028.md`，Blob **722f24d7a2ea1c3aee1e0adea7b9fa0c0a955762**；已读取全文、核对原字节及 main Root 中具名路径。Owner 本地手动派发是执行授权，ACTIVE_STATE 发布时“待派发”不代表此时未获授权。

| 对象 | 本轮直接核验 |
|---|---|
| live main / Root | `dfa1e7828a46284617876bbd729e8b884649039e` / `e8e30f90f5a7351666a01e3b06081afb8b5ffac8` |
| main 已接受 v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 来源候选 ba7 / 唯一 Parent | `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53` / `68feee0443991696385337c318348ead5306e1ef` |
| ba7 Root / apps / services | `8aa1345fcc5f2297169296339065abe604379539` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| ba7 报告 / 索引 Blob | `b0912b629c0d0f9021788e6a5177c63720605d1f` / `b5f1825520e502995e431a571277f04cf4a824c0` |
| ba7 静态解析 / 25项定义 Blob | `f0374f502f2f45e9f4d945fbbce8e6b1a1afd94d` / `023bdd0ddf609f7ffe2f70516cebe66dc56e3871` |
| Astra ba7 验收 Blob | `fd7e7ed3162143bfe257383566563501e2131b25` |
| Astra 6ca 源级验收 Blob | `6d5ee056409de7373e635cd5e75b6aed52396bbd` |
| 原 G2 合同 / 冻结 plan Blob | `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c` / `7d3466b3be67135dc641cfee7c7faef78937ba03` |

main/ba7 完整递归 Root 6232/6662项，均未截断；完整产品文件1777份的源身份保留。ba7 四份文件用 base64 原字节读取，与本地既有副本相等。Astra ba7 仅 `BA7DF19A_BOUNDED_STATIC_DECISION_ACCEPTED_WITH_OBSERVATIONS`；6ca 仅 SOURCE_LEVEL_ONLY，不接受真实解析、OS 隔离或整版产品。schema2 七项、14份源码锚点及固定Gradle8.14 distribution 314文件再次具名核验，没有更改6ca产品代码或共享SDK。

本轮仅新建一个独立任务 outbox，不创建完整 Git 工作树或本地 refs；从 ba7 Root 派生唯一普通文档候选，唯一 Parent 固定 ba7。本报告及最小索引之外无产品变更。最终候选 Commit/Parent/Root、两新增 Blob/原字节、完整 apps/services 与 fresh main 产品树回读写入 LOCAL_ONLY final-readback，避免报告自引用。

## 2. 单份 Seed 的实际准备、来源和独立性

来源为旧可信库存内 **3183 个已知 sealed modules-2 文件，1,362,106,905 bytes**：files-2.1共2149份、metadata-2.107共1034份。只复制这份具名集合，不宣称它等于当前所有活动缓存或完整运行依赖宇宙。fileHashes.bin/file-access.bin、103项生成状态、Flutter tooling cleanup 状态不在该集合，未将其作为不可变依赖复制。未复制SQL/APK或完整Flutter/Android SDK。

复制前先核验保护关系、所有来源路径与祖先无 reparse，并打开全部3183源文件，禁共享写入/删除；6253个目录祖先只读句柄禁止共享删除。所有源文件保持这些句柄，完成首轮SHA与历史pin相等后才开始目标写入，并一直持有到完整复制及末次源Hash复核结束。遇到已存在写句柄、源读取或Hash异常应停止；本轮这些打开/Hash操作成功，没有追赶新Hash或覆盖旧pin。

只用普通新文件逐字节读写，每个目标独占新建，未调用链接、clone、复制快照、压缩/稀疏或copy-on-write API。每个文件核对源Hash、写入Hash、关闭后目标Hash、源/目标FileId不同、目标link count=1。后续 settled及保护审计再次验证3183对Hash/FileId。目标在独立任务根，源保持原处，不直接拿活动缓存充当只读Seed；仅一份完整新Seed，无第二份回滚镜像。

实际布局为 `<task>/readonly-dependency-cache/modules-2/files-2.1` 与 `modules-2/metadata-2.107`；私有 writable 的 gradle-home/project/tooling/module/plugins/build-output/temp 仅为空小骨架，没有运行工程生成。`readonly-dependency-cache` 是预定布局名称，**未被OS DACL锁成不可变对象**，也没有修改全局 GRADLE_RO_DEP_CACHE 或正式 runner。

固定Gradle8.14 `DefaultArtifactCaches.java:62–73,81–96` 验证环境变量根及其 modules 子布局，`DefaultArtifactCacheMetadata` 连接内容/metadata目录；两个源码Hash与既有pin相等（见索引）。这只支持 SOURCE_STATIC 布局，**GRADLE_INDEX_REPOSITORY_IDENTITY_VERIFIED=false、OFFLINE_VARIANT_RESOLUTION_PROVEN=false**。复制二进制索引不证明新根repository identity、离线命中、variant/classpath winner或G2闭包。

## 3. 2GiB 硬上限与容量实测

任务所有新增文件均在同一个新任务根，包括helper索引、ACL fixture、日志、空写面和回读资料。原有保护输入和先前任务目录未计成新占用；没有新本地Git对象/checkout，远端Git对象不冒称本地物理文件。本轮并未为了腾空间删除旧文件。

复制前以实际4096-byte分配单元估算：源文件逻辑1,362,106,905，目标数据round-up估算 **1,370,021,888 bytes**；加入当时任务量、16MiB helper/receipt预留、536,870,912私有写规划预留、67,108,864 metadata规划余量，计划 **1,999,664,808 bytes**，低于2,147,483,648，余147,818,840。write预留没有实际预分配，64MiB是保守规划余量，不是全卷metadata的数学上界。每文件前执行cap护栏，每256文件做完整Owned目录快照；所有Owned文件都需单link、无reparse。

| 测量阶段 | logical bytes | FILE_STANDARD_INFO allocated bytes |
|---|---:|---:|
| 首次 intake 后 before | 8,450,399 | 8,511,496 |
| 完成复制 postcopy | 1,381,397,124 | 1,389,804,848 |
| 完成OS/D盘/保护，报告前 delivery | 1,386,700,032 | 1,395,169,224 |

Seed关闭文件后的逐文件逻辑量 **1,362,106,905**，实际文件AllocationSize **1,367,920,208 bytes**。小resident文件等会使该数不同于按簇round-up估算；MFT等共享metadata不在逐文件AllocationSize中。

复制时目标仍打开的AllocationSize可能大于关闭后读数：各文件pre-close观察值之和 **1,635,970,640 bytes**，**不是同时存在的占用或真实全任务峰值**；最大单文件关闭后缩减14,393,344 bytes。按顺序前缀与settled分配量重构的数据文件高水位参考为1,367,920,208；真实任务测量快照及64MiB规划余量见索引。该修正保留初版copy结果和所有原始读数，未把错误的加总语义继续称peak。

cap未触发，未创建第二份Seed；所有明确实物约1.4GB，持续低于2GiB。测量覆盖文件和目录本身，排除后续receipt、全卷MFT/journal、外部并发；不以volume free差额宣称全轮物理增量精确。真实全卷瞬时peak不能从离散快照完整证明。新任务根创建前无本轮文件，before是intake后而非零时刻；发布回读后的最终量另存LOCAL_ONLY receipt。卷剩余数百GB不扩大授权cap。回滚仅停用此副本并保留旧源，当前无删除/回收动作，也不需第二份完整备份。

## 4. OS 资格：真实 fixture 通过，整体仍失败保守

| 允许操作 | 实际结果与范围 |
|---|---|
| 文件身份/分配 | 3183目标独立FileId、link=1，无reparse/压缩/稀疏标志；6249个目标目录祖先身份记录留LOCAL_ONLY |
| ACL descriptor | 只读查询Seed/writable/任务根至卷根的7个不同祖先descriptor；SID/owner/原始SDDL不公开 |
| 一次性 fixture DACL | 仅给该fixture文件加入当前用户的写入/append/属性/delete拒绝规则；保存原SDDL |
| 应拒绝写入 | 真实文件写句柄打开被拒绝，UnauthorizedAccessException、低位Win32错误 **5**；没有写入文件内容 |
| 私有 writable | 另一个任务自有文件独占创建、写入、flush、回读相等 |
| ACL恢复 | fixture精确恢复原SDDL、文件内容不变；保留事件、stdout/stderr/退出码，fixture本身未删除 |
| Seed/私有父权限 | 在任务自有对象上仅请求WRITE_DAC/DELETE/FILE_DELETE_CHILD资格句柄、不执行修改；Seed WRITE_DAC被授予，父删除/重命名路径存在风险 |
| token | whoami只读记录当前token/组/privilege信息，LOCAL_ONLY；未提权、未换账户/设置受限token或创建服务 |

fixture脚本exit0与“写入被拒绝5”是不同层级的事实。没有使用 takeown、grant、管理员/UAC或权限屏蔽。只有一个受控fixture做DACL改变并恢复；Seed DACL、共享SDK/cache、历史工作树和系统全局安全配置均没有改变。没有对共享目录实施写探针；祖先ACL只读描述并非完整AccessCheck或实际有效token隔离证明。

**阻断依据明确：** 同一可写账户可取得Seed WRITE_DAC，且拥有私有父目录删除/重命名能力；简单拒绝一个文件写权限不能阻止修改ACL、替换路径或未来TOCTOU。未将seed完整封成有效OS只读层，结果为 **OS_ENFORCEMENT_NOT_PROVEN**。到此停止OS强化，不擅自创建受限身份、sandbox或修改共享ACL来求通过。

Flutter tooling编译/cleanup、Groovy/Kotlin/transform/daemon/native、Android SDK manager/NDK/CMake、Pub/native plugin、HOME/AppData/temp的动态写面仍未关闭。modules-2只读布局不能覆盖它们。Seed复制、fixture实测、Python路径政策和Job关闭都不能替代完整工程写保护。

## 5. D盘根目录只读盘点与清理决定

根一级共 **348** 个目录，只筛名称大小写不敏感 EliteSync-v10* 的 **219** 个；没有递归其余129个目录。扫描不沿任何reparse；不读取SQL/APK、日志或私人资料内容。两次元数据扫描分别用于逻辑分类与实际AllocationSize，不是原子快照；逐根文件数差均0，共 **749,691文件**、**252,241目录项（含219根）**，reparse/多link/读取错误/分配未知均0。

逻辑文件总量 **40,888,539,333 bytes**；文件AllocationSize **42,072,746,936**，目录AllocationSize **242,884,608**，合计 **42,315,631,544 bytes**。这是这批目录的测量占用，**不是可安全回收量**，也不包括完整共享MFT等全卷成本。

首轮GetCompressedFileSizeW全部等于逻辑长度，不能据此当作簇分配量；原脚本/回执保留。第二轮改以FILE_READ_ATTRIBUTES + FileStandardInfo只读取得上述AllocationSize，不提权、不重试权限绕过、不更改旧目录。这是测量语义修正，不是构建或文件系统失败。

| 分类 | 目录数 | 逻辑 bytes | 文件+目录allocated bytes |
|---|---:|---:|---:|
| `KEEP_PROTECTED_OR_EVIDENCE` | 2 | 11,626,660,169 | 11,774,101,416 |
| `KEEP_ACTIVE_OR_REFERENCED` | 214 | 29,215,311,360 | 30,494,858,840 |
| `UNKNOWN_MORE_EVIDENCE_REQUIRED` | 3 | 46,567,804 | 46,671,288 |
| `CLEANUP_CANDIDATE_NEEDS_OWNER_APPROVAL` | 0 | 0 | 0 |

215个根目录匹配已有Git worktree注册，其中保护dirty根列为KEEP_PROTECTED，另外214列KEEP_ACTIVE_OR_REFERENCED；**注册仅证明引用关系，不声称有活进程**。另一目录含潜在证据/保全材料，保守KEEP。其余3个非注册目录没有足够备份、引用和唯一性证明，列UNKNOWN，不因日期或名称较早降级为可删。

文件名类别提示138个ledger、42个SQL、10个APK、88个log、8057个report（类别可重叠，未逐项读取，不把Git tracked report都称唯一原证）。匿名逐目录清单给出bytes、文件数、分配量、分类与可取得HEAD恢复锚点；真实目录名、branch、.git指针和文件细节LOCAL_ONLY。Git HEAD只能恢复已提交部分，不恢复dirty/untracked/SQL/APK/失败日志；没有建立可证明完整冗余的备份链，也没有全局进程/open-handle扫描或跨所有项目引用证明。

**本轮有证据支持的安全回收范围为0–0 bytes；实际清理0。** 这不证明未来永远不能释放空间，而是当前没有通过保护/引用/备份资格的候选。3个UNKNOWN未来可单独限定来源/备份核验；214个注册工作树未来需连同refs、dirty/untracked和原证依赖审查，不能直接执行worktree清理。没有输出或执行删除命令、移动、归档、ACL改变或后台清理计划。

## 6. 原证、预算、检查与证据等级

首尾具名保护：91份关键原件Hash/size/FileId、五历史根HEAD/branch/index/status、527个本地旧refs、worktree注册表保持；源286 HEAD仍286且干净。另核验本轮3183对source/target，原314Gradle文件、14源码锚点相等。未冒称26784/108/100453历史全量再Hash。

旧partial **7,941,328 bytes** / `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`，旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316` 保持。旧A/G2 claim仍不存在；旧APK/G各1/1耗尽，旧A gate closed；G2 max1、reservedStarts0/Popen0。本任务不使用剩余额度，不改claim/ledger。Gate2无授权。

intake、单份复制、fixture、settled/OS审计、D盘两次扫描/分类、保护核验均exit0；预期拒绝写入的错误5单独保留。8份当时Python辅助源AST检查无语法错误；没有重跑历史25/56/140套件。关键持久化运行的命令及stdout/stderr/exit Hash随索引提供；少量即时只读工具查询仅保留工具回执或结果JSON，不伪造完整raw日志。本地完整复制逐项清单、ACL/token、目录真实名及原始失败保持LOCAL_ONLY。辅助只读盘点及非作者复核不承担Astra验收，没有声称其执行本地构建/设备测试。

实际Gradle/Java/JVM/Flutter/Dart/AGP/Kotlin、G2、AAR/APK、ADB/RTC、真实observer/Job/网络构建、Gate2、下载升级/缓存删除、服务/DB/Push/生产均0。文件元数据native API、task-owned ACL/fixture与token只读调用确实发生，不能称所有native API为0。本轮没有创建工程进程树、通话、令牌、服务或端口，不进行无授权全局扫描来冒称实测资源已空。

证据等级：固定源码及布局结论 **SOURCE_STATIC**；本地复制、真实fixture/权限和盘点回执 **CODEX_REPORTED_LOCAL_EXECUTION**；完整本机路径/SID/FileId/日志 **LOCAL_ONLY_RAW**；前置裁决 **ASTRA_DIRECT_GITHUB_STATIC**；新候选对象回读 **DIRECT_GITHUB_READBACK**。整体OS隔离与工程解析 **NOT_PROVEN/BLOCKED**。

## 7. 最小后续决策与STOP

Seed镜像有价值：它形成了独立于历史活动缓存、可按Hash再核验的具名sealed输入；没有证明离线运行可用。若继续，真正下一门是限定执行身份/OS隔离资格，覆盖owner/WRITE_DAC、父删除重命名、canonical/链接与TOCTOU，并同时闭合SDK/插件剩余写面；需要Owner对具体对象和身份方案另行授权并由Astra审查。**不建议仅凭本轮镜像恢复G2**。本轮没有申请/启动这种后继执行。

D盘当前无合格清理候选；最窄后续若Owner决定，是只对3个UNKNOWN建立具名恢复/备份/引用证据，或先选择少量注册工作树核验dirty/unique evidence；不默认批准实际清理、扩容或删旧refs。

最终仍 `SINGLE_SEED_OR_OS_QUALIFICATION_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。历史AEC、native handle、真实15/30天与物理清理、真实Push等不关闭。

**本次单一非force文档候选发布并完成对象/原字节/完整产品树回读后STOP，等待Astra独立验收。不得自动G2/A/APK/Gate2、清理D盘、扩大预算、合main或启动v10.1.6。**
