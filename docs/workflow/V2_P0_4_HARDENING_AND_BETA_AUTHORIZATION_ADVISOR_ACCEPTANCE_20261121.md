# EliteSync V2｜P0.4本地加固与Beta管理员恢复安全合同顾问限定验收

日期：2026-11-21。结论：**`P0_4_LOCAL_SCOPED_ACCEPTED / SYNTHETIC_SIGNED_ADMIN_RESTORE_SCOPED_ACCEPTED / PHP_EXPANSION_60_OF_61_WITH_BASELINE_FAILURE / ANDROID_1011806_NOT_RUN / REAL_ADMIN_DATA_NOT_AUTHORIZED / SHARED_HTTPS_NOT_DEPLOYED / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**。

## 1. 固定工程与提交核验

- Codex综合报告：[P0.4 Hardening与Beta授权报告](https://github.com/zcx369658780/EliteSync-v10/blob/f41f25bb8c237f8479b998e82e843f528397e1fa/docs/versions/v2/cloud-r0-20261121/V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md)，固定报告提交`f41f25bb8c237f8479b998e82e843f528397e1fa`，报告blob`adc6f8f4a95378de96422478062db142cb48bd3a`。
- 开发分支`codex/v2-function-completion-20261121`远端HEAD与报告提交一致。相对上一轮报告`0fd75198db3067782241b6777054050ac2af6918`ahead2/behind0，merge-base正是上一轮报告。源代码提交`00ca46f6b020afa25ce472509c2fd3227f74c461`，随后报告提交`f41f25bb8c237f8479b998e82e843f528397e1fa`。源码差异限Android候选构建配置/宿主、Flutter聊天与测试、管理员恢复安全合同/配置/迁移/测试；报告单独新增。
- 顾问直接读取报告、分支/提交差异、Flutter聊天实现及Widget测试、服务端消息幂等实现/唯一索引、管理员Target/Approval/Manifest/Restore/测试、Android Manifest/MainActivity/Gradle。顾问没有本机执行测试、重算日志SHA、读取D盘APK或安装设备。测试结果和APK hash属于`CODEX_REPORTED`；源码逻辑判断属于`ADVISOR_SOURCE_SPOTCHECK`。

## 2. P0.4本地功能加固：限定接受

### 2.1 消息UNKNOWN重试

- 新`_retryUnconfirmedMessage()`创建独立retry operation token；GET`/api/v1/messages?peer_id=…&latest=1&limit=100`不依赖历史/轮询读者，带`Cache-Control: no-cache, no-store`、当前session guard、peer epoch、foreground和原attempt身份约束。
- GET失败保持UNKNOWN并显示重新核对；没有POST。切号、Block authority epoch变化、后台/取消或请求对象变化后，旧操作不再允许POST。
- GET命中同sender、同`client_message_id`且具备服务端ID时确认原消息并清理草稿，不再POST。未命中最新100条时只允许显式复用原不可变key。
- 顾问另外抽查既有服务端`ConversationAtomicSendService`：以`(sender_id, client_message_id)`唯一索引防重复，重放时核对payload fingerprint和receiver；同键同payload返回原消息，payload冲突返回409，发送授权在事务内重验。故最新窗口未命中后的原key重试有服务端幂等保障，不会创建第二条逻辑消息（仍以实际部署schema包含该唯一迁移为前提）。
- Widget具名覆盖轮询在途、快速重复点击、读取503、已提交后读回、切号、Block authority变化和后台取消。Flutter定向72项通过，改动Dart静态分析无问题（Codex回执）。
- **接受**消息UNKNOWN本地逻辑为`P0_4_LOCAL_SCOPED_PASS`。真实无线网络、分页边界/更旧历史窗口、弱网和实际手机生命周期组合仍需新APK实测。

### 2.2 Block、媒体和关系权限

- Flutter会话页Block确认/取消、请求结果UNKNOWN后只读核对、清理消息/草稿缓存、失权后禁用写操作控件，相关Widget验证通过。
- 本地HTTPS+MariaDB报告证据覆盖双向Block、重复Block、旧消息/通知、SELF/FRIENDS媒体受众、历史封面/头像/作品旧链接撤权、合成PNG源字节读回、损坏文件422及头像revision冲突409。
- 这些是本机服务端和Widget证据，不等于手机系统Photo Picker、图片缩略图缓存、设备旧链接或设备冷/热启动已经通过。A10媒体截图、1011806实机Block/媒体缓存仍NOT_RUN。
- 正式关系ACTIVE文案已改为“正式关系已建立”，TEST_ONLY标识继续显示。接受为当前源码限定成果。

### 2.3 URI和断网故障范围

- Android Gradle为本地function candidate设置`flutterPlatformDeepLinks=false`；Manifest当前对外VIEW intent仅保留`elitesync://map_pick`地图回调。V2 function build的MainActivity初始route为空，不从外部intent/file注入初始业务路由。此为源码配置审阅，不代表设备实际intent分发已测。
- 本轮故障注入是在服务端已返回成功头后丢弃响应体，随后独立GET核对消息、Buddy和Block状态。真实设备无线断网、写入前/提交前切断及弱网窗口仍NOT_RUN。
- 因此不将“提交后响应丢失”扩大为所有断网阶段都已通过。

