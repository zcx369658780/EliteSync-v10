# EliteSync v10.1.5｜fd85ac25 可复现Flutter测试入口与AC01–11差距矩阵｜Astra独立审查

日期：2026-10-29（Asia/Singapore）。

**正式裁决：`FD85AC25_BOUNDED_NONPRODUCTION_TOOLING_AND_AC_MATRIX_ACCEPTED_WITH_MATERIAL_PATCH_AUTHORITY_BLOCKER`。**

本裁决接受一次**非生产工具源码＋AC证据矩阵的有界PARTIAL交付**。报告的`CONTRACT_SOURCE_HASH_MALFORMED / PATCH_REPRODUCTION_BLOCKED`为**真实、正确、应当维持的fail-closed门禁**，并非成功准备了可直接运行的普通Flutter测试器。此轮38纯合成检查为Codex本地执行回执，未启动Flutter、Dart、数据库、API、Gradle/G2、APK或设备，不能转化为新的产品功能PASS。

## 1. Owner任务、Git对象与非集成范围

- Owner正式任务`docs/versions/v10.1.5/V10_1_5_REPRODUCIBLE_FLUTTER_TEST_ENTRY_AND_AC_GAP_CLOSURE_TASK_20261029.md`，Blob **`0854b37fdc9f11c55088ed2d2f93816a27bc2fa9`**；批准**非生产工具实际编码与AC01–11证据收口**，没有批准任何新的真实Flutter/Dart/DB/API/G2/Gradle/设备启动。本次产品既有源码与旧受保护文件不得改。
- 开审fresh main **`bbac0d177fa1db5962bf2f08325731fa4bbfb72d`** / Root **`a53db9f1da1a6a5503079df416eaf92e2a5df6f9`**，`ACTIVE_STATE` Blob **`6df2081a71af333334d41f6fabda849330fecb25`**。main接受产品仍v10.1.4 apps **`3468a3dd97da7accfda2539a0f8d8f68931a6110`**、services **`0cb1f9d19659291a462488b3686fd0a07a6698ac`**。
- 唯一候选 **`fd85ac2546afab61aaf51cdfac796cfb9bed31ac`**，sole Parent **`5aa3fc631dd7b450888c794182a1a8b35d57ec0a`**，Root **`2aee0011e6279a44bdf71063edd659cb58a718b7`**。GitHub compare为ahead1/behind0，**恰12个新增路径（8个tools、4个docs），无产品源码/测试/依赖修改**，没有产品main集成。
- 递归Root Tree `2aee0011e6279a44bdf71063edd659cb58a718b7`、**6288项且未截断**；完整候选apps Tree **`798049a15eb33fec16acdd37d83a07af0ed181b5`**（729 Blob）、services Tree **`9bba2938aa41ad3eaee501ef88bfeecdee797591`**（716 Blob），均与5aa原产品树完全一致。
- 综合报告：`docs/versions/v10.1.5/REPRODUCIBLE_FLUTTER_TEST_ENTRY_AND_AC_GAP_CLOSURE_REPORT_20261029.md` Git Blob **`c736354f6d9f574fdce9fd5a908a70c46eea1ed0`**；JSON AC矩阵 `ac01_11_gap_matrix_20261029.json` Blob **`4d3593925d3676722f59d29c324963842a217eb5`**，可读Markdown矩阵 `AC01_11_GAP_MATRIX_20261029.md` Blob **`44df4a7067ce496977d5405a321a2e8fe12d5396`**；工具Manifest `flutter_test_entry_artifact_manifest_20261029.json` Blob **`6a24e9fc084f58ba94499fca4199f5976e444cfa`**。
- Astra直接从固定Git候选读取全部关键工具`core.py`、`entry.py`、`runtime.py`、`locks.json`、`test_entry.py`、README和示例配置/回执，及全部四份docs。Manifest列出其余11个文件，每一项的Git `path/mode/blob`与递归Root Tree **11/11匹配**；Manifest自身Git Blob由按路径回读取得，不循环自签。此为`DIRECT_GITHUB_OBJECT`身份，不等于Astra逐字节重新计算全部文件本地SHA256或启动脚本。

## 2. 非生产工具的真实源码：接受静态交付，不能验收execute运行资格

