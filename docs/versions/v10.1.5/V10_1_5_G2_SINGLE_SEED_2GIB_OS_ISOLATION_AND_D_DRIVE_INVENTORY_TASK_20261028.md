# EliteSync v10.1.5｜2GiB 单份 Gradle Seed 快照、OS 隔离资格及 D 盘旧任务目录只读盘点

**状态：OWNER_APPROVED_BOUNDED_2GIB_SINGLE_SEED_AND_TASK_OWNED_OS_QUALIFICATION / D_DRIVE_INVENTORY_READONLY / ZERO_GRADLE / G2_CLAIM_UNTOUCHED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED**

日期：2026-10-28（Asia/Singapore）  
仓库：`zcx369658780/EliteSync-v10`

Owner 于 2026-10-28 授权：基于 Astra 对 ba7df19a 静态决策交付的独立验收，**将本次单份隔离 Seed 快照＋任务拥有的 OS 只读隔离资格验证的任务空间上限从 512MiB 提高到最多 2GiB**。Owner 还明确希望以后整理 D 盘根下大量 EliteSync-v10 历史目录；本任务仅授权**只读盘点、依赖/保护关系调查及后续清理候选分级**，不授权实际删除、移动或清理。Owner 是重大风险和不可逆决策 authority；Astra 发布任务、独立验收；Codex 须 Owner 手动派发后执行，不能借工具自行启动。

## 0. 本轮唯一目标、边界、成功与阻断出口

**主目标：** 在已有 ba7 静态决策证据之上，**最多构造一份**任务私有、源 Hash 有证据的 Gradle 8.14 `modules-2` 单独 Seed 快照（非第二份同类备份），并对**该新任务拥有的 Seed、私有 writable home/project/tooling/plugin 与可控小型 fixture** 完成真实文件身份和有限 OS 访问资格审查。它属于**Seed 快照和 OS 隔离资格任务**，不应被当成能运行 G2 的预检PASS。若现有索引/闭合缺口无法证明则必须明确记录，不能靠全量复制就认定Gradle离线解析成功。

**副目标：** 只读盘点 `D:\EliteSync-v10*` 等截图显示的 EliteSync-v10 根级目录；产出可回收空间候选、原证依赖链和优先级清单，供今后单独受控清理。截图可见 `app-t05/t06/t07...`、`app-t12`、`b9/b11/b12` 等 2026-09 任务目录，但**名字与日期不证明它们可删**。不调查D盘无关个人项目、普通用户资料或全盘其它软件。

**本轮所有工程运行预算为0**：Gradle（包括`--version`、`--help`、`--dry-run`、Wrapper/init配置）、Java/JVM、Flutter/Dart、AGP/Kotlin、真实G2及G2 Popen、构建AAR/POM/APK、真机/ADB/RTC、Windows真实观察器/Job/网络采样、Gate2、Push/DB/生产均禁止；绝不创建、更名、修改`G2.claim`或旧ledger。允许已有本地原证/Java JAR/POM/Gradle module metadata等**只读**文件访问、Hash、结构与路径/权限元数据检查、Python静态/mock与任务自有*非工程*隔离/ACL审计。不可调用需要真实Gradle依赖解析的命令，不能因为“dry-run”而偷启。

**本轮新任务所有拥有的 Seed / writable骨架 / fixtures / 日志 / outbox / 其它实物** 的峰值可分配磁盘与逻辑字节均以 **2GiB = 2,147,483,648 bytes** 为硬上限（如评估方式不同，取更保守结果）。不把额外副本、隐藏中间目录或同任务其它卷占用排除于上限，也不把历史已有保护文件当任务新占用。少量Git正常元数据也应计量或单列注明。任何超出上限的计划**必须在创建/复制前STOP**，不许拆目录逃避、不通过删除旧证据腾空间。提前测量卷剩余量、inode/allocated file bytes、工具副本独立文件身份及 copy-on-write/稀疏分配的虚实差异；持续定点测量并记录峰值、测量盲区与其他宿主并发。

**成功出口仅可为：** `SINGLE_SEED_SNAPSHOT_CREATED_AND_PINNED / TASK_OWNED_OS_ACCESS_QUALIFICATION_BOUNDED / GRADLE_RESOLUTION_RUNTIME_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE`（需要实际满足单份副本完整性、来源Hash、容量和有限OS访问资格）。**如果容量、读取源、权限或工具限制导致不能完成：** `SINGLE_SEED_OR_OS_QUALIFICATION_BLOCKED`，精确提交失败对象/失效假设与下一步Owner选项；不要为了GREEN绕过。副目标可以独立交付 `D_DRIVE_ELITESYNC_INVENTORY_DELIVERED_READONLY`，与Seed成功无逻辑依赖。若遇共享/保护对象漂移、越界写入或未授权系统变更风险，立即`PROTECTED_INPUT_OR_SYSTEM_SAFETY_STOP`。

