# EliteSync v10.1.1 实施报告

2026-10-19，Asia/Shanghai。**CANDIDATE_FOR_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**。

本版实现和受控联合验证完成，提交候选供 Astra 独立验收。执行方验证不是 ACCEPTED；没有合产品 main、清理旧资产或启动 v10.1.2。远端交付以最终固定引用及独立回读清单为准。

## 固定身份

| 项目 | 固定值 |
|---|---|
| 冻结计划所在 Commit／开工和发布前 main | `c4a3a524ef47980962dfc965d7bf9865037734ae` |
| plan.md Blob，原字节未改 | `d01cf1c43c242d3a492700d71d32edea4375475b` |
| 候选源码 Commit | `34a0b0ed4209895cebd4ef040519ac13a8054b6c` |
| 源码 Tree | `af6ee10b91d542331f682e8a6e140f12ce96dd7b` |
| apps Tree | `1ddc864a8f7f8f7e024d6102a36057252bc77bab` |
| services Tree | `fe0d8f58575ceb98eca60fd47cdeb3804c7874b2` |
| 候选引用 | `candidate/v10.1.1-relationships-privacy-account` |
| 临时审阅引用 | `review/temporary-evidence-v10.1.1-20261019` |

源码候选以接受的 main 为父提交，产品子树与最终实测开发保存点 `95aef6331bf655ed5bd93337dca20671fd21dbcd` 完全相同；本报告及 manifest 是后继文档，不改产品子树。用独立临时 Git index 制作公开候选，保留本地 checkpoint 历史和开发树原 index，不推送其中的私密路径。

没有整体合并 v10.1.0，也未选择其候选源码 Blob。Workerman 5 URI 修补是当前基线的本版现场修复，不是追认旧适配。v10.1.0 仍 PARTIAL / NOT_ACCEPTED、AC-10.1-08 PARTIAL；已接受算法未修改。源码改动路径由审阅包清单逐项列出。

## 实现和受众合同

- 请求／好友：默认关闭接收；合法上下文或定向邀请；散列保存邀请，绑定用途／申请者，24 小时有效；滚动 24 小时最多 5 个不同接收方，两用途合计；未决 7 天；撤回／到期后同方向至少 24 小时；拒绝后须接收方新邀请。幂等重放不新增，交叉请求不自动接受，无自由文本、用户目录或手机号枚举。
- CN／MC：复用既有服务和能力判定，增加具名 friendship／accepted message request 来源，仍分别双向确认、绑定当前生命周期 ID 和 revision。好友／消息请求不产生普通消息、附件、来电或正式恋爱权；解除好友保留独立授权，block 撤销，解黑不复活。
- 隐私／动态：真实 GET、保存、撤回、本人预览；字段、动态、通知计数、媒体按当前事实投影，APP 晚响应及 RTC 各 await 绑定会话／权限代际。SELF／FRIENDS 覆盖发布、读取、点赞、作者入口、实际封面字节。新分享只用受控私盘；旧 public／OSS 封面不再投影 URL，原文件保留。
- block／隐藏：统一拒绝资料、动态、请求、普通消息、通知、媒体和 WS／RTC；隐藏仅存本人视图及消息序号，不删共享消息、不改授权，只有当前有权且更晚的来信使入口再出现。
- 账号：服务器 UUID 设备家族、access／refresh 旋转和当前／指定／全部撤销；离线退出清本机并明确服务端未确认，恢复后用捕获的旧家族补撤销，不借新账号凭据。
- 注销／Web：普通角色近期密码＋二次确认，持久 DELETION_PENDING、立即停用、全凭据撤销及受限回执；durable pending、处理命令和每分钟 schedule 支持恢复重试，实际以新 worker 进程执行。Web 仅有限账号／请求审计／处理状态，普通角色拒绝，没有管理员代替双方授权的入口。

