# EliteSync V2-Q Android 实机测试报告

日期 2026-11-20 至 2026-11-21。综合结果 **PARTIAL**。首次安装受阻后用同一 APK 安装成功，分两天完成具名实机验证与续测。两天的失败、环境拒绝和未运行项目均保留。生产判定沿用 `NO_GO`。[V2-Q 工程报告](V2_Q_ENGINEERING_REPORT.md)

## 设备、候选和测试条件

| 项目 | 实际结果 |
|---|---|
| 设备 | 单台 USB 手机，型号 25060RK16C，Android 16 / API 36，ARM64。 |
| 固定源码和工程基线 | 产品源码 `5e457fb0fd21c5978864f146d78120cc9a7d025b`，Q 交付 `b35f6d0aa43a80e648143a30fbb17a91c2bf922a`。 |
| 测试包 | `com.elitesync.v2qdev`，`10.1.18-dev / 1011804`，209,290,764 字节，APK 签名方案 v2 校验通过。APK 和手机安装后的 `base.apk` SHA256 均为 `db142f7b884589c62622dab8b3cc0e9672a67e33a094b62ffe0aa615ae1326d7`。 |
| 构建选择 | 使用 ARM64 Flutter Release AAR 与 Android Debug 宿主。私有副本仅调整独立包名，将宿主 `activity-ktx` 对齐到 `1.12.4` 解决重复类。按原版本补齐离线依赖。仓库产品源码未修改。 |
| 安装 | 首次 `FAIL`，Android 返回 `INSTALL_FAILED_USER_RESTRICTED`，设备侧具体原因 UNKNOWN。Owner 在场后用同一 APK 重试，`Success`，启动组件是独立测试包的 MainActivity。 |
| 服务与数据 | Windows PHP 8.5.3、Laravel、全新独立持久 SQLite，服务仅绑定本机回环。通过该次专用 USB 反向转发访问。使用两个虚构账号。好友、对方作品、搭子邀请及 Block 由隔离 API 置备，使用手机验证相应的产品展示和行为。 |

## 已执行的实机验证

| 功能 | 结论与实际证据 |
|---|---|
| 启动、访客专题 | **PASS**。冷启动到账号登录。访客可打开官方专题，显示目前无开放正文。真实授权正文读回 `NOT_RUN`。 |
| 注册、欢迎、登录 | **PASS**。A 在手机新注册，进入生活方式欢迎页，完成后跳过首次引导进入首页。B 在手机以账号密码登录。 |
| 生活方式探索 | **PASS**。五题逐题完成显示摘要。从摘要返回第 2 题改选，新选择立即出现在摘要。A 在线冷启动后仍显示偏好已保存。 |
| 首页精选、好友、搜索 | **PASS，具名片段**。精选与好友分别显示其合法合成作品，另一账号的 SELF 作品未出现在频道。好友频道输入关键词后保留匹配作品，可打开详情。Block 后 A 首页不再显示 B 的公开作品。 |
| 社区发布默认受众 | **PASS**。A 在手机发布纯文字作品，界面显示“双向好友可见”。隔离库只读核实受众与评论策略为 `FRIENDS + FRIENDS_ONLY`。媒体上传、扩大受众、旧深链 `NOT_RUN`。 |
| 评论和撤回 | **PASS**。A 在好友作品下提交评论，实际显示正文。确认撤回后只显示“评论当前不可见”。作品作者隐藏他人评论与独立回复 `NOT_RUN`。 |
| 删除申请与数据用途 | **PASS，拒绝合同**。评论数据页说明对象范围与展示撤回的区别，并显示暂无核实渠道。展示草稿用途页说明无法复用账号城市，并保留手填草稿入口。真实受理、删除执行和撤销后的跨设备传播 `NOT_RUN`。 |
| 搭子草稿与发现 | **PASS，具名片段**。A 保存本人搭子草稿。关闭请求许可时发现页拒绝，开启后可读空结果。B 的邀请已授权时 A 可见，B Block 后刷新，邀请和正文从 A 页移除，A 本人草稿保留。实际分页 403、发现发布和双方参加闭环 `NOT_RUN`。 |
| 搭子未确认后重试 | **PASS，首次请求未到达服务端的情形**。暂时移除本测试的 USB 转发后，在 B 的手机上保存草稿。页面提示未确认，保留草稿及原命令。恢复转发后点“原编号重试”，日志顺序为回执 GET → 创建 POST → 列表 GET。界面显示新草稿，SQLite 仅有一条对应记录。请求键未记录进访问日志，已提交但响应丢失分支及并发 `NOT_RUN`。 |
| 通知、待办和历史 | **PASS，具名片段**。A 在通知中心看到 B 邀请产生的最小提醒，点击后在既有授权下进入搭子页。Block 后当前提醒不再出现，历史只显示“通知已不可用”。待办标签可打开，待办正向办理与真实系统 Push `NOT_RUN`。 |
| 匹配、参与与自动化 | **PARTIAL**。匹配首屏、报名准备、自动化说明和空历史可查看，应用显示资格未满足、尚无轮次或提案、持续参与未授权。真实身份、有效报名、候选决定和正式关系闭环 `NOT_RUN`。 |
| 我的、权限与设置 | **PASS，具名入口**。完整打开我的、权限与说明、设置和账号设备页，看到本人操作与独立工具入口。资料编辑、展示发布、头像、反馈和辅助技术 `NOT_RUN`。 |
| 冷启动、撤销和切号 | **PASS，具名片段**。A 在联网时强停测试包后重启可恢复首页。撤销 A 当前测试会话后回到登录页，登录 B 显示偏好尚未开始，搭子页只出现 B 的活动，未显示 A 草稿。 |
| B 普通退出 | **PARTIAL / UNKNOWN**。手机已回登录页，界面提示服务端撤销尚未确认。停止前未核实服务端结果。 |
| 会话和私信 | **PARTIAL / NOT_RUN**。消息列表打开并提示需连接和消息同意。隔离接口置备连接时返回 404。当前 SQLite local 实例未满足关系运行环境要求，双方连接、私信发送、会话详情、语音与视频未运行。 |
| 手填三盘本命 | **FAIL，计算不可用**。手机进入独立手填，使用虚构日期、未知出生时间提交。页面显示保存结果未确认，重读保留输入。隔离库验证状态 `FAILED`，结果及结果版本为空。具体计算失败环节待诊断。 |
| 动态星盘与可选 MBTI | **功能受限**。动态星盘页打开但读取不可用，同一隔离账号接口复核为 403 `dynamic_environment_not_admitted`。MBTI 页面显示 410 `feature_disabled`。未继续计算或答题。 |