无论静态/OS资格如何，**`G2_READY_FOR_POPEN=FALSE / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`** 在本轮不能关闭。

## 1. Fresh authority、固定源与原证保护

Codex接单时必须新鲜读取：

- live main/Root/`docs/workflow/ACTIVE_STATE.md`、本正式任务全文和 Blob；发布前 main 为 `599a44d99c928c8052a0a7edfb783e79fe63513c` / Root `3494eb3956c9529d1714c9b2c15bf982a9857b69`，已接受产品**仅v10.1.4** apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本次唯一来源候选 `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53`、唯一Parent `68feee0443991696385337c318348ead5306e1ef`、Root `8aa1345fcc5f2297169296339065abe604379539`、完整apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。该候选**不是已接受产品main**。
- ba7 决策报告 `G2_MINIMAL_DEPENDENCY_SEED_DECISION_REPORT_20261027.md` Blob `b0912b629c0d0f9021788e6a5177c63720605d1f`、索引 `G2_MINIMAL_DEPENDENCY_SEED_EVIDENCE_INDEX_20261027.json` Blob `b5f1825520e502995e431a571277f04cf4a824c0`，以及 `seed_static.py`、25项测试。Astra 独立裁决 `BA7DF19A_BOUNDED_STATIC_DECISION_ACCEPTED_WITH_OBSERVATIONS`：`astra/v10.1.5-ba7df19a-minimal-seed-review-20261028:docs/versions/v10.1.5/BA7DF19A_MINIMAL_SEED_ASTRA_REVIEW_20261028.md`，Blob `fd7e7ed3162143bfe257383566563501e2131b25`，审查分支HEAD在本任务准备时为 `4b703c9fb8397438e649c6bdd93573ba80f90059`。
- 原冻结G2`--dry-run`合同 `V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md` Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`；已接受源级但未合main的6ca源码、schema2七项/guard/tooling pin、Gradle8.14/JDK/Flutter本地固定来源。**本任务不放行先前仅一次的G2额度**。
- 原旧APK单次预算 **1/1已耗尽**、旧G单次 **1/1已耗尽**，旧A尽管0/1但因G失败**gate closed**，Gate2从未新授权。Codex上轮本地报告原G2 `reservedStarts=0 / Popen=0 / claim absent`，必须此轮fresh只读复核；本轮**不创建claim也不消耗G2**。
- 历史protected root、dirty工作树、LOCAL_ONLY日志、SQL/APK、refs/worktrees、旧Gradle下载partial `7,941,328 bytes / SHA256 b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`；旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`、旧A和G2 claim此前不存在。**先对具名原证做首尾只读Hash/identity护栏**，不得重写旧原证或历史失败身份。不能把少量抽查冒充26784项保护集、108附证或100453项旧库存全部再Hash。

## 2. 单一独立Seed：真正复制前后的规则

前置阅读ba7真实容量方案：旧sealed `modules-2` 共3183文件、逻辑长度 `1,362,106,905 bytes`（当前数为Codex报告，需fresh只读核验完整文件清单/hash/source，且确定硬链接与数据已不变），小骨架 `8,277,854` bytes、任务独有写空间规划 `536,870,912` bytes、metadata余量 `67,108,864` bytes；数学计划峰值 `1,974,364,535` bytes，在2GiB内余 `173,119,113` bytes。**这不是实测上限，禁止先把1.974GB当安全通过。** 若需要第二份同类seed同时存在，规划 `3,336,471,440` bytes，超过2GiB；**不得建第二份**。

