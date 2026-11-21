# EliteSync V2｜P0.4.1 Android 1011806 实机验收与共享 HTTPS 回执

2026-11-21（中国标准时间） · **`DEVICE_INSTALL_PASS_ON_AUTHORIZED_RETRY / DEVICE_E2E_PARTIAL / CLOSED_BETA_NO_GO`**

1011806 已并行安装在原 1011805 实测手机，手机拉回的 APK 与固定候选一致。合成账号通过冷启动、切号、资料、三盘持久读回、消息 UNKNOWN 和双向 Block 的具名实机检查。Block 生效期间旧内容和写入控件失权。解除 Block 并重新建立 Connection 与双方消息同意后，重新获准的会话返回上一轮消息，此项列入顾问复核。Photo Picker 成功选图、完整历史受众和真实网络中断窗口仍待覆盖。 [Owner 设备授权](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/decisions/OWNER_V2_ANDROID_1011806_DEVICE_INSTALL_AND_P0_4_TEST_AUTHORIZATION_20261121.md)

## 设备、候选与运行身份

| 核对项 | 实际结果 |
|---|---|
| 工程 | 授权隔离树 `v2-cloud-r0-20261121`，origin `zcx369658780/EliteSync-v10`，分支 `codex/v2-function-completion-20261121`，固定源码 `00ca46f6b020afa25ce472509c2fd3227f74c461`，首试报告 `2093e01edecfe400ba8a34945635ef526364a98e`。四份首读文件固定在治理 `00f40fb598bc5d3d73b64d942ce2871e38d59d3d`。 |
| 原实体设备 | 25060RK16C，Android 16 / API 36，完整序列号与私有 1011805 日志精确匹配。本机保存完整标识。 |
| 首试与重试 | 首次退出码 1，`INSTALL_FAILED_USER_RESTRICTED`，具体系统拒绝原因 UNKNOWN。Owner 在场重试后退出码 0 / `Success`。PackageManager 回读 1011806 和 1011805 同时存在。 |
| APK 本机与拉回 | `com.elitesync.v2functionp04`，versionName `10.1.18-v2-function-p04`，versionCode `1011806`，arm64-v8a，均为 209,094,076 字节，SHA-256 `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`。两份 APK 的 v2 验签通过，证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。 |
| AAR 与 HTTPS | Flutter AAR SHA-256 `b81774a1730c0835161ee443625493c93c006543192c7b4beffe83afb36466aa`，APK Dart 库字节与 AAR 一致。DEX 和 Dart 两套网络配置均指向 `https://127.0.0.1:18444/`。本机 TLS 证书 SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`，未登录探针 HTTP 401。 |
| 运行库 | 专用 Compose 的 edge、app 和 db 在线。MariaDB 10.11.19，schema `elitesync_v2_function`，server ID 2621121，原数据库和媒体卷均核身。测试仅用本轮两名合成账号。 |

## 实机验收

| 编号与范围 | 状态 | UI、HTTP 与持久化证据 |
|---|---|---|
| A01 安装、启动和会话冷启动 | PASS | 第二次安装成功，拉回包一致。登录态强停后冷启动，`POST auth/session/verify` 200，回到首页，系统入口与反向转发一致。 |
| A02 合成登录、退出、切号、前后台 | PASS | A、B 各自登录，退出回到登录页并显示服务端撤销确认，账号相关请求在服务端归到对应合成主体。A→B→A。另从作品详情送入后台再恢复，同进程重获前台并展示授权内容。 |
| A03 昵称资料 | PASS | 手机保存后显示已读回，`POST profile/nickname`、`GET profile/basic` 均 200，MariaDB A 昵称更新、B 昵称未变。 |
| A04 三盘 | PASS | 未知时刻输入，手机显示已保存并重读以及八字、紫微、西方本命盘三个状态。POST/GET 均 200，MariaDB 输入/结果修订均为 1，整体 `COMPUTED_UNVERIFIED`，各盘保持未知和待核验。 |
| A05–A06 慢约与候选 | PARTIAL | 手机显示无候选和报名资格未满足，主动报名控件禁用。主机使用同一虚构账号试报名返回 403。MariaDB 已有活动默认轮次，本轮保留该轮次。1011806 候选发布与双方接受正向链为 NOT_RUN。P0.2/P0.3 历史实测独立保留。 |
| A07 Connection 与双方消息同意 | PARTIAL | 发现未建立所需上下文时主机请求 404。经双向好友与受限 CLI 授权后，由合成主机 HTTP 置备两轮连接和双方消息同意。手机实际读到 `CN_ACTIVE`/`MC_ACTIVE`，通过站内通知进入会话。手机端双方申请、接受未跑。 |
| A08 正式关系 | PARTIAL | 手机正式关系页显示供应商未配置、当前未核验且无正式关系。主机对已 Block 对象的申请返回 404，MariaDB 两名账号关系数为 0。1011806 合成双确认正向链为 NOT_RUN，既有 TEST_ONLY 验证按原范围保留。 |
| A09 文本、Block、旧消息 | PASS（Block 生效期间） | A 与 B 在手机会话中分别发起 Block。B 的 POST 上游 200 后丢响应，端上自动 `GET moderation/blocks` 200；A 的正常 POST 200。发送、图片、视频以及语音/视频通话控件在 UI 树中禁用，正文清除，当前消息 GET 404，双方主机只读复核亦为 404。B 重复 Block 由主机调用 200，首轮 Block 记录仍为一条。 |
| A09 再连接后的历史消息 | FAIL | B 解除 Block 后，经新的好友、Connection 第 2 代和双方消息同意进入会话。手机 A 同时看到了第 1 代的 4 条历史消息与第 2 代新消息。MariaDB 两代 Connection 分开，消息行在 Block 前后持续可见于库内，需复核授权后的历史边界。两次 Block 生效期间都没有观察到 UI 还原旧消息。 |
| A09 消息 UNKNOWN | PASS | 手机经受控本机 HTTPS 执行三组故障用例。首次 GET 故障注入因旧连接未命中，留底；冷启切换到代理后，精确故障触发和数据库读回均验证通过。详见下表。 |
| A10 手机 Photo Picker、PNG/JPEG 上传 | PARTIAL | 1011806 能打开系统选择器，合成 PNG 已置备。本轮未收到选图返回，未采集系统图库。JPEG、手机发起上传、失败重试均未跑。 |
| A10 SELF、FRIENDS、历史媒体、缓存 | PARTIAL | 主机以 A 创建 SELF/FRIENDS PNG 和头像，原好友 B 的 SELF 字节 404、FRIENDS 200、字节相同且 `no-store`。B 在手机详情显示同版合成图，Block 后列表移除；主机复检旧封面、头像、作品 URL 为 404，作者 A 同一 URL 200。1011806 的内容缓存清理显示成功。独立新好友、退出好友态、媒体缩略图的缓存层和完整设备旧 URL 回读仍未验证。 |
| A11 Buddy | PARTIAL | 手机创建仅本人在线搭子草稿，HTTP POST 201 并成功回列表，MariaDB `DRAFT`、修订 1。1011806 双方申请、确认和退出尚待实测。 |
| A12 外部 URI 与通知 | PARTIAL | 热启动拒绝未注册的私信路由，包括 Block 后携合成对象编号的旧私信 URI，冷启动拒绝未注册的通知 URI。`map_pick` 冷启动可解析，附加 `peerId=0` 时只送达当前 Activity。通知中心 GET 200，当前条目经服务端读回进入合成会话，Block 后历史条目显示「通知已不可用」，旧的正文、媒体和写控件失权。过期链接的真实时效和跨账号独立对象仍待补。 |
| 真实无线中断 | PARTIAL | 实际 WLAN 已关闭再恢复，移动数据原为关闭，USB reverse 全程可用。关 WLAN 期间手机刷新仍收到 `GET messages` 200。真实无线切断请求前、提交前、提交后丢响应及读取中的四个故障窗口均为 `NOT_RUN`，本机传输注入独立计账。 |
| W01–W04 与软著 | NOT_RUN | 没有新 Web 截图。1011806 A10 为设备渲染主机合成图，A12 为撤权后的通知历史。手册保留 1011805 底稿，增加独立 1011806 附页。 |

### 消息 UNKNOWN 的三项权威证据

| 用例 | 手机状态 | HTTPS 与 MariaDB |
|---|---|---|
| `msg-fresh-503` | 显示「发送结果尚未确认，请重新核对服务器」 | 独立 `Cache-Control: no-cache, no-store` GET 命中受控 503。失败到下次确认之间无新增 POST。 |
| `msg-before-upstream` | 重新核对后显示服务器已持久化 | 首次 POST 在转发给后端前关闭。独立 GET 200 后才再次 POST 200，两次请求的 `client_message_id` SHA-256 相同，MariaDB 恰有一行并匹配编号摘要。 |
| `msg-after-upstream-verified` | 丢响应先保留重试入口，核对后显示已持久化 | 上游 POST 200 后关闭端侧响应，独立 GET 200。该消息只观察到一次 POST，数据库只有一行。 |

最先尝试给 fresh GET 注入 503 时，设备仍沿用了调整转发地址前的 HTTPS 长连接。该注入未被领取，原消息已由实际 GET 确认。重新冷启动后确认设备所有测试请求走受控回环代理，再执行上表。此差异属于测试路径证据。真实无线测试中没有用撤除 USB reverse 模拟无线断网。

原 P0.4 PHP 扩围 60/61，唯一基线失败为 `V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields` 期待 409、实得 200。此次观察到合成端遥测 POST 422；测试流程保留该记录。历史 FAIL、UNKNOWN 和 NOT_RUN 不上调。 [P0.4 底账](V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md)

## 共享 HTTPS 决策准备

| 方案 | 当前可核结果 |
|---|---|
| 现有上海旧机 | 沿用只读原证 2 vCPU/2 GiB、约 627–628 MiB 可用内存、swap 0、旧 Laravel/MariaDB/Redis/LiveKit 同驻。并行容量未核准。只有无需升配且原套餐网络足够时，新增实例本体费用才可按零估。现账单、续费、带宽与峰时负载待获准后核。 |
| 独立上海 Staging | 以 2 vCPU/4 GiB/50–60 GiB 为候选。阿里云开发者社区公开参考为 70 元/月刊例或 379 元/年活动档，活动、上海库存、账号资格、续费、税费及实际结算均 UNKNOWN。轻量旧固定流量内地溢出 0.8 元/GB，轻量内置快照免费且有数量上限。ECS 另核系统盘、EIP/带宽或流量、快照存储、VPN、备份保留和续费，价格计算器未给具名订单报价。 |

共享环境需要独立 V2 FPM、worker、数据库账号/schema、媒体和数据卷、应用密钥与会话。使用可信 TLS 和具名访问限制，Web 管理和激活入口额外限制来源或经 VPN，数据库、Redis、FPM 保持内部网络。先做合成账号外地 HTTPS、远程权限和回滚演练。后续共享 APK 另固定原生/Dart 端点和签名。当前云端支出 0 元。 [阿里云轻量公开参考](https://developer.aliyun.com/article/1784154) · [轻量计费](https://help.aliyun.com/zh/simple-application-server/product-overview/billable-items) · [ECS 计费](https://help.aliyun.com/zh/ecs/billing-overview) · [EIP 计费](https://help.aliyun.com/zh/eip/billing-overview)

真实管理员数据授权包沿用 [独立签名、持有人及最小字段模板](V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md#一次性真实管理员数据授权包待-owner-确认)。真实候选数 UNKNOWN，实际候选清单、签名配置、旧库读取、备份解密和迁移均待 Owner 另行具名批准。共享 HTTPS、全部指定旧账号恢复及本人外地登录均是内测准入硬门。

## 收尾与待验收事项

- 先恢复本轮反向转发到原本机 18444，然后停止仅用于测试的代理并只撤销本轮 USB reverse。回读映射列表与试验前相同。PackageManager 仍能找到 1011805 与 1011806，专用 Docker、MariaDB 和原卷保持在线。WLAN 已恢复并重新关联，移动数据和飞行模式保持原设置。
- 1011806 的 A10 同版图为 `P041-A10-friend-cover-render.png`，展示由主机置备并经手机权限读取的封面。A12 同版图为 `P041-A12-history-revoked.png`，展示 Block 后通知历史。Android release 进程的两次定向 logcat 过滤均取得 0 条符合条件的网络事件。本轮 HTTP 证据来自筛过合成账号的 Laravel 日志和本机代理，数据库证据来自只读查询。
- 顾问优先复核第 2 代会话重见第 1 代正文是否违反既定权限边界。完整设备验收还包括完成选图和 JPEG 上传、新好友及退出好友受众、端上缩略图缓存、过期/跨账号独立对象、合成正式关系双确认、Buddy 双方链，以及能实际影响设备到后端链路的无线中断实验。固定回环候选的 USB 路径在 WLAN 关闭时仍能访问本机后端。
- 封闭内测继续 `NO_GO`，待共享受限 HTTPS 单独裁决和验证、具名旧管理员数据授权及本人异地登录、缺失的实机用例和顾问集中验收。旧排盘 A/B/C 和注册可信离线 T0 仍待 Owner 决定。软著材料为准备稿，正式选图需锁定同一版本。 [操作手册](ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)

## 本机日志和截图 SHA-256

索引包括本次 APK 拉回件、截图、UI 抓取、日志及验收用数据库快照。原件留在本机证据目录 `p041-android-1011806-20261121`，表中路径相对该目录。完整设备标识、账户凭据和未筛选记录留本机。`P041-A09-fresh-get-failed` 保留首次未命中代理时的实际画面，失败用例以 `P041-A09-503-retains-unknown` 为准。`P041-A11-buddy-entry` 保存了首次因底部导航遮挡而进入消息页的画面，Buddy 入口与草稿以具名补验图为准。

| 证据路径 | 字节 | SHA-256 |
|---|---:|---|
| `api-trace-synthetic.jsonl` | 74366 | `f0db71a7f2caff1f085c31657c79851aafa4fac2a0dd9ecece8fbccd5ceb4dcc` |
| `fault-proxy-synthetic.jsonl` | 54377 | `91cc25ce510e01bc7ad2609d0eab9bfeb2df1f0691a6293c0a7477ead7fba60a` |
| `first-launch.log` | 231 | `51ed456caf3692ce0dfdf7f92482a41b3e6c8e22651a2fbe7f26024668779b31` |
| `fixture-seed.log` | 56 | `7451c783ae2051f64b97ed4c745835fe81236e04b34b78fad3ed5c492a77d3d2` |
| `install-attempt-01.log` | 1242 | `a13a10af956a3f2c31a79a58ff27e95a088c0f508be436f8f2151101e81018a0` |
| `install-attempt-02.log` | 598 | `2ba71bb19f1932663742224ad47619fed58b7ece42ae04c5ab1a65f203ff4310` |
| `install-stop-receipt.md` | 1481 | `cbc5a15a3f194ffa7e13ecc3b849f327fb84f97b1f3893295e00fd9babb85cff` |
| `installed-base.apk` | 209094076 | `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130` |
| `installed-identity.log` | 264 | `d01b469488891466991a15b7367ade4a0ae14f80b4d4f5521a3396a76489547c` |
| `P041-1011806-SYNTHETIC.png` | 1295 | `e04e41161154703a2f6de0e3613e1d1092c8de59ce6e4f4ceaf6155664f782dd` |
| `P041-A-block-prerequisite.log` | 414 | `49f27885fb67885c54b55103029ffed984ae3a7e8ef15594c819640de5231d49` |
| `P041-A01-after-A-signout.png` | 885220 | `cd235facffbf510e1141eb9d0dfaedb6dc7c7e3d0aeb0e485928d336fc94494f` |
| `P041-A01-after-A-signout.xml` | 10653 | `746db4df425e2106e841ce8c4a10f9790f8314c47865822b68626a6fc3d8d925` |
| `P041-A01-cold-login.png` | 823443 | `daec69f22ecbba31aebe118bdb024d5f4b62493b8ac63328b270c29820fe3393` |
| `P041-A01-cold-login.xml` | 10572 | `b7908dfd1fb9955a06f4c2e0a6a5b73239cf201a2e5f70fe9af468e9fe6f6c51` |
| `P041-A02-A-cold-after-block.png` | 278406 | `8d9ad9170f92dcd999219009b1da40be8340905061ad108c166f5bfe03ef22fd` |
| `P041-A02-A-cold-after-block.xml` | 16226 | `da98835e63242267da859cbf3d8f64f4c08a338e9406e5bf7b7012c62613417a` |
| `P041-A02-A-return.png` | 280354 | `871130815c3bb45c9e2254ebc9bce438e2cc187751f4bf9df8ae34758b046b9a` |
| `P041-A02-A-return.xml` | 11088 | `f228ce60a96f09630b4b5e314a6ed7e3de6b7ee8224f6866fc5d0759ec11242f` |
| `P041-A02-B-home.png` | 278352 | `89057539ec9405701ffd140f00fca0af75dc41d9b2eca77f1582631d94198117` |
| `P041-A02-B-home.xml` | 16225 | `0ff8a32ed0d1670b8a3134cdd8d5522ffe204fa9facab50c306b345d66396ea6` |
| `P041-A02-cold-home.png` | 278208 | `3e854d0cdd648eddfeea9d5b51d5edc218598752f2bf0e85a745cd70cc72bdb0` |
| `P041-A02-cold-home.xml` | 16226 | `da98835e63242267da859cbf3d8f64f4c08a338e9406e5bf7b7012c62613417a` |
| `P041-A02-home.png` | 277900 | `c8a6870ab5490ddf6da491e42cb918226f89e5eaa4913742c5387c0182b42085` |
| `P041-A02-home.xml` | 16225 | `0ff8a32ed0d1670b8a3134cdd8d5522ffe204fa9facab50c306b345d66396ea6` |
| `P041-A02-signed-in-cold-relaunch.png` | 93949 | `7d026ff8aa91367dec1c0eea551e0a3a6d4e213e53d297eb1c301d89ca4f3dcf` |
| `P041-A02-signed-in-cold-relaunch.xml` | 3362 | `adb6b0852311d4267b3bf36aecfc93bb1e39b4038fd5f500049fe97a2c766abb` |
| `P041-A03-nickname-saved.png` | 265746 | `6a93db3b6155f4d33dc35346e4042861149910f0bdc768ffe03a6d27832afe95` |
| `P041-A03-nickname-saved.xml` | 10752 | `73615fb5e805f52ceb3c4a3055dcc360d75684e9bbf8444564714c360a8d3629` |
| `P041-A04-chart-more.png` | 219015 | `a6eb568806444ca265c7a77475988d6748bd467176cd2e04de8cdd0db4edf288` |
| `P041-A04-chart-more.xml` | 14208 | `50fdfdbcd7b1ddbe8b4bf840e282e12fbfd23a8c0c70461a64c73f8ef7f2936f` |
| `P041-A04-natal-result.png` | 321156 | `fba3ef716e9026d103c71a89cc54afa9818b70b6b06974aad617ff18c77331a1` |
| `P041-A04-natal-result.xml` | 11180 | `bcd9be4ff13f73a3f5ab2b95c6a148a7c32d35558aef8a7b4fef0ef13999152d` |
| `P041-A04-three-statuses.png` | 296862 | `9c5e7465e23b4f220db6a4409c2885f6742555cee62c2bc21a72b69f0b6a8e04` |
| `P041-A04-three-statuses.xml` | 20813 | `f9a1f32defd3301990cbfbd53b30416269c428f3a1d8ebbd84e7317ac14878f4` |
| `P041-A05-enrollment-guard.png` | 380314 | `20b9de5a80d579f52d8cd4433cce3dca32f615542332a43e4ac6acaa97abedee` |
| `P041-A05-enrollment-guard.xml` | 15628 | `cf8261041cff9ab858769878de353950a206b1f00323a4d66c368ecf0911311b` |
| `P041-A05-opt-in-result.png` | 379176 | `804aeb8af670b325af47d8328282c0ec83ec2176ed00fed4cc2745e24a49beb2` |
| `P041-A05-opt-in-result.xml` | 15628 | `cf8261041cff9ab858769878de353950a206b1f00323a4d66c368ecf0911311b` |
| `P041-A07-live-gates.png` | 196793 | `bfc041997fa4d677e1a60f4ea50953158dca5a022b9aff5c2a4cfb15b95436b4` |
| `P041-A07-live-gates.xml` | 9038 | `b133bf92f2943d8e392bd9599d275053b12e8d85e33d539cacb4233be1861411` |
| `P041-A08-relationship-guard.png` | 454648 | `8be054f68cfe6eb8c82c1c423321ddfceaa3d0bdcd316af424f5f8ef220cd090` |
| `P041-A08-relationship-guard.xml` | 9713 | `4461aeb3cfccafcafcd017382de4f93e15e9134462cac7a71a80163d5b7d90be` |
| `P041-A09-503-retains-unknown.png` | 166719 | `07eaa3c2c02955729589e53db28f87608f110bb774605cf2583560ef65aa0b8f` |
| `P041-A09-503-retains-unknown.xml` | 11153 | `7c6c9cc52b05cc0cc853871c2f4df4e68cab20e653e6eecd23d6a2a630d38044` |
| `P041-A09-A-blocks-B.png` | 105978 | `1bb4b83eadf87b70e9f2d0ba8bc34fb28f951666fd38903b5f0d9dafc46ac02f` |
| `P041-A09-A-blocks-B.xml` | 8908 | `032269eaa3b631990dd8669a4e62a1a623e40f2d3752e7a3622ea9966f767943` |
| `P041-A09-B-block-after-response-loss.png` | 104773 | `1dbcf0604d0cc5c0a24941898e9d1955148428430b5b2b8c763a7c47a94ad7c5` |
| `P041-A09-B-block-after-response-loss.xml` | 8908 | `032269eaa3b631990dd8669a4e62a1a623e40f2d3752e7a3622ea9966f767943` |
| `P041-A09-block-confirmation.png` | 181957 | `e1960d918d4940f6d54c24e5c50af24f19e353b6dd34b327f15faf15369010c7` |
| `P041-A09-block-confirmation.xml` | 5584 | `c66d894ff881369b0b8bb2d8a698842ea576a44f3e6d95e78a2c4132913c20a8` |
| `P041-A09-commit-verified-no-resend.png` | 237068 | `2561120f782c33b2f369bdcd9c0035a39227d2b10eeddfcb08761aa8d57d50d5` |
| `P041-A09-commit-verified-no-resend.xml` | 11511 | `ba162f55fde12e352a847d7f2b087f6f533383a166229b757b4576b8300dbb3b` |
| `P041-A09-committed-unknown.png` | 165759 | `2e31635f3a1e5422f811f3534075bb82b16a868ec45b0ee5d5680bbe1530a45a` |
| `P041-A09-committed-unknown.xml` | 9722 | `d81408afccf9b265e6120ee7411fc719731879d902e7351a57dc9d703f08f1d8` |
| `P041-A09-fresh-get-failed.png` | 228349 | `3ebae22fd1f37b2f11363eab3e9e5b900a41cfa00c55edfa443e5510e2609c65` |
| `P041-A09-fresh-get-failed.xml` | 11495 | `756363b39d0540e5d663f24ad81741c16a5a78cd367671d3b63ac0fcbed28456` |
| `P041-A09-notice-to-chat.png` | 100129 | `6b421ad6e0b566b7eb6cde1792ae73a8914fe6c252389ac42777f44ae4c81b57` |
| `P041-A09-notice-to-chat.xml` | 9967 | `9720430c210ed1450346db4d1d917de76c018c6778d3078b69e67b6e31ba739f` |
| `P041-A09-original-key-ack.png` | 235877 | `d2cedf421e6a31cb7966971f20181c5341fb2648b3254e4b656cd61b8eb472b0` |
| `P041-A09-original-key-ack.xml` | 11505 | `b38ee34199d56b8d1e1d344bab238f68c9685c45c94324a764bb14e373209c2c` |
| `P041-A09-post-commit-unknown.png` | 211054 | `6020c377d4e2a5d1f96cef011a38a904689ca5b71c5c75ec499cf7a486ac6cd9` |
| `P041-A09-post-commit-unknown.xml` | 12699 | `25f59d9d2e3caf312cd66ce44b4e62a7c2a18db98969a8d94ce14feacd1fa64b` |
| `P041-A09-pre-commit-unknown.png` | 167304 | `8a11c29082d4b34239bb6c9f7ac4720fa6fca3dd6d2fb44afd8848727a285407` |
| `P041-A09-pre-commit-unknown.xml` | 11165 | `db32e9cd6d329f33381667643f139a537676298e67b111faff8b9b85392bbcac` |
| `P041-A09-proxy-fresh-session.png` | 125682 | `df5bc7b3174d27bb33635aeb5bc22ea46fdb341365a33e41a90c7203bd576860` |
| `P041-A09-proxy-fresh-session.xml` | 11102 | `79cab99d93a0600c53bae067e1d4067d693e646a9f878b981b4c6f28b410c0b6` |
| `P041-A09-reauthorized-old-messages-visible.png` | 165616 | `63ec792aab3a26b87f87733ef00822719fe2fc9e797edeefb8b2273c34fd83df` |
| `P041-A09-reauthorized-old-messages-visible.xml` | 14453 | `39549adddb4b502fdafb219d678e1b7aaf339ca37ab00183bc388a9e64379421` |
| `P041-A09-wlan-off.png` | 235663 | `75e216632bfe22e51680e5e95eedc09f5e01ebfbf445638916957b57dbbbbde1` |
| `P041-A09-wlan-off.xml` | 11511 | `ba162f55fde12e352a847d7f2b087f6f533383a166229b757b4576b8300dbb3b` |
| `P041-A09-wlan-recovered.png` | 235544 | `21a5814c7f6ef70ebe6b844b7a3d726f9f7e33e9522ae1210c4eaa1b21b4cdd1` |
| `P041-A09-wlan-recovered.xml` | 11511 | `ba162f55fde12e352a847d7f2b087f6f533383a166229b757b4576b8300dbb3b` |
| `P041-A10-app-cache-callback.png` | 266543 | `ed4bcc52bca8fb9a34d2988c909e5eb22672a69533ea48c78284a26086f05c7e` |
| `P041-A10-app-cache-callback.xml` | 9642 | `3e892a096bf671827623bd2fc157356d966285b649f61b50158f7f40b1ee4a6e` |
| `P041-A10-before-picker.png` | 226881 | `fffc745290118c907e444c2a5ef968ef6ae2f436a41dc41c522d18a3d827fbb8` |
| `P041-A10-before-picker.xml` | 9019 | `871181c9f608a10c7d6c75863b7008ee5791fd288822a78cf8aa1491169edfb7` |
| `P041-A10-foreground-again.png` | 129739 | `b4ca82b1f1f3ab33583407e1da41db059f081038405e4702aa1b3fb2314bdaf6` |
| `P041-A10-foreground-again.xml` | 5734 | `1bf3736b29c91c3634e9d9fcd634c1af204d4a9b17fc3b2f5f565a33a13e2a3d` |
| `P041-A10-friend-cover-render.png` | 129739 | `b4ca82b1f1f3ab33583407e1da41db059f081038405e4702aa1b3fb2314bdaf6` |
| `P041-A10-friend-cover-render.xml` | 5734 | `1bf3736b29c91c3634e9d9fcd634c1af204d4a9b17fc3b2f5f565a33a13e2a3d` |
| `P041-A10-missing-after-B-block.png` | 282887 | `a86ba38ff3c0fe7d835418896de31ee0853a6b7b8fe598e4fe24bd777a441e58` |
| `P041-A10-missing-after-B-block.xml` | 16305 | `7d9b454b2c717179d50bdc1a49f8047c608719c29c7898b388c7d0e1fc7169f0` |
| `P041-A10-phone-renders-host-fixture.png` | 306847 | `cff5f27eea94309ae236a466a58969e4d8430f157bbf633949eb353cefaea273` |
| `P041-A10-phone-renders-host-fixture.xml` | 16228 | `ea641b13624aea1fc29d15829a19de0ffdf47ed96c917831eea8d74bd2191478` |
| `P041-A11-buddy-confirmed-entry.png` | 204904 | `0b4a4f1e3f726a4a6d495158e9cde68a4a9fa4b1e4cd8397c80bb3209b455d13` |
| `P041-A11-buddy-confirmed-entry.xml` | 9828 | `a7a3ad90f15a5341a2198e832ec2f0742e99c49b11a3781153d644d45b42d442` |
| `P041-A11-buddy-entry.png` | 185970 | `91fb3aedda75f3ae632d994465a50ac5288ef0843cccb798c5a93802401c0669` |
| `P041-A11-buddy-entry.xml` | 8872 | `dc885e8ec623d7389cf1e2e61842564fd8cf10189da3e177d827500e3c4868ea` |
| `P041-A11-private-draft-confirmed.png` | 307762 | `671fab3a252d74c8818033f808e5d225e3b838c79ae4683e7e4f2363882f07b0` |
| `P041-A11-private-draft-confirmed.xml` | 11857 | `3c50ccc0ecaf1ed2b7a88b0dea3cf2bbe91cb5b7dd6b4313d3624984c6396a39` |
| `P041-A11-private-draft.png` | 206254 | `830c872110f4d098a45f5cc2f85f6532a023bc2a82da90e98b25e775cd95e4d3` |
| `P041-A11-private-draft.xml` | 13076 | `ea0e62351a8c5393c22cd8e3d94087eb8100389bc5b2bc308e7a2de27ea02d1a` |
| `P041-A12-after-block-notice.png` | 108853 | `0ef42d5f40a80ca870d32b1e96923cb1e8ef03e82cfd8e0f9aafd5bece181d54` |
| `P041-A12-after-block-notice.xml` | 6366 | `e10e8966e902bb7c1fe29d8af5e5912c70f3c770fa971f43d7bc95ac74911aad` |
| `P041-A12-history-revoked.png` | 81341 | `f90654e73313e59387b0d4faf3dc483525d8d43f93a2c289711c06dba6b2fba7` |
| `P041-A12-history-revoked.xml` | 7705 | `69af7009ea4803f36f291210edb9659d2e16b366fe634d60598ed0623d0d36e1` |
| `P041-A12-notice-current.png` | 137143 | `8e70ccec0372c8a2a01ddf89dc9bf38eb6cae9ec2bd6dfbc81efcceff4a548df` |
| `P041-A12-notice-current.xml` | 7823 | `ce3069e4ffd3b637bc46051535a83884988969e01999d829c0b39dbb22d7e327` |
| `P041-A12-notice-inbox.png` | 110602 | `6fb2d580107611fac8a8eeb855aa77dacfd4a5a04a1df920cbae54c244580c98` |
| `P041-A12-notice-inbox.xml` | 6367 | `169650809a63941afae44d00001c0b0f3ec85df7d07ab64d1c9083c459b1dd1e` |
| `P041-actual-wlan.log` | 1965 | `ab2d4ff4b6a69a56f1692618ed114ccfdad073339812a945315126e00f6006cd` |
| `P041-after-A-block-host.log` | 124 | `fef28492a4ec11059595e3133857ae291b1f206ac8aa983f3a133e723af9958d` |
| `P041-after-B-block-host.log` | 264 | `c6fcb081aa1df3dc99dddbcf39286fe345762fd623a0a6bcbdc6fcb31183961b` |
| `P041-app-network-before-final-relaunch.log` | 2 | `7eb70257593da06f682a3ddda54a9d260d4fc514f645237f5ca74b08f8da61a6` |
| `P041-app-network-last.log` | 2 | `7eb70257593da06f682a3ddda54a9d260d4fc514f645237f5ca74b08f8da61a6` |
| `P041-B-cold-after-cache-clear.log` | 225 | `85178e787ff647ebd96c6bd2daa65d31c8b871e0af02938fa70670efa7435b73` |
| `P041-B-first-login.png` | 844682 | `e8d704e3feea5aa948084f861922c6be3a8c5c1cb2f9a08bdd7ec3b00e6c3bbd` |
| `P041-B-first-login.xml` | 11089 | `beac58a3e2b522c61f05f5489ece0e74f1beaef45ca2625cdaf3a726467bfd8a` |
| `P041-cold-relaunch.log` | 225 | `8eebadba3ad03d3427cc83227556da2a0fb8544b5d3fa8c20911105cdaeb6668` |
| `P041-connection-consent-prerequisite.log` | 65 | `3758192af04efae574afe8f8d43a7f929374be66b306ad28d583df0a82360a08` |
| `P041-connection-fixture.log` | 89 | `75452ddbdbc4e33b6f6f724e16b8487502b7bb5dfd5c0273811c7083c6eb679f` |
| `P041-connection-read-after-friend.log` | 124 | `0cc0a07bf9cd796a94116aef6b1797d2090bcb5f69a5ed38e0ad9614102c6809` |
| `P041-DB-after-A-block.json` | 1083 | `e51532785abd7c74e4c4ead659889681742b9cfb7401ebeb88e5e9a112d4b7da` |
| `P041-DB-after-B-block.json` | 966 | `a722eabdf3ddf12383c26b85fc22a7349267f46525661fc33bbfe23c80f32e12` |
| `P041-DB-baseline.json` | 324 | `3156fcf6b7eb08fa74553bc64f3ca8f09c3659d60eae95f6144f77a54bf3afc4` |
| `P041-DB-before-block.json` | 716 | `85d4d194aa30e07863030fcba97e2403257cca393239064f941bf8200ecd876c` |
| `P041-DB-buddy-matching.json` | 165 | `85d7a352a48165a528061446889ef8f31cfa2222fad870a7c66ef91960d0884f` |
| `P041-DB-idempotency.json` | 443 | `efe36ee2068c289c4666a3c84df6ceb34fb88c706262b90f7be520011acfc992` |
| `P041-DB-profile-natal.json` | 437 | `7bd1ba3e998ea8b177ef15705cbff0dc5d9aa85e0afce29aacda3593dbec79b9` |
| `P041-fault-proxy-stop.log` | 29 | `688211767a5c44c7521c828540a621fed0efbd275e92348a5d807ca00609bb89` |
| `P041-fault-reverse-restore.log` | 44 | `9c550ec89a250435a75f7b56e96f8a29a605fdb9df2d609db3ee74e4ffee09d3` |
| `P041-fault-reverse-swap.log` | 44 | `06b62e708e496d9b0cf53c52d2ab254d272e0bc4bbaf912cb0b3474761e51b9a` |
| `P041-final-readback.log` | 178 | `23b6d411c319343710569622472beaba06eab321494a0c49ee14ce8ca1d35591` |
| `P041-FIXTURE-ONLY.png` | 93 | `4baf8036df1c2a5a44a6a94f290a3069a4af37e93672d1bd594593409c8dc06d` |
| `P041-friend-fixture.log` | 164 | `24ab4b8a9d3c465d82187c991383bfa6a8581dd41195472e597ba1765f81be7e` |
| `P041-media-host-seed.log` | 392 | `d72817c64a6566087bc98c85d20e19500a2e01538688e5803852590fee8318e2` |
| `P041-message-seed.log` | 178 | `5d7475c19220a52b911ff9c30af94c77ff39aa22e2d3e900a6ba18de5b8c6f5c` |
| `P041-negative-matching.log` | 195 | `279b81ec2b2162ab8f2f2639ef8631353a1363dc1474fb48dde2661cae5a008e` |
| `P041-picker-deferred.log` | 101 | `468d289da53ec12ccf4a34ad58b628aa2817cb3041eea8d4ec968ad7d00be7e0` |
| `P041-resume.log` | 148 | `c9f7800f362d6d7ca2062f4f80a58ec42fc909d90e2fbff3a2e4ba92b8344656` |
| `P041-reverse-final.log` | 57 | `4420ce8326902775797673621c664e24a6439d95ba5a6db66540cb8e996ca39a` |
| `P041-URI-map-cold.log` | 113 | `fa7350b53f412e08d783a5d357d89f0312386bd17556b5daa598d0c50558769c` |
| `P041-URI-map-cold.png` | 97004 | `48f46efe9e5109a6c022dde703eb5d82b7250777514e80f29c126d62fbfaa5a6` |
| `P041-URI-map-cold.xml` | 3362 | `adb6b0852311d4267b3bf36aecfc93bb1e39b4038fd5f500049fe97a2c766abb` |
| `P041-URI-map-peerId0-hot.log` | 216 | `9750c60851cbe2939e4b3784632adc91b553a63211a6475ecf3678e02330b427` |
| `P041-URI-map-peerId0-hot.png` | 278208 | `3e854d0cdd648eddfeea9d5b51d5edc218598752f2bf0e85a745cd70cc72bdb0` |
| `P041-URI-map-peerId0-hot.xml` | 16226 | `da98835e63242267da859cbf3d8f64f4c08a338e9406e5bf7b7012c62613417a` |
| `P041-URI-notice-cold.log` | 12 | `33c8a62c14c543669012b62944d23be4a630f4c61e53c1bf87dd1ee4140c1f22` |
| `P041-URI-postblock-hot.log` | 12 | `33c8a62c14c543669012b62944d23be4a630f4c61e53c1bf87dd1ee4140c1f22` |
| `P041-URI-unregistered-hot.log` | 175 | `e72e16a3c73471aa9d5ff0581a5f5db7aa309c9fad7a6cd6c8046c3895ff1ba2` |
| `P041-URI-unregistered-hot.png` | 278208 | `3e854d0cdd648eddfeea9d5b51d5edc218598752f2bf0e85a745cd70cc72bdb0` |
| `P041-URI-unregistered-hot.xml` | 16226 | `da98835e63242267da859cbf3d8f64f4c08a338e9406e5bf7b7012c62613417a` |
| `photo-fixture.log` | 134 | `c92bdb65e2a387490009f354030a5c82c0146ac6265e786f6ac9bb6bef1441b9` |
| `reverse-close-01.log` | 57 | `4420ce8326902775797673621c664e24a6439d95ba5a6db66540cb8e996ca39a` |
