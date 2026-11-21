# EliteSync V2｜封闭内测准备：共享远程后端与旧管理员身份恢复综合任务

日期：2026-11-21。任务状态：`BETA_PREP_MANDATORY_GATE / LEGACY_ADMIN_IDENTITY_CONTINUITY_REQUIRED / SHARED_REMOTE_HTTPS_REQUIRED / PREPARATION_AND_SYNTHETIC_REHEARSAL_AUTHORIZED / REAL_ACCOUNT_DATA_GATE_PENDING / CLOUD_WRITE_GATE_PENDING / CLOSED_BETA_NO_GO`。

权威Owner决定：[旧管理员身份连续性必须在封闭内测前恢复](../../decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md)。本任务接续P0.3实机验收和P0.4功能收口；不是当前立即开始生产迁移或内测招募。

## 0. 先明确Owner真正要的结果

- Owner和经确认的同事在外地可以使用**原来已有的管理员账号身份/登录标识**进入同一V2测试环境，不必重新经过公开注册流程创建第二套账号。
- V2管理员账号在APP使用现有账号登录；经允许的管理员也能以同一身份登录V2 Web后台，按角色和受控名单获得必要管理能力。
- 保留原手机号等登录标识（手机号是当前V2唯一登录字段），但在V2分配新user ID并签发新密码/激活凭据。**账号身份连续不等于旧密码、旧Token或旧会话继续有效**。
- 此任务是内测准备阶段的必需项。核心功能P0.4和其它既定功能开发继续；不要为管理员恢复重新启动PC清理，也不要让云服务器采购提前阻断当前本地功能开发。

## 1. 起手：固定基线与当前实际身份（只读）

先读取：
1. `docs/workflow/ACTIVE_STATE.md`顶部CURRENT ENTRY；
2. `docs/decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md`；
3. 本任务全文；
4. `docs/versions/v2/cloud-r0-20261121/V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md`固定报告；
5. `services/backend-laravel/app/Services/Accounts/AdminAccess.php`、`config/app.php`、`app/Http/Controllers/Web/AdminController.php`、`app/Http/Controllers/Api/V1/AuthController.php`、用户表迁移与`V1006AdminWebTest.php`。

工程锚：R0本地隔离源码`4c255a0915ecc792b083f94798c40216ec870f07`、P0.2功能源码`362abd618a1f670e313b365b60b5dfe1f6ab71b8`、P0.3设备报告`651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`。先核实际本地工作区root/origin/branch/HEAD/dirty/index；保护脏main、IP13I、S1、治理树、专用Docker卷、旧阿里云MariaDB/Redis/LiveKit/Nginx和备份。不得盲pull/reset/stash/clean或覆盖。

## 2. 当前可自主完成的本地准备（立即执行）

### 2.1 管理员合同审计

当前源码合同：
- `users.phone`唯一，作为手机号+密码登录标识；
- `AdminAccess::allows()`要求账号存在、`disabled=false`、`role=admin`、手机号精确命中`config('app.admin_phones')`；
- `config/app.php`从服务器私有`ADMIN_PHONES`环境变量读取白名单；
- Web登录验证手机号和密码后调用AdminAccess，成功轮换Web session ID并写管理员会话审计；登录throttle 10/min，退出撤销会话并轮换CSRF token；
- API会话使用V2自身的DeviceSessions/Sanctum体系。

逐项确认当前P0.3之后源码有无改变上述合同；不能把测试库里的admin fixture号码或硬编码名单带到beta环境。真实号码只留本机受控材料或云Secret，不进GitHub。

### 2.2 恢复工具与数据映射（只用虚构记录）

实现/完善一个**仅CLI运行、默认dry-run、显式source和target identity、幂等且可审计**的LegacyAdminRestore工具：
- 只接受经Owner批准的候选清单，不扫描后自动导入全部`role=admin`；
- 映射旧`legacy_user_id`到V2新生成`user_id`，不复用旧ID；
- 最小字段白名单：规范化手机号（原登录标识）、显示名（若必要）、账号启用/禁用状态、经批准的管理员角色；可选邮箱仅当确为登录/找回必需且Owner批准。旧admin名单需在V2的私有`ADMIN_PHONES`中逐一设置；
- 记录私有映射/恢复审计：来源快照标识、旧ID、V2 ID、字段集合、时间、操作者、结果、回滚标识。公开报告仅输出代号/计数/哈希，不含手机号、姓名、邮箱或明文账号映射；
- 对V2已有手机号冲突采取STOP并人工审查，不能覆盖、合并或重置已有用户；
- 默认dry-run不写库；正式执行使用事务和唯一键，重复执行同一恢复批次返回原映射，不重复创建。

