# Owner B Laravel12 / PHP8.5 兼容迁移交付｜2026-10-30

状态：`OWNER_B_LARAVEL12_SOURCE_MIGRATION_CANDIDATE_DELIVERED_WITH_DEPENDENCY_GATES / AWAITING_ASTRA_REVIEW`。

已实施 Laravel12 源码准备与 PHP8.5 官方扩展/失败关闭政策。**没有运行 Laravel12，也没有生成新 lock**。旧 Laravel11 lock 原字节保留为 `LOCK_RESOLUTION_PENDING`；产品 main 未集成。不能声称 `FRAMEWORK_UPGRADE_RUNTIME_PASS`。

## Authority 与来源

- 唯一正式任务 Blob `1ade4e5a89116eeba329311ed274229823aafd17`，开工 fresh main `be2204a7513145af2e764e6a36e63950aa3739b2` / Root `593fa732e1048df479fadb068e66d455f579f992` / ACTIVE_STATE `3e134db5db499912b0526adfb8439a3519972590`。
- 唯一研发 Parent `be7ebd1faa0fd3cb45bd88bd24af15ea9e805631` / Root `db2725ee513816f430002265e19c0f96ec21325f`；apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`、services `dd552af956733514977cdd4bc82207c062792a96`。从具名历史源只读导入741份后端/E2E文件，全部按 GitHub Parent Blob 比对；未导入旧 vendor 作为 Laravel12供应。
- 已读取 CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`；Astra Parent裁决 `e918c651b7c44b83c1a60e979aad065ac30e7632`、兼容研究 `fc96469622517436d1d7a316dff7545e1dc912a9`。
- `DIRECT_GITHUB_OBJECT`仅指直接读取对象/源码身份；本机检查属于`CODEX_REPORTED_LOCAL_TEST`。完整本机路径、ledger、原输出及历史凭据不入Git，为`LOCAL_ONLY_RAW`。

## 实施与依赖判断

`composer.json`：框架从 `^11.31` 到 `^12.0`，PHP从 `^8.2` 到 `~8.5.12`（>=8.5.12且<8.6）；根声明Laravel Deployment全部13个扩展及项目`pdo_mysql`。保留现有Composer脚本/插件许可配置原样，本轮未运行它们；未来供给解析必须显式禁止脚本与插件。

Sanctum4.3.1、Tinker2.11.1、Pail1.2.6、Sail1.53.0锁定包的Illuminate约束明确含12；Collision8.9.1排除框架<11.48或>=14，PHPUnit11.5.55符合已有`^11.0.1`；Pint1.28、lunar-php1.4和Workerman5.1.9的PHP约束没有8.5上限冲突。**这只是必要约束核查，不是完整求解、Windows Workerman运行或PHP8.5兼容实测**。Carbon原锁3.11.3，符合Laravel12的Carbon3方向。

2026-10-30读取官方框架12.x `composer.json` Blob `2ee76c507d6abdd10aeb2f8fc70bdac68d5068b3`：Carbon要求`^3.8.4`，另有Symfony/polyfill等版本下限。未将dev分支源码或上游开发依赖整树加入产品。本机具名Composer框架缓存ZIP经只读核实为11.48.0，SHA256 `f87209e97e4ff502a5e66b1dd960e9dccace9133133ef368bdebb31926a037d4`，不是12。不能证明完整合法离线闭包，因此Composer求解0/2，旧`composer.lock` Blob `66327f584d3961c2b53391bb012047dda9cc9d23`完全不变，不伪造content-hash或包版本。

新`migration_contract.py`提供无副作用输入审计，明确区分lock版本匹配、Composer求解和真实运行；不是通用Composer schema/SAT实现。Python CLI/API共用资格与PHP pre-bootstrap增加依赖供给、lock、exe pin及VC来源/许可门。当前任务和已结束原生任务进入关闭集合；原closed集合保留。`validate_manifest`拒绝缺失exe pin，不能把null或ZIP Hash作为exe身份。历史私有hardlink/reparse、OS观察、DB实例与业务门未放宽。

## Laravel11→12影响矩阵

