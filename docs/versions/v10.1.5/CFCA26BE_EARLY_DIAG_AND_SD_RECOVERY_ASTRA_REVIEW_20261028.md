# EliteSync v10.1.5｜cfca26be 受限子进程启动期证据及安全描述符恢复｜Astra 独立验收

日期：2026-10-28（Asia/Singapore）

**正式裁决：`CFCA26BE_BOUNDED_DIAGNOSTIC_AND_NEW_FIXTURE_ACCEPTED_WITH_OBSERVATIONS`。**

接受范围严格为：遵守零新受限子进程/零Gradle的启动期被动证据调查、两件**新任务自有fixture**的`flags7`所捕获安全描述符视图精确恢复、10项纯设计mock的交付证据，以及旧18件在来源与回滚未闭合时的正确零写入STOP。

**不接受或不关闭：`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE / CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

## 一、GitHub直接核验——固定对象与范围

- Owner正式任务：`docs/versions/v10.1.5/V10_1_5_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_FIXTURE_SD_RECOVERY_TASK_20261028.md`，Git Blob `19a25f1446e08ff875d1533f78b8cf2726c2d795`，已按GitHub main完整读取。该任务允许最多2件任务私有新fixture、各1轮真实ACL变更+恢复，旧18件仅在历史原件/身份/完整来源/回滚/引用门全面闭合时逐件最多一次恢复；禁止新的受限child launch、Gradle、G2 claim、工程/SDK/系统权限操作。
- fresh main `5dc7e1752e62454acd0d9e4bfdec58c25e602e19`、Root `611f05ab3312b5a639b8144f51ee3fc2ce24abf4`，接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 源基线`8186cebc94661bcdc229ee5b62b31871dc784a4c`（唯一Parent`76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7`；Root `1d9ec83dbfe6c211d95f713d5aa4ab93f69d8bf7`）。
- 本轮交付`cfca26beb6e3710b46f9c3559cce706c332a61b9`，唯一Parent`8186cebc94661bcdc229ee5b62b31871dc784a4c`、Root `462e4e542ebb6dbc2f6e9ed721134129c5a190de`，完整递归Root 6669项、`truncated=false`。apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` 与源候选两产品Tree严格相等，**未集成main**。
- GitHub compare 8186→cfca ahead1/behind0，**只新增3份安全文档/设计源码**：
  - `G2_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_SD_RECOVERY_REPORT_20261028.md` Blob `edc910819c6614cfdd8f0db02274ebfd8f9166f3`、16056 UTF-8 bytes、SHA256 `d853be85d957215d5c0c053f02dd0c5f3a5d6704c2e3895bdab7b389003858c6`；
  - `G2_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_SD_RECOVERY_EVIDENCE_INDEX_20261028.json` Blob `4c7121c33030d66908c2f1423c1fddee07098c79`、25390 UTF-8 bytes、SHA256 `cc17550334163db94811be499c02d11cc241fb32bf46f9e204c0c1ddea01d587`；
  - `restricted_child_early_diag_design_mock.py` Blob `4cfb3ba25f6e15d5e3156016ec0082677f9815fc`、3676 UTF-8 bytes、SHA256 `fe998b51fcb16dfef468b837036d5cc76faf21cfe8e0982fbc9b5b77c3a09226`。
  Astra直接读取这3件、比对Root Tree path/mode/Blob/size，**独立重新计算三件UTF-8 SHA256与字节数**。报告/模拟源码公开身份与索引匹配；没有候选产品源码修改。
- 前置Astra审查`8186_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_REQUIRED_OBSERVATIONS`，报告Git Blob`a6a01ad4d56633cf2ab0aeed66658067c2fc42ed`，曾确认`0xC0000142`只能作为初始化失败错误类别；旧18件`0x8404→0x8004`严格恢复0/18。

## 二、A：受限child启动期——只有被动查询及纯设计

- 历史受限子进程一次`CreateRestrictedToken`和`CreateProcessAsUser`成功，随后退出`0xC0000142`，但没有首个child frame、stdout/stderr、native creation FILETIME或可靠同实例loader栈。失败实例具体DLL/desktop/profile/权限因果均`NOT_PROVEN`，不能根据名称或退出码猜定根因。
- Codex报告只读Application Error/EventID1000与已知PID/AppPath、约4.027秒窄窗执行一次被动查询，0命中，句柄关闭。这只能是`NO_CORRELATED_EVENT_AVAILABLE_WITHIN_EXACT_FILTER`，**不能认定Windows系统没有任何失败事件**。窄窗依据当时归档文件mtime，并非原生进程creation时间；就算有同PID候选亦须防PID复用和attempt错配。
- 新`restricted_child_early_diag_design_mock.py`直接源码检查表明仅实现父端durable receipt/native stage/first child frame/stderr及实例身份匹配的**纯分类策略**，没有真正launcher、Windows API或G2解锁。其10个unittest及禁用API审计`exit0 / errors0 / skips0`是`CODEX_REPORTED_LOCAL_EXECUTION`；Astra没有运行本地Python测试，且mock不证明未来stdio/loader诊断真实可取得。
- 新受限child启动=0，历史14项访问矩阵仍`NOT_RUN_NO_CHILD_RECEIPT`。把`0xC0000142`定位到特定DLL的结论在本轮不存在。

