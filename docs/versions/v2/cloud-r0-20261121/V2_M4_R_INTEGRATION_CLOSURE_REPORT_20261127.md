# EliteSync V2｜M4-R 集成运行与软件候选收口

2026-11-27，北京时间。任务 `V2-M4-R-INTEGRATION-CLOSURE-20261127`。范围为本机隔离集成与合成账号。总体发布状态 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。网页 GPT 顾问复审待 Owner 转交。

| 验收出口 | 结果 |
| --- | --- |
| `M4_NATAL_RUNTIME_IDENTITY_AVAILABLE` | **PASS**，隔离容器读回实际依赖、数据签名和运行准入。 |
| `M4_NATAL_INTEGRATED_SAVE_READBACK_PASS` | **PASS**，模拟器正式提交、独立 HTTP 和 MariaDB 读回、页面重入、重登和冷启动。 |
| `M3_R04_INTERRUPTION_DIAGNOSTIC_COMPLETE` | **完成**。原自然观察仍 `PARTIAL / INTERRUPTION_CAUSE_UNKNOWN`。 |
| `M4_UNIFIED_SOFTWARE_CANDIDATE_READY` | **PASS（本地 QA）**。同一 App、API、Web、计算及数据库环境完成代表性验证。 |
| `V2_REMAINING_ROADMAP_GAPS_MAPPED` | **完成**。A–D、E1–E3、具名设备、发布门槛和 UI-S 输入见下文。 |

## 工程与运行身份

| 范围 | 固定身份 |
| --- | --- |
| 活动工程 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，origin `git@github.com:zcx369658780/EliteSync-v10.git`。开工 HEAD `8322e691f5207695388aa04e6fe5ebbba2ecf1d6`、tree `b5cae8622e41fd5a4bd85319b252f41e5de942a5`，开工暂存区和工作树干净。续作时工作树仅有本轮新 Dockerfile。保护 `D:/EliteSync-v10` main，接续核对 HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、43 条未暂存与 213 条未跟踪状态。 |
| M4-R 固定源码 | `8d31ade2d6aaba965f7f169ba49ce76189e940c9`，tree `865fcab54effc59eb1ef0da224bb99a1c87c38bb`。Dockerfile blob `a3c1822eced5f060d5811c903f907ee3a8332648`。产品源码从 M4 `ad520ba527580dba946cd904047c45abc069eebd` 沿用，Android tree `84cdd60999c8fbae59106175fb8ff2aa2c6863af`、Flutter lib tree `056656586e256fa8f4f8d32da765ef1bfaf58d34`、Laravel app tree `1849dba17fd0925b4ab144e64be2ae42ca42dbfa`。 |
| 本地 API 和 Web | 独立 WSL Docker 守护进程及内部 Docker 网络。旧对照 `m4-journey-api` 保留。最终 `m4r-final-api` 容器 ID `429f788a23fe5ce39368cf834525fed4a1e4e0a7ffef7f596cb9b2a2b63190da`，本地镜像 ID `sha256:bad4f6134ea78b6ef1dc3d2d249b4ae889ed072cc9cb3f66f4886d719adfed26`。复用固定基础镜像 ID `sha256:6bce0c32e49a3ac2800644fb42eac616742b88e9a0beffb159fe6045e42a9f10`。逐文件核对归档、构建上下文与运行容器 617 个复制文件，字节一致。运行容器挂载仅涵盖独立密钥文件、合成媒体卷及只读 DE440s。 |
| 数据库 | 原 M4 隔离容器 `m4-journey-db`，镜像 ID `sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab`，MariaDB 10.11.19，server ID `2621121`，逻辑库 `elitesync_v2_function`。迁移 tree `d0d4e1fbdec30d8e486750379ed86952c0af700e`。运行库 121 表、96 条迁移，三盘表及 M3-R 上传编号迁移均读回 `Ran`。本轮复用现有 schema。 |
| 模拟器与 APK | 原 M4 AVD `elitesync_api36`、`emulator-5572`。包 `com.elitesync.v2m4journeyqa`，versionCode `1011807`，versionName `10.1.18-v2-m3-wlan-qa`。保存文件及模拟器已安装 APK SHA-256 均为 `a26145f85356dacfba614ffe782677716ce955b638edec1abf8d3394de089182`。签名证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。现有 APK 通过 `127.0.0.1:18445` 严格 TLS 与模拟器 ADB reverse 访问同一容器。Web 管理和 API 均由该容器提供，独立 HTTP 读回走本机回环中继。 |

