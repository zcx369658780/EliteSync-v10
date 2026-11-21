# EliteSync V2｜P0.4剩余功能修复 + Beta管理员恢复工具加固综合任务

日期：2026-11-21。状态：`P0_4_REMAINING_LOCAL_REMEDIATION_AUTHORIZED / SYNTHETIC_ADMIN_RESTORE_ACCEPTED / REAL_ADMIN_DATA_GATE_PENDING / SHARED_HTTPS_CLOUD_WRITE_GATE_PENDING / NEW_APK_DEVICE_INSTALL_OWNER_GATE / CLOSED_BETA_NO_GO`。

依据：
- [本轮Beta准备报告](https://github.com/zcx369658780/EliteSync-v10/blob/0fd75198db3067782241b6777054050ac2af6918/docs/versions/v2/cloud-r0-20261121/V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_REPORT_20261121.md)
- [本轮顾问限定验收](../../workflow/V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_ADVISOR_REVIEW_20261121.md)
- [Owner旧管理员恢复Beta硬门决定](../../decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md)
- [Owner功能优先决定](../../decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md)

## 0. 固定基线与禁止事项

- 报告提交`0fd75198db3067782241b6777054050ac2af6918`，相对P0.3`651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`ahead3/behind0，开发分支`codex/v2-function-completion-20261121`远端HEAD与报告一致。
- 起手核当前本地工程root/origin/branch/HEAD/index/dirty。保护原脏main、IP13I、S1、治理树、P0.3 APK/截图/日志、MariaDB专属卷；不reset/clean/删除/覆盖。
- 本地专用`elitesync-v2-function`及MariaDB`elitesync_v2_function`可继续具名测试，运行前核容器/卷/DB identity；不`down -v`、volume prune或全局Docker清理。
- 本任务允许P0.4本地源码/Flutter/PHP修复、合成管理员工具加固、合成演练、Owner数据授权包模板和共享环境方案。**不授权**真实旧数据库行读取/导出、历史SQL解密/恢复、真实V2账号写入、阿里云SSH/云写、公网/防火墙/DNS变更、实例采购/额外费用、真实管理员激活或新APK安装覆盖1011805。
- P0.3 1011805实机证据固定不变。P0.4源码需重建新APK时，只能生成和固定本机工件；安装到设备或覆盖当前包必须先取得新版本/设备操作的Owner明确授权。
- 封闭内测仍NO_GO；不得合main、软著申报或招募同事开始测试。

## 1. P0.4｜消息UNKNOWN重试必须保证新鲜权威读回

顾问抽查发现当前`_retryUnconfirmedMessage()`的`await _load()`不保证一定发出新的GET，因为`_load()`在已有`_loading`、`_loadingOlder`、后台/会话变化等情况下可以直接return；随后重试仍可能读取旧`_messages`并POST。

修复要求：
1. 建立一个明确的`readLatestForRetry`/等价方法，返回`freshReadSucceeded`与当前会话/peer epoch。它必须序列化等待已存在的最新读取或执行独立的当前会话GET，不能把普通`_load()`的void返回当作新鲜读回成功。
2. 读请求必须携带session guard、peer epoch和当前消息同意/权限；切号、Block、后台、404/403或会话失效均停止重试。
3. GET返回同一`client_message_id`且sender一致：确认原消息、清理草稿，不POST。
4. GET成功且最新消息窗口未发现原消息：仍须按服务端幂等合同和原不可变key显式重试；不得生成新key，不允许编辑原内容/附件。
5. GET失败、超时、429/5xx、网络断开或权限未知：保持`UNKNOWN`，发送按钮/重试控件不得盲目发起POST；提供“重新核对服务器”操作。
6. 对轮询/历史读取在途、多个快速点击、commit后响应丢失、切号竞争、Block竞争、应用前后台切换和服务端已经提交等情况增加Widget及API测试。
7. 保留原始失败和测试基线，不删断言，不将UNKNOWN改为PASS。

## 2. P0.4｜端上Block与媒体失权完成Android候选闭环

- 当前代码增加会话页Block入口与UNKNOWN读回，但当前新APK尚未生成/实机。
- 补正反链：A Block B、B Block A、重复Block、Block请求UNKNOWN先查服务器、Block成功后消息/草稿/头像/媒体/发送/通话/通知控件及旧深链均失权；新登录/冷启动/切号不能恢复旧敏感内容。
- 现有API若拒绝或返回404，UI显示最小不可用状态，不能继续展示可写控件。
- 社区图片、头像/封面用专门合成PNG/JPEG实测Photo Picker、上传、原始字节读回、SELF/FRIENDS原受众、新好友、Block后旧链接和缓存清除。不要读取Owner私人照片。
- 外部URI深链识别与当前App routes/intents一致，测试伪造peerId、跨账号、过期和Block后URI。写入中断/UNKNOWN至少覆盖消息、Block和Buddy幂等请求。
- A10媒体截图、A12深链、W01–W04后台截图按新同版APK和固定源码采集；更正A05文件映射索引时不改原图字节。
- 正式关系状态文案应区分ACTIVE/PENDING_MUTUAL/SUSPENDED_REVERIFY/ENDED与TEST_ONLY身份，不得把合成关系表述为真实身份认证。

## 3. 旧管理员工具｜真实数据门前加固

### 3.1 数据库目标身份

在`LegacyAdminTarget`补充并具名测试：
- 预期DB username、port和host必须由私有target config提供；
- 实际`CURRENT_USER()`/数据库连接身份、`DATABASE()`、`@@server_id`、MariaDB完整版本与Laravel实际connection config全部精确匹配；
- DB_URL/unix socket/连接别名或运行时重绑定必须拒绝；
- session driver/table/connection、HTTPS origin、APP_URL、debug关闭和私有target identity全部核对；
- 任何不匹配都在CLI dry-run前拒绝，错误不打印凭据或绑定值；
- 已知旧生产MariaDB、R0和function实例绝不允许成为真实恢复target。Beta target必须是明确独立V2数据库/schema和服务身份。

### 3.2 Owner批准与候选持有人证明

当前Manifest的`approval`是短引用并匹配私有配置值，不能单独作为真实Owner授权的独立证据。真实数据门之前：
- 定义可审计的Owner授权包/签名回执，至少绑定source snapshot、target identity、字段白名单、候选代号、批准角色、operator、有效期和一次性批次；CLI在apply前验证签名/回执有效性和不可重复使用。
- 每个真实候选需有私有证明引用：旧主体ID、原登录手机号当前持有人确认、旧admin私有名单命中、旧账号active/disabled状态、必要的管理员职责范围、确认人和核验时间。公开报告只写不可逆候选代号。
- Manifest只允许当前批准的最小字段。禁止生日/城市/位置/三盘/认证材料/关系/消息/媒体/旧password hash/token/session/MFA/API key。
- 原手机号保持V2唯一登录标识；V2生成新user ID、新密码激活，不复用旧ID/旧密码。
- 旧账号若disabled、旧allowlist未命中、持有人不再控制号码、source snapshot不一致或已有V2手机号冲突，停止该候选，不能自动跳过后仍宣称所有指定管理员已恢复。
- 合成测试继续覆盖dry-run/apply/issue/activate/rollback/幂等/allowlist/禁用/权限撤销和审计。增加DB username/port错配、错误CURRENT_USER、伪造审批、签名篡改、候选持有人证明缺失/过期、批次重放测试。

### 3.3 回滚与运行手册

- 回滚需确认撤销V2 DeviceSessions/Sanctum、数据库Web sessions、platform_admin_sessions、激活码、role、disabled和私有ADMIN_PHONES配置；保留审计与旧→新映射，不删历史证据。
- 私有ADMIN_PHONES逐个设置、变更和回滚必须留运维审计，严禁写入GitHub或客户端。
- 管理员实际权限需按同事职责最小化；若V2当前admin角色过宽，提出细粒度RBAC建议，不因恢复账号而自动授予全部运营权限。
- 任何真实候选数据读写之前必须形成单次Owner数据授权包并停下等Owner批准。

## 4. 共享远程HTTPS｜只做方案和只读准备

- 本机`127.0.0.1:18444 + ADB reverse`仅供本机单手机测试，外地同事无法直接访问。
- 现有上海旧机历史资源：2vCPU/2GiB、约627–628MiB可用内存、swap0，旧Laravel/MariaDB/Redis/LiveKit共驻。不要假定可安全同驻V2。
- 可以准备一次只读容量采样计划和明确阈值，覆盖旧站峰值、CPU/RAM/OOM、磁盘I/O、LiveKit并发、备份峰值和端口占用；当前不新SSH、不重启旧服务、不改防火墙。
- 输出两种受限方案：A) 现有实例满足独立隔离容量时的专用V2容器/DB/schema/volume/worker/TLS方案；B) 独立2vCPU/4GiB/40–60GiB候选的资源和报价。价格必须按当前供应商实际报价，不编造；标出公网IP/带宽/流量/快照/续费。
- 不采购、不创建实例、不修改DNS/防火墙/443、不开放公网、不访问真实旧库。Owner云写/费用授权另行审批。
- 共享服务要能从每位同事外地设备HTTPS访问；DB/Redis/FPM不得公网开放，Web管理和激活入口另加来源限制或VPN，TLS和APK原生/Dart endpoint必须固定。

