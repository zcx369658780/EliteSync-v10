# EliteSync V2｜RC-E 发布准入证据集中报告

2026-11-27，北京时间。任务 V2-RC-E-RELEASE-EVIDENCE-CLOSURE-20261127。

**结论：RC_E_CLOSED_BETA_READINESS_ASSESSED。建议维持 R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO。** 本地软件和合成验证支持继续受控 QA。法律与资产依据、现行公网运行证明、实体设备与网络、算法精度范围及历史工程债务仍有限制。Owner 保留封闭内测、生产发布及后续范围的决定。

| 工作包 | 具名出口 | 证据状态 |
| --- | --- | --- |
| RC-E1 | RC_E_DATA_AND_ASSET_EVIDENCE_READY | PARTIAL。八类数据与四批原稿完成索引，主体与法域待 Owner，PNG 原件与许可缺口保留。 |
| RC-E2 | RC_E_PUBLIC_RUNTIME_SECURITY_EVIDENCE_READY | PARTIAL。历史配置和回执已交叉核验，/32 FAIL、根因 UNKNOWN，自然续期和独立 Chrome 未证。 |
| RC-E3 | RC_E_DEVICE_AND_NETWORK_EVIDENCE_READY | PARTIAL。候选文件复验、历史矩阵及新观察方案已备，原自然观察仍中断。 |
| RC-E4 | RC_E_THREE_CHART_ACCURACY_EVIDENCE_READY | SCOPED PASS。三盘离线子项有独立参考，整盘及全域精度门槛仍 PARTIAL。 |
| RC-E5 | RC_E_ENGINEERING_DEBT_DISPOSITIONED | PARTIAL。全量 FAIL 账已复核，合成恢复和媒体定向通过；剩余用例仍需分类复测或 Owner 裁决。 |
| RC-E6 | RC_E_CLOSED_BETA_READINESS_ASSESSED | PASS。完成证据汇集与准入判断，发布维持 NO_GO。 |

## 1. 固定工程、候选与决策合同

| 项目 | 核验值 |
| --- | --- |
| 活动工程 | D:/EliteSync/development/v2-cloud-r0-20261121，codex/v2-function-completion-20261121，origin git@github.com:zcx369658780/EliteSync-v10.git。开工本地及远端 HEAD 09575088eb9241d46036913a01c882cbb3441545，tree 5cee386ca5022b55817d17b446bc045e0a8cf19c。工作区及暂存区为空。 |
| 产品身份 | RC-F 源码 03d6740e9cbe36255129ef848d66d4a54dea2327，固定交付 f7f06a856606a2192204371c03c3b59598a51660。至 RC-E 开工的 apps 与 services 无变更。M4-R 统一 QA 源码 8d31ade2d6aaba965f7f169ba49ce76189e940c9，报告 440ac56217659b32b040d58b3cd1748761f6039a。 |
| 软件锁 Git 对象 | Composer e236fbc960c1dd08c1fecb9aeed4926b4cab3933，iztro npm 锁 0a6f81dba6e461ff8388b7a0674763de91bd305c，Python Linux 锁 b4d7a353ab9df82a924a00f53586b5892442e283，迁移 tree d0d4e1fbdec30d8e486750379ed86952c0af700e。 |
| 本轮运行 | 新隔离 Docker daemon 复用已核镜像，原 M4 服务 socket 本轮不可用，历史容器状态不作现场确认。PHP 8.4.28 镜像 sha256:bad4f6134ea78b6ef1dc3d2d249b4ae889ed072cc9cb3f66f4886d719adfed26；MariaDB 10.11.19 镜像 sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab。RC-E 测试容器禁用网络，数据库走各自 Unix socket。 |
| 保护树 | D:/EliteSync-v10 的 main 回读 HEAD 4bebc8f394248e254c1368a06fbdee5d2c883301，43 个已跟踪未暂存文件、213 个未跟踪项、暂存 0。原工作树、运行卷、QA APK 和私有证据各保留。 |

