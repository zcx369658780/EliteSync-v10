# EliteSync V2｜P0.4.1 1011806实机验收与异地共享Beta环境决策准备

日期：2026-11-21。状态：`P0_4_LOCAL_SCOPED_ACCEPTED / OWNER_AUTHORIZED_1011806_INSTALL_ON_PREVIOUSLY_USED_DEVICE / DEVICE_E2E_PENDING / SHARED_HTTPS_OPTION_PACKAGE_PREP / REAL_ADMIN_DATA_GATE_PENDING / NO_CLOUD_WRITE_OR_PURCHASE / CLOSED_BETA_NO_GO`。

依据：
- [Codex P0.4 Hardening报告](https://github.com/zcx369658780/EliteSync-v10/blob/f41f25bb8c237f8479b998e82e843f528397e1fa/docs/versions/v2/cloud-r0-20261121/V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md)
- [顾问P0.4限定验收](../../workflow/V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_ADVISOR_ACCEPTANCE_20261121.md)
- [旧管理员恢复Beta硬门决定](../../decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md)
- [Owner 1011806单设备安装与实机测试授权](../../decisions/OWNER_V2_ANDROID_1011806_DEVICE_INSTALL_AND_P0_4_TEST_AUTHORIZATION_20261121.md)

## 0. 已接受与当前固定事实

- 开发分支`codex/v2-function-completion-20261121`固定报告`f41f25bb8c237f8479b998e82e843f528397e1fa`，源代码提交`00ca46f6b020afa25ce472509c2fd3227f74c461`，从前一报告`0fd75198db3067782241b6777054050ac2af6918`ahead2/behind0。
- P0.4本地Flutter 72项通过、Dart分析无问题；PHP扩围60/61、唯一失败按既有基线FAIL保留。不要重跑/重做已经具名接受的本地流程。
- 本地HTTPS/MariaDB已覆盖双向Block、历史媒体受众、旧链接撤权、消息/Block/Buddy提交后丢响应读回。设备Photo Picker、缓存清除、无线弱网、外部URI、前后台组合仍待。
- 两名虚构管理员的Ed25519签名恢复和回滚，PHP管理员定向12项/123断言通过。真实管理员候选为0，真实数据没有读取或迁移。
- 1011806候选包身份：`com.elitesync.v2functionp04`，versionCode1011806，versionName`10.1.18-v2-function-p04`，APK SHA256`3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`，v2证书SHA256`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，Flutter AAR SHA256`b81774a1730c0835161ee443625493c93c006543192c7b4beffe83afb36466aa`，TLS证书SHA256`41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。
- 1011806 API为本机`https://127.0.0.1:18444/`，需本机ADB reverse；它不是共享Beta服务器APK。1011806包名不同于1011805，可并行安装；此前1011805授权本身不自动覆盖新包，但Owner已另行作出1011806明确安装决定，见本任务第1节。

## 1. Owner授权状态：已授权，直接执行设备步骤

Owner于2026-11-21在当前会话明确授权：

“好的我同意授权Codex在此前那台Android设备上安装1011806，并完成上述P0.4实机测试。”

授权正式记录：[Owner 1011806单设备安装与实机测试授权](../../decisions/OWNER_V2_ANDROID_1011806_DEVICE_INSTALL_AND_P0_4_TEST_AUTHORIZATION_20261121.md)。

因此：
- 当前有效状态为`OWNER_AUTHORIZED / DEVICE_EXECUTION_PENDING`；不再保留安装等待门。
- Codex不得再次询问是否允许安装1011806或执行本任务。
- 仅允许此前安装并测试1011805的同一台实体Android设备（上一轮记录Android16/API36）。用本机私有ADB记录核对原设备serial；完整serial不得写入GitHub。若设备不在线/身份无法核对/多台无法唯一匹配，停止安装并提出最小设备识别问题，不换设备或模拟器。
- 安装前核实APK实际文件、209,094,076字节、SHA256、签名、包名、versionCode、native/Dart endpoint和TLS证书与本任务第0节固定值一致；任一不符STOP。
- 将`com.elitesync.v2functionp04`作为独立新包并行安装，保留1011805及其数据。不得卸载、覆盖、降级1011805，不清理设备数据。
- 使用合成账号/合成图片。只采集EliteSync应用截图和相关脱敏logcat，不访问私人照片、联系人、短信或其它App数据。
- 允许建立本轮ADB reverse；结束时只撤销本轮新建的映射，不用`reverse --remove-all`。
- 本授权不包含云端访问、真实管理员数据、阿里云写入、费用采购或封闭内测。

## 2. 1011806实体设备测试

Owner授权已具备，无需等待新的许可。新包应作为独立并行应用安装，保留1011805及其数据。测试仅限上述同一具名实体设备和合成账号。

### 2.1 启动与基础链路
- 安装后读取PackageManager包名/versionCode/signature并从手机拉回base.apk重算SHA256，与构建候选一致。
- 核原生和Dart均指向`https://127.0.0.1:18444/`，证书指纹一致；ADB reverse建立/撤销和失败恢复有日志。
- 登录、退出、切号、冷启动、前后台恢复、三盘入口与资料页回归。不得连接真实阿里云。

### 2.2 Block与消息UNKNOWN
- A→B、B→A、重复Block；确认端上Block写入、响应丢失后只读核对、旧对话正文/媒体/通知/通话/发送控件失权。
- 已有消息提交后丢响应：独立fresh GET命中原client_message_id时不再POST；GET失败保持UNKNOWN；GET成功未命中时复用原key，服务端同key去重只产生一条消息。
- 无线网络实际断开分别覆盖请求前、服务端提交前、服务端提交后响应丢失和读取中；不能以USB reverse完全断开替代无线网络测试。
- 切号、Block、后台/恢复和冷启动不得恢复旧私密内容；设备缓存缩略图与草稿需核验。

### 2.3 媒体与历史受众
- 使用专门生成的合成PNG/JPEG，实机Photo Picker选择、上传、服务端源字节读回、预览和缩略图。
- SELF/FRIENDS分别测试本人、原好友、新好友、退出好友关系、Block双方的当前与旧媒体URL；旧链接/缓存不得绕过服务端授权。
- 验证错误MIME/损坏文件、头像revision冲突、上传响应丢失和重试。
- 不使用Owner私人相册或同事私人照片。

### 2.4 URI和通知
- 验证Android对外intent只有预期地图回调`elitesync://map_pick`；测试外部伪造peerId、过期/跨账号/Block后链接及冷/热启动。
- 验证内部通知跳转仍由服务端当前权限重验，不以外部initialRoute或旧通知恢复已失权对象。
- 记录A12证据；若外部URI按设计应拒绝，则验证拒绝行为，而非强行要求业务深链可打开。

### 2.5 交付
- 同版1011806 APK、手机拉回APK、签名/SHA、设备/Android版本、截图、脱敏logcat、ADB reverse记录和后端HTTPS/MariaDB事件索引。
- 每项标`PASS/PARTIAL/FAIL/NOT_RUN`；首试失败保留，不覆盖日志。
- 更新操作手册A10媒体/A12 URI和设备步骤；W01–W04后台截图若没有同版Web后台设备入口则另标NOT_RUN。
- 完成后等待顾问集中验收，不自动转封闭内测。

## 3. 异地共享HTTPS环境决策准备（只读/方案，不部署）

目标是让Owner和同事从不同地点使用同一V2测试后端；本地ADB reverse不能替代共享环境。

### A. 现有上海阿里云实例
- 旧现场历史证据：2vCPU/2GiB、空闲内存约627–628MiB、swap0、根盘约24GiB可用；旧Laravel/MariaDB/Redis/LiveKit共驻。
- 当前同驻容量仍`NOT_APPROVED`。没有新Owner授权前，不进行SSH、容量采样、服务重启、配置更改或云写。
- 若Owner另行批准只读容量核验，先采至少一个旧业务日峰值和备份窗口：CPU/RAM/OOM、磁盘I/O/空闲空间、MariaDB连接/慢查询、Redis内存、LiveKit并发/丢包、80/443/8088端口与旧站错误率。不得读取真实用户行。
- 建议门槛仅作初筛：CPU p95≤70%；可用内存≥V2实测峰值预算×1.25；无新增OOM/持续swap；磁盘保留≥20%且可放置独立可恢复备份；旧站p95增长≤10%、错误率和通话质量无回归。阈值不代替实测。

### B. 独立上海Staging
- 报告公开参考为2vCPU/4GiB/50–60GiB SSD，阿里云轻量公开参考70元/月或379元/年活动价；账号实际上海库存、活动资格、续费、税费和套餐带宽均未核。不得将公开参考当成Owner实际结算价。
- 需提供同周期月付/年付总价、系统盘/数据盘、EIP/带宽/流量、快照、域名/TLS、VPN/访问限制、备份保留、停机后留存与续费价。ECS另列EIP、系统盘、快照和公网流量。
- 任何购买、创建实例、开公网、改DNS/防火墙/443、域名切换和新增费用均等待Owner明确批准。

### C. 共同安全架构
- 独立V2 FPM/worker/MariaDB/schema/数据库账号/媒体卷/应用密钥/session和私有ADMIN_PHONES；DB/Redis/FPM不公网开放。
- APP API使用可信TLS和受限访问；Web管理和激活入口额外限制来源/VPN；Android native/Dart endpoint一致且不回退旧站。
- 先合成账号远程联测、备份恢复演练、迁移回滚、负载和停止回滚，再允许真实管理员迁移。
- 真实旧MariaDB行读取/备份解密/真实V2写入另需Owner一次性数据授权；云部署/费用另需Owner云写授权，两个批准不能互相替代。

## 4. 真实旧管理员身份恢复准备（不读取真实数据）

- 保持原手机号登录标识、V2新user ID、新V2密码激活；不迁移旧密码hash/token/session/MFA/API key。
- 真实候选数量当前UNKNOWN。每人必须由具名人员私下核验旧账号enabled、旧admin名单命中、原手机号当前持有人控制、职责和Web后台必要性；公开报告仅使用不可逆代号。
- 使用Ed25519签名私有清单，签名绑定来源快照、目标数据库身份、字段白名单、候选/角色、operator、时效和holder proof；批准号一次性消费。
- 真实数据授权包填定来源A现时旧MariaDB快照或B具名五月备份manifest、字段、操作者、目标V2独立数据库、备份回滚、费用、时间窗、持有人证据、签名回执。未经Owner具名批准，不解密、不读取真实行、不写入V2。
- 所有Owner指定管理员必须本人从外地用原手机号+新V2密码登录APP；获准Web管理员本人登录Web。未完成任何一人均不能申请封闭内测。

## 5. 下一次集中交付

提交一份中文报告：
1. 1011806设备实测逐项矩阵、APK拉回身份和日志hash；
2. 媒体、受众、Block、UNKNOWN、外部URI和无线网络故障证据；
3. 操作手册A10/A12及同版截图；
4. 共享HTTPS A/B选项真实费用和容量证据，明确Owner待决；
5. 真实管理员数据授权包空白模板/签名配置状态/候选代号数（不含PII）；
6. 当前P0.4 PHP基线失败与旧全量失败账；
7. Beta准入硬门和NOT_RUN。

## 6. 严格禁止

- Owner已授权安装1011806：在完成APK身份与设备核对后直接并行安装；不得卸载/覆盖/清理1011805或清除设备数据。
- 不卸载或覆盖1011805；
- 不用真实管理员账号或真实用户个人数据做设备测试；
- 不读真实旧管理员行、不解密备份、不写真实V2库；
- 不SSH/部署/采购/开公网/改DNS/防火墙/443，不产生云费用；
- 不将1011806回环APK作为共享服务器包；
- 不合main、不申报软著、不招募同事开始封闭内测、不发布生产版本。
