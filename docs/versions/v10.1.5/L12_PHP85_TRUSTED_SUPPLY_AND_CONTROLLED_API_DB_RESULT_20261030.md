# Laravel12 / PHP8.5可信供给与受控API/DB验证结果｜2026-10-30

**`PARTIAL_WITH_EXPLICIT_DEPENDENCY_OR_RUNTIME_GATES / AWAITING_ASTRA_REVIEW`。**

已真实取得并核验官方PHP发行ZIP与微软官方VC原始包，完成静态成员、PE、来源与离线签名调查。**VC app-local具名DLL权利链及新PHP精确编译工具下限仍未资格化，未拆出/放置任何VC DLL，未执行安装器或PHP。** 因此Composer求解、vendor安装、无DB Probe、Laravel12 Feature及MariaDB/API/HTTP均`NOT_RUN_GATE_CLOSED`，没有新Laravel12 lock。不能声称仅下载成功即运行资格成立。

## 1. Authority / SOURCE_PROVENANCE

- 正式任务：`V10_1_5_LARAVEL12_PHP85_TRUSTED_SUPPLY_LOCK_AND_CONTROLLED_API_DB_E2E_TASK_20261030.md`，Git Blob `5f1c709e31af0d4f2c1c93363c147942db7116c5`。开工fresh main `06af7fb2e7a7db2953cefeefcfb819eb81d02ac2` / Root `7bb00f0130255cb355ff602e9dad8290baa4342b` / ACTIVE_STATE `a817469a34e1fcdeb427f059f973fbbd466ff536`。
- 唯一研发Parent `e93ef51401f4e25916149cca104f09debc32bc78`，Root `5941573199ea340a11691ce45cf3ed96282ab5a1`，apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `91611699217d6e9fae7b2ebe03e6023c90e23bbc`。Astra上一验收Blob `158659dc0b0f6b08caeb49dc7978cc298afd23ea`已直接读取，不用Astra分支作为Parent。
- 当前工作流`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议`0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划`7d3466b3be67135dc641cfee7c7faef78937ba03`，以及AC01–11矩阵、原15场景与来源映射已核对。744份后端/工具文件由具名上一任务副本导入，逐件匹配GitHub Parent Blob；旧根没有修改。
- `DIRECT_GITHUB_OBJECT`指固定Git身份/字节与源码事实；本机下载、校验与测试是`CODEX_REPORTED_LOCAL_TEST`，Astra没有在Windows重演。绝对路径、证书原件、二进制、vendor、原始输出及ledger为`LOCAL_ONLY_RAW`。

## 2. 实际PHP供给

当次官方入口 https://www.php.net/downloads.php?os=windows&version=8.5 给出实际archive链接：
https://downloads.php.net/~windows/releases/archives/php-8.5.12-1-nts-Win32-vs17-x64.zip

仅下载一次，**36,310,917 bytes**；当次发布页面、SPDX及实际ZIP的SHA256均为`2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`。两份元数据分别35336、206549 bytes，SPDX SHA256 `5e80c4aa29a39f7825aab34d7fde76c3a277645d47bee21bb00a1af51b3e3cfd`，包许可元数据PHP-3.01。未请求CDX、未下载第二个PHP包。

安全解包78个文件：事前拒绝绝对/遍历/ADS/大小写冲突/链接/Windows保留名及异常展开尺寸，zipfile读取校验成员CRC；每个成员SHA256、本机原路径仅LOCAL_ONLY。没有运行归档脚本。必需PHP/扩展及非OS传递依赖共13成员，其静态PE为x64；PHP exe资源版本8.5.12.0、exe SHA256 `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`，与ZIP Hash明确分开。PHP_ZTS/实际扩展集合/函数类能力仍需真正Probe，不能从发行名提升为运行证明。