沿用的七项 Owner 合同如下。NEW-PC-04 既有候选快照不自动更新。NEW-PC-05 首期为官方原创专题和站内受控推荐，正式转载关闭，访客正文默认空。D0 旧写入 409，现行本人只读兼容保留，正式保存使用 natal。D4 真实对象渠道为 REQUEST_CHANNEL_UNAVAILABLE。E1 正式匹配保留真实身份门禁，KYC 未接入。E2 首期仅站内通知。E3 缺乏法律、数据来源及权利依据的功能保持关闭。 [RC-D Owner 归档](../../../decisions/OWNER_V2_RC_D_FINAL_PRODUCT_DECISIONS_20261127.md) · [RC-F](V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md) · [M4-R](V2_M4_R_INTEGRATION_CLOSURE_REPORT_20261127.md)

## 2. RC-E1｜数据、法律与资产

历史 Owner 决定延后公司注册、备案和上架讨论，并保留受控开发通道。已知历史开发环境有本机隔离库和阿里云轻量实例上的受控 Staging。此次查到的是开发部署事实。正式运营主体、个人信息处理责任主体、服务地区和相关司法管辖为 OWNER_INPUT_REQUIRED。正式存储及副本区域、服务商与管理员访问链、跨境传输或远程访问路径目前 UNKNOWN。合成库恢复、受控云库及历史具名账号的限定回执不能给出实际业务保留期限。 [Owner 决策索引](../../../../PRODUCT_DECISIONS.md) · [RC-D §E3](V2_RC_D_OWNER_DECISION_DOSSIER_20261127.md) · [历史受控通道限定接受](../../v10.1.0/DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_ACCEPTANCE.md)

| 数据 | 来源及权威存储 | 用途、受众及允许复用 | 更正及撤权 | 历史、保留与依据缺口 |
| --- | --- | --- | --- | --- |
| 基础账号 | 注册、本人编辑、受控管理员恢复，MariaDB users 与相关安全表 | 登录、账号资料及独立指定的可展示字段；本人及有角色的后台。禁止借旧排盘回填 | 本人资料写权威、改密撤会话、停用及退出依各自合同 | 历史仅具名账号获字段级验证。其他迁移来源、主体、字段必要性与保留 UNKNOWN |
| 出生日期、时刻、地点 | 本人手填、选择地点及旧资料；users 私有字段与 user_natal_profiles 独立输入；data_purpose_grants 与来源版本绑定 | 本人独立排盘；受控场景的用途版本与来源版本同时有效才可复用；精确时地默认私有 | 更正更新来源及修订；撤回具名用途；手填独立保留原语义 | 历史衍生数据用途未核，旧写入拒绝；真实收集、地理服务及副本依据 UNKNOWN |
| 三盘结果 | 本人输入与固定引擎；user_natal_profiles 及本人历史归档；历史 user_astro_profiles 独立 | 本人计算、显示与经具名授权的派生；旧入口有限私有投影 | 输入签名与结果版本失配则隐藏；旧结果、用途撤回及对象处理各自判定 | M1 与 M4-R 有限读回；历史推导来源、解释用途及保留依据待核 |
| Lifestyle 与匹配 | 本人作答与独立确认；问卷、matching_inputs、matching_participations、候选绑定及形象发布记录 | 本人进度；已授权且有资格时使用必要匹配资料；既有候选按绑定版本和当前权限读取 | 纠错、重确认、撤权与 Block；旧快照按当前许可失效 | 旧问卷及衍生结果的来源与保留 UNKNOWN；正式匹配受 E1 门禁 |
| 作品、评论、媒体 | 站内作者及评论者提交；status_posts、status_post_comments、media_assets 和私有存储 | 原创、站内受控推荐、按当前与历史受众交集读取；真实访客素材待授权 | 作者隐藏、评论者撤回、受众收窄；旧通知、深链及媒体复核当前权利 | RC-F 仅合成资产审计；权属、历史上传、附件及备份例外待核；真实删除渠道关闭 |
| Connection、私信、关系 | 双方操作和系统状态；product_connections、messaging_consents、chat_messages、关系及附件记录 | 分别确认，合法参与者及具名运营权限；共享环境会话入口按现行关闭策略 | 失权、退出或 Block 使当前读取、旧代缓存和 room_key 按合同失效 | 历史聊天来源、保留与跨设备传播证据待核；24 小时离线授权是访问窗口 |
| 通知与设备会话 | 权威业务事件、设备注册及登录；notifications、device_sessions 与相应凭据 | 本人站内通知与会话管理，追踪最小状态；通知深链重新校验权限；Push 关闭 | 标读与业务确认独立；退出、切号、设备撤销及旧凭据拒绝 | 站内和 Push 存储/送达分列；生产日志、备份和实际期限待核 |
| Safety 与运营审核 | 用户反馈、授权运营处理、系统审计；safety_cases、审核决定及申诉表、具名后台审计 | 有角色且有业务需要的处理，按最小权限访问；KYC 凭证和普通运营审核独立 | 更正与申诉按当前审核权威；安全证据受保护，不进入普通关系投影 | 历史来源、必要留存、申诉责任和第三方副本范围待核 |