真实 KYC、外部 Push/RTC、MariaDB、跨设备以及正式 A6 继续为 `NOT_RUN`。旧排盘 A/B/C 策略和法律受理状态沿 Q 原记录。

## 11月20日暂停记录

收到 Owner 停止指令时，B 已退回登录页，测试包保留在手机。已移除本轮专用 USB 转发并停止回环 API。原安装失败、成功回执、设备哈希、页面快照、隔离 SQLite 和服务日志均保留。续测时先核固定包、设备及隔离 API，再核 B 普通退出的服务端撤销状态，按具备的安全环境继续未覆盖或失败功能。此前已通过的具名项目保留证据。

私有证据根为 `D:/EliteSync/development/v2-q-phone-evidence-20261120`。以下仅列文件校验值，原始界面与日志留在本地。

| 证据 | SHA256 |
|---|---|
| `apk-install-attempt1.log` | `8e2a11226066e37e1e28dba1a20c8433fc3c21dc49432f9d62739b928e93f04f` |
| `apk-install.log` | `c4aa470acafcf8576c15b0f0b5ae7e852d1ec5413372d0e6a9272e788e1306d3` |
| `apk-identity.txt` | `2de6bb9895fa7686c026520ff990b70605ad791401002f893040f19ab238a885` |
| `apk-signature.log` | `b9c6879e48d25a9786d2beb8a15738c06edce7d06f2722dd860894618592bd09` |
| `sqlite-migrate.log` | `b3494f12c8dd29062c0fd052a8b8afba91a2cf3355727c81eca2600f75e39e11` |
| `api-phone-retry.log` | `a1888105522b7e8e606614702e01757a977b4d12acce02bcd4a4223757ea184a` |
| `phone-sqlite-verification.json` | `351e3919f6eadafa03b77594d2324fbc1ed48f40031517004fe7e915c341c5ac` |
| `life-step-5.xml` | `db8c6891c58a44a663b5d2d7cd36dbcda6ed6f5f4c3210eb08c6a995e1c5ce33` |
| `09-lifestyle-edited.xml` | `22fd3f9871c6a11ab65a91bf280e9fc6ff0cdb6faa5a64a352a58efe60ef83ae` |
| `23-work-published.xml` | `0aed2638f8f58d925468bf7983c415fde03ed77d99f6b66982ba37ae10588eb6` |
| `17-comment-rights.xml` | `25f4f9d173aa88de9c2227e66c7fafec3830575e8c91031fab9fb74f5ae1290f` |
| `19-comment-withdrawn.xml` | `bc83ea9508e881dba69b7f9cf5a0c12dd6812ff76e1a82c6a0fae4e60b93e132` |
| `41-natal-result.xml` | `a0f08ff13babd7086cb9c7f4bb224a2b1668eced9e3bdfcc4bb1ef8be47b07ad` |
| `45-notice-opened.xml` | `defca99927ba891027148488d1b212598b13a8b981df193b46a4db5c76ee877a` |
| `46-buddy-after-block.xml` | `3d4abbd522e42dc8d028d03e4fc19a54f0caabb7f518839c1ae455761756c2cb` |
| `49-notice-history.xml` | `2532f591bc659d8e3752ae0e080f8d82890d38f1ce2a95e8d5f3df632ee6a75f` |
| `57-revoked.xml` | `8dd1aa2f47dbde5d802330099ad01cb5abd3a3a6650670fc68bdac6745c5d0ab` |
| `59-b-home.xml` | `6132fbc40e0d6a17e6e1089edfd7f0e245e573ab57b8e5a88fc20730e6a133e2` |
| `63-buddy-no-return.xml` | `22f0918337492eede068d24db9aabe1bb2cb0c03dbdf723d85854e7ffec65ae7` |
| `64-buddy-retry-result.xml` | `9d3470172d049faf64199fee753663a81886303abf7587d64a2f5ee42bed6e97` |
| `65-purpose.xml` | `ae5ca428c42dbdd431f68dc05de9537f7e7402fcde2bcef005785d2adec6540f` |
| `66-mbti.xml` | `551eefc761bc235ae7cf6742a25572b5d6210582936222fb25685d53b4099c92` |
| `67-dynamic-tools.xml` | `268ceb9ed81b5c51244ffbdc3a76de15a4cb5dee1046ba7bf2eed4314e233c4e` |
| `70-end-logged-out.xml` | `c6ecbfff8fde195d4a9e9cb7117a752b0d7344d4efda1bc4023839d0b26074a8` |