| 数据 | 本版受众 |
|---|---|
| 有合法入口的陌生 peer | 最小应用公开 ID、头像；block／禁用／注销优先拒绝 |
| 动态和受控封面 | SELF／双向 FRIENDS；旧缺受众迁移为 SELF，不自动公开 |
| 喜好、生日、履历、星座等深资料 | 默认本人；可保存未来意向，无服务端正式恋爱事实时 peer 不可见 |
| 候选 Showcase | 保留原候选用途／本人选择，不转成全局 Profile，不披露原匹配输入 |
| 证件、精确出生时地、星盘原始输入、私聊、安全／举报数据 | 不因好友、付费或客户端关系字段公开；本人正常私有用途保留 |
| 认证 | provider 未配置为 NOT_CONFIGURED／NOT_VERIFIED；运营审核不等于实人认证 |

两份增量迁移：`2026_10_19_200000_social_privacy.php` 新增隐私、邀请、请求、好友、隐藏视图，动态 audience 默认 SELF；product_connections 的 match_id 可空，增加 friendship_id、social_request_id、lifecycle_generation，解除旧 match 唯一限制。`2026_10_19_200001_account_security.php` 新增设备家族、注销请求、演练成员／资产登记及 token 家族关联。事务、有序用户锁、幂等唯一键和状态检查共同处理并发。旧 schema 无法表达非匹配／多生命周期时，rollback 明确拒绝并要求验证备份恢复，不静默丢行。

有意调整：旧公开动态缺省收窄 SELF；旧自报核验不赋真；旧前缀直接删除改为普通角色 pending＋受控处理；旧任意 `/relationships` 客户端写旁路关闭，历史行保留但不作可信事实。没有删有效测试掩盖非预期回归。

## AC 逐项执行结果

以下为 **CODEX_REPORTED / LOCAL_ONLY 原证支持的执行方验证通过**，不等同 Astra 接受。真实链为独立 APP→Laravel→持久 MariaDB，另有真实 Web 浏览器和受控 SFU；API、单元／Widget、实际 APP 证据分别列示，不相加冒称去重总数。

| AC | 实际结果 |
|---|---|
| 01 | main／冻结 Blob、独立树／库／卷／包名明确；三处保护根 HEAD、index、普通 porcelain 字节终检一致，状态数 252／68／2；旧试点和算法未操作。 |
| 02 | 手机实际发起、撤回、拒绝、接受、解除好友，独立 API 持久读回；先前 APP 接受并发剩余请求亦读回 active。配额、上下文、幂等、重放、到期、防绕过有定点测试。到期和冷却完成使用精确登记的虚构请求时间戳夹具，未改系统时间／配置；到期后立刻重试 409，完成隔离时间夹具后才允许新生命周期。 |
| 03 | 好友接受后普通消息／附件／来电拒绝；双方另行 CN＋MC 后真实聊天和 APP 呼叫成立。actor、生命周期、关系、认证、管理员及处罚否定例；解除好友保留独立授权，解黑不复活。 |
| 04 | A／B／C 三账号、本人保存／预览、好友动态、深资料否定、实际图片字节及 SELF／解除好友旧 URL 拒绝。APP 保存 revision=1，重启读回；切号／晚响应定点测试。无正式恋爱／provider 假成功。 |
| 05 | 资料／请求／动态／通知／媒体／消息／WS／RTC 拒绝。合成 call7 两 AVD 音视频字节和解码帧增长，block 后约 1.531／1.312 秒停止。最终双架构同包真机＋AVD call14 双向音频增长，block 后 0.719／0.704 秒停止，5 秒后无该 call RTP。旧 URL／JWT 重入失败，解黑不恢复。 |
| 06 | 隐藏只影响本人，重登及 DB／API／WS 重启保持；对方列表不变，当前有权的新来信按序再出现，旧事件／无权来信否定；共享消息保留。 |
| 07 | 当前／指定／全部设备撤销、跨号拒绝、旧 access／refresh 失败。真实双进程刷新 [200,401]，winner 可用；WS 登出约 0.516 秒关闭。APP 离线如实提示，恢复网络切另一账号后补撤销使旧家族 tokens=0，新家族 active 且 tokens=2。 |
| 08 | 非特殊前缀普通登记角色实际 APP 注销、即时停用、受限回执、独占物删、失败重试。第1次 FAILED_RETRYABLE，第2次准确完成；注销后 peer 资料／动态／旧媒体 404。未登记／错误环境物删拒绝，共享／审计／备份保留。 |
| 09 | 最终同一双架构包实装手机和 AVD，逐端拉回一致；APP／Laravel／MariaDB／Web 实链。持久链经 DB／API／WS 重启核隐私、隐藏、回执及新消息；手机补测前从保留卷再次恢复。Web 管理员正例、普通角色否定。 |
| 10 | 固定源码／产品子树、包／签名／安装回读、迁移受众、真实退出、原失败、非作者复核及资源终态登记；公开副本脱敏，候选与审阅引用普通发布并独立回读后才成立交付，不自行 ACCEPTED。 |