实际处理目的、必要字段、权利渠道、留存与恢复后再处置、未成年人或敏感字段、外部访问/跨境及许可文本，需要在具名运营范围确认后交相应专业人员审查。本轮依据已有 Owner 文档和技术合同登记缺口，未作法域或实际法律适用判定。 [阶段 C](../phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md) · [RET-D1/D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md) · [HIS-D1/D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_HIS_D1_D2_HISTORICAL_ACCESS_AND_SNAPSHOTS_20261119.md)

### F-01 版本化索引

固定治理提交 8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7。逐份回读顶部增量与历史待审定位，采用具名 Owner 文件解释已接受范围。其余页面细节在各自的历史阶段保持 OPEN。全仓同类检索风险仍 READABILITY_PARTIAL。

| 原稿范围 | 原稿 blob ／历史待审定位 | 具名 Owner 增量 |
| --- | --- | --- |
| S01–04 | de7e03248ed4bbd3e7734cdfb0fd46442259397d，顶部 1–5，原文 12、114–119 | 5c8721f957393499dae11ec7575c39d4093867e4。S02 保存后自动进题、S03/S04 安全空态。 |
| S05–08 | c036d63f3495d563ee4657dc3382ea79be91533f，顶部 1–5，原文 12、36、83、116 | 2829426bb4f9a9c237ae2b1a8c262d02378124c0。S05 当前可完成任务、S07/S08 连续导航和独立授权。 |
| S09–12 | 3bdae5864e0c8864cba5db08570574cbf32a173a，顶部 1–5，原文 12、44、76 | 7566eeca560717c781c1e5729a528367e0bbd32b。S09 合法通知回流、S11 发布影响摘要。 |
| S13–16 | 5aeec8a85536317bb629bf236334b7149b610cc8，顶部 1–5，原文 12、69、89 | 477276ef597ce48ef600b29e75e8eb6f106ad6d2。S15 受众影响确认、S16 推荐与正式转载分流。 |

静态总索引 blob 614cce16a9d8168e2880a97a2eaeba6c0ff05beb，一页入口 blob 625fa0077a22e3afde3101b43e17e45191e30279。 [固定 F-01 审计与原文链接](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/workflow/V2_F01_HISTORICAL_SNAPSHOT_READABILITY_AUDIT_03_20261119.md) · [固定 Owner 静态索引](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md)

### 43 PNG 素材清单

固定 CSV blob 9504976a336b9db5820ac927e877deeb4172bfa3。逐项文件名、包内相对路径、字节数与历史 SHA-256 均取该清单。筛选 filename 后缀 .png 得 43 项，18 项 approved-stage、22 项 exploration、3 项 future-meeting。来源记录为 11 月 18 日会话附件去重归档。三组均缺逐项权利人、许可及授权范围，上传与公开可用性保持未获核准。概念认可与素材授权各自记证。 [固定逐件清单](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ui-concepts-20261118/ALL_LOCAL_ASSETS_SHA256_MANIFEST_20261118.csv) · [历史来源](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_DESIGN_ASSET_COVERAGE_20261118.md)

按全部 43 个确切文件名、交接 ZIP 名及分卷前缀，对 EliteSync 工程、旧工作树、Codex 附件与本机常用交接位置做只读查找，未定位 PNG 原件或完整 ZIP。ZIP 历史身份为 EliteSync_V2_20261118_SESSION_HANDOFF_FULL.zip，48,346,194 字节，SHA-256 98b6c40c64468fa3482559d26c310c6c6929f74dd8cf22cb0d99a63e00221a2c。本轮原件复算 0/43，继续 PENDING_BINARY_UPLOAD。若 Owner 提供原件位置，可先完成逐项字节与摘要回读，上传和公开仍按具名许可决定。四份原始 SVG 继续沿其独立历史核验。 [固定 ZIP 身份](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/workflow/handoff-assets/ZIP_UPLOAD_INSTRUCTIONS_20261118.md)

