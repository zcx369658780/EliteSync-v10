# 中央VC信任链、真实加载工具与条件式Laravel12验证结果｜2026-10-30

**PARTIAL_WITH_EXPLICIT_TRUST_NATIVE_OR_SUPPLY_GATES / AWAITING_ASTRA_REVIEW。**

具名中央VC文件的支持式Windows信任检查已真实通过：`CENTRAL_VC_EVIDENCE_QUALIFIED`。Python/PHP原生资格工具已实装独立中央VC加载分支和本任务无DB探针入口，但**真实PHP加载仍NOT_PROVEN**。启动前检查实际拒绝未资格化的直接OS依赖；PHP、Composer、Laravel Feature、API和MariaDB全部未启动。没有生成Laravel12锁，也没有把合成检查升级为动态通过。

## Authority与固定来源

- 正式合同Blob `960a738505054ac97a8cb85df660bf4f0b6decc9`；开工及交付准备fresh main `fb04ac80863bae9b2a9c2c00ea7eb11d4015f107`，Root `cf81b68a19f2f48e8fda901497592f2ea0445a30`，ACTIVE_STATE `7a714aec0dcea560331b6d552cc849290f4ba1f9`。
- 唯一Parent `28994ea486eccc5191985c57952a61f6f7ab3d38`，Root `ad7150eeb6996adbdf22ea4f4560d58afb9c71d4`；apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `4c01326cbf44b4705548e97221e3336e0448406f`。Astra独立验收Blob `c3af499789923013c7237bdeb81ff291a6059c9c`。
- 当前工作流Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`，派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`，冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`均已读取。748件导入源码逐件核对Parent Blob；未采用其它候选整树。
- `DIRECT_GITHUB_OBJECT`指远端对象身份；本机API观察和纯检查为`CODEX_REPORTED_LOCAL_TEST`。原证、证书DER、文件/进程身份、本机路径、原始输出和账本为`LOCAL_ONLY_RAW`。本报告不是Astra独立重演或整版接受。

## 中央VC观察：2/3，历史额度未退款

| 观察 | 实际结果 |
|---|---|
| 1 | WinVerifyTrust=0，严格cached-revocation链error=0，code-signing EKU成立，Authenticode策略error=0；OID7默认产品根策略返回`0x800B0109`，据实NOT_QUALIFIED |
| 2 | 先核对官方SDK和纯负例，再使用OID7应用签名根flag `0x00020000`；API true、dwError=0；WinVerifyTrust、链及Authenticode均成功，CENTRAL_VC_EVIDENCE_QUALIFIED |

微软SDK明确区分产品根与应用签名根。修复使用受支持的应用根策略，未使用test root、ignore错误、显示名/issuer/thumbprint/serial或算法白名单放行。第一观察失败原件完整保留，第二次不是抹除失败。严格缓存撤销检查、不联网更新根或获取撤销对象；未知撤销仍拒绝。第二次链3证书、1 simple chain，撤销freshness为912秒。该证据只覆盖观察时本机缓存状态，不宣称在线撤销取证。

目标版本14.51.36247.0、x64、178616 bytes、links=1，SHA256 `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`。API系统根、只读持有句柄、规范路径、FileId/Volume和前后Hash稳定。没有主动LoadLibrary加载VC、没有复制系统DLL、没有installer/repair或系统配置变更。此次中央观察不是PHP模块加载观察；精确compiler最低版本和动态ABI仍NOT_PROVEN，PE linker14.44不替代该证明。

## 已实施的实际工具接线

`windows_vc_trust.py`真实调用WinVerifyTrust、CertGetCertificateChain、CertVerifyCertificateChainPolicy，保存API返回与dwError、EKU、严格撤销、时间和完整证书链；原始DER只留本机。`central_vc_loader.py`在使用前及实际模块映射时重新绑定系统根和中央文件身份。

`php_runtime.validate_manifest`仅对确切vcruntime140使用独立中央pin；没有扩大泛化os_import。私有文件必须匹配官方PHP归档13个固定成员，不能用私有同名VC或其它redist冒充。`os_images`先走中央分支，额外未资格VC模块拒绝；普通OS只读规则与private hardlink/reparse保护分别保留。

`php_native.cli/api`在真实Popen路径使用原child handle和创建代际、存活状态、nonce及Manifest进行观察/receipt绑定，要求中央和所有扩展实际出现；PHP `nativeReceipt`核对同样的三分类和身份。这是已接线源码，**本轮没有启动它来取得PHP动态PASS**。

`current_native_task`和探针入口只接受本任务精确Blob/Parent/工作根，执行前核对原ledger、120分钟单调窗口、Probe2次/30秒、CLI60次上限和直接OS依赖的实际文件/签名来源pin。无DB分支独立于旧Laravel11锁；它不能授权DB、Laravel/bootstrap、网络或Composer。业务入口仍要求真实Laravel12锁/vendor与独立DB身份，未删除负向业务门。

握手、映像守卫或加载失败会保存原stdout/stderr及真实退出码。独立只读源码审查发现的预启动OS pin仅查名称问题已修复：现在在Popen前校验实际文件Hash/FileId/Volume、签名资格、source_class和系统根；静态source匹配与loaded证明明确分离。复核无剩余P1/P2；这不是Astra最终验收。

## 原生阶段实际阻断与失败保留

归档Hash核验后，仅将官方PHP包13件已具名成员复制到本任务私有目录；未重新下载PHP。纯静态Manifest检查返回STATIC_PRECONDITION_OK，实际调用本任务预启动门返回：`NATIVE_OS_IMPORT_NOT_QUALIFIED:iphlpapi.dll`，Popen=0。

具名OS来源检查还发现wldap32、secur32、normaliz文件路径WinVerifyTrust为`0x800B0100`且未取得所需签名者链；iphlpapi的WinVerifyTrust=0但独立链error=1、Authenticode时间错误`0x800B0101`。**这些是当前取证路径不足，不证明系统损坏、文件恶意或需要安装VC。** 本轮没有实现受支持的catalog签名/可信时间戳链资格补充，也没有忽略错误或把缺证据直接当PASS，因此完整PHP原生闭包未成立。

OS检查只沿具名PE依赖/旧固定pin读取，不枚举System32/WinSxS目录、不枚举其它进程。初始递归过度纳入optional系统delay-import，后收束为已具名文件集合；105个候选、65个合格pin、40个未合格，均只作静态来源证据，不能声称105模块实际加载。四次静态检查执行记录、NameError、PE_IMPORT_PATH_REJECTED以及optional wpaxholder缺失原始失败均保留；不计作中央VC新观察或PHP进程。递归检查设计范围偏宽，本报告明确保留该实现限制，不以此放宽任何运行门。

只有中央信任通过而原生闭包不通过，不能进入Composer供应阶段。可信PHAR、供应启动器/网络守卫、真实solver、vendor及业务阶段均未运行/未在本轮证明可执行。旧Composer锁仍Laravel11.48.0、Blob `66327f584d3961c2b53391bb012047dda9cc9d23`，LOCK_RESOLUTION_PENDING；content-hash未改写，未生成假锁。

## 实际检查与预算

最终Python纯检查**193/193，failed0/errors0/skipped0，exit0**，输出SHA256 `2ef88351b008dda6ec89f0836766e5d99c4affd4243637f38323a81c75e6683f`。前批次169、171、171(1 fail/1 error)、188、191、193(2 fail)、193依次保留；193是最终独立用例数，不把多批累加当独立测试。Popen/socket/system/startfile/真实模块枚举使用拒绝或合成替身，3个启动失败用例仅用内存假进程。PHP测试源已同步source_class契约，但PHP语法和PHP合成测试全部NOT_RUN，不冒充已编译通过。

| 操作 | 实际 / 上限 | 证据层级 |
|---|---:|---|
| 新中央VC观察 | 2/3 | CODEX_REPORTED_LOCAL_TEST，完整原证LOCAL_ONLY_RAW |
| PHP CLI / 无DB Probe | 0/60、0/2 | NOT_RUN_GATE_CLOSED |
| Composer PHAR / 包流量 / 包HTTP | 0/8MiB、0/256MiB、0/240 | NOT_RUN_GATE_CLOSED |
| Composer求解 / vendor安装 | 0/2、0/1 | LOCK_RESOLUTION_PENDING |
| Laravel12 Feature | 0/3 | NOT_RUN_GATE_CLOSED |
| MariaDB / API启动 | 0/2、0/2 | NOT_RUN_GATE_CLOSED |
| 业务HTTP / migration / seed | 0/160、0/1、0/1 | NOT_RUN_GATE_CLOSED |
| 系统DLL复制 / VC安装 / 全局安全修改 | 0 | 未执行 |
| Flutter / Gradle / G2 / APK / 设备 / RTC / Push | 0 | 未授权、NOT_RUN |

同一task_id和attempt-0001、同一持久ledger；未重建根或重新领取预算。报告时空间和单调时间见Manifest，最终本机terminal回执另封存，均须小于8GiB/120分钟。

## 保护、差异身份与后续门

受保护dirty根和527既有refs逐字节摘要前后相同；四个具名旧任务根FileId/Volume及其原ledger/hash/terminal/receipt摘要一致。122原证、五保护根、旧Seed、旧18件/两ACL树沿具名历史保护回执传递，本轮未重新扫描或声称逐对象重验；没有ACL写入、删除、重建、历史清理或预算修改。永久保留PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT、OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN、RESTRICTED_IDENTITY_GATE_BLOCKED、OS_ENFORCEMENT_NOT_PROVEN。

F1/F3/F4生产业务源码、apps树、原15场景和业务Feature保持Parent原字节。变更仅为必要非生产资格工具、测试及说明；完整变更来源如下。

| path | Parent Blob | 本轮 Blob |
|---|---|---|
| `services/backend-laravel/tests/E2E/MainlineEnvironment.php` | `455aa1afd8877d0bc6fbdd17cfcd755c861360f6` | `69441d9247c18184e6a3688089290f45d049f5df` |
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `5ad2dbe3677a5a75491f8f63685bec6c56030f05` | `e267877595a611b09b677845c6ecf85eeabcf511` |
| `tools/v1015/mainline_e2e/README.md` | `b241f67f862fbf3d3b1e40d22e7b8400ee7478d6` | `2582be1ec6a5f6f0dfceb08051c5e8b459d2a15c` |
| `tools/v1015/mainline_e2e/central_runtime_preconditions.py` | `f07d17c7f855eb971761c0e6b0dfc491c5760825` | `93e313457830089b0722a70545a281ddfb104a77` |
| `tools/v1015/mainline_e2e/central_vc_loader.py` | `NEW` | `2989c010e8af6990b4884893fc5d89062026a544` |
| `tools/v1015/mainline_e2e/current_native_task.py` | `NEW` | `af070f41ea6b8eaebde8456ceeb61af9b109fbea` |
| `tools/v1015/mainline_e2e/os_images.py` | `6d31c90d5911741bdb199533a60d3ff4fbde1210` | `7949c647e50d3ab68b9162b8cc7887aa68b90375` |
| `tools/v1015/mainline_e2e/php_native.py` | `0b642ba96bc96cb938566f08c5650ea7dd884b2a` | `7eb3daf208da0f5c7d861aee628cba839e6052f2` |
| `tools/v1015/mainline_e2e/php_probe_entry.py` | `2b540a79a5ef9d64f1e02294713e2e08c7fde187` | `d4fbf158a92058ac746ac6a3e9e899b799c12e33` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `945de044f389ca18a56b1e273ba26f7950c6b5f7` | `5e83e7382ea1c7867861a5c78aa25337b36796ec` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `29a038a4f2d5d116789075a78c0c0231cf8c27a9` | `72c7a89f7136bc13cfc4ffb86760551501888bee` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `37c4240136a281ade4b7a3af97243f5cbb8c7810` | `bbb4b9321c6aae16a086d719042069eac4a0e41c` |
| `tools/v1015/mainline_e2e/test_central_runtime_preconditions.py` | `e576df715655d6254d77e6959352a8734fe50d83` | `20dce6be54c2b7e5a957bc3d5fc29cb57e8b58d1` |
| `tools/v1015/mainline_e2e/test_current_native_task.py` | `NEW` | `4d4599b75f01ad331d3672f941fb3c6f40054390` |
| `tools/v1015/mainline_e2e/test_native_failure_receipts.py` | `NEW` | `3fe3945d82058e85f4f4c647d878d3cb0a001bf3` |
| `tools/v1015/mainline_e2e/test_native_unblock.py` | `49c5c09318bcc577e1f8a195328849ab20deac8f` | `68cbbd778bc3fd0753f03fd0ca20f05efbf2e25a` |
| `tools/v1015/mainline_e2e/test_php_capabilities.php` | `c4e885a64c80974da27219914474e3f968246973` | `53701c23bcbd91b385201ec14fb5ab8daddc4e12` |
| `tools/v1015/mainline_e2e/test_php_runtime.py` | `5f4c3a27b80f2c34063024f6a8652cf8f2066818` | `a64229dc5cb3679d075775f0bc082dee746ffba9` |
| `tools/v1015/mainline_e2e/test_windows_vc_chain_loader.py` | `NEW` | `a37e0af857002c29239f024eef263f2dc57f35c3` |
| `tools/v1015/mainline_e2e/windows_vc_trust.py` | `NEW` | `75409a863545ebc40ffc03c32800a83ca48afe1c` |

下一最小授权需求应一次集中覆盖：普通Windows OS catalog签名/可信时间戳的受支持验证实现与具名来源复核；之后在新的精确运行授权下验证PHP原生实际加载，再有条件执行已冻结的Composer供应/solver/vendor和API/DB场景。不得用忽略过期、证书名、全局OS例外或安装器求PASS。本轮未创建后继任务，也未自行申请系统安装。

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`全部保留。GitHub最终对象、sole Parent、Root、全部path/mode/Blob、完整双产品树及fresh main回读记录在LOCAL_ONLY完成回执；报告内不自指不存在的最终Commit。唯一候选完成后STOP，等待Astra独立验收。

## 官方来源

- https://support.microsoft.com/en-us/servicing/os/windows/docs/2026/08/next-generation-code-signing
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust
- https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-certgetcertificatechain
- https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-certverifycertificatechainpolicy
- https://github.com/microsoft/win32metadata/blob/main/generation/WinSDK/RecompiledIdlHeaders/um/wincrypt.h
- https://github.com/microsoft/msix-packaging/blob/master/src/msix/PAL/Signature/Win32/SignatureValidator.cpp
