# EliteSync V2｜P0.3 Android 1011805实体机实测顾问独立限定验收

日期：2026-11-21。结论：**`P0_3_DEVICE_E2E_PARTIAL_ADVISOR_SCOPED_ACCEPTED / LOCAL_LOOPBACK_BACKEND_ONLY / ALIYUN_V2_BACKEND_NOT_CONNECTED / REAL_LEGACY_ADMIN_ACCOUNTS_NOT_RESTORED / CORE_FUNCTIONS_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**。

## 1. 固定证据与Git身份

- 固定报告：[P0.3实机报告`651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`](https://github.com/zcx369658780/EliteSync-v10/blob/651f3dea30cb6744d6a3863e5d9f7a921ca7ae43/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_3_ANDROID_1011805_SINGLE_DEVICE_REPORT_20261121.md)，blob `942ea5506ee9d930041165ea35b3970b3b79859a`。
- 同版手册修订：[操作手册P0.3稿](https://github.com/zcx369658780/EliteSync-v10/blob/651f3dea30cb6744d6a3863e5d9f7a921ca7ae43/docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)，blob `57a54361c8b4004a50ccef13f89c9fdc2ad3e8aa`。
- 截图/证据索引：[P0.3 SHA-256索引](https://github.com/zcx369658780/EliteSync-v10/blob/651f3dea30cb6744d6a3863e5d9f7a921ca7ae43/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_3_EVIDENCE_SHA256_20261121.md)。
- 开发分支`codex/v2-function-completion-20261121`远端HEAD核对为报告SHA；相对P0.2交付`daa96756f96fb6fd62845323ebd3c53d2b2438d2`ahead1/behind0，提交仅改手册、增加P0.3报告与哈希索引，无产品源码、Compose或云端部署代码变化。
- 顾问直接读取报告、手册、哈希索引、P0.2报告和CLOUD-R0报告。未下载本机PNG/APK/日志逐字节重算、未连接设备、未操作服务器；运行事实为`CODEX_REPORTED_DEVICE_EVIDENCE`。本地证据索引提供截图、APK、日志和HTTP记录SHA，支持可追溯复核，但不等同顾问本机重演。

## 2. 实机工件与环境

- 唯一实体设备（本机私有标识，不在治理公开正文重复序列号）：Android 16 / API 36。
- 安装包：`com.elitesync.v2functionp0`，`10.1.18-v2-function-p0 / 1011805`，arm64-v8a，209,094,024 bytes；安装后从设备拉回`base.apk`，Codex报告SHA-256 `d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`，v2签名证书SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。
- 原生和Dart均使用`https://127.0.0.1:18444/`，固定TLS证书SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。ADB USB reverse将手机loopback映射到**本机**专用服务。
- 后端为专用WSL Docker项目`elitesync-v2-function`，本地MariaDB10.11.19、schema`elitesync_v2_function`、server_id2621121、116表；FPM镜像源码`2a528919702289b4e0c39d86a5bb52d6067fc745`，镜像ID`sha256:4e55a606161eca08bacf568462395470a71bf60e551bfd01b64922885d26377e`。三个容器仍运行、两个专属卷保留。ADB reverse本轮已撤销。
- **本次真实设备链路完全是本机回环USB反向转发，不是阿里云连接。** 127.0.0.1:18444没有对外可达含义；其他手机或同事电脑不能仅凭该APK直接访问本机后端。

## 3. 设备具名结果与边界

| 功能 | 顾问结论 | 实际证据与限制 |
|---|---|---|
| 登录/切号/资料 | `DEVICE_SCOPED_PASS` | A/B多次切换、退出/登录HTTP200，昵称写入并重读；冷启动恢复会话。直接回放旧访问/刷新令牌、账号停用、注册NOT_RUN。 |
| 三盘 | `DEVICE_SCOPED_PASS_WITH_OBS` | 未知时刻和精确到分输入、POST/GET 200、输入/结果版本v1/v2读回；A私有记录与B隔离。历史详情、版本冲突和失败恢复实机NOT_RUN，算法仍`COMPUTED_UNVERIFIED`。 |
| 慢约候选 | `DEVICE_SCOPED_PASS_WITH_OBS` | 已公布的TEST_ONLY轮次，双方接受及历史回读；正式报名、运营发布和无资格拒绝实机NOT_RUN。 |
| Connection/消息许可 | `DEVICE_SCOPED_PASS` | 双方Connection和独立消息同意均200；仅Connection时进入消息404；Block后状态撤销。 |
| 文本私信 | `DEVICE_SCOPED_PASS` | 同一合成消息发送、接收、ack/已读读回；Block后正文消失、旧读取404、冷启动列表为空。服务端仍保留历史行。 |
| 正式关系 | `TEST_ONLY_DEVICE_SCOPED_PASS` | 双方分别确认，MariaDB PENDING_MUTUAL→ACTIVE→Block ENDED；界面始终标TEST_ONLY。凭据撤销后的实机二次确认NOT_RUN。UI终态文案“已参与”不够清楚，需修订。 |
| Buddy | `DEVICE_SCOPED_PASS` | 草稿/开放/发布/发现/申请/确认/退出，MariaDB状态和版本相符。 |
| 社区 | `TEXT_ONLY_PARTIAL` | 双向好友文字作品发布；A10为文字截图。图库入口可打开，但图片选择/上传、SELF与历史好友受众、新好友及Block后媒体字节均NOT_RUN。 |
| 通知 | `PARTIAL` | 应用内当前通知状态读取/已读，Block后转为不可用历史；外部URI深链NOT_RUN。 |
| Block | `PARTIAL` | 主机API施加Block后，前台旧对话约8秒后隐藏正文、列表及冷启动无会话，MariaDB记录及主机HTTP旧连接/消息/资料404。**APP对话页没有可用Block写入口**，不是端上用户主动操作通过。撤权后发送/媒体控件仍显示，相关写操作未触发，UI未完全失权。 |
| 断网恢复 | `TRANSPORT_SCOPED_PASS` | 关闭本轮USB reverse约38秒，冷启动显示登录页无私有内容；恢复同一映射后session verify 200、首页恢复。仅验证传输链路中断，不等同飞行模式、写入途中断网、UNKNOWN原结果恢复。 |

