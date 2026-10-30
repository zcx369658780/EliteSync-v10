# API-set 原字节先归档、真实宿主与条件式 Laravel12 验证结果（2026-10-30）

**PARTIAL_WITH_EXPLICIT_API_SET_HOST_OR_NATIVE_GATES / AWAITING_ASTRA_INDEPENDENT_REVIEW**

本轮已把真实取证入口改为不可注入 no-op 的持久化链，并实际保存、回读及签名绑定完整 Schema 原字节。第1次观察解析到旧 revision 合约名称差异后失败；离线重放形成候选修正，第2次受支持宿主查询返回 **E_NOTIMPL (0x80004001)**。两次观察均 exit1，2/2 已耗尽并 STOP 动态阶段。**完整宿主闭包、PHP 实际原生加载、Laravel12 Composer 锁及 API/MariaDB 业务回归均未成立或未运行。** 不把成功归档或部分宿主签名当成整体资格通过。

## 1. Authority 与来源

- 正式任务 Blob `8faa3733369f714fb331e43c1da56762c589aa6b`；fresh 开工 main `ef8ceed1a61af4c8d5b0ea1c2440fce4efa37d62`，Root `9aa5b279d1178a81323ecdd84a6b1a26ca6ddc2f`，ACTIVE_STATE Blob `522467189614f69647ecdaa74725328fac5a6fc4`。正文、Owner 授权及 main 路径/Blob 已核，不使用本地 draft。
- 唯一研发 Parent `d33845e62f1aa5eb82e0a4bf443b0396f2eb8b1a`，Root `89665b425cd6c2bc9d32f49e300e35614abfe4e8`，apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `bc44baa6f04ce57a8a6dc331be12c67a79e6e0da`。Astra 上轮独立审查 Blob `0e8f3475a1950f7fe5338dff881cb9cfc9cf73c2`；审查分支不作为 Parent。
- CURRENT_WORKFLOW Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03` 已读取；原 AC01–11 和15场景不重写。761件本轮所需源码逐件匹配 Parent Blob 后导入私有工作面。
- 中央 VC、原23件 OS 来源证据从固定历史回执只读核验，不重复完整签名调查，不重装 VC、不下载 PHP。官方 PHP8.5.12-1 ZIP SHA256 `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`；exe `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`。13件官方私有成员复制到新根并按既定 Hash 核验，未启动。

## 2. 真实 raw-first 入口与保全

`schema_capture_entry.observe` 实际调用任务绑定的 `Journal`，不接受外部 persist 回调。执行顺序是持久 PREPARE+fsync → 原始只读、无写共享句柄读取 → exclusive 创建 raw 文件 → 文件 flush/fsync → 实际 Windows 目录 FlushFileBuffers → 回读大小/Hash/FileId/Volume → 源身份和签名绑定 → 解析已归档字节。任务根身份、attempt、ledger、窗口及工具源码闭包也被核验。

第1次观察保存完整 Schema **204152 bytes**，SHA256 `568c72f6216d83a716d6fa9bec59ae8d93e6728062d969ac362013f3910c0007`。原始文件与完整收据仅 LOCAL_ONLY；文件和目录持久化、exclusive/readback 标记均为真实收据。嵌入签名/链/时间戳来源通过既有严格验证器绑定同一源 Hash/身份；并非仅凭 System32 名称放行。

随后解析失败仍保留完整原字节、完整失败栈、exit1 和回执。读取中断/增长的源码路径也会先保留实际读到的 partial 前缀并拒绝解析，合成负例覆盖该路径；本轮真实观察没有发生 partial-read 故障。失败写入不删除或用合成文件覆盖；torn ledger tail 被拒绝。默认 inspect 无观察或执行副作用。

## 3. 两次观察与不能升级的结论

| 步骤 | 实际结果与证据边界 |
|---|---|
| 观察1 | 原始 Schema 已持久保存；精确名称匹配在 `api-ms-win-core-datetime-l1-1-0` 失败，`API_SCHEMA_CONTRACT_MISSING`，exit1。并归档15份所需 OS PE 输入，包括新候选宿主 ucrtbase。 |
| 新宿主子集 | ucrtbase 的实际 OS 路径、FileId/Volume/Hash、版本、PE架构及签名来源取得本地合格证据；只证明这一具名文件来源，不证明完整 API-set 闭包或 ABI。 |
| 离线重放 | 仅解析已归档字节发现 schema 有 `api-ms-win-core-datetime-l1-1-2`，HashedLength=58 bytes，候选指向 kernelbase；28份已有 PE 输入的导入/导出表离线解析通过。未新读系统文件。 |
| 观察2 | 复用第1次已归档 Schema/签名；绑定已加载且来源 pin 合格的 KernelBase，经 GetModuleHandle/GetProcAddress 查找受支持 API，并核函数地址 owner，未调用 LoadLibrary。 |
| 真实查询 | 接口 carrier 可用性为真，但首个 `api-ms-win-crt-heap-l1-1-0.dll` 宿主查询 HRESULT=`0x80004001` / `-2147467263` / E_NOTIMPL，host为空、actualNameLength=0。严格拒绝，exit1，未继续 PHP。 |

**HashedLength/revision 候选推导没有获得 Microsoft 公开保证的 loader 等价性证明。** 最终源码要求候选与受支持系统查询相符，再核所需 export/forwarder；不把 revision 数字相似直接当作真实映射。未选择的无关 entry 不扩大 host 资格阻断，选中项仍严格拒绝空值、歧义、越界、异常 UTF16/NUL、路径及非法后缀。

第2次原始 query 回执的 `available=true` 只记录当时接口 carrier 可用性，绝不代表 lookup 成功；非零 HRESULT 从未放行。原件保持不变。后续源码明确区分 `query_interface_implemented`、`lookup_succeeded`，`available` 仅随成功 lookup 为真；这是观察后的源码修正，未再运行该系统查询。

两个失败栈、收据和原字节均保留。2/2 后已持久登记 `DYNAMIC_PHASE_STOP_AFTER_SCHEMA_BUDGET_EXHAUSTED`；没有第三次来源查询、替换 API 继续求 PASS 或 PHP Popen。E_NOTIMPL 的具体 OS 实现原因仍 NOT_PROVEN，不能推断系统损坏、缺 DLL、需要安装/repair 或安全策略错误。

## 4. 原生闭包与权限接线

`native_closure.py` / `pe_symbols.py` 分离普通导入、delay-import、具体宿主及必要 export/forwarder。缺少 export、越界 EAT RVA、forwarder 循环、额外 VC 或未知模块严格拒绝；合法 data/BSS 导出不因非文件 raw 区而误拒绝。最终闭包仍要求真实宿主查询结果与归档 Hash/身份一致，不凭静态候选声明 PHP 已加载。

`current_native_task`、PHP runtime/probe 入口及 PHP E2E 资格类更新当前 task/Parent/source binding。provider/pin 缺字段不可因 None==None 通过；停止检查前置于完整 manifest 资格调用链，避免 STOP 后重读系统源，执行前也再次检查。私有二进制 hardlink/reparse/路径保护、中央VC与WINDOWS_SYSTEM_IMAGE分层、nonce/PID/创建代际/原 child handle/实际模块/退出回执合同保留。没有全局 os_import 例外。

无DB Probe 不以 Laravel12 新锁已存在为前提；只绑定当前真实源码字节，拒绝 DB、Laravel bootstrap、网络及实例资格配置。真实业务入口仍需真实新 lock/vendor、CLI/API 同源及独立数据库实例，不能用 Probe 权限代替。PHP requirements 与 Manifest 示例同步本轮 policy Hash 和 Parent；**旧 lock、composer_evidence、vendor 未伪造为 RESOLVED。**

## 5. 检查、失败和运行矩阵

最终 Python 纯合成/静态检查 **287/287 passed，failed0/errors0/skipped0，exit0**；输出 SHA256 `80308f879e74502783bce7e440de193e2592edb90f9bc5a0a3b8ce9d6accec33`。共13批，最终批为最终源码；各批不是独立用例数累计。Popen/socket/system/startfile/真实模块枚举被测试驱动拒绝；私有临时文件与目录 flush 为真实 task-owned I/O，不是额外系统来源观察。

首批257项有5 errors，原因是合成 fixture 的账本初始行缺换行；修复 fixture 并加入 torn-tail 拒绝，原失败保留。后续通过批次为257/259/260/264/277/279/280/281/283/286/287/287。只读 Sol 辅助审查发现 source closure、partial-read保全、export RVA 和 query provider 缺字段问题，已集中修复并加入负例。最终 STOP 调用链另有负例；辅助审查未独立重验最后全部修改，不替代 Astra 验收。

| 本轮动作 | 实际消耗 / 上限 | 状态 |
|---|---:|---|
| 新 Schema 具名观察 | **2/2** | 两次exit1，已耗尽 |
| 重复旧23件签名 / 新中央VC信任调查 | **0 / 0** | 复用固定历史原证 |
| PHP CLI / 无DB Probe | **0/60 / 0/2** | NOT_RUN_GATE_CLOSED |
| Composer PHAR / 包metadata / 请求 | **0/8MiB / 0/256MiB / 0/240** | NOT_RUN_GATE_CLOSED |
| Composer求解 / vendor安装 | **0/2 / 0/1** | NOT_RUN_GATE_CLOSED |
| Laravel12 Feature | **0/3** | NOT_RUN_GATE_CLOSED |
| MariaDB / API启动 | **0/2 / 0/2** | NOT_RUN_GATE_CLOSED |
| 业务HTTP / migration / seed | **0/160 / 0/1 / 0/1** | NOT_RUN_GATE_CLOSED |
| PHP语法检查 | **0** | NOT_RUN_GATE_CLOSED |
| 安装、系统二进制复制、全局系统修改 | **0** | 禁止且未执行 |
| Flutter/Dart/Gradle/G2/APK/设备/RTC/Push | **0** | 未授权且未执行 |

唯一 task-owned 根、attempt-0001、持久 ledger 自首次建立起计时，观察及各成本动作前 PREPARE+fsync；8GiB/120分钟内完成交付，实测空间/报告生成时刻耗时见 Manifest，最终值封存在 LOCAL_ONLY budget-terminal/completion 回执。后续封存文件仅增少量字节，预留64MiB；没有继承历史余额。旧 Laravel11.48.0 lock Blob `66327f584d3961c2b53391bb012047dda9cc9d23` 不变，仍 LOCK_RESOLUTION_PENDING。

## 6. 保护、证据等级与交付

受保护 dirty 摘要252项、527 refs 摘要前后相同；6个具名历史任务根的 FileId/Volume 和 ledger/hash/completion/budget 文件摘要前后相同。旧18、两ACL树、122原证、五保护根、3183 Seed沿既有保护回执传递；**本轮没有逐对象重扫，不能声称全部对象新鲜逐件核验。** 未修改历史原证、预算、claims、SDK、数据库、ACL或受保护工作树。历史事故 `PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、旧18精确恢复未证、RESTRICTED_IDENTITY_GATE_BLOCKED、OS_ENFORCEMENT_NOT_PROVEN永久保留。