1. 按已有完整sealed离线文件清单和Gradle本地源码确定`GRADLE_RO_DEP_CACHE`根须含`modules-2`等真实layout；只在新任务**自己拥有、无保护根祖先/别名的新目录**建立一份Seed，引用来源Hash/POM/.module/metadata二进制索引、repository identity和缓存目录结构。**严禁**以原正在使用的共享cache根本身直接充当新read-only Seed，不能用硬链接、symlink、junction、reparse、存储别名/copy-on-write未证明独立的快照假冒独立字节。
2. Seed文件只允许从**fresh复核SHA及历史pin**的已有字节做受控独立复制；对两份运行状态`fileHashes.bin`/`file-access.bin`、103个新增衍生项、tooling buildOutputCleanup两项，沿68fe的分类不应复制成不可变modules-2依赖内容。源可能正在变化则若无法原子一致快照先STOP而不“追赶最新Hash”。
3. 复制前估算**所有任务自有目录总量+可能的复制暂存/输出高水位**，确保不足即STOP；按单文件small-batch受控写入，每阶段统计真实独立FileId、目标link count、source/target SHA、链接祖先/reparse，禁止复制任何历史SQL/APK或完整Flutter/Android SDK。新Seed之外的私有 home/tooling/project/fixture只可从剩余额度内建立；若空间不足**只提交阻断证据而不扩大quota**。
4. 完整Seed如做到`BYTE_COPY_VERIFIED`，仍分别将`GRADLE_INDEX_REPOSITORY_IDENTITY_VERIFIED`、`OFFLINE_VARIANT_RESOLUTION_PROVEN`保留未知，除非本轮合法的静态证据真实证明。当前禁止启动Gradle“试试看”，禁止下载缺依赖补齐。新Seed可能最终不可用，不能把文件复制成功改写为运行闭合。
5. 对任务新Owned目录可作可回滚普通**本地权限配置与只读检查**，但不是对共享根、软件安装或全局防火墙/策略的授权。只有具名source/target与静态pin、容量及回退策略通过后才进入OS资格验证。

## 3. OS 有效只读/私有写面资格（**仅操作任务拥有的对象**）

任务允许对**新私有 Seed 与临时fixture文件/目录**进行小范围、可追踪的ACL/DACL设置及在任务自有路径中的最小、确定性文件权限验证。可只读查询必要Windows token/文件安全descriptor、effective access/FileId/link/祖先信息；可在**唯一受控的可删除任务私有fixture**做受限的写入应被拒绝验证（含预期失败和明确成功/失败代码），但不得对历史共享缓存/SDK/插件/其它项目目录做写探针或修改ACL，不得提升权限、改系统全局安全策略、替换用户帐户或创建持久系统服务。测试如触发权限拒绝即保留原始回执，不得使用 `takeown`、`icacls /grant` 全局修改、管理员自提升、UAC绕过或权限屏蔽求绿灯。

需要证明/分级：
- Seed路径及**所有祖先**的文件身份、link count、symlink/junction/reparse、volume/file id、parent delete/rename/write权限、owner/WRITE_DAC/WRITE_OWNER/privileges与可更换ACL的风险；
- 新任务私有writable home/module/tooling/build-output/temp与Seed、受保护共享源的**canonical、FileId和ACL不重叠**，通过任务拥有fixture模拟合法写入和非法写入被拒绝；
- `GRADLE_RO_DEP_CACHE`只对modules-2生效、不包含Groovy/Kotlin/transform/daemon/native、included tooling `.gradle`、Android SDK manager/NDK、Pub/插件等写入的真值。OS资格/fixture通过**也不代表这些真正工程写入已被封闭**。
- 对同一可写用户可以修改ACL或父目录rename/unlink导致绕过的路径，不得标为`EFFECTIVE_OS_ISOLATION_VERIFIED`；如必须使用受限token/独立身份/OS sandbox，而本轮不能安全构造，记录`OS_ENFORCEMENT_NOT_PROVEN`并STOP该项。
- 对命令、环境变量、默认user-home、source SDK/NDK实际隐式输出与动态路径，仍必须保留`UNKNOWN`直到另一门审查；Job kill-on-close不是写保护。

无论资格结果，`G2_READY_FOR_POPEN`保持**FALSE**。若操作仅在私有fixture成功，应准确称`TASK_OWNED_FIXTURE_ACCESS_TESTED`，而不是`FULL_SDK_OS_WRITE_ISOLATED`。

## 4. D盘旧目录只读清理盘点（**不得删任何一个目录**）

在不影响主目标预算和保护的前提下，专门盘点D盘根目录中名称属于`EliteSync-v10*`（大小写不敏感）及Owner截图明确给出的同系列旧任务目录；其他D盘项目一律不触及。使用只读根级目录列表、文件数量/逻辑与可分配空间、最近修改/访问的**非可靠证据**、Git HEAD/ref/工作树关系、`.git`文件/linked-worktree指针、跨目录符号/硬链接、当前进程/项目及其它任务依赖**可取得的只读指针**与已有protected名录构建最小候选清单。不得以简单文件夹名、9月时间戳或“main已接受v10.1.4”为删除理由。