## 3. RC-E2｜公网 HTTPS 与运行安全

| 项目 | 历史实证与本轮判定 |
| --- | --- |
| 仅 /32／规则 | FAIL，根因 UNKNOWN。单一获批桌面物理网卡对照中 TCP 22、80 到主机，443 超时且主机未观察到该来源的 443。云侧 8/8 自助检查未提供逐连接结果。仅 /32 再验仍失败。Owner 恢复全 IPv4 TCP 443，远端历史两路径在早一次同类恢复后严格 TLS 返回 200，最终一次恢复只有控制台读回。沿现行停止公网探测。 |
| 安全组与云防火墙 | 控制台证据对应阿里云轻量实例入站规则，/32 和全 IPv4 TCP 443 同时启用。独立 ECS 安全组的归属与配置 UNKNOWN。此次核对保存回执，当前云侧实时规则 UNKNOWN。 |
| Nginx 和上游 | APP、Web 管理分别限制获批来源；API 管理、激活及 Upgrade 继续拒绝。外层严格校验回环 HTTPS 上游。M1-R 保存配置显示 18446 网关接 staging-app:9000，PHP-FPM 运行。历史 /up、Web 登录页及旧服务基线有回执。现行公网生产保护范围 PARTIAL。 |
| IP SAN 与续期 | 历史正式公开可信 IP SAN、Certbot 5.4.0 与约 160 小时叶证书通过，80 为 ACME challenge-only。独立续期 timer 每日四次检查、0–15 分钟随机延迟且 Persistent；健康 timer 每半小时。staging dry-run、deploy hook、隔离回滚和网页 OnFailure 测试事件均有存档。正式自然续期 NOT_RUN 于本轮，当前叶证书、自然续期结果及实际事故告警送达 UNKNOWN。 |
| 容器与访问入口 | M1-R 历史只读应用镜像 sha256:cf7243d010ba792aa361d1acaf1f3080d7f24e65c242a2131bf4833d0b7fd2d2，属具名共享 Staging 历史实例，与本地 QA 镜像分别记证。Owner 内置浏览器管理登录有脱敏 302/200。独立 Chrome 管理登录 NOT_RUN。 |

本轮对 P1 交接索引中可定位的 11 份 JSON 回执重算 SHA-256，11/11 与历史索引一致，另读回两份 timer 模板及后续精确来源再验和控制台恢复回执。对外准入仍需证书自然轮换、受限来源拒绝、具名 Chrome 登录及告警的实际证据。若未来单独获准诊断，仅在指定时段记录同一源、已批准的 22/80/443 端口对照、云侧逐连接判决、主机入站计数、Nginx 来源与状态，按时间关联且预设停止和回退。现行任务没有开启该实验。 [P1 历史回执索引](V2_P1_PUBLIC_HTTPS_OWNER_WEB_HANDOFF_20261123.md) · [P0/P1 补证](V2_P0_P1_ADVISOR_FOLLOWUP_20261126.md) · [M1-R 容器证据](V2_M1_R_DEVICE_BACKEND_IDENTITY_AUDIT_20261126.md)

## 4. RC-E3｜设备、网络及自然离线观察

| 证据 | 判定 |
| --- | --- |
| M4-R 统一 APK | 本轮文件 SHA-256 a26145f85356dacfba614ffe782677716ce955b638edec1abf8d3394de089182，签名验证通过，证书 SHA-256 9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09。包 com.elitesync.v2m4journeyqa，1011807，10.1.18-v2-m3-wlan-qa，Android 调试签名。 |
| M4-R 后端与库 | 本地统一候选的 PHP 8.4.28、Skyfield 1.55／DE440s、iztro 2.5.8、lunar-php 1.4.7。历史隔离库 MariaDB 10.11.19，server ID 2621121，121 表、96 条迁移。历史镜像与 §1 本轮复用镜像相同。正式 GET/POST /api/v1/profile/natal、本人历史和旧只读投影的路由范围固定。 |
| Android 冷启动、M4-R 保存 | SCOPED PASS。固定本地 APK 经模拟器 ADB reverse 严格 TLS；正式提交、HTTP 与 MariaDB v1/v1、重入、退出重登及冷启动。该环境的设备链为模拟器。 |
| 一台实体与模拟器、WLAN | SCOPED PASS。M3/M3-R 原具名实机 Wi-Fi 发送中断／丢响应两项及媒体等各按原 APK、场景与回执。M3-R 最终 APK 模拟器复验为装机、哈希、启动。固定 M4-R APK 本轮仅做静态文件核验。 |
| M1 远程实机排盘 | SCOPED PASS。1011814 原实体 v3/v3，M1-R 将同秒入口 200 与容器 POST/GET 对照。由于缺请求 ID、路径和版本，跨端唯一绑定仍 PARTIAL。 |
| 双物理设备、移动网、独立 Chrome | NOT_RUN。双方授权、撤权、搜索、媒体、通知和缓存传播有本地合成证据及有限单机实测。两实体在真实 WLAN／移动网络和独立 Chrome 的同期状态传播未运行。 |

