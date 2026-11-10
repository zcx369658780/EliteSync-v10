# EliteSync-v10 项目迁移报告书（DOT 接续）

报告日期：2026-10-02（Asia/Shanghai）。用途：迁移项目上下文、历史决定与工程进度，供 DOT 首次只读接续。本文是说明与导航，不发布运行任务，不改变产品决定或旧预算。

事实基线：GitHub `main` 的 `b70d190a1f005d9aee4b48c5163dc84d076b8752`。本文发布后 HEAD 会前进；接续时核对实际 HEAD，并优先读取根目录五份 authority 的最新顶部及精确任务/验收记录。

## 1. 项目基本情况

EliteSync v10 是以隐私、安全、用户控制为优先的关系决策支持系统。目标是让用户理解当前状态、下一项决定、信息用途/受众，以及暂停、撤回、纠正和退出方式。新版本强调平静、解释性与逐阶段同意，不以更多匹配、消息或停留时长作为产品目标。

v10 从旧版本资产迁移进入架构重置阶段：旧 9.x 的算法、数据知识、视觉参考可有条件复用，旧架构与路线不是新版本权威。准确历史入口见[架构重置交接](../ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)；其中早期运行/备份描述是历史记录，不能替代今天的验收门。

| 项目 | 当前定位 |
| --- | --- |
| GitHub 仓库 | https://github.com/zcx369658780/EliteSync-v10 |
| SSH 地址 | `git@github.com:zcx369658780/EliteSync-v10.git` |
| 原 Windows 实时工作区 | `D:\EliteSync-v10`，分支 `main` |
| 历史旧仓库 | `D:\EliteSync`，不得默认读取、迁移或用作当前 authority |
| 后端源码 | `services/backend-laravel/`，Laravel/PHP |
| Flutter 模块 | `apps/flutter_elitesync_module/` |
| Android 产品 host | `apps/android/` |
| 隔离 synthetic 工程/工具 | `apps/android_synthetic_demo/`；存在源码不等于允许构建/启动 |
| 文档与证据 | `docs/`、`EVIDENCE/<task-id>/` |
| 当前发布能力 | `NOT_READY`；无本轮新增可安装 App、签名 APK、真实内测或生产部署证明 |

DOT 的具体产品版本、运行平台、文件挂载、执行模型与凭据配置尚未提供。上述 Windows 路径是原机器 locator，不是 DOT 主机上已存在的路径。GitHub 同步不复制 SDK、JDK、依赖缓存、设备、凭据或数据库运行环境。

## 2. 关键文档位置与读取顺序

### 2.1 当前权威：先读这五份

| 文件 | 用途 |
| --- | --- |
| [AGENTS.md](../../AGENTS.md) | 工作区、角色、模型分工、任务/交接规则、受保护操作 |
| [CURRENT.md](../../CURRENT.md) | 最新进度与当前停点 |
| [PRODUCT_DECISIONS.md](../../PRODUCT_DECISIONS.md) | Owner 已决定的产品边界及未决事项 |
| [TASK_CURRENT.md](../../TASK_CURRENT.md) | 最新任务状态、准确任务入口、已关闭预算 |
| [REVIEW_GATE.md](../../REVIEW_GATE.md) | LEVEL 0–3、独立审查与现场放行门 |

只消费与当前接续有关的准确材料，不把历史段落中的 `ISSUED` 当作可重新执行的任务。根目录实时状态优先于项目源快照和旧 `CURRENT_*` 文档。

### 2.2 迁移、设计、计划与路线图