### 2.3 凭据重设与首登安全

- 不迁移旧密码hash、remember token、Sanctum access/refresh token、Web session、MFA secret、API key、设备凭据或密码重置token。
- 为每个获准恢复账号在V2生成独立新凭据或一次性激活码；只通过Owner认可的私有渠道交给对应持有人。不得写日志、命令参数、GitHub、截图、任务报告。
- 核当前代码是否有可用的强制首次重设流程。如果没有，先在合成账号上实现一次性、短TTL、一次使用、哈希存储、绑定用户和恢复批次的激活流程；成功后设置新密码并立即撤销激活凭据。不得用可公开枚举的短信/手机号验证码替代身份确认。
- 需要实现/验证：首次登录强制改密、登录失败速率限制、session ID轮换、旧会话/旧token不接受、退出撤销、管理员角色/allowlist任一撤销后当前会话立即失权、审计无凭据内容。

### 2.4 合成迁移演练

在现有`elitesync-v2-function`专用MariaDB隔离库内使用虚构旧管理员A/B：
- dry-run预览字段、映射和冲突；
- 正式合成迁移后生成新V2 ID，保留原登录标识，admin role + enabled + allowlist三条件同时满足；
- 使用新激活凭据登录V2 APP与Web后台，验证访问和审计；
- 旧密码/旧token/旧session拒绝，任一权限条件缺失403，禁用账号不能登录；
- 重复执行幂等、回滚只撤销本次新建账号/角色/名单/会话，不触碰其它V2账号；
- 不连接阿里云旧数据库，不读取真实旧账号行。

## 3. Beta准备阶段必须完成的共享远程V2后端

本机P0.3的`127.0.0.1:18444 + ADB reverse`仅供本机单手机测试。外地同事无法通过该地址访问，故正式内测准备阶段必须建立一个**共享、受限、可从外地登录的V2 HTTPS后端**。这不等于必须更换生产服务器。

### 3.1 现有阿里云实例优先评估，不能假定可用

CLOUD-R0只读现场已知：上海轻量应用服务器`Ubuntu-zlxh`、2vCPU/2GiB、采样可用内存约627–628MiB、swap0、根盘约24GiB可用；旧Laravel/PHP-FPM、主机MariaDB10.11.14、Redis和LiveKit仍运行。Docker只有LiveKit容器不等于主机空闲。旧库和旧服务属于保护对象。

- 先完成本地部署包、资源需求与端口/网络方案；当前不要新SSH、部署、开公网、重启旧服务或修改旧库。
- Beta准备时以现有实例作为首选候选，必须核容量、CPU/RAM峰值、磁盘、LiveKit与旧业务影响、端口、TLS、备份和回滚。若无法安全隔离V2 PHP8.4/MariaDB10.11与旧Laravel/MariaDB10.11.14，给Owner一个清晰的继续用旧机/额外隔离资源选择包。
- 不自动采购新实例或带宽，不自动改DNS/防火墙/443，不在旧机上直接复用生产DB、Redis、LiveKit端口或旧业务volume。任何真实云写入、费用、公网入口或生产服务改动均须Owner具名批准。
- V2远程环境应独立数据库/schema、volume、应用/worker、网络和服务身份；TLS有效，管理入口限制来源或加额外访问控制；数据库不公网暴露；原生/Dart API endpoint一致且无旧站回退。
- 若现有服务器资源不够，暂时使用本地合成测试继续功能；Beta准入保持BLOCKED，不要假装本地ADB reverse是共享远程环境。

## 4. 真实旧管理员数据门（仅在Beta准备、Owner集中批准后执行）

此前Owner意向是恢复旧管理员最小身份，但实际读取/解密/迁移真实记录仍需具名数据门。执行顺序：

### 4.1 来源核实与候选识别