M3-R04 按原日志为 PARTIAL / INTERRUPTION_CAUSE_UNKNOWN。07:30:38 签发，07:31:23 最后核实同进程，07:34:23 首次无法核定，后两次心跳仍无法核定。07:41:45 宿主休眠晚于首次身份不明。代理记录一次置闸、25 次拦截和零次转发，日志覆盖外的签发与通信 UNKNOWN。原探针把 ADB 超时、应用进程消失及输出解析失败归并，异常的确切原因仍未知。

具名授权后的方案：用独立于对话的常开观察进程和独立入口，先在合成环境演练心跳中断和回收。只限定测试入口和合成会话，冻结服务端 UTC 签发与 86,400 秒到期，分别记录账户与设备绑定摘要、进程启动序号、boot ID、可信时钟、入口签发和放行计数。持久化区分 ADB 错误、解析错误、设备断开和进程变化，连续性中断即标 PARTIAL 或 INVALID。独立的恢复执行器在预定到期后恢复测试入口，异常须有审计回执与紧急恢复方式。到期前验同进程文字只读、媒体/发送拒绝，到期后验内容隐藏、授权到期和入口未续发，恢复联网再验证读权、代际和按需新授权。执行时段和具名设备由 Owner 决定，以专用入口避免影响日常网络。 [M4-R 中断诊断及统一候选](V2_M4_R_INTEGRATION_CLOSURE_REPORT_20261127.md) · [M3-R 实体回执](V2_M3_R_FINAL_CLOSURE_REPORT_20261127.md) · [M1 实体读回](V2_M1_NATAL_SAVE_READBACK_REPORT_20261126.md)

## 5. RC-E4｜三盘独立离线对照

使用 §1 固定源码和依赖锁，产品运行在无网隔离容器。仅合成出生输入。DE440s 读回 SHA-256 c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2。对照的规则、历法事实和数值引擎与产品分别记证。 [计算约定](../../../../services/backend-laravel/tools/natal/CALCULATION_CONVENTIONS.md) · [独立来源及脚本](../../../../services/backend-laravel/tools/natal/oracle)

| 算法 | 本轮结果 | 规则差异与剩余范围 |
| --- | --- | --- |
| 八字 | 94/94 四柱一致，94/94 签名从规范输入贯穿至计算结果；同一民用输入切换真太阳时设置会改变输入签名。香港天文台分钟表及独立干支算术的 64 常规与 24 原盲选样本，加 5 个立春两侧／子时边界和 1 个真太阳时跨日。Shanghai 民用 +08:00 转 UTC。 | 立春比较避开参考源 ±60 秒不确定域。年月用 TT 半开区间，日时柱依具名民用/真太阳时和 day sect 2。年/月、日/时分框架；保留现有起运 sect 和 Gregorian 规则标识。实际 lunar-php 1.4.7；旧 1.4.0 文档与兼容规则名称按历史口径解释。交运扩展、全历元、独立秒级节令和其它流派未全覆盖。 |
| 紫微 | 72/72 公历到农历年、月、日及闰月标记一致。72/72 命身宫、十二宫名/宫干和十四主星位置分别一致。含新年、闰月分界附近、23:30 子时等既有合成样本。独立历法基于香港天文台日期，宫星用独立规则脚本；产品 iztro 2.5.8。 | 沿当前天盘、闰月分日及子时规则。结果只支持所测流派规则与字段，亮度全表、辅曜、四化异文、流年及超出样本年代的历法精度仍待证。 |
| 西洋 | Skyfield 1.55/DE440s 与本地 Swiss Ephemeris 2.10.03 的 Moshier 路径对照 5 组合成 UTC 时点，每组核心十体。真黄道/真春分点的包角经度最大差约 1.086″、纬度约 0.276″。四个可算宫制样本宫尖最大差约 0.00055″，Placidus、Alcabitius、整宫均有覆盖。北纬 78° 两路均拒绝 Placidus。 | 产品为地心视位置，外行星目标 ID 4–9 为 DE440s 质心。参考模型、目标及时间模型差异尚未做逐项隔离归因。宫制比较使用同一 UT1 输入，不能独立证明地球时标误差。纽约 DST 折叠解析为 05:30 与 06:30 UTC，春季空档和缺折叠标志拒绝。独立时间方程对照 5 个样本，与产出整秒当地真太阳时标签至多约 0.54 秒差；另验本地太阳时跨日。全域历元、恒星黄道及扩展点的完整覆盖仍待更宽参考。 |