### 并发和注销证据

MariaDB RR 交叉请求原始结果 [201,201] 保留。修复 store 的事务前候选定位、先有序锁用户再首次一致性读及锁邀请重读后，[201,409]；transition 亦在用户锁后锁定重读请求和接收开关。另一进程关闭接收开关先提交，accept 等待后 404、PENDING 保留。最后修补经非作者复核和 10 项／143 assertions 检查。

本人私有写的 fresh 用户锁覆盖 next，不破坏双人锁序。真实 writer 先持锁时注销等待；随后擦除其刚写入的独占文件及私密资料，晚写 403。物删仅限本版服务端登记普通虚构成员／资产、私盘、归属、散列、引用和保留门，不靠 90／Smoke 前缀。

Alice 的 standalone-retry、self-post-only 最终 deleted 且文件不存在；evidence-hold、reported-post 原文件、正文、关联及举报原行保留。Alice／Bob 共享消息 2 条及原备份保留。Diana 的竞态注销、重启后回执亦完成。回执区分 ACCOUNT_CLOSED、PRIVATE_DATA_ERASURE_COMPLETE、RETAINED_SHARED_OR_AUDIT_RECORDS、FAILED_RETRYABLE，不声称所有数据彻底删除。生产物删适配默认关闭，真实保留政策仍待确定。

### 真机补授权与媒体边界

原计划只允许 AVD。Owner 后续明确授权手机双端测试、USB 安装和麦克风，再当场批准一次 20 分钟的精确手机私网 UDP7882 窗口、同窗口宿主自身来源及模拟器内定向映射／合成音调。窗口 21:32:38 开始，21:50:38 提前关闭，未续窗；没有复用 Docker 修复的旧 UAC。

USB TCP 原始 MediaConnectException 保留；回显验证宿主私网 UDP hairpin 不通、loopback 可达。精确私网＋loopback 发布和本版 AVD 定向映射后，同 call14 两 APP 连通；未开电脑麦克风。模拟器注入 40 秒间歇 880Hz 合成音，Owner 同 call 回答“能听见”，只证明模拟器→手机方向实际可听；反向人工听辨、音质、AEC 不作通过结论，没有录制真人声音。

保存 JWT 是撤权前受控脚本调用产品官方 LiveKitTokenService 签发、先 validate=200；不是从 APP 提取原 token。block 后 validate／真实 WS 重连403、官方 issuer 新 join404。实际媒体由两 APP 正常 API 授权入房，未以签发夹具代替联合链。另一 device family 试图取既有 call token 被403正确拒绝，原记录保留。

## 最终制品与检查