| 变更点 | 当前源码事实/处理 | 限制与下一实测 |
|---|---|---|
| UUIDv7 | app未使用HasUuids/HasVersion7Uuids；媒体显式Str::uuid保留 | 不添加无依据UUID替换 |
| 可空构造参数 | F1发送服务四个授权/通知依赖均必需无默认；现有可空天文适配器已有fallback | 新增Laravel12容器回归源，尚未执行 |
| Carbon3 | 锁已3.11.3；T0使用CarbonImmutable及独立时间合同，refresh不改可信登录锚 | F1/F3不改；未来重跑原登录/refresh/撤销/时间边界 |
| 私有存储 | local显式storage/app/private；三个业务私有disk显式根/throw | 不随框架默认迁移数据；新配置回归源NOT_RUN |
| SVG验证 | 没有allow_svg例外；不为升级放开私有媒体 | 新增image拒绝SVG回归源NOT_RUN |
| 路由同名优先级 | 具名admin路由按现有group前缀；未发现同组重复name常量 | 不重排路由；动态注册及route cache仍待验证 |
| mergeIfMissing/Concurrency/自定义Grammar | 具名app/routes/bootstrap未发现相应调用或手工数据库Grammar构造 | 无确证影响不改；非全局语义证明 |
| 数据库检查/API | 未使用getTables/getTableListing；APP_DB选择优先级和测试DB资格保留 | MariaDB事务、并发、通知与旧Token必须在新授权下实测 |

业务`app/`、现有路由/配置/迁移和全部原Feature/Unit测试保持原字节，Flutter完整apps Tree不变；未虚构新业务Bug。新`Laravel12CompatibilityTest.php`有3个测试方法，覆盖显式存储、F1必需容器依赖和SVG拒绝；仅源码交付，`NOT_RUN`。原TestCase防误连库守卫未改。

## PHP8.5 / VC / cURL来源与门禁

官方页面及其SPDX均列 `8.5.12-1`、Windows VS17 x64 NTS，发行`2026-10-26 13:05:05 UTC`；PHP运行版本元数据为8.5.12。官方ZIP：
https://downloads.php.net/~windows/releases/php-8.5.12-1-nts-Win32-vs17-x64.zip

发布SHA256：`2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`，页面显示34.63MB。**未获取ZIP、未核其实际字节或签名；这不是php.exe Hash**。新`reference_executable_sha256=null`，不继承8.5.3历史Hash。ZIP内新exe、php8.dll、扩展及全部非OS DLL的准确文件Hash/PE普通与delay-import/架构/来源/许可仍待实际供给。

cURL由optional改为必需shared模块，加入curl_init/curl_exec/curl_version；保留Ctype/DOM/Fileinfo/Filter/Hash/Mbstring/OpenSSL/PCRE/PDO/Session/Tokenizer/XML及项目pdo_mysql；XMLWriter/Phar/libxml/iconv/json等dev需求另列。`php_curl.dll`只是待供给目标名，不能据名字猜测其依赖集合。官方SPDX含依赖版本/许可元数据但`filesAnalyzed=false`，不能据此给每个加载DLL编造Hash或推导完整PE闭包。CLI/API仍要求同一私有profile，global php.ini/PATH/System32替代均不允许。

微软官方规则要求x64、运行库版本不少于实际构建工具版本，且再分发受相应许可/REDIST清单与实际权利约束。本次VS17家族可确认，但**新PHP包准确最低工具版本/实际VC文件未证明**；旧参考PE14.44不能替代新包下限。14.38.33126.1明确排除为动态默认。三个具名VS2022 Redist目录不存在；未扩大扫描、未复制第三方Python DLL，`REDISTRIBUTABLE_NOT_QUALIFIED / PHP_RUNTIME_COMPATIBILITY_NOT_PROVEN`。没有Hash、签名或Owner实际许可回执则保持阻断。

## 实际检查与失败

