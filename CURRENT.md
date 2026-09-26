# EliteSync v10｜CURRENT

更新：2026-09-25。此页是本地项目状态快速入口；任务、产品决定、风险门和证据分别见 `TASK_CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`EVIDENCE/`。旧 remote-centric 治理文档仅作历史来源。

**本次 Work 交接停点**：AUTH-101 仅 Phase A 静态候选获 LEVEL 3 ACCEPT；Phase B 未放行、未执行，旧 AUTH-99 候选仍禁止运行。Owner 要求本长会话在验收、保存本地状态后立即交接，本会话不下达后继任务。下一 Work 会话先独立读取本地五份入口文件、Git/工作区及 AUTH-101 证据，再决定是否对同一任务放行一次 Owner 在场的虚构 CMS 演练；不得借交接自动消耗 UAC、BitLocker 或密码输入预算。见 `EVIDENCE/WORK-HANDOFF-20260925-AUTH101/handoff.md`。

**新 Work 会话核验与治理更新（2026-09-25）**：已独立核对本地 `main` HEAD `c54ece3887d95829fc7fbfd090a37464565d9305`、仅两个既有无关未跟踪目录、AUTH-101 Phase A 证据与候选/固定 OpenSSL 哈希；跨磁盘 bundle 哈希及 `git bundle verify` 通过，该 bundle 仅覆盖修改前的精确 HEAD，不包含本轮未提交的文档修改。Owner 新定的 Work/Codex 会话超过 30 条或明显过长即交接、Codex 复用最新合资格会话规则见根 `AGENTS.md`，取代下方历史“约 20 张任务”会话安排。本次新 Work 会话尚未达到交接阈值；依 Owner 指令，规则更新后暂停，等待后续指令。AUTH-101 Phase B 仍未放行，预算未使用；本轮未查询 BitLocker、启动脚本、触发 UAC 或 OpenSSL CMS。

**Codex 接续与当前派发（2026-09-25）**：Owner 已指示交接过长的最新 Codex 执行会话并继续下达任务单。新会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115` 已在实时项目完成只读交接；旧会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。现仍为同一 AUTH-101，`TASK_CURRENT.md` 仅派发临运行只读复核与有限回执，供 Work 独立 LEVEL 3 裁决；Phase B 未放行，所有一次运行预算仍为 0/1。现有未提交文档修改与两个无关未跟踪目录保留。

**本次只读复核验收（2026-09-25）**：新 Codex 会话已交 AUTH-101 临运行有限回执，Work LEVEL 3 接受该回执并在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/pre-run-recheck.md` 记录审查与并发余量。候选与 OpenSSL 哈希匹配、E: 有限元数据由作者在单轮普通权限下报告匹配、任务 Temp 当时不存在。Owner 本人在电脑前仍未核实，**Phase B 不放行**；无 UAC、BitLocker 查询、CMS 或比较运行，预算均 0/1。下一步只在 Owner 到场且动态条件仍匹配时由 Work 再作放行裁决；不得向旧会话派发或运行 AUTH-99。

**AUTH-101 Phase B 单次放行（2026-09-25）**：Owner 后续确认本人在电脑前、无录屏/屏幕共享、可核对 UAC 与原生非回显提示。Work 对照上个 Codex 会话和 AUTH-92/97～101 本地证据，重新核对固定候选/OpenSSL 哈希、Kingston E: 与两份精确文件有限身份及任务 Temp 不存在；在 `pre-run-recheck.md` 记录 LEVEL 3 裁决。仅放行 Owner 从 Explorer 单次手动启动 AUTH-101 固定 CMD；脚本仍须通过当前 BitLocker 保护门，任何失败或提示异常即止且不重试。**放行不等于已执行**，目前手动启动/UAC/BitLocker/CMS/比较预算均 0/1；AUTH-92 的 C: 私钥往返和 AUTH-97 的 E: 字节相等不代替本次 E: 私钥 CMS 演练。旧 AUTH-99 继续禁止运行。

**AUTH-101 Phase B 执行验收（2026-09-25，当前结论）**：Owner 报告单次可见入口结果 `AUTH101_RESULT=A_MATCH_AND_CLEAN;EXIT=0`；Work 独立核对固定脚本/工具哈希未变、指定任务 Temp 目录已清理、E: 两精确副本有限身份及本机源私钥 ACL 未变，在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/plan.md` 作 LEVEL 3 **ACCEPT 仅本次 E: 副本虚构 CMS 往返**。启动、UAC/BitLocker 查询、CMS 加密/解密及比较各 1/1 预算已耗尽，不重跑。旧 AUTH-99 仍禁止运行；U 盘重插密码解锁、纸质 BitLocker 恢复密钥、真实数据库备份/恢复均未证明。

**当前任务 AUTH-102（2026-09-25）**：Owner 要求继续推进真实阿里云数据库备份准备。已向同一新 Codex 执行会话下达 `AUTH-102-DB-BACKUP-TARGET-IDENTITY-PREFLIGHT` Phase A 本地静态候选任务，见 `TASK_CURRENT.md`；只设计部署目录 CLI 与运行中 Web worker 有效 DB 目标、备份账号权限/对象范围的最小只读核验及失败停点，不连接服务器或真实数据库。AUTH-20/65/67 的可见聚合不能证明目标同一或完整备份范围。最早的真实备份须另经目标/权限/范围、一致性、服务器侧加密与本地密文传输、隔离恢复准备各门和 Owner LEVEL 3 单次授权；目前没有日历时间可据实承诺。

**AUTH-102 审查结论（2026-09-25，当前状态）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-102-DB-BACKUP-TARGET-IDENTITY-PREFLIGHT/plan.md` 的本地静态预检方案，仅确认下一步核验边界。现有本地 v2 健康入口不查 DB，v1 只做 `select 1`，都不能证明部署运行中 Web worker 与 CLI 同库；拟备份账号完整权限及外部数据范围也为 `UNKNOWN`。没有 SSH、Web 诊断、真实 DB、备份、传输或恢复。生产诊断方式与受限调用须另立具体任务并过风险门；真实加密完整备份目前未获放行。

本地工作流迁移提交 `1a2ab56be66673b7151ce2d6dac3ca3dae2d7337` 已完成独立本地验收：`EVIDENCE/WORKFLOW-MIGRATION-20260923/summary.md`。该验收不包含 APP-INT-05。

Codex 本地执行入口 `WF-CODEX-01` 已独立 ACCEPT，见 `EVIDENCE/WF-CODEX-01/summary.md`；根 `AGENTS.md` 和项目技能已在全新只读 Codex 任务中核验。

**Owner 到场规则（2026-09-25）**：Owner 目前不会随时在电脑旁。后继步骤凡可能触发 UAC，必须在触发前停下，待 Owner 在当前 Work 会话明确输入“我在”后才按独立任务和风险门继续；先前 AUTH-101 的到场确认不得复用。当前可继续无需 UAC、无需现场连接的备份准备。此规则见根 `AGENTS.md`。

**当前任务 AUTH-103（2026-09-25）**：已向最新合资格 Codex 执行会话下达 Web worker 有效 DB 连接身份诊断的 Phase A 本地静态设计任务，详见 `TASK_CURRENT.md`。本轮只准备可审查方案，无 SSH、HTTP、Laravel CLI、真实 DB、部署或备份。AUTH-102 的接受不放行现场连接；真实备份的目标、权限、范围、一致性和恢复门仍未关闭。

**AUTH-103 审查与当前 AUTH-104（2026-09-25）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-103-WEB-DB-IDENTITY-DIAGNOSTIC-DESIGN/plan.md`，仅限本地静态诊断设计；Web/CLI 同库仍 UNKNOWN，生产诊断、数据库侧会话观察和部署均未放行。现已向同一最新合资格 Codex 会话下达 AUTH-104 本地静态对象全集、备份账号权限及外部数据类别预检设计，见 `TASK_CURRENT.md`。本轮仍无真实连接、UAC 或备份。

**AUTH-104 审查结论（2026-09-25，当前停点）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-104-DB-BACKUP-OBJECT-SCOPE-PREFLIGHT-DESIGN/plan.md`，仅是本地静态对象全集与拟备份账号权限预检设计。真实权威对象全集、账号逐项权限、dump 版本/选项、Web/CLI 同库、非 DB 范围与一致性仍 UNKNOWN。AUTH-103/104 均无可运行现场探针，未发生产诊断或真实备份任务。下一阶段须先形成具体实现与权限/隐私/回退方案，再经对应风险门；Owner 对“完整数据库”与外部文件的范围定界已询问，等待回复。可能触发 UAC 的动作继续按到场规则停在触发前。

**AUTH-105 当前派发（2026-09-25）**：Owner 要求继续推进。已在 `TASK_CURRENT.md` 向同一最新合资格 Codex 会话下达 MariaDB 10.11 官方文档核对与备份选项/权限本地静态候选；允许公开官方资料读取，不连接阿里云服务器或真实 DB，不触发 UAC、备份或传输。AUTH-103/104 的静态接受仍不放行现场动作；“完整数据库”与外部文件边界待 Owner 回复。

**AUTH-105 验收与当前 AUTH-106（2026-09-26）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-105-MARIADB-DUMP-OPTION-AND-PRIVILEGE-SOURCE-CHECK/plan.md`，仅限 MariaDB 官方文档的静态选项/权限核对；在线文档不是目标主机 10.11.14 固定快照，当前工具支持项、账号权限及完整对象仍 UNKNOWN。现向同一最新合资格 Codex 会话下达 AUTH-106：本地严格解析器及纯虚构帮助文本测试，见 `TASK_CURRENT.md`。本轮禁止真实主机访问、UAC 和备份。

