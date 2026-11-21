# EliteSync V2-CLOUD-R1｜G0b备份可恢复性与并行容量决策：单次安全接续

日期：2026-11-21。状态：`G0_SSH_READONLY_COMPLETE / CLOUD_WRITE_NOT_AUTHORIZED / BACKUP_RESTORE_NOT_RUN / CAPACITY_NOT_PROVEN / REAL_ADMIN_DATA_GATE_PENDING / PHONE_CLOUD_NOT_RUN`。这不是新的对外发布阶段，而是Owner云恢复主线的**最小前置收口**。

## 当期固定来源

- 工程R0最新 SSH 补证提交`9baa82aa0cdf947dcc4996d2a584c92e4f4535f1`，报告`docs/versions/v2/cloud-r0-20261121/V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md`。
- 顾问[SSH/旧DB/备份目录限定接受](../../workflow/V2_CLOUD_R0_G0_SSH_DATABASE_BACKUP_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)。
- 本地G1已有PHP8.4.28/Laravel13.39/MariaDB10.11.19/三盘HTTPS、迁移/回滚/单服务重启、worker/合成管理员/部分业务具名回执，尚非云端。既有R0报告中G2/G3、Connection 404、T0和旧星盘欠账不得改判。

## A｜仅使用当期已明确获准的只读来源完成G0b

1. 首先核本地Git、Worktree、SSH目标/认证资料和历史证据SHA，不读取/显示私钥内容；2026-11-21 root SSH成功是**已消耗的两轮具名只读工作**，不自动取得新一轮任意主机查询预算。可以不新增远端调用地分析既有两轮日志和容器证据。
2. 建立一张去敏**资源与端口表**：旧业务Nginx/PHP-FPM/旧MariaDB/Redis/LiveKit及网络/8088/443；主机2vCPU、2GiB RAM、约628MiB available、swap0、24GiB根盘余量，实际峰值和负载趋势UNKNOWN。不能把Docker只含一个LiveKit容器推成服务器空闲。
3. 新的远端哈希/负载/备份元数据操作如需SSH，先交Owner**固定主机身份、只读命令清单、读哪些目录、调用次数、输出脱敏、超时和归档方式**的简短审批；默认不读取业务表行。取得许可后才可对指定文件作SHA-256只读重算，逐条比较远端声明与本地3份、统计21组时间范围/是否有更新的可信来源；不打印备份文件内容。
4. 审阅历史备份生命周期和恢复所需的schema/版本，而非宣称当前SQL可恢复。**gzip完整性/恢复实际演练若涉及真实数据内容或临时实例写入**，必须另经具名个人数据/隔离资源门；无门则`BACKUP_RESTORE_NOT_RUN`。
5. 旧数据库当前正在主机使用。按Owner目标可提出**current-live-DB作为未来更近的来源候选**与旧五月备份并列比较，但只核其已允许的schema/system元数据，不查询真实管理员记录；到真实账号/角色读取才进入数据门。

## B｜优先做隔离云Staging方案与成本门

- 默认**不在现有2GiB旧主机并行启动第二套MariaDB、FPM和worker**：现场只见约628MiB可用、无swap，且旧Laravel+主机数据库+Redis+LiveKit仍在运行。即使24GiB磁盘剩余，不构成内存/性能及回滚合格证明。
- 推荐首选具名**独立的阿里云Staging实例/现有可验证独立资源**，在Owner确认具体套餐价格/账单影响、预算上限、地域、访问主体、可恢复备份和生命周期后再创建。具体规格需依据既有R0实测镜像和工作负载计算，先评估≥4GiB内存的测试档、临时资源隔离，不把4GiB写为官方性能保证。
- 如Owner不愿额外付费，则先继续本地WSL隔离及只读远端核身；不因此同意复用旧库或改旧站。旧服务器作为受保护生产基线，不能重装、升级、迁移、停机或动旧DB/LiveKit。
- 新Staging网络入口只给Owner测试手机和受控操作者；新域名/有效TLS、独立API base URL、私网DB及无旧地址回退是设备测试前置。当前nginx localhost回环证书不能直接外网用。不得提前开放443/改防火墙/Nginx或打洞到旧业务。
- 新实例镜像digest、APP_ENV=staging、DB preflight与空数据库迁移、独立备份/rollback及资源监测须作为真实云部署的`GO/NO_GO`条件，不从本地PASS继承云端PASS。

## C｜管理员与Connection：准备但不跨门

- 管理员真实数据：未经单独Owner批准，不读取/decompress/decrypt源SQL或管理员手机号/密码hash，不复制整个库。先提交“使用当前旧数据库或者指定历史备份”的**来源选择+管理员主体范围+允许字段+操作人员+独立恢复目标+回滚**决策包；只有获批后才做真实迁移，新密码/MFA/新ID/角色与允许名单三条件核验。
- Connection：仍被`LiveConsentService::enabled()`的旧本地资格拒绝。只允许设计`staging-instance-bound/synthetic-only/auditable/revocable`模型、合同正反测试方案，未经Owner选择不解除旧权限门、不宣称手机消息链PASS。
- 实机：原测试APK以及R1证据保留；云端独立TLS、新签名APK双端URL固定、测试设备授权均满足后才实施。手机测试仍NOT_RUN。

## 交付与停止

Codex下一次仅交**一份**综合中文“G0b决策准备/如已授权则只读补证报告”，含本地可复用证据、远端回执和权限范围（没有则NOT_RUN）、当前容量与备份状态、两种云方案的实报报价或UNKNOWN、真实管理员来源候选、下一次Owner需要一次性确认的具体选择。

禁止新增任何未获授权SSH、云实例开通/计费、旧服务重启或数据库写入、备份解密/恢复真实账号、开放公网端口和手机操作。新的实际云写入门明确通过之后才签下一个部署任务；不将本轮预检伪装部署完成。
