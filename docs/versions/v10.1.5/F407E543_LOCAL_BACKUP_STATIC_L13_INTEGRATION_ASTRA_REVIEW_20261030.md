# EliteSync v10.1.5｜f407e543本地备份、Laravel13选择性集成源码候选与OCI下载受阻｜Astra独立验收｜2026-10-30

**正式裁决：`F407E543_PREMIGRATION_LOCAL_BACKUP_CODEX_REPORTED_VERIFIED_AND_STATIC_SOURCE_SELECTION_ACCEPTED_WITH_OBSERVATIONS / OFFICIAL_OCI_SUPPLY_INCOMPLETE_FAIL_CLOSED / LARAVEL13_MAIN_RUNTIME_NOT_RUN / SAFE_INTEGRATION_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED`。**

本审查只接受**已交付对象来源、备份操作有界记录及选择性源码静态集成候选**，确认供应失败后正确停止。**不签真正v10.1.4→Laravel13运行兼容或安全集成通过**；没有发生main产品合并或默认本地开发环境切换。备份真实文件、11,066项SHA及恢复试读是Codex本机报告，Astra直接查GitHub脱敏收据和程序对象，不能冒称已由Astra接触本地备份目录或独立复算全量哈希。

## 1. 固定授权与GitHub对象身份

- Owner已选择Laravel13＋PHP8.4作为未来开发基线，但不等于生产升级或整版v10.1.5验收；Owner要求旧版先在本地硬盘备份、验证成功后才迁移，旧版清理保留后续按项明确决定。
- 正式综合任务`docs/versions/v10.1.5/V10_1_5_L13_PHP84_BASELINE_SAFE_INTEGRATION_AND_PREMIGRATION_LOCAL_BACKUP_TASK_20261030.md` Git Blob `63712dba26ec1c24539bec7082dd4f0c557df583`。新task-owned根、attempt-0001与独立ledger；此任务已STOP，不得再消费未用余额。
- 唯一研发候选Commit `f407e543e1d6bcd3f9f7f341d876d97dc7228ac1`，Git原生**唯一Parent** `7a4595c60ac2fced957cd3bffd132daa23b4db74`，Root `976bde38f80720bb9ac44c1a5808e6cc62c686e1`；Parent Root `7d9005590deda0cd5f4e98f9676eae8c9a5daa23`。GitHub compare ahead1/behind0，18条变更。完整递归Tree候选6268、Parent6259 entries，均truncated=false。
- Manifest共17条非自身path/mode/Blob与候选Git Tree **17/17直接匹配**；Manifest自身Blob `c88f2413351701bb408236e8b26838d50c081d96`，因此18/18变更身份闭环，未发现额外路径。Result Blob `5aced9d9550d660cf3c1f9f9bbbc45a7c4b0c1af`、差异映射Blob `0845d8594de13d5f668bcb784bf336fda0843c4b`、备份收据Blob `4b604ea660eff7ffd80b8a3126b85b774c3d2ba9`、动态预算Blob `dfacb45f6e4f46124f5b6668383112aa7cd409ae`、失败/测试回执Blob `df255ee3f171769f1c8d1f324f0c7df5a38be76e`。
- 候选apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`与Parent一致，candidate services Tree `0d1a1e9b1c1064e7746051fb1e939e63c2b70891`，本轮只改变10个`services/backend-laravel/`路径和8个文档；原main已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`仍未变。

## 2. 本地旧版本备份：有界支持，但分清Astra证据等级

