## 2026-11-16 第二轮顾问复核结论

**`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`。** R1-01第二轮复核PASS，七项AC均在具名范围内通过顾问验收。Owner整版接受仍为PENDING。

详见[第二轮顾问复核报告](ADVISOR_R1_REREVIEW_20261116.md)。首轮条件接受报告、R1关闭记录和所有历史UNKNOWN/FAIL/NOT_RUN均保留。

# v10.1.16 实施报告

## 2026-11-16 R1-01 当前工程关闭记录

R1-01 为 CLOSED，GPT 顾问第二轮独立复核 PENDING，Owner 接受 PENDING。首轮顾问结论 `CONDITIONAL_ACCEPTANCE_IN_NAMED_SCOPE — R1_01_OPEN — NO_R2` 按[原报告](ADVISOR_ACCEPTANCE_20261115.md)保留。修正对象与回归要求见[R1任务](R1_01_AUTOMATION_REVOCATION_SCOPE.md)。

固定审阅提交为 `82b7946d2399200a099499f2fcb2a2b44fdb048a`。同步时远端另有 `e292ac4dbf063ba88354c5845bba555314cb0e6f` 的工作流文字修正，两份顾问/R1文件 Blob 与指定审阅提交一致。六份入口文档均已逐Blob核对，LOCAL_DOCS_SYNCED。

R1 后端及测试源码提交为 `4bfa9245f06548197532ecec2d5da0397ba8d33d`。本轮修改两个生产服务文件、一份既有定向测试及一份隔离 HTTP fixture。APP 源码仍为 `00cec7843911bb3341304c004059de0a91e12f16`，沿用 `10.1.16-dev / 1011601` 原 APK，现存文件 SHA256 回读一致。

### 修正行为

授权暂停、撤销及到期仅选择绑定到本 scope 授权记录 ID 的 ACTIVE 参与。授权 revision 在到期时已经递增，仍可按记录 ID 识别旧 revision 的真实委托。未产生委托 effect 的手动 ACTIVE，以及用户手动 opt_in 清除绑定后的 ACTIVE，保留完整参与行。

实际改变授权 ID、授权 revision 或 round ID 绑定时，参与 revision 增加，updated_at 写入当前时间，effect 收据使用绑定后的最终 revision。重复相同绑定和 UNKNOWN 已提交结果核对保持一次业务效果。原锁序、CAS/幂等、lease/fencing、UNKNOWN 及有限退避合同由定向测试继续覆盖。

### 本轮验证

| 验证 | 结果与具名范围 |
|---|---|
| 复现 | 新增十个参数化 case，fixture校正后修正前六个断言失败，覆盖四种停止条件、手动接管及绑定版本 |
| PHP/API 定向 | B2原十七个case与R1新增十个，共27项、267断言通过，包含SQLite内真实控制器路径 |
| 隔离 MariaDB + HTTP | 新建无外部网络的独立MariaDB/PHP环境，十个场景、36次真实回环HTTP请求通过，private/no-store核对通过 |
| 提案合同 | 已委托参与暂停/撤销/到期/策略失效后proposal与slot原值保留，接受门禁拒绝，用户明确withdraw仍可执行 |
| 版本与收据 | 手动参与1→绑定2；同周期暂停/恢复后最终5，generation沿原报名规则；新既有轮次绑定推进版本；重复绑定保持原值，receipt与最终版本一致 |
| 进程可靠性 | 提交前SIGKILL、提交后回执前SIGKILL、双worker并发、claim后撤销四项通过，两次进程退出137，已提交效果均恰一份且最终参与revision为2 |
| 代码与身份 | 四个受影响PHP文件语法通过，隔离运行的两服务与两测试文件逐字节规范内容匹配固定源码 |
| 工程复核 | 只读Sol/high助手未确认新增缺陷，主代理完成修复及工程裁决 |

MariaDB场景只使用新建虚构账号与新隔离数据库。测试环境网络仅回环，实际SQL `SELECT DATABASE()`、driver及环境在迁移前验证。MariaDB的matching_runs和proposals均为0，受保护匹配消费者未启动。测试fixture的已有轮次由具名测试准备步骤创建。

修正前首两轮定向测试暴露了测试peer准备不完整，已将双方资格、参与和slot按现有fixture合同补齐，随后只剩六项预期缺陷复现。首次HTTP探针未启用docker stdin透传而读到空请求，启用透传后完成全部场景。原失败记录均保留私有目录。

### 当前环境和边界

