# EliteSync v10.1.5｜14e6cde7中央VC信任、原生加载接线与OS预启动阻断 Astra独立验收｜2026-10-30

**正式独立裁决：`14E6CDE7_BOUNDED_CENTRAL_VC_TRUST_EVIDENCE_AND_LOADER_SOURCE_ACCEPTED_WITH_OBSERVATIONS / NATIVE_OS_IMPORT_GATE_CLOSED / PHP_COMPOSER_LARAVEL12_API_DB_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本审查直接读取GitHub候选固定Git对象、变更/Manifest及相关PHP/Python源码，并核对Microsoft系统文件目录签名的官方说明。Astra**没有**在Owner Windows机器运行签名验证、PHP/Composer、MariaDB或API；Codex报告的中央VC观察及纯Python用例是`CODEX_REPORTED_LOCAL_TEST`，不是Astra动态重演证据。

## 1. 固定Authority及Git对象

- 唯一正式任务：`docs/versions/v10.1.5/V10_1_5_MS_VC_TRUST_CHAIN_CENTRAL_LOADER_LARAVEL12_COMPOSER_E2E_CONSOLIDATED_TASK_20261030.md`，Git Blob `960a738505054ac97a8cb85df660bf4f0b6decc9`，该任务允许条件式VC信任修复和PHP/Composer业务验证，不允许VC安装器、System32/全局ACL或生产数据操作。
- 候选Commit `14e6cde7b714c5bacdeedeb87233345d36a435c5`，**唯一Parent** `28994ea486eccc5191985c57952a61f6f7ab3d38`；Root Tree `d716ca18fac3ea2e992346355eabf64b4bfb4043`。GitHub compare `ahead1/behind0`，共22项变更；全部变更path/mode与Manifest路径一致，**21/21非自引用Git Blob由Astra按固定候选路径分别回读匹配**；Manifest自身Blob `e9ecedab8ffc373b3ecdb842429225882a93f859`，不以自引用假签名替代回读。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`与Parent完全相同；services Tree `4dbf710d64cf12ca513c4747bf53b7d73d5cfe1a`，变化仅限`tests/E2E`等非生产资格路径。历史F1/F3/F4业务、生产Controller、路由、迁移和Flutter没有变化。
- 正式交付报告 `docs/versions/v10.1.5/CENTRAL_VC_TRUST_CHAIN_L12_COMPOSER_API_DB_RESULT_20261030.md`，Blob `7f77e16bdf0f9ead67ef0d67eccdb9881868e210`；Manifest `docs/versions/v10.1.5/central_vc_trust_chain_l12_composer_api_db_manifest_20261030.json`，Blob `e9ecedab8ffc373b3ecdb842429225882a93f859`。
- 审查时live main仍 `fb04ac80863bae9b2a9c2c00ea7eb11d4015f107`，其产品双Tree仍仅接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`及services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本独立审查分支不成为研发Parent，绝不更改产品main。

## 2. 中央VC信任证据：有界接受，非PHP动态加载

Codex报告对具名central `vcruntime140.dll`作本轮两次独立、前记账的Windows只读观察；保留首次产品根策略`0x800B0109`拒绝，按官方SDK识别产品根与应用签名根不同后，第二次使用`MICROSOFT_APPLICATION_ROOT=0x00020000`。报告显示`WinVerifyTrust=0`、链API及Authenticode成功、Microsoft应用签名根策略`dwError=0`、CodeSigning EKU合格、cache-only严格撤销的本地链状态通过。具名版本`14.51.36247.0`、x64、单链接、文件SHA256 `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`保持。**有界接受`CENTRAL_VC_EVIDENCE_QUALIFIED`的本机观察归类**，但Astra没有直接读取LOCAL_ONLY证书DER/原始系统API输出；不可扩为在线撤销确证、完整Microsoft所有文件可信、精确MSVC工具集最低版本或实际PHP ABI通过。两次观察用量2/3，剩余1次在任务STOP后不自动成为新任务预算。

源码`windows_vc_trust.py`已经以具体`WinVerifyTrust`、`CertGetCertificateChain`、`CertVerifyCertificateChainPolicy`取代“固定publisher显示名称必须等于Microsoft Corporation”的单字符串规则，并区分API结果、错误状态、EKU、政策flag和离线吊销未知。使用受支持根政策而非忽略错误，符合本轮约束。注意测试里用的布尔/证据Hash只是合成输入；证书原件的可信来源不由这些字符串自动证明。

## 3. 中央VC真实加载资格接线：源码已实现，动态资格未取得

- `central_vc_loader.py`校验独立中央`MICROSOFT_CENTRAL_V14_RUNTIME`快照及当下SystemDirectory直接路径/FileId/Volume/Hash、只读身份；`php_runtime.validate_manifest`仅针对具名`vcruntime140.dll`引入中央特殊闭包，不将它加进泛用`os_import`或任务私有二进制清单。
- `os_images.image_map`、`php_native.cli/api`已具名路由到实际受控子进程的PID、原始句柄/创建代际、ready+nonce与加载镜像收据。`PhpRuntimeQualification::nativeReceipt`新增中央VC的source_class、路径、Hash/文件身份及原生进程绑定，另外保留普通OS镜像和strict private file的独立检查。失败原始stderr/stdout收据的代码已增加并有纯合成负例。
- **有界接受的是已写入、可供未来实际运行检验的代码接线，不是其真实正确运行。** PHP没有Popen/模块枚举，没有验证加载器是否真正选择中央DLL，也没有执行新增PHP文件语法或PHP功能测试；Windows ctypes/API失败模式、版本/时间戳与TOCTOU等现场缺口均仍需真实证据。特别是`current_native_task.execution_gate`新的OS源预检必须先合格，不能靠静态输入或伪造`source_class`推进业务。
- 旧任务关闭集合、硬链接/reparse/私有闭包和CN/MC/Block/Token、F1同键重试及T0/隐私权限仍留源中。没有发现本次变更直接更改生产鉴权代码。

## 4. 本轮精确阻断：iphlpapi和OS签名路径，不能误判Windows损坏

Codex报告在同一新私有运行根中从已核官方PHP8.5.12-1来源复制13个具名PHP成员，静态Manifest校验`STATIC_PRECONDITION_OK`，但在真实调用预启动门时遇到`NATIVE_OS_IMPORT_NOT_QUALIFIED:iphlpapi.dll`；`PHP Popen=0`。另记录`wldap32.dll`、`secur32.dll`、`normaliz.dll`等的当前文件路径嵌入签名验证不足，以及iphlpapi的链或可信时间状态不足；这些是**现有资格方式/证据缺口**，不是“恶意/损坏/需要修复Windows”的诊断。Codex报告对105候选OS模块仅65个获得静态pin、40个未合格；这里是具名源码/依赖读取的`CODEX_REPORTED_LOCAL_TEST`，不等于105个进程镜像被真正加载。候选的递归OS枚举范围过宽、把optional/delay-import误作必需的问题应保留在下一轮边界，不能扩大所有模块读取或临时忽略未核验OS模块来制造PASS。

**独立官方核查：** Microsoft在`Use SignTool to Verify a File Signature`说明系统文件可能采用catalog签名，可使用`SignTool verify /a`验证系统文件目录签名，而`/c`可对指定catalog检验文件。详见https://learn.microsoft.com/en-us/windows/win32/seccrypto/using-signtool-to-verify-a-file-signature 和 https://learn.microsoft.com/en-us/windows-hardware/drivers/install/catalog-files 。这些一般资料**没有证明**本机`iphlpapi.dll`或其他列名DLL确实属于哪个目录签名，也没有使签名/时间错误失效；下一合格的只读诊断应仅对已具名、实际必要的系统导入实现受支持catalog/可信时间戳验证，并绑定该DLL的真实文件Hash、文件身份、catalog成员关系、受信链与加载回执，拒绝未知/错文件/错签名。若本轮权限或新预算不足则继续STOP；**不得**将`System32`目录名视为已签名认证，更不能放宽私有DLL硬链接限制。
 
## 5. 测试次数、证据分级及永久门禁

Codex报告最终Python纯合成检查**193/193 passed，failed0/errors0/skipped0，exit0**；中途多次失败/改动和OS pin静态分析原证均在LOCAL_ONLY账本保留。该结果只属于`CODEX_REPORTED_LOCAL_TEST_PURE_SYNTHETIC_ONLY`，并非Astra在Windows重新运行，也不代表PHP/Laravel12业务成功。官方PHP成员复制13件、中央观察2/3；PHP CLI/Probe0、Composer供应/求解/vendor0、Laravel Feature0、MariaDB/API/HTTP0、迁移/seed0；原15场景在本轮均`NOT_RUN_GATE_CLOSED`。Flutter/G2/APK/设备/RTC/Push与物理15/30天仍未获许可。

当前`composer.lock`仍Laravel11.48.0，`LOCK_RESOLUTION_PENDING`；没有任何新Laravel12 vendor或真实PHP服务。不能因此宣布`SYNTHETIC_API_DB_PASS`，更不能签`SAME_SOURCE_APP_API_DB_E2E_PASS`。历史Flutter6/6与3bed3/3、MariaDB2/2、Gradle/APK1/1、过去所有VC观察、ACL事故及18件/两ACL树/122原证/五根/527refs/3183 Seed/旧错误与账本不得退款、清理或重审为PASS。永久保存`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。

最终`14E6CDE7_BOUNDED_SOURCE_ACCEPTED_WITH_OBSERVATIONS / CENTRAL_VC_EVIDENCE_QUALIFIED_CODEX_LOCAL / NATIVE_OS_IMPORT_PRESTART_CLOSED / PHP_COMPOSER_L12_API_DB_NOT_RUN`，产品仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11=10 PARTIAL/1 OPEN。

**下一步仅建议一份集中、Owner另授权的定点OS签名来源/可信时间验证＋限定导入闭包修复及后续条件式真实PHP、Composer和API/DB任务；不是重做中央VC、下载PHP、系统重装或旧ACL专项。** 当前审查STOP，不自动派发后继、不合产品main、不关闭AC05，不签整版FUNCTION_ACCEPTED。
