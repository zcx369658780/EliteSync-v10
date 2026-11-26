# EliteSync V2｜M1 三盘正式保存与读回

2026-11-26，北京时间。任务 `V2-M1-NATAL-SAVE-READBACK-20261126`。本报告的工程结论限于下列具名环境。网页 GPT 顾问集中验收 `PENDING`，Owner 实体终验 `PENDING`。总体 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。

## 工程与运行身份

| 项目 | 读回 |
| --- | --- |
| 活动工程 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，origin `zcx369658780/EliteSync-v10` |
| 开工 HEAD / tree | `2593a079894cb381ed9ad70b2e50977c240d25c0` / `7d5b34efe34f214eee9cc0ea5ac76523971c5310`。开工工作树、index 皆干净。GitHub 分支引用与开工 HEAD 相同。 |
| 工程证据源码 / tree | `242c5b6cea419297a05a4851dccd837050e1b7ae` / `ee2dc2a8a8d2cd97e69e621dd2290298311725da`。上一轮固定顾问证据 `23d4ff5de54398a58320ec078e5f2e14fd610163` 保留。 |
| 脏 main | `D:/EliteSync-v10` 的 `4bebc8f394248e254c1368a06fbdee5d2c883301`，43 条未暂存修改、213 条未跟踪状态、暂存区空。只读检查。 |
| 实体候选及共享 Staging | 25060RK16C 上次安装读回 `com.elitesync.v2stagingremote / 1011814`，APK SHA-256 `37b9d370dda05f737cdd5e367d12267e3572220120edd6a27ec7710d8aec18d4`。本轮复核存档 APK 和安装回执哈希。已存 Staging 应用镜像 `sha256:7019922fee8a108895614faae87a1b897c9c678deb1147d334a5a0921dab1f39`。本轮联网或实体身份读回另见验收段。 |
| 本地 Android | 独立 AVD `elitesync_m1_20261126`，Android 36.1，arm64 转译。仅合成联调，复用已有本机包标识 `com.elitesync.v2functionp042r1 / 1011807`，APK SHA-256 `22c57ea6a65842a7cadff36007a64dea180aad680fecbabb87f921f40ddadd5c`。通过 ADB reverse 连接固定信任证书的宿主回环 HTTPS。 |
| 本地后端与持久库 | PHP 8.5.3、Laravel 13.39.0，专用 Windows MySQL 9.6.0，server ID 2626126，新建库 `m1_natal_20261126`，121 表，监听回环，使用虚构账号。副本来源为开工归档加最终控制器，应用代码由本地代码身份覆盖。另起本地端口模拟依赖不可用。 |

[上轮顾问材料](V2_P0_P1_ADVISOR_FOLLOWUP_20261126.md) · [1011814 部署、APK 与实体回执](V2_NATAL_MANUAL_BAIDU_20261126.md)

## M1-01｜源码、API 与结果生命周期

