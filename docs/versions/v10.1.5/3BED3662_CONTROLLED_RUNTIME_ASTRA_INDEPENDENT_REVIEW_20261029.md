# EliteSync v10.1.5｜3bed3662同源受控运行Astra独立验收｜2026-10-29

**独立裁决：`3BED3662_BOUNDED_FLUTTER_WIDGET_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / PHP_NATIVE_PRELAUNCH_GUARD_STOP_ACCEPTED / API_DB_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本轮Astra通过GitHub独立审查对象、父子源码diff、脱敏结果及Manifest，没有直接访问Owner Windows本地运行、原始日志、PHP DLL、MariaDB或设备。裁决只接受各自已证的有界结果，不签`FUNCTION_ACCEPTED`、`E2E_PASS`或生产授权。

## 1. GitHub精确来源与身份

- 原正式任务：`docs/versions/v10.1.5/V10_1_5_CONTROLLED_PRIVATE_PHP_MARIADB_API_E2E_AND_TARGETED_FLUTTER_RUNTIME_TASK_20261029.md`，Blob `128fa1f7746ee73ee6d52d2d693715b003a4ec13`；签发后main的原权威`ACTIVE_STATE` Blob `f1ff64cc3f3bc68c18598dac24d2593bfa3691d4`。
- 本候选 Commit `3bed366233a39472f8a9e905021788b8d29e12b3`，sole Parent `ad25903e05ab5c0a4d88fe96c41df7963b565c1c`，Root `ce901ec23e06e29552677afe34abe257012cdf89`；与Parent的compare为ahead 1/behind 0。
- 完整产品Tree：apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`；services `eb47fe58d1167b1795224d4c748fb046042b9c92`，后者与Parent完全一致。apps只改一份非生产Flutter测试文件，没改业务runtime源码。
- 实施报告 `docs/versions/v10.1.5/CONTROLLED_SAME_SOURCE_SOFTWARE_RUNTIME_AND_E2E_RESULT_20261029.md` Blob `e6477d07fe98de86d8a07a6555801c0abf180c6f`；证据JSON Blob `5b1338d0abc4f1a902372b6d49622abd973d16c4`；Manifest自身Blob `726c3ff999f16ff05602278d6a8922a9729fcbf7`。GitHub4项变更与Manifest路径完全一致，三个非自引用final Blob均与当前GitHub对象相符；Manifest自身`final_blob=null`是明确的自引用排除。此核验没有读取Windows原始证据或独立重算各条SHA-256。
- 本次main仍`40657361e78e12ae0095183106159941c49ab573`，Root `3c54e2f19578557cb1b55693d037ea20fe516c52`，正式main产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。此Astra审查分支不是研发Parent，不应合入产品main。

## 2. 阶段C：有界Flutter Widget交付接受

Codex在新的task-owned私有Flutter3.41.7/Dart3.11.5 SDK/Pub和具名patched runner下报告三批实际运行：
- 第1批：私有Dart Runner资格exit0，19项行为检查，5项私有子调用及10个启动前拒绝负例（均是Codex运行回执，不是Astra重跑）。
- 第2批：固定Parent Widget测试文件Blob `f7ba9db3f901ae3dc84479a7a90dbd55dcac596d`，真实11项执行9通过2失败，exit1，失败保留。
- 第3批：唯一测试查找器修正后Blob `36f3d7a6a260f731df068a3aed2891b51fc2510e`，11执行/11通过/0失败/0跳过，exit0。

Astra对实际Dart差异进行了直接审查。新增`Finder _mediaButton(String tooltip)`限定`widget is IconButton && widget.tooltip == tooltip`，替换3处不当`find.byTooltip`后强转`IconButton`的断言读取；未删除、放宽原`onPressed isNull`业务负向期待，未改用户实际发送路径。前后源码均有10个`testWidgets`声明（包含参数化到11执行）、67个`expect(`、4个`isNull`、15个`tester.tap(`。原首次异常文字归因`RawTooltip is not a subtype of IconButton`与源码修正吻合；公开脱敏JSON的首轮错误记录不含完整原始Windows堆栈，不能宣称Astra目视了所有原始失败字节。

因此`TEST_PASSED_UNDER_TASK_PRIVATE_PATCHED_RUNNER`在本候选**按Codex本地有界执行＋GitHub源码核对接受**。不扩展为未打补丁的标准Flutter runner、真实Android APP、API/DB端到端、真机RTC或全版本功能成功。新Flutter预算资格批1＋Widget两批共**3/3耗尽**，`analyze=NOT_RUN_BUDGET_EXHAUSTED`，不得自动退款或替换旧6/6额度。

