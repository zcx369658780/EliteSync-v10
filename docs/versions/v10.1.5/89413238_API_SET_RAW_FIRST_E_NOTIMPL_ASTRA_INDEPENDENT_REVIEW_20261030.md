# EliteSync v10.1.5｜89413238 API-set Raw-first与E_NOTIMPL Astra独立验收｜2026-10-30

**正式裁决：`89413238_BOUNDED_DURABLE_SCHEMA_CAPTURE_AND_STATIC_NATIVE_SOURCE_ACCEPTED_WITH_OBSERVATIONS / API_SET_SUPPORTED_HOST_QUERY_E_NOTIMPL / FULL_NATIVE_CLOSURE_NOT_PROVEN / PHP_COMPOSER_LARAVEL12_API_DB_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本报告通过GitHub连接器直接读取固定候选、唯一Parent、Root/产品Tree、全部22项文件路径和21项非自引用Git Blob，独立审查核心API-set取证、宿主查询、原生闭包及持久化源码，并核对微软`GetApiSetModuleBaseName`官方用法。**Astra没有直接访问Owner本地Schema原件、证书DER、OS系统API日志、完整ledger或运行PHP、Composer、Laravel/MariaDB；Windows两次观察与287项纯检查仅是`CODEX_REPORTED_LOCAL_TEST`。** 禁止把源码通过直接等同动态业务验收。

## 1. 固定Authority和GitHub对象

- 当前Owner正式任务：`docs/versions/v10.1.5/V10_1_5_API_SET_SCHEMA_RAW_FIRST_REAL_HOST_AND_CONDITIONAL_L12_E2E_TASK_20261030.md`，Blob `8faa3733369f714fb331e43c1da56762c589aa6b`。只授权新的具名Schema只读观察最多2次，满足所有来源/原生门后才有PHP、Composer、合成API/DB许可；不授权系统安装和产品main集成。
- 交付Commit `8941323808ce0cdfc68b9f0c3796f86400a75d43`，sole Parent `d33845e62f1aa5eb82e0a4bf443b0396f2eb8b1a`，Root Tree `6808c706f4b2f03b641975f71315c241ce6e435a`。compare ahead1/behind0，共**22**个变更文件。
- manifest所列20个源码文件的**Git Blob SHA+100644 mode逐项通过实际Git树回读20/20**；加上综合报告，21项非自引用Blob通过21/21。全部22项变更路径与Manifest+报告+self路径集合一致。Manifest自身Blob `870200e191b21aa46ee7a71400d18fad5321b418`，本身不伪造循环自签。报告 `docs/versions/v10.1.5/API_SET_RAW_FIRST_L12_API_DB_RESULT_20261030.md`，Blob `535ec8ac25e267fa1570935f6833fd151690c611`；Manifest `docs/versions/v10.1.5/api_set_raw_first_l12_api_db_manifest_20261030.json`，Blob `870200e191b21aa46ee7a71400d18fad5321b418`。
- 候选apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`与Parent未变；候选services Tree `521cafbb463e0099271618c22cafd1ed6218bea2`，仅后端`tests/E2E`及非生产资格工具/说明变更，没有F1/F3/F4生产业务代码更改。
- 审查时main HEAD `ef8ceed1a61af4c8d5b0ea1c2440fce4efa37d62`，Root `9aa5b279d1178a81323ecdd84a6b1a26ca6ddc2f`；main唯一已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本Astra独立审查分支不作为研发Parent，不合并产品main。

## 2. 真实Schema取证：源码和本机回执有界接受

原`d33845e6`阶段的关键缺陷是**API-set解析前未持久化当次真实输入**。本候选新增`schema_capture_entry.observe`和`durable_evidence.Journal`，在源文件解析前执行任务与source绑定、持久PREPARE、只读handle读入、专属raw命名空间独占创建、文件flush/fsync、目录flush、原字节回读Hash/大小与FileId/Volume检查、源身份/签名关联，然后才解析归档内容；异常不删除raw，partial-read路径也保存已有前缀。**这是真实调用链中的改动，不是仅提供可注入no-op回调的辅助函数，有界接受。**

Codex的第1次本机观察报告归档完整Schema **204,152 bytes**，SHA256 `568c72f6216d83a716d6fa9bec59ae8d93e6728062d969ac362013f3910c0007`，并保存`API_SCHEMA_CONTRACT_MISSING:api-ms-win-core-datetime-l1-1-0`的exit1及原始异常。第2次复用固定已归档Schema，未重读替换原件；Astra独立见GitHub源码中的`verified_archive`重校Sha/FileId/Volume和STOP/预算门。**这些原始本机文件/目录刷新与回执由Codex报告，Astra没有直接重算本机字节。** `RAW_ARCHIVED_WITH_READBACK_CODEX_LOCAL`可以接受，不能声称在线OS安全或Native加载完成。

## 3. API-set宿主解析与E_NOTIMPL：必须继续fail-closed

第1次失败后，Codex使用归档原件离线解析出目标请求`api-ms-win-core-datetime-l1-1-0`与Schema中`...-l1-1-2`候选的版本/hashed-prefix关系，新增`api_set_schema.py`的按需选择及HashedLength有界候选规则；并根据已归档PE文件构造普通导入/export/forwarder闭包。**这些是候选算法与静态推导，尚未证明与运行Windows加载器实际映射完全等价**。

