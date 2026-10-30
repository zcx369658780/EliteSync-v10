# EliteSync v10.1.5｜28994ea4中央VC签名取证与Laravel12启动阻断 Astra独立验收｜2026-10-30

**正式裁决：`28994EA4_BOUNDED_CENTRAL_VC_DIAGNOSTIC_SOURCE_ACCEPTED_WITH_OBSERVATIONS / CENTRAL_VC_PUBLISHER_CHAIN_NOT_PROVEN / OBSERVATION_2_OF_2_EXHAUSTED / PHP_COMPOSER_LARAVEL_API_DB_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本报告为Astra直接读取GitHub候选Commit、Root/Parent/双Tree、所有变更Blob及重要源码后作出的独立有界裁决。没有在Owner的Windows主机重新执行签名检查、系统模块观察、PHP/Composer/数据库或Flutter测试。真实本机观察与149项纯测试均须标`CODEX_REPORTED_LOCAL_TEST`；本次独立阅读Microsoft官方Windows签名兼容指导，明确追加一个系统签名验证策略观察。

## 1. Authority与GitHub固定对象

- 正式综合任务 `docs/versions/v10.1.5/V10_1_5_EXISTING_SYSTEM_VC_AND_LARAVEL12_COMPOSER_RUNTIME_E2E_CONSOLIDATED_TASK_20261030.md`，Blob `d048f7f8fee97a93f8bf8c52293f60762fff0bda`；该合同授权既有central v14 x64只读调查与独立资格成功后的Composer/软件回归，**没有安装/repair Windows VC运行库的权限**。
- 唯一交付Commit `28994ea486eccc5191985c57952a61f6f7ab3d38`，sole Parent `f16d4cda817282d935cb53ce399d26a7850381a1`，Root `ad7150eeb6996adbdf22ea4f4560d58afb9c71d4`，compare ahead1/behind0，共11项变更。GitHub全路径/Manifest一致，**10项非自引用Blob经固定GitHub候选路径独立读回10/10一致**。Manifest自身Blob `432a57f8d6d34e167f3240777bfa2b273f864cc6`，内部正确排除循环self签。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，与Parent未变；services Tree `4c01326cbf44b4705548e97221e3336e0448406f`，变化只在后端非生产E2E门禁及tools/文档，业务app/routes/DB迁移/生产Controller未修改。
- Codex正式报告 `docs/versions/v10.1.5/CENTRAL_VC_L12_COMPOSER_API_DB_RUNTIME_RESULT_20261030.md`，Blob `aa732ad41990d310c71e991ddaba01cadee5ce30`；Manifest `docs/versions/v10.1.5/central_vc_l12_composer_api_db_runtime_manifest_20261030.json`，Blob `432a57f8d6d34e167f3240777bfa2b273f864cc6`。
- 审查时 live main `d499658e0104960ebf270dbffb57a02ae86c36ee`；main产品仍唯一已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本Astra独立审查分支不是研发Parent，不合产品main。

## 2. 中央VC取证的有界独立裁决

Codex本机报告在Windows API返回的System32具名位置发现`vcruntime140.dll`，AMD64、单硬链接、FileVersion `14.51.36247.0`，SHA256 `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`、178616 bytes，且两轮具名只读Hash一致。WinVerifyTrust cache-only离线结果为`0x00000000`；**这既不是当次在线吊销查询，也不等于独立核验完整的微软发布者证书链**。两次当前Python控制进程的定点只读观察均完成、账本2/2耗尽；第1次只得部分身份信息，第2次遇证书显示名校验拒绝。代码记录的显示名是`Microsoft Windows Software Compatibility Publisher`而不是预设的`Microsoft Corporation`，并未持久化足够的可信发布者链字段。原绝对路径/卷/文件ID/签名原件/进程信息均是`LOCAL_ONLY_RAW`，Astra本次无法直接检查真实字节。

**这只支持`CENTRAL_VC_PRESENT_BUT_NOT_QUALIFIED / OBSERVER_PUBLISHER_PROOF_INCOMPLETE / FAIL_CLOSED_STOP_COMPLIANT`；不能升级为中央文件损坏、不信任Microsoft、实际PHP加载失败、必须重装或已成功加载中央库。** 当前Python控制进程加载的同名runtime路径不等于中央目标，也不能推断未来PHP进程必加载哪个位置。旧安装包和当前中央文件版本同为14.51.36247.0，版本相同并不是“需要repair”的证据。

微软2026-08官方支持指导 **Preparing the Windows ecosystem for next-generation code signing**：
https://support.microsoft.com/en-us/servicing/os/windows/docs/2026/08/next-generation-code-signing
明确指出，Windows正在替换签名证书/CA及算法，要求开发者**不要把固定证书名、主体/issuer、thumbprint或特定算法当作信任充分/必要条件**；推荐由受支持Windows信任API处理证书链，不因微软证书轮换误拒合法签名。另微软`WinVerifyTrust`与`CertGetCertificateChain`、`CertVerifyCertificateChainPolicy`文档：
https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust
https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-wthelpergetprovsignerfromchain
可作为后续证书链信任审查接口依据。**独立官方指导直接增加一个本轮静态设计观察：仅以显示名称必须等于`Microsoft Corporation`的规则确实脆弱，不宜成为下一轮默许默认资格。** 但这一外部规则不能代替具体DLL的签名来源、代码签名用途、文件Hash、实际加载路径及其它安全检查；不得因为显示名看似Microsoft就跳过验证。

## 3. 源码审查：分离方式合理，真正运行仍受阻

- 新`tools/v1015/mainline_e2e/central_runtime_preconditions.py`为**纯输入事实合同**，将`MICROSOFT_CENTRAL_V14_RUNTIME`与`WINDOWS_SYSTEM_IMAGE`和`TASK_PRIVATE_BINARY`分开。它要求实际SystemDirectory API直接根、canonical path、只读且links=1、x64、文件Hash/FileId/Volume、版本及具名签名/兼容证据pin；加载事实另绑定PID/创建代际/nonce。没有Popen/Windows原生信任验证器、真正PHP进程observer或Composer执行权限；合成true及任意64字节Hash字符串自身不是可独立信赖的签名/版本原证。
- `os_images.validate_os_fact`新增对`vcruntime140.dll`的普通系统映像例外**拒绝**，防止借`WINDOWS_SYSTEM_IMAGE`通用规则跳过专门资格；`php_runtime.os_import`仍不把vcruntime列为泛用系统导入例外；严格私有hardlink/reparse安全门未放松。这是有意义的fail-closed源码边界，**有界接受**。
- **保留一个关键实现缺口：** 当前生产前E2E`php_runtime.validate_manifest`依然要求每个非OS import都可在private目录闭合，`php_native`的现有OS路径分支也尚未连接中央runtime的独立合法加载资格。故“选用已安装central VC”目前只有输入模型、**没有真正接入动态PHP加载器的完整许可规则和进程module验证**。报告已如实披露，无实际PHP启动；不能将本次源码接受视为具备Composer/PHP实际运行条件。
- 当前`php_requirements.json`继续标`CENTRAL_VC_NOT_QUALIFIED`、`REDISTRIBUTABLE_NOT_QUALIFIED`及`LOCK_RESOLUTION_PENDING`，并沿用Laravel11.48.0的旧`composer.lock`。Python/PHP关闭集合加入本轮结束任务Blob，旧历史授权不复活。`test_supply_preconditions`仅为历史纯事实fixture保持其原Parent，不发放新真实运行grant。
- 若未来修复证书字段，应将签名来源分类、预期用途、Windows信任API策略、离线吊销限制、真实system路径和私有路径的严格区分收紧在具名中央模块，不可全局跳过issuer/signer检查、在任意系统/非系统目录加载DLL、让所有同名模块直接通过或放宽私有硬链接。

## 4. 测试、预算与证据边界

Codex报告纯Python合成契约第一批148/148 exit0、最终149/149 exit0，新增17项中央运行库负例，真实原Windows测试回执与stdout SHA保留LOCAL_ONLY。Astra直接阅读测试源码确认存在模拟正反条件和默认inspect的无副作用约束，但并未亲自执行该环境；149项只说明本轮Python模拟套件通过，不说明完整Windows OS信任、真正Composer/PHP或Laravel业务通过。

报告的实际消耗：中央具名观察**2/2耗尽**；PHP ZIP重复下载0、VC安装器0、Composer PHAR/包下载0、Composer求解0/2、vendor安装0/1、PHP CLI/Probe均0、Laravel12 Feature 0/3、MariaDB/API启动各0/2、真实HTTP0/160、迁移/seed 0。观察2次都由Python控制进程完成；没有本轮PHP、DB、API/Flutter/真机/RTC/Push过程。剩余未消费额度随着本任务`STOP`**不能自动作为后继Owner授权**。旧Flutter6/6、3bed3/3、MariaDB2/2、G/APK1/1与历史ACL非合规事故、旧18/两ACL树/122原证/五根/527refs/3183 Seed、账本/claims/dirty都保持原证，不退款、不清理。

所有证据等级严格分层：`DIRECT_GITHUB_OBJECT`为对象SHA/改动及源码；`CODEX_REPORTED_LOCAL_TEST`为系统读取/真实退出/纯合成用例；`LOCAL_ONLY_RAW`为证书原始内容、路径/进程及完整ledger；`NOT_RUN_GATE_CLOSED`为PHP、Composer、Laravel12 Feature、独立MariaDB/API及APP实物E2E；`NOT_PROVEN`为Windows完整受信来源/真实动态ABI、物理时间、OS连续隔离与系统安装必要性。

## 5. 独立终态和下一Owner决策

**`28994EA4_BOUNDED_CENTRAL_VC_SOURCE_AND_FAIL_CLOSED_STOP_ACCEPTED_WITH_OBSERVATIONS / PUBLISHER_EVIDENCE_GATE_CLOSED / COMPOSER_LOCK_PENDING / PHP_API_DB_NOT_RUN`**。

AC01–11仍10 PARTIAL/1 OPEN（AC05 RTC），`V10.1.5_PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`不变。

下一步的**优先分支是修正证书信任取证**：冻结同一具名中央DLL，保留已有两次原始观测，只读复核现有LOCAL_ONLY证书链，并针对微软最新CA变化使用官方信任API而非固定显示名。若还需要新实际观察，必须由Owner明确独立次数和工作面；以完整签名/版本/OS映像身份链成功后，才继续真实PHP及Composer供给，运行器本身须落实独立中央VC加载分支和不弱化private DLL门。**不推荐基于当前证据直接重装/repair同版本中央库**；安装/repair涉及系统共享组件、UAC及潜在不可逆变更，必须另由Owner明确选择、预算及恢复边界，不能在此裁决中自动授权。避免重复已完成的PHP官方ZIP/旧Laravel静态审查及历史ACL微任务。

仅归档本独立裁决，**不合并产品main、不签整版FUNCTION_ACCEPTED、不自动派发新任务；STOP等待Owner**。