F1/F3/F4业务源码、Flutter apps、原15场景及原业务权限断言保持 Parent 字节；本轮 services 变更仅 E2E 资格辅助类。源码清单：

| path | Parent Blob | 本轮 Blob |
|---|---|---|
| `services/backend-laravel/tests/E2E/MainlineEnvironment.php` | `1200f970f48f4901e931d2f7caac56bd08a1537f` | `531de57e70fec78bfefd293f669232a887bd5a8b` |
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `297b383fcf6f4f65c208da05b022eb5f60566310` | `23696d832431a8a329f19926ef33bf5bcbb19a74` |
| `tools/v1015/mainline_e2e/README.md` | `ddb7bfab0f0a2241070485f166f73270a9bb22e3` | `a8c2c4dbac9c2e7a0606841f0bd80dab2d90ce9e` |
| `tools/v1015/mainline_e2e/api_set_query.py` | `NEW` | `09a5a23ea8207f128b17295e22dbbb922ae82463` |
| `tools/v1015/mainline_e2e/api_set_schema.py` | `84bc3ded06a3f9def16b8c9c5595e9b75447fc92` | `329f8c3be20edacdd82d2352f6fe55a6df5fbeea` |
| `tools/v1015/mainline_e2e/current_native_task.py` | `9a092b078fe93bcac1ab2a424340f307288de04b` | `c3ca0c4d57e924a9e4ea669b034114aae2f9dc86` |
| `tools/v1015/mainline_e2e/durable_evidence.py` | `NEW` | `d542ba6f12460e323ff3ea825613718f5101a7b3` |
| `tools/v1015/mainline_e2e/native_closure.py` | `NEW` | `2619359b48cf2a5e5c15a9d715063073059b40bc` |
| `tools/v1015/mainline_e2e/pe_symbols.py` | `NEW` | `bddbf86e519eb9cb2d5b774363773bd8103a4eb3` |
| `tools/v1015/mainline_e2e/php_probe_entry.py` | `b1c866180b0a27f25c44b50bf4a5b15f9624c136` | `6606328ad23023974f1f00e0856ae44bd1b2e1a8` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `3fa2d2e4442fd26e09119647ba86d1c2e46ee890` | `18e770fc37b3321d2ae3d376d5189896fd63ab86` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `4f704667d5832f3661157948dbad84a29c7cc471` | `cd0704dcc7a16a910c511cc50ec380d4c5653181` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `232fb430da17d1ad71583f2caec60d9f26eb1173` | `492579f14661763871662f7b3d05fef2a615dc15` |
| `tools/v1015/mainline_e2e/schema_capture_entry.py` | `NEW` | `53de44579f26a54d1b8e4e9ebd0fd7b6490e64ad` |
| `tools/v1015/mainline_e2e/test_api_set_query.py` | `NEW` | `0146748bc6e083bf2b3608d6393d21d052a297d9` |
| `tools/v1015/mainline_e2e/test_api_set_schema.py` | `1b6cd057f2a1ec6243d56331f2c694212efd69f3` | `27eede04a05f7cc2a69a6c48578fdca0494c37d6` |
| `tools/v1015/mainline_e2e/test_current_native_task.py` | `4d4599b75f01ad331d3672f941fb3c6f40054390` | `b88bdfa6e52a29bbb5b31a453bbeeaa05d5536b4` |
| `tools/v1015/mainline_e2e/test_durable_schema_entry.py` | `NEW` | `7069deeb3d5f52a6f60b4b19818072d38c86a58c` |
| `tools/v1015/mainline_e2e/test_native_minimum_closed_gate.py` | `d212df529f58a32a6d242a060cc39737351d3725` | `17fb0eb06d894e014e3951f54762e7e7baef77c5` |
| `tools/v1015/mainline_e2e/test_pe_symbols.py` | `NEW` | `7f14ea9ca6c6ff725d1bcc4f982322d08d84ee98` |

