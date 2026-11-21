# EliteSync V2｜P0.2 MariaDB正式关系合成闭环 + Android单设备验收准备

日期：2026-11-21。执行依据：[Owner功能优先](../../decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md)、[P0上一批固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/6e3f52522033da04bc84d0c291d11d13f2dff36d/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_CANDIDATE_CLOSURE_REPORT_20261121.md)、[顾问独立复核](../../workflow/V2_FUNCTION_P0_CANDIDATE_CLOSURE_ADVISOR_REVIEW_20261121.md)。

状态：`P0_LOCAL_SELECTED_PASS / MARIADB_SYNTHETIC_RELATIONSHIP_POSITIVE_NOT_RUN / ANDROID_ARTIFACT_FIXED_DEVICE_OWNER_GATE / CLOSED_BETA_NO_GO`。

## 0. 固定基线和限制

- 本轮固定源码`36ae37206f482109e0bfc7a0f95335fc056da323`，综合报告`6e3f52522033da04bc84d0c291d11d13f2dff36d`，开发分支`codex/v2-function-completion-20261121`。起手先核实际本地工程root/origin/branch/HEAD/index/dirty；保护原脏main/IP13I/S1/治理树/历史9.1C/原始证据，不reset/clean/覆盖。
- 复用`elitesync-v2-function`本地专用WSL MariaDB10.11.19，schema`elitesync_v2_function`，host`r0-db`，DB user`elitesync_function_app`，port3306，server_id2621121，APP_ENV=staging，回环HTTPS18444。执行前重新跑db-preflight并确认唯一正确实例、卷、端口、测试容器；不得连阿里云旧MariaDB、历史9.1C或旧业务。
- 本地APK固定：`com.elitesync.v2functionp0` / `10.1.18-v2-function-p0` / 1011805 / APK SHA256 `d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`。native与Dart均固定`https://127.0.0.1:18444/`，TLS cert SHA256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`，Debug签名仅本地测试。任何APK源码/构建配置改变需重建新版本并重算身份，不能沿用旧hash。
- 本轮允许既定本地隔离合成工程；**不授权**真实KYC、真实用户资料、阿里云/新服务器写入、真实管理员数据、采购费用、外部供应商、真实设备安装/读取，除非Owner另行具名批准。设备操作先停在`DEVICE_OWNER_GATE`。

## 1. F1｜MariaDB上受限TEST_ONLY身份与正式匹配/Relationship正向链

### 1.1 现状必须保持准确

- `TrustedIdentityService::participationAllowed()`目前只在`APP_ENV=testing + SQLite :memory:`且HMAC签名有效时放行；正式环境没有真实身份provider。
- 当前V1017正向链确实覆盖轮次→执行→揭示候选→双边接受→独立Connection→Relationship双方确认→Block结束，但正向资格是PHP/SQLite内存TEST_ONLY。
- MariaDB smoke现状为合法好友来源可以创建`PENDING_MUTUAL`，无真实provider时确认403、`test_only=true`。这是预期fail-closed，不要修改成真实身份通过。
- 目标是**额外证明相同状态机在实际MariaDB持久化和HTTP链上可跑**，不是为生产增加测试绕过。

### 1.2 严格隔离的实现要求

优先独立新建MariaDB合成资格组件/适配器，不扩大旧`TrustedIdentityService::sandbox()`旧库范围。所有条件同时满足才启用：
- `APP_ENV=staging`并且固定的本地V2 function build/环境标识；
- 当前DB driver MariaDB，`DATABASE()`、`@@server_id`、`VERSION()`与固定schema、server ID 2621121、MariaDB10.11严格匹配；
- Laravel实际连接配置host=`r0-db`、user=`elitesync_function_app`、port3306，禁用DB_URL/unix_socket替换，核实连接实际身份而不只读env；
- 专用开关默认false，仅`compose.function.yaml`测试环境打开；无该开关、错DB/错server id/错host/错APP_ENV/生产/旧R0数据库均拒绝；
- 双主体均为`is_synthetic=true`、`account_type=test`、固定`synthetic_batch`、active、未禁用，绝不按HTTP客户端传入`test_only`、header、actor_id、verified或credential建立资格；
- 资格只能由本地受控CLI命令为指定合成账号批次签发；HMAC密钥只从本机未跟踪secret环境加载，不进源码、GitHub、命令行日志或报告；签发必须有nonce防重放、有限TTL（建议最多1小时）、revision、签名、issuer、dataset和审计；具备CLI撤销、过期及禁用账号自动失权；
- 不提供任何HTTP/API/Web公开签发入口；不能改全局`APP_ENV=local`，不能改变正式报名/Relationship确认默认拒绝，不准将MariaDB资格提升为正式身份证明或外部KYC。

### 1.3 具名正反测试

在真实MariaDB HTTPS上使用两个合成账号，从合法测试准备上下文开始，走完整链：
1. 当前用户资格、Lifestyle/匹配输入、有效参与、轮次准备、实际matching execute、候选揭示；
2. A单方接受、B单方接受、同键回放、过期/旧revision、退出/改代、资格失效；
3. 独立Connection双方请求/接受；验证Connection本身不自动授予消息同意；
4. Formal Relationship请求、A/B分别确认、active slot、relationship source revision及审计落库；
5. 消息双方同意独立；Block后Relationship ENDED、slot清空、旧Connection/Relationship/消息/通知失权；重复确认、同键冲突与旧深链404；
6. 对非合成账号、错批次、只单方授权、无来源陌生人、禁用用户、错误实例、生产配置、关闭开关及签名过期/篡改，逐项期望拒绝且数据库无越权副作用；
7. MariaDB独立重启后检查迁移、凭据TTL/撤销、关系状态与权限拒绝持久。严禁将SQLite结果复制为MariaDB结果。

所有记录继续明确`test_only=true`，正向结果只代表本地合成DB的状态机集成，不代表真实KYC、真实用户资格或生产可用。

## 2. F2｜Android单台设备验收（Owner设备门之前仅准备）

### 2.1 安装前静态准备

- 从本地私有APK路径重算SHA256、包名、versionCode、证书fingerprint、arm64 ABI和Dart AAR/原生配置；必须与报告完全一致。
- 逐一确认Gradle构建身份、native `BuildConfig.API_BASE_URL`、Flutter `ELITESYNC_API_BASE_URL`、证书SAN与TLS指纹一致。测试APK仅指向回环18444；没有公网/旧站fallback，禁止临时改证书校验或关闭TLS。
- 准备USB ADB回环计划：在Owner批准的手机连接后使用`adb reverse tcp:18444 tcp:18444`，检查手机`127.0.0.1:18444`是否到达本地服务；没有设备授权时不得运行adb install、读取设备标识、截图、导出logcat或操作照片。
- APK为Android Debug签名，只供Owner指定的本地测试，不是公开内测发行包。未来封闭内测候选需另行确认签名、版本、API域名/TLS和后端环境。

### 2.2 Owner授权后唯一测试设备旅程

仅在Owner明确具名授权一台自有测试手机和USB测试窗口后：
- 先备份该设备上既有EliteSync app数据或确认使用独立包名，避免覆盖旧正式APP；不读取无关个人数据；
- 安装前后记录APK hash、包名、版本、签名、ADB reverse与TLS；确认不会访问`slowdate.top`或阿里云旧站；
- 用虚构账号A/B完成登录、刷新/退出/切号、冷启动、本命三盘已知/未知时刻、首页/慢约当前状态、候选可见性与拒绝状态、Connection/双方消息同意/文本发送收取/Block、好友封面/头像、Buddy发现申请/退出、通知与旧深链、断网/恢复；
- 对每个旅程记录APP实际UI、API status、MariaDB持久化、旧入口失权；对相机/麦克风/通讯录/真实照片权限采取最小授权，未经Owner单独许可不读取真实媒体；
- Android真机正反证据未完成前继续`DEVICE_NOT_RUN`，不能拿Flutter 128测试、USB回环HTTP或旧1011804结果替代。

## 3. F3｜软著材料同步准备

- 允许Codex先起草操作手册正文骨架：软件概述、账户/资料/三盘、慢约匹配/候选/关系、Connection/消息同意/私信、社区/媒体/Buddy/通知、Web管理员、权限与安全、异常与退出。
- 建立同一固定版本的截图清单，标记需要Android真机拍摄的页面；在1011805设备验收前不伪造截图，不从不同版本拼接为同一版。
- 建立依赖许可与素材权属索引：`pubspec.lock`、`composer.lock`、Gradle/AAR依赖、三盘notices、图像/字体/音效来源。权利主体、职务作品/委托关系、原创及第三方素材待Owner确认。
- 仅准备材料，不注册申报、签名缴费或声称登记成功。

## 4. 报告与停点

一份中文P0.2集中报告，含：
- 本地MariaDB合成issuer的精确隔离条件、正反测试、DB持久和重启证据；
- SQLite TEST_ONLY与MariaDB TEST_ONLY分层；真实KYC仍BLOCKED_EXTERNAL；
- 当前APK hash/签名/双端endpoint，设备操作若未获Owner许可明确NOT_RUN；
- 若设备获批，按真实UI/API/DB/撤销形成具名旅程矩阵；
- PHP精选12项历史对照、全量旧失败和A/B/C/T0状态不重写；
- 软著手册正文、同版截图、依赖/权属清单及封闭内测仍缺门；
- 固定非main开发commit和脱敏日志SHA。

PC清理不再做；不操作阿里云旧站/旧数据库/备份、不恢复真实管理员、不采购资源、不合main、不申请软著、不公开招募或开启内测。