**AUTH-106 验收与当前 AUTH-107（2026-09-26）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-106-DUMP-TOOL-HELP-STRICT-PARSER/summary.md`，仅限纯函数对虚构帮助文本的拒绝边界；Work 独立复跑 20 项虚构检查 PASS。人工帮助布局不代表目标主机真实输出，工具现时能力仍 UNKNOWN。现向同一 Codex 会话下达 AUTH-107 Phase A 单次只读主机工具观察的本地候选设计，详见 `TASK_CURRENT.md`；本轮不放行 SSH、真实工具、UAC 或备份。

**AUTH-107 与本次 Work 交接（2026-09-26）**：Work LEVEL 2 仅接受 `EVIDENCE/AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE/plan.md` 的 Phase A 静态调用边界；作者的唯一虚构测试提前失败，修正后未复跑，`projector.py` 不算已验证采集器。无可运行 SSH/远端程序，Phase B 未放行。当前 Work 会话已较长，按根 `AGENTS.md` 在本地记录后交给 Owner 手动开启新 Work 会话；本次交接不下达新任务、不重置 AUTH-101、AUTH-17、AUTH-107 等预算。下一 Work 会话先独立核对本地 Git/工作区及 AUTH-105～107，再决定独立新任务来实现并验证受限采集器；不得将 AUTH-107 静态接受当作 SSH 授权。Owner 尚未回复“完整数据库”是否包含外部文件的范围问题，且未在本会话为后续 UAC 现场步骤回复“我在”。

**2026-09-26 交接纠正（当前有效）**：Owner 指出本 Work 会话约 10 次往返，未达 30 条门槛，且工具调用多不等于上下文已无法可靠工作。前述 AUTH-107 “本次 Work 交接”决定和交接 prompt **撤回**；没有发生新 Work 会话交接，本会话继续推进。历史检查点与 bundle 保留为已完成工作记录，不据此重置任何预算。根 `AGENTS.md` 已明确对话计数口径；AUTH-107 的受限静态 ACCEPT、测试 NOT_VERIFIED 与 Phase B 未放行结论保持有效。

**当前任务 AUTH-108（2026-09-26）**：在交接纠正后继续沿用最新合资格 Codex 会话，已下达 `AUTH-108-BOUNDED-TOOL-CAPTURE-SYNTHETIC`，见 `TASK_CURRENT.md`。仅在本地用虚构子进程实现/验证双流限额、超时、退出码和原文不泄漏；不连接 SSH/DB、不运行真实 dump 工具、不触发 UAC。AUTH-107 的 1/1 失败测试预算不重置，Phase B 仍未放行。

**AUTH-108 审查结论（2026-09-26，当前状态）**：Work LEVEL 2 接受 `EVIDENCE/AUTH-108-BOUNDED-TOOL-CAPTURE-SYNTHETIC/summary.md`，仅限本地虚构子进程的双流有界采集核心；作者 10 项和 Work 独立 10 项均通过。测试后新增的管道关闭失败分类已包含在 Work 复跑版本中，但终止失败、子孙进程和其他系统行为仍 UNKNOWN。没有 SSH、真实 dump、DB、UAC 或备份；AUTH-107 Phase B 仍未放行。前述过早交接已撤回，本 Work 会话继续；Owner 对数据库外文件范围的答复仍待收到。

**当前任务 AUTH-109（2026-09-26）**：Owner 同意继续推进，已向同一合资格 Codex 会话下达有界采集与固定脱敏投影的本地虚构集成任务，见 `TASK_CURRENT.md`。AUTH-108 只返回类别/计数，不能安全地把原始字节交给 AUTH-107 投影器；本任务在受控进程内验证衔接，不连接 SSH/DB、不运行真实 dump 工具或 UAC。AUTH-107 Phase B 与真实备份均未放行。

**AUTH-109 审查结论（2026-09-26）**：Work LEVEL 2 受限 ACCEPT `EVIDENCE/AUTH-109-BOUNDED-CAPTURE-SAFE-PROJECTION-SYNTHETIC/summary.md` 的本地虚构集成；Work 独立复跑 12 项通过。真实工具身份/帮助格式、环境净化、SSH、目标及权限仍 `UNKNOWN`，AUTH-107 Phase B、真实备份及 UAC 均未放行。两个无关未跟踪目录保留；本 Work 会话继续，未达必须交接门槛。

**当前任务 AUTH-110（2026-09-26）**：AUTH-109 已进入本地 `main` 检查点 `908e4d4bacccad17b627bfbd5907fc2dd7a0312b`；跨磁盘 bundle `C:\Users\zcxve\.codex\backups\EliteSync-v10\2026-09-26-main-908e4d4.bundle` 的 SHA-256 为 `9D6EF4D16918995F03ACBBC4D39B1C079C497BD286B3C66B5E827E1BFCF36304`，`git bundle verify` 通过。已向同一合资格 Codex 会话下达 `AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC`，只做本地纯虚构字节接收解析；不启动 SSH/工具或触发 UAC，见 `TASK_CURRENT.md`。检查点 bundle 不含这张新任务单的未提交修改，也不含两个无关未跟踪目录。

**AUTH-110 审查结论（2026-09-26）**：Work LEVEL 2 受限 ACCEPT `EVIDENCE/AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC/summary.md` 的纯虚构传输解析；Work 独立复跑 42 项通过。没有 SSH、真实远端程序、工具、DB 或 UAC；输入字节及双层退出码的真实来源仍 `UNKNOWN`，AUTH-107 Phase B 和真实备份未放行。

| 项目 | 当前状态 |
|---|---|
| 本地根 / Git | `D:\EliteSync-v10`；本地 `main` 已含工作流迁移及本页状态修订，精确 HEAD 以本地 Git 读取。`origin/main` 本轮未刷新或推送；根目录有无关 untracked `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保留原状。 |
| App 元数据 | Flutter `pubspec.yaml` 声明 `0.07.04+70402`；不是受证分发版本。交接记录 Flutter 3.41.7 / Dart 3.11.5，本轮未重新运行工具链核验。 |
| 最后已接受工程状态 | APP-RUN-01、APP-INT-01～05 已有本地接受记录并进入主线；Android synthetic/dev 四栏与 Readiness → Match → Connection → Messaging consent → Conversation → Home 活态摘要交互。APP-INT-05 集成提交 `03ee72e1abe4e617abc45e9498ec1711ffee9ac9`；验收见 `EVIDENCE/APP-INT-05/summary.md`。 |
| 当前任务 / 门 | `APP-INT-06`～`10`、`SEC-01`～`04`、`CACHE-01`～`06` 已获本地 ACCEPT。CACHE-01 停止旧私密键读写与提前展示；CACHE-02 加入精确清除路径，均无真实设备擦除证明。Owner 允许离线冷启动只读已保存的加密会话/消息/图片视频/草稿，离线不得发送；草稿编辑/写回未授权。Owner 已定在线登录 15 天；第 16～30 天设备仍离线可继续只读，最后一次成功在线登录满 30 天清理加密私密内容，自动 Token 续期不重置计时。CACHE-05 合同及 CACHE-06 隔离纯判定均已获 LEVEL 2 独立接受；真实身份、可靠时间、离线凭据、UI 接线和清理实现未建立。AUTH-01 的一次受限 SSH 尝试使用旧 `codexkey` 对历史候选 `root` 用户认证被拒，远端未核验；事实回执获 LEVEL 2 接受。Owner 随后纠正私钥为 `CodexKey.pem`；AUTH-02 一次严格只读 SSH 核验成功，部署 `AuthController.php` 与本地同哈希，`routes/api.php` 不同哈希，事实回执获 LEVEL 2 接受。AUTH-03 的一次远端路由读取和哈希复核成功，但本地逐行比较脚本失败；Work LEVEL 2 REJECT 具体差异目标，SSH 预算已耗尽。Owner 另行授权的 AUTH-04 已获 Work LEVEL 2 ACCEPT：部署源码相对本地缺少四条 v2 POST 路由及其三个 controller import，另多一条 v1 media `process-demo` POST；`v1/auth/login` 和 `v1/auth/refresh` 静态声明相同。AUTH-05 纯本地静态影响清单亦获 Work LEVEL 2 ACCEPT；四条入口的直接已知消费主要为合成测试，线上运行路由、可信登录事件和真实权限仍未建立。AUTH-06 获 Work LEVEL 2 ACCEPT：部署目录此次 Laravel CLI `api/v2` 路由视图共三条，四条目标 URI 均未出现；Web/HTTP 行为和真实用户影响仍未核验。四条 synthetic/dev-test 路由是否应进入该服务器，待 Owner 环境/发布决策；不据此部署。AUTH-07 本地静态映射已获 Work LEVEL 2 ACCEPT：当前检查的链路未见可信 T0、15 天期限或 30 天密文清理接线；发现 Flutter `auth_interceptor.dart` 打印完整 bearer Token；SEC-05 已获 Work LEVEL 2 ACCEPT，移除了该处完整 bearer Token 调试输出；未做全项目日志或设备旧日志核验。Owner 已确认服务端成功交互登录 `T0`、同账户/设备可验证离线凭据、Token 续期不重置 `T0`，时间不可可靠判断时先锁定并联网重验；AUTH-08 实现前合同已获 Work LEVEL 2 ACCEPT；AUTH-09 隔离 synthetic 登录锚事件纯判定获 Work LEVEL 2 ACCEPT，独立复跑 13/13 测试；只处理调用方声明，未验证服务端来源或形成真实读发权限。AUTH-10 docs-only 持久化与未来数据库备份/恢复设计获 Work LEVEL 2 ACCEPT；AUTH-11 一次部署目录迁移账本只读观察获 Work LEVEL 2 事实回执 ACCEPT，但输出未通过安全解析，四条迁移状态仍 UNKNOWN、SSH 预算已耗尽；AUTH-12 本地输出解析预检合同获 Work LEVEL 2 ACCEPT；AUTH-13 本地严格解析器与 12 项合成测试获 Work LEVEL 2 ACCEPT；AUTH-14 获 Work LEVEL 2 ACCEPT：一次部署目录 CLI 迁移账本视图经严格解析，四条目标均 Ran、57/57 已运行；原始输出未保存且未核验实际表结构或备份；AUTH-15 本地固定范围 schema 元数据探针预检获 Work LEVEL 2 ACCEPT；AUTH-16 获 Work LEVEL 2 ACCEPT：本次 CLI 连接固定元数据投影报告 MySQL、三张指定表、14 个指定字段和两个单列唯一索引存在；原始输出未保存，实例身份和整库结构仍 UNKNOWN；AUTH-17 备份主机工具与空间只读核对获 Work LEVEL 2 ACCEPT：当次见 mysqldump 10.11.14、/var/backups 存在且当前用户 test -w 通过、可用 27,151,868 KiB；不证明可完整备份或恢复；AUTH-18 备份/恢复演练 docs-only 后继任务链方案获 Work LEVEL 2 ACCEPT；AUTH-19 本地固定目标/规模元数据探针及 22 项虚构检查获 Work LEVEL 2 ACCEPT；AUTH-20 获 Work LEVEL 2 ACCEPT：当次 CLI 连接报告 MariaDB 10.11.14、固定目标指纹、43 个 information_schema 条目及 7,176,192 bytes 估算；未证明 Web worker 同库、完整 dump 大小或恢复能力；备份保留 30 天已获 Owner 决定，存放位置与加密细节仍待定；目标 DB 现状、备份/恢复能力、凭据协议、可靠时间和真实 auth/缓存接线仍未建立。AUTH-21 本地虚构 SQLite 持久化预检已获 Work LEVEL 2 ACCEPT，26 项虚构检查由作者报告 PASS；真实来源和运行接线仍未建立。 |