纯静态/合成检查至最终制品核验共5/8批；第1批在AST读取时Windows默认GBK解码失败，0用例、exit1；修为显式UTF-8并保留原输出，不退款。第2批116/116 exit0；新增cURL闭包及双入口负例后第3批119/119 exit0，无失败/错误/跳过。第3批含原96个Python契约及23个新增迁移用例；两次成功批累计235次用例执行，不将重复计为235个独立用例。第4批制品扫描错误地把Composer schema的https URL后缀当作盘符，exit1；只修正盘符前边界，不放行真实本机路径，失败原证保留并计数。

| 批次 | executed | passed | exit | LOCAL_ONLY输出SHA256 |
|---|---:|---:|---:|---|
| 1 | 0 | 0 | 1 | `d8da955eba781df449632eb7325cd6c14d5db17b7e799254436b1d094ff14bdd` |
| 2 | 116 | 116 | 0 | `76d15afa2a5eedee6771355d51ee9dbd2783354735f9c394e371ffe1f0b94923` |
| 3 | 119 | 119 | 0 | `e4c15dfdcf2eea432e5ee3289ade749f5de2b149a17a8c8db3dc003b5a2dcf85` |
| 4 | 0 | 0 | 1 | `ff598d75d2026d60b745ca072bd8ecc81ead12c6c12221b173eae64824ff587d` |

覆盖JSON/AST、旧lock识别、新框架/PHP范围、必需扩展、null/错误Hash、未合格VC、cURL缺失/依赖缺失、闭合任务、默认inspect及不启动进程/网络的负向合同。Popen/socket/system/startfile/实际模块枚举均用拒绝替身；静态/Mock不等于OS强制隔离。第5批仅交付文件/保护身份/脱敏静态核验，结果单列Manifest/最终回执，不冒称新业务测试。

PHP `-n -l` 0/12：没有在本任务新私有根独立合格的可信纯lint原生闭包，不沿用旧运行资格；新增PHP源**尚无真实语法退出证据**。Composer resolution 0/2：具名缓存缺Laravel12闭包。PHP扩展Probe、Laravel/bootstrap/Feature/API、MariaDB、HTTP E2E、Flutter/analyze/Widget、Gradle/JVM/G2/APK/ADB/设备/RTC/Push全部0，`NOT_RUN_GATE_CLOSED`。15场景资产与旧真实MariaDB/Flutter回执仅历史证据，未升级为新框架结果。

## Laravel13仅评估与时间建议

当前仍实际目标12。官方12支持PHP8.5，安全期限2027-02-24；13支持PHP8.3–8.5、安全期限2028-03-17，维护收益约一年。建议Owner在2026-12-15前决定独立13范围，2027-01-15前完成候选审阅以留出12安全截止前回退窗口；这些日期是建议，不是新任务或接受承诺。

13需要单独评估Tinker3/PHPUnit12、cache可序列化类白名单和session序列化、缓存/会话名字、请求伪造中间件、nullable call与domain route优先级。当前admin登录CSRF、Sanctum会话和F3隐私必须重测，不开启反序列化任意类以求兼容。MariaDB10.11应检查upsert的uniqueBy、DELETE JOIN ORDER BY/LIMIT生成SQL和消息/通知事务；缓存对象、队列、路由缓存与测试隔离需真实回归。本轮未修改这些13配置，没有升级到13。

## NEXT_OWNER_SUPPLY_CHAIN_AUTHORIZATION_SPEC（一次合并建议，未执行）

1. 冻结本候选后，允许取得上述官方PHP8.5.12-1 ZIP一次（建议上限64MiB）及同源SPDX/许可；按发布Hash比对，私有解压，逐成员Hash/PE/架构/签名来源/扩展及cURL依赖完整清单。若版本或Hash变化停止，不静默换版本；回退是保留候选和原证、不运行、不改系统。
2. 对冻结Composer输入授权可信官方Composer/Packagist/GitHub包供给与私有cache，建议总包流量上限256MiB、最多2次解析，scripts/plugins关闭、无artisan/服务。锁定Laravel12维护补丁及全部传递依赖，生成真实composer.lock、来源/许可/完整Hash清单后再独立审阅。具体包数量/总大小和最终Laravel12补丁尚未求解，不能预先编造；任何超额须Owner再授权。
3. 提供适用VS许可及REDIST清单、匹配新PHP构建工具下限的官方x64 v14资产，建议供给上限64MiB。精确版本/Hash应从官方资产和签名/发行元数据取得；目前未下载，不能猜Hash。必须单独明确应用私有复制权与文件清单；不授权全局install/System32替换/安全策略变更。
4. 合格供应链及新lock通过独立审阅后，再一次冻结动态任务：建议无DB Probe1次≤30秒、PHP CLI≤48次、独立MariaDB启动≤2次/API启动≤2次、migration1次/合成seed事务1次/HTTP≤160次、90分钟。沿用同源15场景的F1幂等/撤权、F3可信T0与refresh、F4通知隐私；新增Laravel12三个测试及原负向Feature。端口、根、来源、ledger和实际预算须新合同明确，未使用历史余额。物理15/30天、设备/Push/RTC仍需各自权限，不包含在此建议。

