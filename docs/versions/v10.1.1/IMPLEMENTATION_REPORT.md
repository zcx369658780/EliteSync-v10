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