AUTH-22 阿里云备份准备决策包已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-22-ALIYUN-BACKUP-READINESS-DECISION-PACKET/packet.md`。Owner 已定阿里云内加密保留 30 天，并选择优先核验私有 OSS 与受管密钥的可用性；恢复演练按阿里云内独立隔离目标设计，演练副本恢复后清理，完整备份自完成日起保留 30 天并核对清理回执。AUTH-23 一次只读主机命令存在性回执已获 Work LEVEL 2 ACCEPT：当前 shell 中 `ossutil`、`aliyun` 未解析到，`openssl` 可解析；未核验实际 OSS/KMS 资源。真实备份与恢复尚未执行。

AUTH-24 阿里云备份资源与费用选择包已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md`。当次控制台观察：上海轻量应用服务器公网 IP 与授权目标一致；该账号 OSS 页面提示尚未开通且开通后默认按量付费；上海 KMS 软件实例列表无记录、用户主密钥 0；ECS 上海列表未见实例；RDS 列表未完成加载，保持 `UNKNOWN`。这只是指定页面和时点的 UI 事实，不证明全局资源、权限、真实 DB 目标、报价或备份/恢复能力。下步可只读核验优先路线的资源开通条件、权限要求与官方计费项；实际开通、创建和费用由 Owner 决定。

**Owner 后续改定（2026-09-24）**：因 OSS 为付费服务，完整数据库备份改为加密保存到 Owner 的电脑或本地磁盘，不采用尚未开通的 OSS 作为当前方案。此前“完整备份仅在阿里云内保存”及 OSS/KMS 优先路线被此决定取代；加密、自完成日起保留 30 天、真实改库前先备份并验证可恢复的要求继续有效。Owner 此次未改变阿里云内独立隔离恢复演练及演练副本清理方向，该部分可能另有费用，仍待具体方案与费用边界决定。没有执行备份、传输、恢复或删除；本地精确存放位置、密钥保管、传输方式、数据类别与恢复路径尚未确定。完整备份不得进入 Git、Git bundle、普通证据或任何第三方云服务。

AUTH-25 本地加密备份实施前方案已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-25-LOCAL-ENCRYPTED-DB-BACKUP-PREFLIGHT/plan.md`。这是 docs-only 顺序门：先只读核验真实 DB 与数据范围，再由 Owner 定精确本地目标、密钥与隔离恢复安排，随后才可能另立实际备份、校验和恢复任务。当前无真实备份、传输、解密或恢复证明；该方案中恢复演练地点的未决项已由下方新决定更新。

**Owner 再次改定（2026-09-24）**：恢复演练优先在 Owner 电脑上的独立环境进行，先核验本机能否安全隔离并恢复；此前“阿里云内独立隔离目标”不再是当前首选。AUTH-25 是作出该决定前的已接受实施前方案，其云内恢复假设只作历史设计输入，不作为当前执行授权。目标环境、磁盘余量、权限、密文解密与恢复路径均待核验；无真实数据恢复。

AUTH-26 本机恢复环境五项固定只读查询获 Work LEVEL 2 ACCEPT：PowerShell 能解析 Docker、WSL，未解析 Podman；当次 `C_free_bytes=653779619840`、`D_free_bytes=1267261124608`。见 `EVIDENCE/AUTH-26-LOCAL-RESTORE-HOST-READINESS/summary.md`。这是作者受限事实回执，Work 未重查原始对象；命令存在与空间数字不证明容器可用、隔离成立、已选备份目录或可以恢复。真实数据仍未触碰。

AUTH-27 本机 Docker 只读预检获 Work LEVEL 2 ACCEPT：当前上下文归类为本机命名管道，daemon 当次不可达；按依赖门未检查 `mariadb:10.11` 本地镜像。见 `EVIDENCE/AUTH-27-LOCAL-DOCKER-ISOLATION-PREFLIGHT/summary.md`。未启动 Docker、运行容器、拉取镜像或恢复数据；隔离能力仍未建立。

AUTH-28 一次本机已安装 Docker Desktop 启动与 daemon 复核获 Work LEVEL 2 ACCEPT：作者报告固定程序存在、启动前无进程、一次隐藏启动后等待 20 秒，本机 daemon 当次可达。见 `EVIDENCE/AUTH-28-LOCAL-DOCKER-STARTUP-RECHECK/summary.md`。未检查镜像或运行容器；隔离和恢复能力仍未证明。

AUTH-29 本机固定 `mariadb:10.11` 镜像标签只读核验获 Work LEVEL 2 ACCEPT：当次本机 context 与 daemon 可用，固定标签存在。见 `EVIDENCE/AUTH-29-LOCAL-MARIADB-IMAGE-READ/summary.md`。未运行容器；镜像实际内容、网络隔离、合成恢复和真实数据兼容仍未证明。

AUTH-30 本地虚构恢复证明目标被 Work LEVEL 2 **REJECT**，仅接受失败与清理的受限事实回执，见 `EVIDENCE/AUTH-30-LOCAL-SYNTHETIC-RESTORE-PROOF/summary.md`。一次容器启动后隔离声明检查返回 `ISOLATION_DECLARATION_MISMATCH`，数据库建表、dump 和 restore 均未执行；作者报告按 ID 清理并核对容器不存在。原始 inspect 未保存，具体不符项 `UNKNOWN`。旧一次运行预算已用尽，不能据此宣称本机隔离或恢复可用；下一步需另立只读/虚构定位任务。

AUTH-31 Docker 隔离字段定点诊断目标被 Work LEVEL 2 **REJECT**，仅接受部分事实回执，见 `EVIDENCE/AUTH-31-LOCAL-DOCKER-ISOLATION-MISMATCH-DIAGNOSIS/summary.md`。当次本机虚构 `sleep` 容器的 ID/名称、`NetworkMode=none`、空端口、空 Binds 和三个 tmpfs 目标报告为真；`Mounts` 数量/类型因脚本解析失败仍 `UNKNOWN`。Work 独立复核 PowerShell 严格模式空数组赋值可导致 `.Count` 错误；不证明原始 inspect 内容或完整隔离。作者报告精确清理 PASS；旧任务运行预算已耗尽。

AUTH-32 `Mounts` 纯解析器与 14 项虚构负向/正向测试获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR/summary.md`。它修复 null/空数组 `.Count` 路径并拒绝 bind、volume、额外/重复目标与畸形输入；未调用 Docker 或证明原容器实际 `Mounts`、完整隔离或恢复能力。

AUTH-33 使用已接受解析器的一次本机虚构恢复回放被 Work LEVEL 2 **REJECT** 完整证明目标，仅接受部分事实，见 `EVIDENCE/AUTH-33-LOCAL-SYNTHETIC-RESTORE-REPLAY/summary.md`。当次容器固定隔离声明通过：本机、无网络/端口/宿主 Binds，三个 tmpfs 目标匹配，`Mounts=0`；readiness 后虚构 setup 返回 `SYNTHETIC_SETUP_FAILED`，dump/restore 未执行。作者报告按 ID 精确清理 PASS。setup 具体原因 `UNKNOWN`，真实备份/恢复仍未证明；旧一次预算耗尽，需另立分步诊断。

AUTH-34 本机虚构 setup 分步诊断获 Work LEVEL 2 **ACCEPT（仅定位事实）**，见 `EVIDENCE/AUTH-34-LOCAL-SYNTHETIC-SETUP-DIAGNOSIS/summary.md`。作者一次运行报告预检和固定隔离声明通过，首次真正认证连接的 `SELECT 1` 失败，安全分类 `AUTH_OR_CONNECTION`；创建 schema、表、三行及 dump/restore 均未运行。作者报告按本次容器 ID 精确清理并核对不存在。Work 静态核对脚本、回执和允许路径，未重跑一次性容器预算。具体认证或连接失败原因、AUTH-33 原始 setup 错误和任何真实备份恢复能力仍未知。Owner 重启应用后明确要求继续；AUTH-35 已下达，执行与验收另见 `TASK_CURRENT.md`。

AUTH-35 本机虚构认证就绪探针的目标获 Work LEVEL 2 **REJECT**，仅接受一次预检失败回执，见 `EVIDENCE/AUTH-35-LOCAL-SYNTHETIC-AUTH-READINESS-PROBE/summary.md`。作者报告当前 Docker daemon 不可达，按任务立即停止；未检查镜像/容器名，未创建容器或进行三个认证探针，清理无需执行。Work 静态审查脚本和回执，未重跑一次预算；本次没有认证或数据库就绪结论。AUTH-36 已下达本机 Docker Desktop 启动/复核任务，执行与验收见 `TASK_CURRENT.md`。

