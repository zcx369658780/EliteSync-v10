# EliteSync V2｜P0.4.2 会话代际历史隔离与1011806实机缺口收口任务

日期：2026-11-21。状态：`P0_4_1_DEVICE_PARTIAL_ACCEPTED_WITH_P0_HISTORY_PRIVACY_FAIL / D03_HISTORY_DEFAULT_FAIL_CLOSED / LOCAL_REMEDIATION_AUTHORIZED / REAL_HISTORY_DELETE_NOT_AUTHORIZED / NEW_APK_INSTALL_REQUIRES_NEW_OWNER_AUTHORIZATION / CLOSED_BETA_NO_GO`。

依据：
- [P0.4.1固定实机报告](https://github.com/zcx369658780/EliteSync-v10/blob/e4d1588acee62d8f8f166042c328e26cc951c14a/docs/versions/v2/cloud-r0-20261121/V2_P0_4_1_ANDROID_1011806_DEVICE_AND_SHARED_HTTPS_REPORT_20261121.md)
- [P0.4.1顾问限定验收](../../workflow/V2_P0_4_1_ANDROID_1011806_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)
- [Owner接受的Conversation数据权利D-01至D-04](https://github.com/zcx369658780/EliteSync-v10/blob/main/docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md)
- [APP-T07 Conversation访问基础接受](https://github.com/zcx369658780/EliteSync-v10/blob/main/docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md)

## 0. 起手和固定事实

- P0.4.1报告提交`e4d1588acee62d8f8f166042c328e26cc951c14a`，实机源码固定`00ca46f6b020afa25ce472509c2fd3227f74c461`；报告提交只增加实机报告和操作手册修订，没有改变产品源码。
- 1011806已在原Android16设备安装，与1011805并存，均须保留。P0.4.1的设备安装授权仅覆盖1011806，不自动覆盖任何新versionCode/APK。
- 本任务允许本地源码、MariaDB、Flutter/PHP测试及新候选APK构建；**不允许在手机安装/覆盖新APK**，除非Owner对新包作出新的明确安装授权。可以保留1011806供回归，不得卸载/覆盖1011805。
- 使用专用本机`elitesync-v2-function`MariaDB/HTTPS和合成账号。不得触碰阿里云、真实管理员、真实用户记录、旧DB、真实数据解密或共享HTTPS部署。
- 不删除旧消息/Conversation记录，不清空数据库卷，不执行全局Docker清理，不合main、不申报软著、不启动内测。

## 1. P0｜修复第2代Connection/MC重新授权后第1代私信历史重新出现

### 1.1 已确认的现象与代码路径

P0.4.1实机观察：
1. 第1代Connection+双方MC产生4条消息；
2. Block调用`SocialPolicy::revokePair()`，将pair已有Connection置为`CN_CLOSED`，将相关`MC_ACTIVE/MC_PENDING`置为`MC_REVOKED`；
3. Block生效期间，当前消息GET404，UI正文和写控件清除；
4. 解除Block后，建立第2代Connection和新MC；
5. 新会话重新显示第1代4条消息及第2代新消息。

顾问源码抽查：
- `ConversationDomainService::roomKey(a,b)`只按两个用户ID排序生成稳定pair key；
- `ensureDirectConversation()`按稳定`room_key` firstOrCreate，复用同一Conversation；
- `LiveConsentService`的Connection/MC身份确实按Connection ID和generation区分；
- 但`MessageController::listAuthorized()`先检查当前pair`canRead`，随后只按稳定pair room_id查询全部ChatMessage，没有按Connection generation/context过滤；
- 因而第2代新live gate打开后，旧代消息被一并读出。

### 1.2 产品权利合同（不可自行更改）

Owner已接受D-03：
- 在消息同意撤销、Connection暂停或关闭后，普通只读Conversation历史默认不开放；
- 除非针对主体、受众、用途、保留状态和适用法域建立单独明确的history-access authority；
- fail-closed不等于历史数据已删除/擦除。

Block是独立动作，但本实现中Block通过`revokePair()`实际关闭Connection并撤销MC，因此第1代会话进入上述关闭状态。第2代CN/MC只建立新的live上下文，不自动产生第1代历史访问权。

本任务按当前Owner已接受的保守D-03执行，不要求重新询问是否允许默认关闭旧历史。若产品未来希望解除Block并重新同意后可查看旧历史，必须另行形成显式Owner产品决定及history authority合同，不能由Codex以实现便利自行开放。

### 1.3 修复要求

- 将消息可读范围绑定到精确Conversation/Connection代际上下文，不能仅凭pair稳定room key和当前最新CN_ACTIVE/MC_ACTIVE返回所有历史消息。
- 第2代Connection/MC建立后，只能读取第2代live上下文产生的消息。第1代历史默认不可读，直到未来另有独立history authority。
- 旧消息及附件在数据库中继续保留；不物理删除、不重写消息、不宣称已擦除。按现有保留合同留存并保持受限。
- 可采用独立Conversation generation、消息绑定connection_id/consent context、或等效的不可混淆数据模型；先核对现有迁移和兼容消费者，再选择最小、安全方案。不得只在Flutter端按时间/ID过滤。
- 第2代新消息仍正常收发、已读、回复和附件访问；同代双方可见。
- 旧消息ID、旧通知、旧回复引用、旧附件/媒体URL、旧Conversation route即使当前第2代live权限有效，也不能绕过history authority读取第1代正文/媒体。
- 普通会话列表的last_message、last_time、unread、预览、通知标题/正文/计数不得从旧代记录推导出内容；必要时显示中性“上一段会话已结束，历史内容当前不可用”。
- 不得把不可读解释为对方删除、内容不存在、已法律擦除、Safety认定或有罪判断。

### 1.4 必须新增的回归测试

使用A/B合成账号：
1. 建立第1代Connection、双方MC，发送A→B与B→A多条文本消息及合成图片附件。
2. A Block B、B Block A分别覆盖；核对旧CN关闭、MC撤销、live读写拒绝。
3. 解除Block，按合法新上下文建立第2代Connection及双方新MC，确认身份/代际与第1代不同。
4. 第2代发送新消息；A/B当前会话只能读到第2代消息。
5. 通过`GET messages`的默认/latest、after_id、before_id、search和分页参数尝试旧消息；旧代内容均不可返回。
6. 尝试旧message ID的read/ack、reply summary、旧notification route/URI、旧Conversation detail、last-message preview、unread count和旧媒体附件URL；均不得泄露旧正文或媒体。
7. 确认第2代消息仍可正常发送/读取/已读/附件；第1代消息仍留在DB且未被修改或删除。
8. 切号、冷启动、前后台、缓存清理、重新登录和两端交叉测试。
9. 旧代访问拒绝不能依赖仅客户端隐藏；直接API和服务端数据库读路径必须 fail-closed。
10. 新增测试必须断言历史权利状态与live CN/MC状态分离，不能只验证HTTP状态码。

## 2. P0/P1｜补齐P0.4.1设备未完成项

### 2.1 Photo Picker和手机图片上传
- 使用专门合成PNG/JPEG，真实完成系统Photo Picker选图返回、预览、上传、服务端字节读回和页面展示。
- 覆盖错误MIME/损坏文件、上传中断、响应丢失和重试；不使用Owner私人相册。
- 如果Android选择器需要人工点选，等待Owner在设备前操作，不读取其它私人媒体。

### 2.2 完整历史媒体受众与缓存
- SELF/FRIENDS分别验证本人、原好友、新好友、退出好友和Block双方。
- 手机端核对头像/封面/作品原图、缩略图、旧URL和缓存；失权后冷/热启动均不得通过本地缓存复现旧字节。
- 第1代Conversation媒体也纳入第1节的代际隔离；新第2代live gate不得恢复旧代附件。

### 2.3 URI/通知
- 对真实过期链接、独立跨账号对象、Block后旧URI做冷/热启动。
- 验证通知跳转始终重新核对当前对象权限；旧代消息通知不能在第2代授权后恢复第1代正文。

### 2.4 无线断链
- P0.4.1 WLAN关闭时ADB reverse仍可达本机后端，故该结果不是有效网络断链。
- 本APK固定`127.0.0.1:18444`且依赖USB reverse。不得再将关闭WLAN等同后端不可达。
- 若仍需真实无线故障测试，须使用一条实际受WLAN控制的测试路径/独立受控代理，并证明目标请求确实经过该链路；否则明确标`NOT_RUN`，不为凑PASS更改固定APK或绕过TLS。
- 分别覆盖请求前、提交前、服务端提交后响应丢失、读取中断；与USB reverse故障注入分开记录。

## 3. 1011806及新APK设备门

- 保留已安装1011805和1011806及其数据。
- 本任务允许本地构建新候选并核包名、versionCode、签名、SHA、native/Dart endpoint和TLS证书。
- **安装新候选（例如1011807）需Owner另行明确授权**；不得把1011806授权解释为永久授权后续所有APK。
- 若没有新包安装授权，可先完成后端PHP/Flutter Widget/API测试及候选构建，不安装设备。旧1011806实机报告作为历史证据保留，不覆盖。

## 4. 交付

一次中文P0.4.2集中报告，明确：
- 历史消息重见根因与数据模型变更；
- 第1代关闭后历史默认不可读、第2代新消息可读的PHP/API/MariaDB正反证据；
- 旧消息/附件/通知/预览/搜索/未读/回复引用的隔离；
- 原消息/媒体数据保留，不删除、不声称擦除；
- Photo Picker、手机上传、SELF/FRIENDS历史受众和设备缓存；
- URI、通知和真实无线测试哪些完成/NOT_RUN；
- PHP/Flutter具名测试及历史FAIL账；
- 新APK固定身份和等待Owner安装授权的状态；
- 封闭内测仍NO_GO的剩余条件。

## 5. 严格禁止

不删除历史消息或附件，不读取真实用户数据，不访问阿里云，不恢复真实管理员，不部署共享HTTPS，不采购/开公网，不卸载/覆盖1011805或1011806，不未经新授权安装新APK，不合main、不申报软著、不启动封闭内测、不发布生产。
