# EliteSync v10.1.5｜f16d4cda Laravel12/PHP8.5可信供给 Astra独立验收｜2026-10-30

**正式独立裁决：`F16D4CDA_BOUNDED_OFFICIAL_SUPPLY_AND_STATIC_SOURCE_ACCEPTED_WITH_OBSERVATIONS / APP_LOCAL_VC_RIGHTS_AND_TOOLSET_NOT_QUALIFIED / LOCK_RESOLUTION_PENDING / PHP_LARAVEL_API_DB_RUNTIME_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本审查通过GitHub连接器直接读取固定候选、单父、Root/两产品Tree、compare的10项变更、全部非自引用Git Blob、源码门禁及报告/Manifest，并独立参照PHP与Microsoft官方说明。**没有**读取Owner Windows原始二进制/证书/日志/ledger或重新运行PHP、Composer、Laravel、MariaDB、Flutter，因此不签任何动态运行PASS。只在Astra独立审查分支归档，产品main保持原状。

## 1. Authority和对象

- Owner正式任务：`docs/versions/v10.1.5/V10_1_5_LARAVEL12_PHP85_TRUSTED_SUPPLY_LOCK_AND_CONTROLLED_API_DB_E2E_TASK_20261030.md`，任务Blob `5f1c709e31af0d4f2c1c93363c147942db7116c5`；本轮仅允许具名官方私有供给和满足安全资格之后的有界软件运行。
- 候选 `f16d4cda817282d935cb53ce399d26a7850381a1`，sole Parent `e93ef51401f4e25916149cca104f09debc32bc78`，Root `eb4045b343749b7f3fceb46121100fa946b92329`；compare ahead1/behind0。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，与Parent完全相同；services Tree `120177c9f35905190972be7bbcb3dfdda95ba776`。10项变更路径与Manifest完整一致，固定候选GitHub路径直接校验9项非自引用Blob **9/9通过**；Manifest本身Git Blob `7fec479f5b902da6b69fd3d3ba4b41164fc9c25c`，其内部没有循环自签。
- 正式Codex交付报告 `docs/versions/v10.1.5/L12_PHP85_TRUSTED_SUPPLY_AND_CONTROLLED_API_DB_RESULT_20261030.md` Blob `917baca1de522e0e8c1fa57e5c67232c974f7922`；Manifest `docs/versions/v10.1.5/l12_php85_trusted_supply_and_api_db_manifest_20261030.json` Blob `7fec479f5b902da6b69fd3d3ba4b41164fc9c25c`。
- Fresh main HEAD `06af7fb2e7a7db2953cefeefcfb819eb81d02ac2`，Root `7bb00f0130255cb355ff602e9dad8290baa4342b`；main唯一已接受v10.1.4产品 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，没有产品main集成。

## 2. 有界接受的供给事实和源码改动

### A：官方PHP发行材料

Codex报告从PHP官方archive取得单个 `php-8.5.12-1-nts-Win32-vs17-x64.zip`，36,310,917 bytes，历史发布与本地校验SHA256 `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`一致，SPDX两份元数据受控读取，安全解包78文件。其本地静态PE/Hash摘要说明13个具名必要归档成员均为x64，`php.exe` SHA256 `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`；cURL导入的非OS依赖及所需本地闭包列明，缺`vcruntime140.dll`。Astra独立官方网页确认**PHP8.5.12-1 VS17 x64 NTS发行项真实存在**；这些ZIP实际字节、exe Hash、PE闭包来自`CODEX_REPORTED_LOCAL_TEST`，不是本次Astra亲自下载验证。

新版`tools/v1015/mainline_e2e/php_requirements.json`已经如实保存各类归档Hash/来源，并将`reference_executable_sha256`从null更新为上述已报告exe Hash；仍标`DEPENDENCY_SUPPLY_PENDING`。不能把归档Hash当exe Hash，也不能把静态已取得当做实际PHP模块已加载。

### B：官方Microsoft VC原始包

Codex报告已取得Microsoft官方重定向链的VC x64 v14原始包，18,731,856 bytes，SHA256 `843068991daaa1f73ad9f6239bce4d0f6a07a51f18c37ea2a867e9beca71295c`，PE FileVersion `14.51.36247.0`，WinVerifyTrust **cache-only离线验证**返回0；但这不是本轮联网吊销查询。当前不存在已核实际payload的单DLL app-local许可、Owner授权权利链、准确PHP编译工具下限和完整native映像握手。**没有提取DLL、安装或运行PHP**，Codex严格保留`REDISTRIBUTABLE_NOT_QUALIFIED`，可接受为按合同正确STOP。

独立微软官方资料：https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files 和 https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist/ 确认：app-local单DLL部署技术上可行，但再分发受许可条款/持权条件限制；微软优先推荐集中安装进行维护，且运行库不能早于真实构建工具版本。不能将“Microsoft签名有效”和包版本高于PE linker=14.44，自动推断Owner拥有单DLL再分发权或PHP ABI已证明。此风险是**尚未证实资格**，不是已实测加载失败或侵权事实。

### C：关闭运行资格与Supplier源码

- `tools/v1015/mainline_e2e/supply_preconditions.py`新增明确只读的`SUPPLY_ONLY_COMPOSER`事实合同，专门避免“先有Laravel12 lock才能解析Laravel12 lock”的循环，拒绝未授权task、错误Parent/apps、scripts/plugins/业务bootstrap、DB配置和未具名网络来源。它只返回`STATIC_SUPPLY_INPUT_FACTS_MATCHED_ONLY`并明确`runtime_authorized_by_this_check=false`；**没有实现真实Composer启动器**，不能把该合成契约视为已能合法运行Composer。输入proof包含可信operator布尔和SHA文本，真正执行时仍需来源原证、进程/文件闭包及独立授权。
- `php_runtime.py`和`PhpRuntimeQualification.php`继续使旧任务及当前已结束任务不得复用PHP真实运行权限；真实Laravel12/DB/API需`composer_lock_state=RESOLVED`、合格VC来源及PHP exe/Native完整Manifest。旧`composer.lock` Git Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍是Laravel11.48.0，`composer_evidence`仍说明为历史11源码，绝不能随意改`RESOLVED`字段。无新vendor，也无Laravel12实际求解。
- test代码新增13个纯合成供给拒绝/分层用例，Codex报告**132/132、exit0**，历史119套件仍运行；Astra独立审查源并确认它们不执行PHP或网络，不能将“测试数”当产品进度。准备阶段一次源URL严格相等比较失败，Codex保留错误并利用同一具名release/SPDX证据复核，未自动更换未授权源。

## 3. 本轮预算与未运行范围

报告显示PHP ZIP 1/1、元数据2/3、VC包1/1；12次HTTP请求总response body 55,751,164字节（**不含HTTP header/TLS开销，不能冒称全部线缆字节**）；Composer网络0/240、求解0/2、vendor安装0/1；PHP CLI与无DB Probe 0、Feature 0/3、MariaDB 0/2、API 0/2、业务HTTP0/160、迁移/seed均0；Flutter/G2/APK/设备/RTC/Push均0。APP端到端E2E及真实模块加载全部`NOT_RUN_GATE_CLOSED`，不推断HTTP/DB状态或生产可用性。所有消耗/旧保护状态是Codex本地回执与GitHub脱敏报告，不是Astra在Owner机器重演。

历史Flutter6/6和3bed3/3、MariaDB2/2、G/APK1/1及ACL超额事故和旧18、两ACL树、122原证、五保护根、527refs、3183 Seed、旧原始失败/账本/claims/dirty持续原状态；不能用新任务未消费预算在STOP后自动延续。保持`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`，不重做历史ACL/Hash专项。

## 4. 有界裁决与下一实际门

**`F16D4CDA_OFFICIAL_PHP_ARCHIVE_AND_VC_PACKAGE_BOUNDED_SUPPLY_EVIDENCE_ACCEPTED_WITH_OBSERVATIONS / NATIVE_VC_APP_LOCAL_LICENSE_NOT_QUALIFIED / TOOLCHAIN_MINIMUM_NOT_PROVEN / COMPOSER_LOCK_PENDING / PHP_LARAVEL_API_DB_E2E_NOT_RUN`。**

本次没有发现需要在当前候选内重写F1产品代码的确定性缺陷，但既无Laravel12 lock也无真实PHP/App API/DB测试；因此版本仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11仍10 PARTIAL/1 OPEN。

下一Owner决策应**集中而非微任务**处理：取得准确适用的Microsoft v14许可/可用部署方式及已核原生DLL版本和合法来源，或者选择在严格受控、可回退环境下使用官方系统级Redistributable installer（这需要新的显式系统安装授权，本轮未批准）；核PHP真正MSVC工具链下限及Composer PHAR来源，形成一次合规依赖/真实lock/无DB Probe/API+MariaDB授权。Microsoft官方安装路径在长期维护上优于app-local，但不得未经Owner决定实际安装。新任务仍需另行冻结独立真实运行预算及Hash。

**本轮只发布独立审查报告；不修改产品main，不自动发布后继任务，不签整版FUNCTION_ACCEPTED。STOP等待Owner。**
