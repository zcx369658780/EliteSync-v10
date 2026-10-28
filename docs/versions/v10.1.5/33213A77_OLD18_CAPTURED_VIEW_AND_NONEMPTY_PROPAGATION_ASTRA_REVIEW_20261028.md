# EliteSync v10.1.5｜33213a77旧18件捕获视图与非空目录传播资格｜Astra独立验收

日期：2026-10-28（Asia/Singapore）。

**正式裁决：`33213A77_BOUNDED_CAPTURED_VIEW_AND_NONEMPTY_FIXTURE_DELIVERY_ACCEPTED_WITH_REQUIRED_OBSERVATIONS`。**

接受范围仅为：按本任务合同形成旧18件逐项可追溯的O/G/DACL/control捕获范围及阻断分类、只读旧目录结构和引用资格调查、一份新任务私有非空目录及三个后代的**一轮允许ACE传播与回滚**报告/证据索引，以及旧18件零写入停止。公开 Git 对象和报告之间的相互一致性为`ASTRA_DIRECT_GITHUB_STATIC`；本地Windows API、保护首尾/空间/Mock为`CODEX_REPORTED_LOCAL_EXECUTION / LOCAL_ONLY_RAW`，Astra没有访问用户Windows原始二进制或实际操作OS。

**不接受/不关闭：**`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE / REFERENCES_NOT_EXCLUDED / OLD_NONEMPTY_CHILD_PROPAGATION_NOT_PROVEN / OLD_TREE_ROLLBACK_NOT_GUARANTEED / HISTORICAL_FULL_SD_BINARY_OR_SACL_UNPROVABLE / CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

## 一、固定Git对象及精确产品边界

- 正式Owner方向A任务 `docs/versions/v10.1.5/V10_1_5_OLD_FIXTURE_CAPTURED_VIEW_AND_NONEMPTY_DIRECTORY_PROPAGATION_QUALIFICATION_TASK_20261028.md`，Blob **`86adf8d774379b6a7b5a90d416a01f35ae7ce35c`**，由GitHub直接读取，严格要求旧18件所有写/删/移/恢复为0、新任务自有1棵非空树/3后代、父DACL-only变更≤1/恢复≤1、各空间≤32MiB、新restricted child/Gradle/G2为0。
- 开审fresh main `7d5c60eb331dae145c025e89decd7705a7d605f9` / Root `f7d77a49afdac0266161b3c39bb1359dadfcbe9c`；`ACTIVE_STATE.md` Blob `c90b291316fc0b3f0490ec6f92f5d99c13aadd97`。唯一正式接受的产品仍v10.1.4，main apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本轮候选分支 `codex/v10.1.5-old18-captured-view-nonempty-20261028`，HEAD **`33213a779c993e39989100ba661e81dcdef62b2d`**，唯一Parent **`cfca26beb6e3710b46f9c3559cce706c332a61b9`**，Root **`d29124a90f0e79723721e0688855fcaa2a172003`**。GitHub compare cfca→3321为ahead1/behind0，仅新增下述两条docs文件；没有产品源码变化。
- 报告 `docs/versions/v10.1.5/OLD18_CAPTURED_VIEW_AND_NONEMPTY_PROPAGATION_QUALIFICATION_REPORT_20261028.md`，Blob **`4fa297cad6f15c99b0d4b79e2095426b8595c3e4`**，tree size **11592 bytes**。
- 索引 `docs/versions/v10.1.5/OLD18_CAPTURED_VIEW_AND_NONEMPTY_PROPAGATION_EVIDENCE_INDEX_20261028.json`，Blob **`c9e0b5ef2f4c69f52801fd92f051cc6899aebd12`**，tree size **72209 bytes**。两件均`100644`，GitHub直接读回正文/JSON且与Tree Blob匹配；报告自身SHA256在索引申报为 `249b41750e3e8af3e22e8ab7a039461badcd2f520b89d3f7f1bdb70d987491dd`，本轮未单独把Astra重新计算该SHA256称为已证。
- 本轮候选递归root **6671**项，`truncated=false`；候选完整 apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，其各自递归树在GitHub可读且`truncated=false`。未接受候选产品与main接受产品必须分开，未执行产品main集成。

## 二、旧18项只读矩阵：接受可比较性，不接受旧原态恢复

索引成功解析为JSON、包含18个唯一F001–F018条目，10 directory、8 file；非空F001有17后代、F003有1、F004有7、F005有5。各行原control为`0x8404`、当前control为`0x8004`，来源历史flags7 `OWNER|GROUP|DACL`、原采集时间的限制、现有读回Hash及目录/引用字段均明确；旧18项`oldAclWriteRestoreDeleteMoveRecreateCalls=0`。真实SDDL/SID、本机绝对路径/二进制只在LOCAL_ONLY，Astra可检查公开索引的一致性，不冒称直接验证原始Windows SD。

四层定义的边界可接受：`HISTORICAL_OGD_CONTROL_EVIDENCED`、`CURRENT_FLAGS7_VIEW_VERIFIED`、`CAPTURED_VIEW_RESTORATION_CANDIDATE_NOT_EXECUTED`、`HISTORICAL_FULL_SD_BINARY_OR_SACL_UNPROVABLE`。历史完整self-relative binary/SACL未记录的事实无法由现在新采样修复；SACL未读取不能写成不存在。仅ACE、owner、文件内容匹配不能替代control；`0x0400 SE_DACL_AUTO_INHERITED`属于descriptor control，而非ACE inheritance flag。

旧目标当前可见后代枚举完成，不等于排除了外部文件/进程引用、未来路径替换或权限传播影响。父目录`DELETE_CHILD`候选ACE不是token有效AccessCheck，未进行rename/delete探针。本次`REFERENCES_NOT_EXCLUDED`、`CHILD_PROPAGATION_UNPROVEN`、`ROLLBACK_NOT_GUARANTEED`对于旧对象必须保留。旧18严格恢复仍**0/18 NOT_RUN**，不是成功也不是本轮新失败。

## 三、新非空目录实验：有限接受与真实缺口

Codex本地报告：任务自有新父P、直接文件D1、子目录D2、其下文件D3，共4对象；在对象/祖先/FileId/link/reparse/内容及原始flags7视图预登记之后，使用同一P句柄及`SetSecurityInfo(DACL_SECURITY_INFORMATION | UNPROTECTED_DACL_SECURITY_INFORMATION)`，固定mask `0x20000004`，一次添加当前owner允许读属性的OI|CI继承marker ACE，然后一次用原DACL恢复。四对象的公开索引before/after/restore二进制与SDDL Hash支撑本轮**新捕获flags7视图**恢复陈述；三个后代显式ACL写0、父变更1/恢复1，6项纯synthetic mock由Codex报告通过。

**重要边界：四对象control在before/mutation/restore均为`0x8404`，并没有走`0x8404→0x8004→0x8404`。** 因此只支持该特定ALLOW ACE在新树上的传播/撤销和捕获视图回滚；不支持旧18件的control位重建、拒绝ACE、受限token有效性、任意层数目录、旧树跨任务引用或完整SACL。不得将`NONEMPTY_PROPAGATION_BOUNDED_SUPPORTED_ON_NEW_FIXTURE`翻译成`OLD_FIXTURE_RESTORATION_PASS`或`OS_ENFORCEMENT_VERIFIED`。

## 四、执行失败、中断报告与证据等级（必须保留的观察）

- 候选报告列出第一次只读登记文件超过4MiB自设序列化guard的exit1（发生于新ACL操作之前）、工具patch格式拒绝、helper命名冲突和报告准备的JS文本语法错误；原回执被索引/报告保留，未将失败伪装成功。索引显示内部非作者静态评审发现分类过宽、异常路径跳过rollback、AddAce接口、Hash绑定等问题，Codex报告在新fixture操作前修复；静态评审不是本次Astra现场执行。
- **Owner另明确报告存在一次此前生成中途终止，本条消息提供第二次执行报告。** 本轮公开报告/索引未建立第一次中断与第二次执行的**跨尝试唯一attempt ID、全部旧/新fixture写入尝试及任务占用合并账本**，也未证明第一次中断完全没有OS写入或独立任务根；故`PRIOR_INTERRUPTED_ATTEMPT_EFFECTS_NOT_INDEPENDENTLY_VERIFIED`、`CROSS_ATTEMPT_TOTAL_BUDGET_NOT_PROVEN`。这不推断第一次必然有违规副作用，更不能悄悄将第二次的“父ACL 1+1”当作两次合计次数。若未来要授权任何旧对象写入/新OS预算，应先对该具名中断会话做局部只读核验；不能把此观察自动提升为旧18恢复失败以外的新OS证明。
- 索引主张122件原证、五保护根、527 refs、3183旧Seed首尾匹配；其`protectionBefore/Final`与两份保护表逻辑一致，属于`CODEX_REPORTED_LOCAL_EXECUTION`。Owner补报任务最终logical **8,707,454**、allocated **8,859,856** bytes；公开索引记录的交付文档前值是logical **6,563,591**、allocated **6,674,312** bytes。完整最终空间回执位于Owner的本机`final-readback.json`与`completion-receipt.json`，Astra在此聊天工具中未直接访问；**最后空间值是Owner/Codex提供，非Astra独立file-allocation测量**。两种报告值均低于32MiB，但跨中断尝试总占用仍不能从单次回执推定。
- 任务主张：restricted或普通child启动0、历史14项OS访问矩阵NOT_RUN、Gradle/JVM/Flutter/G2 Popen/claim 0、无AAR/APK/设备/DB/生产。历史APK/G各1/1耗尽，旧A关闭；新G2此前Codex记录0/1、Popen0、claim absent是**未使用的条件额度，不是现在已授权可执行**。旧AC05、AEC/最后可闻波形、native handle、15/30日实际清理、Push、SDK写面、Gradle索引与variant、Dokka、TCP因果等均不关闭。

## 五、最终裁决与STOP

**`33213A77_BOUNDED_CAPTURED_VIEW_AND_NONEMPTY_FIXTURE_DELIVERY_ACCEPTED_WITH_REQUIRED_OBSERVATIONS`**，精确接受：已归档且Git身份核实的旧18捕获范围和保守阻断矩阵，以及Codex报告的一棵新非空微型树、一轮ALLOW ACE继承传播及flags7视图恢复、原始失败保留、STOP。不得解释为Astra直接完成OS测试、两次中断执行总体预算已独立清账、旧18历史精确恢复、受限身份、G2或整版产品通过。

本裁决不授权任何新child/对照运行、旧ACL写入/清理、额外fixture写入、G2 Popen/claim、真实AAR/POM/APK、设备/RTC、产品main集成、D盘整理或v10.1.6启动。维持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / NO_SUCCESSOR_TASK_AUTHORIZED`。

**STOP，等待Owner下一项具体授权；Astra不得从本次接受结论自动发布下一正式任务。**