## 3. PHP结果与历史失败

- PHP扩围61项、777断言：60项通过，1项失败。失败为`V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields`，断言期待409、实得200。报告称同一未修改测试在上批镜像单独执行可复现；顾问未自行重跑，故保留为`BASELINE_REPRODUCED_CODEX_REPORTED`，不能标为PASS。
- Flutter72项与Dart静态分析通过是具名范围；PHP全量、历史Q失败和所有NOT_RUN环境不能因此转绿。

## 4. Android候选1011806：身份记录接受，设备验收未通过

报告记录：
- 包名`com.elitesync.v2functionp04`，versionCode`1011806`，versionName`10.1.18-v2-function-p04`，arm64-v8a。
- APK 209,094,076 bytes，SHA-256`3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`；v2签名证书SHA-256`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。
- Flutter AAR SHA-256`b81774a1730c0835161ee443625493c93c006543192c7b4beffe83afb36466aa`；TLS证书SHA-256`41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。
- API endpoint固定`https://127.0.0.1:18444/`，需本机ADB reverse；该APK不是共享远程HTTPS候选。
- 包名与1011805不同，可并行安装而非覆盖；但顾问未取得D盘APK字节，未重算上述SHA或核实签名。安装、启动、设备截图、Photo Picker、外部intent、设备网络故障全部NOT_RUN。此前1011805安装授权不自动覆盖新包1011806。

**结论：**接受1011806为Codex报告的已构建本机候选身份；不接受为实机PASS或共享Beta包。

## 5. 旧管理员恢复：签名合成演练限定接受

- `LegacyAdminTarget`当前核对staging私有target、HTTPS origin/APP_URL、debug关闭、Secure Cookie、session driver/table/connection、MariaDB driver、默认连接与读写PDO同一、无DB URL/socket/read-write分离/别名/重绑定，并逐项比对Laravel连接配置和实际`DATABASE()`、`@@server_id`、`@@port`、`VERSION()`、`CURRENT_USER()`及`USER()`。目标host、database、username、port、grant account和完整版本必须符合私有target binding；已知旧/R0/function实例排除真实Beta目标。
- `LegacyAdminApproval`要求真实target提供独立Ed25519 Owner签名，签名覆盖规范化完整Manifest、目标binding、来源快照、字段、候选、角色、operator、批准号、时效和holder proof；只接受服务器私有可信Owner公钥及指定operator。逐候选holder proof引用要求原号码控制、旧admin allowlist命中、核验人、核验时间、有效期和获准职责。批准号以唯一claim消费一次，批次重放被拒；激活码期限取Owner授权/持有人证明/30分钟三者最早。
- 软件只核验签名和proof结构/字段/有效期；底层原号码控制和旧名单证据仍须具名人员实际核验，签名不是电话号码运营商证明或旧库真实性自动证明。
- 两名虚构管理员签名恢复、dry-run、apply、issue、activate、APP登录API、Web登录、缺allowlist拒绝、撤权、rollback和审计通过。新增管理员定向12项/123断言通过（Codex报告回执）。
- **接受为`LOCAL_SYNTHETIC_SIGNED_ADMIN_RESTORE_SCOPED_PASS`**。真实候选为0，真实旧数据库行读取/备份解密/真实V2写入/本人激活/异地登录均NOT_RUN。Owner签名公私钥真实配置、持有人证据和实际名单尚未具名核定，故没有真实管理员恢复。

## 6. 共享HTTPS与费用

- 旧上海机仍2vCPU/2GiB、历史空闲约627–628MiB、无swap，旧Laravel/MariaDB/Redis/LiveKit共驻；同驻容量未获证明。
- 报告列出独立上海2vCPU/4GiB/50–60GiB候选，公开参考价70元/月或379元/年活动价；这是公开参考而非Owner账号上海结算价。ECS/轻量带宽、快照、续费、流量、TLS/域名等费用仍待具名报价。
- 本轮没有SSH、云写、采购、DNS/防火墙/公网变更，新增云支出0。V2共享HTTPS仍未部署，异地同事不能使用本机ADB reverse。

## 7. 顾问最终判定

接受：
- `P0_4_LOCAL_SCOPED_PASS`（含消息UNKNOWN fresh GET、服务端同key幂等依赖、Block/媒体服务端合成验证和关系文案）。
- `LOCAL_SYNTHETIC_SIGNED_ADMIN_RESTORE_SCOPED_PASS`（两名虚构账号、12项/123断言Codex回执）。

保留：
- `PHP_EXPANSION_60_OF_61_WITH_BASELINE_FAILURE`。
- `ANDROID_1011806_BUILD_REPORTED_DEVICE_NOT_RUN`。
- `REAL_ADMIN_RESTORE_NOT_AUTHORIZED`。
- `SHARED_HTTPS_NOT_DEPLOYED_OWNER_RESOURCE_GATE`。
- `CLOSED_BETA_NO_GO`、`PRODUCTION_NO_GO`。

下一步先完成1011806实体设备验证和共享环境的Owner选项包；真实数据读取、解密、写入、云部署/采购必须各自经过Owner具名授权。所有指定旧管理员本人异地登录和共享V2 HTTPS仍是封闭内测硬门。
