# EliteSync v10.1.5｜新干净Laravel13开发入口三项门禁收口：Astra独立验收｜2026-10-31

**正式有界裁决：`B21F0955_L13_THREE_SPECIFIED_GATES_ACCEPTED_WITH_OBSERVATIONS / CLEAN_LOCAL_L13_DEVELOPMENT_ENTRY_ACCEPTED_WITH_OBSERVATIONS / QUESTIONNAIRE_TWO_PREVIOUS_FAILURES_RETEST_PASS_2_TESTS_53_ASSERTIONS / POPULATED_SYNTHETIC_MARIADB_PROCESS_RESTART_HASH_PASS / ORIGINAL_MANUAL_START_STOP_NORMAL_CYCLE_PASS / FULL_60_REGRESSION_NOT_RUN_THIS_TASK / DATABASE_RESTORE_NOT_RUN / LOCAL_DEFAULT_L11_UNCHANGED / V10.1.5_FUNCTION_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE`。**

**解释：** 三个Owner具名收口门禁已有各自实际本机PASS回执，可作为既有干净Laravel13 **开发入口在所验范围内的可接续基线**。这不是“本轮完整60项测试全绿”、不是数据库逻辑备份恢复成功、不是脚本所有故障清理分支PASS、不是旧Laravel11真实用户cookie兼容已证，更不是v10.1.5功能整版接受或本机默认入口已切换。Astra通过GitHub直接核验原生Git对象/源码/脱敏报告；**Windows PowerShell、Docker/MariaDB、PHPUnit、原生LOCAL_ONLY原始行哈希和终态账本系Codex本机执行记录，不是Astra直接运行**。

## 1. 固定Owner授权、Commit/Tree/Manifest及产品保护