建议每目录分类为：
- `KEEP_PROTECTED_OR_EVIDENCE`：具名原证、唯一Git提交/refs、数据库SQL、APK、历史索引、ledger/claim、运行失败日志、不可重复生产的本地唯一资料；
- `KEEP_ACTIVE_OR_REFERENCED`：活跃工作树、被他处引用的SDK/cache/plugin/任务、不可证明无依赖的目录；
- `CLEANUP_CANDIDATE_NEEDS_OWNER_APPROVAL`：可能冗余、能从固定Git对象或受信任备份恢复，且无历史原证/引用证据，但仍**只候选**；
- `UNKNOWN_MORE_EVIDENCE_REQUIRED`：扫描受限、链接/依赖/备份不清楚。
逐项给出匿名label、只读实际大小、关键文件概况、refs/worktree指针、冗余证明/唯一资产风险、恢复源SHA、可回收空间**估算区间**和需要Owner最终确认的清理方式。对目录递归扫描要有界并避免沿任何链接跨出命名范围；无法统计准确大小则标UNKNOWN，不得绕权限继续。**绝对禁止**`Remove-Item`、`rmdir`、`git clean/reset/prune/worktree remove`、移动/重命名归档、删除回收站、磁盘清理/压缩、改变目录ACL或自动执行任何清理计划。

保留仅 `LOCAL_ONLY` 的真实路径、文件名、PID及可能的个人项目内容；公开报告只出脱敏目录别名与汇总。此盘点不授权在本任务结束后后台自动清理。若某个目录疑似含隐私/无关项目，标UNKNOWN并略过。

## 5. 集中交付、验收分级与STOP

一份综合报告：
`docs/versions/v10.1.5/G2_SINGLE_SEED_2GIB_OS_QUALIFICATION_AND_D_DRIVE_INVENTORY_REPORT_20261028.md`
和一份最小脱敏结构化证据索引；必要时附最小安全纯静态/fixture脚本，不发布本地真实绝对路径、ACL/SID、磁盘编号、进程/网络/数据库原证。

报告应包含：
1. 最新live main、Owner任务Blob、本轮来源候选Commit/唯一Parent/Root和完整apps/services Tree、已有6ca源级与ba7独立裁决；最终候选所有新增文件path/mode/Blob与Git原字节回读、与main已接受产品Tree对比。
2. 本轮Seed是否真的独立落盘、文件数量、bytes、source/target SHA匹配、copy失败位置、是否仅一份、是否保留旧source只读、`GRADLE_RO_DEP_CACHE`可用layout与repository/index UNKNOWN列表；结果不得用`COPY_VERIFIED`代替Gradle resolver证明。
3. **全任务Owned空间**首/中/末逻辑/allocated测量、峰值、回滚额外开销、2GiB hard stop触发或未触发、文件身份和链接审计，明确真实不可测成本、与共享Git存储关系及并发卷活动。
4. OS限定操作表：只对私有Seed/fixture的ACL变化及恢复、允许/拒绝的访问验证、Windows有效token/权限观测可取得范围，root/ancestor/owner/WRITE_DAC/rename/TOCTOU无法证明事项。明确零共享系统ACL更改。
5. D盘目录只读汇总：根级目录数量、筛选数量、估算逻辑/allocated空间，KEEP/UNKNOWN/清理候选类别、参考指针与潜在回收量，不下删除命令，不宣称已清理。
6. 任何发生的只读或任务自有fixture操作、stdout/stderr/exit及Hash和限制；保护根/claim/ledger/旧partial首尾证据，`CODEX_REPORTED_LOCAL_EXECUTION`与`ASTRA_DIRECT_GITHUB_STATIC`分开。
7. 最小Owner后续决策：Seed镜像是否有意义，OS阻断需哪类额外具名授权，是否值得恢复原G2预检，以及D盘可安全清理候选是否有足够证据申请未来单独操作。

执行中允许对任务专有小程序/fixture在冻结范围内自主集中返修和纯mock，不必逐项让Owner审批；不得绕开硬预算、改产品源码或G2 runner正式入口。发生保护漂移/安全漏洞/新未知费用即STOP并保留原件。

**最终STOP：** 一次非force文档/安全源码候选发布+全部GitHub对象回读后停止，等待Astra独立验收。**不运行Gradle/G2、不创建claim、不自动进入A/APK/Gate2或v10.1.6、不合并产品main、不移除D盘旧目录、不开后继任务。**
