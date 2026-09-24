# EliteSync v10｜CURRENT

更新：2026-09-24。此页是本地项目状态快速入口；任务、产品决定、风险门和证据分别见 `TASK_CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`EVIDENCE/`。旧 remote-centric 治理文档仅作历史来源。

本地工作流迁移提交 `1a2ab56be66673b7151ce2d6dac3ca3dae2d7337` 已完成独立本地验收：`EVIDENCE/WORKFLOW-MIGRATION-20260923/summary.md`。该验收不包含 APP-INT-05。

Codex 本地执行入口 `WF-CODEX-01` 已独立 ACCEPT，见 `EVIDENCE/WF-CODEX-01/summary.md`；根 `AGENTS.md` 和项目技能已在全新只读 Codex 任务中核验。

| 项目 | 当前状态 |
|---|---|
| 本地根 / Git | `D:\EliteSync-v10`；本地 `main` 已含工作流迁移及本页状态修订，精确 HEAD 以本地 Git 读取。`origin/main` 本轮未刷新或推送；根目录有无关 untracked `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保留原状。 |
| App 元数据 | Flutter `pubspec.yaml` 声明 `0.07.04+70402`；不是受证分发版本。交接记录 Flutter 3.41.7 / Dart 3.11.5，本轮未重新运行工具链核验。 |
| 最后已接受工程状态 | APP-RUN-01、APP-INT-01～05 已有本地接受记录并进入主线；Android synthetic/dev 四栏与 Readiness → Match → Connection → Messaging consent → Conversation → Home 活态摘要交互。APP-INT-05 集成提交 `03ee72e1abe4e617abc45e9498ec1711ffee9ac9`；验收见 `EVIDENCE/APP-INT-05/summary.md`。 |
| 当前任务 / 门 | `APP-INT-06`～`10`、`SEC-01`～`04`、`CACHE-01`～`06` 已获本地 ACCEPT。CACHE-01 停止旧私密键读写与提前展示；CACHE-02 加入精确清除路径，均无真实设备擦除证明。Owner 允许离线冷启动只读已保存的加密会话/消息/图片视频/草稿，离线不得发送；草稿编辑/写回未授权。Owner 已定在线登录 15 天；第 16～30 天设备仍离线可继续只读，最后一次成功在线登录满 30 天清理加密私密内容，自动 Token 续期不重置计时。CACHE-05 合同及 CACHE-06 隔离纯判定均已获 LEVEL 2 独立接受；真实身份、可靠时间、离线凭据、UI 接线和清理实现未建立。AUTH-01 的一次受限 SSH 尝试使用旧 `codexkey` 对历史候选 `root` 用户认证被拒，远端未核验；事实回执获 LEVEL 2 接受。Owner 随后纠正私钥为 `CodexKey.pem`；AUTH-02 一次严格只读 SSH 核验成功，部署 `AuthController.php` 与本地同哈希，`routes/api.php` 不同哈希，事实回执获 LEVEL 2 接受。AUTH-03 的一次远端路由读取和哈希复核成功，但本地逐行比较脚本失败；Work LEVEL 2 REJECT 具体差异目标，SSH 预算已耗尽。Owner 另行授权的 AUTH-04 已获 Work LEVEL 2 ACCEPT：部署源码相对本地缺少四条 v2 POST 路由及其三个 controller import，另多一条 v1 media `process-demo` POST；`v1/auth/login` 和 `v1/auth/refresh` 静态声明相同。AUTH-05 纯本地静态影响清单亦获 Work LEVEL 2 ACCEPT；四条入口的直接已知消费主要为合成测试，线上运行路由、可信登录事件和真实权限仍未建立。AUTH-06 获 Work LEVEL 2 ACCEPT：部署目录此次 Laravel CLI `api/v2` 路由视图共三条，四条目标 URI 均未出现；Web/HTTP 行为和真实用户影响仍未核验。四条 synthetic/dev-test 路由是否应进入该服务器，待 Owner 环境/发布决策；不据此部署。AUTH-07 本地静态映射已获 Work LEVEL 2 ACCEPT：当前检查的链路未见可信 T0、15 天期限或 30 天密文清理接线；发现 Flutter `auth_interceptor.dart` 打印完整 bearer Token；SEC-05 已获 Work LEVEL 2 ACCEPT，移除了该处完整 bearer Token 调试输出；未做全项目日志或设备旧日志核验。Owner 已确认服务端成功交互登录 `T0`、同账户/设备可验证离线凭据、Token 续期不重置 `T0`，时间不可可靠判断时先锁定并联网重验；AUTH-08 实现前合同已下达，待 Codex 候选和 Work LEVEL 2 门。 |

## Product scope

Relationship Decision Support System；MVP 顶层 `Home | Progress | Messages | Me`。Match、Connection、Conversation、Relationship 权限与生命周期分离；Home 是低密度只读状态投影。Explore、Relationship support 属 Phase 2；AI/reference signals 属 Later/Optional。已接受语义及来源见 `PRODUCT_DECISIONS.md`。

## Flutter

已接受 APP-INT-04：独立消息同意后可在本地 synthetic Conversation 列表/详情读发文本；Connection 关闭后重新锁定。APP-INT-05 Home 随四段状态更新唯一下一步按钮；作者回执报告 targeted tests 17 PASS、Android debug assemble/install/cold launch/main-loop PASS，analyze 为 0 errors、18 条既有 warning/info 且命令退出 1。独立审查静态代码并原样集成，未重跑工具链；这些不是发布证明。

## Backend