- Codex报告先确认本机旧dirty main HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、252项dirty、527 refs；只读识别现有Laravel11.48.0旧composer.lock/vendor及敏感配置归属，绝不覆盖旧主目录。旧本地源与GitHub接受v10.1.4 main是不同来源。
- Codex LOCAL_ONLY备份收据：独立受限本地目录，accepted main apps/services代码1420文件91,671,865字节，另复制旧工作代码、自有未提交修改、旧vendor8497文件与必要私有开发配置；总计**11,066文件 / 240,617,393字节**。报告逐文件读回11,066 SHA256及隔离恢复试读另11,066；恢复的apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，备份原Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。该回执由Codex产生并报告，Astra**没有读取或hash本地11,066原文件**。
- 备份通过状态可记`PREMIGRATION_LOCAL_BACKUP_VERIFIED_CODEX_REPORTED_LOCAL_TEST`，旧版目录/dirty/配置和旧vendor按报告不变且删除0；**不等于完整Git历史、真实生产数据库备份、数据库回滚、另一块物理磁盘冗余或新框架可用**。私有原件/ACL/FileID/manifest仅LOCAL_ONLY，严禁传公开GitHub或将本地备份路径作为他人可访问下载链接。备份必须保留，不把Owner“成功后可删”理解成目前删除授权。

## 3. 精确来源选择：静态集成候选可保留

- Astra用GitHub固定源candidate `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`、正式已接受main与本candidate Tree对照，确认实际只引入10个后端路径：composer.json/lock、config/session.php及7项相关测试适配。apps Tree未变。52项候选services差异已按10项框架兼容、26项未被正式接受的业务/测试变更、16项task-only工具分层；**未把F1/F3/F4未整版接受业务代码、额外业务迁移/路由、Windows/Task E2E资格工具无界合入main**。
- 目标composer.json `130793decf84ff8ab93faa0300117b7fab9d1826`、composer.lock `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`、session.php `dbcb582d0afbab3a0dc95576797730555ce3cd8d`与已独立限定接受的来源候选完全一致。Laravel13 v13.39.0、PHP8.4约束在**候选静态文件**成立，但当前main并未启用/安装vendor。
- 测试改动核实为transport私有query helper改名、PHPUnit12 DataProvider attributes、四个CSRF类名别名、Session array-store新测试。V1006测试只改CSRF import并保留原main refresh测试，不偷渡之前未接受的DeviceSessions/T0夹具。原业务授权源/SQLite TestCase等仍保留，单靠静态对照不能保证这些旧业务代码在Laravel13 runtime下可用。
- **重要待验证兼容项：** composer.json scripts及plugins白名单清空，不再提供原composer dev及package:discover自动脚本；新锁还将Guzzle7→8、Workerman5.1.9→5.2.3、lunar-php1.4.0→1.4.7。必须在正式目标产品集成前有界执行必要的包发现/路由/鉴权和框架相关回归；不能凭来源9b候选258/3071的旧测试判定本次选择性主线通过。真实旧Laravel11二进制生成Cookie迁移仍`NOT_PROVEN`，不能以合成PHP序列化array测试替代。

## 4. 官方OCI供应失败及STOP

- Codex原始本机回执报告：第一次PHP层读取提前EOF，已收25,738,667 bytes，完整状态/长度未记录，保持`NOT_RECORDED`；一次有界重取后PHP完整官方镜像source/config/diff-id闭包通过，之后MariaDB layer声明29,752,488 bytes、只收到19,119,531 bytes（HTTP200），产生第二次截断。**源镜像层没有完整关闭，不能用未核完整性镜像继续构建/迁移**。失败partial/raw和512MiB×2最坏预留均保留，未退款，未第三次重试或调用旧STOP任务镜像/数据库资产。
- 正式报告与预算文件直接可读：37供应请求、4 OCI index/manifest Digest、成功body186,327,053 bytes；两项各536,870,912 bytes失败保守预算保留，总**1,260,068,877 / 2,147,483,648 bytes**。动态关闭快照耗时5603.328秒、task+backup logical4,381,656,319/allocated4,434,054,160 bytes，均小于单任务16GiB/240分钟；Owner汇报最终封存118.67分钟。本机budget-terminal、completion receipt及原始ledger由Codex持有LOCAL_ONLY，Astra未直接核最终峰值，**不补造缺失首次HTTP状态和Content-Length**。
- 本轮**build=0、solver=0、vendor install=0、PHP CLI=0、Feature/Unit=0、业务HTTP=0、MariaDB migration/seed=0、服务组=0**；没有本次目标main产品的Laravel运行兼容、授权负例、API/DB持久或回滚验证。上一候选9b的Laravel13合成API/DB PASS是独立候选、独立业务代码/数据库条件，**不得转写为本次选择性集成候选通过**。
- 候选唯一STOP已封存：任何剩余预算都不能复用，不创建另一attempt填补，不能因成功读PHP OCI而重启旧任务。原始备份、临时镜像、失败数据及历史资产不清理。

