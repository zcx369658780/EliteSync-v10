# EliteSync v10｜CURRENT

更新：2026-09-24。此页是本地项目状态快速入口；任务、产品决定、风险门和证据分别见 `TASK_CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`EVIDENCE/`。旧 remote-centric 治理文档仅作历史来源。

本地工作流迁移提交 `1a2ab56be66673b7151ce2d6dac3ca3dae2d7337` 已完成独立本地验收：`EVIDENCE/WORKFLOW-MIGRATION-20260923/summary.md`。该验收不包含 APP-INT-05。

Codex 本地执行入口 `WF-CODEX-01` 已独立 ACCEPT，见 `EVIDENCE/WF-CODEX-01/summary.md`；根 `AGENTS.md` 和项目技能已在全新只读 Codex 任务中核验。

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

AUTH-49 已下达 docs-only 的认证解密与本地备份恢复合同：细化 AUTH-48 暴露的失败输出隔离、Owner 密码/私钥及服务器/真实 DB/同步边界的后续门，交付后由 Work LEVEL 2 独立审查。尚无执行结果，不授权真实数据动作。

## Product scope

Relationship Decision Support System；MVP 顶层 `Home | Progress | Messages | Me`。Match、Connection、Conversation、Relationship 权限与生命周期分离；Home 是低密度只读状态投影。Explore、Relationship support 属 Phase 2；AI/reference signals 属 Later/Optional。已接受语义及来源见 `PRODUCT_DECISIONS.md`。

## Flutter

已接受 APP-INT-04：独立消息同意后可在本地 synthetic Conversation 列表/详情读发文本；Connection 关闭后重新锁定。APP-INT-05 Home 随四段状态更新唯一下一步按钮；作者回执报告 targeted tests 17 PASS、Android debug assemble/install/cold launch/main-loop PASS，analyze 为 0 errors、18 条既有 warning/info 且命令退出 1。独立审查静态代码并原样集成，未重跑工具链；这些不是发布证明。

## Backend

仓库有 Laravel 11 代码、历史 Runtime Readiness/Canonical Match synthetic HTTP 与 Product Connection evaluator、mapping、application/persistence 开发态工作。真实 auth/session、Connection/Conversation writer 和生产 backend authority 未建立；APP-T12 的 G-02/03/05/06/08/13 仍须按各自最新证据逐项关闭，不以 synthetic 演示推定关闭。

## DB

Contract/mapping：Product Connection 开发态映射有既有接受链。Local/test：存在 Laravel migrations 与 synthetic/dev-test persistence 证据。Target environment：AUTH-14 仅确认部署目录本次 Laravel CLI 视图的四条目标 migration 均 Ran（57/57）；实例身份、实际表结构及 Web worker 配置未核验。Production DB：**NOT ESTABLISHED**；AUTH-14/16 仅为部署目录 CLI 迁移账本与固定结构投影，无目标实例身份、Web worker 同库、整库 schema、备份/恢复或真实数据持久化证明。

Owner 于 2026-09-24 授权：未来任务若确需修改阿里云后端数据库结构，必须先备份并校验可恢复；可将现有管理员创建的测试账号信息导出到本地供变更后恢复，**不得上传至阿里云以外的其他地方**。Owner 最新决定是完整数据库备份加密保存到自己的电脑或本地磁盘，自完成日起保留 **30 天**；恢复演练优先在电脑上的独立环境，先核验隔离与恢复能力。专用目录已定为 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，密码在实际需要时由 Owner 本人输入；加密/密钥恢复、传输、真实数据范围与恢复路径尚待核验；不代表已完成真实备份或恢复。敏感导出不得纳入 Git、Git bundle、普通证据或第三方云服务。

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
