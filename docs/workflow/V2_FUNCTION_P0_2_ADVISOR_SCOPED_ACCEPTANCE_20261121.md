# EliteSync V2｜P0.2 MariaDB关系闭环与Android主机预检顾问限定验收

日期：2026-11-21。结论：**`P0_2_MARIADB_TEST_ONLY_E2E_ADVISOR_SCOPED_ACCEPTED / ANDROID_HOST_PREFLIGHT_CODEX_REPORTED_PASS / OWNER_DEVICE_AUTHORIZATION_GRANTED / DEVICE_INSTALL_AND_JOURNEY_PENDING_EXECUTION / OPERATION_MANUAL_DRAFT_ACCEPTED_AS_DRAFT / CORE_FUNCTIONS_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**。

## 1. 固定证据

- 固定源码：[362abd618a1f670e313b365b60b5dfe1f6ab71b8](https://github.com/zcx369658780/EliteSync-v10/commit/362abd618a1f670e313b365b60b5dfe1f6ab71b8)
- 固定报告：[daa96756f96fb6fd62845323ebd3c53d2b2438d2](https://github.com/zcx369658780/EliteSync-v10/blob/daa96756f96fb6fd62845323ebd3c53d2b2438d2/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_2_MARIADB_RELATIONSHIP_AND_DEVICE_REPORT_20261121.md)
- 手册初稿：[ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md](https://github.com/zcx369658780/EliteSync-v10/blob/daa96756f96fb6fd62845323ebd3c53d2b2438d2/docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)
- 开发分支`codex/v2-function-completion-20261121`的远端HEAD回读为报告SHA；相对P0源码`36ae37206f482109e0bfc7a0f95335fc056da323`ahead3/behind0；本轮固定源码相对P0.2任务范围含既有P0报告、MariaDB fixture service/CLI/compose、HTTPS烟测、Android设备脚本等。报告固定后仅新增报告和手册文件。
- 顾问直接读取固定报告、手册、`MariaDbFixtureIdentity`、CLI command、`SyntheticConnectionScope`、`TrustedIdentityService`、`FormalRelationshipService`、`compose.function.yaml`、`function-relationship-smoke.py`及`v2-function-1011805-device.ps1`。证据等级`ADVISOR_SOURCE_SPOTCHECK`；Codex运行回执和原始日志SHA均`CODEX_REPORTED`，顾问未在本地复算PHP日志、Docker状态或APK二进制。

## 2. MariaDB TEST_ONLY：限定接受

### 2.1 源码安全边界抽查

- `SyntheticConnectionScope::targetsFixtureRuntime()`要求`APP_ENV=staging`、固定`APP_URL=https://127.0.0.1:18444`、driver MariaDB、DB`elitesync_v2_function`、user`elitesync_function_app`、host`r0-db`、port3306、无DB URL/socket替换；`matchesDatabase()`还读实际`DATABASE()`、`CURRENT_USER()`、`@@server_id=2621121`及MariaDB10.11版本。
- `MariaDbFixtureIdentity::key()`要求专用默认关闭开关、runtime`local-v2-function`、数据库identity match和只读挂载secret`/run/secrets/v2_function_identity_key`。key文件必须恰为64位hex；签名绑定issuer、dataset、数据库、server_id、用户、nonce、revision、起止时间。
- 资格限定`is_synthetic=true`、`account_type=test`、固定`synthetic_batch=v2-function-match-qa`，且用户active/未禁用。签发只能CLI且1–60分钟TTL；nonce唯一；撤销更新revision、撤销记录和审计。MariaDB适配器无HTTP签发入口。Smoke专门检查公开假签发路由404、错环境/错DB/错server ID/错host/user/port、错batch、disabled/ordinary、签名篡改、重复nonce、过期与撤销拒绝。
- `TrustedIdentityService::participationAllowed()`仅在测试SQLite内存或`MariaDbFixtureIdentity`严格本地实例匹配时允许签名合成资格。正式provider状态仍PENDING，身份status仍`test_only`，`formal_participation_available=false`。FormalRelationship写入`test_only=true`。此适配器绝不代表真实身份、KYC或正式生产准入。
- Compose只把secret挂入专用app服务，DB与FPM无宿主端口，HTTPS只有loopback18444；报告称独立server_id探针2621122拒绝CLI签发。源码约束充分支持限定验收，未来任何正式部署或合main前仍须重新审查配置默认值和部署隔离。

### 2.2 Codex报告具名运行结果

报告回执：MariaDB10.11.19、本地专用WSL Docker，116表，92条迁移；85条主要HTTP状态+23次CLI回执，另33条提案到期/停用HTTP状态+5次CLI回执；定向PHP127项/1,587断言0失败；仅MariaDB重启后状态/消息/通知/Block/撤销审计读回。报告日志SHA已列在原报告。上述全部标为`CODEX_REPORTED_LOCAL_MARIADB_E2E`。