| 主题 | GitHub 内准确入口 | 阅读边界 |
| --- | --- | --- |
| 本次 GitHub 同步验收 | [DOT 同步 work-review](../../EVIDENCE/DOT-MIGRATION-GITHUB-SYNC-20261002/work-review.md) | 已完成的机械快照同步 |
| 同步范围/排除项 | [snapshot-manifest](../../EVIDENCE/DOT-MIGRATION-GITHUB-SYNC-20261002/snapshot-manifest.json)、[screening](../../EVIDENCE/DOT-MIGRATION-GITHUB-SYNC-20261002/screening.json) | 不是产品验收或完整外部环境备份 |
| DOT 初始接续 | [handoff-current](../../EVIDENCE/DOT-MIGRATION-GITHUB-SYNC-20261002/handoff-current.md) | 先只读，不自动启动后继 |
| 最近合成启动器验收及下一门 | [M118 work-review](../../EVIDENCE/APP-M5-118-ORIGINAL-SYNTHETIC-LAUNCHER-QUALIFICATION/work-review.md)、[M118 handoff](../../EVIDENCE/APP-M5-118-ORIGINAL-SYNTHETIC-LAUNCHER-QUALIFICATION/handoff-current.md) | SOURCEONLY；其中旧 HEAD 是验收时点，不是未来 HEAD 要求 |
| 完整冻结清单 | [M118 workspace-review](../../EVIDENCE/APP-M5-118-ORIGINAL-SYNTHETIC-LAUNCHER-QUALIFICATION/workspace-review.json)、[同步冻结核验](../../EVIDENCE/DOT-MIGRATION-GITHUB-SYNC-20261002/frozen-sync.json) | 22 项；两旧 bin 不直接补读正文 |
| 7 份 GPT 项目源 | [docs/gpt-project-sources](../gpt-project-sources/) | 多数为 2026-09-27 导航快照；产品设计正文/接受记录为 2026-09-12 |
| 产品设计正文 | [APP feature-design supplement](../architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md) | Owner 接受的产品目标，不是实现完成证明 |
| Owner 设计接受 | [feature-design Owner acceptance](../architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md) | 保存已定范围与保留决定 |
| 产品实施基线路线图 | [APP implementation roadmap](../architecture/ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md) | APP-T01～T12/工作流次序是计划，不是当前派发 |
| 交付节奏/M0–M6 | [delivery plan and roadmap](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md) | 2026-09-21 历史计划来源；不复用其旧排期为新承诺 |
| 历史来源/契约索引 | [evidence and contract index](../architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md) | 索引不是批量读取授权 |
| 任务编写参考 | [delivery workflow/task contract](../architecture/ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md) | 与根目录最新治理共同核对 |
| 旧版本迁移资料 | `docs/archive/migration-9x/`、`docs/archive/source-migration/`、`docs/archive/runtime-history/` | 资产考古/历史证明，不能成为新的当前任务 |

原 9.x 迁移计划入口为[迁移计划](../archive/migration-9x/ELITESYNC_V10_MIGRATION_PLAN.md)与[迁移清单](../archive/migration-9x/ELITESYNC_V10_MIGRATION_MANIFEST.md)。它们说明旧资产如何迁入 v10，与本次迁到 DOT 的控制面接续属于不同阶段。

## 3. 项目源“记忆”的可读取范围

本报告已读取当前项目只读镜像中的 7 份源文档，并与发布到 GitHub 的同名原件核对 SHA-256，7/7 一致，共 52,291 字节：

1. `01_当前入口与状态.md`
2. `02_产品架构与不可变边界.md`
3. `03_文档证据索引与覆盖缺口.md`
4. `04_代理协作与近期路线.md`
5. `05_新版本APP功能设计基线.md`
6. `06_新版本APP功能设计正文_已接受.md`
7. `07_新版本APP功能设计Owner接受记录.md`

镜像目录为原机器 `C:\Users\zcxve\.codex\.chatgpt-projects\g-p-6a894f70a9d081919fe97e22388a1fe1\sources`，只读；发布副本位于 `docs/gpt-project-sources/`。