## 5. 后续网络回退方案：Owner主动允许手动下载

- Owner明确补充“如果下载有问题，你可以给我下载链接，我手动下载后让Codex安装也行”。把此决定记录为**允许未来制定`OWNER_MANUAL_DOWNLOAD_AND_LOCAL_VERIFIED_IMPORT`路线**；不是本轮已完成下载、绕过来源约束或自动派发新任务许可。
- 可靠正式入口：Docker官方PHP镜像`https://hub.docker.com/_/php`、MariaDB镜像`https://hub.docker.com/_/mariadb`。真正交付可手动获取的文件前须对照本轮已固定的 **linux/amd64精确manifest Digest、config Digest、每层SHA256及长度**，制定逐件文件名、官方来源URL（可具有临时token/重定向，因此不能预先杜撰永久直链）、目标本机隔离目录与安全导入步骤。优先完整有签名/来源的OCI归档或官方registry blobs；不能将来源不明ZIP、任意镜像名称、Windows Docker Desktop安装器或一次性token/账号凭据发到公开GitHub。
- Codex在**未来单独冻结且Owner手动派发的任务**中仅可从新独立任务根读取由Owner取得的文件，重新计算每层/归档SHA、核索引manifest与platform/config/diff-id来源链、任务空间/权限和预算，合格再导入任务专属Docker tag/容器，不接旧Docker全局卷或生产库。手动外部下载及其耗费不得私下记为“本任务供应0”来规避新合同的完整来源、费用和请求预算。若下载源需要账户/新许可/费用，先Owner决定，不能自动代签。
- 可以沿新版本正式任务回归目标，**不重复整份竞品研究/Windows DLL/旧任务大规模镜像重下**；仅定点处理OCI传输可靠性与目标main选择性Laravel13运行验证。当前不发布后继、不开机运行或把旧版删除纳入本轮。

## 6. 正式裁决和仍需的独立门

**接受（限定）：** 18/18真实Git对象身份、保留main业务源的10个选择性兼容文件、备份+恢复的Codex本地回执（非Astra本地重跑）、OCI截断保留及合规动态STOP；`BACKUP_VERIFIED_CODEX_REPORTED`、`STATIC_SELECTION_ACCEPTED_WITH_OBSERVATIONS`、`DYNAMIC_SUPPLY_BLOCKED`。

**不接受/未证明：** `MAIN_PRODUCT_INTEGRATED`、`LOCAL_DEV_BASELINE_ACTIVE`、`RUNTIME_VERIFIED`、`SAFE_INTEGRATION_ACCEPTED`、`V10.1.5_FUNCTION_ACCEPTED`、真实旧Laravel11 Cookie/API/DB设备全链、AC05 RTC/AEC、G2、真实Push、v10.1.6、生产部署、旧版任何删除。旧四项事故状态、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`、Windows E_NOTIMPL永久保留。

**唯一下一决策点：** 由Owner决定是否授权一份新的、有正式隔离预算与来源/Hash要求的**手动获取官方OCI镜像材料＋Laravel13已选主线后端有界回归＋随后单次安全集成候选**综合任务。此处只形成材料路线，不自动派发Codex或删除旧版。成功后仍由Astra审查，按原工作流决定是否接入main；旧备份直到独立集成接受、回滚/本地连续版本可用及Owner另准清理前永久保留。

审查证据等级：GitHub物件/源码`DIRECT_GITHUB_OBJECT`，本地备份/hash/OCI/STOP与保留余额`CODEX_REPORTED_LOCAL_TEST`或`LOCAL_ONLY_RAW`，本轮PHP/Laravel/API/DB`NOT_RUN`。本Astra Review分支不是下一研发Parent。