| 官方归档成员 | bytes | SHA256 |
|---|---:|---|
| `ext/php_pdo_mysql.dll` | 38400 | `3059312f0f5bd99773909e3d436ae6a36f3ba40e2973d17d3543dbcb6537d191` |
| `php8.dll` | 13923840 | `7f9c2ab08b1668426e4ee0cd571b7012030dad1f99ff435a9efd7b8161c7b086` |
| `ext/php_openssl.dll` | 173056 | `cfe5488a6e6e10856df886bc4d0d8b516179ff9874447d0cf524191b0cdef9b8` |
| `libssl-3-x64.dll` | 1294336 | `7574fc9816458b44dbc61d3a28b2b2200084472765bb995775f671aac19d1972` |
| `libcrypto-3-x64.dll` | 7044608 | `43e20b8c6e3d0d38f184329eacea180be6bdbbdc89871626f1e05c11cbb70fe4` |
| `ext/php_mbstring.dll` | 1624064 | `d7e2cdf80f21fb7a17f76755a6a7cc2e7ad5d6068a9890d77ed3f57917a1c5a0` |
| `ext/php_fileinfo.dll` | 10466304 | `ea85fa94a289146f52abd34c3673f4f3be075c338f1174a0d614448dc241d1ca` |
| `ext/php_curl.dll` | 1094656 | `00b3274ed4d77833fc1d78a995a5fdc98640819bd6a54260fad30056d6ad5436` |
| `nghttp2.dll` | 227840 | `4bee6c3aa3270c49395ff528db1ebd1e3d78c211503a7b9ea6c23aa9ad2dec85` |
| `libssh2.dll` | 419840 | `7dc5903164aec91f4cff6f7f6d56ed5f43e91e5dc3c14ec81c18d63253f6ecfc` |
| `brotlidec.dll` | 92160 | `3ff248840797380f91573c26f072b1173de3ac29bc2565c96b73c68c8d9d386f` |
| `brotlicommon.dll` | 188416 | `f9b7155a0a965fe6e07aa32034329f25abdfcd420f61acb2361609794665293f` |
| `php.exe` | 186368 | `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65` |

cURL实际直接非OS依赖包括php8、brotlidec、libcrypto、libssl、libssh2、nghttp2和vcruntime140，传递包含brotlicommon。普通/delay import静态闭包仅缺`vcruntime140.dll`；没有使用旧Python14.38副本或全局DLL填洞。OS import名称分类只是静态候选，未独立证明新PHP进程实际加载的System32映像集合/签名/身份与全生命周期隔离。

## 3. 实际Microsoft包、许可与停止依据

官方最新v14页面给出的逐跳链：

1. https://aka.ms/vc14/vc_redist.x64.exe （301）
2. https://aka.ms/vs/18/release/vc_redist.x64.exe （301）
3. https://download.visualstudio.microsoft.com/download/pr/ebdab8e5-1d7b-4d9f-a11b-cbb1720c3b12/843068991DAAA1F73AD9F6239BCE4D0F6A07A51F18C37EA2A867E9BECA71295C/VC_redist.x64.exe （200）

只取得一个原始包，**18,731,856 bytes**，SHA256 `843068991daaa1f73ad9f6239bce4d0f6a07a51f18c37ea2a867e9beca71295c`，PE资源文件版本**14.51.36247.0**。包签名者为Microsoft Corporation；WinVerifyTrust离线cache-only、禁止网络URL取证、未做在线吊销查询，返回`0x00000000`。这是离线缓存信任结果，不是当次联网证书撤销证明。证书原件/链/Thumbprint留LOCAL_ONLY。x64是官方发行渠道选择；尚未拆包核验每个payload DLL的架构和版本。

最新页许可链接`https://aka.ms/VCRedistLicense`定向到：
https://visualstudio.microsoft.com/license-terms/vs2026-ga-visualcpp-v14-redist-runtime/

页面内官方文档：
https://visualstudio.microsoft.com/wp-content/uploads/2025/10/Visual-C-V14-License-Redistributable_and_Runtime_ENU.docx

文档Last Updated 2025-10-01、EULA ID Cpp_v14_ENU.1033；原文Hash及完整文本LOCAL_ONLY。条款授予安装和使用权，同时保留范围限制并限制分享/分发。微软一般部署文档说明app-local部署技术路径及VS再分发许可条件；**本轮没有建立适用于Owner、本次从该安装包拆出具名未改DLL再作app-local部署的完整权利链**。这不是认定Owner无权使用或已违法，也不把通用安装使用条款或Microsoft签名自动替换本任务明定的app-local证明。故不拆包、不用第三方提取工具执行安装、不复制单DLL，`REDISTRIBUTABLE_NOT_QUALIFIED`。

新PHP目标的必要PE linker字段已实读为14.44；新VC包版本14.51比该标记新，但**linker字段不等于精确compiler/toolset最低运行库版本证据，安装包版本也不等于已取得的具名DLL版本**。PHP包的精确工具链下限、实际app-local payload及全部静态/动态闭包仍`NOT_PROVEN`。没有把旧14.38/17符号匹配结论继承为动态资格。

合同要求未闭合许可/native时连`SUPPLY_ONLY_COMPOSER`也必须停止，因此未启动PHP来生成锁。没有为取得PASS修改安全策略、全局环境、PATH/php.ini、System32/WinSxS或使用共享DLL。