## 11月21日实机接续

实机复核仍使用同一独立包。手机和本地 APK 的 SHA256 与首次安装一致。先恢复原回环服务并核对 B 账号，再在不同回环端口新建独立 SQLite。第二套环境按仓库内建的 `testing + SQLite` 规则启用动态盘、MBTI 和关系测试，测试身份签发关闭，私有封面使用隔离本地盘。两套环境的记录分别保存。第二套只使用新建的虚构账号 C 和 D。PHP 8.5.3 与 APK 产品源码保持固定，未接真实供应商。

| 复测功能 | 结果与范围 |
|---|---|
| B 待确认会话撤销 | **PASS**。昨日旧手机会话仍有效，新登录后点击“完成上次离线退出的待确认撤销”。手机提示全部已确认。只读核对昨日对应会话已撤销、关联令牌数为 0。 |
| B 在线普通退出 | **PASS**。先回登录页并显示撤销暂未确认，后台完成后显示已确认。数据库核对今天的对应会话已撤销，关联令牌数也为 0。昨日和今日的手机会话分别核对。 |
| 连接、消息同意与私信 | **PASS，具名隔离链**。C、D 按正常 API 完成好友、双向连接和消息同意，D 用隔离 API 发送合成消息。手机 C 在会话列表和详情读到该消息，随后在手机发送回复，界面确认服务端已持久化，D 通过 API 读到回复。D Block 后，C 的旧消息接口返回 404，手机刷新会话列表后不再显示该会话或预览。实时 WebSocket、双手机互发、音视频 `NOT_RUN`。 |
| 私有封面与 Block | **PASS，读权链**。D 通过隔离 API 上传合成 PNG 并绑定好友作品。C 在手机好友频道打开详情，封面实际渲染。D Block 后，C 刷新旧详情，标题、正文和封面均从界面移除。以 C 身份复核旧详情和媒体字节接口均返回 404。系统相册选图、手机上传和短视频 `NOT_RUN`。 |
| MBTI 简版 | **PASS，仅启用后的隔离环境**。手机 C 答完三题、提交、显示服务端结果，并从历史列表读回。独立 SQLite 有一条测评记录。昨日默认关闭环境的 410 保留。 |
| 动态星盘 | **PASS，私有计算与手机读回片段**。隔离 API 用两套虚构手填输入建立双盘相位，手机从本人持久历史打开版本 1，显示双盘轮和相位。输入与结果版本均为 1，状态 `COMPUTED_UNVERIFIED`。手机从空表单重新计算、真实精度和其它盘型未验证。昨日环境拒绝 403 保留。 |
| 三盘本命 | **FAIL，HTTP 计算未完成**。原环境补齐锁定的 `iztro` Node 依赖后，手机 B 使用虚构日期和未知出生时间再次提交，页面仍提示结果未确认，数据库状态 `FAILED`。第二套环境另外配置可用本地 Python 与已核 SHA256 的 DE440s，已知时间的隔离 HTTP 请求仍两次返回 503 `natal_calculation_unavailable`，结果版本为空。同一持久输入在 CLI 调用计算服务可返回三个模块。HTTP 执行路径失败点仍 UNKNOWN。原失败数据保留。 |
| 私密资料昵称 | **PASS**。手机改写 C 的虚构昵称，界面明确显示服务端读回确认，隔离库记录一致。 |
| 私密资料说明 | **FAIL，文案与权限合同不符**。手机编辑页的保存说明仍称“完整出生资料用于本地真实八字”，并称缺时刻会采取默认午时。当前 V2-Q 后端保存账号事实时不自动启动独立工具，也没有恢复无许可计算。该发现涉及当前测试包的文案，未改变旧排盘 A/B/C 待决状态。[资料页源码](../../../../apps/flutter_elitesync_module/lib/features/profile/presentation/pages/edit_profile_page.dart#L156) · [资料保存合同](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php#L67) |

本轮测试结束时，C 已退出并看到服务端撤销确认，手机停在独立测试包登录页。已移除本轮 USB 转发并停止两套回环服务。测试包及隔离资料保留。有效匹配报名与候选闭环、真实删除受理、真实 KYC/Push/RTC、双设备传播与正式 A6 仍为 `NOT_RUN`。生产判定维持 `NO_GO`。

### 接续证据 SHA256

| 私有证据文件 | SHA256 |
|---|---|
| `77-retry-revoke.xml` | `032dad3dca8e1a86d52ba165a858adf681373dc7d2d8c30cc0412532bc65f4ee` |
| `logout-revocation-20261121.json` | `a0918e85e34d1520ed3f232eee185a075c569f71462e354bdf73b64db4344271` |
| `81-b-logout-confirmed.xml` | `a1bfe62a95b9de731cb8094fcc6e380bcef3fae91414221aed357679e71be234` |
| `logout-online-20261121.json` | `a9f67829d14ee3bc869a2fb01b34f6c5a71f4c7dfdf7f71f1e00e0ed52841646` |
| `feature-gate-20261121.log` | `aff9052c5a919ecb2fcc85ff3ef926f7abaf2b2dc83ceb8173f031e8e25abee4` |
| `api-phone-feature-runtime-20261121.log` | `6970b0f82b6c9896d59750fd1a73b15b6fe6913c33247bb6c0c5fe5ac2e94d5d` |
| `feature-fixture-http-20261121.log` | `16a7285945b82fc5359da6aea4844fb463172556633731bc299c8dcda7649329` |
| `86-c-message-sent.xml` | `17d57c6b2ae2a78c969560cb9fbad4d05205c2459696bfaf5a46ac5e34412295` |
| `89-cover-open.xml` | `4ac919bfc7210341f3662f65323cb6d216229c25148ba4ec29d4153a015538fd` |
| `90-cover-after-block.xml` | `7490a8283f0f8a3adafefca498bb3eff45a56ac83a6152eeaf2ddfe3e99e0692` |
| `91-chat-after-block.xml` | `1661486942510b929ff581d51527af976c1d5670f4e177b7ef411996efe01bab` |
| `96-mbti-history.xml` | `143a9b7566ebcc60da5466789ef4791edacf5ea5e084d5ed99fc3ed9693fa5f4` |
| `99-dynamic-result.xml` | `f3711b8db46a87ea81e08deffc108a95e405b01a34dc78b917b5e0fda2746fe0` |
| `79-natal-unknown-recovered.xml` | `a0f08ff13babd7086cb9c7f4bb224a2b1668eced9e3bdfcc4bb1ef8be47b07ad` |
| `natal-feature-cli-20261121.log` | `9511be4f6afeb4e5abebda38c3a2351d4ba3170bfa20f996ef86226b48c22d00` |
| `101-private-profile-saved.xml` | `772ce98f5f78b3bade8e5c10eaa13e7d3e1d861b52f232bdaa5a1abf5e8816b3` |
| `phone-feature-sqlite-20261121.json` | `b23faf68db653d1c17dbba62a8be35281fd9e01efbb336f002d43f50ea48a352` |
| `102-c-logout.xml` | `a1bfe62a95b9de731cb8094fcc6e380bcef3fae91414221aed357679e71be234` |
