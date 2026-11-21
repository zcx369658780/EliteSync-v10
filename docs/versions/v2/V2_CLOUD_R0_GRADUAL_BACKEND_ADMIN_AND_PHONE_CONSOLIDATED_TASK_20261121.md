# EliteSync V2-CLOUD-R0｜阿里云渐进后端恢复、管理员最小恢复与手机复测单一综合任务

日期：2026-11-21。执行原则：**推进到每个实际满足的安全门，首次缺真实授权时只停该高风险子项；其余本地隔离工作继续，最终一次集中报告**。阶段结论`PREPARE_AND_PREFLIGHT_AUTHORIZED / STAGING_WRITE_CONDITIONAL / ADMIN_PII_RESTORE_DATA_GATE / PRODUCTION_NO_GO`。

## 0. 首读与零清理

- 唯一当期Owner决定[渐进恢复授权](../../decisions/OWNER_V2_GRADUAL_ALIYUN_RESTORE_AND_ADMIN_ACCOUNT_RECOVERY_AUTHORIZATION_20261121.md)。代码基线R1 `585a8c21aeab103daac166338f881ef343c8af99`；清理收口 `716e74d92c7b9e9a10f6dc474e8300a222f0357b` 和顾问结论 `95401764f90244a3764552d901741011a6720ac5`。
- 先以本机实际Git root/origin/HEAD/branch/index/dirty检查，继续现有合法工程工作区，不盲pull/reset/rebase/stash/clean，保留原脏main、IP13I、S1、治理树、历史9.1C、APK、JUnit、数据库、备份和密钥。**PC清理已停止，不另跑盘点。**
- 只使用Owner现有连接/受控账户/工具；禁止浏览器/SSH会话把secret、个人数据、数据库原件或远端证书私钥写入公开GitHub、工具回显和普通日志。输出仅类别/数量/状态及去敏校验。

## 1. G0｜阿里云资源身份与安全只读现场核查

目标为历史资料中上海**轻量应用服务器**，不是未经验证的ECS/RDS。首先按可实际使用的云控制面，只读核**当前**所属账号/地域/产品类别/实例ID/服务状态/CPU内存磁盘/剩余空间/公网绑定/是否存在外部账单影响。再核当前站点的服务角色、Nginx/API、运行中业务与数据库所属、容器网络/挂载关系及已有备份。取证只读、最少，不能扩大主机内数据访问范围，不会因为旧IP或SSH历史可用而跳过主机真实性验证。

- 现时SSH目标与有效端口、可信host key、操作者权限如未核实，不用`StrictHostKeyChecking=no`或重写known_hosts硬闯；需通过独立可信途径建立实例与目标绑定。不要自动复用2026-09-26历史一次性命令预算。
- 若控制台要求Owner验证码、密码、实名确认、授权升级，停止此动作，集中汇报精确需求；不能以替换登录方式或工具猜测规避。不得读取原业务库行或管理员PII用于“仅只读”名义。
- 记录`INSTANCE_IDENTITY_VERIFIED`或`BLOCKED`，并建立“旧业务不可触碰清单”。现有云端缺备份证明时，在任何写入前STOP对应云分项。

## 2. G1｜构建可部署、可复现且隔离的V2 Linux运行时

- 优先在**本地或任务专属独立环境**完成，再决定云端部署；Windows Docker desktop-linux未启动不代表云端已存在可信镜像。不能因为旧Linux镜像名称相似就认同Q/R1源码。
- 固定从R1源码出发，构建新的`staging`定义：PHP8.4（R1 composer.json=`~8.4.0`，旧Dockerfile却`php:8.5.3-fpm`）、Laravel13+锁定composer依赖、Nginx/FPM/worker、MariaDB10.11独立测试库及专属volume/网络、最小持久媒体路径和审计，必要Redis队列隔离。所有镜像固定digest和SBOM/依赖版本；源/构建树/镜像身份可追溯。
- 本命计算在FPM/worker同等权限下验证Python/Node、锁定iztro、de440s及已准入数据原字节SHA、只读权限/超时/内存；本机R1的HTTP正向并不证明容器内运行，旧手机503根因仍UNKNOWN。无真实出生数据/外部计算回退。
- 若Docker Desktop不可用，可另用可验证、可撤销的独立构建主机或未来的独立Staging构建渠道，但不得因此覆盖当前生产容器、安装/卸载服务器Docker组件、清已有volume。依赖/OCI来源和新费用需要按现行授权单独核。
- 把`APP_DB_CONNECTION`、`DB_CONNECTION`、`DB_URL`、`APP_ENV`和PHP/FPM有效配置实际核对为新**空**Staging数据库。防误清门先验实际连接，不对历史DB运行migration或`RefreshDatabase`。具名P0回归+数据库迁移/回滚/并发、登录会话/Block、私有媒体、命令幂等、三盘HTTP成功与503负例。记录真正未跑项，不追求抹平旧全量46errors/122failures和25旧盘合同。
- 只有当现时云资源、隔离资源容量、零旧业务冲突、访问主体、受限TLS入口、备份回滚、明确费用边界与部署身份均PASS，才提交**真实云端Staging写入资格**。Owner已同意渐进目标，不代表自动获准重装系统、购买资源、公开公网管理面或触碰旧数据。写入涉及新公网入口、云费用、原生产配置/端口时停在`OWNER_CLOUD_WRITE_GATE`。即便实际Staging获准，也只能用虚构用户，不得将其宣传为正式发布。