## 保护、证据与STOP

单一task-owned根/attempt与持久ledger；关键写入及每批检查前PREPARE/flush。空间native AllocationSize与logical分别计量，4GiB上限，90分钟窗口；最终实测/ledger Hash在LOCAL_ONLY完成回执和GitHub回读证据中封存，Manifest记录交付快照，不把离散快照称连续峰值证明。

原dirty状态原始回读Hash、527 refs及be7任务ledger/receipt/budget原字节前后相同；无dirty根写入，无旧ACL/Seed/数据库/历史目录清理。未重扫旧18/122/五保护根/3183 Seed，不冒称新核验其全部内容。旧Flutter6/6、3bed3/3、MariaDB2/2、G/APK1/1及ACL跨尝试超限事故不改、不退、不复用。

持续 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / OS_ENFORCEMENT_NOT_PROVEN / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`。候选不自行FUNCTION_ACCEPTED。

GitHub候选Commit、sole Parent、Root、每条变更Blob和完整双产品Tree由发布后独立读取并逐字节核对；最终身份在本任务LOCAL_ONLY `final-readback.json`/完成回执封存，避免提交Hash自引用。fresh main仍必须只含已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。**交付后STOP，等待Astra独立验收，不派发后继、不合main。**

## 源码身份

| 文件 | Parent Blob | 候选源Blob |
|---|---|---|
| `services/backend-laravel/composer.json` | `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1` | `d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56` |
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `774153ad28d6deeba7fb1be82dd45e6d6aec4f0f` | `96266bab5c97015f9e5fa73cacb00cabbb456231` |
| `services/backend-laravel/tests/Feature/Laravel12CompatibilityTest.php` | `NEW` | `575eeb747fa696765a8bdb3b6989001de4ca7662` |
| `tools/v1015/mainline_e2e/README.md` | `aa71f51835977efdb6bad512c076aaaf5e90ead6` | `64d13d0bc5c27c703318facbb3fd2ca41b915986` |
| `tools/v1015/mainline_e2e/migration_contract.py` | `NEW` | `31b307ff3a7a12cbe0a2aa8d485d96d9d63b97be` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `d367cdf79f8c8d3507fec2c097d8906b6758dd3e` | `43a7a4e222646b3dc5e805e2c314b47f563d39d0` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `a78157f20a1101d4ade1cd47ff2bc1805580b7c0` | `2875cec40644ae2fd9b7b5176d543c3b6a108d62` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `95e7630707f253851730df1b7752c5c985d278a2` | `c0818b8880d7acf53aea2b16868bbc56c4cccc2e` |
| `tools/v1015/mainline_e2e/test_migration_contract.py` | `NEW` | `c628fe2e36914d5e810739ee11932fa7dbde2716` |

## 官方只读资料

- https://laravel.com/docs/releases
- https://laravel.com/docs/12.x/upgrade
- https://laravel.com/docs/12.x/deployment
- https://laravel.com/docs/13.x/upgrade
- https://github.com/laravel/framework/blob/12.x/composer.json （本次读取Blob已列）
- https://www.php.net/downloads.php?os=windows&version=8.5
- https://downloads.php.net/~windows/releases/archives/php-8.5.12-1-nts-Win32-vs17-x64.zip.spdx.json
- https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
- https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files