最终制品见 [artifact_manifest.json](artifact_manifest.json)：包名 `com.elitesync.v10x.relationshipdev`，versionName `10.1.1-dev`，versionCode `1010101`；ARM64＋x86_64，同包 `403852021` bytes，SHA256 `5ed82741074904b8f3d91817d1d2aab5117579bf918c12036f3e79f049e6ebd9`；Android Debug 证书 SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。手机／AVD 各 pm path→pull→SHA256 一致。较早 x86 包 `c2df93bd...` 仅支持 AVD，不冒充最终手机包。

构建 `assembleDebug -PflutterDartDefines=ELITESYNC_RELATIONSHIP_DEV_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain` exit0；原锁定 JDK17／Flutter／SDK 未升级。双架构门有本版 dev define 校验，AAR／APK 同步且登记 Gradle 输入；非作者静态复核无可操作发现，实际包 ABI／包名读回通过。产品子树与构建实测点相同，没有后继业务源码差异。

| 检查 | 结果（套件重叠，不合计） |
|---|---|
| 较早 PHP 相关 | 75 tests／739 assertions，exit0 |
| 后续隐私／注销／通知相关 | 41 tests/deprecated／406 assertions，exit0 |
| 最后 social transition | 10 deprecated／143 assertions，exit0 |
| Flutter 本版相关合跑 | 63 项，exit0 |
| 最后完整 RTC 范围 | 67 项，exit0；范围 analyze 0 issues，exit0 |
| Pint／whitespace | 通过；Git 按原有 CRLF 行尾检查，详见下文 |
| 真实 API | 分批34／22／17／9项，后续并发、注销、手机补证另列 |

非作者复核驱动修复：消息请求后续入口、CN／MC 生命周期、通知撤回／跨号、封面授权、旧关系写旁路、私有写与注销锁、晚到媒体复活、RTC 切号／await 竞态、保留证据、RR 锁后重读。最后相关源码无剩余可操作发现；构建小增量另经非作者复核。不是 Astra 接受，原现场对话／材料 LOCAL_ONLY。

Git 默认范围检查曾将两个原本即为 CRLF 的 Dart 文件的 CR 记为 trailing whitespace（exit2）；已逐一比对基线／候选行尾，使用命令局部 cr-at-eol 检查 exit0，不改源码或全局 Git 配置，原失败保留。

原始失败保留：私有写／注销／动态断言修复；Flutter focused02→03；RTC测试失败→66→67，introduced analyze10→2→0；Gradle缺环境／错误cwd；Workerman握手；RR双201；TCP媒体失败；设备未boot／控件未就绪；手机NO_MATCHING_ABIS、USER_RESTRICTED，双架构修复和Owner手机端允许后成功。PHP8.5／旧PHPUnit deprecation、原rtc_invite_coordinator历史info保留。注销业务FAILED_RETRYABLE时worker CLI exit0不代表擦除成功；无监听查询外层exit1不代表停止失败。不冒称全仓绿色，不跑无关全部算法oracle。

## 环境、备份与资源终态

数据库 `elitesync_v10_1_1_dev`，容器／卷 `elitesync-v1011-relationships-db`／`elitesync-v1011-relationships-db-data`，仅loopback43322；MariaDB digest `sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008`。旧近似名v10.0.11库未触及。API loopback8012→8014、WS8013；RTC镜像 `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`，授权代理保留，原生7880未发布。

| SQL恢复点（均LOCAL_ONLY） | bytes／SHA256 |
|---|---|
| 初始 | 102602／`a48f4e98aa1150deaf286be8ad396e2b4fbdd56c8c0f76476c6cfd409bdd657e` |
| 擦除前 | 155499／`d9ec42e2174aba81623abef13d7784d5a9a6b03a680730109264c85642314e01` |
| 终态 | 226473／`74cd48fae53a46c65ae1aad383495be0095bb40d366cddede36879724229c46f` |

Owner自行重启Windows后Docker恢复；未卸载／重装／reset／unregister WSL。旧具体一次UAC修复及VHDX备份保留，第二份虚拟化修复脚本未执行。