## 4. 需要明确保留的失败、UNKNOWN、NOT_RUN

- 首次安装`INSTALL_FAILED_USER_RESTRICTED`已保留；Owner允许重试后成功。不能删除首次失败记录。
- 手机端Block写入缺入口；撤权后对话页面发送/媒体控件未完全隐藏/禁用。
- 社区图片、头像/封面媒体受众、历史链接、新好友与Block后的真实设备字节访问未测。
- 外部URI深链未测；写入途中网络丢失及幂等/UNKNOWN恢复未测；手机飞行模式未测。
- 注册、旧访问/刷新令牌直接回放、停用用户实机、三盘历史/冲突/失败恢复、凭据撤销后关系实机二次确认均NOT_RUN。
- 部分`POST /telemetry/events`返回422，根因UNKNOWN；业务请求状态另行核对，不把遥测422自动视为业务功能失败。
- A10为文字作品，W01–W04未采集。证据索引中A05对应的本机文件名写为`A04-matching.png`，应核对是否命名错误并更正索引/引用，不改原图字节或SHA。
- PHP/Flutter全量、正式A6、真实KYC/Push/RTC、法定删除受理、真实用户数据、真实管理员恢复均NOT_RUN/BLOCKED_EXTERNAL。旧排盘A/B/C与注册可信离线T0仍Owner待决。历史Q PHP46 errors/122 failures、旧盘25、R1 Flutter扩围5 FAIL及1011804历史FAIL/UNKNOWN/NOT_RUN不改写。

## 5. Owner问题：阿里云和旧管理员是否已打通/恢复

### 阿里云V2后端：没有打通

P0.3设备报告明确：
- Android native/Dart endpoint是`https://127.0.0.1:18444/`；
- 通过USB ADB reverse连接本机`elitesync-v2-function`容器；
- 本地MariaDB是`elitesync_v2_function`，不是阿里云旧MariaDB；
- 本轮没有阿里云访问、云端部署、云域名/TLS、云数据库迁移或公网设备联测。

CLOUD-R0固定报告`9baa82aa0cdf947dcc4996d2a584c92e4f4535f1`已明确：G0只读核身/旧DB归属通过；G1云Staging`NOT_RUN`；真实管理员恢复`NOT_RUN`；G3云端Android`NOT_RUN`。P0.3 commit相对P0.2只更改本地实机报告、手册和hash索引，没有云部署源码变化。

### 旧管理员真实账号：没有恢复

- CLOUD-R0只在本地对合成旧主体映射、新ID/新凭据、管理员role+allowlist+启用三条件、撤权进行了演练。
- 报告明确真实账号、旧密码hash、会话、MFA、密钥与业务记录均未进入演练；真实管理员重签/MFA与实际管理页面登录`NOT_RUN`。
- 2026-05-08备份三份本地副本与旧主机声明元数据有关联，但远端原件未重新哈希，解压/恢复资格未证；另一GPG组来源也未证。不得把备份元数据匹配当作管理员账号恢复。
- 因此没有证据表明原管理员用户名/账号已迁入新V2库或能登录V2后台。不得向同事宣称已恢复。

**会议可用性结论：**当前可以在原测试电脑启动本地专用后端，并重新为已授权测试手机建立USB reverse，使用虚构A/B账号演示本轮已通过旅程。当前不是可供同事从其他设备/网络直接登录的共享测试服务器，也不是恢复旧管理员后的真实后台。若要多人/多设备会议测试，需要另行准备受限可达的共享Staging或多台设备各自的安全转发，并先经Owner明确测试范围；当前Owner功能优先原则仍允许把云替换放在内测后，但不能把本地loopback误称为共享云环境。

## 6. 手册与内测判断

- 操作手册P0.3已按实际入口修订，接受为`DEVICE_EVIDENCE_ALIGNED_DRAFT`。A01–A12同版索引已存在，但A10图片版、A12外部URI深链、W01–W04、截图索引A05命名待修。软著权属/依赖许可逐项复核及登记交存版本未定。
- 封闭内测仍`NO_GO`：手机Block写入、撤权UI、社区媒体及受众、外部深链、写入中断恢复等P0缺口未关；真实KYC/Push/RTC与删除受理仍外部阻断；测试范围/告知/Owner正式准入决定未完成。

**最终接受范围：**P0.3实机已实际完成的登录/切号/资料、三盘输入、候选双方接受、Connection/消息许可/文本私信、TEST_ONLY关系双确认、Buddy生命周期、服务端Block后端上失权投影和USB链路中断恢复；其余保持PARTIAL/NOT_RUN。顾问未执行云写入、旧管理员数据恢复、真实供应商或正式内测。