第2次只读观察，`api_set_query.BoundQuery`使用已经加载且源已固定的KernelBase，通过GetProcAddress取得`GetApiSetModuleBaseName`等导出，并对`api-ms-win-crt-heap-l1-1-0.dll`调用真实宿主查询；报告HRESULT `0x80004001`（`E_NOTIMPL`）、host空、actualNameLength 0，exit1。工具**按失败拒绝**，最终源码把`query_interface_implemented`和`lookup_succeeded`分开，`available`仅在HRESULT=0时为true。Astra阅读`validate_query`确认需要返回成功、合法host及与候选一致，故未把E_NOTIMPL洗为通过。

**重要独立来源观察：** 微软官方`GetApiSetModuleBaseName`文档（https://learn.microsoft.com/en-us/windows/win32/api/apiquery2/nf-apiquery2-getapisetmodulebasename）明确说明：函数存在并不确保单次查询成功；推荐按`IsApiSetImplemented`检查后，动态绑定`api-ms-win-core-apiquery-l2-1-1.dll` API-set契约并检查HRESULT，失败时采用受支持的fallback。候选工具选择**直接从已加载KernelBase模块取得导出**，与官方示例绑定路径不相同。**这是一项未来技术评估缺口，不足以单独断言它造成了本机E_NOTIMPL，也不授权绕过既有系统源与进程/网络门禁或对现有STOP任务追加LoadLibrary/Popen。** 微软官方亦指出该查询只报告运行系统Schema的宿主名，不会核文件存在、加载或export。即使未来fallback成功，仍须独立验证宿主文件的真实签名、Hash、必要export/forwarder、已加载镜像与子进程身份。

因此本次只能签`SCHEMA_RAW_DURABLE_CODEX_LOCAL / QUERY_E_NOTIMPL_FAIL_CLOSED / REAL_HOST_MAPPING_NOT_PROVEN`，绝不能签`API_SET_FULL_NATIVE_CLOSURE`或`PHP_NATIVE_LOADED`。E_NOTIMPL不能证明系统损坏、DLL不存在、VC ABI不兼容或必须重装Windows。

## 4. 源码门禁、安全及尚未发生的运行

- `native_closure.py`和`pe_symbols.py`新增有界静态普通导入、必要exports/forwarders、循环/RVA拒绝；`current_native_task`在PHP启动前强制已归档可信Schema/已归档Query receipts与真实OS文件来源一致，要求新候选与受信查询结果一致；STOP前置可拒绝回读当前系统源。三类`TASK_PRIVATE_BINARY / WINDOWS_SYSTEM_IMAGE / MICROSOFT_CENTRAL_V14_RUNTIME`的权限分离与私有hardlink/reparse/路径拒绝仍保留。
- 本次`php_runtime.py`、`php_probe_entry.py`和PHP侧测试入口仅更新非生产当前task/Parent绑定；无PHP`-n -l`或新PHP代码运行证明。仅有源码存在、静态构造/模拟通过，未见本轮生产消息授权/数据变更。
- Codex报告两次Schema真实观察均exit1，**2/2耗尽**，已持久STOP；Composer PHAR/Packages、真实solver、vendor、PHP CLI/无DB Probe、Laravel12 Feature、MariaDB/API、HTTP/迁移/seed全部**0**。旧Composer.lock Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍Laravel11.48.0，`LOCK_RESOLUTION_PENDING`。历史23项Laravel Feature/77 Widget、Flutter旧测试不可冒作本次运行。
- Python最终**287/287**纯合成/静态用例，Codex报告exit0、无失败、无跳过；前13批及初始化torn-tail等失败均保留，本Astra没有本地重跑。单task根、attempt-0001、ledger、空间/时间、当前raw证据及旧保护是`CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW`；Manifest末尾snapshot约75.54MB logical、78.73MB allocated，报告当时计时4193.172秒，Owner终态称约74.4分钟/81.1MB/84.3MB，二者是不同封存阶段而非可相互替代的实测。同一任务预算8GiB/120分钟未见报告超额，但Astra未亲自验证连续峰值或最终回执。
- 历史旧18/两ACL树/122原证/五根/527refs/3183 Seed、旧失败/claims/ledger/dirty，以及`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`保留，未重新逐对象审计，不可重置旧预算。未安装VC、写系统配置或操作生产/真实用户数据。

## 5. 有界正式终态与下一Owner门

**`89413238_BOUNDED_SCHEMA_RAW_FIRST_AND_STATIC_NATIVE_SOURCE_ACCEPTED_WITH_OBSERVATIONS / E_NOTIMPL_SUPPORTED_LOOKUP_BARRIER / API_SET_HOST_CLOSURE_NOT_PROVEN / PHP_COMPOSER_LARAVEL12_API_DB_NOT_RUN`。**

保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11仍10 PARTIAL/1 OPEN；不签整版`FUNCTION_ACCEPTED`。

下一次如Owner再授权，应**集中处理现有已归档Schema与受支持宿主查询失败的兼容/fallback选择**：先基于已有原始数据离线判断各必要contract及revision策略；比较官方API-set契约绑定与当前KernelBase导出绑定的差异，在官方支持与既有许可下选择严格可验证的失败替代路径，仍必须保证源字节/真实映像/exports及任务预算闭包。不要再重复中央VC、23个OS签名、PHP官方下载、历史ACL或系统安装。旧2/2观察和所有旧剩余额度不能继承；新的真实操作须另有Owner冻结授权。

**本轮仅发布独立Astra审查报告、GitHub回读后STOP；不自动下发后继任务、不合并产品main、不放行G2、不关闭AC05。**