- 候选来源优先级：当前旧阿里云MariaDB（最新活动状态候选）优先；2026-05-08三份历史备份为回退候选；另一组GPG密文独立，不与五月组混为一谈。
- 只读元数据证据已经确认旧Laravel配置指向主机MariaDB10.11.14；五月本地副本与远端声明哈希/大小/schema/端口匹配，但远端原gzip尚未重算、实际恢复未做。不得声称五月备份已恢复或完整可用。
- 真实行读取之前先具名核准数据来源、最新备份/快照、独立恢复目标、数据持有人、操作者、恢复用途与回滚责任；禁止直接在旧生产DB上跑迁移脚本。
- 只纳入Owner列明并由同事本人确认继续使用的既有管理员账号。需要同时核旧库角色、未禁用状态、旧服务器受控admin名单和同事本人对原登录标识的控制权。任一不符则该账户`BLOCKED_REVIEW`，不能通过手机号相似、旧admin标记或姓名猜测。
- 不在公开GitHub报告或Issue列出姓名、手机号、邮箱、账号ID、password hash或备份内容。Owner私有确认表以短代号列示。

### 4.2 Owner真实数据授权包（一个集中包，不逐个追问）

在实际解密/读取真实行和写入V2前，只提交一次精确授权包：
- 选定来源（旧MariaDB快照/具体备份manifest ID，不写秘密）及来源可信证据；
- 拟恢复管理员数量、脱敏候选代号、持有人确认状态；
- 字段白名单（phone/name/status/role及确需字段）；
- 明确排除字段：生日、城市/位置、三盘资料、真实姓名认证材料、聊天/作品/媒体、其它用户关系、旧密码hash、token/session/MFA/API keys；
- 独立目标V2数据库/实例身份，隔离网络与备份回滚；
- 操作者、恢复时间窗、费用、审计、失败撤销与通知方式。
Owner确认后方可解密/提取最小行并执行迁移。没有这一步就继续合成演练，不得读取真实管理员行。

### 4.3 实际恢复与持有人登录验证

- 只向V2 Beta数据库导入批准字段；V2新ID，保留已验证的手机号登录标识；不修改旧MariaDB原记录。
- V2`ADMIN_PHONES`私有allowlist只包含Owner确认的账号；role admin且enabled才授予后台访问。真实实名/KYC字段不得由管理员角色推断为verified。
- 新激活/重设凭据私下交给对应同事，强制设置独立V2密码；不向Owner或Codex回显明文密码。
- 每个管理员本人从外地通过受限HTTPS完成APP登录；获准管理员再验证Web后台登录、session轮换、用户/审核/举报/审计等最小必要权限、退出和撤权。不得仅由Codex代替本人登录并声称持有人已验证。
- 旧服务器/数据库/备份保持原状；V2失败时撤销新V2账号、allowlist和session，保留审计，不删除旧账号。

## 5. Beta准入检查（旧管理员恢复是硬门）

封闭内测申请前，至少满足：
1. 核心功能P0.4和必要设备/隐私缺口完成，当前APK与共享后端版本固定；
2. 共享V2 HTTPS从Owner和每位异地同事可达，端点/证书/API双端配置固定；
3. 所有Owner指定旧管理员账号均已完成最小字段恢复、本人新凭据激活与APP登录；授权Web管理员本人完成后台登录；未恢复账号清晰标记并阻止内测准入；
4. `AdminAccess`三条件、allowlist保密、session/CSRF/速率限制/撤权/审计正反例通过；
5. 测试人员、设备、账号、数据、告知、用途、反馈与停止机制由Owner确认；
6. 真实KYC、Push、RTC、删除受理如未就绪，必须有明确可见的内测降级范围，不能宣称已具备。

本任务不自动批准封闭内测。完成后提交一份Beta准备与管理员恢复报告，等待Owner集中验收和准入决定。

## 6. 交付

Codex在当前功能主线并行准备本地工具/合成迁移测试；不打断P0.4核心修复。报告包含：
- 当前旧管理登录合同与V2差异；
- 恢复CLI dry-run/合成演练/幂等与回滚；
- 旧源元数据和备份状态，清晰标NOT_RUN；
- 共享后端方案和现有旧机容量风险，不实际云写；
- 真实账号候选数据门模板（只在私有本地保存敏感值，GitHub只放脱敏摘要）；
- Beta管理员硬门和本人远程登录验证标准；
- 未完成项/Owner一次性集中决定。

禁止：全库导入、把旧role=admin全部复制、复用旧密码/token/session/MFA、直接改旧生产DB、真实数据未获准先解压、在公开GitHub保存账号清单、云资源自动采购/改防火墙/切DNS、main合并、正式内测招募、生产发布。