另用独立 ERFA 公式核对 1965、2000、2024 三个 TT 时点的 CRC1956 自定义恒星黄道偏移与平均 Lilith，最大差分别约 0.0000521″、0.0000284″。两路以相同 TT 标签和具名数学定义比较。该项支持所选定义和坐标旋转，官方 Lahiri、真交点及全域 Chiron 精度另待证。

核心离线比较为 SCOPED PASS。现有 API 的 UNVERIFIED 标识和算法合同继续沿用。历史 Chiron 离线对照及归因依固定资料所列样本范围。 [Chiron 独立参考](../../../../services/backend-laravel/tools/natal/oracle/CHIRON_REFERENCE.md)

## 6. RC-E5｜工程债务、媒体与数据库恢复

### PHP 8.4.28

全量退出 2、1,525 tests、28,035 assertions、69 errors、49 failures、4 skipped、2 risky。与 RC-F 最终在 1,525 个类名＋方法键上的错误、失败、跳过分类差异为 0。历史阶段 D 的 PHP 8.5.3 分列，1,498 项、83 errors、131 failures。保留阶段 D 的 214 条旧失败逐例索引，其中 RC-F 对照 118 条仍有错误/失败，95 条不再有同类标记，1 条旧用例标识缺席。RC-E 的逐例映射含当前结果、历史结果、定向复验状态和处置，原 XML 均为本机证据。

| 当前分组 | 数量与处置 |
| --- | --- |
| D0 旧写、旧资料反填与缓存重算 | 25，2 errors / 23 failures。AstroCanonicalApiTest 14 failures、ProfileBasicRecomputeTest 5 failures、V1007BaziProvenanceTest 2 errors / 3 failures、AuthPasswordApiTest 1 failure。按 Owner A 保留拒绝，先更新测试权威合同再验证；旧错误保留。 |
| 题库挂载缺失 | 36 errors，13 个测试类。把同一 Git 题库只读挂进新容器后，36 例中 22 无失败标记，13 转为断言 FAIL，1 转为 TypeError。残留聚于旧匹配预期、投影或解释夹具。补装题库消除了原缺件错误，残留仍待合同与夹具复核。 |
| 老 RTC/正式身份门禁 | 10 个 RTC/LiveKit connection unavailable；13 个正式资格前置门禁拒绝。按运行范围登记旧夹具契约，正式 RTC 与真实匹配未开放。 |
| 音频与紫微旧测试入口 | 3 个音频用例受硬编码 /ffmpeg/bin/ffmpeg 缺件影响，真实录音范围仍看历史具名实机；旧紫微运行器与适配共有 7 项，含 4 个 algorithm_route 字段错误、运行器可用性及旧适配断言。当前盘的 RC-E4 直接计算覆盖另一条路径，旧路径债务保留。 |
| 其余遗留与合同冲突 | 24 项，涵盖旧资格/状态、通知、工具历史、内容审核、旧传输包络及聊天搜索/引用。保留未证问题。注册可信离线 T0 的一条已知冲突在全量重现，旧测试期待注册不产出可信登录回执，当前 register 路径以可信参数签发。历史标为 P1 待 Owner 决定；公开注册仍关闭。 |
| 当前具名合同 | 本轮定向 V2PhaseCDataRightsTest 8/8、PrivateImageAuditTest 2/2。题库复验所在定向组合整体 55 项、1 error / 13 failures。RC-F 具名 PHP 8.4、合成 HTTP/MariaDB、Flutter 结果沿原范围。 |

