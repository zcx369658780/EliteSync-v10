# v10.1.5 PHP三项原生阻断集中修复｜2026-10-29

**V10.1.5_THREE_ISSUE_UNBLOCK_PARTIAL_WITH_GATES / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

结论：已定位当前控制进程真实首个Hardlink拒绝为 `ntdll.dll`，实现独立且仅只读的固定OS映像规则，并在第2次当前进程观察中通过。已把无DB动作与DB/API资格分离，新增纯负例。现有Microsoft运行库的合法来源/Owner许可与PHP最低运行库要求仍未充分证明，故**复制0/1、真实无DB能力Probe0/1**。不宣称PHP模块加载、Laravel/DB/E2E或整版通过。

## Authority与固定来源

Fresh main `1e00aa6229ef13f26eaec7594b24f8303afac8d2`，Root `e83fe18d2c6a8edf313d9146e98c56eb6d24bd50`，ACTIVE_STATE `525e63fc3ef16998ed3349071080cd636e7f7043`，正式任务全文/Blob `8b6bd9233a08a7f4d0986d6f592eb114dec63e04` 已直接回读。CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`，派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`，冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`，3bed Astra审查 `940d82b4367b75f81f5fd0555775a14e881b1b49` 均本轮读取。

sole Parent `3bed366233a39472f8a9e905021788b8d29e12b3` /Root `ce901ec23e06e29552677afe34abe257012cdf89`，Parent apps `8cd9b6df8e744c8fc9d4217412edce31795a318d` /services `eb47fe58d1167b1795224d4c748fb046042b9c92`；具名24个必要输入从旧受控source只读导入并逐Git Blob匹配，不复制SDK/vendor/数据或运行库。前轮报告 `e6477d07fe98de86d8a07a6555801c0abf180c6f`、证据 `5b1338d0abc4f1a902372b6d49622abd973d16c4`、Manifest `726c3ff999f16ff05602278d6a8922a9729fcbf7` 随Parent完整保留，不覆写。

## 1. 实际拒绝及系统只读规则

观察1在当前Python控制进程自身PID进行一次OS模块枚举；按OS返回顺序对每条实际路径调用原`contracts.local`，捕获原拒绝和堆栈，同时仅用只读文件句柄记录canonical path、Volume/FileId、link count、SHA256。真实首个拒绝为 `ntdll.dll` /links=2，文件SHA256 `651ac9041af8e6b5ebd331d53163244c0a27d36d1433f0f15cac1f28c5f2e82c`，位置是原 `contracts.local` 的hardlink条件；它由本次被拒路径本身取得，**不是**用另一份已知links=2文件代替。精确路径、PID、身份和完整堆栈仅LOCAL_ONLY。

当前31个loaded module中22个System32映像触发原严格规则；对这些同一次枚举实际返回的22条具名OS映像，分别取得有效Windows签名和固定文件/目录身份，不扫描系统目录或WinSxS。`os_images`将只读OS规则从私有规则分离：GetSystemDirectoryW实际根与其身份、GetFinalPathNameByHandle规范路径、直接System32父级、已加载来源、固定basename/pin/签名/Hash/Volume/FileId/size/links、拒绝reparse与alias、单个禁止共享写入/删除的只读句柄散列及前后元数据一致。其它目录、WinSxS别名、错卷、未声明模块或签名/Hash不符均拒绝。它不适用于写面或扩展来源。

第2次实际自身进程观察通过上述System32读取规则，31个映像读回成功；OS观察 **2/2已耗尽**。这只能说明本机这组已加载映像的只读资格，不证明完整PHP原生闭包、后续模块变化、恶意代码OS隔离或未来服务能启动。观测时os_images源SHA256 `33c138fb1c397dedb0a696613f5c043e44469f651f4b5514059397ff842e0adb` 已封存。随后非作者复核补齐了未来API已认可路径集合不再重进private local，以及保留Popen原始句柄/创建时间/等待状态的身份核；这部分额外收紧由最终纯测试覆盖，**没有第三次观察或真实PHP子进程验证**。

`contracts.local`原始私有hardlink/reparse保护原样保留；private manifest仍沿用它，native私有映像错误可分类HARDLINK_REJECTED_PRIVATE，系统未资格化分类OS_IMAGE_SOURCE_NOT_QUALIFIED。观察器和PHP互相核PID/nonce/profile，未知或已退出进程、创建时间替换、退出码259但句柄已signaled都拒绝。没有全局放开hardlink、改ACL/系统目录或系统策略。

## 2. Microsoft运行库：身份已核，许可及ABI未闭合

仅重核前轮已具名的现有Python工具安装候选 `vcruntime140.dll`：FileVersion/ProductVersion **14.38.33126.1**，AMD64，119,192 bytes，SHA256 `4d292623516f65c80482081e62d5dadb759dc16e851de5db24c3cbb57b87db83`，Microsoft签名验证Valid。精确源路径、证书及完整PE图留LOCAL_ONLY。候选有71个具名导出；8个已核PHP参考文件直接要求该DLL的17个具名符号均存在。所有这些PHP文件PE linker version为14.44。**同架构和符号集合匹配不是PHP ABI/完整运行兼容证明；linker字段也不是已经获得厂商最低MSVC包版本证明**。未执行动态加载。

官方依据：
- [Redistribute Visual C++ files](https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files?view=msvc-170)：runtime包、merge module和individual binaries分发限licensed Visual Studio users，并受对应Software License Terms约束。
- [VS2022 REDIST](https://learn.microsoft.com/en-us/visualstudio/releases/2022/redistribution)：validly licensed对应VS副本，才可依条款分发未修改清单文件；列有VC143和VC/redist条目。[VS2026 REDIST](https://learn.microsoft.com/en-us/visualstudio/releases/2026/redistribution) 的相应前提不能自动证明本14.38候选来源。
- [VC运行库兼容条件](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)：架构匹配，运行库至少与目标构建所用MSVC工具一样新。当前没有把14.38自动判为足以支持PHP参考二进制。

限定读取的Python LICENSE说明部分随附软件受各自许可；NEWS中的VC打包历史不能将本文件映射至特定合法REDIST资产，也没有证明Owner具备相应VS许可/使用权。**发行包→此文件的来源链、适用REDIST条目及Owner实际许可、PHP实际最低工具集要求未证明**，所以 `REDISTRIBUTABLE_NOT_QUALIFIED / PHP_RUNTIME_COMPATIBILITY_NOT_PROVEN`。签名只证明签名事实。没有穷举其它项目或系统运行库、没有复制、下载、安装/升级或System32替换。

## 3. 无DB Probe与真实DB资格分离

新增明确动作 `php_native_no_db_probe`，只接受本任务Blob、固定3bed来源和本任务私有根/有效期/源文件Hash/Manifest/空间、1次<=30秒预算与无DB/网络/Laravel范围。`validate_probe_authority`与`MainlineEnvironment::assertProbeContext`不要求new_instance_qualified、datadir、schema或DB凭据；反而拒绝这些配置字段/数据库操作。`php_runtime_probe.php`只调用Probe源资格及原能力/native握手，没有PDO连接、vendor/autoload、Laravel或HTTP路径。

共享的`assertSourceContext`复用源/配置/时效资格；原`assertContext`、connect、boot、MariaDB版本/43349/actor/datadir/schema/GRANT/selector/CN/MC/Block/Token全部保留。Python和PHP对当前无DB任务即使被改标为DB动作也显式拒绝；无DB grant不能进入API/seed。已结束的128fa受控任务加入两语言关闭集合（保留原6项，不重置旧余额）。policy仅随本次唯一Parent/apps来源更新，PHP版本/架构/原exe Hash/扩展需求不放宽。

新增`php_probe_entry.py`默认inspect无Popen/文件副作用，plan只到STATIC_PRECONDITION_OK。execute还必须有同ledger的单次额度、合法来源/ABI证明及单次私有复制回执、已观察的OS policy Hash、共享CLI/API Manifest和有限native握手。当前没有合法来源回执/副本，因此没有调用execute或PHP能力Probe；不能伪造new_instance_qualified来绕过A/B顺序。

## 真实检查与失败保留

最终Python纯检查 **96 executed /96 passed /0 failed /0 error /0 skipped，exit0**：原48项完整保留，新增48项；惯性文件与合成事实，Popen/socket/system/startfile/OS枚举拒绝替身下运行。覆盖私有hardlink、OS伪装/错误根/Hash/签名/身份/跨卷/reparse/未加载来源、未知/替代/退出进程、错nonce/PID/profile、无DB静态正例及API/DB负例、过期/旧task/错源/缺依赖等。合成正例不证明现场OS模块或PHP已加载。

允许的既有固定PHP纯CLI仅做3份改动PHP文件 `-n -l`，均exit0，没有extension参数、vendor、Laravel、PDO连接或能力探针。**这3次lint进程单独记账，不是“所有PHP进程均0”，也不是本任务1次能力Probe通过。** 最终代码相关PHP语法通过；PHP能力和真正DB仍NOT_RUN_GATE_CLOSED。

首次第2观察控制器在读取policy文本时因编码名写为utf8-sig而准备退出1，发生在观察PREPARE/任何OS枚举之前。该Python准备失败原exit/stdout/stderr保留；修正为utf-8-sig后才预记并执行第2次实际观察。两次实际观察各消费1次，没有第三次OS枚举。另有文档patch锚点不存在、没有写入的工具失败记录。首次交付扫描误识测试中小写合成OS路径，保留失败，仅对该文件的具名合成路径输入作有限扫描例外。源复核所指API集合/句柄/259问题在本综合任务中集中修正，不删负例，不重跑已过Flutter。

## 预算、保护与交付

唯一task `V1015_NATIVE_UNBLOCK_THREE_ISSUES_20261029` /attempt-0001，单一新根、写前PREPARE+fsync账本，窗口45分钟单调累计；本报告时已用1941.047秒。上限logical/native allocated各1,073,741,824 bytes，实际为数MiB，终态含目录分配和元数据预留；离散测量不等于连续峰值或MFT/journal证明。已用：OS观察2/2；运行库复制0/1；能力Probe0/1；允许纯PHP lint3次另列。MariaDB/迁移/seed/API/HTTP/Flutter/Dart/Gradle/G2/JVM/APK/ADB/设备/RTC/WS/Push均0；无全局PATH/php.ini/ACL/注册表/系统策略修改。

3个具名受保护根身份、旧ledger/receipt/digest字节Hash前后相同，候选运行库原字节未改；dirty43和527 refs与前轮固定保护快照相同。没有借任务重扫旧18、122原证、五历史根或3183 Seed，也不声称本轮重验这些完整历史门；旧失败、claims、SD及ACL预算事故全部保留。apps Tree **8cd9b6df8e744c8fc9d4217412edce31795a318d**（729 Blob）与Parent完全相同；services **dd552af956733514977cdd4bc82207c062792a96**（722 Blob），只改tests/E2E非生产资格。原finder修复、消息重试、15场景、旧报告/manifest/计划与生产路由/授权/迁移均保留。

证据分层：GitHub权威/源码/最终完整对象回读DIRECT_GITHUB_OBJECT；本轮纯测试/lint/两次观察为CODEX_REPORTED_LOCAL_TEST；raw路径/PID/安全身份/证书/映像图/账本LOCAL_ONLY_RAW；PHP Probe、模块加载与API/DB为NOT_RUN_GATE_CLOSED；运行库合法来源/ABI、OS隔离/设备物理行为为NOT_PROVEN。

## 一次最小后续Owner决定与STOP

先提供该已有候选对应的合法发行包/REDIST资产身份、Owner相应使用/再分发权及目标PHP最低MSVC要求；缺少时不得复制。若改选官方Redist取得方式，需要Owner另行具名来源、文件Hash/大小/许可、下载/安装是否允许及新复制/Probe预算，不能沿用本任务0余额或自动下载。拟执行的候选、私有闭包、原生子进程句柄/映像收据还须在独立运行授权下实际验证；这一次请求应集中覆盖这些剩余必要项，不自动拆微任务/派发。

最终候选仅sole Parent=3bed，普通non-force；按GitHub回读Commit/sole Parent/Root、全部变更原字节和完整apps/services/main，main产品仍v10.1.4（apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` /services `0cb1f9d19659291a462488b3686fd0a07a6698ac`）。

持续 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。**交付后STOP等Astra独立验收，不自签整版、不合main、不放行G2、不自动后继。**