## 3. 阶段A：启动前安全守卫拒绝，STOP正确

Codex报告对`php_native.capture_images`真实观察能力做前置检查（针对本次Python控制进程PID，**没有Popen PHP**）遭`HARDLINK_REJECTED`。同轮另有具名标准OS模块元数据链接数2，但**实际引发拒绝的具体路径未被记录**；不能推断这份OS模块就是唯一根因，也不能把该结果说成PHP动态扩展加载失败、Laravel故障、数据库错误或真实PHP兼容验证。

原合同规定守卫拒绝时STOP相关风险项。Codex没有放松hardlink检查、重试改API、借System32/PATH复制、修改全局ACL/防火墙，也没有通过签名有效的第三方候选文件冒充已获准再分发或PHP ABI闭包；8个参考PE/Hash只读核对，仍缺一项有来源资格的私有原生依赖。因此接受`PHP_NATIVE_GATE_CLOSED_PRELAUNCH_HARDLINK_REJECTED / STOP_COMPLIANT`，**不接受任何PHP运行PASS**。

后续受控决定应一次性具名核查：实际拒绝映像的真实路径/身份；只读、可信、固定System32 OS模块是否可适用与私有可写DLL不同的Hardlink规则，保留Hash、签名、进程/系统目录与禁止跨根写入；现有Microsoft签名候选运行库的真实再分发合法性和与PHP版本/ABI兼容性；以及无DB的A探针是否被过早绑到B独立MariaDB的资格。以上是`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`的受限审议事项，**不是本报告批准修改任何守卫、下载或系统安全配置**。不开展历史ACL事故调查。

## 4. 阶段B：真实API/DB未运行

A未合格导致MariaDB服务启动0/2、PHP API启动0/2、HTTP0/160、PHP CLI0/48、探针0/2、迁移0/1、seed0/1。所有15个原E2E场景仍`NOT_RUN_GATE_CLOSED_STAGE_A_PREREQUISITE`。原始HTTP响应、数据库真实行数/唯一性、Block/CN/MC当前权限、通知投递、真实重启均未观察。没有将Mock Widget输入、之前23 Feature/152断言或旧77 Widget提升为本轮实际端到端证据。

本次已执行任务STOP后，上述**未消费的额度不自动变为新的任务许可**；90分钟窗口与新task-owned ledger不得因会话结束更名重建。只有Owner明确冻结有界后继执行条件才可再次使用新的预算，且不可追认前轮已运行。

## 5. 保护和证据等级

- `DIRECT_GITHUB_OBJECT`：Commit/sole Parent/Root、两Tree、4项变更与3个非自引用Blob、1份Dart diff及正式报告/证据/Manifest。
- `CODEX_REPORTED_LOCAL_TEST`：三批Flutter的原始exit/时长/日志Hash摘要、11项Widget结果及A阶段观察器fail-stop；Astra未重放原日志。
- `LOCAL_ONLY_RAW`：原始runner日志、私有patch/SDK、Windows模块/SD、原位账本、protected FileId、old repo和历史SQL等。
- `NOT_RUN_GATE_CLOSED`：PHP真实进程、模块加载、Laravel、MariaDB/API、HTTP/DB E2E、analyze（预算耗尽）、APK/Android、RTC/AEC/真实Push、Keystore与实际15/30天物理删除。

本轮报告的历史保护核查按Codex回执有界保留，不能冒称Astra实地重新审核旧18件严格SD恢复、五保护根、122原证、527refs、3183 Seed及所有未知dirty对象。历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`永久保持，旧Flutter6/6、MariaDB2/2、旧G/APK1/1不退款，不得删除历史失败/claims/ledger。

## 6. 独立结论与下一门

正式结论：`3BED3662_BOUNDED_PRIVATE_PATCHED_WIDGET_AND_SOURCE_REVIEW_ACCEPTED_WITH_OBSERVATIONS / PHP_PRELAUNCH_STOP_COMPLIANT / REAL_API_DB_NOT_RUN`，整体仍`V10.1.5_CONTROLLED_RUNTIME_PARTIAL_WITH_EXPLICIT_GATES`。

AC01–11**10 PARTIAL/1 OPEN（AC05 RTC）**，`V10.1.5_PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`维持。**禁止自动下一任务、main产品合并、G2/Gradle/APK/设备启动或整版验收。** 下一步仅在Owner明确选择后，对硬链接守卫与可信PHP运行库来源做具名、有限的新真实资格合同；别为历史Flutter Hash/ACL反复发微任务。