## 4. 实际源码与锁状态

- `php_requirements.json`现在绑定实际新exe Hash、官方ZIP/SPDX、13成员与缺失native清单，以及已取得VC原始包的版本/离线签名/许可调查。runtime仍`DEPENDENCY_SUPPLY_PENDING`，VC仍`REDISTRIBUTABLE_NOT_QUALIFIED`，Composer仍`LOCK_RESOLUTION_PENDING`。
- Python/PHP两端同一关闭集合加入本次结束任务，旧关闭集合全保留；新候选Parent绑定e93。示例Manifest同步新政策Hash，但不含假运行闭包或实际VC DLL。
- 新`supply_preconditions.py`只实现`SUPPLY_ONLY_COMPOSER`的**静态事实合同**，刻意不要求已经解析的Laravel12 lock，避免供应前先要lock的循环；仍要求独立PHP成员、app-local许可、工具链、payload、native进程边界及Composer PHAR来源证明。它没有Popen/下载/安装实现，返回STATIC_INPUT_FACTS_MATCHED_ONLY也不是启动许可；未将此称作已执行的Composer供应器。任何未来运行入口仍需另行真实资格及新合同。
- 原迁移负例保持；仅将“历史null exe pin”的合成缺失情形显式放回各负例fixture，另用实际新Hash测试ZIP/exe身份分离。没有删除负断言或把拒绝改成功。未改变F1消息、CN/MC/Block、Token、T0、通知、私有媒体或Flutter业务源码。
- `composer.json`保持Parent Blob `d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56`；`composer.lock`保持原Blob `66327f584d3961c2b53391bb012047dda9cc9d23`（Laravel11.48.0），未手改任何锁字段/content-hash。`composer_evidence`继续明确标为历史11锁，不能冒称解析了Laravel12。尚无新vendor来源身份可绑定。

## 5. 真实失败与检查结果

首次元数据适配脚本exit1：对URL做了过严的相等比较，官方页面已经指向archives，而SPDX的downloadLocation保留release路径。真实来源host、精确包名、版本和SHA256一致，不是证书、发布Hash或版本改变。保留失败源与工具回执；原stderr未预重定向，本机存的是明确标为`CODEX_TOOL_RECEIPT_COPY`的副本，不冒称原始stderr文件。随后复用已取得的两份元数据，核其回执Hash，只选择页面实际公开的精确archive URL，未猜测/替换URL、增加元数据请求或退款。

纯Python/AST/JSON/合成契约：**132/132，failed0/errors0/skipped0，exit0**；完整输出SHA256 `917668195c9a4bbf8b9c21cea946d2f412d54502ed30bfc9b9dcf7c26ee78b50`。其中Parent119个原用例及13个新供应负例均实际执行。正例只是可信operator合成事实，不是许可、原生环境、Composer、Laravel或OS隔离真实通过。Popen/socket/system/startfile/OS枚举在此批使用拒绝替身。

| 项目 | 本轮实际消费 | 结果/限制 |
|---|---:|---|
| PHP ZIP | 1/1，36,310,917 bytes | 官方发布Hash一致；未执行 |
| PHP小元数据 | 2/3，241,885 bytes | release与SPDX；原件保留 |
| VC原始包 | 1/1，18,731,856 bytes | 原始包离线签名信任通过；未安装/拆DLL |
| MS元数据/跳转 | 8请求，466,506 bytes | 所有逐跳host在请求前冻结并记账 |
| 全部供应HTTP | 12请求，55,751,164响应body bytes | 无自动重定向或重试；不把此当TLS/HTTP头的线缆流量测量 |
| Composer网络 | 0/240，0/256MiB | 未启动、不下载包 |
| Composer求解/vendor安装 | 0/2、0/1 | native门关闭，lock仍旧原件 |
| PHP CLI总量/无DB Probe | 0/60、0/2 | 包括语法检查也0；未加载新PHP |
| Feature/Unit批次 | 0/3 | 新Laravel12兼容3方法及原业务套件均NOT_RUN |
| MariaDB/API启动 | 0/2、0/2 | 未建库/启动服务，不接旧端口或实例 |
| 业务HTTP/迁移/seed | 0/160、0/1、0/1 | 无本轮真实状态码、DB计数或事务回执 |
| Flutter/G2/Gradle/APK/设备/RTC/Push | 0 | 无本轮权限，不能重置旧预算 |

## 6. 场景与AC限制