终态：本版API／front／WS／bridge、collector、SFU／诊断、DB容器均停止；容器、卷、APK、配置恢复点、失败和备份保留。AVD正常停止，临时DNAT删除、adbd回到非root、host microphone关闭；手机开发APP停止、包保留、本次reverse为空。临时防火墙规则回读不存在。Docker Desktop保持运行，未停未知资源。

三处保护根HEAD／index／普通porcelain字节一致，无reset／stash／clean／force。扩展status采集出现历史长路径warning，不冒称全ignored资产盘点。

## 审阅副本和 NOT_RUN

按[现行协议](../../workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md)，独立临时分支的 `docs/_temporary_review/v10.1.1-20261019/` 只放脱敏统计、必要脚本审阅副本、源码／制品／原证摘要hash和复核摘要。脚本私密根替换为明确占位，原执行脚本和审阅副本SHA分列，不冒称字节相同。临时分支不合产品／main，不自行清理旧分支。

APK、SQL、凭据、JWT、私配、VHDX、真实设备序列／IP、原日志／截图LOCAL_ONLY。Astra不能直接读取本地原证；运行结论统一CODEX_REPORTED，可独立读取的是公开源码／测试／脱敏副本。最终报告后继Commit／Tree／报告Blob、审阅包身份及逐文件回读在交付清单固定。

**NOT_RUN**：阿里云原试点及8服务／数据库／隧道；公网／证书／备案／TURN／费用；真实认证／Push／支付；真实用户物删和生产保留政策；最终双架构APK真机摄像头／视频画面；反向人工听辨／音质／AEC；全部算法oracle；SQL恢复演练／强制旧schema rollback。call7合成音视频和call14最终包真机音频分别列示，未拼接为同包同call真机视频结论。

交付后停止：**AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**。独立接受、main集成、清理和下一版派发各自需要相应权限。


## R1 同版集中返修（2026-10-20）

本节追加于原报告，不改写上文原时点结论。状态：**V10.1.1_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**；成立条件为本节后继候选与审阅引用普通发布并独立回读完成。不是 Astra 接受、产品 main 集成或后继版本授权。

### 固定身份与范围