AUTH-36 本机 Docker Desktop 一次启动与复核的可达目标获 Work LEVEL 2 **REJECT**，仅接受受限事实回执，见 `EVIDENCE/AUTH-36-LOCAL-DOCKER-STARTUP-RECHECK/summary.md`。作者报告固定程序只启动一次，等待 30 秒后的 daemon 仍不可达，未创建容器或接触数据库。Owner 同时报告 Docker Desktop 弹出 `unexpected error` 并亲自重启；界面错误不构成根因结论。Owner 随后报告重启完成，Work 本次只读核对本机 Docker context 与 daemon `29.6.2` 可达；这是新时点观察，不更改 AUTH-36 的验收结果。AUTH-37 已下达冻结 AUTH-35 虚构探针的新一次运行任务；截图中停止的旧容器不需启动。

AUTH-37 冻结虚构认证探针的新一次运行获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-37-LOCAL-SYNTHETIC-AUTH-READINESS-REPLAY/summary.md`。作者报告本机固定隔离声明通过，约 20/40/60 秒三个 `SELECT 1` 均失败且安全码均为 `1045`，按本次 ID 清理 PASS。Work 核对冻结脚本哈希、唯一候选和回执，未复跑容器；这不能判定密码、客户端选项或镜像初始化等具体原因，也不能证明虚构 dump/restore 或真实备份可恢复。旧预算耗尽，AUTH-38 已下达一个新容器的只读认证方式诊断。

AUTH-38 本机虚构 root 认证方式对比获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-38-LOCAL-SYNTHETIC-ROOT-AUTH-MODE-DIAGNOSIS/summary.md`。作者报告两种带同一虚构密码的连接均返回 `1045`，不传密码的本机 socket `SELECT 1` 成功，容器按本次 ID 清理 PASS。Work 静态审查候选并核对回执，未复跑；这不确定镜像具体认证机制，不适用于真实数据库，也不证明虚构或真实备份可恢复。旧预算耗尽，AUTH-39 已下达单容器小样本虚构 dump/restore 任务。

AUTH-39 同容器虚构 dump/restore 目标获 Work LEVEL 2 **REJECT**，仅接受部分事实回执，见 `EVIDENCE/AUTH-39-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/summary.md`。作者报告本机隔离声明和无密码 socket `SELECT 1` 通过，虚构源 schema 创建后，建表命令失败；插入、dump、导入、内容核验均未运行，按本次 ID 清理 PASS。Work 静态审查候选和回执，未复跑；建表具体失败原因未知，真实备份恢复能力仍未建立。旧预算耗尽，AUTH-40 已下达固定建表安全码与单变量诊断任务。

AUTH-40 建表定点诊断目标获 Work LEVEL 2 **REJECT**，仅接受受限事实回执，见 `EVIDENCE/AUTH-40-LOCAL-SYNTHETIC-TABLE-FAILURE-DIAGNOSIS/summary.md`。作者报告预检、隔离声明、无密码 socket 和虚构源 schema 创建通过，原建表再次失败；安全码 `UNRECOGNIZED/UNKNOWN`，所以字段名对照未执行，按本次 ID 清理 PASS。Work 未重跑；现有证据不能判定语法、空间、权限或连接原因，旧预算耗尽。AUTH-41 已下达本机虚构 tmpfs 整数投影与固定错误类别诊断。

AUTH-41 资源与错误投影的完整目标获 Work LEVEL 2 **REJECT**，仅接受部分事实回执，见 `EVIDENCE/AUTH-41-LOCAL-SYNTHETIC-TABLE-RESOURCE-PROBE/summary.md`。作者报告虚构容器建表前 `/var/lib/mysql` 的 128 MiB tmpfs 已用满、可用 0 KiB，建表失败，按本次 ID 清理 PASS；类别提取提前中断，建表后资源和 State 未检查。Work 静态发现类别函数使用与 PowerShell 自动 `$Matches` 同名的 `$matches`，但未复原运行错误。0 KiB 提示资源约束，不证明唯一根因；旧预算耗尽。AUTH-42 已下达扩大新虚构容器 tmpfs 后的一次同容器小样本恢复任务。

AUTH-42 扩大 tmpfs 后的虚构恢复目标获 Work LEVEL 2 **REJECT**，仅接受部分事实回执，见 `EVIDENCE/AUTH-42-LOCAL-SYNTHETIC-EXPANDED-TMPFS-RESTORE/summary.md`。作者报告预检与固定隔离声明通过，但 45 秒后无密码 socket `SELECT 1` 返回 `1045`，按本次 ID 清理 PASS；空间门、源表、dump/restore 均未运行。Work 静态审查并核对回执，未复跑；与 AUTH-38 的 128 MiB 容器观察不同，认证机制仍未知。扩大空间是否解决建表问题未检验，旧预算耗尽。AUTH-43 已下达该配置的虚构密码认证与空间只读探针。

AUTH-43 扩大 tmpfs 的虚构密码认证探针获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-43-LOCAL-EXPANDED-TMPFS-AUTH-PROBE/summary.md`。作者报告本次容器虚构初始化密码与环境变量匹配、数据 tmpfs 可用 372552 KiB，`MYSQL_PWD` 方式的首次 `SELECT 1` 成功，按本次 ID 清理 PASS；显式密码对照未运行。Work 静态审查并核对回执，未复跑；它不证明 AUTH-42 失败原因、建表或恢复能力。旧预算耗尽，后继需新任务验证同容器小样本恢复。

AUTH-44 本机三行虚构样本的同容器导出、导入与固定内容一致回执已获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-44-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/summary.md`。作者报告固定隔离、空间、认证、写入、dump、导入、内容核对与按 ID 清理均 PASS；Work 静态审查并只读核对容器名不存在，未复跑一次性脚本。没有独立环境恢复或真实备份证明；旧预算耗尽，后继须新任务。

AUTH-45 分离容器的三行虚构恢复回执已获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-45-LOCAL-SYNTHETIC-SEPARATE-CONTAINER-RESTORE/summary.md`。作者报告源容器清理后将 2039 字节内存 dump 输入新目标容器、固定内容一致、两容器按 ID 清理 PASS；Work 静态审查并只读核对两个固定容器名均不存在，未复跑一次性脚本。它不证明真实完整加密持久备份可恢复。下一步真实数据库范围、精确本地存放位置和密钥保管等仍需 Owner 定界，不自动执行真实备份或改库。

**Owner 新授权（2026-09-24）**：允许在 C 盘建立完整数据库加密备份专用目录，实际需要密码时由 Owner 本人输入。Work 已建立空目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，只为该目录设置显式 ACL：当前 Windows 用户、SYSTEM、Administrators FullControl，禁用继承。AUTH-46 本地只读预检获 Work LEVEL 2 **ACCEPT（仅受限事实）**，见 `EVIDENCE/AUTH-46-LOCAL-BACKUP-DESTINATION-READINESS/summary.md`：目录仍为空，当次 C 盘可用 649684254720 bytes，OpenSSL 3.5.6 与 SSH 9.5p2 可用；GPG 版本、BitLocker 状态、OneDrive 前缀及其他自动同步仍 UNKNOWN。该目录不是备份，未存放数据库、密钥或密文；加密/传输方案仍待核验。

AUTH-47 本机虚构 CMS 探针的完整目标获 Work LEVEL 2 **REJECT**，仅接受虚构证书生成失败及固定临时目录清理的受限事实回执，见 `EVIDENCE/AUTH-47-LOCAL-SYNTHETIC-CMS-ENCRYPTION-PREFLIGHT/summary.md`。一次运行中证书命令退出 1，CMS 加密/解密/篡改均未执行；原始错误未保存，原因 UNKNOWN。Work 未重跑，另只读确认临时目录不存在且 C 盘备份目录仍为空。旧预算耗尽；不据此判断 CMS GCM 是否可用或开始真实备份。

AUTH-48 虚构显式配置 CMS 探针的完整目标获 Work LEVEL 2 **REJECT**，见 `EVIDENCE/AUTH-48-LOCAL-EXPLICIT-CONFIG-CMS-PROBE/summary.md`。一次运行中证书及正常 CMS AES-256-GCM 解密 PASS；篡改解密退出 4，但仍留下与固定输入相同的输出文件，未满足拒绝判据。Work 静态审查并只读确认固定临时目录不存在、备份目录仍为空，未重跑。不能在认证成功前消费解密输出；旧预算耗尽。没有真实密钥、密码输入或备份。

AUTH-49 认证解密与本地备份恢复 **docs-only 合同**已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-49-AUTHENTICATED-LOCAL-BACKUP-RESTORE-CONTRACT/contract.md`。AUTH-48 暴露的失败输出必须先隔离，认证与密文校验成功前目标容器消费 0 字节；真实 DB 身份/范围、服务器 CMS 兼容、自动同步边界、Owner 私钥失钥恢复均保持 UNKNOWN。该合同不证明或授权真实备份、解密、恢复或改库。

**Owner 后续决定（2026-09-24）**：真实密码保护私钥在本机与密文分开的目录保存，并在加密 U 盘留恢复副本；密码由 Owner 本人输入。Work 已建立空目录 `C:\Users\zcxve\EliteSync-v10-DB-Keys`，仅当前 Windows 用户、SYSTEM、Administrators 显式 FullControl，禁用继承；尚未生成私钥、证书或 U 盘副本。U 盘精确设备与副本校验须在真实密钥任务前确认。Owner 同时确认 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 未被 OneDrive、Dropbox、Google Drive、iCloud 或其他云同步/备份包含；这是 Owner 的设备配置声明，尚无独立全局软件审计，执行真实备份前仍应核对目标路径未变化。AUTH-50 本机虚构认证失败消费者门已获 Work LEVEL 2 **ACCEPT（仅受限样本）**，见 `EVIDENCE/AUTH-50-LOCAL-SYNTHETIC-AUTHENTICATED-CONSUMER-GATE/summary.md`：正常解密退出 0 才向内存消费者交付固定 21 字节，篡改解密退出 4 虽观察到暂存字节，消费者仍为 0 次/0 字节；未证明真实规模或恢复。