## 3. G2｜旧管理员备份与帐号数据最小恢复

- 先用已有本地**仅元数据**审查旧来源：R1报告`D:/EliteSync/backup/database/aliyun-legacy`有2026-05-08三套manifest+gzip+SHA sidecar；历史9.0-C GPG交互中止，不能声称此组备份已加密或完成独立恢复。其它年代`D:/SecureBackup/EliteSync9x/Database`线索不能与该来源混用：若存在，分别核实际文件、SHA、备份时间、来源实例、schema版本、是否含管理员以及合法保存/解密资格。无独立证明时停止真实提取，不能假设“几个管理员”表示整库仅数行。
- 先合成映射`legacy_account_id→V2新的user_id`、合法联系人标识及`role=admin`、当前`config('app.admin_phones')`受控allowlist，并核AdminAccess逻辑：非禁用 + admin角色 + 显式名单共同成立。为每个候选定义属主确认、字段、权限、迁移审计和撤销/回退、重复账号/手机号冲突分支。
- 真实恢复只应是**获证明的最小管理员主体**，不复制整库、密码hash、旧JWT/refresh/session/MFA、历史聊天媒体、生日地理坐标和其它用户数据。重设新密码与MFA/设备认证；旧会话须不可用，未确认主体fail closed。不要在GitHub、命令行、日志、PR/Issue显示完整手机号/姓名/hash、备份明文或密文文件。
- Owner明确希望恢复已有管理员，故可完成安全的备份来源核实、**空库+全合成管理员迁移演练**和真实恢复包准备。但在需要解密/读取真实原始行、向真实V2库导入前，应以一份集中Owner门禁确认**究竟哪一份备份、哪些管理员主体/字段、数据持有人和测试隔离库**。若源不可验证、本人/Owner未证明归属、管理员名单或隔离环境缺证，不擅自进行真实数据操作，也不得自动创建带真实旧身份的管理权限。
- 推荐“只迁移最小已核身份与角色，重新签发凭据”，独立记录备份与恢复后admin名单计数（不泄露个人信息），原旧库和备份保持不变。

## 4. G3｜真实阿里云后端接手机的隔离回归

- 真实云端**隔离Staging + HTTPS/可信证书 + 有限入站来源**PASS才启动。新构建独立测试包必须固定APK SHA、包名、签名、版本、源码与API base URL，并验证不误连原旧生产；禁止在日志中输出token/用户PII/私聊正文。
- 以虚构账号及获准的单台测试手机核注册/登录与重启读回、资料说明、已知/未知出生时刻三盘POST/GET/FAILED→复核、账号权限/切号、频道与评论受众、私有封面失权、双向Connection→消息同意→消息→Block、Buddy原命令查后重试、通知最小投影、设备撤销与退出。检查MariaDB真实回滚/并发、长时计算FPM timeout、队列作业，不借此宣称真实KYC/Push/RTC/音视频和正式身份已PASS。
- 管理员如已完成G2合规恢复，另以受限管理登录验证只有本人允许名单可访问，审计可查，旧token失效；如未恢复则用合成管理员完成管理入口正/负例，真实账号项`NOT_RUN`。
- 真机新增授权/设备无法取得则停G3实际操作，保留具体`DEVICE_PENDING`，**不得把先前Windows回环手机报告记作阿里云实测**。

## 5. 停点、回滚与报告

一份综合中文报告，固定非main开发分支GitHub提交（无个人数据），含阶段G0–G3矩阵：`DONE / PARTIAL / BLOCKED / NOT_RUN`、每个真实操作的操作者/目标实例类别+ID脱敏/环境、源码与容器digest/Compose identity、命令退出码、截图及敏感数据本地SHA、后端与MariaDB测试、管理员归属审查状态、回滚与成本、真实APK/手机入口和失败。若出现关键门禁，**只集中给Owner一个具体决策包**，其余可合法进行的独立任务尽可能完成。

禁止：删除PC旧目录、重新安装/重置旧服务器系统、覆盖原站/生产Nginx或DB/volume、`docker system prune`、`compose down -v`、`migrate:fresh`到未知DB、降低SSH/TLS校验、开启公网3306/6379/管理面、未经许可恢复真实账户或发布。Production维持`NO_GO`；旧排盘A/B/C和注册可信T0产品决策继续`PENDING`，fail-closed不变。