本候选确实交付了**工具代码**，非单纯设计说明：
- `entry.py`提供默认`inspect`、`plan`、`prepare`、`recover`、`execute`接口，默认inspect不启动子进程；`core.py`实现固定源Hash/Flutter版本/输出树/私有路径与链接检查、严格单文件diff、dependency resolver、任务授权字段、Hash链ledger、copy后readback、旧root恢复与空间上限检查。非生产目录`tools/v1015/flutter_widget_test_entry/`，没有正式产品依赖修改。
- `locks.json`固定Flutter3.41.7、Dart3.11.5、hooks_runner1.0.1、Git源apps Tree 729 Blob及具名测试路径，且对历史已关闭task ID/Blob拒绝。`runtime.py`含**未来**Windows suspended Popen/Job与子进程映像观察、批次保守消费逻辑、白名单参数和JSON回执Hash；本轮**从未用真实Windows进程资格化或运行**。未来的`execute`当前仅接受明确后继Owner授权及一份task-owned资格证明，**JSON字段只是可信操作者一致性约束，不能证明Owner身份/任意恶意代码沙箱**。直接读代码可见`PROCESS_EXIT_ZERO_TEST_RESULTS_UNVERIFIED`，没有将exit0自动宣称77用例通过。
- `test_entry.py`直接源码可计**38个具名unittest test_方法**；报告称Python3.11无Flutter/DB/HTTP的纯合成测试38/38 exit0，属于`CODEX_REPORTED_LOCAL_TEST`。Astra没有重跑任何实际本地测试；38方法存在也不自动证明全部执行。模拟的正向launcher不代表Windows OS Job/子进程守卫已可靠实现；后者需要新的、单独批准的真实运行与原始回执。
- 未来保留的隐患/观察：runInShell=false对.bat/.cmd不等于无系统shell；`hook_arguments`是**工具独立检查函数，不自动拦截第三方hook内部的Process.start**，实际白名单仍依赖先前LOCAL_ONLY的私有patched runner。Windows采样有瞬时进程覆盖缺口，不能视为对任意第三方Dart原生执行的通用安全容器。此工具是`REVIEWABLE_NONPRODUCTION_SCAFFOLD`而非已部署、已资格化的标准Flutter入口。

## 3. Material finding：正式任务62位原Hash，必须保持停止

GitHub固定任务文字、候选`locks.json`实际`hook_original_sha256`为：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`（**62 hex**）。

此前独立审查`5aa3`报告、其GitHub索引`privateRunner.beforeSha256`明确为：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`（**64 hex**）。

**Astra已再次直接读取并对照了三个GitHub正文，确实不一致**；不是模型猜测。此错误源于**正式Owner任务单文字的不可用Hash**，不能由Codex默默改`locks.json`来冒充在原合同下合规。其`validate_pins`对62位值返回`CONTRACT_SOURCE_HASH_MALFORMED`，当前`inspect`可报告原因，但带锁的`plan/prepare/execute`必须阻断：`PATCH_REPRODUCTION_BLOCKED`。

候选另提供`accepted_reference_original_sha256`64位、目标SHA及原始CRLF diff与LF canonical diff区别。报告称**只在内存中**以具名已审参考字节成功复现目标Hash，且没有将LOCAL_ONLY patch原件提交仓库、未真正prepare新SDK或运行Flutter：`IN_MEMORY_REFERENCE_BYTES_REPRODUCED_ONLY`。这是符合本轮安全合同的诚实结果；**不等于可移植patch已完整归档或全局Flutter开发环境已修复**。

**后续最低需要**：Owner明确批准一次**修正合同源Hash的文档级勘误/权限重冻结**，以固定64位历史Blob索引和当前真实Hash为唯一来源；Astra独立回读新Task/Blob和locks修复候选，验证补丁输入真实可信，并继续保留**默认execute关闭**。这项提议不是当前任务自动获得新的真实运行预算。旧错合同应作为历史永久可追溯，不能悄悄覆写成“从未出错”。

## 4. AC01～11差距矩阵验收