原15场景、已接受F1修复及Widget源码完整保留。消息同键/冲突/持久唯一性、CN/MC/Block/旧Token拒绝、T0/refresh、通知最小披露及媒体Range在**本轮Laravel12/API/DB**均NOT_RUN。没有合格H264素材也不编造视频206。没有数据库资格/空库/actor/GRANT证明就不提前迁移或seed。

不签`SYNTHETIC_API_DB_PASS`或`SYNTHETIC_LARAVEL12_API_DB_RUNTIME_OBSERVED`，更不能签`SAME_SOURCE_APP_API_DB_E2E_PASS`。AC01–11仍10 PARTIAL/1 OPEN，AC05 RTC OPEN；Keystore、物理15/30天、清理、真实设备/Push/AEC均未关闭。历史MariaDB23/152、Widget77及旧接受只作历史证据，未作为本轮重跑。

## 7. 保护、预算及集中剩余门

仅一个新task-owned根、task_id `V1015_L12_PHP85_SUPPLY_AND_API_DB_20261030`、attempt-0001，所有有代价操作先PREPARE/flush；网络请求/跳转和响应字节按唯一ledger累计。窗口从根创建时单调tick起≤120分钟，logical/native AllocationSize分别≤8GiB，终态数值及最终ledger SHA256封存在LOCAL_ONLY完成回执；Manifest为交付快照并预留末尾元数据，离散快照不冒充连续峰值监测。

受保护dirty状态/527 refs、e93和be7具名任务根身份及其ledger/完成回执/预算Hash前后相同。不写旧根、SDK/Composer缓存/原PHP环境，不清理任何历史目录或refs。不重新扫描旧18/122/五根/3183 Seed，也不冒称已逐件重新核验；原保护证据与ACL超限事故保持原样。历史Flutter6/6、3bed3/3、MariaDB2/2、G/APK1/1与所有历史失败/claims不重置。

剩余核心门一次集中列明：适用app-local许可与具名未改DLL合法来源/取得方式、新PHP确切工具链下限/可核兼容证据、VC payload与PHP完整native来源/Hash/OS握手闭包、合格Composer PHAR及受控包来源，再真正求解Laravel12 lock/vendor。**这些不足不授权换包、安装或借用旧DLL**。Owner将来若补齐证据，应另冻同源运行合同及新次数；本轮未用余额在STOP后不自动延续。没有自动生成后继任务。

维持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / OS_ENFORCEMENT_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / V10.1.6_NOT_STARTED`。仅交付一个sole Parent=e93的普通non-force候选。发布后直接回读Commit/Parent/Root、所有变更原字节、完整apps/services Tree和live main；最终身份封存在LOCAL_ONLY回执，避免文档自引用。main仍只接受v10.1.4。**完成后STOP等待Astra独立验收。**

## 8. 变更身份

| 文件 | Parent Blob | 候选源Blob |
|---|---|---|
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `96266bab5c97015f9e5fa73cacb00cabbb456231` | `96df0787ad75fd53a6de91b5451ab9a44ea29c5f` |
| `tools/v1015/mainline_e2e/README.md` | `64d13d0bc5c27c703318facbb3fd2ca41b915986` | `4db1ba6ecf956a6d77be856a4dad855e37e10dc9` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `43a7a4e222646b3dc5e805e2c314b47f563d39d0` | `4816503c471963cb46e89ff0ed23afe252c9d62e` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `2875cec40644ae2fd9b7b5176d543c3b6a108d62` | `847c0d6e41a9e0120498e4c9ce2850d346d15622` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `c0818b8880d7acf53aea2b16868bbc56c4cccc2e` | `b33c9e76405e53e27253a29f1d740fab5b79e7fd` |
| `tools/v1015/mainline_e2e/supply_preconditions.py` | `NEW` | `b1b8be10f44a36151172c69b3657f762a2d5042a` |
| `tools/v1015/mainline_e2e/test_migration_contract.py` | `c628fe2e36914d5e810739ee11932fa7dbde2716` | `bb88c4c791c2bd8d1c995afaae90e249ece09cb5` |
| `tools/v1015/mainline_e2e/test_supply_preconditions.py` | `NEW` | `db6af71ee54958d67e0e14f5eb6e43b6ace2a5f9` |

## 官方来源（实际仅上述有界请求）

- https://www.php.net/downloads.php?os=windows&version=8.5
- https://downloads.php.net/~windows/releases/archives/php-8.5.12-1-nts-Win32-vs17-x64.zip.spdx.json
- https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170
- https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files?view=msvc-170
- https://learn.microsoft.com/en-us/visualstudio/releases/2022/redistribution
- https://visualstudio.microsoft.com/license-terms/vs2026-ga-visualcpp-v14-redist-runtime/