**未导出的 ChatGPT 长期记忆、网页端项目完整历史聊天不能通过当前工具直接读取。** 因而本文覆盖已导出源文本、仓库 Owner 决策及定点审查记录，不宣称覆盖全部隐含记忆。如果网页端 GPT 顾问掌握尚未写入上述材料的决策，请 Owner 导出补充其日期、原话、依据和未决项，再作为候选增补；不要让其自动覆盖已经接受的决定。

源文档中的“GitHub 当前不可用”“上传前暂停”等是 9 月 27 日快照信息；10 月 2 日已由 SSH 成功连接与本次同步验收更新。源文档保留原样，使用时校正时间语境。

## 4. 历史决策与不能丢失的理由

| 时间/来源 | 决定 | 迁移后应保持的含义 |
| --- | --- | --- |
| 架构重置交接 | v10 建立新产品 authority，旧 9.x 作为资产来源 | 不逐功能复制旧系统，不让旧治理链、旧 API 或旧方案绑住新设计 |
| 2026-09-12 设计及 Owner 接受 | 关系决策支持；Privacy/Safety/User Control 优先 | 不以 engagement 指标替代用户控制和逐阶段同意 |
| 同上 | `Match != Connection != Conversation != Relationship` | 匹配不自动建 Connection，Connection 不自动授权私密对话，聊天不推断 Relationship |
| 同上 | `Home | Progress | Messages | Me` | Progress 为导航容器；Explore/Support Library、Relationship 支持为 Phase 2 |
| 同上 | Private Identity / Matching Inputs / Readiness / Showcase 分离 | MVP 不做全球公开 Profile；不同用途、受众、生命周期分别约束 |
| 同上 | 无单一权威 Compatibility 总分 | 解释依据、约束、来源和不确定性；用户声明和 AI 输出不变成客观事实 |
| 同上 | Safety 与普通 Match/Compatibility/reputation 隔离 | Block != Report；Allegation != Finding；即时保护不等于过错裁决；UNKNOWN != FALSE/SAFE |
| 同上 | AI/人格/星座等属 Later/Optional 的限定参考 | AI 不建立关系事实、人格真相或安全裁决；私密 Conversation 不默认用于 AI、训练、排名或广告 |
| 设计/当前产品决定 | 在线 live read/send 需要当前有效 Connection 与独立消息同意，send 时重查 | Synthetic 测试或旧 matched/conversation 数据不建立可信的 `CN_ACTIVE` / `MC_ACTIVE` 来源 |
| 2026-09-24 PRODUCT_DECISIONS | 在线登录 15 天；最后一次成功在线登录满 30 天清理按账户加密私密内容；第16～30天可在其余条件满足时离线只读 | 离线不发送；Token 自动续期不重置计时；不混淆旧未加密缓存清理与新加密内容保留 |
| 同日 | 服务端成功交互登录建立 `T0`，凭据绑定同账户/设备；时间不可靠先锁定、联网重验 | 这是接受的方向；真实签发/撤销、可靠计时、清理和 UI 接线仍未证明 |
| 2026-09-23 工作流迁移 | 本地五 authority/EVIDENCE 为实时控制面 | GitHub 用于明确授权的备份/里程碑/迁移；远端不可用不阻断纯本地任务 |
| 2026-09-27 Owner | 优先整体软件与后端开发，再考虑加密备份账号回填 | 允许与真实数据隔离的开发；不因此放行真实备份处理或生产改库 |
| 同日 | 回填最低目标：账号、现有密码哈希、昵称、生日、出生地点 | 不处理明文密码；账号集合、两库优先级、最终 schema 与哈希兼容仍待决定 |
| 同日 | 同账号出生地点优先 `users.private_birth_place`，缺失才取 `user_astro_profiles.birth_place`，以后可由用户修改 | 仅适用于这两个承载；不等于跨库来源优先级或真实字段核验 |
| Owner 备份决定 | 完整数据库密文保留在 Owner 本机，保留30天，不云同步 | 已导出/已传输不等于已证明可恢复；真实改库前必须独立验证恢复 |
| 持续推进/交接授权 | 已授权范围由 Work 选择有界后继；普通细节无需重复小授权 | 单次预算、独立审查、重大 Owner 决策和真实/生产保护门仍保留 |
| 2026-10-02 本会话 | 项目源上传、项目快照同步到 GitHub，再准备 DOT 报告 | 明确允许本次文档 commit/normal push；未创建 PR、未恢复自动化、未启动 M112 |