## 三、B：两件新fixture有界成功，不等于旧18件已修复

- Codex报告在本任务**全新文件N01与空目录N02**各执行**一轮**：flags7，即`OWNER_SECURITY_INFORMATION|GROUP_SECURITY_INFORMATION|DACL_SECURITY_INFORMATION`，先记录binary/SDDL/control/ACL/owner/group/FileId和内容；DACL-only变更后control`0x8404→0x8004`；再用`SetSecurityInfo(DACL_SECURITY_INFORMATION|UNPROTECTED_DACL_SECURITY_INFORMATION,originalDacl)`在持有句柄上恢复，control`0x8004→0x8404`。每件恰好变更1/恢复1，按Codex本地逐字段回执对**已捕获flags7视图**的二进制、SDDL、control、DACL/ACE、owner/group、FileId和内容严格匹配。Astra可核对公开索引一致性，但未直接获取LOCAL_ONLY真实SDDL、原始二进制及系统调用回执。
- 这证明的是`NEW_FIXTURE_FLAGS7_CAPTURED_VIEW_EXACT_RECOVERY_SUPPORTED_2_OF_2_CODEX_REPORTED`，而不是完整安全描述符/SACL证明，也不代表已经验证Windows对**旧非空目录/子对象的继承传播**。新空目录上的成功不可外推到存在子对象、未知引用的旧树。
- 旧18对象的既有`O/G/D` SDDL以及当前`flags7`视图确有来源/可比较；**并非否定这些记录可信性**。但旧历史`self-relative binary`和`SACL`从未捕获，现补读不能代替历史原件；原source/当前引用/目录继承变化及完整回滚条件不足。因此原合同的旧对象恢复前置门**未闭合**，Codex如实执行旧对象写入0/18、逐个`NOT_RUN_UNMET_SOURCE_AND_PROPAGATION_GATES`，没有删除或重建旧fixture求绿灯。
- 旧18项仍保留`0x8404`历史control与当前`0x8004`的严格残留，相关失败原证继续LOCAL_ONLY。正确裁决是`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE`，不能称`RESTORATION_PASS`或`OS_ENFORCEMENT_VERIFIED`。

## 四、预算/保护/空间与证据边界

- Codex报告新restricted child/普通对照child/Gradle/JVM/Flutter/G2 Popen/G2.claim/设备/RTC/Job/工程网络/生产均0；真正执行的是允许的一次限定Event Log查询、2件新fixture ACL操作以及10项纯mock。旧AAR/APK/Gate2未运行，旧G和APK单次各1/1耗尽；旧A门禁封闭；新G2`max1/reserved0/Popen0/claim absent`仍仅`CODEX_REPORTED_LOCAL_ONLY`的有条件余额，**不是启动许可**。
- 具名保护101+额外21件共122件、五保护根、527 refs、旧Seed3183份Hash/FileId、旧fixture18项当前状态保护，由Codex报告首尾一致；Astra没有直接访问本地全部真实原证，不得放大为全盘保护复算。
- 64MiB任务Owned上限未报告触发。GitHub公开索引中交付文档前`FILE_STANDARD_INFO allocated=11,573,072 bytes`；Owner称最终约19.8MB来自本地最终回执，**Astra没有现场测量**，离散snapshot不能证明全卷瞬时峰值。旧Seed、共享SDK、五保护根和D盘未修改/清理均为Codex本地报告。
- 原历史AEC/native handle/真实15/30日/物理清理、真实Push、Dokka、AAR/POM、TCP因果等缺口继续开放；产品main仍v10.1.4。D盘治理副线延后。

## 五、裁决与下一门（本次不授权运行）

**`CFCA26BE_BOUNDED_DIAGNOSTIC_AND_NEW_FIXTURE_ACCEPTED_WITH_OBSERVATIONS`**：接受可审查的新fixture精确恢复方法证据、启动期有限被动调查和未证停机处理，但保留`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`及其他科学/运行门禁。

建议下一步由Owner针对**已捕获O/G/DACL+control究竟足以允许哪些限定对象恢复、旧非空目录继承传播与完整回滚如何保证**作新的具体决定；不可通过更名“精确恢复”偷换历史字节见证，不能为了消掉18项残留而随意变更SACL、全局ACL或系统用户权限。未来若允许新的受限child启动，必须独立指定次数、早期观测和失败强停，不能挪用G2旧额度。本轮既未发布后继任务，也未执行任何child/G2/工程、未清理D盘或合并main。

**STOP，等待Owner决定。**