仓库有 Laravel 11 代码、历史 Runtime Readiness/Canonical Match synthetic HTTP 与 Product Connection evaluator、mapping、application/persistence 开发态工作。真实 auth/session、Connection/Conversation writer 和生产 backend authority 未建立；APP-T12 的 G-02/03/05/06/08/13 仍须按各自最新证据逐项关闭，不以 synthetic 演示推定关闭。

## DB

Contract/mapping：Product Connection 开发态映射有既有接受链。Local/test：存在 Laravel migrations 与 synthetic/dev-test persistence 证据。Target environment：本轮未核验目标 DB 实例或 migration 执行。Production DB：**NOT ESTABLISHED**；无生产 schema、备份/恢复或真实数据持久化证明。

## Environments / Release

Local synthetic dev：`main_demo.dart` 使用 mock flags 与 loopback，Android API 36 模拟器 debug host 已有运行证明。Invited real beta：auth、server writer、数据权利、运营和分发证据未建立。Public production/staging：本轮没有核验可用实例或部署。当前仅可称生成的 Flutter module Android **debug APK** 曾构建、安装、启动；正式 host、release build、签名和分发均未证明。

## Existing assets / deferred

Date Drop：Flutter 的 Date Drop 卡片目前只查到由 `local_only_visual_fixture_page.dart` 使用，归为旧展示/兼容资产；canonical Match 才是当前核心，legacy participant-linked Match 仅在 inventory、replacement contract、rollback/cutover gate 后退休。旧 Laravel 仍有 weekly drop 相关接口，存在不等于 v10 产品接受。

AI / Relationship：未在当前 Flutter `lib/`、Laravel `app/` 的限定搜索中找到 AI assistant/relationship summary/health score 主流程；有 `relationship_runtime_local_preview_harness.dart`，归为本地 preview/兼容资产。Relationship mutual opt-in 与 AI support 仍为 Phase 2/Later，不能以代码存在升级为 MVP。

Astrology/reference：八字、紫微等页面、服务与 migrations 确实存在，归为旧代码/可复用参考资产；不是强制 Readiness、当前 Match 权威或 Safety 证据。是否接入新的可解释 signal 架构留待独立设计。

## Open observations / blockers

Windows 曾有跨卷 Kotlin incremental-cache、Gradle/Maven TLS 瞬断及模拟器空间不足；APP-INT-05 作者报告复用 C 盘隔离 cache 后构建，卸载旧 synthetic host 后安装成功。约 1.38 GB 为 debug host APK 大小，不是 release 大小。GitHub push 曾因账号 suspended 失败，不阻断本地工作。APP-INT-06 的 targeted tests 报告 4 PASS；一次 Android synthetic/debug 进程退出与冷启动观察显示 `CN_ACTIVE/CV_ACTIVE` 回到重新 seed 的 `CN_NONE/CV_LOCKED`，Home 返回“查看连接”；设备原始日志和截图未保留，未独立复现。Match loading/error 的 Home 为 UNKNOWN、下一步到 Match。以上仅为现有行为基线，不证明恢复能力；G-04/G-09 按历史索引保留 UNKNOWN，G-07 数据权利和其他真实后端缺口不由本轮关闭。

本地 Git 检查点已建立。C: 与项目所在 D: 为不同物理磁盘；完整 Git bundle 保存在 `C:\Users\zcxve\.codex\backups\EliteSync-v10\`，同目录清单记录精确 HEAD、SHA-256 与恢复镜像核验。Git bundle 不包含未跟踪文件；重要材料须先按任务范围纳入 Git。远端仍未同步。

## Unsupported claims / next safe task

不得宣称 production/backend/DB ready、真实用户 beta ready、真实 WebSocket/RTC、签名 release APK/store/deployment ready、Relationship 完成、AI relationship summary 生产可用、玄学匹配权威，或主循环持久化/重启恢复已完成。APP-INT-06～10 已接受；Owner 已授权旧未加密聊天缓存清理，但真实来源、设备恢复仍无实现授权。APP-INT-10 静态审计定位旧写入和登出清理缺口；未证明设备现存内容。CACHE-01 移除两个聊天页面的旧键读写与提前展示；CACHE-02 建立启动及账户边界的精确清除路径，尚无真实设备擦除证明。CACHE-03 的待决材料被 Owner 新离线方向部分更新；CACHE-04 合同只细化离线只读与残余撤权风险，不实施加密缓存、会话有效期或真实恢复。`app_providers.dart`、`session_provider.dart`、`login_form_provider.dart` 的已识别私密调试输出由 SEC-01～04 移除；这不是全项目日志审计。未触碰真实密钥或 token。

证据指针：`EVIDENCE/CACHE-01-LEGACY-PRIVATE-READ-WRITE-CONTAINMENT/summary.md`、`EVIDENCE/CACHE-02-LEGACY-PRIVATE-CACHE-PURGE/summary.md`、`EVIDENCE/CACHE-03-PRIVATE-RESTORE-DECISION-PACKET/summary.md`、`EVIDENCE/CACHE-04-OFFLINE-PRIVATE-READ-BOUNDARY-CONTRACT/contract.md`、`docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`、`ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_ACCEPTANCE_V0_1.md`、`ELITESYNC_V10_APP_INT_04_SYNTHETIC_MESSAGING_CONVERSATION_ACCEPTANCE_V0_1.md`、`ELITESYNC_V10_APP_INT_05_HOME_LIVE_STATE_MAIN_LOOP_INTEGRATION_RESULT_V0_1.md`、`EVIDENCE/APP-INT-05/summary.md`、`docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md`。旧 context/roadmap 只作迁移输入。