`DIRECT_GITHUB_OBJECT` 只指 GitHub Commit/Tree/Blob及原文身份；本地观察/纯测试属于 `CODEX_REPORTED_LOCAL_TEST`，Astra尚未独立验收。Schema、PE、签名/certificate、系统路径/身份、PID、原始日志与ledger均为 `LOCAL_ONLY_RAW`，不上传。完整宿主/原生闭包、PHP实际加载为 `NOT_PROVEN`；PHP/Composer/Feature/API/DB/15场景均 `NOT_RUN_GATE_CLOSED`。历史23 Feature/77 Widget不是本轮重跑，更不是本轮端到端结果。

只有一个普通non-force候选，sole Parent固定d33845e6；GitHub发布后回读Commit、sole Parent、Root、全部变更path/mode/Blob原文、完整apps/services Tree与live main，回执封存在LOCAL_ONLY。不在本报告中预造尚未产生的Commit。发布不会合main；main产品仍是已接受v10.1.4。未签署整版FUNCTION_ACCEPTED。

## 7. 未关闭门禁与最小后续授权需求

本轮源码和raw保全可供独立复核。后续若Owner选择继续，需一次集中授权针对**已保存真实schema与E_NOTIMPL的受支持解析/查询兼容边界**完成离线方案及必要的有界新观察，确认所选宿主与必要exports/forwarders完整闭包；不应重复23件OS签名或中央VC调查。闭包合格后仍需新任务明确授予PHP Probe、Composer供给求解和独立API/DB预算。本轮未发布或启动后继任务，不据此自动使用未消耗额度。

继续保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11仍10 PARTIAL/1 OPEN。完成唯一候选后STOP，等待Astra独立验收。

## 官方参考

- https://learn.microsoft.com/en-us/windows/win32/api/apiquery2/nf-apiquery2-getapisetmodulebasename
- https://learn.microsoft.com/en-us/windows/win32/apiindex/api-set-loader-operation
- https://learn.microsoft.com/en-us/windows/win32/apiindex/windows-apisets