## 5. Owner真实数据授权包模板（只准备，不填真实PII）

一次性提交给Owner的授权包应包括：
1. 来源A现时旧MariaDB或来源B具体五月manifest；证据与时间点、快照一致性和回滚。
2. Owner指定候选数量及私有代号；每位持有人控制原手机号/管理员职责确认。
3. 只读字段和目标写入字段；明确排除旧密码/token/session/MFA和其他用户资料。
4. V2目标实例/schema/server_id/username/host/port/域名/TLS与独立备份恢复证据。
5. 数据保管人、提取执行人、迁移操作者、独立复核人和回滚负责人。
6. 费用上限、访问来源、时间窗、数据留存/销毁计划和失败停止条件。
7. 迁移成功标准：每位指定管理员本人用原手机号+新V2密码从异地APP登录；获准人员本人完成Web登录；旧token/session拒绝；缺role/allowlist/disabled反例拒绝。

未取得此批准前只用合成账号，禁止读取真实旧管理员行或解密备份。

## 6. 交付要求

一次中文综合报告，固定非main源码提交和报告：
- P0.4消息UNKNOWN并发读回修复及测试；
- 端上Block/媒体/受众/深链/断网UNKNOWN结果；
- 新APK身份固定但不安装，等待Owner对新包具名授权；
- LegacyAdminTarget DB身份完整校验、Owner签名审批和持有人证明合同；
- 两名虚构管理员完整回归、旧10项PHP和新增测试结果；
- 真实数据授权包（脱敏）和候选状态，清楚标NOT_RUN；
- 共享HTTPS两方案、容量和当前价格证据/成本上限待决；
- Beta准入硬门和未通过项。

禁止：真实旧行读取/备份解密/真实V2库写入、阿里云SSH/部署/公网变更、采购、真实管理员激活、同事异地登录、安装覆盖新APK、main合并、软著正式申报、封闭内测招募或发布。
