# EliteSync V2｜P0.4.1 Android 1011806 实机集中顾问限定验收

日期：2026-11-21。结论：**`1011806_INSTALL_PASS_ON_AUTHORIZED_RETRY / DEVICE_E2E_PARTIAL_WITH_P0_HISTORY_PRIVACY_FAIL / OWNER_D03_HISTORY_DEFAULT_FAIL_CLOSED / REAL_WIRELESS_OUTAGE_NOT_RUN / PHOTO_PICKER_UPLOAD_NOT_RUN / SHARED_HTTPS_NOT_DEPLOYED / CLOSED_BETA_NO_GO`**。

## 1. 固定提交与证据核对

- Codex报告：[P0.4.1 Android 1011806 实机与共享HTTPS回执](https://github.com/zcx369658780/EliteSync-v10/blob/e4d1588acee62d8f8f166042c328e26cc951c14a/docs/versions/v2/cloud-r0-20261121/V2_P0_4_1_ANDROID_1011806_DEVICE_AND_SHARED_HTTPS_REPORT_20261121.md)，固定提交`e4d1588acee62d8f8f166042c328e26cc951c14a`，报告blob `14a1c2bddf64ae0f764019517eb29dd5ead17718`。
- 开发分支`codex/v2-function-completion-20261121`远端HEAD与报告提交一致。相对固定P0.4源码`00ca46f6b020afa25ce472509c2fd3227f74c461`ahead3/behind0；提交差异包括此前P0.4报告、P0.4.1实机报告和操作手册。**P0.4.1交付提交本身只修改操作手册、增加实机报告，没有修改产品源码。** 本轮实机所运行的产品源码仍为`00ca46f6b020afa25ce472509c2fd3227f74c461`。
- 操作手册：[1011805底稿+1011806独立附页](https://github.com/zcx369658780/EliteSync-v10/blob/e4d1588acee62d8f8f166042c328e26cc951c14a/docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)。主文仍标1011805，附页单独绑定1011806；作为登记准备稿可接受，不是已定版软著材料。
- 顾问逐段读取完整报告、操作手册、145项SHA-256表，并抽查固定源码`SocialPolicy::revokePair`、`ConversationCapabilityService::evaluate`、`LiveConsentService`、`ConversationDomainService`、`MessageController::listAuthorized`及Owner已接受的Conversation数据权利决定。145项SHA-256记录已按报告表格行计数；顾问没有取得本机145个原件重新计算hash，也没有重新连接手机重演测试。设备运行事实和APK实际hash仍标`CODEX_REPORTED_DEVICE_EVIDENCE`；代码路径和既定产品合同的比对属于`ADVISOR_SOURCE_SPOTCHECK`。

## 2. 1011806安装与设备身份

**限定接受安装成功。**
- 设备：此前1011805实测的同一实体手机，型号25060RK16C，Android16/API36。完整serial只留本机。
- 首次安装退出码1，`INSTALL_FAILED_USER_RESTRICTED`，系统拒绝原因UNKNOWN；Owner在场重试后退出码0/Success。首试失败保留。
- PackageManager同时回读1011805和1011806；旧包和原有数据未卸载、覆盖或清除。
- 手机拉回的`base.apk`与Codex报告的固定候选一致：`com.elitesync.v2functionp04`、versionCode1011806、209,094,076 bytes、SHA256 `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`、v2证书SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。
- Native和Dart均指向`https://127.0.0.1:18444/`；本机TLS证书SHA256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。MariaDB10.11.19、schema`elitesync_v2_function`、server_id2621121；专用容器、数据库和媒体卷保持。
- USB reverse已撤销，WLAN已恢复。1011806是本机回环测试包，不是共享远程Beta包。

## 3. 实机旅程限定验收矩阵

| 功能 | 顾问结论 | 报告所载结果与边界 |
|---|---|---|
| 安装/冷启动/登录会话 | `PASS_REPORTED` | 重试安装成功；强停冷启动后session verify 200。首试失败保留。 |
| 登录/退出/切号/前后台 | `PASS_REPORTED` | A/B/A切换，服务端主体对应；前后台恢复展示当前授权内容。 |
| 昵称资料 | `PASS_REPORTED` | 手机保存后服务端读回，A/B资料隔离。 |
| 三盘持久读回 | `PASS_WITH_OBS_REPORTED` | 未知时刻输入、POST/GET 200、MariaDB版本读回；结果保持`COMPUTED_UNVERIFIED`，不是算法独立正确性PASS。 |
| 慢约候选/报名 | `PARTIAL` | 当前手机无候选且资格不足，报名禁用；主机报名403。1011806正向候选发布/双方接受未跑。 |
| Connection/双方消息同意 | `PARTIAL` | 手机读到置备的CN_ACTIVE/MC_ACTIVE；双方在手机端实际申请/接受未跑。 |
| 正式关系 | `PARTIAL` | 手机显示未核验/供应商未配置、无正式关系；1011806正向双确认未跑，既有TEST_ONLY结果不扩展。 |
| 消息UNKNOWN | `PASS_REPORTED` | 独立fresh GET失败保持UNKNOWN；提交前失败读回后用相同client_message_id重试；提交后丢响应读回原消息且仅一条DB记录。 |
| 双向Block生效期间 | `PASS_REPORTED` | 手机端A/B分别Block；控件禁用、正文清除、旧读取404，响应丢失后GET blocks核对；Block生效期间未观察到旧正文恢复。 |
| **解除Block后旧消息** | **`FAIL`** | 新Connection第2代及双方消息同意建立后，手机仍看到第1代4条旧消息和第2代新消息。见第4节。 |
| Photo Picker/图片上传 | `PARTIAL` | 能打开系统选择器，但未取得选图返回；手机发起上传、JPEG、失败重试均NOT_RUN。 |
| SELF/FRIENDS/历史媒体 | `PARTIAL` | 主机合成PNG验证SELF拒绝、FRIENDS允许、Block后旧URL撤权；手机可显示主机置备封面，但新好友、退出好友、缩略图缓存及完整设备旧URL复验未完成。不能称手机图片上传PASS。 |
| Buddy | `PARTIAL` | 仅本人在线草稿POST201及读回；双方申请/确认/退出未实测。 |
| URI/通知 | `PARTIAL` | 未注册私信/通知路由拒绝；map_pick可解析且peerId=0不打开私信；通知经服务端读回，Block后历史通知显示不可用。真实过期和独立跨账号对象仍待。 |
| 真实无线断网 | `NOT_RUN`（报告总体PARTIAL） | WLAN关闭时USB reverse仍连接本机后端，手机仍GET messages 200。因此这次不是实际手机到后端的无线断链。请求前/提交前/提交后响应丢失/读取中四个无线故障窗口均NOT_RUN。 |
| W01–W04 Web截图 | `NOT_RUN` | 没有新Web后台截图。 |
| 同版软著材料 | `DRAFT_ONLY` | 手册主文1011805，1011806另附页；未完成同一登记版本定版、许可逐项复核和权属确认。 |

## 4. P0隐私失败：重新授权的新会话恢复旧消息

### 4.1 观察事实

报告记录：
1. 第1代Connection及消息同意期间产生4条私信；
2. 双方Block后，旧消息读请求404、手机正文清空；
3. 解除Block后，系统建立第2代Connection及双方消息同意；
4. 新会话进入后，手机同时显示第1代4条旧消息和第2代新消息；
5. MariaDB中两代Connection分开，但消息行持续留在同一个历史数据范围。

### 4.2 与Owner已接受产品合同的冲突

Owner已接受的[Conversation Data-Rights D-01–D-04](https://github.com/zcx369658780/EliteSync-v10/blob/main/docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md)明确：
- D-01：Block、Close Conversation、revoke等是不同动作和权限，不可互相借用。
- D-03：**Connection关闭/消息同意撤销后的只读历史默认不开放**，除非针对主体、受众、用途、保留状态和适用法域建立独立、明确的历史访问权限。这是fail-closed默认，不代表历史数据已删除。
- [APP-T07接受合同](https://github.com/zcx369658780/EliteSync-v10/blob/main/docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md)要求历史消息、既有Conversation行、路由或peer ID本身不能创建读取/发送授权。
- 本轮源码抽查确认Block调用`SocialPolicy::revokePair()`，该方法将相关Product Connection置为`CN_CLOSED`并把其`MC_ACTIVE/MC_PENDING`置为`MC_REVOKED`。所以第1代live上下文确实关闭。
- 解除Block后的第2代Connection/MC是新live上下文，但当前`ConversationDomainService::roomKey()`只用两名用户ID生成稳定pair room key；`ensureDirectConversation()`继续复用同一Conversation。当前`MessageController::listAuthorized()`只验证当前pair`canRead`，随后按pair room_id读取全部消息，没有按Connection generation/context或独立历史权限过滤。新MC授权了当前live read，却意外打开了旧代消息。

### 4.3 顾问结论

**这是P0隐私/授权边界FAIL，不是可以按“用户重新同意了”直接接受的正常行为。**

第2代新Connection和新MC只证明新的live上下文已建立，不能自动授予第1代已关闭会话的历史读取权。当前Owner已接受的默认历史策略没有为该旧历史建立单独authority。

要求修复：
- 保留旧消息记录，不做物理删除，不宣称已删除/擦除；
- 默认普通会话、消息列表、搜索、通知、回复引用、媒体附件、last-message预览、未读计数和旧深链均不得在第2代live上下文中泄露第1代正文；
- 第2代只读取第2代产生的消息；
- 旧历史如未来要开放，必须由单独、明确的历史访问authority决定其主体、受众、用途、保留状态、时效和地区规则；不能借用新的MC_ACTIVE；
- 对外显示中性状态，例如“上一段会话已结束，历史内容当前不可用”，不得暗示内容不存在或已被删除。

这项问题应阻止P0.4.1整体接受及封闭内测准入，直到修复和回归通过。

## 5. 共享HTTPS与阿里云

- 1011806 endpoint仍是本机`127.0.0.1:18444`+USB reverse，不是阿里云。
- 现有上海旧机2vCPU/2GiB、约627–628MiB历史可用内存、swap0、旧Laravel/MariaDB/Redis/LiveKit共驻，容量未批准。
- 独立2vCPU/4GiB/50–60GiB报价仍是公开参考；Owner账号上海实际结算、活动资格、续费、税费、带宽、流量、快照等UNKNOWN。
- 本轮无SSH、云写、采购、DNS/防火墙/公网修改，新增云支出0。
- 真实旧管理员身份恢复仍未执行；候选清单、数据授权、V2写入、同事本人异地登录均未完成。共享HTTPS及全部指定管理员本人异地登录仍是封闭内测硬门。

## 6. 最终判定

接受：
- 1011806在原设备安装成功及报告所载包身份核验；
- 已完成的冷启动、登录切号、昵称、三盘、消息UNKNOWN、Block生效期间撤权等具名实机范围；
- 145项哈希清单已进入报告并完成条目计数；顾问未重算本机原件。

不接受：
- P0.4.1整体PASS；
- 解除Block后旧历史自动随第2代连接恢复；
- Photo Picker/手机图片上传/完整历史受众；
- 真实无线断网测试；
- 共享HTTPS或阿里云已打通。

状态：
- `DEVICE_INSTALL_PASS_ON_AUTHORIZED_RETRY`
- `DEVICE_E2E_PARTIAL_WITH_P0_HISTORY_PRIVACY_FAIL`
- `OWNER_D03_HISTORY_DEFAULT_FAIL_CLOSED`
- `PHOTO_PICKER_UPLOAD_NOT_RUN`
- `REAL_WIRELESS_OUTAGE_NOT_RUN`
- `SHARED_HTTPS_NOT_DEPLOYED`
- `REAL_LEGACY_ADMIN_NOT_RESTORED`
- `CLOSED_BETA_NO_GO`
- `PRODUCTION_NO_GO`