接受范围：
- 合成报名→真实matching consumer→候选发布→双边决定→Connection→双方消息同意→文本消息持久化/读回→Formal Relationship双边确认；
- HMAC签名篡改、TTL、nonce replay、撤销、停用、错批次、普通账号、错误环境/DB identity拒绝；
- 撤销后Relationship`SUSPENDED_REVERIFY`，新凭据不能自动激活，须双边再确认；
- Block后关系`ENDED`、slot清空、旧Connection/消息/对方资料404、通知最小历史投影；
- MariaDB独立重启后持久化状态和审计读回。
- 定向127项包括上批46项及原12项；不是PHP全量PASS。

未接受或未完成：
- 真实KYC、真实账号/Relationship、Push、RTC、法定删除受理、生产服务器均BLOCKED_EXTERNAL/NOT_RUN。
- PHP/Flutter全量本轮NOT_RUN，旧Q全量46errors/122failures、旧排盘25、R1 Flutter扩围5 FAIL和1011804历史状态不改写。
- 当前Android设备安装与用户旅程仍NOT_RUN。

## 3. Android 1011805：主机预检回执，设备尚未执行

Codex报告固定：
- APK`com.elitesync.v2functionp0`，`10.1.18-v2-function-p0 / 1011805`，arm64-v8a，209,094,024 bytes；
- APK SHA256`d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`；
- Android Debug v2证书SHA256`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`；
- TLS证书SHA256`41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`；
- 原生+Dart均固定回环HTTPS`https://127.0.0.1:18444/`。
- Codex称PowerShell主机预检exit0，固定APK/签名、TLS证书与访客401通过，ADB platform-tools reverse/no-rebind能力可用。顾问未下载APK复算hash或本地执行脚本。
- 设备序列号、USB ADB reverse、安装、设备读写、截图和logcat均NOT_RUN。脚本`Host/Reverse/Install`分段执行，要求设备serial与Owner authorization reference；拒绝emulator；安装前如发现同包已安装即停止，禁止覆盖。该包为Debug测试工件，仅适用USB reverse本机服务，不是公网封闭内测发行包。

### Owner授权更新（优先于报告中的旧门禁文字）

Owner在本轮报告提交后已明确回复：“好的我确认授权，下一轮可以实机检验，设备就绪。”这项当前会话的具名授权已满足下一阶段**一台指定实体Android手机**的安装及功能验证Owner门。故报告里的`DEVICE_OWNER_GATE / WAITING_OWNER_AUTHORIZATION`已经过时；当前应更新为`OWNER_AUTHORIZED / DEVICE_EXECUTION_PENDING`，Codex不得再重复要求Owner授权。若ADB发现多台实体设备，才需确认选择哪台；若只有一台，直接按本任务执行。序列号只在本机日志使用，GitHub报告需脱敏。

## 4. 操作手册初稿验收

已直接阅读完整手册，覆盖软件概述、账户/资料/三盘、慢约候选/正式关系、Connection/消息同意、好友社区/图片、Buddy/通知、Web管理、异常/退出及A01–A12/W01–W04截图清单；附源码/依赖许可/素材/权属核对入口。

接受为`OPERATION_MANUAL_DRAFT_ACCEPTED`，不是定稿：
- 实机页面和真实可达入口尚未核，尤其「管理正式恋爱关系」、消息/好友/Buddy/通知的页面名称和顺序需与1011805现场一致。
- 当前截图仅计划，不能作为真实截图或软著材料。
- 手册准确说明三盘`COMPUTED_UNVERIFIED`、TEST_ONLY和真实KYC待接、删除受理取决实际渠道。
- Owner权利主体、职务/委托作品关系、第三方素材授权仍未确认。

## 5. 最终判定与下一步

**接受P0.2本地MariaDB TEST_ONLY集成与定向回归限定交付；接受Android主机预检Codex回执；接受手册为初稿。整体核心功能仍PARTIAL，封闭内测NO_GO、生产NO_GO。**

下一批唯一主线是已获Owner授权的1011805实体Android设备安装和真实UI旅程。继续沿用本地专用服务，先核实例/卷并启动，不访问阿里云。检查唯一实体设备并执行ADB reverse、APK安装；保留既有包/数据，不卸载/清空。使用虚构账号及合成素材，完成账号/切号/冷启动/三盘、慢约状态、Connection/消息同意/文本消息、社区图片、Buddy、站内通知、Block和断网恢复。逐项核对UI/API/MariaDB/失权旧链接。只采集EliteSync本应用截图和相关logcat，不读其它App/个人照片/无关通知。仅删除本轮自己建立的`tcp:18444` reverse映射，不用`reverse --remove-all`。同版截图后同步修订手册并准备软著权属确认包。

真实KYC/Push/RTC/法律删除、软著申报、封闭内测参与人招募、main合并、生产云迁移仍须独立门禁。