AUTH-51 服务器 OpenSSL 完整工具能力目标获 Work LEVEL 2 **REJECT**，仅接受作者一次只读 SSH 成功、`openssl` 可解析且 `version`、`cms -help`、`list -cipher-algorithms` 命令均退出 0 的受限事实回执，见 `EVIDENCE/AUTH-51-SERVER-OPENSSL-CMS-CAPABILITY-READONLY/summary.md`。版本过滤未取得版本值，区分大小写的算法匹配不足以判断 AES-256-GCM 是否列出；原始输出未保存，二者均为 `UNKNOWN`。Work 未连接服务器，旧 SSH 预算 1/1 已耗尽；服务器与本机 CMS 密文互通、真实备份及恢复能力仍未建立。此次交接未发布后继任务；补测须另立有界任务。

AUTH-52 纯本地虚构 OpenSSL 输出解析预检获 Work LEVEL 2 **ACCEPT（仅解析门）**，见 `EVIDENCE/AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT/summary.md`。作者报告最终 12/12 测试 PASS；解析器将列表结果分为 `LISTED`、`NOT_LISTED` 和 `UNKNOWN`，不把未列出推断为不支持。它无法独立证明未来远端输出采集完整；服务器版本、AES-256-GCM 是否列出和 CMS 互通仍 `UNKNOWN`，后继须另立固定 SSH 预算与截断失败门。未触碰 U 盘、Owner 密码、真实密钥、备份或数据库。

AUTH-53 服务器 OpenSSL 完整能力补测获 Work LEVEL 2 **REJECT**，仅接受一次 SSH 成功、`openssl` 可解析、OpenSSL 版本 token `3.0.13`、`cms -help` 与算法列表命令退出 0 的受限事实回执，见 `EVIDENCE/AUTH-53-SERVER-OPENSSL-CAPABILITY-RECHECK/summary.md`。列表虽经有界采集与分帧，未通过 AUTH-52 行式解析，AES-256-GCM 是否列出仍 `UNKNOWN`；无原始输出可事后补判。SSH 预算 1/1 已耗尽，不重用；服务器 CMS 互通、真实备份及恢复仍未建立。未触碰 U 盘、Owner 密码、密钥或数据库。

AUTH-54 本地 OpenSSL 算法列表格式解析修复获 Work LEVEL 2 **ACCEPT（仅虚构解析门）**，见 `EVIDENCE/AUTH-54-OPENSSL-LIST-FORMAT-PARSER-REPAIR/summary.md`。作者报告 9/9 targeted 测试 PASS；新版本接受裸算法、OID、`alias => name` 和 `name @ provider` 行，并保持完整算法名及 `UNKNOWN` 边界。AUTH-53 的远端失败原因仍未证实，服务器 AES-256-GCM 是否列出与 CMS 互通仍 `UNKNOWN`；后继服务器观察须新连接预算。

AUTH-55 本机 OpenSSL 花括号别名格式解析修复获 Work LEVEL 2 **ACCEPT（仅本地格式门）**，见 `EVIDENCE/AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR/summary.md`。作者报告 12/12 虚构测试 PASS；当次本机 3.5.6 算法列表命令退出 0、9010 字符，新解析器返回 `LISTED`。本机列表解析不证明远端相同；AUTH-53 服务器 AES-256-GCM 是否列出仍 `UNKNOWN`，后继服务器观察须新连接预算。

AUTH-56 服务器 OpenSSL 算法列表单次只读观察获 Work LEVEL 2 **ACCEPT（仅受限静态事实）**，见 `EVIDENCE/AUTH-56-SERVER-OPENSSL-CIPHER-LIST-READONLY/summary.md`。作者报告一次 SSH 成功，OpenSSL 可解析，算法列表命令退出 0；8600 字符字段经有界完整采集和 AUTH-55 解析器返回 `LISTED`，即当次列表列出 AES-256-GCM。原始列表未保存，Work 未重连；AUTH-53 历史 `UNKNOWN` 不追溯改写。AUTH-56 预算 1/1 已耗尽；CMS 实际加解密、与本机互通及真实备份恢复均未建立，也未触碰 U 盘、密码或真实数据。

AUTH-57 虚构 CMS 服务器到本机互通 docs-only 方法获 Work LEVEL 2 **ACCEPT（仅方法与停点）**，见 `EVIDENCE/AUTH-57-SYNTHETIC-CMS-INTEROP-METHOD-PREFLIGHT/plan.md`。方案限定固定 21 字节虚构样本、一次性无密码虚构证书/私钥、单次严格 SSH、服务器不落盘、密文完整采集、本机认证成功前消费者 0 字节及失败清理；服务器文件描述符/管道证书输入可行性仍 `UNKNOWN`。没有运行互通、真实密钥、备份或恢复。

AUTH-58 本机虚构 fd/CMS 管道可行目标获 Work LEVEL 2 **REJECT**，仅接受证书生成成功、fd 加密退出 1、解密未运行及固定临时目录清理的受限事实，见 `EVIDENCE/AUTH-58-LOCAL-SYNTHETIC-FD-CMS-PREFLIGHT/summary.md`。原始 stderr 未保存，具体失败原因 `UNKNOWN`；Work 只读确认临时目录不存在，未重跑旧 1/1 预算。服务器 fd/CMS 能力、跨端互通和真实备份恢复均未建立，不据此改用服务器临时落盘。

AUTH-59 本机虚构 fd/CMS 三阶段定位目标获 Work LEVEL 2 **REJECT**，仅接受证书生成、Git Bash fd 3 字节读回 1147 字节并匹配、OpenSSL `x509 -in /dev/fd/3` 退出 1、CMS 未执行及固定临时目录清理的受限事实，见 `EVIDENCE/AUTH-59-LOCAL-SYNTHETIC-FD-CMS-FAILURE-DIAGNOSIS/summary.md`。脱敏错误类别 `OTHER` 不定根因，原始 stderr 未保存；Work 只读确认临时目录不存在。旧 1/1 预算耗尽，不能外推服务器同样失败或可互通。

AUTH-60 服务器虚构公有证书 fd 读取获 Work LEVEL 2 **ACCEPT（仅受限事实）**，见 `EVIDENCE/AUTH-60-SERVER-SYNTHETIC-CERT-FD-READONLY/summary.md`。作者报告本机一次性虚构私钥未离机，只有公有证书经一次严格 SSH stdin 发送；服务器 `openssl x509 -in /dev/fd/3 -noout` 退出 0，SSH 退出 0，固定本机临时目录已清理，Work 只读确认不存在。原始远端输出未保存；这不证明 CMS fd 收件人读取、AES-256-GCM 加密或跨端互通。SSH 1/1 已耗尽，无真实密钥、备份或密码操作。

AUTH-61 固定 21 字节虚构 CMS AES-256-GCM 服务器到本机**正向**互通获 Work LEVEL 2 **ACCEPT（仅单次虚构样本）**，见 `EVIDENCE/AUTH-61-SERVER-TO-LOCAL-SYNTHETIC-CMS-GCM-POSITIVE/summary.md`。作者报告一次严格 SSH、远端管道加密和本机隔离解密均退出 0，完整 PEM CMS 667 字节、解密为固定 21 字节且预定摘要匹配，本机临时目录清理，Work 只读确认不存在。仅公有虚构证书入服务器，私钥留本机；原始输出未保存。AUTH-61 预算 1/1 已耗尽；篡改/截断/错钥/超限/中断时消费者 0 字节、真实密钥与备份恢复仍未证明。

AUTH-62 本机虚构 CMS 消费者完整矩阵获 Work LEVEL 2 **REJECT**，见 `EVIDENCE/AUTH-62-LOCAL-SYNTHETIC-CMS-FAILURE-CONSUMER-MATRIX/summary.md`。作者一次运行报告正常路径消费者 1 次/21 字节，篡改、截断、错钥的本机解密调用和超限、中断的受控模拟均为 0 次/0 字节并清零；错钥退出 4 且曾观察暂存字节。Work 静态发现正常路径以固定 `identity_ok=True` 放行，没有实际比较密文长度/摘要，完整身份门未接线。超限和中断也不是实际大规模或进程中断证明；旧 1/1 运行预算耗尽。本机临时目录已清理，Work 只读确认不存在；未连接服务器或触碰真实密钥/备份/U 盘/密码。

AUTH-63 本机虚构密文身份门修复获 Work LEVEL 2 **ACCEPT（仅本次虚构矩阵）**，见 `EVIDENCE/AUTH-63-LOCAL-CMS-CIPHERTEXT-IDENTITY-GATE-REPAIR/summary.md`。消费者门从实际送解密的密文字节核对长度和 SHA-256；作者一次运行报告正常消费者 1/21，篡改、截断、错钥及超限/中断受控模拟均 0/0 且缓冲清零。纯虚构测试覆盖“篡改密文但伪造成功解密与正确明文”仍拒绝。Work 静态独立审查并确认本机固定临时目录不存在，未重跑已耗尽的 1/1 预算。原始输出未保存，超限/中断仅为模拟；真实 DB 身份/范围、一致性、真实密钥、完整备份及隔离恢复仍未建立。

AUTH-64 本机固定 DB 对象元数据探针预检获 Work LEVEL 2 **ACCEPT（仅本地预检）**，见 `EVIDENCE/AUTH-64-DB-OBJECT-INVENTORY-PROBE-PREFLIGHT/summary.md`。八条固定聚合 SELECT 区分可见基表、视图、列、索引、约束、触发器、例程及事件；Work 独立复跑 35/35 虚构检查。当前连接的权限可隐藏对象，因此探针固定报告完整性 `UNKNOWN`；未连接真实库，现场观察须另立任务。真实 DB 身份、范围、一致性与恢复能力仍未建立。

