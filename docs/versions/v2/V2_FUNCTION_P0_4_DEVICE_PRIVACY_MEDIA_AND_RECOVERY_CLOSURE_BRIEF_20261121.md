# EliteSync V2｜P0.4实机缺口收口：Block端上入口、媒体受众、深链和UNKNOWN恢复

日期：2026-11-21。状态：`P0_3_DEVICE_E2E_PARTIAL_ACCEPTED / P0_4_LOCAL_REMEDIATION_AUTHORIZED_WITHIN_EXISTING_SCOPE / CLOUD_BACKEND_NOT_CONNECTED / LEGACY_ADMIN_NOT_RESTORED / CLOSED_BETA_NO_GO`。

依据：[P0.3顾问限定验收](../../workflow/V2_FUNCTION_P0_3_ANDROID_DEVICE_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)、[P0.3固定实机报告](https://github.com/zcx369658780/EliteSync-v10/blob/651f3dea30cb6744d6a3863e5d9f7a921ca7ae43/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_3_ANDROID_1011805_SINGLE_DEVICE_REPORT_20261121.md)、[Owner功能优先决定](../../decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md)。

## 0. 本轮结论和服务端状态必须继承

- 本轮实机Android 16、1011805从手机拉回安装包身份核对通过；P0.3报告/手册/hash索引已固定于`651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`。
- 当前本机专用Compose`elitesync-v2-function`、MariaDB`elitesync_v2_function`和两个卷保留运行，ADB reverse已撤销。
- **阿里云V2后端尚未打通；真实旧管理员账号没有恢复。** 不因P0.3实机PASS推断云端连接或账号迁移。Cloud R0的G1云Staging、G2真实管理员恢复、G3云端Android仍NOT_RUN。
- Owner优先级为核心功能→软著材料→另行批准封闭内测→之后再考虑换服务器。当前任务只做本地功能修复与必要本地验证，不启动云端部署/管理员恢复/PC清理。
- Owner此前授权范围是1011805在一台实体手机上的实测。**新源码需要重建新APK时，不自动沿用旧1011805安装授权去覆盖/卸载/清数据。** 先完成本地修复和新包身份固定；若需要安装新版本，再向Owner提出一次明确的新版本/设备替换请求，保留当前1011805。

## 1. P0｜端上Block入口与失权UI（最高优先）

P0.3缺口：
- 对话页没有可用Block写入口，Block由主机API施加；
- 失权后正文会消失，但发送/媒体控件仍显示，写操作未触发。

任务：
1. 找到当前对象详情/会话菜单和既有`POST /moderation/blocks`业务合同，提供清晰、可确认的端上Block入口；禁止另造不一致的客户端本地block事实。
2. Block动作应幂等、处理响应UNKNOWN时重新查询服务端权威状态，成功后立即清空本地敏感投影、消息正文/附件/对方资料，刷新通知与关系状态。
3. 当Connection/MC/Block/账号/会话资格失效或读权限404时，隐藏或禁用发送、媒体、附件和重试控件；不得仅隐藏消息文本而仍显示可写操作。
4. 切号、退出、冷启动、前后台恢复和网络恢复后重新核验；旧深链只显示不可用/最小历史投影。
5. 正反例：A拉黑B、B拉黑A、重复同键、撤销/取消策略若产品已有定义、请求中断UNKNOWN、Block后对方旧链接、重登录/新设备旧缓存。服务端与客户端必须一致。

## 2. P0｜社区图片、头像和历史媒体受众

P0.3只完成文字作品，图库虽打开但未选图、未上传。
1. 用专门生成的合成PNG/JPEG，不使用Owner私人照片；确认系统Photo Picker仅选指定测试文件。
2. 实机验证头像、作品封面/图片上传、缩略图与原始字节读回、格式/MIME/尺寸错误、修订冲突和失败重试。
3. 分别验证SELF、FRIENDS受众；A发布后再改变好友关系/新增好友/Block/退出，核对旧媒体URL当前授权和原受众。任何缓存不得绕过服务端权限；敏感图像响应需private/no-store。
4. 验证Android缓存/缩略图/图片预览在失权后清除，冷启动与旧链接重新验证。
5. 视频、聊天附件、音频若当前范围没有实现，明确列为未实现/外部依赖，不借图片测试PASS冒充。

## 3. P0/P1｜外部URI深链与网络写入中断/UNKNOWN恢复

- 识别App真实intent-filter、App Links/URI路由及通知跳转合同；构造仅本地合成的URI，验证当前/过期/被Block/跨账号对象，拒绝外部伪造peerId或绕过受众。不得引入真实域名流量或云服务。
- 用本机代理/可控故障注入在**写入前、服务端提交后响应丢失、客户端等待中、读取中**断开请求；对注册/资料/Block/消息/Buddy/提案选择等幂等命令分别测试。结果未知时必须先按幂等键/权威读回查询，不盲目重发，不生成重复消息/作品/申请。
- 区分P0.3已通过的USB reverse完全断开38秒（仅运输链路恢复）和真正的写入途中断网；新证据不能互相替代。
- 将`POST /telemetry/events 422`的字段/合同/服务端验证错误脱敏定位；修复合法事件或明确客户端错误，不能吞错或把telemetry状态伪装业务成功。

## 4. P1｜关系状态文案、截图索引和操作手册

- 正式关系已双确认的页面当前文案为“已参与”，与正式关系语义不符；TEST_ONLY演练必须同时清楚显示“测试数据/非真实身份”，正式关系状态文案应准确表达ACTIVE/待双方确认/暂停/结束。
- P0.3截图索引A05的本地文件名记录为`A04-matching.png`，先核对实际文件及哈希引用，修正索引或解释，不改截图原字节。
- A10当前文字作品，媒体版待补；A12外部URI深链待补；W01–W04 Web后台截图未采集。所有截图绑定源码/服务端commit、APK SHA、设备和页面入口。
- 操作手册只记录实测入口。新增Block/媒体/深链后，按同一版重新采集必要截图并更新手册。
- 依赖许可、素材来源和权属资料继续准备，不自动提交软件著作权登记。

## 5. 验证要求与交付

- 先用现有本机MariaDB+HTTPS跑后端/Flutter具名测试；不触碰阿里云。测试容器/卷先核身份，禁止`down -v`和全局清理。
- 任何新APK都要重新固定包名、versionCode、签名证书、APK SHA-256、原生/Dart API base URL和TLS证书；无Owner新版本安装授权前，不在设备上覆盖/卸载/清数据。
- 只交一份P0.4中文综合报告：P0.3缺口逐项DONE/PARTIAL/FAIL/NOT_RUN；Block端上正反、媒体字节/受众、深链、写入UNKNOWN、telemetry 422；新包身份及Owner设备门；更新后的手册/截图索引；PHP/Flutter具名测试和旧全量FAIL账；软著材料与封闭内测剩余条件。
- 保留P0.3报告及原始证据不变，新增报告引用它，不重写已通过的事实。
- 完成后仍为`CORE_FUNCTIONS_PARTIAL`，是否进入封闭内测由Owner另行集中决定。阿里云部署、真实管理员账号恢复、真实KYC/Push/RTC、法定删除受理、正式A6、main合并和发布均不属于本任务。