正式任务为 [Astra R1](https://github.com/zcx369658780/EliteSync-v10/blob/f6531845e05992619123748ca3251b4c7c2f8f73/docs/versions/v10.1.1/ASTRA_REVIEW_AND_R1_TASK_20261019.md)，Blob `9ff9f23304fe47aed7ac7f375ed2b627fa741605`。被审源码 `34a0b0ed4209895cebd4ef040519ac13a8054b6c`、原完整候选 `713e801345c4cb2f996fdf1338eb2d973c810359`、原审阅 `e03b4c44df328ce3ae5656009dcca7a3cba7b262` 均保留。接收时实时 main 为 `8823fc6244efa0ab6007228c6738b58ce571cc1c`；只读核验，没有合入其后继文档或改写冻结计划。

| R1 对象 | 固定身份 |
|---|---|
| 新源码 Commit | `ee2459953146a135ae9b118a1ffe75946efd0183` |
| 新源码 Tree | `a25020ce6f11da173aafc5e699a38f3c9b32fec7` |
| 源码父提交 | `713e801345c4cb2f996fdf1338eb2d973c810359` |
| apps（未改） | `1ddc864a8f7f8f7e024d6102a36057252bc77bab` |
| services | `e4ae92d12d0bbac81a8ed7730a061aaec214da13` |
| 候选引用 | `codex/v10.1.1-r1-candidate` |
| 脱敏审阅 Commit / Tree | `33f64ef9a4adcd04f34d51e946cbea35ea9422cb` / `433f28170d03d26cecc321185c59b9356d62f4ae` |
| 审阅引用 | `review/temporary-evidence-v10.1.1-r1-20261020` |

最终报告提交是上述源码的后继文档提交，完整 Commit/Tree 与逐文件回读登记于集中交付回执；没有把本地私密 checkpoint 历史推到远端。源码只改变下面九条路径：

- `services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php`
- `services/backend-laravel/app/Services/Admin/UserGovernance.php`
- `services/backend-laravel/phpunit.xml`
- `services/backend-laravel/tests/TestCase.php`
- `services/backend-laravel/tests/Feature/V1011R1AuthorizationTest.php`
- `services/backend-laravel/tests/Integration/v1011_r1/worker.php`
- `services/backend-laravel/tests/Integration/v1011_r1/run.py`
- `services/backend-laravel/tests/Integration/v1011_r1/README.md`

### 修补合同与有界类比检查

`privateContent` 的附件参与者发现移至事务外，作为候选。事务内先按 id 递增取得全部候选 User 协调锁，再重读附件关系；新增未锁参与者直接 404，不在锁后乱序追加用户。重新锁定 MediaAsset 并核对 owner 与候选一致，再判断当前受众、好友、block 和独立聊天授权。事务外旧关联不作权限证据。

`toggleLike` 的作者候选定位移至事务外；事务内先有序 User 锁，再锁 Post 重核作者、删除状态及当前用户状态，之后才执行受众查询、like/unlike、event、notice 和正文投影。不是改名 fresh，也不是只锁最终资产。真实路由及 EnsureAccountActive 不在这两个入口外层先开启一致性读事务；SQL 屏障记录最终首次定位的 transaction_level=0，协调锁与授权在 level=1。该结论针对当前 HTTP 调用链，不声称能刷新任意调用者预先建立的外层 RR 快照。

直接相关的作者 `destroy` 原来未参与协调，现为 User→Post 锁后重读再软删除。管理员删除仍限已允许的 public/square 内容及原 revision/reason/confirm 合同，增加按 id 排序的 actor+owner 锁和作者重核。非作者发现它与举报删除经 `UserGovernance::target` 的 actor→owner 顺序可能互等，后者已统一为有序两用户查询；未放宽管理员受众或处理真实私有内容。检查限于两个受影响 Controller、SocialPolicy、LiveConsent gates、现行中间件及直接删除/举报协调，没有扩为全仓审计。

没有新增产品字段、迁移或受众种类；原 SELF/FRIENDS、独立 CN/MC、消息/附件/RTC 许可、拉黑、隐藏、登出和注销区分保持。下面披露的测试事故曾误执行已有迁移流程，不将其写成“数据库迁移从未运行”。

### 真实 MariaDB 前后对照

独立本地 `elitesync_v10_1_1_dev`，loopback 43322，MariaDB **10.11.18**。实际 session/global isolation 均 **REPEATABLE-READ**，autocommit=1，innodb_snapshot_isolation=OFF；未降低隔离或修改全局配置。最终 runner 对每个 reader 的实际 RR 作 PASS 条件。

真实 Laravel HTTP kernel→认证/路由/Controller→持久 MariaDB/私盘响应。每例使用独立虚构 pair/post，无聊天附件独立授权。撤权进程先持有有序用户锁；reader 完成首次读取并尝试用户锁；第三 PDO 观察到精确 reader connection→revoker connection 的 INNODB_LOCK_WAITS 后，才开放撤权屏障。撤权走实际 audience/unfriend/block 产品入口，外层提交后 reader 得锁继续；请求事务结束后再读已提交权限和 like/event/notice。COMMIT 的进程回执可晚于 reader 唤醒，依据是数据库锁交接及持久状态，不拼接 wall-clock 假次序。

| 最终有效 PNG 对照 | 并发 9 项 | 先撤权再请求 9 项 | 合法正例 3 项 | 原始总 exit |
|---|---|---|---|---|
| 原两个 Controller（34a0…固定 Blob，PHP prepend 加载） | 9 项均 200，封面字节/正文泄露；like 增行/event/notice，unlike 删除既有 like 并新增 event | 全部明确 404、无新副作用 | 全部 200，图片字节/正文及预期互动成功 | 1，12/21 符合安全断言 |
| R1 Controller | 全部明确 404；无图片/正文，无 like/event/notice 改变 | 全部明确 404，无副作用 | 全部 200，合法读取/like/unlike 保持 | 0，21/21 |

三类撤权分别为 FRIENDS→SELF、解除好友、拉黑；media/like/unlike 各独立覆盖。两轮各 9 个精确锁等待屏障、各 21 个实际 RR 记录均命中。没有把 500、死锁或进程异常当拒绝。原源码现场失败是 Codex 本地合成执行结果，不冒称 Astra 曾现场复现或有真实用户受害。

最早原源码轮 12/21、首修轮 21/21、恢复后首轮 21/21 原证均保留。其 68-byte PNG 后被发现 IDAT CRC 错误：可证明返回私密字节，不能证明正常图片渲染。最终重新生成 CRC 正确的 32×32 图片，并重做上述原 Controller/R1 对照；没有用旧坏图结果代替最终 APP 渲染。原 Controller 两文件 Blob 与正式审阅一致；baseline prepend 不重写授权算法，固定副本与 loader 原件保持 LOCAL_ONLY。

### 必须披露的开发库事故与恢复

主代理第一次 Feature 启动只设置 DB_CONNECTION=sqlite，没有识别本项目优先的 APP_DB_CONNECTION。它把 PHPUnit RefreshDatabase 连到了本版本地持久库，误清空数据；相关测试出现连接/fixture/授权错误。**这是执行错误，不是产品权限拒绝，也不是获准的清库操作。** 原错误 stdout/stderr/exit、误清空后的 SQL 快照和事前恢复点全部保留。其它数据库、旧试点和保护仓未触及。

停止 API 后用事前 SQL 恢复：restore exit=0；事前 31 个有 INSERT 数据表的规范 VALUES 哈希全部一致，差异表为空。恢复点 SHA256：`e9ab8f176b3049097fcf9469a73ec4f31cfc3d52e6ffb471a5055241a9637c95`。这是主代理实际回读，非作者没有现场核验数据库。最初 baseline/fixed 新增的 R1 夹具行已经丢失，不能宣称这些新行连续保留；其原始请求/屏障/响应证据仍保留。恢复后重新建立独立 final/validpng 夹具，最终库、SQL 备份和所有失败保留，没有再次 seed 或覆盖原历史数据。

修正防护：phpunit.xml 强制 APP_ENV/testing、APP_DB_CONNECTION 和 DB_CONNECTION/sqlite、DB_DATABASE/:memory:、DB_URL 空；Tests\TestCase 在 RefreshDatabase 执行前检查有效配置，包括缓存配置，异常立即阻止迁移。持久 MariaDB harness 不继承该 TestCase、不调用迁移，另核对实际连接 host/port/database/unix_socket。

### Feature、APP、APK 与原失败

- R1 Feature：**10 tests / 117 assertions / exit0**，含合法正例、三类撤权、作者删除、锁后资产 owner/动态 author/附件参与者变化拒绝，以及低 id owner/高 id admin 的统一查询顺序和审计。SQLite 的身份注入/SQL 顺序测试不声称证明真实锁等待。
- 相关原测试：55 tests / 453 assertions / exit1，剩余两项为私媒注销后预期404实际401、旧动态发布预期201实际422；以原两个 Controller 精确加载重跑这两项仍同样失败（2 tests / 12 assertions / exit1），未删断言。其它相关项通过；不把重叠集合加成通过率。管理举报/处罚回归另 12 tests / 270 assertions / exit0。PHP 语法及差异空白检查通过；既有 deprecation 仍记录。
- 初始错误环境：R1 Feature exit1（9项/90断言/3失败），相关集 exit2（55项/275断言/10错误/5失败）；均保留而非擦除。修正环境首个 R1 Feature 为9项/103断言/exit0，随后补管理锁序测试形成最终10项。
- 先启动的既有 AVD 装有较早 x86 APK，225646810 bytes / SHA256 `c2df93bd9030af6677872f3677e3776fe424d012e1b6adad2992bd195e075346`，身份断言 exit1；该轮只是前置观察。停止它后使用另一既有授权 AVD，pm path→pull 确认原最终双 ABI 包：`com.elitesync.v10x.relationshipdev`、10.1.1-dev / 1010101、403852021 bytes、SHA256 `5ed82741074904b8f3d91817d1d2aab5117579bf918c12036f3e79f049e6ebd9`。与原包完全同 hash，签名仍为原 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`；本次未构建或安装。
- 最终 APP 组合为上述原 APK/apps 对象＋本节新 R1 后端。真实登录虚构测试账号、显示经产品上传/创建的有效封面和正文、点击喜欢与取消喜欢；独立后端读回 true/1→false/0。Owner 产品入口撤 SELF 后，图片及正文新请求均404，点击旧卡片未新增互动；显式刷新后标题/正文/卡片消失。原先已交付的像素可留到刷新，不声称能远程擦除旧画面。
- APP 辅助副作用脚本曾错误预期第二轮再新增一条通知；产品有5分钟去重，实际仍为1条。原脚本抛异常但 Laravel 顶层使进程exit0；按 stdout 将该次列为失败，未把exit0算通过。随后过早连接刚启动DB又出现 QueryException/exit0，也未算通过。修正 oracle 后等待 SELECT1就绪，JSON及断言核对最终0 like、4条合法like/unlike事件、1条去重通知、SELF，exit0；拒绝操作没有第五条事件。所有原异常与恢复后只读结果保留。

最终截图、SQL、凭据、token、响应字节、设备日志与 APK 原件均 LOCAL_ONLY。公开运行结论为 CODEX_REPORTED；非作者及 Astra 没有亲自操控这些物理资源。

### 非作者复核、资源终态与 NOT_RUN

独立 GPT-6.1 Sol/high 只读复核（非本次 Controller 作者）集中检查 RR、锁序、候选身份、独立附件授权、正文与 like/event/notice。其发现的 admin/report 锁序冲突已修；复核最终增量后无剩余阻断项。限制保留：封面矩阵不是全部聊天附件或管理删除并发矩阵；旧聊天媒体正例在相关测试中保持，但没有新增全量矩阵。源码复核不是 Astra 独立接受。

本轮专属 API、两既有 AVD、MariaDB 容器均停止；8012/8013/43322/5554/5556 无监听，ADB无设备、临时8012 reverse已精确移除。AVD无音频、未root；没有再开手机、UDP、系统防火墙、DNAT或UAC窗口。为纠正辅助oracle最后只读重启过本版DB，SELECT1就绪后读回并再次停止；未启动其它服务。Docker Desktop保留运行，容器/卷/恢复点/事故及最终SQL/APK/原证全部保留。三保护根 HEAD/index/status 与本轮事前快照相同；长路径枚举警告保留，不把它写成全盘文件内容审计。

复用原 call14 及其听辨/传输/撤权证据，仍按原同call/原时点限制；没有再测人耳、最终手机视频、AEC或新 RTC 窗口。NOT_RUN：手机操作、私网/公网开口、提权、防火墙/DNAT、云端原试点、供应商/费用/真实身份、真实用户删除、算法oracle、整版十AC重跑、客户端构建/安装、main/K08集成、旧资产/分支清理、v10.1.2。

按现行临时审阅协议，新分支只增加 `docs/_temporary_review/v10.1.1-r1-20261020/` 的31份脱敏副本，旧审阅固定点与分支不变。文件清单 SHA 描述公开 LF 字节；脚本执行原件与占位副本 hash 分列。候选最终报告提交及审阅提交须普通 non-force 发布，再用独立全新 bare fetch 核 Commit/Tree，并逐一读取本次变更文件/审阅副本的远端字节核 Blob/SHA；回执固定最终身份。完成后停止，等待 Astra。