旧 Android 历史宿主具有 Retrofit GET/POST astro 和 AppRepository 包装声明，未发现可证的宿主页面重调旧 POST。现 Flutter 本命正式保存走 /profile/natal，历史按归档读，星盘兼容页保留本人旧 GET 投影。实际旧 APK 安装面、活跃调用和迁移覆盖 UNKNOWN。保留稳定 409、只读兼容、合法历史与签名拒绝，等待具名客户端验证。 [RC-D D0 源码与调用面](V2_RC_D_OWNER_DECISION_DOSSIER_20261127.md) · [Q 逐例账及 T0](../q-20261120/V2_Q_ENGINEERING_REPORT.md#L374) · [RC-F 软件回执](V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md)

### 私有媒体及恢复

合成 MariaDB 历史审计回执为 3 个已登记资产、5 个实际文件，含未登记最终文件和 .pending 各一。审计核对实际是否存在、文件和数据库摘要、上传编号与账号、完成/处理中/终态失败、业务引用与可能回滚残件。未登记路径只见上传号摘要，不能恢复完整编号或断言文件可清理。单次扫描的候选孤立状态保留。RC-E 本轮两项审计定向通过，真实存储的保留、备份和删除运营证据仍待查。 [RC-F 私有媒体证据](V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md)

备份使用全新 MariaDB 10.11.19 源实例 server ID 2621271 与异库 2621272，双方无 TCP 网络。源库先迁移全量，写入两名虚构账号、一个私有作品和一条旧媒体资产，再回退上传编号迁移以构造旧 schema。以单事务按主键逻辑 dump，目标库恢复前无表；恢复后重导出与备份逐字节一致。备份为 187,043 字节，SHA-256 f3c4fe461617de661a3d214c81c9129622efca51e1f9578b48c4987ffa463d4b。目标库应用上传编号迁移后，具名旧数据摘要不变，旧资产编号为空、账号＋上传编号唯一索引成立。

恢复库迁移前后复测通过：跨账号对象读取 404；原作者真实请求渠道不可用；旧排盘本人读取响应带 private/no-store；错签名的合成命盘投影返回 STALE_RECALCULATION_REQUIRED 且不显示结果或版本。首次投影夹具用错字段名，Laravel CLI 打印 invalid_civil_date；纠正测试夹具后在同一恢复库重走迁移两侧，分别核对显式 PASS。错签名检查为内存投影，客户端磁盘缓存、实际异地备份、外部媒体文件恢复和生产恢复时间指标仍未验证。阶段 C 数据权利迁移的安全回退、索引与旧数据保留由 RC-F 原 MariaDB 专项支撑。 [RC-F 迁移回执](V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md)

## 7. RC-E6｜封闭内测准入矩阵

| 门槛 | 状态 | 准入判断及下一证据 |
| --- | --- | --- |
| 具名账号、Lifestyle、首页、进度、站内通知、内容、Buddy、Web 管理 | SCOPED PASS | 可继续已获授权的隔离软件 QA。已验收入口和错误表达按 RC-F/M4-R；真实用户及访客发布依外部门槛。 |
| 关系、授权、Block、消息与媒体 | PARTIAL | 具名软件和单设备部分 WLAN 场景有证。双实体及真实移动网 NOT_RUN，M3-R04 仍 PARTIAL。共享 Connection、私信、WSS 和生产 RTC 保持关闭。作为依赖这些功能的内测范围的 P1 阻断。 |
| 三盘保存与独立精度 | PARTIAL | 本机链 SCOPED PASS，M1 实机 v3/v3 有限通过，唯一后端绑定仍 PARTIAL。独立算法按 §5 样本通过。需要宽历元、边界与规则覆盖后才能审议全量精度门。 |
| 公网准入和管理 | PARTIAL | 历史 /32 FAIL、根因 UNKNOWN、自然续期未证、独立 Chrome NOT_RUN。当前规则、叶证书和持续告警缺现场证据。P1，维持当前受控范围。 |
| 处理主体、法域、跨境、真实对象权利和资产 | OWNER_PENDING / EXTERNAL_DEPENDENCY_OPEN | P0，需主体、实际处理链、专业审查、正式资产许可及权利渠道证据。F-01 READABILITY_PARTIAL，43 PNG PENDING_BINARY_UPLOAD。 |
| RC-D 决定 | PASS | 七项均有 Owner 正式记录。正式匹配继续有身份门禁，KYC 与真实 Push 不接入，真实对象删除受理不可用，真实访客正文默认空。 |
| 合成数据库恢复 | SCOPED PASS | 本机 MariaDB 10.11.19 逻辑恢复、具名迁移、权限与服务端缓存状态通过。正式备份保管、恢复和回灌后处置仍 NOT_RUN。 |
| 工程全量、公开注册、冷启动边界 | FAIL / OWNER_PENDING | PHP 全量仍 FAIL，继续对齐旧合同和现行路径。注册可信离线 T0 需 Owner 定义；公开注册保持关闭。已有模拟器冷启动与具名原件单列。 |
| 设备自然观察、双实体、移动网、独立 Chrome | NOT_RUN | 新观察、安装、共享环境、真实网络和具名真实账号均待 Owner 授权。 |

P0 先补齐实际运营与数据/素材使用依据。P1 按拟开放范围明确持续公网安全、真实设备、独立精度、可信注册及当前债务验证的放行条件。Owner 可以请网页 GPT 顾问审阅证据与拟开放范围，随后决定具体补证授权。若后续启动 UI-S，需另行确认范围、基线与验收，延续构成主义与二次元极简方向，保留明确确认、双方同意、独立撤权、退出及隐私控制。可沿现有入口记录减少重复输入和安全回流机会，正式 UI-S 维持 UI_S_DEFERRED。

### Owner 接续决定

1. 确认拟服务区域、运营与数据处理主体、实际处理/存储链及专业审查负责人。提供有权读取的 43 PNG 原件位置与来源，实际许可核实后再决定是否公开。
2. 确认限定内测候选范围，以及注册是否应创建可信离线 T0。对 P1 网络、续期和独立 Chrome 证据，按目标场景决定最小验收及对应授权窗口。
3. 确认是否优先具名启动 M3-R04、双实体或移动网验证。把需验证的 APK SHA、后端身份、入口、网络、操作时段和停止条件登记为单次授权。
4. 由网页顾问复审独立算法样本、规则与时标归因，Owner 决定哪些算法范围是拟开放场景的必要条件。

## 8. 本地证据索引及停点

私有原件保存在 D:/EliteSync/development/v2-rc-e-local-20261127。GitHub 同步使用此脱敏报告及三个工作流索引。Owner 可手动转交本报告给网页 GPT 顾问集中复审。总体状态维持 R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO。

| 本机回执 | SHA-256 |
| --- | --- |
| PHP 8.4 全量 JUnit | f9636e3e868d0cd2e8085f4040b9c71df42841c61cd4369de4ab7e656063335f |
| 118 条逐例处置映射 | 5d4791f836a642d0d568731567ee98959d2abdca6c03005f6c42b69427fbbd2b |
| PHP 8.4 挂载参考题库后的定向 JUnit | 8b705cfa91faa4fd72feaf34d24ea689c44717514aac37a56756c336ab561b64 |
| MariaDB 恢复库权限与缓存复核 | f7e4347c9b12d0af534daef7aa96280222c9f7a08d8f95d9de74bbe37bb72313 |
| 八字离线对照 | c845ca859468e1ba4827bfa8af696cf2eb884f516a286622d5b9f842e5a567a9 |
| 紫微离线对照 | 7245b583957b6e985cbb8611db976dd30752c81b80aaafa4578dab5696398bc7 |
| 西洋天体、宫制、真太阳时离线对照 | 45b5ab896bd5e51d620a051795ae2ae24f01004eb7f8f36cb148d14ffbf08a41 |
| 西洋自定义恒星黄道与平均 Lilith 对照 | d7ae392516a7fbf28d33b5f90261b4abd4dd34fc3b88110ebc971fee0760c910 |
| 离线对照运行脚本 | 1d53273f67dfcdad38590a4697e1e8f1ad8301ef31c3436cb74b05e615a39aaf |
