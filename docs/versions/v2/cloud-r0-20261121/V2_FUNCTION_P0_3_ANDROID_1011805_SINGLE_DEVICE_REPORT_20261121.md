# EliteSync V2 P0.3 Android 1011805 单机实测报告

2026-11-21 · **HOST_PREFLIGHT_PASS / DEVICE_INSTALL_PASS / DEVICE_E2E_PARTIAL / CORE_FUNCTIONS_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO**

## 工程与设备身份

- 本轮从隔离工程 `v2-cloud-r0-20261121` 的 `codex/v2-function-completion-20261121` 分支执行。起点 `daa96756f96fb6fd62845323ebd3c53d2b2438d2`，初始工作树和暂存区为空，origin 为 `zcx369658780/EliteSync-v10`。本轮提交限报告、手册和哈希索引。Android 构建源码为 `36ae37206f482109e0bfc7a0f95335fc056da323`，与 P0.2 源码 `362abd618a1f670e313b365b60b5dfe1f6ab71b8` 的 Android 和 Flutter 子树一致。 [P0.2 固定源码](https://github.com/zcx369658780/EliteSync-v10/commit/362abd618a1f670e313b365b60b5dfe1f6ab71b8)
- 唯一 USB 实体机为 25060RK16C，Android 16 / API 36。首试保留 `INSTALL_FAILED_USER_RESTRICTED`，Owner 回复「可以重试」后安装成功。拉回实际安装的 `base.apk` 并复核为 `com.elitesync.v2functionp0 / 10.1.18-v2-function-p0 / 1011805`，209,094,024 字节。APK SHA-256 为 `d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`，APK v2 签名验证通过，签名证书 SHA-256 为 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。 [Owner 单机授权](https://github.com/zcx369658780/EliteSync-v10/blob/22ed45f22e1bcff26db3a28a089a40fe3cac6192/docs/decisions/OWNER_V2_ANDROID_1011805_SINGLE_DEVICE_TEST_AUTHORIZATION_20261121.md)
- 启用原三个专用容器与原数据库、存储卷。FPM 源码 `2a528919702289b4e0c39d86a5bb52d6067fc745`，应用镜像 ID `sha256:4e55a606161eca08bacf568462395470a71bf60e551bfd01b64922885d26377e`。专用数据库 `elitesync_v2_function` 为 MariaDB 10.11.19，server ID 2621121，116 表。原生与 Dart 使用同一回环 HTTPS `https://127.0.0.1:18444/`，主机访客 401，固定 TLS 证书 SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。本轮设备映射已按端口撤下并复核运行，三个容器保留运行，DB 健康。 [专用 Compose](../../../../services/backend-laravel/docker/cloud-r0/compose.function.yaml)

## 单机旅程与证据

A/B 是专用库中的两个合成账号。轮次、已公布候选和有效期 60 分钟的 TEST_ONLY 签名凭据在本机置备，双方业务选择通过手机分别作出。表中「主机 HTTP」单列本机固定证书接口调用。HTTP 状态来自 Laravel 请求追踪，MariaDB 读回限定两名合成用户及其对象。截图和原始日志本地留存。 [证据哈希索引](V2_FUNCTION_P0_3_EVIDENCE_SHA256_20261121.md)

| 功能 | 设备 UI 与 HTTPS | MariaDB 与失权 | 设备结论 |
|---|---|---|---|
| 登录、切号、资料 | A→B→A→B→A→B。退出显示服务端确认，登录和退出均 200。B 修改昵称，`POST /profile/nickname` 200，页面重读确认。冷启动可恢复 B 会话，`POST /auth/session/verify` 200。A01–A03 | 观察到 A 三个及 B 两个已撤销设备会话，B 新昵称持久化。B 的三盘输入空白，A 私有三盘继续保存在 A 下。旧访问令牌与刷新令牌的直接回放、账号停用后实机、城市场景与注册 NOT_RUN。 | PARTIAL |
| 三盘本命 | A 输入未知时刻和精确到分，两个 `POST /profile/natal` 200，随后 GET 均 200。页面分别显示输入/结果 v1/v1 与 v2/v2，均为 `COMPUTED_UNVERIFIED`。A04 | 库内只有 A 的当前记录 v2，存档 v1，B 打开同一页面看不到 A 的输入或结果。历史详情、版本冲突与写入失败恢复的实机复测 NOT_RUN。算法独立核验仍待裁决。 | PARTIAL |
| 慢约与历史 | 匹配页显示已参与、轮次已揭晓。A/B 分别接受，`POST /journey/proposals/{id}/decision` 两次 200。Block 后从「匹配记录」重进，`GET /journey/history` 200。A05–A06 | 提案 `MUTUALLY_ACCEPTED` v3，双方 `ACCEPTED`。旧历史保留双方选择，对方展示资料不可见。报名、运营发布动作与无资格时实机拒绝 NOT_RUN。 | PARTIAL |
| Connection 与双方消息同意 | B 请求连接、A 接受；仅有连接时「进入消息」未打开对话，会话请求 404。A 请求消息同意、B 独立接受，四次 `POST /connections/{peerId}/{kind}` 均 200。A07 | Connection `CN_ACTIVE` v2，消息许可 `MC_ACTIVE` v2。Block 后连接 `CN_CLOSED` v3，绑定的消息许可 `MC_REVOKED` v3。 | PASS，具名连接与消息许可 |
| 文本私信 | B 发送一条，`POST /messages` 200，UI 显示服务器已持久化。A 接收同一条，`GET /messages` 和 `POST /messages/ack` 200，B 可见「对方已读」。A09 | 同一合成消息行由未读变为已读。Block 后当前页清掉正文，消息列表与冷启动后列表为空；服务端保留消息记录，旧读取 404。 | PASS，具名文本链 |
| 正式关系 | 首次 A 向未开启接收的 B 申请，HTTP 404，UI 显示通用刷新提示。A 开启接收后，B 申请并独立确认，A 再确认，三次实际写入均 200。页面始终标 TEST_ONLY，双确认后状态文案为「已参与」。A08 | 先 `PENDING_MUTUAL` v2 且只有 B 确认，后 `ACTIVE` v3 且双方确认，来源 Connection v2，两个关系槽位。Block 后 `ENDED` v4，槽位为 0。凭据撤销后的单机二次确认 NOT_RUN。 | PASS，具名 TEST_ONLY 双边链 |
| 社区文字与媒体 | B 发布一条双向好友文字作品，`POST /status/posts` 201，作者端可见。A10 | 作品 `FRIENDS` v1，封面为空。当前 APK 选择图片会进入系统图库。保留图库隐私边界，图片选择、上传、SELF 与历史好友受众、新好友及 Block 后旧媒体字节全部 NOT_RUN。 | PARTIAL |
| Buddy | B 建草稿 201、开放和发布 200。A 未启用时发现 403，开启后查找 200 并申请 200；B 切回后确认再退出，两次 200。A11 | `OPEN` v3、`REQUESTED` v4、`CONFIRMED` v5、`WITHDRAWN` v6。发现记录由 `PUBLISHED` 变成 `CONSUMED`，退出页只展示终态。 | PASS，具名发布至退出链 |
| 通知与旧入口 | B 在通知中心经「查看当前状态」进入 Connection，通知详情 GET 和标记已读 POST 均 200。Block 后历史页显示「通知已不可用」，旧通知没有可操作入口。A12 | 通知及已读记录持久化。主机用旧通知 ID 查看，两个由当前变历史且载荷为空，另一个仍为当前。Android 外部 URI 深链 NOT_RUN。 | PARTIAL |
| Block 与本机缓存 | 实际对话 UI 未提供可用 Block 入口。以 B 的合成凭据从主机调用 `POST /moderation/blocks` 200。保持旧对话在前台，约 8 秒后见原正文消失和重验失败提示，回到消息页及冷启动均无可读会话。A09、A12 | 单条 Block 持久化。主机验证双方旧 Connection、旧消息及 B 查 A 旧资料均 404。Android 的 Block 写入入口、旧头像及作品 URI、脱机跨账号缓存边界 NOT_RUN。 | PARTIAL |
| 网络中断与恢复 | 暂停本轮 18444 USB 反向转发约 38 秒，冷启动显示登录页，未显示私有内容。重建同一映射后冷启动，`POST /auth/session/verify` 200，恢复 B 首页。A12 | 定向读回关系、消息、作品、Buddy 和设备会话均仍在。手机飞行模式、写入途中网络丢失和 UNKNOWN 原结果恢复 NOT_RUN。 | PASS，指定服务链路中断与恢复 |

## 失败、产品缺项和历史范围

- 首次安装的系统确认失败保留。正常连接/消息许可完成后，私信可收发。旧对话失权后，正文已隐藏，但页面仍绘制发送和媒体操作控件，撤权后这些控件的写动作未触发。当前实机对话的 Block 入口缺口仍待修复。
- 一次未获接收许可的关系申请只给通用提示。实际 ACTIVE 在界面显示「已参与」，需要与正式关系文义区分。另观察到部分 `POST /telemetry/events` 422，原因 UNKNOWN，相关业务 HTTP 结果在上表单列。
- 本轮只跑具名设备旅程和闭环读回，P0.2 的 127 项 PHP / 1,587 断言是上批旁证。本轮 PHP/Flutter 全量、正式 A6、真实 KYC/Push/RTC、正式删除受理和用户数据场景为 NOT_RUN。旧排盘 A/B/C 和注册可信离线 T0 继续由 Owner 裁决。
- 历史全量 Q PHP 46 errors / 122 failures、旧排盘 25 项、R1 Flutter 扩围 5 项、1011804 原 FAIL/UNKNOWN/NOT_RUN、F-01 READABILITY_PARTIAL 和原 43 PNG PENDING_BINARY_UPLOAD 保留。本次截图属于 1011805。

## 软件著作权与封闭内测

A01–A12 已建立同版图片索引。A10 当前为文字作品，图片版替换待安全的具名测试图库；A12 记录应用内旧通知及会话，外部深链截图待实测。W01–W04 尚未采集，权属、逐项许可、最终交存范围与登记版本待确认。手册已按实际入口修订，可交 Owner/GPT 集中审阅。封闭内测仍为 NO_GO，优先补媒体受众、外部旧链接、端上 Block 与撤权操作控件，以及保留的产品和外部依赖裁决。 [操作手册](ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)
