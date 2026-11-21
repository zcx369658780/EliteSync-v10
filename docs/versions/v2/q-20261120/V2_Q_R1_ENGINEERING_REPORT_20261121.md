# EliteSync V2-Q-R1 中文工程报告

2026-11-21，Asia/Shanghai

**R1 工程自验 PARTIAL · 实机历史失败保留 · Staging 仅静态准备 · Production NO_GO · 清理待 GPT 顾问判断**

## 1. 授权、代码与证据身份

- 首读固定治理 [8e5e2272](https://github.com/zcx369658780/EliteSync-v10/tree/8e5e22724162158531c75b9e2e8513d326c621ed) 中的[手机顾问审查及云门禁](https://github.com/zcx369658780/EliteSync-v10/blob/8e5e22724162158531c75b9e2e8513d326c621ed/docs/workflow/V2_Q_PHONE_20261121_ADVISOR_SCOPED_REVIEW_AND_CLOUD_GATE.md)和[Owner 接续意图](https://github.com/zcx369658780/EliteSync-v10/blob/8e5e22724162158531c75b9e2e8513d326c621ed/docs/decisions/OWNER_V2_Q_PHONE_CONTINUATION_AND_ALIYUN_INTENT_20261121.md)。第二份文件提及的一次性任务书在该提交返回 404，执行依据为这两份固定文件和 Owner 本轮任务单。
- 工程根为 **D:/EliteSync/development/v2-phase-a-20261119**，分支 **codex/v2-q-r1-phone-cloud-readiness-20261121**，origin 为 GitHub 的 zcx369658780/EliteSync-v10。Q 固定交付为 **b35f6d0aa43a80e648143a30fbb17a91c2bf922a**，Q 产品源码为 **5e457fb0fd21c5978864f146d78120cc9a7d025b**。R1 父提交 **f155a9cb29f2a2f3ed989b46f1a9acd7de446cb9** 只比 Q 交付多一份本地实机报告，报告 SHA-256 **790c5b16c0f64ac0701640062d841007277ed0f3c37bc1219e65da1b4eb0eb42** 与顾问收到的版本一致。
- 本报告所在提交固定本轮源码。R1 Git 树 **apps 549d0547137bb03c9e75eb3ebafd0c594fb02586**、**services cee28052c40840c1ef1866dc8dcf8aa2ffee1289**。证据和测试脚本留在 **D:/EliteSync/development/v2-q-r1-evidence-20261121**，含隔离 SQLite、服务日志与 Flutter 基准工作树。本报告收录可审阅的测试摘要和证据哈希。
- 保护树核对为 **D:/EliteSync-v10** main@4bebc8f3，43 项已跟踪变更、213 项未跟踪、暂存 0。**D:/EliteSync-v10-product-v1015-20261101** S1@1d8b485b，未跟踪 2、暂存 0。**D:/EliteSync/development/v2-governance-handoff-20261120** @c73074be，未跟踪 1、暂存 0。

## 2. 两项实机失败与本轮工程结果

### 三盘本命 HTTP 503 · PARTIAL

历史实机独立 SQLite 只读回执显示两条未知时刻失败记录的运行身份均为 **IDENTITY_UNAVAILABLE / runtime_not_configured**。历史 Node 预检另有 **iztro 模块找不到**，之后补齐依赖。已知时刻 HTTP 的失败记录则显示 Python/星历运行身份 **AVAILABLE**，结果和结果版本为空。历史控制器把计算异常统一转换为 503，原记录不足以锁定该次异常。复查历史启动命令后，以同样的 Windows PHP 内置服务器方式和缺算法性别的已知时刻虚构输入重跑，**未重现历史 503，精确根因 UNKNOWN**。对 Laravel serve 环境传递的假设也未重现，历史启动使用 php -S。

本轮在新 SQLite 和回环端口里显式绑定本机 Python、Node 与已核对 SHA-256 的 DE440s，复用锁文件一致的 iztro 依赖。PHP 子进程成功执行 Python 和 Node，完整输入 POST 200，八字返回 COMPUTED_UNVERIFIED、紫微和西占模块为 CALCULATED，总结果为 **COMPUTED_UNVERIFIED**。省略算法性别时，八字部分可计算、紫微维持 UNKNOWN、西占可计算。未知出生时刻保持空，返回的西占为 UNKNOWN。分别验证结果版本、原账号读取、重启后读回和 SQLite 行。无身份返回 401、换账号看不到原结果、旧修订返回 409。指定不存在的 Node 时可复现 503，输入保留、状态 FAILED、结果与结果版本为空，重启后同样读回。

[NatalProfileController.php](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/NatalProfileController.php) 新增固定枚举的服务端故障分类，覆盖进程超时、执行不可用、运行身份不可用、适配器失败、JSON 和计算一致性错误。缺 Node 实测记录 **adapter_process_failed**。外部仍得到通用 503 和 private/no-store，日志不记录出生输入、异常原文或子进程输出。计算算法、运行身份验证、用途门禁、结果的非认证标识和竞争写入防护沿用 Q 合同。本轮验证了可运行的本地配置和故障分类，手机补测仍待安排。

### 编辑基础资料页 · PASS（Widget 与后端定向）

[编辑资料页](../../../../apps/flutter_elitesync_module/lib/features/profile/presentation/pages/edit_profile_page.dart) 的两种构建统一使用“保存基础资料”，说明昵称和城市可单独保存，排盘需从“三盘本命排盘”另行填写和提交。核对按钮、字段提示、空时刻确认、等待、成功和失败提示。成功提示依据保存返回的出生时刻，空值仍表述为未知。Widget 覆盖两种构建、空时刻取消和确认、保存等待与成功、已知时刻保存、非法坐标、昵称及城市独立操作。

后端回归按 APP 实际提交方式先写已知时刻，再发送空字符串。服务读回 null，数据库未采用默认午时，也未创建星盘或三盘记录。返回仍为 recomputed_at=null、astro_profile=null。注册可信 T0 与旧排盘 A/B/C 仍待 Owner 决策。

### 实际测试与证据

| 检查 | 结果 | 日志 |
|---|---|---|
| **php vendor/bin/phpunit --do-not-cache-result --filter 'V1010NatalApiTest\|V2Phase[A-D]\|V2Q' --log-junit …**。Windows PHP 8.5.3、Laravel 13.39.0、SQLite 3.49.2，PHPUnit 使用内存 SQLite | **PASS，29 项 / 346 断言**。含相关阶段安全用例、空时刻保留、503 分类不泄漏、私有读权、停用和旧修订 | php-targeted.xml |
| **flutter test --no-pub --reporter expanded**，目标 edit_profile_local_birth_test.dart、edit_profile_city_test.dart。Flutter 3.41.7 / Dart 3.11.5 | **PASS，8 项**。新增两项在旧文案上先失败。改文案后同步修正旧城市测试的按钮查找文本，保留交互断言 | flutter-red.log、flutter-scoped-final.log |
| **flutter analyze --no-pub**，针对编辑页和上述两个测试文件 | **PASS，3 文件零问题** | flutter-analyze.log |
| 扩围加 profile_page_test.dart 与 b3_me_navigation_test.dart，另在 Q 固定提交以相同 SDK 对照这两份旧测试 | **FAIL**。R1 27 通过、5 失败，固定 Q 对照 19 通过、同名 5 失败。涉及资料回填、个人准备布局、窄屏和两项管理员入口 | flutter-profile-final.log、flutter-baseline.log |
| **python -B -u run_natal_http.py fullfinal fixed**、**historicalreadback historicalfixed**、**missingnode missing**。新文件 SQLite、各自回环端口、真实 Python/Node，PHP 内置服务 | **PASS**，进程计算、HTTP 和重启读回、失权及缺依赖负例。历史已知时刻的实机故障根因仍 UNKNOWN | natal-fullfinal.log、natal-historicalreadback.log、natal-missingnode.log、natal-missingnode-category.log |

证据 SHA-256

| 文件 | SHA-256 |
|---|---|
| php-targeted.xml | 1bfd59ed487ca3f978a029228bbf0de2fa80e4ed6822e13a86c63bc5bf85df41 |
| flutter-scoped-final.log | 0c9f186462215950970081a1fb8d405380673ed49a1fb401e5fce8c20e13cb34 |
| flutter-analyze.log | 36fabfced63532de1eaeb6f4799c8d2e98e2fe5d727dbd931e2863595650a5bf |
| flutter-profile-final.log | aa185c1bd26ca98aaf7fc64ad2474da1846d698e941afc433dada8ecc1ab02b4 |
| flutter-baseline.log | c1374e5bc23541ff740a7f684d06c974c5fd97b7c0523622583a46b639011e51 |
| natal-fullfinal.log | 227e7e6f031d6927dbd3a39a80a7958707d884ba4620b8fb5a3e8a43ea79d0f0 |
| natal-historicalreadback.log | 73a61141a29ffa6dbdfa8a831e15bae357ec1813a7660f43957308399de22759 |
| natal-missingnode.log | 72d697897af99dbb4330c6637a15821fe89eb9129b8be5e044f7dc9269e246e5 |
| natal-missingnode-category.log | d1623e9e6937a4be08b9ec63cbd3fa37b2a855c299fff6d27fe34d348e7dc415 |

阳性完整输入首先以 HTTP GET 读回版本 1，提交未知时刻修订 2 后重启服务，GET 与 SQLite 均读回版本 2。SQLite 哈希分别为完整输入场景 **1dac2a64edb636d8495ce7db53633fda966b09acd9d5a033f3779b72e33c277c**、历史同启动方式场景 **9f5fda132069f00d5aff20a3fe08f152bfe1259ff79ad7d3c8b8dea657b829c2**、依赖缺失场景 **d48d8d6269b7f6896c4044e49cbd38d9f454444ff454db9e216206163bbc5201**。

Q 全量 PHP **46 errors / 122 failures** 与旧排盘兼容 **25 条 FAIL** 保留。R1 全量 PHP、全仓 Flutter、PHP 8.4、容器 PHP-FPM/MariaDB、真机重测、跨端、真实 KYC/Push/RTC、法律受理及正式发布均 **NOT_RUN**。

## 3. Docker 与阿里云 Staging 准备 · PARTIAL

| 检查点 | 当前证据 | 部署准入要求 |
|---|---|---|
| Docker / Compose | Windows Docker 客户端 29.3.0，context desktop-linux。命名管道不可用，服务端、镜像 ID/digest、容器及卷 **UNKNOWN**。docker compose 子命令未注册，已安装独立 docker-compose v5.6.1 | 具名授权后，在独立环境读回 daemon、有效 Compose 配置、项目名、镜像 digest、应用 Git 树、composer.lock 与实际容器版本。 |
| PHP / Laravel / MariaDB | 本机 PHP 8.5.3 / Laravel 13.39.0。Q 的 [php.Dockerfile](../../../../services/backend-laravel/docker/php.Dockerfile) 声明 php:8.5.3-fpm，Composer 约束为 ~8.4.0。Q 树含 nginx/FPM 配置，无跟踪的 Compose 编排 | 先选符合 Composer 约束的 PHP 8.4 镜像并固定 digest；验证要求的扩展及 Laravel 依赖。MariaDB 现用镜像/版本未知，独立实例做迁移、并发、读回和恢复演练。 |
| 排盘运行时 | Windows 隔离验证依赖版本与 DE440s 固定字节；旧 FPM Dockerfile 本身没有交付整套 Python、Node 与数据运行时 | 在批准的 Linux 镜像中锁依赖与数据 SHA-256，以 FPM 用户核执行及数据只读权限。验证无外网计算回退、已知与未知时刻、缺依赖失败、重启读回。健康检查不依赖真实出生数据。 |
| 阿里云目标 | 2026-09-24 时点是上海轻量应用服务器。当前实例身份、规格、应用、DB、权限、主机密钥和成本为 **UNKNOWN** | 先提供精确资源标识、区域、操作者、网络范围、预算、到期与回滚负责人，获批后只读复核再安排部署。 |

建议设计为独立的低并发 Staging。入口经可授权的 VPN 或 IP 白名单和 TLS 访问独立域名；反向代理转 PHP-FPM，MariaDB 仅在内部网络可见。应用账号、迁移账号、密钥、卷、媒体目录、备份和日志均用专属资源；管理面仅私网或受控入口，保留真实供应商关闭和虚构数据限定。预估 **2–4 vCPU、4–8 GiB 内存、40–80 GiB 磁盘**用于小规模试跑，按镜像、数据库、媒体、日志、回滚副本和压测重新核定。MariaDB/Redis/FPM 端口不对公网开放。核对 Nginx、FPM 和客户端超时，覆盖排盘子进程总耗时。

切换前记录应用与数据库迁移版本、镜像 digest 和回滚点。在独立 Staging 上以虚构数据验证迁移、审计和保留期，演练前一镜像回退以及从隔离快照恢复到新卷。数据库采用向前兼容迁移，发生不兼容时先停放量和写入，再切已验证的独立环境。原云业务和数据库沿用原部署；禁止重置其系统镜像、覆盖原服务、清理卷或以旧库覆盖 V2。当前只完成静态准备。 [历史资源治理记录](https://github.com/zcx369658780/EliteSync-v10/blob/8e5e22724162158531c75b9e2e8513d326c621ed/EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md) · [阿里云 Docker 文档](https://help.aliyun.com/zh/simple-application-server/use-cases/deploy-and-use-docker) · [轻量服务器防火墙文档](https://help.aliyun.com/zh/simple-application-server/user-guide/manage-the-firewall-of-a-server)

## 4. 旧管理员恢复预案 · 执行 NOT_RUN

只核对脱敏元数据。历史目录 **D:/EliteSync/backup/database/aliyun-legacy** 有 2026-05-08 的三套 manifest、gzip 对象和 SHA-256 sidecar，sidecar 格式检查通过。清单说明的是 SQL 压缩包，缺少可证明加密状态、真实管理员范围或当前有效身份的字段。此前 9.0-C GPG 交互中止，报告中的密文、转移与隔离恢复均无完成证据。隔离 MariaDB 10.11.18 曾准备成功，结构与摘要比对未运行。安全恢复 VHDX 或历史加密准备同样无法证明旧管理员已可恢复。现有元数据只用于确定待核项，备份载荷未解密、解压、读取或上传。

| 旧字段或能力 | V2 最小处理 |
|---|---|
| 旧账号 ID | 只在后续获准的隔离核对表记录脱敏映射；V2 使用新 ID，逐人核对归属和冲突。 |
| 旧姓名或显示名 | 经本人/Owner 复核后提供最少展示字段；主体未确认则不创建可登录账号。 |
| 旧联系方式或登录标识 | 由 Owner 单独确认可用的当前登录标识；先核查唯一性与归属，禁止批量复制真实联系方式。 |
| 旧管理员标志 | 仅作人工复核线索。V2 AdminAccess 要求活跃账户、role=admin 且进入受控手机号名单；默认无管理员权限，逐人审批。当前实现无更细的角色映射证据。 |
| 密码及哈希、令牌、会话、MFA、其他用户资料 | 排除导入。经单独许可后使用新凭据流程和新的认证状态，复核旧凭据不可用、未批准主体不能访问管理面。 |

未来需 Owner 具名批准来源、合法用途、操作者、入选账号和留存期限。先用虚构数据验证映射、冲突和拒绝路径，再讨论获批密文的最小字段提取与审计。若源加密、完整性或归属无法证明，停在人工核对。保留历史生产库与备份原件。

## 5. 附录 · 待 GPT 顾问判断的清理项目

**CLEANUP_REVIEW_PENDING**。Owner 希望保留最新 APK 和有效开发缓存，并将过期 APK/缓存纳入审查。此次仅列候选，清理 0 项。当前可核验的 Q 实机 APK 为 **com.elitesync.v2qdev / 1011804**，约 **199.6 MiB**，SHA-256 **db142f7b884589c62622dab8b3cc0e9672a67e33a094b62ffe0aa615ae1326d7**。保留这一 APK 及对应包身份、签名证据、源码、构建来源和实机报告。此次未生成更晚的 APK。应保留仍供离线构建或本轮排盘复验的 Flutter/Gradle/Maven 缓存、Python/Node 依赖、锁文件和星历数据。

| 顾问待判 | 盘点量 | 执行条件 |
|---|---|---|
| 五棵旧 Codex 工作树的可重建 .dart_tool / 项目级 .gradle | **539 文件 / 0.98 GiB** | 仅审查已结束且没有现用引用的缓存；保留离线依赖源。 |
| 旧 IP13I 复审树、9.1C 文档发布快照、R6S 授权发布树 | **20,499 文件 / 0.68 GiB** | 三棵已核无修改、未跟踪及忽略条目且提交可从相应 GitHub 仓库找回。若顾问同意版本目录清理，先记录重建索引。 |
| 上述五棵旧树里 Android/Flutter 构建输出 | **7.27 GiB**，与缓存候选不重叠 | 逐一核对 APK/AAR 引用和哈希，保留最新候选及唯一证明旧结果的包；先去可重建中间产物。 |
| 旧设备测试镜像、旧工作树剩余部分 | 126 个镜像合计 **69.81 GiB**；D 盘旧工作树目录 **13.56 GiB**、测试目录 **29.03 GiB** | 目前为调查范围。检查当前进程、镜像依赖、未提交成果和本机唯一证据，禁止整目录删除。 |
| 文档与记忆收敛 | 上次盘点 25 份交接约 **241 KiB**；449 个重复文件路径约 **0.53 MiB**；38 个项目记忆候选约 **182 KiB** | 顾问判断继续保留的入口与历史引用。以固定链接归档，保留共享记忆、会话、凭据及其他项目状态。 |

先审查 **1.66 GiB** 首批候选；各组为文件逻辑长度。Q 实机证据约 1.50 GiB、原脏 main、S1、治理树、未同步资料、旧数据库、恢复 VHDX、当前软件缓存和本轮隔离证据均排除在普通清理之外。

## 6. 等待决策

- Owner 继续保留注册 T0 与旧排盘 A/B/C 裁决权。另行批准 Staging 实例、费用、账户、云操作范围和回滚方案，才进入执行。
- 旧管理员真实恢复、手机复跑、外部供应商、正式 A6、main 合并与发布维持各自授权边界。
- GPT 顾问按附录给出清理范围。收到具名范围后，执行前再核对最新 APK、缓存依赖、已备份清单和工作树状态。