- 矩阵JSON恰**11行**，ID连续`AC-10.1.5-01`至`AC-10.1.5-11`。每行`frozen_endpoint`均可在正式`docs/versions/v10.1.5/plan.md` Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`全文中定位；其30条当前源码`path/mode/blob`与候选完整递归Tree **30/30匹配**。所有行`this_task_retested=false`，没有伪造本任务软件运行证据。
- 结果**10条`PARTIAL`，1条`OPEN`（AC05 RTC）**；此分布是门禁现状，**不是10/11完成率**。模块映射严格`F1消息、F2 RTC、F3离线、F4通知、F5具名旧资产`。前轮不同命名中的“F2离线”简写没有覆盖正式冻结定义。
- AC02/03虽有前轮真实合成MariaDB 23 Feature/152断言、两连接重放/撤权，以及前轮私有patch runner下11文件77/77 Flutter Mock，**仍缺同一当前版本APP→API→DB的实测一致旅程**；响应丢弃非物理断包、两连接非捕获lock-wait。
- AC04需真图片/短视频及媒体200/206、撤权和重启重读；AC05持续`OPEN`，历史RTC真实媒体call4/5、旧token403、host上界10.125秒、AEC不证来自不同apps Tree的Astra报告 **`5e5851cc54185d488490706e99deaed57cb67802`**。Astra本次直接读取此旧RTC审查Blob并核实其限界，**不把旧媒体证据迁移成当前候选实物通过**；5秒停止与声音质量仍缺。
- AC06/07有服务端可信T0与Flutter合成时间/Mock清理等有界证据，但真实设备Keystore、跨重启与物理15/30天经过及清理未证；AC08/09已有通知合同/当前资源资格的有界证据，但真实OS通知/后台Push仍`PENDING/NOT_RUN`；AC10当前源APK+服务端+数据库的整条旅程及构建重启尚未绑定同一版本；AC11独立验收、实际制品与未来安全集成分开。本矩阵没有降低冻结AC，也未以文档方式为任何AC自动给PASS。
- F5旧附件/语音留言/地图地点在源不足时保留`UNKNOWN_OR_OUT_OF_SCOPE`；没有重造附近人/实时位置。完整Markdown矩阵与JSON为同一方向，下一行动区分可复用证据和另需Owner批准的设备/构建/RTC/Push/物理时间门。
- 矩阵所引用的**既有历史设备/DB/Widget通过是前轮接受事实**；不意味着本轮重新运行了测试或存在可以当场合法运行的产品集成/真机环境。

## 5. 预算、保护和报告准确性

- Codex报告本task为一棵新task-owned根，新增逻辑/分配各≤256MiB，静态合成检查后约1.5MiB；前轮Flutter6/6、MariaDB2/2消耗账本保留。**本任务真实Flutter/Dart、MariaDB/PHP API、G2/Gradle、Android/APK/设备/RTC/Push的新增启动均为0**，没有依赖网络下载、修改产品旧源码。耗时/空间和原Windows ledger为`LOCAL_ONLY_RAW`，Astra未现场复核每个Popen/全程空间峰值。
- 报告明确承认一次手动源编辑批次没有逐编辑before Hash，不能升级为全量逐操作原字节审计；已交付文件的最终Git Blob/Tree身份与该缺口分开。首轮合成测试失败与错误被保存，没有不实声称整轮始终无失败。
- 旧ACL事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`按Owner决定封存；旧18、两实验树、122历史原证、五根、527refs、Seed3183、原失败/旧budget/dirty worktree不清理。无本轮重新完整OS身份核验就不声称旧ACL已经恢复或隔离门通过。
- 持续`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

## 6. 裁决、唯一建议及STOP

**`FD85AC25_BOUNDED_NONPRODUCTION_TOOLING_AND_AC_MATRIX_ACCEPTED_WITH_MATERIAL_PATCH_AUTHORITY_BLOCKER`**：接受本次完整、可定位的非生产工具源与AC证据治理资产，正确阻断不能证明的prepare/execute；不接受“完整可运行/未改版Flutter通用入口已修复”，不签`V10.1.5_FUNCTION_ACCEPTED`或任何AC关闭。

**优先下一方向**：一次**零真实Flutter/数据库/设备启动的权威Hash勘误＋工具锁定身份集中修复/独立审查**，解决当前62位正式合同的前置阻断。与此同时使用已交付的11行矩阵供Owner决定真实APP/API/DB、当前同源媒体/RTC、设备Keystore/物理时间、Push和未来构建G2的最小授权序列。避免重复已PASS的MariaDB/77 Widget、自动开启旧预算或为换环境反复制造空候选。

**STOP等待Owner明确后继授权，不自动发布新研发任务、不改main产品、不重新启动Flutter/DB/G2、不清理旧原证、不进入v10.1.6。**