AUTH-65 部署目录 CLI 当前连接对象元数据一次只读观察获 Work LEVEL 2 **ACCEPT（仅可见计数事实）**，见 `EVIDENCE/AUTH-65-DEPLOYED-DB-OBJECT-INVENTORY-READONLY/summary.md`。作者报告严格 SSH 1/1 成功，目标指纹与 AUTH-20 同算法值一致；当次可见 43 张基表、0 视图、532 列、196 索引、43 主键、29 唯一约束、66 外键、39 CHECK，触发器/例程/事件各 0。Work 静态审查脚本和脱敏回执，未重连服务器或见原始输出。权限完整性、Web worker 同库、业务数据范围与写入一致性仍 `UNKNOWN`；SSH 预算耗尽，无真实备份或恢复。

AUTH-66 本机 DB 存储引擎与备份一致性元数据探针预检获 Work LEVEL 2 **ACCEPT（仅本地预检）**，见 `EVIDENCE/AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT/summary.md`。两条固定查询区分可见基表中的 InnoDB、非 InnoDB 和 NULL 引擎；Work 独立复跑 34/34 虚构检查。探针始终保留范围完整性和备份一致性 `UNKNOWN`；没有连接服务器或真实 DB，现场读取须另立任务。

AUTH-67 部署目录 CLI 当前连接引擎元数据一次只读观察获 Work LEVEL 2 **ACCEPT（仅可见聚合事实）**，见 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/summary.md`。作者报告唯一严格 SSH 成功，当次可见 43 张 InnoDB 基表、非 InnoDB 0、引擎 NULL 0、视图 0，版本和指纹与 AUTH-65 匹配。Work 静态审查脚本，未重连服务器；一次独立测试调用因调用目录导入问题未执行测试用例，任务测试预算已耗尽。权限完整性、Web worker 同库、并发写入/DDL 下完整备份一致性及恢复能力仍 `UNKNOWN`；SSH 预算耗尽。

AUTH-68 真实备份前的 docs-only 范围与一致性门合同获 Work LEVEL 2 **ACCEPT（仅合同）**，见 `EVIDENCE/AUTH-68-DB-BACKUP-CONSISTENCY-BOUNDARY-CONTRACT/contract.md`。它把实例/连接身份、完整对象与外部数据类别、事务引擎、DDL/写入边界、dump 权限/选项、加密先后、密钥与隔离恢复列为独立停点；影响生产写入的具体方案须 Owner 决定。没有连接服务器、真实 DB 或备份。Work 独立测试生成的 AUTH-67 Python 缓存目录仍未跟踪，因删除操作被自动审批拒绝而保留，不属于候选。

AUTH-69 Owner 密码保护私钥与加密 U 盘恢复副本的 docs-only 实施前合同获 Work LEVEL 2 **ACCEPT（仅合同）**，见 `EVIDENCE/AUTH-69-OWNER-KEY-USB-RECOVERY-PREFLIGHT/plan.md`。目录与设备识别、加密卷、私钥/证书配对、副本写入、失钥演练及临时清理各有独立停点；仍无真实私钥、U 盘副本或恢复证明。真实创建/写入/解锁须各自任务及 Owner 高风险门。本地 main `0264eba53ad310d015eaf6bb86992504b7de0f14` 已制作跨磁盘 Git bundle，SHA-256 `1B0B4B5EA3FDC8A9CA757E0D8347B3FA53FE4BCF50F8427FA0F87EDB101E0D29`；bundle 不含未跟踪内容、真实 DB 或密钥。

AUTH-70 两处固定本机目录的只读元数据回执获 Work LEVEL 2 **ACCEPT（仅当次受限观察）**，见 `EVIDENCE/AUTH-70-LOCAL-BACKUP-KEY-DIRECTORY-READINESS/summary.md`。作者报告目录及必要父路径为规范、非重解析目录；ACL 主体仅归类当前用户、SYSTEM 和管理员且继承关闭，C: 当次可用 642974105600 bytes。Work 未重查原始系统对象。两目录自动同步技术边界和 C: BitLocker 均 `UNKNOWN`，备份目录另有 Owner 无云同步声明；密钥目录须单独确认。未使用 U 盘或密码，无真实私钥/备份/恢复。

AUTH-71 本机固定 1 MiB 虚构 CMS 容量和失败消费者门演练获 Work LEVEL 2 **ACCEPT（仅本次虚构矩阵）**，见 `EVIDENCE/AUTH-71-LOCAL-BOUNDED-CMS-CAPACITY-FAILURE-DRILL/summary.md`。作者一次运行报告正常消费者 1/1,048,576；篡改、截断、错钥及超限/中断受控模拟均 0/0，缓冲清零且临时目录清理。Work 静态审查并只读确认目录不存在，未重跑已耗尽预算。原始输出未保存；真实 dump 体量、服务器端大流加密、真实密钥、完整备份和恢复仍未证明。

**Owner 补充决定（2026-09-25）**：备份与密钥均不采用云同步或云备份。Owner 指定空的 `E:\` 32GB U 盘供私钥恢复副本使用，并授权使用该盘；密码仍仅由 Owner 本人输入。Work 当次只读观察 `E:` 为 USB 可移动卷、约 30.9 GB、FAT32，尚未验证卷内为空或具备可用的加密保护。后继须在精确设备识别与加密门通过后才写入恢复副本；无需再次询问是否可使用这只 U 盘。此前 Codex 连续任务约 20 张任务单交接的安排已由根 `AGENTS.md` 的新会话规则取代；仍不得逐单创建新会话。

AUTH-72 `E:\` U 盘只读身份、空盘与加密状态回执获 Work LEVEL 2 **ACCEPT（仅当次受限事实）**，见 `EVIDENCE/AUTH-72-OWNER-USB-IDENTITY-ENCRYPTION-READONLY/summary.md`。作者报告单一可移动 USB 卷、FAT32、约 28.802 GiB；根目录含 1 个条目，与 Owner 所述“空盘”并存，条目性质 `UNKNOWN`，没有查看名称或内容。BitLocker 工具存在但固定卷状态查询失败，保护和锁定状态仍 `UNKNOWN`。未写入或格式化；后继只读分类和状态定位另立任务。AUTH-72 的查询预算已用尽。

AUTH-73 同一 `E:\` U 盘根条目与保护状态只读定位获 Work LEVEL 2 **ACCEPT（仅当次受限事实）**，见 `EVIDENCE/AUTH-73-OWNER-USB-ROOT-ITEM-AND-PROTECTION-DIAGNOSIS/summary.md`。作者报告唯一根条目为 `System Volume Information` 系统目录、隐藏/系统属性均真；根目录未观察到用户数据，但整盘空与加密保护均未证明。一次 `manage-bde -status E:` 非零，转换/保护/锁定仍 `UNKNOWN`。未删除、格式化或写入；旧查询预算耗尽。继续复用 AUTH-71/72 的 Codex 会话。

**Owner 补充授权（2026-09-25）**：Owner 在看不到 U 盘文件后，明确允许对指定 `E:\` U 盘执行格式化，建议快速格式化节省时间。此授权只限准确复核后的该设备，不授权其他盘；是否需要格式化须结合加密方案判断，实际操作另立有界任务并核对停点。密码仍只由 Owner 本人输入。

AUTH-74 `E:\` U 盘 BitLocker 状态只读权限定位获 Work LEVEL 2 **ACCEPT（仅未提权进程事实）**，见 `EVIDENCE/AUTH-74-USB-BITLOCKER-ACCESS-DIAGNOSIS-READONLY/summary.md`。作者报告 Windows EditionID `Professional`、当前管理员令牌未启用；对 E 盘的 PowerShell 和 `manage-bde` 状态查询各一次均归类 `ACCESS_DENIED`，两种预算已耗尽。Work 未复核原始输出；卷转换/保护/锁定仍 `UNKNOWN`。快速格式化授权不能解决管理权限，下一步须在 Owner 在场的具体任务中处理提权和密码/恢复信息。

AUTH-75 Owner 在场启用 BitLocker To Go 的 docs-only 交互与验收合同获 Work LEVEL 2 **ACCEPT（仅合同）**，见 `EVIDENCE/AUTH-75-OWNER-BITLOCKER-TO-GO-INTERACTIVE-CONTRACT/plan.md`。它要求操作前再核对 E 身份、Owner 离线保管恢复密钥、本人批准 UAC 并输入密码，完成后独立核验保护和重新接入锁定/解锁；根目录系统元数据不构成必须格式化的理由。后续实际操作与结果以 AUTH-76/77 的最新证据为准。

AUTH-76 E 盘 BitLocker To Go 的 Owner 交互回执获 Work LEVEL 3 **ACCEPT（仅回执事实）**，见 `EVIDENCE/AUTH-76-OWNER-USB-BITLOCKER-ENABLEMENT/summary.md`。Work 复核了 E 为约 28.8 GiB Kingston USB、仅有隐藏系统目录，打开本机 BitLocker 界面；Owner 报告 E 加密完成，实际恢复密钥已纸质抄写、核对并安排与电脑/U 盘分开。Work 未看到向导或秘密，未格式化。当次保护状态由 AUTH-77 后续核验；重新接入锁定与 Owner 密码解锁仍待证明。

AUTH-77 固定 E: 的 BitLocker 状态只读回执获 Work LEVEL 2 **ACCEPT（仅当次状态）**，见 `EVIDENCE/AUTH-77-USB-BITLOCKER-PROTECTION-READONLY/summary.md`。当前令牌读取被拒；Owner 批准 UAC 后一次提权只读查询复核设备身份并返回 `FullyEncrypted`、`ProtectionOn`、`Unlocked`、100%。未重插或验证密码解锁，恢复密钥可用性仍未证明；后续重插过程以 AUTH-78 最新证据为准。

AUTH-78 完整锁定与解锁证明被 Work LEVEL 3 **REJECT**，仅接受受限过程及失败事实，见 `EVIDENCE/AUTH-78-USB-REINSERT-LOCK-OWNER-UNLOCK-PROOF/summary.md`。Owner 安全移除并重插各一次，原 E: 卷消失、重插后固定 Kingston 身份通过；一次提权锁定阶段查询返回 `FIELD_UNKNOWN`，具体字段未保存，旧预算耗尽。因锁定门未过，任务内 Owner 密码解锁和解锁后查询未运行；后续锁定字段以 AUTH-79 新时点证据为准。

AUTH-79 固定 E: 锁定状态逐字段诊断获 Work LEVEL 2 **ACCEPT（仅受限新时点事实）**，见 `EVIDENCE/AUTH-79-USB-LOCKED-STATE-FIELD-DIAGNOSIS/summary.md`。重插后的同一只 Kingston 在一次提权只读查询中 `LockStatus=Locked`；锁定时 `ProtectionStatus=Unknown`、`VolumeStatus` 未映射、加密百分比缺失，不从这些字段推定保护关闭。Owner 随后说明曾自行用密码成功解锁，之后又拔出重插，再次锁定；截图仅作 Owner 辅助回执，不纳入 Git 或独立状态证明。解锁后状态以 AUTH-80 新时点证据为准。

AUTH-80 Owner 密码解锁固定 E: 及解锁后保护状态获 Work LEVEL 3 **ACCEPT（仅本次受限证明）**，见 `EVIDENCE/AUTH-80-OWNER-USB-PASSWORD-UNLOCK-VERIFY/summary.md`。Owner 本人在 Windows 界面输入一次密码并确认解锁成功、亲自批准 UAC；提权进程再次核对设备身份，唯一一次只读状态查询返回 `Unlocked/ProtectionOn/FullyEncrypted/100%`。结合 AUTH-79 的 `Locked`，支持本轮重插后锁定及本人密码解锁；纸质恢复密钥实际失钥恢复、真实私钥与副本、DB 备份与恢复仍未建立。后续密钥准备以 AUTH-81 最新接受边界为准。

AUTH-81 真实密码保护私钥生成的本机 docs-only 实施前方案获 Work LEVEL 2 **ACCEPT（仅候选方案和受限只读事实）**，见 `EVIDENCE/AUTH-81-REAL-KEY-GENERATION-LOCAL-PREFLIGHT/plan.md`。两处固定目录当次规范路径、ACL 和 C: 余量复核通过，不落在本次观察的 2 个 Windows 同步根下；其他第三方同步覆盖仍技术性 `UNKNOWN`，Owner 的不使用云同步决定另行成立。本机固定 OpenSSL 3.5.5 的相关选项可见，真实口令提示、RSA 3072 密钥/证书和跨端 CMS 均未证明。Work 选定 RSA 3072、AES-256-CBC 加密 PKCS#8、用途证书与 365 天作为后继候选；C: 整卷加密不是当前真实生成前硬门。Owner 已决定真实私钥密码另写纸质副本、与电脑/U 盘分开放置，实际密码只本人输入。后续虚构交互结果以 AUTH-82 证据为准。

AUTH-82 本机虚构密码保护 RSA 3072 私钥与用途证书交互预检获 Work LEVEL 2 **ACCEPT（仅虚构流程）**，见 `EVIDENCE/AUTH-82-LOCAL-SYNTHETIC-PASSPHRASE-KEY-PROOF/summary.md`。原生提示生成加密 PKCS#8 私钥和公有证书、正确虚构口令配对、错误口令无可消费输出均由作者按各 1/1 预算报告；Work 独立只读核对临时根已清理。原计划清理命令被自动审批拒绝，作者后以精确文件删除和空目录非递归移除完成，未接触真实材料。PTY 可记录虚构口令，因此不证明真实密码安全输入；AUTH-83 的真实执行结果另见下方。

AUTH-83 的真实密码保护私钥生成目标被 Work LEVEL 3 **REJECT**，仅接受一次失败事实，见 `EVIDENCE/AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY/summary.md`。Phase A 无秘密 `launch.ps1` 经 Work 静态审查并放行 Phase B；Owner 确认在场、无录屏/共享并准备纸质密码副本。唯一一次脚本启动父进程返回子窗口退出码 1，Owner 未见可报告的失败类别；Work 独立只读确认精确真实私钥目标不存在。子窗口可见性、失败原因及 OpenSSL 是否启动均 `UNKNOWN`，旧一次预算耗尽。

AUTH-84 的一次无秘密可见窗口探针获 Work LEVEL 2 **REJECT（诊断目标）**，仅接受窗口闪现和约 0.98 秒提前退出的受限事实，见 `EVIDENCE/AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS/summary.md`。Owner 未看到固定标记；因短于预定 12 秒，退出码 1 按位解读的控制台布尔均不可采信。具体失败阶段及 AUTH-83 原因仍 `UNKNOWN`，旧预算 1/1 已耗尽。真实密钥、证书、U 盘副本仍不存在；AUTH-85 另行验证 Owner 桌面手动启动的无秘密交互入口。

AUTH-85 的桌面手动无秘密探针获 Work LEVEL 2 **REJECT（探针运行目标）**，仅接受 Owner 看到 `PROBE_LAUNCH_EXCEPTION`、PowerShell 退出 1、`POWERSHELL_NONZERO` 和按键提示的受限事实，见 `EVIDENCE/AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT/summary.md`。固定标记和控制台布尔未出现，宽泛异常的根因 `UNKNOWN`，不能推定 AUTH-83/84 的失败原因。一次双击预算已耗尽。AUTH-86 将只读核查本机执行策略与脚本文件标记，不启动探针、不修改策略；真实私钥、证书和 U 盘副本仍不存在。

AUTH-86 的固定只读定位获 Work LEVEL 2 **ACCEPT（仅受限观察）**，见 `EVIDENCE/AUTH-86-POWERSHELL-PROBE-LAUNCH-READONLY-DIAGNOSIS/summary.md`。当前会话作用域策略为 `CurrentUser/LocalMachine=RemoteSigned`、其余三项 `Undefined`；AUTH-85 两文件无 `Zone.Identifier` 流且哈希匹配。没有支持“下载来源标记触发拦截”的正向证据，也没有 Owner 当时的原始异常；具体根因仍 `UNKNOWN`。AUTH-87 改用无 PowerShell 的纯 `.cmd` 做无秘密前台可见性预检；真实私钥、证书和 U 盘副本仍不存在。

AUTH-87 的纯 CMD 无秘密可见性和单键入口获 Work LEVEL 2 **ACCEPT（仅本次交互路径）**，见 `EVIDENCE/AUTH-87-CMD-ONLY-OWNER-CONSOLE-PREFLIGHT/summary.md`。Owner 报告成功标记出现，按键关闭提示出现且按键后窗口才退出。旧一次双击预算已耗尽。这不证明 OpenSSL 密码提示或真实密钥。AUTH-88 将为新的真实密码保护私钥生成准备固定 CMD 入口，先做 LEVEL 3 预运行审查；真实私钥、证书和 U 盘副本仍不存在。

AUTH-88 的一次 Owner 真实生成回执获 Work LEVEL 3 **REJECT（完整安全目标）**，仅接受 OpenSSL 成功类别、精确文件存在且 2666 bytes、加密 PKCS#8 首行等受限事实，见 `EVIDENCE/AUTH-88-OWNER-CMD-REAL-ENCRYPTED-PRIVATE-KEY/plan.md`。文件 Owner 为当前用户且三条 FullControl 主体仅当前用户、SYSTEM、Administrators，但均为继承 ACE，文件级继承尚未关闭；密码解锁及私钥与证书配对均未证明。旧生成预算 1/1 耗尽，不重试或覆盖。AUTH-89 仅修复此文件 ACL 并独立核验；之前不进行解锁、证书或 U 盘副本操作。

AUTH-89 的精确真实私钥文件 ACL 修复获 Work LEVEL 3 **ACCEPT（仅权限）**，见 `EVIDENCE/AUTH-89-REAL-PRIVATE-KEY-FILE-ACL-REPAIR/summary.md`。文件仍 2666 bytes、非重解析，Owner 为当前用户，继承关闭，恰三条显式 FullControl：当前用户、SYSTEM、Administrators。此变更不证明逐字节内容一致或密码可解锁。AUTH-90 将准备只读解锁校验入口；证书、U 盘副本、数据库备份及恢复仍不存在。

AUTH-90 的一次 Owner 原生提示密码解锁检查获 Work LEVEL 3 **ACCEPT（仅本次现有私钥可解锁）**，见 `EVIDENCE/AUTH-90-OWNER-PRIVATE-KEY-UNLOCK-CHECK/plan.md`。Owner 回报固定 CMD 出现 `AUTH90_UNLOCK_EXIT_ZERO`；Work 复核文件仍 2666 bytes、ACL 仍为三主体显式且继承关闭。未输出私钥正文；纸质密码副本准确性、证书配对、跨端 CMS、U 盘恢复均未证明。旧解锁预算耗尽。AUTH-91 准备由同一私钥创建固定用途公有证书；真实备份和恢复仍不存在。

AUTH-91 的一次 Owner 公有收件人证书生成获 Work LEVEL 3 **ACCEPT（证书及元数据）**，见 `EVIDENCE/AUTH-91-OWNER-REAL-RECIPIENT-CERTIFICATE/plan.md`。精确证书 1541 bytes、PEM X.509，Subject/Issuer 为固定用途名，RSA 3072、SHA-256 签名、365 天有效期，critical `CA:FALSE` 与 `Digital Signature, Key Encipherment`；私钥元数据与三主体显式权限未变。旧一次预算已耗尽。证书与私钥实际配对、CMS 兼容和 U 盘副本未建立；AUTH-92 将以纯虚构内容进行本机 CMS 配对演练，不接触真实数据库。

AUTH-92 的一次 Owner 本机虚构标记 CMS 往返获 Work LEVEL 3 **ACCEPT（仅本机受限演练）**，见 `EVIDENCE/AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP/plan.md`。经审查脚本成功分支须 AES-256-CBC 加密、现有私钥解密、逐字节一致和三个精确临时文件清理均通过；Owner 回报成功标记，Work 复核三临时文件不存在、私钥元数据/ACL 与证书指纹未变。此证明本机此次证书/私钥配对及虚构数据 CMS 往返，不证明服务端或真实 DB 备份恢复。旧预算已耗尽。AUTH-93 将只读复核当前 Kingston 加密 U 盘身份与保护状态，之后才可考虑真实私钥恢复副本写入。

AUTH-93 的固定 E: BitLocker 只读查询获 Work LEVEL 2 **REJECT（状态目标）**，仅接受一次普通进程返回 `UAC_OR_LAUNCH_FAILED`、退出 1 的受限事实，见 `EVIDENCE/AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT/plan.md`。Owner 说明当时正在打字，可能误取消 UAC，具体原因未确诊；四字段仍 `UNKNOWN`，旧 1/1 预算耗尽。Owner 明确请求再触发一次；AUTH-94 为该请求另立单次有界只读尝试，成功前不写 U 盘恢复副本。

AUTH-94 的一次 Owner 批准 UAC 后固定 E: 只读查询获 Work LEVEL 2 **REJECT（四字段目标）**，仅接受 `Unlocked/FullyEncrypted/100%` 等受限字段事实，见 `EVIDENCE/AUTH-94-USB-BITLOCKER-OWNER-UAC-RETRY-READONLY/summary.md`。保护位回报 `OTHER`，但 Work 静态定位脚本把本机枚举 `Off/On/Unknown` 与不存在的 `ProtectionOn` 比较，故该位必然不匹配，不能判断当前保护开关；原始值未保存，仍 `UNKNOWN`。旧 1/1 预算耗尽，私钥副本写入停止。AUTH-95 先修复固定枚举映射并审查，再安排新的一次有界查询。

AUTH-95 的修正枚举脚本一次只读核验获 Work LEVEL 2 **ACCEPT（仅本次固定 E: 状态）**，见 `EVIDENCE/AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR/summary.md`。Owner 亲自批准 UAC；固定 Kingston E: 的成功分支证明当次 `Unlocked/On/FullyEncrypted/100`，旧查询预算已耗尽。Work 后续非提权观察 E: 仍为同名 USB、FAT32、约 30.9 GB 可用，两个拟定恢复文件名不存在。AUTH-96 将准备在独立高风险门下复制已加密私钥与公有证书到受保护 E:，并做有界字节身份核验；纸质恢复密钥实测与失钥恢复仍未建立。

AUTH-96 的固定恢复对复制目标获 Work LEVEL 3 **REJECT**，仅接受一次普通进程约 80 秒后 `UAC_OR_LAUNCH_FAILED`、退出 1 及两精确 E: 目标不存在的受限事实，见 `EVIDENCE/AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY/summary.md`。本机源私钥仍 2666 bytes、ACL 受限；Owner 后续说明当时不在电脑前、未看到 UAC，失败具体原因仍 `UNKNOWN`，BitLocker 查询和复制没有可证成功回执。旧 1/1 启动预算耗尽，不重试；后继另立 AUTH-97。

AUTH-97 经 Work LEVEL 3 **ACCEPT（固定加密恢复对副本及本次字节身份）**，见 `EVIDENCE/AUTH-97-OWNER-VISIBLE-USB-KEY-PAIR-COPY-RETRY/plan.md`。Owner 从 Explorer 单次启动可见入口并报告成功标记；Work 独立确认当前 E: 为指定 Kingston USB Removable，两精确副本各与本机加密私钥/公有证书同长度、SHA-256 相等，源私钥三主体受限 ACL 未变。入口和复制脚本哈希仍与放行值一致。新 1/1 启动预算已用尽。未验证纸质恢复密钥解锁、失钥恢复或真实数据库备份/恢复；E: 保护状态成功分支只适用于脚本运行当时，不能推断未来状态。

AUTH-98 的 docs-only U 盘私钥恢复演练设计获 Work LEVEL 3 **ACCEPT（仅方案）**，见 `EVIDENCE/AUTH-98-USB-KEY-SYNTHETIC-RECOVERY-DRILL-DESIGN/plan.md`。后继优先 A：Owner 本机非回显输入现有私钥密码，OpenSSL 只以精确 E: 私钥副本对固定虚构内容作 CMS 往返；B 为拔插锁定后的 U 盘密码解锁，C 为纸质 BitLocker 恢复密钥验证，各自独立。AUTH-98 未执行任何演练，不证明 A/B/C 或真实数据库恢复。下一步须另立可执行脚本候选并经 Work 高风险预运行审查。

AUTH-99 的可见入口/虚构 CMS 脚本候选获 Work LEVEL 3 **REJECT（不得运行）**，见 `EVIDENCE/AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY/plan.md`。静态控制流固定唯一 E: 私钥路径，但候选把 OpenSSL 解密的标准错误重定向到空输出，可能一并隐藏原生密码提示；Owner 不得盲输。固定 Temp 输出目标还存在检查后并发覆盖余量。候选从未运行，UAC、BitLocker、加解密预算均 0/1。下一步先用完全虚构的密码保护密钥确认本机提示通道与 PowerShell 行为，再另立修订候选；未触碰真实 E: 私钥执行。

AUTH-100 完全虚构的提示通道诊断获 Work LEVEL 2 **REJECT（完整合规目标）**，仅接受本次有限观察：A/C 的密码提示在标准错误检出，B 的 `2>$null` 把该提示隐藏，见 `EVIDENCE/AUTH-100-SYNTHETIC-OPENSSL-PROMPT-CHANNEL-DIAGNOSIS/summary.md`。三次虚构调用均非零，原因 `UNKNOWN`；脚本在 A 非零后仍执行 B/C 并清理，违反失败即停/保留现场任务边界，预算各 1/1 耗尽。Work 确认虚构 Temp 目录事后不存在。该事实支持 AUTH-99 拒绝，仍不能证明 Owner 真实密码提示交互可成功；后继要修订可见提示的候选，不能运行 AUTH-99。

AUTH-101 的修订 Owner 可见 CMD/只读保护脚本候选获 Work LEVEL 3 **ACCEPT（仅 Phase A 静态候选）**，见 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/plan.md`。唯一 CMS 解密 `-inkey` 指向 E: 精确加密私钥副本；OpenSSL 原生 stderr 留在 Owner 前台窗口，单次 BitLocker 门先于读取；三个虚构临时文件在仓库外任务目录，成功清理、失败保留。Owner 要求本长会话在验收后交接，因此 **Phase B 未放行且未执行**，UAC/BitLocker/加解密预算均 0/1。下一 Work 会话先独立复核本地状态、候选哈希、固定 E:、Temp 与 Owner 在场，再决定是否放行一次实际虚构演练；不得自动派发给旧 Codex 会话。A/B/C 及真实数据库备份/恢复仍未证明。

