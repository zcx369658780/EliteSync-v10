# OS Catalog、最小导入与条件式Laravel12验证结果｜2026-10-30

**PARTIAL_WITH_EXPLICIT_OS_CATALOG_OR_NATIVE_GATES / AWAITING_ASTRA_REVIEW。**

本轮已真实解决iphlpapi、wldap32、secur32、normaliz的具名Windows来源资格问题：普通导入递归23件文件均取得受支持的嵌入或Catalog成员签名、可信时间戳及严格cache-only撤销证据。**完整PHP原生闭包仍未成立**：第二次观察在API-set schema解析器处失败，且未在解析前保存schema原始字节，2/2观察已耗尽。本轮没有PHP Popen、Composer、Laravel Feature或API/MariaDB运行，不声称生成Laravel12锁或真实PHP加载。

## 1. Authority与来源

- 唯一正式任务Blob `5ac1777d3f9cac6e414208a9a9e1a9bbb36a61b0`；开工及交付准备fresh main `24e5a96e7b2c1fc0437aa76417ff08e6aae3ab06`，Root `3b10f72a78eb320caaf4e54c916a1eafa76dabf8`，ACTIVE_STATE Blob `68022cd6af4c32562931805c9c52856b9a4678db`。任务和ACTIVE_STATE在main的path/Blob身份已分别核对，不使用本地draft作为合同。
- 唯一研发Parent `14e6cde7b714c5bacdeedeb87233345d36a435c5`，Root `d716ca18fac3ea2e992346355eabf64b4bfb4043`，apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `4dbf710d64cf12ca513c4747bf53b7d73d5cfe1a`。Astra独立验收Blob `4393e0bb295884d6882be16da163e2c63854282b`已读取；不使用审查分支作Parent。
- 工作流Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`、AC矩阵及原15场景保留。754件具名后端/工具源码导入新工作面，并逐件匹配Parent Blob。
- 上轮中央VC原证只读复用，不重做信任观察。具名中央vcruntime140版本14.51.36247.0、Hash `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`仍是独立中央pin；只在本轮观察内复绑当下文件身份/Hash。旧2/3额度没有移入本轮。
- 官方PHP ZIP Hash `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`重新核对后复制13个固定成员至新私有根，exe Hash `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`保持。没有重新下载PHP、复制系统VC或使用旧vendor。

## 2. 第一次观察前完成的最小分析与负例

`pe_dependencies.pe_info`现在分列ordinary与delay，并保留兼容的imports并集；私有PE不因系统可选delay目标放宽路径规则。`minimal_imports.minimum_private_graph`从php.exe及5个必需扩展出发，仅递归私有普通依赖，证明13个私有成员、13个普通具名OS种子；PHP侧delay边为0。

种子为kernel32、shell32、ws2_32、advapi32、crypt32、iphlpapi、normaliz、secur32、wldap32、bcrypt、dnsapi、ole32、user32。每个种子保留归档PE中的具体普通导入路径，四个历史缺口均由php_curl普通导入直接证明必要。API-set名称单列为合约，不假定存在同名文件，也不以延迟加载标签放行实际镜像。

首次新OS观察前已完成229项纯检查，含错成员hash/tag、错路径、证书链/EKU/签名策略/可信时间/撤销失败、文件/catalog交换、可选delay不能冒充强制、未知实际模块拒绝；还使用真实惰性PE双目录fixture验证ordinary/delay拆分，使用API替身验证WinTrust接收的同一成员句柄/hash/tag与Catalog枚举耗尽/提前退出释放。此前224项批次和全部原始回执保留。

## 3. 第1/2次观察：23件普通文件与Catalog成员真实证据

本次在完整PREPARE+fsync后，沿13个种子及其递归**普通**PE导入读取，未列举System32/WinSxS目录、未查询其它进程、未沿旧105候选重做信任。最终23件具体OS DLL全部合格；OS自身405条delay边只记录，不查询、不当作强制启动条件。

| 具名问题 | 本次实际证据 |
|---|---|
| iphlpapi.dll | 嵌入WinVerifyTrust=0；签名者和timestamp countersigner来自成功provider state；按其可信verify-as-of时间检查代码签名链/时间戳策略，严格cache-only撤销通过，未ignore expiration |
| wldap32.dll | 原嵌入路径`0x800B0100`保留；SHA256 CatalogAdmin成员查询→Catalog文件身份→WinVerifyTrust catalog-member选项成功，可信时间戳和链策略通过 |
| secur32.dll | 同样由Catalog成员路径取得合格证据；未把文件Hash或catalog合法分别当作整体PASS |
| normaliz.dll | 同样由Catalog成员路径合格；member handle、member tag、计算hash、规范路径及前后身份绑定 |

23件中19件通过嵌入路径，4件通过Catalog成员路径；第4件Catalog文件为普通递归所必需的dsparse.dll。每个结果固化成员FileId/Volume/Size/Hash、规范路径、只读持有句柄、catalog本体身份、成员hash/tag、完整链DER、代码/时间戳EKU、API返回和dwError、Microsoft应用或产品根策略、撤销freshness及cache-only限制；原件全部LOCAL_ONLY。

`windows_os_trust.py`真实调用CryptCATAdminAcquireContext2/CalcHashFromFileHandle2/EnumCatalogFromHash、CatalogInfoFromContext和WinVerifyTrust。Catalog来源由现有只读索引返回，绑定API系统目录下的实际catalog；没有CatalogAdd/Remove、catdb、安装、更新或根证书写入。枚举句柄生命周期按Microsoft SDK与官方CodeSigning样例处理。没有固定显示名/issuer/指纹白名单，没有忽略expiry/revocation、test root或未知DLL放行。

代码签名与timestamp链分别用受支持策略；verify-as-of只取成功WinTrust provider，不取文件时间或任意输入。当前原证显示counter signer及code/timestamp链全部通过。这里的通过只指观察时本机cache-only状态，不升级为在线撤销确证、所有Windows文件可信或实际PHP ABI。

第1次收据使用`OS_CATALOG_AND_MINIMUM_IMPORT_PROVEN`标签仅覆盖该轮**具体普通文件子集**。综合结果明确收窄：仍须解决API-set到真实宿主的完整映射，不能以此标签提前认定全部原生闭包已闭合。

## 4. 第2/2次观察：schema解析失败与执行责任

Microsoft官方资料说明API-set是合约，由当前设备schema解析为宿主DLL。为避免api-ms-win-crt等普通导入在启动前被静默跳过，第2次额度用于具名ApiSetSchema来源和这些普通合约的宿主解析；原23件来源只重绑身份/Hash，没有重做23件完整证书调查。

本次ApiSetSchema具名文件的嵌入签名、可信时间戳和严格链/撤销检查已合格，但版本化本地字节解析器在`API_SCHEMA_HOST_PATH`处返回错误，captured=1，未继续查询宿主文件。**这是解析器资格和取证实现失败，不是Windows损坏、恶意文件、VC缺失或必须安装的证据。** 原始失败/traceback及schema签名/FileId/Hash原证完整保留。

本轮没有在parse之前落盘schema原始PE字节。因此确切触发值及最终宿主映射仍`NOT_PROVEN`，不能借第二次成功的签名证据声称解析成功，也不能在观察2/2用尽后补读文件。这一顺序错误由本轮执行负责，不归咎Owner环境、不退款、不另建根。

后续只修源码并作纯合成检查：未选择的schema记录不再被全局强加DLL宿主后缀；真正选中的普通合约仍严格拒绝路径、空宿主、歧义、非DLL/未知映射。新增`archive_then_parse`将同Hash输入通过durable回调存原字节后才检查/解析，持久化失败不得继续。该修复只有合成证据；**没有重读实际schema，所以没有证明它已修好本机失败**，不把“可能涉及未选中kernel host”的合成例子当作实际原因。

## 5. Native工具与安全门实装

本任务绑定独立task Blob、14e6 Parent、唯一工作根和原ledger。延续中央VC、普通Windows映像、13个官方private成员三类隔离，private hardlink/reparse/路径保护不变，中央vcruntime不进入通用os_import。`msvcp_win.dll`作为确切已签名普通Windows映像与未资格的msvcp140等额外VC区分；它不允许私有副本冒充。

`current_native_task.execution_gate`只把普通导入当作prestart条件；任何实际已加载delay/未知文件仍受原native镜像守卫严格拒绝。新API-set门要求有签名/身份绑定且已归档的schema原字节，并从实际Hash/身份绑定OS PE重建递归ordinary/API闭包，与完整模块/边集合匹配；缺归档、删边或漏宿主不能用PASS字符串替代。源代码审查指出的可省略OS边问题已修复并有负例；STOP标记在任何系统读取或Popen之前拒绝。

原PHP CLI/API nonce、原child handle、PID/创建代际、source/Manifest、映像Hash、真实退出及失败流保存接线继续保留。PHP侧当前任务绑定/历史关闭集合同步更新；业务入口仍要求真实Laravel12 lock/vendor和独立数据库资格。**本轮没有启动PHP，也没有执行PHP语法检查来证明这些PHP修改可运行。** 无DB不依赖业务锁的分层保留，但缺OS/API-set闭包时必须先拒绝。

## 6. 测试、成本与明确未运行项

最终Python纯检查**247/247，failed0/errors0/skipped0，exit0**，输出SHA256 `fa0fe8a037e97cfd02ef61fd735e32a27d5847e197b561708546028bd9a3e6a6`。8批真实执行分别为224、229、236、239、241、246、246、247项，均exit0；批次不是独立用例数累加。所有Popen/socket/system/startfile/实际模块枚举被拒绝或合成替身替代，纯测试不能当作真实加载。

| 操作 | 本轮实际 / 合同上限 |
|---|---:|
| 具名新OS来源观察 | **2/2，已耗尽** |
| 新中央VC信任调查 | **0**，复用上一已接受原证 |
| PHP CLI / 无DB Probe | **0/60、0/2** |
| Composer PHAR / 包与metadata / HTTP | **0/8MiB、0/256MiB、0/240** |
| Composer求解 / vendor安装 | **0/2、0/1** |
| Laravel12 Feature | **0/3** |
| MariaDB / API启动 | **0/2、0/2** |
| 业务HTTP / migration / seed | **0/160、0/1、0/1** |
| PHP下载 / VC复制或安装 / 系统写入 | **0** |
| Flutter/Dart/Gradle/G2/APK/设备/RTC/Push | **0**，未授权 |

只有本任务独立根、attempt-0001和持久ledger；所有观察/成本动作前PREPARE+fsync。空间/单调时间实测见Manifest和最终LOCAL_ONLY terminal回执，限8GiB/120分钟；未更换根或重领余额。阶段STOP后未再读系统来源、运行任何PHP或开启供应。

交付准备还保留本地文本helper的GBK解码失败与旧246数量断言失败；已显式使用UTF-8、保持Parent README原字节前缀并同步最终247收据。这些打包失败未启动任何被测软件，不修改观察或运行额度。

旧Composer lock仍Blob `66327f584d3961c2b53391bb012047dda9cc9d23`、Laravel11.48.0，LOCK_RESOLUTION_PENDING。可信PHAR、供应进程/网络守卫、solver、vendor和Laravel12业务都未达到本轮动态资格；不伪造content-hash、版本或RESOLVED，不把旧23 Feature/77 Widget搬作本轮结果。原15业务场景全部NOT_RUN_GATE_CLOSED，无HTTP状态/DB计数/事务/服务重启回执可提供。

## 7. 保护、来源清单与出口

受保护dirty根和527既有refs摘要前后相同；五个具名旧任务根身份及其ledger/hash/terminal/completion摘要保持。旧18件、两ACL树、122原证、五根、3183 Seed等沿已保存保护回执传递，未重新扫描或声称逐对象重验。没有ACL/旧数据/历史SDK/数据库/claims/ledger清理或改写；永久保留历史跨尝试ACL超限及RESTORATION/RESTRICTED_IDENTITY/OS_ENFORCEMENT未证明状态。

F1/F3/F4产品业务、Flutter apps、原15场景和旧业务测试原字节保留；变更仅限必要非生产资格工具、E2E资格绑定/测试及本报告。SOURCE_PROVENANCE逐项如下：

| path | Parent Blob | 本轮 Blob |
|---|---|---|
| `services/backend-laravel/tests/E2E/MainlineEnvironment.php` | `69441d9247c18184e6a3688089290f45d049f5df` | `1200f970f48f4901e931d2f7caac56bd08a1537f` |
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `e267877595a611b09b677845c6ecf85eeabcf511` | `297b383fcf6f4f65c208da05b022eb5f60566310` |
| `tools/v1015/mainline_e2e/README.md` | `2582be1ec6a5f6f0dfceb08051c5e8b459d2a15c` | `ddb7bfab0f0a2241070485f166f73270a9bb22e3` |
| `tools/v1015/mainline_e2e/api_set_schema.py` | `NEW` | `84bc3ded06a3f9def16b8c9c5595e9b75447fc92` |
| `tools/v1015/mainline_e2e/current_native_task.py` | `af070f41ea6b8eaebde8456ceeb61af9b109fbea` | `9a092b078fe93bcac1ab2a424340f307288de04b` |
| `tools/v1015/mainline_e2e/minimal_imports.py` | `NEW` | `00d8d26cabaf02d206e3210a5f91ec1737e3ccc5` |
| `tools/v1015/mainline_e2e/os_images.py` | `7949c647e50d3ab68b9162b8cc7887aa68b90375` | `fce2f5388ca9e8e9a12cf8f2c6ea6fcd5c4a1e89` |
| `tools/v1015/mainline_e2e/pe_dependencies.py` | `c379dd5b377c39e3b9b1f4aaeb3521d309a0259d` | `adc3dce21faa3dc96d8fd9acbc23ef10a5d1f5bc` |
| `tools/v1015/mainline_e2e/php_probe_entry.py` | `d4fbf158a92058ac746ac6a3e9e899b799c12e33` | `b1c866180b0a27f25c44b50bf4a5b15f9624c136` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `5e83e7382ea1c7867861a5c78aa25337b36796ec` | `3fa2d2e4442fd26e09119647ba86d1c2e46ee890` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `72c7a89f7136bc13cfc4ffb86760551501888bee` | `4f704667d5832f3661157948dbad84a29c7cc471` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `bbb4b9321c6aae16a086d719042069eac4a0e41c` | `232fb430da17d1ad71583f2caec60d9f26eb1173` |
| `tools/v1015/mainline_e2e/test_api_set_schema.py` | `NEW` | `1b6cd057f2a1ec6243d56331f2c694212efd69f3` |
| `tools/v1015/mainline_e2e/test_native_minimum_closed_gate.py` | `NEW` | `d212df529f58a32a6d242a060cc39737351d3725` |
| `tools/v1015/mainline_e2e/test_os_catalog_api_doubles.py` | `NEW` | `0fa2d443b8f7779074f7e85f40a1cb18ac15d362` |
| `tools/v1015/mainline_e2e/test_os_catalog_minimal.py` | `NEW` | `d2ad99d9ec1b879fa76308ba804b9bb29cfe511d` |
| `tools/v1015/mainline_e2e/windows_os_trust.py` | `NEW` | `bbffd828370178166c17cd0363c2de3d6a6d10c4` |

`DIRECT_GITHUB_OBJECT`只指远端对象与原字节身份；`CODEX_REPORTED_LOCAL_TEST`指本机有界观察/纯检查，Astra未在本机重演；证书/catalog、系统路径/PID/FileId、原始输出、ledger及二进制均`LOCAL_ONLY_RAW`；PHP真实加载、完整API-set闭包/ABI为`NOT_PROVEN`；Composer/Feature/API/DB为`NOT_RUN_GATE_CLOSED`。

一次集中后续Owner需求应仅覆盖：具名schema原字节先存后验、被实际普通导入选中的宿主映射与签名/身份，以及仅在完整资格成立后的新独立PHP/Composer/DB预算。不要重复23件已合格签名或中央VC调查；禁止安装/更新/忽略错误。本轮未创建下一任务、未申请或执行系统安装。

本候选仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11仍10 PARTIAL/1 OPEN。GitHub发布后回读sole Parent、Root、全部path/mode/Blob原文、完整双产品Tree与fresh main；最终身份留完成回执，报告不自指尚未存在的Commit。唯一候选完成后STOP，等待Astra独立验收。

## 官方资料

- https://learn.microsoft.com/en-us/windows/win32/api/mscat/nf-mscat-cryptcatadminacquirecontext2
- https://learn.microsoft.com/en-us/windows/win32/api/mscat/nf-mscat-cryptcatadmincalchashfromfilehandle2
- https://learn.microsoft.com/en-us/windows/win32/api/mscat/nf-mscat-cryptcatadminenumcatalogfromhash
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/ns-wintrust-wintrust_catalog_info
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/ns-wintrust-crypt_provider_sgnr
- https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/ns-wincrypt-authenticode_ts_extra_cert_chain_policy_para
- https://learn.microsoft.com/en-us/windows/win32/apiindex/windows-apisets
- https://github.com/microsoft/Windows-classic-samples/blob/main/Samples/Security/CodeSigning/cpp/codesigning.cpp
- https://github.com/microsoft/win32metadata/blob/main/generation/WinSDK/RecompiledIdlHeaders/um/mscat.h