| 链路 | 现行行为 |
| --- | --- |
| 基础资料导入 | `GET /api/v1/profile/basic` 用当前登录主体读取 `users.birthday` 及 `private_birth_time/place/lat/lng`。Flutter 的 `ProfileDetailDto` 和坐标解析器接受数值或有效数值字符串。导入只补空草稿，成对坐标须由用户确认 WGS84。 |
| 写入与重读 | `POST /api/v1/profile/natal` 接收 `input/settings/expected_revision`。控制器逐项校验公历日期、当地时间、精度、IANA 时区、DST 折叠与坐标；锁定 `users.id` 串行化该主体首次写入，事务内归档旧版本并保存新输入为 `COMPUTING`。计算在事务外执行，按行 ID、输入版本及签名约束结果写入。客户端读回新版本和签名一致后才显示成功。 |
| 八字 | `NatalBaziCalculator` 使用已核定年月节令、日时分界及可选真太阳时。结果在 `results.bazi`，包含 `status`、四柱及条件允许的运限。传统算法性别单独选择。 |
| 紫微斗数 | `tools/natal/ziwei.mjs` 使用已核定的民用或有效太阳日期、时刻、算法性别与目标年。结果在 `results.ziwei`，包含 `calculation_status`、宫位与星曜；缺时间或相应前提可为 `UNKNOWN`。 |
| 西洋占星 | `tools/natal/western.py` 使用统一时间上下文、可选 WGS84 及计算设置。结果在 `results.western`，包含 `calculation_status`、行星、宫位、四轴与相位；空坐标时可计算行星，四轴与宫位不可用。西盘的时间上下文也供八字链路，真太阳时启用时由同一上下文提供有效时刻。 |
| 持久化与隔离 | `user_natal_profiles.user_id` 是唯一外键。JSON 列保存 `input/settings/context/results`，另存 `input_signature/input_revision/result_revision/status`。归档写入 `user_tool_revisions`，由 `user_id/tool/record_id/input_revision` 限定。当前、历史和星盘兼容镜像均按本人权限读取。 |
| 重复、失败与过期 | 当前版本同输入可复用，旧版本提交 409。输入改动会立即清除活跃结果，再提交匹配版本的计算结果。计算依赖失效返回 503，持久输入仍在，结果为 null。代码、规则、tzdb 或运行时身份变化时，GET 派生 `STALE_RECALCULATION_REQUIRED` 并屏蔽旧结果。历史详情会重新校验签名。 |

[Flutter 排盘页](../../../../apps/flutter_elitesync_module/lib/features/profile/presentation/pages/natal_restoration_page.dart) · [Flutter 读取与会话守卫](../../../../apps/flutter_elitesync_module/lib/features/profile/presentation/providers/natal_restoration_provider.dart) · [Laravel 路由](../../../../services/backend-laravel/routes/api.php) · [基础资料 API](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php) · [保存控制器](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/NatalProfileController.php) · [排盘计算](../../../../services/backend-laravel/app/Services/NatalCalculationService.php) · [读回与过期](../../../../services/backend-laravel/app/Services/NatalProfileView.php) · [表定义](../../../../services/backend-laravel/database/migrations/2026_10_17_100010_create_user_natal_profiles_table.php) · [历史作用域](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/ToolRevisionController.php)

原链路的缺口为正式提交前缺少汇总核对，选点来源和层级没有持久化，已由本轮修复。单盘计算产物具有各自状态及 `oracle_status`。运行时异常采取整批 `FAILED`，无部分成功写入，也无逐盘异常码。缺失有效时间、空坐标等受支持的输入则保留相应单盘或子结果的不可用状态。客户端收到 409 后通过显式重新读取收敛。批次因进程中断停在 `COMPUTING` 时，读回版本后可显式重提。自动回收计时器与并发进程中止实测为 `NOT_RUN`。

