# EliteSync v10.1.5｜Sandbox关联guest状态未确认｜Astra独立复审

日期：2026-10-24（Asia/Singapore）｜独立复审Authority：Astra / EliteSync GPT顾问。

**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / SANDBOX_GUEST_SAFE_CLOSURE_NOT_CONFIRMED / OWNER_MANUAL_CONFIRMATION_REQUIRED / SDK_NOT_RUN / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 1. 固定Git身份与源码零差异

- 最终Codex候选Commit `7292a8c39cec2e0bbb611436686828263129614b`；唯一Parent `29eced7453d876ca3d229341241b518e80b82635`；Root Tree `270adcd0c7934b974be7f820f1fd063a52e63285`。GitHub Compare `ahead1 / behind0`，候选仅新增2份docs，无任何`apps/services`变化。
- [候选报告](SANDBOX_SESSION_CLOSE_AND_SDK_RUNTIME_RESULT.md) Blob `8a0c00e8bab4e2eed85df5a824e8e2ea185b9ba2`；[Manifest](sandbox_session_close_and_sdk_runtime_manifest.json) Blob `0698c26e0bad31900eab7e224a59c28c50e7153b`。Astra独立读取固定GitHub文档、Commit/Parent/Root及compare，并验证候选与Parent完整apps Tree均`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree均`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。固定诊断产品source`1522466faf798b719ccff281de7584f043946437`与`apps/android/app/build.gradle.kts` Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`继承不变。
- 前置正式任务Blob `e30a0e1e35d5f39c6e0f77bfa9fa8e2f8d7574df`，上轮Astra复审Blob `c716c8cb5f42b6ef0da019c6cfc8042fc9c5a181`；本轮已核任务使用了当时`ACTIVE_STATE` Blob `d476af928ef7c7b0c34ac4af043110e75e7effb1`。Astra核验时`main` Commit `b3ae592ff3484609cb69fe4eb65fa17cfb2328ff`／Root `3d21256f4dc763901a16d688c633502760aa95dc`，仍为v10.1.4独立接受产品apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`和services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本轮审查文档可能使main docs-only前进，不会改变产品源码。

## 2. D0的真实结果与证据缺口

- Codex本地接收进程摘要报告关联Sandbox / RemoteSession进程数量0，未找到可精确归属的当前窗口；因此**本轮正常关闭请求0次**，没有使用旧PID作为当前身份，也没有force/restart/修改系统服务。
- 本轮**没有生成独立原始空进程快照文件**；进程数量0仅为`CODEX_REPORTED_LOCAL_ONLY`的`session-intake.json`摘要，而不是可由Astra直接审计的原始查询结果，必须保留`MISSING_RAW_PROCESS_SNAPSHOT`限制。
- 唯一既有微软签名`hcsdiag list`只读查询1次，Codex记录返回码`-2143878885`（`0x8037011B`），stdout0字节、stderr仅CRLF2字节；**没有可用guest清单**。未得到这一错误码的独立因果解释，不推断权限、HCS服务、平台损坏或运行状态。空输出不是空guest清单。
- 上次Sandbox探针`Networking Disable`有界PASS仅适用原独立探针实例，未证明新SDK映射实例；上次RemoteSession`CloseMainWindow`已返回true但10秒内未确认退出、最后观测仍存在；本次没有从这个旧事实推定当前guest运行或已结束。二者之间的当前guest状态**UNKNOWN / NOT_CONFIRMED**。
- 由前置D0明确`STOP`，本轮新SDK实例**0/1 NOT_RUN**、Flutter/Dart/JDK/Gradle实机验证0、producer`0/1`、`libs.jar`未生成；正式`resolvePinnedDebugInputs 0/1`、30配置全部`NOT_RUN`，无Flutter AAR、宿主APK、设备、RTC/SFU/DB/API、网络配置或工具升级。ICE诊断Dart参数在已有DAG中仍`targetPath=lib/main.dart`、`dartDefines=null`，`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`继续保留。

## 3. 保护与审查来源分层

- Codex本地保护回执：当前具名原件1115份逐Hash无变动，508 old refs含507旧refs、五历史根原状态保持；前轮20226份只读/复制源保护仅继承旧回执，**本轮没有重新全部逐Hash**。旧SQL/APK、备份、私密env、SDK、未授权part与历史失败未按本次任务授权修改。非作者一次有界静态审阅支持如实停止，但没有现场打开guest或运行HCS。
- GitHub固定对象与公开文档为`ASTRA_GITHUB_DIRECT`；Windows进程摘要/HCS执行与具名保护为`CODEX_REPORTED_LOCAL_ONLY`；独立原始空进程清单属于`MISSING_RAW_EVIDENCE`；探针PASS、GPU来源、DAG等均属于`INHERITED_NOT_RERUN`。Astra没有权限直接观测Owner Windows机器内当前guest状态，不能代替Owner本人确认。

## 4. 正式裁决与Owner门禁

**`BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / SANDBOX_GUEST_SAFE_CLOSURE_NOT_CONFIRMED`**：候选合法交付和停止受支持，但本轮没有证明旧guest已安全退出，不能签`SDK_RUNTIME_READY`、`PRODUCER_PASS`、`30_CONFIG_PASS`或产品`ACCEPTED`。

**本次需要Owner本人核对并明确反馈**：此前唯一无凭据Windows Sandbox探针会话（已登记的专属WSB/RemoteSession）及相关guest是否均安全结束；若Owner仍见该具名隔离窗口，请本人按正常方式关闭并确认状态。不要让Codex从一次失败的`hcsdiag list`反向推断已关闭，不得让新任务自动force kill、提权、重启系统、修改Hyper-V/HCS或网络设置来获得“PASS”。

**直到Owner确认，当前停在`OWNER_MANUAL_CONFIRMATION_REQUIRED`，不发布可立即运行的后继Codex任务、不启动新Sandbox/SDK、producer、resolve或APK。** Owner反馈后，Astra可在保留既有DAG/GPU缓存/产品基线与安全预算的前提下，发布后继单一综合任务；若无法人工确认，先由Owner决定是否授权有界的宿主guest生命周期修复，而不是用下一轮相同只读查询代替人工决定。

最终状态：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。