M4 APK 构建副本与固定 App 源码抽查覆盖 526 个跟踪文件。三处编译源码的差异为本地回环端口、QA 包名、显示版本、证书错误提示及关闭原生调试入口。一份 Android 测试源码按原构建方式从 QA 副本排除。M4 阶段已有 ARM64 AAR 与 APK 字节对应。M4-R 复用原 APK 和证书。

[固定源码](https://github.com/zcx369658780/EliteSync-v10/commit/8d31ade2d6aaba965f7f169ba49ce76189e940c9) · [M4 集中报告](V2_M4_INTEGRATED_USER_JOURNEY_REPORT.md) · [M3-R 集中报告](V2_M3_R_FINAL_CLOSURE_REPORT_20261127.md)

## M4-R01｜503 根因与运行恢复

旧容器的 `NATAL_PYTHON`、`NATAL_NODE` 和 `NATAL_JPL_KERNEL` 均未显式配置，`/opt/elitesync-data` 无 DE440s。Laravel 读到 Python 与 kernel 配置为空，Node 为默认 `node`。同容器直接调用 `NatalRuntimeIdentity` 得到 `IDENTITY_UNAVAILABLE / runtime_not_configured`。全时刻计算因此进入现行 503 分支。M4 历史 Windows HTTP 服务启动受本机策略限制。本轮使用现有 WSL Docker 及其已安装依赖。

在隔离 Dockerfile 固定 Python、Node 与 kernel 路径，关闭线上地点供应商，保留基础镜像非特权 `www-data`。复用旧镜像依赖，校验 Composer、Python 和 Node 三套锁及 `pip check`。私网探针初次经默认代理返回 502，改用隔离网络的直连探针。第一镜像启动时复制整个 bootstrap 目录导致 `bootstrap/cache` 变为 root 所有，Laravel 返回 500。最终镜像仅覆盖 bootstrap PHP 文件，并在构建中验证原缓存目录可写。

| 依赖 | 最终容器实际读回 |
| --- | --- |
| PHP | PHP 8.4.28、Composer 2.9.8、Laravel 13.39.0、`6tail/lunar-php 1.4.7`，实际安装与 `composer.lock` 一致。M1 固定源码锁和本机存档的 M1 vendor 也为 1.4.7。既有 M1 报告及八字结果的静态引擎标签写 1.4.0，单列为待校正的版本标识差异。 |
| Python 与 Skyfield | CPython 3.11.2，`/opt/elitesync-natal/bin/python`；Skyfield 1.55、NumPy 2.4.6、jplephem 2.24、pyerfa 2.0.1.5、sgp4 2.27、certifi 2026.7.22。校验读回包元数据、实现、时间表和可执行文件指纹。 |
| Node 与 iztro | `/usr/local/bin/node`，22.23.5，iztro 2.5.8。M1 原 Windows 正向环境 Node 24.14.0。本轮实测锁定脚本和库在容器运行。 |
| DE440s | 复用已核 NASA/JPL NAIF 存档。运行路径 `/opt/elitesync-data/de440s.bsp`，只读 0444、32,726,016 字节，SHA-256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`。容器内实际散列与准入值相同。 |
| Laravel 准入 | `NatalRuntimeIdentity=AVAILABLE`，配置指纹 `7cb36fb26cbacee2f7ca27ae8d91c0af13cfef9bc2117ab79445a560bbd13e87`。容器的计算脚本、核验程序及数据文件可被服务进程读取并运行。 |

复现时先核对本地基础镜像 ID，从固定源码提取 Dockerfile 需用的 Laravel 路径和三套锁。以该后端目录结构作为最小构建上下文，使用现有本地基础镜像和 `--network=none --pull=false`。启动时挂载经 SHA-256 核对的独立 DE440s 为只读，保留隔离库的既有凭证和 TEST_ONLY 校验，在同一网络执行运行探针和独立 HTTP。实测构建上下文归档 SHA-256 `941b5b0bf0b4d7df51cd7277c24b9daa5333324acebbff09ed0787c4254aa154`。私有脚本、数据原件和镜像保留本机。算法源码和三套锁沿用开工身份。

[集成 Dockerfile](../../../../services/backend-laravel/docker/cloud-r0/m4-integration.Dockerfile) · [三盘算法和数据准入依据](../../../../services/backend-laravel/tools/natal/README.md)

## M4-R02 / M4-R04｜正向闭环与定向回归

| 场景 | 本轮结果 |
| --- | --- |
| 基础资料与正式提交 | **PASS**。合成账号从无命盘开始，API 持久资料含完整出生日期、时间、地点和经纬度。App 打开星盘画像及三盘排盘页，导入本人资料，确认 WGS84，单独选择算法参数，再核对民用时区、地点、坐标与来源。点击确认后同一候选经 TLS 收到 POST 200 和后续 GET 200。 |
| 三盘计算、独立 GET、MariaDB | **PASS**。八字 `COMPUTED_UNVERIFIED`、紫微 `CALCULATED`、西洋 `CALCULATED`。App 与独立会话 GET 均读到输入 v1、结果 v1。MariaDB 当前记录唯一，输入签名、版本及三盘状态与 HTTP 一致。三盘独立精度核验均为 `UNVERIFIED`，沿用历史参考范围。 |
| App 页面重入、退出重登与冷启动 | **PASS**。三种操作后均经 API 200 读回 v1/v1。退出及重登各有 HTTP 200 回执。冷启动确认进程 PID 改变，在保留登录会话后重新进入三盘页。 |
| 缺运行身份的真实 503 | **PASS**。第二合成账号先在最终容器取得匹配版本的合法结果，再向旧容器提交更正后的输入。返回 503／`natal_calculation_unavailable`。GET 读到新输入和 `FAILED`，当前结果及版本均为空。历史合法版本的行关联、签名与结果摘要保持。切回最终容器后本人读回同一历史结果，另一账号读该归档返回 404。 |
| 软件代表性集成 | **PASS（HTTP、MariaDB 和 Web）**。首页、精选入口及数据、社区、Buddy、Lifestyle 完成态、进度和资料可读取。新 TEST_ONLY 配对通过好友邀请、独立 Connection 和 Messaging Consent，再建立可读写的会话并读回消息及站内通知。Web 密码登录、CSRF、用户、轮次、Showcase、Buddy 页面和管理 API 与 MariaDB 事实互证。严格回环 TLS 的 Web 登录页 200。 |
| App 代表性集成 | **PASS（同一 APK 与模拟器）**。登录回首页，首页已保存的 Lifestyle 状态、进度及社区和 Buddy 入口可达。消息列表打开本轮合法会话并显示落库消息。站内消息提醒重读权限后打开同一会话，Android Back 回原通知中心。原合成授权到期后的 404 已观察，使用该隔离夹具的合法 TEST_ONLY 签发恢复。 |
| 其他测试证据 | M4 的 Flutter 159/159、PHP 128/128、真实 MariaDB/HTTP 9 组以及既有模拟器旅程沿用。本轮四份通过的定向回执累计 6 组、51 次 HTTP 响应，另计模拟器请求、健康和 TLS 探针。保留首轮资料和 Buddy 参数 422、旧夹具开关拒绝及模拟器定位脚本的失败证据。 |

固定候选的发布范围为本地调试签名 QA。独立 Chrome 公网后台、共享 Staging、实体安装与生产链本轮均 `NOT_RUN`。

## M4-R03｜M3-R04 中断只读诊断

| 时间或对象 | 证据分级与结论 |
| --- | --- |
| 2026-11-27 07:30:38 至 07:31:23 | `DIRECTLY_VERIFIED`。服务端授权送达。07:31:23 最后确认同一 QA 进程可读本代文字，离线发送和媒体不可用。预定到期为 11 月 28 日 07:30:38。 |
| 07:34:23、07:37:23、07:40:23 | `DIRECTLY_VERIFIED`。监测仍写入三次心跳，均无法核定原进程。历史探针将 ADB 异常、进程缺失和解析失败归并，具体触发条件 `UNKNOWN`。 |
| 旧代理 | `DIRECTLY_VERIFIED`。独立入口记录 1 次置闸、25 次隔离请求及 0 次上游转发。代理日志最后写入 07:34:50。监测记录最后写入 07:40:23，监测与代理 stderr 为空，无正常退出或恢复回执。日志覆盖外的续发状态 `UNKNOWN`。 |
| 宿主机与执行器 | `DIRECTLY_VERIFIED`。Windows 在 07:41:45 休眠，10:06:14 恢复，所查范围无系统重启记录。休眠晚于首次身份读取失败。Task Scheduler 与 DriverFrameworks 所查操作日志当时未启用。现 ADB 进程于 10:18 启动。USB 断开、ADB 当时退出、QA 进程回收及执行器终止的具体因果均为 `UNKNOWN`。 |
| M4 时序及原数据 | `CORROBORATED`。M4 隔离 Docker 守护进程及服务约 10:12–10:14 启动，晚于原观察证据中断。使用独立 socket、数据根、网络、数据库卷、端口和模拟器。M3 Docker 残留容器和卷目录仍在，专用 socket 和旧入口监听当前不可用。原库运行与数据库行留存状态本轮 `NOT_RUN`，原实例未启动。 |

诊断完成，原自然观察继续 `PARTIAL / INTERRUPTION_CAUSE_UNKNOWN`。缺失同进程到期前后和恢复联网证据，原到期窗口已失去验收前提。

下一次观察须单独取得 Owner 对设备、固定 APK、隔离方式和操作时段的授权。采用独立于 Codex 会话的宿主进程或具名专用常开测试机，观察器和 QA 入口分别留下启动、心跳、可辨别的 ADB 错误、退出及恢复回执。限定唯一测试入口和合成会话，保存一次签发的 UTC 时间、到期、代际、账号设备绑定、进程和 boot ID 的去敏摘要。独立入口记录每次放行、阻断及授权回包计数，所有时间以原签发起 86,400 秒为准。预先在合成环境演练观察器故障时维持隔离及自动恢复，恢复依据预定到期后时刻，另有可审计的紧急恢复动作。到期前后由同进程读回和可信时间回执确认，恢复联网后复核代际与新授权。系统时钟、设备日常网络和其他工程环境保持原安排。手机被回收或观测连续性无法证明时，保留原件并记 PARTIAL 或 INVALID。

## M4-R05｜路线图剩余目标

| 路线 | 可沿用的具名证据 | 剩余目标与类型 |
| --- | --- | --- |
| A1–A4 安全基线 | 正式身份 fail-closed、候选原合法发布快照、Lifestyle UNKNOWN 先查、Block 与旧受众/缓存。M3 和 M4 补充本地运行。 | E1 真实核验仍阻正式参与。对已变更的写入链补真实丢包、晚到及跨设备失权。重复无变化的具名阶段 A 矩阵无必要。 |
| B1–B4 内容与评论 | 访客／登录双域合同、受众默认、评论者撤回与作者隐藏、当前受众及历史封面和评论的独立授权，已有定向及部分 HTTP 验证。 | 正式访客官方专题缺具名授权与内容。官方复制／转载首期范围及旧候选主动分享新版（NEW-PC-05／04）待 Owner。评论分页竞争、权限收窄和大受众下的 MariaDB/端侧矩阵仍缺完整运行回执。 |
| C1–C4 资料与对象权利 | 具名城市／本命复用、来源及用途版本、限定派生纠错、旧候选绑定。对象独立删除入口及 TEST_ONLY 状态通过具名测试。 | 真实用途、第三方权利和历史来源等待 E3。本人作品／评论的真实受理、处理和对象范围完成依赖合法渠道、留存与第三方范围决定。旧 `POST /profile/astro` 兼容或退役仍待 Owner，现行基础资料与私有本命独立入口继续使用。 |
| D1–D4 旅程与 UX | TEST_ONLY 完整关系主链、站内待办和跳转、社区、Buddy、后台一致性、三盘 App 正向闭环。 | 真实身份与真实 Push 全链待 E1／E2。S01–S16、G01–G10、D/I/N/A/W 综合运行证据仍有开放项。读屏、减少动效、设备大字与系统 Back 的完整专项和 F-01、43 份原图正式身份继续待验。未来 UI-S 集中处理认知和导航成本。 |
| M3-R04 自然到期 | 期内文字与可靠 TTL 自动化测试沿用，WLAN 和网络故障范围按 M3 与 M3-R 固定证据。 | 具名实体自然经过 24 小时及同进程到期、重连仍 `PARTIAL / INTERRUPTION_CAUSE_UNKNOWN`。新观察待 Owner。 |
| P1 公网、证书与设备 | 正式可信 IP SAN、续期演练、告警、内置浏览器后台、具名远程 API 有回执。 | 仅 `/32` 历史 **FAIL**、根因 **UNKNOWN**，按既有 Owner 边界停止探测。既有全 IPv4 TCP 443 云规则和外层 Nginx 来源限制按原决定保留。正式证书自然续期、独立 Chrome 公网管理、真实移动网络和双实体专项待证。既有 WLAN 记实际候选与窗口，其余窗口各自保留。 |
| 三盘和媒体工程 | 本机 v1/v1 与 M1 实机 v3/v3 各自具名通过。图片编号、幂等、私有读取、撤权和迁移沿用。 | M1-R 历史实机请求与后端身份仍 PARTIAL。三盘独立算法精度限制继续，八字版本标签待核对。无永久重试的落盘孤立文件还需生命周期、审计与留存治理，删除动作另行授权。 |
| E1 真实身份 | TEST_ONLY 身份与正式门禁已有证据。 | Owner 指定供应商、适用合同和费用后，再授权真实数据、失效传播、资格回执与申诉端到端验证。 |
| E2 真实 Push | 站内通知、撤权和跳转有具名回执。 | 供应商与隐私策略、设备同意、成功与失败回执、旧设备撤回和重登验证待决。 |
| E3 法律、个人数据与第三方资产 | 合成软件链及保守关闭可沿用。 | 确认适用法域和合法处理基础、对象权利、保留例外、备份／日志／媒体范围、第三方内容和 43 PNG 来源与回读。 |
| 独立发布硬门槛 | 本地阶段性证据与历史失败按各自范围保留。 | E1–E3、P1 受限公网和证书生命周期、具名端到端安全／失权与发布权限分别核对。共享 Connection、私信、WSS、公开注册和生产 RTC 沿用关闭。内测与生产继续 NO_GO，合 main 未授权。 |

[Owner 路线图](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md) · [阶段 A](../phase-a-20261119/PHASE_A_ENGINEERING_REPORT.md) · [阶段 B](../phase-b-20261120/PHASE_B_ENGINEERING_REPORT.md) · [阶段 C](../phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md) · [阶段 D](../phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md)

## UI-S 输入与 Owner 决策

Owner 确定先交付既定路线图，再集中进行全 APP UI 简化。未来沿构成主义与二次元极简方向，降低必要操作次数、学习成本和认知负担。本轮沿用现行视觉体系。 [Owner 决策记录](../../../decisions/OWNER_V2_M4_R_ROADMAP_BEFORE_UI_SIMPLIFICATION_20261127.md)

- 三盘实测入口需从「我的」进入「三盘本命」，经过星盘画像中转，再进入「三盘本命 · 手填与排盘」。可评估首屏直达本人命盘和编辑入口。WGS84、来源和正式提交核对仍是必要控制。
- 进度页同时呈现轮次、候选、Connection、Messaging Consent、聊天和正式关系。UI-S 可按当前服务端权限突出可执行下一步，保留查看状态、拒绝和撤回。
- 站内通知从消息进入通知中心，再打开业务详情，完成后回原频道。可整合「我的」和消息页的重复入口，保留待办、历史和当前权限。
- 资料、用途、展示快照和账户安全由不同服务授权。可集中入口与通俗命名，同时保留相应独立的拒绝、退出和隐私控制。

下轮可先处理独立软件差距、八字版本标签和媒体孤立文件治理设计。需要 Owner 集中决定旧接口兼容或退役、B 阶段内容政策、自然观察和具名跨端验证窗口，以及 E1–E3 权限和发布前置门槛。其余工作按已接受证据复用。

## 私有回执索引

原件保留在 `D:/EliteSync/development/v2-m4r-local-20261127` 和原 M3／M4 证据目录。GitHub 交付限本报告、Owner／工作流记录及 Dockerfile。

| 回执 | SHA-256 |
| --- | --- |
| `runtime.private.json` | `4a442a539eb01d6bc21e8c8b4d3dcb713736d7c039078956381a74aa7b5a6fb7` |
| `source-proof.private.json` | `54ce7ac822c332eb8db5a29b4bc853d0f332ae5ca4a8c4e6a21176199d6214a2` |
| `readback-http-e46e5b5b.private.json` | `aa2a37d2cfa4f5ff86e7d0715c7509835da9e91c84f5d29a60f5cead314358d7` |
| `failure-http-babe00ea.private.json` | `7cc9139852dffed4f5b242fb08de4f46598d05de38caaa91e795745b7712b89b` |
| `smoke-http-c0489a38.private.json` | `d8b8666afc978f4b86708fd8190b745058bab1f707a88f847f83a4ab55a82555` |
| `natal-confirm.private.png` | `d7b5475d1cfb90854c2023c63569c96733c25f0e9d2dcb482e2df1807773acdc` |
| `natal-saved.private.png` | `d3a049bcd2116e415c24e7bc4756297b14466949fdb6aed6f9a6b79b51e459c5` |
| `natal-page-reentry.private.png` | `b41796f12e4c9df49fbb58377c1ee5d1f2784d46d201b15923956af1a6f58f9b` |
| `natal-relogin.private.png` | `429dc6b1bbd579408a8b3bd0ed71f20271d10d000c073442e4bf4f106bf1acbd` |
| `natal-cold-start.private.png` | `1797cab8eab36f05c5de8a95c8976c073eb4e6686bc04722ef22fdcfb799e025` |
| `candidate-notice-chat.private.png` | `8b07fadb69abf6f8e0874d21bb368474214bf7663b708e32a07d9564bc75beb0` |
| `candidate-notices-return.private.png` | `a511f08ee965d9f4755b8ab23d485ccb3b8afc66f8929bdcaf6d3aaa04ace48a` |
| `m3r-lease-observation.private.jsonl` | `a63922ec21579b6660e35df348bc9d4d938e65862513c121eaf272dbda607852` |
| M3 `lease-request.private.log` | `af6956b2a7fdbc80defbc1fa539410ab1ba0a65fe4c14c7265be9be38bcd8aa3` |