## Product scope

Relationship Decision Support System；MVP 顶层 `Home | Progress | Messages | Me`。Match、Connection、Conversation、Relationship 权限与生命周期分离；Home 是低密度只读状态投影。Explore、Relationship support 属 Phase 2；AI/reference signals 属 Later/Optional。已接受语义及来源见 `PRODUCT_DECISIONS.md`。

## Flutter

已接受 APP-INT-04：独立消息同意后可在本地 synthetic Conversation 列表/详情读发文本；Connection 关闭后重新锁定。APP-INT-05 Home 随四段状态更新唯一下一步按钮；作者回执报告 targeted tests 17 PASS、Android debug assemble/install/cold launch/main-loop PASS，analyze 为 0 errors、18 条既有 warning/info 且命令退出 1。独立审查静态代码并原样集成，未重跑工具链；这些不是发布证明。

## Backend

仓库有 Laravel 11 代码、历史 Runtime Readiness/Canonical Match synthetic HTTP 与 Product Connection evaluator、mapping、application/persistence 开发态工作。真实 auth/session、Connection/Conversation writer 和生产 backend authority 未建立；APP-T12 的 G-02/03/05/06/08/13 仍须按各自最新证据逐项关闭，不以 synthetic 演示推定关闭。

## DB

Contract/mapping：Product Connection 开发态映射有既有接受链。Local/test：存在 Laravel migrations 与 synthetic/dev-test persistence 证据。Target environment：AUTH-14 仅确认部署目录本次 Laravel CLI 视图的四条目标 migration 均 Ran（57/57）；实例身份、实际表结构及 Web worker 配置未核验。Production DB：**NOT ESTABLISHED**；AUTH-14/16 仅为部署目录 CLI 迁移账本与固定结构投影，无目标实例身份、Web worker 同库、整库 schema、备份/恢复或真实数据持久化证明。

Owner 于 2026-09-24 授权：未来任务若确需修改阿里云后端数据库结构，必须先备份并校验可恢复；可将现有管理员创建的测试账号信息导出到本地供变更后恢复，**不得上传至阿里云以外的其他地方**。Owner 最新决定是完整数据库备份加密保存到自己的电脑，自完成日起保留 **30 天**，不采用云同步或云备份；恢复演练优先在电脑上的独立环境，先核验隔离与恢复能力。备份专用目录为 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，独立私钥目录为 `C:\Users\zcxve\EliteSync-v10-DB-Keys`。现有加密私钥和公有证书的 E: 受保护副本已在 AUTH-97 获字节身份验收；Owner 本人输入密码，纸质私钥密码副本和 BitLocker 恢复密钥分开放置。失钥恢复、传输、真实数据范围与恢复路径尚待核验；不代表已完成真实备份或恢复。敏感导出不得纳入 Git、Git bundle、普通证据或第三方云服务。

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