算法文件、计算依赖锁及规则未改。实际使用 lunar-php 1.4.0、iztro 2.5.8、Skyfield 1.55、CPython 3.11 和 Node 24.14.0。DE440s SHA-256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`，请求运行时身份为 `AVAILABLE`。历史独立样本覆盖按既有说明，整体数值状态仍为 `UNVERIFIED`。 [固定算法与已有参考范围](../../../../services/backend-laravel/tools/natal/README.md) · [原算法验收证据](../../v10.0.10/IMPLEMENTATION_REPORT.md)

## M1-02 / M1-03｜定向验证与输入语义

| 项目 | 结果 |
| --- | --- |
| 定向 Flutter | 53 PASS，涵盖选点、会话隔离、提交后读回比较和三盘渲染。改动文件 Dart analysis 无问题。 |
| 定向 PHP | 合并口径 52 PASS 中计入第二轮补跑的 4 项。首轮运行 52 项，48 通过、4 条需显式运行时路径而跳过。补跑 7/7，含原 4 项与重叠 3 项。PHP 语法通过。Pint 两文件基线已有样式失败，留档。 |
| 独立 MySQL、实际 HTTP 和真实引擎 | 新账号从无命盘写入 v1，POST 后独立 GET 完全相等。八字 `COMPUTED_UNVERIFIED`、紫微 `CALCULATED`、西洋 `CALCULATED`，三盘 oracle 均 `UNVERIFIED`。实测真太阳时和 WGS84 上下文。 |
| 重复、超时和输入纠错 | 同版本同输入复用 v1。真实客户端读超时后服务器完成 v2，原版本 POST 重放 409，当前 v2 输入与结果匹配。时间与坐标改动改变签名并重算，旧 v1 归档只读。 |
| 错误状态、跨版本和账号 | 越界或只有单项坐标的 3 组输入均 422，v2 保持。运行时变化时老盘派生过期且清空结果视图。另一个账号真实 503 后保留输入，恢复时无坐标可保存，西盘四轴 `UNKNOWN`。来宾 401、另一用户读不到本人的精确资料和命盘，直接访问他人的归档 ID 为 404。真实 HTTP 退出使旧令牌失效，重登读到原 v2。 |
| Android 真实链 | 合成账号经基础资料导入和 WGS84 核对后正式提交，持久接口读回输入 v1、结果 v1。页面重入、强制结束进程后冷启动、设置页退出并完成服务端会话撤销后重登，均重新读回 v1。八字和紫微版面、西洋盘详情均可读。 |
| 来源与精度 | 持久化可选 `input.location_coordinate_origin`，识别 GeoNames 区县/城市代表点、OSM 地标/院区代表点、已保存且由用户确认的坐标、手填坐标。正式核对页显示民用时区与时间、地点名、WGS84 坐标和来源。历史无来源时提示来源和精度未记录。手改经纬度清除原供应来源。行政区代表点标明约略级别。来源为客户端确认的输入信息。 |

`NATAL_SYNTHETIC_E2E_PASS` 和 `NATAL_INPUT_SEMANTICS_VERIFIED` 覆盖本地最终源码。SQL 直读确认两个 HTTP 验收账号均为当前行 1 条、归档 1 条，Android 验收账号为当前行 1 条、归档 0 条。计算签名维持原口径，纯来源标识修改经版本比较持久化。行政区和 OSM 数据来源采用原 1011814 种类，本轮未增加地点库样本或发起真实供应商调用。实际 HTTP 初轮保留了 Windows 开发服务器的 Node CSPRNG 启动失败。以开发服务器进程参数 `variables_order=EGPCS` 恢复，产品算法代码保持原样。构建初轮 x86_64 Flutter 引擎未命中离线缓存，复用已缓存 arm64，并在具备 ARM 转译的独立 AVD 运行。

## M1-04｜Owner 实体 APP 与顾问入口

`NATAL_REAL_APP_SAVE_AND_READBACK_PASS` 尚未取得。候选档案及历史安装回执已核验，新一轮实体版本、已装哈希和账号身份核对仍待本轮具名授权。Owner 使用已安装 1011814 可核对原有地点确认和正式保存读回。新增正式提交核对页及来源持久化仅经过本地工程验证，覆盖它们的共享 Staging 与 APK 实体验收需要后续对应授权。正式资料由 Owner 核对并提交。三盘实际状态、重新进入、重登读回逐项记证。出生资料及盘面原件留本机。

## M2｜公网 HTTPS 安全只读诊断

`P1_RESTRICTED_HTTPS_DIAGNOSTIC_READONLY`，历史仅 `/32` 仍为 `FAIL`，根因 `UNKNOWN`。历史对照中同一批准来源的 TCP 22/80 抵达主机，443 超时，主机未见获批来源的 443 流量。阿里云控制台自助结果 8/8，无逐连接依据。Owner 启用全 IPv4 TCP 443 后全网与 `/32` 同时启用，严格 TLS 的两个路径 200。历史样本提示仅 `/32` 失败发生在主机观察点之前或其观测范围之外，现有证据不足以定位云规则匹配、回程或路径中的具体环节。上述对照、续期演练及告警等 5 份私有回执 SHA-256 与已存索引相符。

模板按方法和归一化路径选择入口，以连接原始来源分别限制 APP、Web 管理、API 管理和激活。未批准源拒绝，未知路径和 Upgrade 拒绝，回环上游严格验链。历史已验证正式可信 IP SAN、ACME challenge-only 80、续期与健康 timer、staging dry-run、deploy hook、隔离回滚、网页 OnFailure 测试告警。自然续期、实流量完整拒绝统计、独立 Chrome 登录、手机移动网络出口、真实 WLAN 和双实体专项仍待验。本轮公网 443 探测、规则变更、来源放宽和外部业务调用均为 0。

若 Owner 日后批准一轮具名网络对照，先固定双方时钟、来源出口和规则快照，对齐客户端、主机入站观测及云端逐连接回执的时间窗。沿一个获批客户端、一个目标和一次连接尝试记录 SYN、SYN/ACK、TLS 与 HTTP 段。主机未见 SYN 时提交给供应商核对入口匹配证据，见 SYN 后按回程、TLS、路由与 HTTP 日志依次收敛。日志只留时间、请求标识、来源判定、事件与状态，不记录请求体或口令。规则调整与 `/32` 复验等待独立决策，本轮仅保留此方案。 [固定 P1 证据索引](V2_P1_PUBLIC_HTTPS_OWNER_WEB_HANDOFF_20261123.md) · [入口模板](../../../../services/backend-laravel/docker/shared-staging/restricted-edge/nginx.conf.in) · [证书与回滚脚本](../../../../services/backend-laravel/docker/shared-staging/restricted-edge/RUNBOOK.md)

## 证据索引与保留门槛

本轮本机索引目录 `D:/EliteSync/development/v2-m1-natal-local-20261126`。GitHub 仅保存去敏工程记录和测试代码。已接受 P0 资料恢复、1011814 地点回填与历史失败沿原记录。共享 Connection、私信、WSS、公开注册及生产 RTC 继续关闭。M1 的工程范围与 R1、内测和生产门槛分别验收。待 Owner 实体回执齐备后，由 Owner 手动转交本报告的固定 GitHub 版本给 GPT 顾问。

| 本机证据 | SHA-256 |
| --- | --- |
| `m1-http-receipt.json`，隔离 HTTP 状态和版本 | `538f8f2dfa5ae226a057ac18cacc1a6a4871dd2240ad3e7d5e4edcfbc43eebcb` |
| `m1-db-receipt.json`，实际数据库统计和状态 | `1a3befadd455d2b41c060e7769115919790f58301cb7604ceeef6644925b5366` |
| `android-02-confirm.xml`，正式确认页 | `b436eae817adb34fd02e56bf97bd4579f55efe379f87affb4fa8f985263fe567` |
| `android-03-saved.xml`，Android v1 保存并重读 | `206d21c4ce2160ff4cf3020c4692a7abec9025cff1d7d8cf9da62c8d95f33fa8` |
| `android-08-restarted.xml`，进程冷启动后读回 | `9c8a9a6869f946dbb4a9e806d9f7baaded7fb3bcf51dd80170122e93c734fe9e` |
| `android-09-western-route.xml`，西盘计算状态及读回版本 | `e5e362e58cf396d694745965396403804cd784869cb5738fa995cb38ec5ec737` |
| `android-12-relogin.xml`，退出重登后读回 | `7b820bae41a15c5bffa1880532fa738094346dd15482e584582e621810715b3f` |
| `android-13-reentry-confirmed.xml`，退出页面后重入 | `df09f1b3551fe91a92b9d0e8075678899106e08ebac403649c6917df56542fe8` |
| 1011814 上一次真实安装回执 | `6320cef8dabcc793d80519064ee5abe8928a9d7ad26f717cd486f82ccbf1b448` |