产品设计保留决定还包括：launch segment/资格、最低身份保证机制、Proposal 期限、共享内容/对话保留导出删除、地区法律与运营、Phase 2 工具及 optional signal allowlist。不得在迁移中替 Owner 补定。

关键来源：[产品源摘要](../gpt-project-sources/02_产品架构与不可变边界.md)、[完整设计源](../gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[Owner 接受源](../gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)、[实时 PRODUCT_DECISIONS](../../PRODUCT_DECISIONS.md)、[本地工作流迁移验收](../../EVIDENCE/WORKFLOW-MIGRATION-20260923/summary.md)。

### 4.1 Product Connection 的已接受契约

R17-R3 自包含 mapping 已有接受记录：[result](../architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_RESULT_V0_1.md)、[acceptance](../architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md)。接受 blob 分别为 `813817fdfe4a67c2835021ca64d74d4ed41acc03`、`2b1f23520912517f0e3ae6735208253fbfa37b4f`。

保留 Binding Model A、非权威派生关联与以下区分：projection materialization 不等于 protected use validity；transition admissible 不等于 authoritative state change；当前性/新鲜性、protected binding 和 PRESENT 来源需分别成立。历史 R17/R18 的拒绝不得因后继修复整体追认。真实 Connection writer、消息同意来源、客户端真实消费与部署必须核对自己的准确任务/验收。

## 5. 目前工程进度

### 5.1 已同步的检查点

| 检查点 | 提交/结果 |
| --- | --- |
| 7份项目源文档 | `a8f6ff265cc3c2e809f9dde0b70f985d8ebec813`，原字节一致 |
| Codex 项目进度快照 | `3741c7e6ddd19797982aa582940ae0c09b1a72ba`，963文件，10,690,093 working bytes |
| Work 机械同步验收 | `b70d190a1f005d9aee4b48c5163dc84d076b8752`，远端 main一致，scope缺0/额外0、暂存0 |
| 本报告 | docs-only 新检查点；准确提交看 GitHub 文件历史，不把上一行永久固定成当前 HEAD |

“快照纳入 Git”只说明当前文件被保存；不把所有候选变成已接受实现。历史记录中的“当时未提交”仍描述其验收时点，如今文件已进入快照不反向改变那次记录。

### 5.2 已取得的限定成果与保留缺口

| 工作线 | 已有证据 | 当前限制/入口 |
| --- | --- | --- |
| 产品设计/计划 | Owner 接受设计目标与实施计划基线 | 不证明实现；MVP、邀请制真实内测、公开运营是不同出口 |
| Flutter/AppShell | 有目标导航、synthetic 契约、静态/定向分析与既往测试记录；M5-04显式编译期开关分派到demo | 不证明 AAR带标记、当前可安装/启动；[M5-04](../../EVIDENCE/APP-M5-04-EXPLICIT-SYNTHETIC-DART-ENTRY/work-review.md) |
| Android host | v10 host与生成式 runner定位；synthetic工程/隔离合同逐项准备 | M5/隔离构建仍NOT_READY、settings拒绝、loader-runtime false；[M5-02](../../EVIDENCE/APP-M5-02-ANDROID-HOST-REPO-LOCATOR/work-review.md) |
| 设备观察 | 9月30日 emulator-5554/用户0，当时 synthetic包未安装 | 时点观察不证明现在设备可用或安装成功；[M5-09](../../EVIDENCE/APP-M5-09-SYNTHETIC-PACKAGE-OCCUPANCY/work-review.md) |
| 后端消息保护 | BE-12七条私密路由固定opaque404，限定2tests/24assertions；BE-16过滤revealed/closed公开next_action，限定16tests/223assertions | 没有真实消息读发/生产部署证明，完整套件NOT_RUN；[BE-12](../../EVIDENCE/BE-12-UNVERIFIED-MESSAGING-ROUTE-FAIL-CLOSED/work-review.md)、[BE-16](../../EVIDENCE/BE-16-MATCH-ROUND-NEXT-ACTION-FAIL-CLOSED/work-review.md) |
| 私密账号候选 | AUTH-160五项目标准则docs-only；AUTH-162纯内存同账号四来源修复，18tests/22assertions | 真实来源、最终schema、哈希兼容及账号集合未知；[AUTH-160](../../EVIDENCE/AUTH-160-PRIVATE-ACCOUNT-TARGET-SEMANTICS/work-review.md)、[AUTH-162](../../EVIDENCE/AUTH-162-SYNTHETIC-NAME-SOURCE-BINDING/work-review.md) |
| Kotlin源变换 | 新CRLF变体的M5-73静态及M5-75准确七例测试获限定接受 | M5-50旧LF源码输入适用性阻塞保留；内部scope/anchor/scratch与SDK兼容未查；[M5-50](../../EVIDENCE/APP-M5-50-PURE-SCOPED-KOTLIN-TRANSFORM/work-review.md)、[M5-75](../../EVIDENCE/APP-M5-75-FROZEN-CRLF-TEST-ONCE/work-review.md) |
| Gradle API定位 | M110资格核定原一次JVM/API事实，189fresh文件/115,118,021bytes，188分发classpath，exit0/子stderr0 | 三接口定位不等于Gradle构建或installer运行；M100整task/B仍拒绝；[M110](../../EVIDENCE/APP-M5-110-ORIGINAL-API-SCOPE-QUALIFICATION/work-review.md) |
| 合成installer/harness/launcher | M84、M85及M118资格接受；固定14case契约已准备 | **尚未运行14case**；M118仅SOURCEONLY，M117Work失败不追认；[M118](../../EVIDENCE/APP-M5-118-ORIGINAL-SYNTHETIC-LAUNCHER-QUALIFICATION/work-review.md) |
| 数据库/备份 | 源文本记载主库elitesync与2.6备份库elitesync_restore_2_6的加密导出/传输事实 | 未证明解密、隔离恢复、逐对象/行数比较、无冲突DDL；真实回填/恢复/生产NOT_READY |
| 运行/发布 | 当前源与证据已可从GitHub读取 | 无新增可安装App/完整MVP/签名发布/真实身份与production-ready证据 |

不提供虚假的完成百分比。APP-T01～T12 是产品实施基线；交付计划的 M0～M6 是里程碑；当前 APP-M5-xx 是 M5 的工程子任务，不要与旧工具链 M1/M2/M3混用。历史路线图的工作量/日期只是当时假设，DOT需按当前缺口重新估算。

## 6. 开发工具目录、版本与证据等级

本次仅对已在使用的治理宿主读取版本（PowerShell/Git/SSH）；没有运行 Flutter/PHP/Python/Java/Gradle/adb 或进行外部SDK枚举。其余为已有准确项目文件、配置或历史回执的读取。历史实测不保证新主机/今天仍可用；声明版本也不证明安装或兼容。

| 工具/组件 | 原机器目录或准确入口 | 版本/状态 | 证据 |
| --- | --- | --- | --- |
| Windows治理宿主 | 原工作机 | 本次宿主报告NT 10.0.26200.0 | 2026-10-02本次宿主元数据；不推DOT系统 |
| PowerShell Core | `C:\Program Files\PowerShell\7\pwsh.exe` | **本次实测7.6.6/Core** | 当前治理命令；历史文档的Windows PowerShell5.1另属历史客体 |
| Git | 当前命令入口；绝对exe路径未定点核验 | **本次实测2.53.0.windows.1** | 本次git --version及正常push |
| OpenSSH | 当前命令入口；绝对exe路径未定点核验 | **本次实测OpenSSH_for_Windows9.5p2 / LibreSSL3.8.2** | 本次ssh -V；GitHub连接成功 |
| GitHub SSH key | `C:\Users\zcxve\.ssh\id_ed25519` | 默认指定key/已用于GitHub认证；无私钥内容读取 | 不把key上传到GitHub或直接复制给DOT |
| Flutter | `D:\flutter\bin\flutter.bat` | 历史实测3.41.7 stable，framework cc0734ac71，engine59aa584fdf | T1，2026-09-13；今天未重测 |
| Dart | `D:\flutter\bin\dart.bat` | 历史实测3.11.5 stable/windows_x64；项目约束`^3.11.3` | T1、模块pubspec.yaml；约束不是安装版本 |
| CPython | `C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe` | 历史静态探针记录3.11.9/64bit；M5静态/测试launcher固定该入口 | T2；今天未重测，不证明真实Job/FFI能力 |
| PHP CLI | `C:\tools\php85\php.exe` | 历史记录8.5.3/NTS/VC++2022 x64 | T3；不推云端PHP或今天兼容 |
| Composer | 历史composer命令入口，绝对启动器目录未记录 | 历史记录2.9.5（PHP8.5.3） | T3；不能据此猜ProgramData或PATH |
| Laravel | `services/backend-laravel/` | 当前composer.lock锁定v11.48.0 | 本次锁文件读取；不等于当前服务在运行 |
| PHPUnit | `services/backend-laravel/vendor/bin/phpunit`（若依赖已恢复） | 当前lock11.5.55，项目约束`^11.0.1`；历史版本回执11.5.55 | T4；Git克隆不保证vendor存在 |
| Gradle | 见6.1准确分发目录；`apps/android/gradle/wrapper/gradle-wrapper.properties` | Wrapper声明8.14-all；不是本次Gradle --version实测 | T5；不得自动下载或执行wrapper |
| Groovy | 见6.1的groovy-3.0.24.jar | M110原调用实测3.0.24 | T6；不是今天新JVM观察 |
| Java/Temurin JDK | `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe` | M110原调用Java17.0.18/runtime17.0.18+8 | T6；不等于SDK/Gradle构建兼容通过 |
| AGP/Kotlin | `apps/android/build.gradle.kts` | **配置声明**AGP8.11.1/Kotlin2.2.20 | T5；不推插件已解析或完整工具链兼容 |
| Android SDK | `C:\Users\zcxve\AppData\Local\Android\Sdk` | 历史准确locator；Build Tools/NDK/platform包/许可当前未核 | T7；不是可运行证明 |
| adb/模拟器 | `C:\Users\zcxve\AppData\Local\Android\Sdk\platform-tools\adb.exe` | 当时模拟器SDK level36；adb版本、当前设备状态未重测 | T7；level36不等于SDK工具链版本 |
| Android Studio | 准确安装目录/版本未在所读材料建立 | UNKNOWN / NOT_CHECKED | 不能从有SDK推IDE版本 |
| NDK/CMake | 准确目录/版本未建立 | UNKNOWN / NOT_CHECKED | 不枚举SDK/缓存补猜 |
| Node.js | 准确目录/版本未建立 | UNKNOWN / NOT_CHECKED | 无本次Node运行 |
| DOT | Owner指定迁移目标，平台与版本未提供 | UNKNOWN | 接续时先确认执行能力与仓库位置 |

工具来源：

- T1：[Flutter工具链记录](../architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md)，[pubspec.yaml](../../apps/flutter_elitesync_module/pubspec.yaml)。
- T2：[AUTH-176静态探针摘要](../../EVIDENCE/AUTH-176-SYNTHETIC-CTYPES-LAYOUT-PROBE/summary.md)，[AUTH-121准确解释器记录](../../EVIDENCE/AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY/plan.md)，[M74 launcher](../../EVIDENCE/APP-M5-74-STABLE-TEST-LAUNCHER-SOURCE/Invoke-CrlfTest.ps1)。
- T3：[后端依赖准备历史](../archive/runtime-history/ELITESYNC_V10_BACKEND_DEPENDENCY_PREPARATION_REPORT.md)，[R18-R1历史PHP/Composer记录](../architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_RESULT_V0_1.md)。
- T4：[composer.lock](../../services/backend-laravel/composer.lock)、[composer.json](../../services/backend-laravel/composer.json)、[PHPUnit历史](../architecture/ELITESYNC_V10_IP_11F_BACKEND_VENDOR_BOOTSTRAP_AND_PHPUNIT_READINESS_REMEDIATION_RESULT_V0_1.md)。
- T5：[Android build.gradle.kts](../../apps/android/build.gradle.kts)、[Gradle wrapper](../../apps/android/gradle/wrapper/gradle-wrapper.properties)。
- T6：[M87准确三文件元数据](../../EVIDENCE/APP-M5-87-OWNER-EXACT-RUNTIME-METADATA/runtime-metadata.md)、[M90准确188 jar TSV](../../EVIDENCE/APP-M5-90-EXACT-188-JAR-IDENTITY/jar-identities.tsv)、[M110独立原运行资格](../../EVIDENCE/APP-M5-110-ORIGINAL-API-SCOPE-QUALIFICATION/work-review.md)。
- T7：[M5-08历史模拟器观察](../../EVIDENCE/APP-M5-08-EMULATOR-READONLY-PREFLIGHT/summary.md)、[M5-09准确包占用](../../EVIDENCE/APP-M5-09-SYNTHETIC-PACKAGE-OCCUPANCY/work-review.md)。

### 6.1 下次合成运行的准确 locator

分发lib根：

```text
D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib
```

Groovy jar为上述根下 `groovy-3.0.24.jar`，8,056,938bytes，SHA256：

```text
ABDADFFEB2CE15E375F16B13F5BBE634C30B54791D62DA38BD4AD3D5A4E89DA9
```

Java启动文件50,344bytes，SHA256：

```text
5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B
```

准确188个jar以[原TSV](../../EVIDENCE/APP-M5-90-EXACT-188-JAR-IDENTITY/jar-identities.tsv)为准，TSV19,534bytes/hash `E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80`。188分发jar合计115,067,677bytes，加Java为189files/115,118,021bytes。早期M87的classpath缺口后由M88/M90清单与M110原运行事实补充，不能把早期未知原封当成当前完整清单不存在。

历史generated Gradle API jar locator是 `D:\GradleHome\caches\8.14\generated-gradle-jars\gradle-api-8.14.jar`；其加入曾引发SLF4J重复绑定stderr。当前分发专用方案**不读取、不加入该cache jar**。不能用 `lib\*`、邻库猜测、PATH/环境/注册表/HOME/cache搜索扩大输入范围。

这只是下一任务的准确文字输入。新任务仍须fresh身份核定与自己的单次运行预算；在DOT主机上不存在这些路径时报告阻塞，不擅自换路径、下载、安装或启动JVM。

## 7. 接续状态、下一门与操作边界

当前迁移同步已结束；本报告只补充文档。自动化仍PAUSED，没有新的产品/运行任务。既有执行Codex为 `01a0f74b-03a7-7d41-8185-9c47d92ab428/local`；最近同步turn `01a0f9f6-85b0-7e71-8cf0-2d42b2765b02` completed/error=null/idle。这些是原Codex会话标识，不是假定DOT可直接使用的API。

下一工程候选为 **M112单次合成installer测试**，准确root/task `APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE`，目前root/task/authority未建、未发布、未派发：

1. 先只读恢复状态、核当前仓库/HEAD/dirty与22冻结身份、检查原执行会话；保留排除项。
2. 由Work在原持续授权及现时环境成立时另发一张新bounded task，准确14键authority与单次189外部fresh身份输入。
3. 精确固定M85 harness/M84 installer/M117交付且M118资格接受的launcher；一JVM、installer两阶段读取（launcher1、child1）、parseClass1、14次synthetic proxy调用。
4. 首失败关闭该预算，保留partial，关闭未执行项；不修改缩短、补查、修补重跑或因失败换会话。
5. 作者交付后独立GPT-6.1 Sol/high限定只读审查，再由Work原完整证据独立LEVEL2终裁；NO_FINDINGS不代终裁。
6. 即使14case成功，也只证明synthetic范围。真实binding-ID-path-hook、四project事务、LibraryExtension时序、SDK兼容、真实权限及生产门仍另审。

准确源码/长度/hash和未来字段见[M118接续](../../EVIDENCE/APP-M5-118-ORIGINAL-SYNTHETIC-LAUNCHER-QUALIFICATION/handoff-current.md)。B验证必须用实际 `TestSchemaChecked`、`HarnessSourceRead`、`HarnessCopies`、`LocalInstallerPreflightRead`、`CandidateParseClassLoad` 等字段，不猜旧 `SchemaChecked`。

持续保留 `NOT_READY`、父stderr UNKNOWN、OS硬截止/文件网络隔离NOT_PROVEN、SDK/内部scope NOT_CHECKED、未实测失败路径NOT_EXERCISED、implicit JVM/native loads NOT_MEASURED；M118完整源码nativeAdd字节证明NOT_PROVEN、预写hashNOT_MEASURED。不重开M93/M100/M111/M113/M115/M117及其他旧拒绝预算。

迁移不放行真实数据、备份/密钥、生产DB/API/SSH、数据库解密恢复、自动下载安装、SDK/cache配置、邻源索引或旧仓访问。UAC仍需当前Owner明确“我在”及准确具体授权。普通本地小范围授权不替代这些门。

## 8. GitHub 快照没有迁入的内容

七项排除条目均保留原工作区，未删除/移动/清理：

- `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`：无关嵌套Git仓。
- `EVIDENCE/APP-M5-07-SYNTHETIC-BOOTSTRAP-ENDPOINT-POLICY/out/policy-tests.jar`：编译产物。
- `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/test_run.cpython-311.pyc`：缓存。
- `EVIDENCE/AUTH-154-TWO-DB-ACCOUNT-STRUCTURE-AUDIT-PATH/plan.md`、`task.md`、`work-review.md`：三份受保护server/DB证据。
- `EVIDENCE/WORK-HANDOFF-20260926-DB-BACKUP/handoff.md`：受保护备份交接。

列表引用不授权打开保护材料。本轮没有迁移真实密文、私钥、.env、账号值、依赖缓存或运行设备。真实备份验证若必须消费缺失材料，由Owner按受保护范围另行提供。GitHub快照不能称完整恢复证明或独立存储的全环境备份。

## 9. DOT 首次接续的验收结果

首次只读接续应返回：

- 实际仓库位置、分支、HEAD与本报告基线关系；
- 五份最新authority/精确验收对当前active task的判定；
- SOURCEONLY/原运行事实/真实能力三个层次与关键阻塞；
- 原Windows locator在DOT环境是否可消费，未核项明确保留；
- 未导出记忆/保护材料是否需要Owner补充；
- 下一张可安全推进的bounded task建议，不自行恢复自动化或运行M112。

报告事实由主Work汇总核定；两名只读助手提供历史源与工具记录提取，没有委派实现或运行。本文发布前检查准确引用路径、文档差异和同步远端；不借文档任务复跑历史测试或补环境调查。