原 DB/API/WS 在 Docker 引擎恢复后保持停止。R1 新建隔离 DB/PHP 容器在验证结束后停止，专属测试卷与原证保留。旧 SFU 随引擎启动自动重试，已恢复停止。主开发 API/后台调度的 R1 部署验证为 NOT_RUN。原库 HEAD、分支、tracked/cached diff、相同选项status及index原字节与本次启动快照一致，稳定根原 `%SystemDrive%/` 保留。

本轮APP源码差异为空，APK构建、Flutter/Widget、Dart分析、设备操作和104项全套重复为 NOT_RUN。主开发库及其他既有数据库为本轮测试范围外，首次误连探测前后逐表摘要继续 UNKNOWN。旧十二项失败、原备份及其恢复限制保留原身份。

本轮证据保存在 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev\v10116-current\r1-01-20261116`。R1关闭为Codex工程结论，最终文档提交和同源回读身份列入交付回复，第二轮顾问结论等待独立记录。R1完成后停止等待第二轮复核。

## 2026-11-15 初次交付历史记录

以下保留首轮交付事实、当时源码、运行状态与测试结果。当前后端修正和运行验证范围以上方R1记录为准。

## 交付身份与工程结果

本版执行 V3.0 阶段 B2。任务分支为 `codex/v10.1.16-user-state-automation-center-20261115`，唯一父基线 `b981796e68ca512beeed2a18b40aeb8b09e26bc2`，任务文档固定提交 `89ce556ab67c6ea759d3a2ffea7016edf11b892e`。

十四份路线、授权和任务文件在编码前逐 Git Blob 与规范内容核对，结果 LOCAL_DOCS_SYNCED。[同步回执](LOCAL_DOCS_SYNC_RECEIPT.json)与[路线 ACK](ROADMAP_ALIGNMENT_ACK.md)已先行固定在 `c793eefcad2f5cff0c613b79b2b1d1cba32e6fa5`。

最终产品源码为 `00cec7843911bb3341304c004059de0a91e12f16`。APP、API 和相关 Web 后端均绑定该仓库提交，Web 前端沿父基线内容。候选为 `10.1.16-dev / 1011601`，包名 `com.elitesync.v1015dev`，debug、arm64-v8a，APK 共 124048353 字节。APK SHA256 为 `ac86f8df05d1e39abfead445ba5d6e23bcb457b6c73030c02fa38d2d2cedb055`，签名证书 SHA256 为 `7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42`。

| 验收项 | 工程结果 | 具名交付范围 |
|---|---|---|
| AC16-01 | PASS | 权威状态来源、版本、更新触发、隐私裁剪和纯读风险形成[来源图](USER_STATE_SOURCE_MAP_V1.md) |
| AC16-02 | PASS_IN_NAMED_SCOPE | 当前账号只读聚合 API、private/no-store、来源变化与双账号隔离，过期 proposal 纯读投影 |
| AC16-03 | PASS_IN_NAMED_SCOPE | 默认 OFF、明确 scope 授权、CAS/UUID、pause/resume/revoke、expiry 和策略版本失效，旧 ACTIVE 无静默授权 |
| AC16-04 | PASS_IN_NAMED_SCOPE | 数据库 ledger、幂等、lease/fencing、UNKNOWN 收据核对、三次有界重试、审计；真实双进程和两种 SIGKILL 窗口验证 |
| AC16-05 | PASS_IN_NAMED_SCOPE | 复用既有参与、资格与轮次合同；隔离 MariaDB 完成真实参与写入；主开发链遇已结束报名轮次按 ROUND_NOT_OPEN 跳过 |
| AC16-06 | PASS_IN_NAMED_SCOPE | 现有我的与慢约会入口，APP 明确授权、暂停、恢复、撤销、冷启动和切号，底部四入口沿既有结构 |
| AC16-07 | PASS_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS | 定向 PHP、Flutter、Dart、真实 HTTP/DB、模拟器与候选身份完成；扩大检查的基线失败和未运行矩阵另列 |

顾问独立验收与 Owner 接受均为 PENDING。工程自验和助手代码复核分别记录。[manifest](artifact_manifest.json)与[证据摘要](EVIDENCE_SUMMARY_20261115.json)集中固定文件身份和实际验证范围。

## 实现与产品选择

统一状态 API 实时读取现有来源，返回账号、资料、Lifestyle、Readiness、参与、轮次、本人 proposal、隐私、通知偏好与自动化摘要。来源没有 revision 的域使用真实更新时间。新轮次 summary 复用现有 publicState，避开会协调过期 proposal 的旧旅程读取路径。GET 只标记 RECONCILIATION_REQUIRED，保持原记录与 slot。

原 APP 的“主动报名/明确重新报名”文案未明确未来每周持续委托，因此本版新增单独 scope `weekly_slow_dating_participation`，默认关闭。原参与记录继续作为业务事实，授权另存用户委托。未设强制短期限，空 expires_at 表示持续至用户暂停、撤销或策略/同意版本失效，APP 给出明确说明。

自动化每用户、scope、cycle 一条 task，绑定当前授权 revision 与已存在的 default round。只有准备中且无 active run 的轮次允许协调报名。每次副作用前重核当前授权、资格、账号、轮次和 proposal slot。人工 opt_in 清除旧委托绑定，草稿保留绑定，人工 pause/exit 同步暂停/撤销未来委托。自动委托参与绑定当前轮次，后续周期需再次协调。

业务参与更新与 effect 收据同事务提交，任务完成回执另行确认。提交后丢失回执通过 task 与授权 revision 核对 effect，保持原参与 revision。提交前崩溃无收据时先记录 NO_EFFECT_CONFIRMED，再按 `[30,120]` 秒有限重试，最多三次。旧 worker 的 fence 不能覆盖新授权。暂停/恢复后同周期复用 task 行并以新授权 revision 重新协调，旧过程保留最小审计。

Worker 可以按 proposal 原期限调用既有自然过期处理，释放已到期占位。暂停/撤销授权本身保留当前 proposal 原规则。管理员轮次、匹配执行和用户关系决策仍由既有合同管理。运行实现详见[状态与自动化合同](IMPLEMENTED_STATE_AUTOMATION_CONTRACT_V1.md)。

## 定向验证

- 104 项唯一 PHP 测试、1115 断言通过。主组 84/883，WebSocket 兼容组 11/74，消息语义组 9/158。B2 主体为 17 项参数化 case，覆盖私有纯读、授权生命周期、未知结果、旧账号迁移、资格变化恢复与 proposal 边界。
- 新迁移在 SQLite 完成 down/up，保留旧手动 ACTIVE 参与并保持自动化 OFF。主开发 MariaDB 增量迁移成功，effect 收据的 authorization_revision 列已直接确认。
- 真实隔离 MariaDB 中执行提交前 SIGKILL、提交后回执前 SIGKILL、双 PHP 进程并发和 claim 后撤销四项。两种 SIGKILL 均为退出 137。最终 effect 恰一份、参与 revision 为 1；撤销竞态 effect 为 0。隔离库 matching_runs 和 proposals 均为 0。
- 真实本机 HTTP 使用两个新虚构 QA 账号。Lifestyle、匹配准备与通知偏好变化反映到聚合视图，账号 B 保持独立。九类本人的来源/ledger 行摘要在六次状态读取前后相等。匿名请求拒绝，指定其他 user_id 查询拒绝。
- 未完成 Lifestyle 且自动化 OFF 的账号仍可访问社区、Buddy、social 与正式关系列表。空授权会话清单沿既有权限返回 404。实际双方 Connection/消息许可与消息读写边界由 20 项消息/WebSocket 定向兼容测试覆盖。
- 四项新增 Widget 测试通过，五个受影响 Dart 文件分析无问题，十六个 PHP 文件语法检查通过。
- 候选构建完成，APK 包名、版本、debug、arm64、签名与模拟器安装 SHA256 相符。保留数据的 AVD 使用 Android user 11 和 emulator-only ADB 5038，触摸使用模拟器内置 gRPC。

## APP 具名旅程

旧 B1 虚构账号进入状态中心时自动化仍为 OFF，准备不足时授权按钮禁用。新 QA A 在完成现有资格后，从我的页面进入状态中心，先查看授权说明，再明确确认。服务端记录 ACTIVE，最近任务显示已跳过及当前轮次报名阶段已结束。

APP 暂停写入 PAUSED，恢复写入 ACTIVE。结束 APP 进程并重新启动后，在线核验及重新读取仍显示同一授权 revision。随后通过 APP 撤销为 REVOKED。A→B→A 切号后，B 为探索未开始和 OFF，A 保持 REVOKED。代表截图来自同一 1011601 候选，见[截图索引](evidence/README.md)。

主开发库原轮次已结束报名，本轮没有为了演示而创建新轮次。真实报名副作用和下一已有周期的可靠性由隔离数据库与定向合同测试验证。主开发 APP 的新开放轮次报名、真实跨周日历等待、Owner 手机及整体实机验收均为 NOT_RUN。

## 调试、审查与原失败

只读 Sol/high 工程助手发现并复核了草稿清除委托绑定、同周期暂停/恢复后旧 effect、自然过期 proposal 阻塞三项修复。主代理另修复 User→task 锁序，以及 claim 后资格变化时 SKIPPED 指纹需保存执行时条件。后者定向测试先失败后通过，助手有界静态复核未确认新增 P1/P2。上述工程审查不替代 GPT 顾问独立验收。

扩大检查曾运行 97 项，得到六个 error 和七个 failure，其中一项为本版资格恢复缺陷，已修复。剩余十二项在固定任务提交的独立 backend 源码、原 app/bootstrap/config/database/routes/tests 下用隔离 SQLite 再现为相同名称的六个 error 和六个 failure。涉及旧 MatchingFoundation 准备 fixture/旧回滚索引、旧 Messaging 通知计数和旧 Social 预期。基线对照已直接核对 SlowDatingService、MatchingRunService 的实际加载路径及 APP_BASE_PATH。首次仅设置 PSR4 的对照仍加载当前 classmap，后续使用明确 classmap 和 base path 重新运行，前次对照保留并由验证后的记录取代。原记录保留，这些旧套件继续为 FAIL，完整全量回归为 NOT_RUN。

可靠性 runner 初次只覆盖 DB_*，而源码优先 APP_DB_*。首次 migrate 命中已完成全部迁移的主开发库并返回 Nothing to migrate，fixture 的隔离名称 guard 随后拒绝业务测试写入。之后增加实际 SELECT DATABASE 与 app-scoped 参数核对。另修复测试连接端口、虚构 phone 长度、只读 runtime 屏障及自定义 PHP 脚本异常退出仍为 0 的回执识别。失败隔离库、日志与配置快照全部保留。首次主库探测前后逐表摘要为 UNKNOWN，现有证据显示该次没有新增 migration，业务 fixture 被 guard 阻止。

MariaDB 揭示 admin_versions 的实际字段为 revision，原 version 误读已修复并加入状态断言。消息兼容 runner 缺少 Support trait 的首次启动失败已通过复制具名支持文件修复，随后九项通过。APP 探针修复了冷启动等待、ROUND_NOT_OPEN 文案预期及底部导航遮挡位置的触摸范围，最终逐项以服务端授权 revision 确认结果。

## 本机运行、备份和资产保护

本机 DB/API/WS 与 B2 专用调度运行，Laravel 原 queue 配置为 sync。专用启动器只运行 user-automation 事件，最终取证时已观察 31 次成功分钟回执，失败回执为 0。匹配消费者未启动。API 容器重启后该本机调度需要手动重新启动，步骤见[运行恢复说明](LOCAL_AUTOMATION_OPERATIONS.md)。SFU 保留 exited 状态。模拟器验证结束后停止，AVD 与数据保留。

主库迁移前私有备份为 3331363 字节，SHA256 `46bf44d402dc3a9fc6d5105ca0bc962a7b3e19ab851132275727b4c58eb96c42`。最终私有备份 3361220 字节，SHA256 `84c29c49dd03b5fdfed74a64d400baeaa39348f6bde064aec07cd3d58f77298d`，身份同时列入 manifest。最终备份的独立导入恢复本版为 NOT_RUN，既有 v10.1.14 隔离恢复保留原范围。

原 `D:\EliteSync-v10` 的 HEAD、分支、跟踪 diff、cached diff、相同选项 porcelain-v2 和 index 原字节均与本版启动快照一致。稳定根 `%SystemDrive%/` 保留。私有 SQL、凭据、APK、AVD、配置和原证继续由 Owner 本机保管。

## 停止边界与远端固定

本版 B2 工程具名交付后等待 GPT 顾问独立验收。B3、B4、阶段 C、Owner 手机、main 集成、正式发布及真实运营均为 NOT_RUN。Owner 整体实机验收安排在 B1+B2+B3 完成后。

产品源码已推送原任务分支，并由同一 origin fetch 与 ls-remote 回读为 `00cec7843911bb3341304c004059de0a91e12f16`。最终文档交付由包含本报告的 Git 提交固定，最终同源回读回执保存在 Owner 本机，交付回复列出该固定提交。
