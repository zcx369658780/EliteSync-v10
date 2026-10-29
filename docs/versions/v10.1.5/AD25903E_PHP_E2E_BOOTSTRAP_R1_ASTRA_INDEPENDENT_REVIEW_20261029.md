# EliteSync v10.1.5｜ad25903e PHP E2E入口同版R1 Astra独立验收｜2026-10-29

**独立裁决：`AD25903E_BOUNDED_PHP_E2E_QUALIFICATION_SOURCE_ACCEPTED_WITH_RUNTIME_GATES_RETAINED`。**

本裁决只接受R1-01源码资格修正、合成守卫与来源可审性，不签`E2E_HARNESS_RUNTIME_READY`、整版`FUNCTION_ACCEPTED`或产品main集成。本次只使用GitHub固定对象进行独立源码审阅；不操作Owner Windows环境、原生PHP DLL、Laravel、数据库、Flutter、设备或任何服务。

## 1. Authority和Git对象

- Owner批准的正式R1任务：`docs/versions/v10.1.5/V10_1_5_E2E_PHP_RUNTIME_DEPENDENCY_QUALIFICATION_R1_TASK_20261029.md`，Blob `a307391e3872ff5367d84ddb7da86e53e531445e`；冻结原v10.1.5计划及前轮0d28裁决均继续有效。
- 候选 `ad25903e05ab5c0a4d88fe96c41df7963b565c1c`，**sole Parent** `0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`，Root `1ef1269c72a708155acc9ab1a00985819244bc71`，GitHub compare为单次前进。
- 本候选apps `03ba3602a7dc807bf963264e24f33eed01c231c8`，与Parent完全相同；services `eb47fe58d1167b1795224d4c748fb046042b9c92`。提交变更18个路径，全部与R1 Manifest清单一致。17个非自引用文件按固定候选路径取得Blob与清单17/17匹配；Manifest文件自身以实际Git Blob `9d4a8aa54e811c7f5c322db49e6f92942b657525`为准，其清单final_blob=null不是遗漏产品源码。该比对不是对18条SHA256或全部未改动产品Blob作本机重算。
- Codex报告 `docs/versions/v10.1.5/0D28E89F_PHP_E2E_BOOTSTRAP_QUALIFICATION_R1_REPORT_20261029.md` Blob `faa59dbb074d9fded3fe33d6ae8f8bfe2e634d1f`；Manifest Blob `9d4a8aa54e811c7f5c322db49e6f92942b657525`。
- 本次只读时main HEAD `8ac81fb16f2493b957eaf716fc3821f03d037385`；唯一已接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本审查分支不能作为下一研发Parent。

## 2. 源码验收：R1-01闭合在“设计/源码”层

原缺口是PHP桥接`-n`忽略全局ini后，仅显式加载pdo_mysql/openssl，但Laravel锁定依赖与本项目`DeviceSessions::issue()`的`mb_substr`需要具名扩展。该风险不是前轮真实运行观察到的故障。

实际差异：
1. 新`php_requirements.json`以具名Composer锁定输入和源调用记录所需模块、函数、类，分开普通包与开发包要求，真实选择的PHP8.5.3 NTS x64身份有固定Hash；没有把可选curl强行宣称硬依赖。
2. `php_runtime.py`使用冻结policy、私有Manifest、SHA256、PE32+ AMD64静态导入（含delay import）、声明的扩展/DLL闭包和拒绝目录逃逸；显式要求mbstring/fileinfo/openssl/pdo_mysql为shared而不是由任意builtins替代；未资格化返回失败，不声称加载成功。
3. CLI及API路由共用`launch_arguments`，保留`-n`、绝对扩展路径、受控include/open_basedir、禁dl和自动prepend/append、私有环境；`php_native.py`提供未来父观察器的PID/nonce/Manifest/模块映像绑定，进程原证仍须实际核。
4. `PhpRuntimeQualification::assertCurrent`在`MainlineEnvironment::connect`的PDO连接之前接入；bridge与test-only PHP API均经同一规则核PHP版本、SAPI、模块/函数/类/PDO驱动及私有原生映像收据。正常生产public/index并未变更。
5. 原E2E 15场景及0d28产品F1源码不重写；原`run.py inspect`仍不调用真实PHP、API、DB、Flutter。R1另外提供未来可独立授权的PHP API entry，默认inspect而非自动启动。

上述修改与正式R1任务直接相关，未发现确定性新产品越权、生产鉴权扩张或需要R2的源码层阻断。本次接受的是可审阅的**静态入口/预检设计**，不推断这些Windows闭包能够在Owner机器实际启动。

## 3. 证据等级及持续阻断

- `DIRECT_GITHUB_OBJECT`：Commit/Parent/Root/双产品Tree、18项变更与17条非自引用Blob、具名源码与文档。
- `CODEX_REPORTED_LOCAL_TEST`：Python纯契约48/48，PHP原有14项＋R1新增25项合成资格，8份PHP语法lint，Codex报告exit0。Astra没有重新执行Codex Windows原命令或目视全部LOCAL_ONLY运行日志；旧准备失败/脱敏扫描失败按原报告保留，不能删除改写。
- `LOCAL_ONLY_RAW`：历史私有PHP源、原生DLL详细图、原始日志、空间台账、实际exe/扩展字节与Windows现场。Codex报告某一私有原生依赖仍缺，**依赖未合格**，不得借助系统DLL、共享缓存或未经授权下载绕过。
- `NOT_RUN_GATE_CLOSED`：真实PHP模块加载、PE/native Observer、CLI/API握手、Laravel Bootstrap、PDO、MariaDB、HTTP/DB驱动、Flutter新增Widget、APP及真机同源E2E。源代码标注`STATIC_PRECONDITION_OK`仍是“静态前提条件”，不是可运行证明；将来只有在独立Owner批准的新版预算与来源下实际运行并核对结果才可能提升证据。

**保留运行观察**：PE静态导入和初始模块映像快照不能证明所有动态加载/OS安全隔离；原本仅手工APP观察协议不等于自动APP UI驱动。历史MariaDB23 Feature/152断言和77 Flutter patched-runner Widget仅作为历史有界证据，不转换为本候选E2E通过。

## 4. 终态与后续建议

R1-01无需再发纯工具治理微任务。未来真正有效的下一阶段是由Owner**一次**明确批准具名私有PHP缺失依赖的可信取得/闭包、独立API+MariaDB运行预算与Flutter/同源APP测试（可按先A后B的分级许可），而不是反复新建静态资格计划。无新授权时STOP，不能利用旧Flutter6/6、MariaDB2/2、Gradle/APK1/1或API旧余额，G2仍未获放行。

保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。AC01–11仍10 PARTIAL/1 OPEN，不能用静态用例数量算完成率。历史18件/两ACL树/122原证/五根/527refs/3183 Seed、旧fails、ledger、claims与dirty根全保持不可变。

**独立验收最终出口：`AD25903E_R1_BOUNDED_SOURCE_ACCEPTED / REAL_RUNTIME_AUTHORIZATION_PENDING / STOP_AWAIT_OWNER`。** 不合main、不自动发任务、不启动G2、RTC、Push或v10.1.6。