- Owner在前轮Astra `bb94a6c...`有界验收后明确批准将**问卷根JSON只读挂载复测、带数据MariaDB进程重启、原手动脚本真正启停**三缺口合为唯一综合任务。正式任务`docs/versions/v10.1.5/V10_1_5_L13_LOCAL_DEV_REMAINING_GAPS_SINGLE_CLOSURE_TASK_20261031.md`，Git Blob **`4080ba09cd83aa68537fcc719fb63f2dec312efc`**，task_id `V1015_L13_DEV_3_GAPS_CLOSURE_20261031`，attempt-0001、独立账本、现已STOP，所有预算永不复用。
- 唯一候选Commit **`b21f09550a64f1c14bf59964c371aceb5b871323`**、原生sole Parent **`e0baf03d4f63ab9fc22e65c8431b019017fded5f`**、Root **`fdf2b43290203642bb3282704486c99c7a4d1fb7`**、Parent Root `0b8ad8ff8d88ab51ff68be0d76d54022c1b936fa`。GitHub compare`ahead1/behind0`，且只新增三个docs结果文件：`L13_DEV_THREE_GAPS_CLOSURE_RESULT_20261031.md`、`L13_DEV_BASELINE_THREE_GAPS_HANDOFF_20261031.md`、`l13_dev_three_gaps_closure_manifest_20261031.json`。
- GitHub原生递归Tree Parent 6271、candidate 6274 entries，**均`truncated=false`**。Manifest所列2条非自身文档的path/mode/Blob/size直接比对**2/2吻合**，自身Manifest Blob **`211278a836016ab734fdf40a7d5b8ca492b27202`**与候选Tree相符，故全部3/3身份闭环，无额外变更。Result Blob **`ba64c296838c669a9fcd1f8e7bf3f6bb2187cf3f`**、Handoff Blob **`2dfb179fddafa40fce99a8ab0cf60442469e9f17`**。
- 候选及Parent两边apps Tree都为 `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree都为 `049a8676cc90b3b830e32a524c172720e800fa37`；**没有修改GitHub正式main或任何apps/services、Seeder/题库/测试/脚本原Blob、生产配置或历史审查原件**。Astra Review分支仅归档，不作下次研发sole Parent或main合并。

## 2. 门一：QUESTION_BANK_MOUNT_AND_REGRESSION_PASS（有界）

- Astra直接从正式main读取`question_bank/`四份接受资源Git Blob（全部mode100644）：core `02611e93fcb50cbe35126381cc4a79b178b2d423`、docx_scored `6d3fb19242734dd6938979f3846e9837518be175`、extended `d18a585139e7b179c670f84e9ca1f8734fa0398b`、research `086cceddba59704b0085e21d7e3fead8a01f7495`；均与新候选Manifest中的固定Blob **4/4匹配**。原`QuestionnaireQuestionSeeder.php` Blob `9108ca9802b8b6fb9b0ffe48f34b6bc5f1ae86a2`直接核验，按backend的`base_path('../..')`读取仓库根目录question_bank，与只读挂载目标一致。
- Codex本机回执：新隔离SQLite runner将四份已验来源的JSON**逐个只读映射至`/workspace/question_bank`**，后端位于`/workspace/services/backend-laravel`；无数据库外部连接，原两项失败`AuthQuestionnaireApiTest`分别真实通过，最终**2 tests / 53 assertions / 0 errors / 0 failures / 0 skipped / exit0**，JUnit SHA `d77b8b1fcd03b94c6e1aede015894927ccd90d570f244b09b775cce84b4ba3cc`，stdout/stderr/raw仅LOCAL_ONLY。未修改Seeder、题库语义、权限断言或原已接受业务源码。
- **关键限制：旧一轮`58 passed / 60 tests / 2 errors`的失败原件永久留存；本次只把上轮2个确切失败用例重测为PASS，未运行原60项完整单批，不能把“58+2”拼装成新`60/60 PASS`**。重跑原60需再消耗2个seed批次，将超本轮冻结seed≤3；Codex选择按合同STOP，而非减测/重置账本。此项裁决是`TARGETED_TWO_QUESTIONNAIRE_FAILURES_RETEST_ACCEPTED`，不是`COMPLETE_60_TEST_REGRESSION_ACCEPTED`。
- 映射**仅存在本轮任务私有SQLite runner**，旧开发API容器未新增常驻题库挂载；未来若日常开发API确需问卷seed，另在具名开发权限下审查只读mount，不得在已填充卷执行`migrate:fresh/seed`。

## 3. 门二：真实非空MariaDB进程重启与行一致性（有界）

- Codex报告从授权现存**唯一合成MariaDB90表、83行（1虚构user、4token）**的新本地L13开发卷中，在重启前记录完整的90表规范行序列、逐表count/full-row SHA256、DDL、列顺序和可用principal/grants，原始逐行数据和Snapshot只存LOCAL_ONLY。非空前置与既有独立卷/容器/端口、server_id/schema/10.11.19/无宿主DB端口保护符合任务收口合同。
- 具名容器执行真正`stop` → inspect `Running=false / PID=0` → `start`，**Host PID与started_at变化**，保持同容器、同原合成卷及volume filesystem身份；API未重建。重启后90表仍83行，所有逐表count、规范化全行Hash与DDL/GRANT、server_id/版本/有效权限一致；合成授权用户可以读取，系统schema越权读取拒绝。因此接受`POPULATED_SYNTHETIC_MARIADB_PROCESS_RESTART_HASH_PASS_CODEX_REPORTED`，不再是之前只做API容器重建的较小证据。
- 原始前后snapshot**文件SHA不同不是前后数据不一致的证据**：Code报告前后完整文件回执哈希为`ce48403bdc4f72ce215fb4832f28c25380608c9dbf007e643de5ebeeef8bfbd7`及`3bbf94b59db261a7f71a94f434edbb67340739e7350132bcdc32b2cc58a4fab6`；有效比较对象是**每表的count/规范行hash/DDL/权限**，并非两份带时间/元数据Receipt文件本身必须同SHA。Codex曾遇元数据类型`int`与`string`比较误报，报告在**重启前**只调整元数据数字比较口径，行Hash规范没更改，保留错误原件。
- **仍未完成**：从dump/备份重建另一独立DB并读回（这叫恢复演练）、旧/生产DB迁移或冷恢复、跨物理磁盘灾备，以及真正的长期物理时间稳定性。`DB_LOGICAL_RESTORE_TEST_NOT_RUN`与`PRODUCTION_DB_RECOVERY_NOT_PROVEN`不能因进程重启PASS自动关闭。

## 4. 门三：原PowerShell手动启动/停止正常路径闭环（有界）

- Astra先前已独立静态审查`start-existing-dev.ps1`（Git Blob `38582fd4fe145961a30e3c74a0644bbaa41fb7c2`）和`stop-existing-dev.ps1`（Blob `f0bb6e41121b0efb912bdd5d51346be4f5aa0dcf`）；本轮候选未修改两脚本。Codex报告新任务内复制固定原字节脚本与LOCAL_ONLY配置，从两服务停态真实执行start **exit0**，真实inspect确认DB/API启动；Windows宿主访问仅绑定`127.0.0.1`的端口，实际health200/guest401，专门DB重启后仍health200/401；原stop **exit0**，再次独立inspect两者PID0、runner全停，原合成卷保留。
- 因而接受`MANUAL_START_STOP_NORMAL_CYCLE_RUNTIME_PASS_CODEX_REPORTED`；不代表未来所有首次启动、冷机Docker Desktop启动或故障清理路径均可用。Astra同样注意到原start脚本**异常清理分支未检查stop命令退出结果**：这条真实安全观察继续保留，**本轮没有做超范围故障注入，也不得签失败分支自动清理PASS**。后续如要常驻使用，需要遵守Handoff的既有Engine/冻结身份先验并具名启动许可，不自动启动后台。
- 保守计量正确区分一次手动闭环、初始DB进程启动/重启计1，加专门stop/start计1，总DB process restarts **2/2**；原start脚本最多20次健康轮询在父命令前预留，外加4次独立Windows请求，HostHTTP预算**24/30为保守预付上界，不是实际HTTP请求了24次**。API restart 1/2、服务组2/2，所有现存任务服务已停止。

## 5. 预算、旧版备份、STOP与证据层级

- Codex公开预算快照：elapsed **802.110s / 10800s**，新根 logical2,575,549 / allocated2,750,568 bytes，加上保守2GiB Engine新增长度计费，均低于本次8GiB限制。受控外部依赖/OCI供应0，build0、Composer solver/install0，service groups2/2、feature batch1/3、SQLite migration1/3、seed2/3、PHP CLI4/80、manual cycles1/2、DB process restarts2/2、host HTTP24/30(预付上界)。Owner汇报最终19.84分钟未超180分钟；终态peak、ledger SHA和completion receipts仅LOCAL_ONLY，Astra不把公开动态快照当成真实最终计费。
- Codex报告原默认Laravel11 local HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、dirty252、refs527、旧vendor/index原样；原受限11,066文件/240,617,393byte备份、Manifest `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`，本轮触及范围160样本SHA/身份/尺寸只读核对、14项历史和来源STOP封存保持。旧18/两ACL/122原证/3183Seed/五根本轮未逐个重扫，只能说未触碰且保留先前证明；Astra未进入用户本机文件系统，不能独立hash旧原证。
- 原bb已STOP任务的ledger、脚本/配置原字节未被回写；本轮具名合成资源由新预算受限执行，所有新服务最终停态、新vendor/镜像/卷/源码目录保留，未设置autostart，旧默认入口及备份未删除、覆盖或移动。**本轮及所有旧任务的剩余预算永久不得复用**。
- 证据等级：本次三个门的真实运行均`CODEX_REPORTED_LOCAL_RUNTIME`，原始Junit、进程/PID、每表原始行/hash、PowerShell退出与ledger`LOCAL_ONLY_RAW`；GitHub commit/tree/正式题库、Seeder及两脚本Blob`DIRECT_GITHUB_OBJECT`。不得把间接GitHub回执称为Astra本人重跑PHPUnit或MariaDB。

## 6. 有界验收后的项目状态与后继边界

**正式结论：`L13_CLEAN_LOCAL_DEVELOPMENT_ENTRY_ACCEPTED_WITH_OBSERVATIONS`；本次Owner指定的三项欠缺门禁全部获得有界接受。** 旧已接受的GitHub Laravel13/PHP8.4框架主线保持不变，新干净本地开发入口可在**后续独立授权的开发任务**中作为可接续候选基线；原本地Laravel11默认入口**不自动切换**。

**不能升级为：** `FULL_60_TEST_REGRESSION_PASS_THIS_TASK`、`DB_BACKUP_RESTORE_ACCEPTED`、`MANUAL_SCRIPT_FAILURE_CLEANUP_VERIFIED`、`FULL_OS_ENFORCEMENT_PROVEN`、`REAL_LEGACY_L11_USER_COOKIE_MIGRATION_PROVEN`、`V10.1.5_FUNCTION_ACCEPTED`、`G2_READY_FOR_POPEN`。可选的未来完整版60项回归不得被写成当前阻断新开发的无底洞，也不因其未在本轮重跑而否定2项定向修复实测。
 
**正式v10.1.5功能门禁仍为`10 PARTIAL/1 OPEN`，AC05 RTC/AEC OPEN、真实Push provider pending、G2 false、v10.1.6 NOT_STARTED**。真实设备、APP/Flutter/Gradle/APK/ADB、H264实片、真实WebSocket/Push、物理15/30日、生产/实人/旧DB与Windows OS-wide政策验证仍未执行或未证明。旧Windows`E_NOTIMPL`、`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`和`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`原样保留。

**下一步只做战略建议，不自动派发：** 可以将已接受的干净L13本地入口作为下一轮v10.1.5 F1/F3/F4未完全完成部分的具体开发基线，在原冻结计划/AC与安全门内继续业务功能恢复和真实APP/Web/后端/独立DB贯通；是否对宿主开发入口永久改变默认值、真实推送供应商、生产/清理仍由Owner具名另行决定。当前任务STOP，旧版本和备份继续保留。

验收责任：Astra／EliteSync GPT顾问。该Review分支不作为下一研发任务Parent或产品main集成授权。
