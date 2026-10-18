# EliteSync v10.1.0 R1 同版接续结果

2026-10-19（Asia/Shanghai）

**V10.1.0_DEV_CHANNEL_CONTINUATION_DELIVERED / EXTERNAL_ICP_GATE_OWNER_DEFERRED / AC-10.1-08_PARTIAL / VERSION_NOT_ACCEPTED / AWAITING_ASTRA_REVIEW**

Owner 已手动派发本轮。已保全云端试点、核验既有源文件和备份，整理并恢复原有本机回环开发转发，完成端点配置身份及最小匿名读回。没有产品源码、算法、数据库结构或云端配置差异，不重建 APK 或重跑整版验收。**受邀同事外部 Web 后台仍未交付，AC-10.1-08 仍 PARTIAL；这不是整版接受或生产就绪结论。**

公司注册、网站/APP 备案、正式上架与运营推迟至功能完善、内部会议和质量评估后，由 Owner 决定。最新决定暂停公网恢复、Certbot 续期及443启用，覆盖旧实施报告中“备案解除后继续HTTPS”的旧时点安排；不是当前自动执行许可。

## 1. Authority 与身份

完整读取了[固定接续任务](https://github.com/zcx369658780/EliteSync-v10/blob/e802b926a95e49f7b8398fd85ac7ed8463777d0c/docs/versions/v10.1.0/DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_TASK.md)及[既有实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/939ac6f95d962bed8c75d872c9fa68be2a503933/docs/versions/v10.1.0/IMPLEMENTATION_REPORT.md)，读取实时 main 的现行入口、Owner 决定、工作流、路线图和恢复台账。原冻结 AC、原报告、旧接受记录与原始失败未修改。

| 对象 | 身份 |
|---|---|
| 启动核验 main | `e802b926a95e49f7b8398fd85ac7ed8463777d0c` |
| 接续任务 Blob | `f2c37373b4ae4ea6b208c2f7f52076d2ab73b437` |
| 原冻结 plan / task_order Blob | `d2123f345b9455d5db8311662be93ac69de795b6` / `f1a78c960b694a081a429e534bf66ea835067977` |
| 开发分支 / 起点 | `codex/v10.1.0-cloud-devpilot` / `939ac6f95d962bed8c75d872c9fa68be2a503933` |
| 原实施报告 Blob | `7757b1c47070e916b61a766c6d6f2a935db6ef54` |
| **仍实际部署的产品源码 Commit / Tree** | `997af1e58e8982eb791ead54861c23e1c1a6e4a2` / `f4d39c58785d3a1d64bccc276e6deff9fe64dae4` |
| **开发候选 apps / services** | `a1fef5535db3e196580f437040dd5b1f86fd70db` / `7cbd25640b8c0f0c23de7e32cb60cb2e04bc9166` |
| 正式 main 的已接受 apps / services | `fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7` / `29cedff599411c7c246ba32e62d53b5d63e28f3f` |

main 的后续变化是当前治理/任务资料；未把候选整分支合 main，也未用 main 的前版产品覆盖试点源码。专用开发树继续复用。R1 产品/测试变更路径和新增产品 Blob：**空集**。唯一结果报告为本文件，活动入口仅在 `CURRENT_STATE.md` 前置本次状态，历史正文原样保留。报告交付 Commit/Tree 是本文件所在 Git 对象，由普通发布后的远端回读给出，不与部署源码锚混淆。

## 2. 资源保全与实际运行终态

本轮云端管理检查只执行已有严格主机密钥验证 SSH 通道内的文件 hash、归档可读性、进程/监听及服务状态查询。没有直接执行 DB 查询/写入、迁移、seed、重启、停服或部署。最小 HTTP GET 另走原有受控隧道，正常请求可能产生框架会话/日志，不声称整个运行库前后字节不变；不访问公网域名或公网裸 IP。

2026-10-18 23:10 UTC（本地 10-19 07:10）核验：

| 核验 | 结果与证据等级 |
|---|---|
| 当前部署源 | **658 文件逐项 SHA256 相同，0 mismatch**；2个 Git storage 脚手架仍按原保留路径核验。只证明这658项，不涵盖全部运行文件 |
| 旧必要配置 | 原备份清单中的8项内容与 mode 相同 |
| 本版8服务 | database、redis、php、http、websocket、queue、rtc-authority、rtc 均 active/running；非 authority 均 disabled，authority static；不是已经配置开机恢复 |
| 运行隔离 | 本版DB/Redis/API/WS仍各用既有 loopback；RTC `PrivateNetwork=yes` 且namespace与host不同；3个专属Unix socket均0600；host无本版RTC TCP监听，无443监听 |
| 旧SFU | 容器ID、image digest、StartedAt与原证一致；未重启或复用其密钥 |
| SSH撤回状态 | 主sshd_config SHA256仍为原始 `233de7bf77edb119c8d8acae8a88e3c2966066a796fc5b02bfa5543608b284d6`；未恢复同事账号方案。锁定探针账号/空公钥状态沿用旧撤回证据，本轮未重新查询shadow/改账号 |
| 原dirty根 | HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`；index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`；porcelain SHA256 `2ad56cde4151ea497ea97755fbe31a0b257b616e4fe725e243628ad03e71758d`，与原基线相同 |
| 保护范围限制 | 未建立全部dirty/untracked/ignored文件的初始字节表，**不声称全资产逐字节相同**；其它worktree、卷、旧媒体、备份、原证和审阅分支没有清理操作 |

五份备份均原位置保留，摘要相同、0600、可读；私钥/数据库实体没有下载或上传：

| 备份（完整受控路径见原报告） | SHA256 |
|---|---|
| 旧管理员/必要配置归档 | `43285cbdbc6f9216487421b9906f04e82557423e31be0f8cdc18c97fc3d0564e` |
| cadence前虚构库dump | `a157176d0043b68566bf3779314f61c692d2b2c5668bd8c5ef77ee4dc18c7140` |
| 最终重启前虚构库dump | `230e95022d96196f630f77387f130fe0e1a5cd9d0dff51a1922b78bd78d7724f` |
| SSH修改前归档 | `b492a1e40343609aa96134378b648d804637f44d4710f80ed13ff59c108cfe60` |
| HTTPS尝试前归档（含私钥，仅受控云端） | `e236ef4766989ccac97266c67eca00ccfc83c3c24ba9bf97be1e703126fa0e4d` |

当前虚构开发库的数据内容、旧管理员记录和迁移行与历史备份的逐行一致性，本轮 **NOT_RUN**；复用原报告的先备份/重启/持久读回结论，不冒称今日重新验库。

**建议 KEEP_RUNNING，实际未停服。** 快照时8个服务 `MemoryCurrent` 合计约259 MiB，整机约1.58 GiB内存、约612 MiB可用，load约0.26/0.16/0.15；shared占用约857 MiB。这是瞬时读数，不是容量压测或费用估算。维持条件是现有ECS、持久目录、专属配置/依赖及loopback隔离保持，Owner本地隧道会话存活。没有新增云资源或付费服务。

将来若 Owner 决定 SAFE_PAUSE，应先确认无开发写入，按依赖顺序仅停本版RTC/authority、HTTP/WS/queue/PHP，再停Redis/DB；保留所有文件/卷/备份。恢复时先核release、配置、DB/datadir身份，再按DB/Redis→PHP/HTTP/WS/queue/authority→RTC启动并做最小读回，最后恢复Owner本地隧道。该停/启方案**未执行、未设自动化**。灾难恢复、缩列或把旧管理员备份导入虚构库均不在本轮执行范围。

## 3. 固定且可替换的开发配置

本轮 LOCAL_ONLY 新增 `r1-20261019/dev-profile.json`，集中描述已有 APK 的六个 build-time define 与原有三项转发；恢复工具消费它并与旧 `apk-identity.json.flags` 精确比较，不相同即拒绝。**它没有改写 APK 或替代客户端实际编译参数，也不是新的生产配置系统。** 未来受权切换域名时先改这一份准备清单，统一传入 Android Gradle 的 `flutterDartDefines`，该构建链再传给 Flutter；仍须重建、核验两级参数一致和受影响实测，不会运行时偷偷换址。

当前唯一复用配置：

```text
ELITESYNC_V10_1_0_PILOT_BUILD=true
ELITESYNC_PILOT_API_BASE_URL=http://127.0.0.1:8030/
ELITESYNC_PILOT_WS_BASE_URL=ws://127.0.0.1:8030/
ELITESYNC_INTERNAL_DEV_PREVIEW=true
ELITESYNC_MATCH_ROUND_CONTRACT=true
ELITESYNC_ADMIN_MATCHING_OPERATIONS=true
```

profile SHA256：`0e8b895cc84df35d48aa1b6318f881a50d7bcf3fa54b40ae1a6a4c847471d144`。普通构建参数、云端.env、Nginx、算法配置未改变。

| 通道 | 实际端点类别与映射 | 传输/权限 | 本轮证据 |
|---|---|---|---|
| APP API | APP loopback8030→既有ADB reverse→Owner主机loopback8030→原SSH转发→云loopback8030 | HTTP仅受控本机段，跨机器SSH加密；Laravel token/禁用/同意门保留 | 原APK/产品hash一致；恢复本机隧道后 `/up` 200、匿名profile401；APP链复用旧实装证据 |
| 独立Web管理后台 | Owner受控浏览器loopback8030 `/admin`，同一云端Laravel/DB | 手机号/密码＋独立Web会话/角色门；不向同事交SSH账号；不是公网入口 | `/admin/login` GET200仅证明登录页可达；登录、退出、角色变化与失效复用原真实浏览器证据 |
| 消息WS | **当前消费者仍由API派生loopback8081**→原SSH转发→云loopback8031 | 本机WS段＋SSH；token/actor/peer/当前授权及poll重验 | 本机原映射恢复、监听归属核验；真实101/消息/撤权关闭复用旧证据。配置中的WS8030不是当前聊天实际消费端点 |
| RTC信令 | 由同一已鉴权API join-info返回，当前专属HTTP代理转Unix信令socket | token/call/当前CN/MC/authority；云内private namespace | 源/部署身份复用；本轮不创建call、不重测媒体 |
| RTC媒体 | APP loopback8033→既有ADB reverse→Owner loopback8033→原SSH到专属Unix socket | host无RTC端口；socket0600；private namespace | 恢复**原有**本机8033映射；媒体/撤权复用原call证据，非本轮新测试 |
| 私有LAN/VPN或同事远程访问 | 未建立新方案、未核验新路由 | 不授权新代理/CDN/境外迁移或备案规避 | **NOT_RUN；外部受邀Web访问仍PARTIAL** |
| 公网域名/裸IP | 不作为本轮APP/Web开发入口 | 不续证、不启443、不新增监听/端口映射/防火墙/安全组 | **OWNER_DEFERRED / NOT_RUN**，未再次探测旧备案拦截 |

启动时旧本地隧道PID已不存在、相关本地端口无监听。这是原证已说明的会话结束限制，**不能把上轮“转发可用”当作今日事实**。本轮核验端口空闲后，在隐藏后台进程恢复完全相同的8030/8081/8033三项原有转发；仅绑定127.0.0.1，StrictHostKeyChecking=yes、BatchMode、转发失败退出、keepalive。没有新远端监听或新转发目标，没有重置或导出业务凭据；新PID和私密SSH定位留本地。未启动AVD、APP，未增改ADB reverse，因此当前设备侧状态不声称已重新检查。会话结束后需按身份核验再恢复，不能把这个Owner工具包装为同事长期访问设施。

## 4. 有限边界核查、复用与观察

图谱未索引本专用树，助手按本树源码读取/搜索；没有借用原dirty根旧图谱。Android、Flutter、Laravel、WS与RTC核查结果：

| 检查 | 结论与准确范围 |
|---|---|
| pilot非开发构建 | Gradle拒绝pilot release/profile任务，并禁用相关非debug变体；native还需DEBUG＋PILOT。**此结论仅覆盖pilot通道，不把所有legacy普通构建宣称已全局加固** |
| Intent/bootstrap换host | pilot native忽略运行时endpoint覆盖，Flutter要求与编译配置精确一致，不匹配fail-closed；复用原冷/热Intent与文件负向实测；本轮源码hash未变 |
| 非授权明文地址 | pilot API只接受精确loopback8030或显式HTTPS，WS配置只接受指定loopback或WSS；公网HTTP负例与错误authority/userinfo/query有既有测试。当前实际聊天8081另以原专属隧道承载 |
| TLS校验 | 本轮未关闭或修改TLS验证；当前复用通道是SSH加密，不声称已经实测HTTPS/WSS证书。公网TLS、证书错误拒绝端到端测试本轮NOT_RUN |
| 跨账号/当前同意 | 复用原API/WS/媒体/RTC正反例；WS核对token actor=userId、peer能力、过期和持续重验。没有删除鉴权或为管理员增加私密资料读取权 |
| 跨环境 | pilot端点与独立包身份、云DB schema/配置门及namespace保持；本轮读取部署/映射身份。客户端没有额外RTC join-info host白名单，不声称已穷尽跨环境攻击路径 |

**两项保留观察，不标成已修复：** Android `network_security_config.xml` 的base-config仍允许较广的明文，真正pilot API门由现有代码收窄；它不是系统级“所有SDK均只准loopback”的证明。RTC客户端直接消费可信后端返回的join-info URL，缺少单独pilot host白名单；当前控制依靠本版后端配置/鉴权、隔离代理和实际已核转发。普通legacy构建仍存在旧端点/覆盖路径，未纳入此次新开发入口，也未运行。R1没有向这些路径写入公网IP或把它们包装成合法对外方案。未来若扩大分发/切换网络，应先处理对应加固与测试，不凭本报告放行。

原call7同一通双向合成视频/非零PCM、重入、end DB/room终态和authority断桥；call10 APP视频；APP→Laravel→持久DB、管理员/匹配/CN/MC/媒体/星盘/重启等均按原报告范围复用。**human audibility/AEC未测，call10模拟器音频RMS0不得拼接成双向有声。** 星盘保持 `COMPUTED_UNVERIFIED`、既有科学/许可限制。

原PHP16失败、matching integrated smoke stale字段失败、week_tag原失败、vendor classmap/WS/SDK/媒体harness/SSH/HTTPS预检失败、v10.0.9回声及旧/up UNKNOWN全部保留。未因本轮 `/up`200倒填旧超时根因或旧call65终态。

## 5. 新证据、命令退出与NOT_RUN

原证位于原 LOCAL_ONLY 根下的独立 `r1-20261019/`，旧日志没有覆盖。新记录使用完整文件名追加扩展名，避开旧封装对带点名称使用with_suffix的碰撞风险。公开内容仅为本报告的安全摘要；未把私密JSON、原始响应、helper、数据库或配置上传产品分支。下列操作不是Astra独立实测。

| 本轮检查 | 实际结果 / 原证前缀 |
|---|---|
| 固定task与实时main文档API回读 | 成功；task Blob如§1，逐文件stdout/stderr留 `authority-api`、`authority-file-*`；本地CRLF与API LF的字节差不等于冻结Blob变更，Git对象已另外核对 |
| 云端最小只读检查 | `cloud-readonly` exit0；stdout SHA256 `6b420b2ef0ce800a365fc7b2cc90c7a290558326f288e142afb969289dc48fbf`；stderr为空（SHA256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`） |
| 本地profile/语法/APK/产品身份 | `configuration-check` exit0；3个新LOCAL_ONLY helper用AST解析；profile精确等于旧APK flags；无产品差异；stdout SHA256 `9fad4abc63df38be5c93437cdd0c2e8959e82fccffb29a43071fb2582b905d0e`，stderr为空 |
| APK签名/包身份 | `apk-signature`、`apk-package`均exit0，使用已有SDK工具与JDK，无全局升级；debug签名，详见§6 |
| 隧道恢复及最小读回 | 新隧道进程存活、三原端口可连接；`minimal-private-readback.json`关联三次GET，各断言exit0；HTTP response SHA256分别为 `b306be7bc79f6b36399bb34ff0df20ac6990a5f65871b125b19e44159603cfdf`、`75045c98d3a4c4b3be7ef3954364115c4fc44898cbf60a289c24e0fd3b79063c`、`24adaba268a402c0169ffe6b7fe3139bbbc804ff0389b6f4465bcb5c72c32e03`。响应原件LOCAL_ONLY，登录页含会话材料不公开 |
| 旧测试回执真实性复核 | Flutterpilot3项、旧端点/router/socket10项、PHP共享门73项350 assertions、Workerman19项113 assertions；4份原manifest exit0及stdout/stderr摘要重新比对一致；**不是今日重跑，且不相加为覆盖总数** |
| 本地终态 | `final-netstat`、`final-owned-process` exit0；原三端口均只绑定loopback且属于记录中的SSH PID。原dirty根HEAD/index/状态摘要再次一致；候选whitespace检查exit0 |

本轮工具失败也保留：最初在未fetch的本地对象读取R1任务路径失败（外层exit1，内部Git退出码未单独捕获），随后固定GitHub API完整读取成功；首次逐行解码base64导致展示乱码，改一次性JSON/base64解码后核定真实Blob。一次对绝对路径拼接glob的rg查询报Windows路径错误、命令链exit1；一次在隧道脚本成功打印后查询不存在的JDK候选路径使外层命令exit1；后续定位实际已有JDK并完成签名检查。它们不是产品测试失败，也不将外层exit1改写为exit0。上述早期命令原stdout/stderr/exit保留于本任务工具记录；隧道启动脚本父进程的独立stdout/stderr/exit三文件**未另存**，不伪造完整命令回执，已保存子SSH stdout/stderr、PID及HTTP读回。

最终一次 PowerShell `-File` 只读核验被本机脚本执行策略拒绝（`final-tunnel-state` exit1，原stdout/stderr已保存）；没有修改或绕过执行策略。改用已有系统程序netstat/tasklist核对进程和监听，均exit0；进程命令行的最终重读NOT_RUN，精确映射依据本轮启动源码、profile与成功转发读回，不把后续监听核验说成命令行复读。

本轮明确 **NOT_RUN**：新APK构建/安装、启动APP/AVD、重新登录/写资料、真实WS消息、RTC call/媒体/真人听辨、全量PHP/Flutter/算法验收、数据库内容比较/迁移/seed/恢复/服务重启、外部域名/IP/备案403复测、Certbot续期、443启用、外部管理员登录/邀请同事、安全组/防火墙/UAC、费用购买、备案账户查询/申请/身份证上传、main产品集成及下一版本。

## 6. 将来备案所需技术资料（仅准备，不提交）

| 资料项 | 已知事实 / 待核 |
|---|---|
| 名称/图标 | 当前Android展示名EliteSync；Manifest引用ic_launcher/ic_launcher_round，资源引用现有drawable/logo.png。正式上架名称、商标/图标权利与最终尺寸由Owner另核 |
| 类别/语言 | 现有社交婚恋定位；当前抽查中文界面，包含资料/问卷/匹配、独立关系和同意、文字图片短视频、RTC、星盘。不是平台已核定的备案分类；语言完整覆盖、内容分类及星盘内容合规待正式评估 |
| 测试包 | `com.elitesync.v10100pilot`，`10.1.0-devpilot` / `1010000`，debug-only；APK 214435684 bytes，SHA256 `a19ea2a365ae4c7a1976dbb55c6cc208aa465c0bf9a46c2a37e272a842fcb0a7` |
| 普通/未来发布包 | 仓库普通applicationId为`com.elitesync`，旧默认版本0.08.04/80400；**不是已决定的v10.1.0正式发布身份**。最终发行包名、版本/渠道、签名与升级连续性须Owner冻结 |
| 签名 | 实际apksigner verify成功，证书DN为Android Debug；证书SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。不得当作正式上架签名。未来从实际待交付APK运行SDK `apksigner verify --print-certs <apk>`并关联APK摘要、包名/变体；不导出/提交私钥，不伪造备案指纹 |
| 域名/IP依赖 | 当前试点仅§3受控loopback/SSH/Unix通道；已有域名slowdate.top的公网恢复延期。云主机定位、私网及真实IP在受控资产表，不写公开材料。将来逐项核API、Web、WS、RTC/TURN、媒体、更新/推送/地图等真实启用依赖与SDK数据流；未实用的历史配置不冒充当前必需服务 |
| 后台 | 独立Web `/admin`，手机号密码、独立会话、服务端角色/权限；同源Laravel和虚构开发DB。APP不新增管理员面板；同事不SSH。外部后台仍PARTIAL |
| 主体与资质 | 主体名称/证件/负责人/联系方式、网站/APP备案/接入信息、域名实名、签名/包名一致性、隐私与SDK清单、数据保存与删除机制，均需未来合法准备。**公司主体建议不等于已证实婚恋社交必须公司或某行业前置许可**；由属地通信管理局、接入商与适用规则核定，未知项待核 |
| 运营触发条件 | 功能恢复和安全欠账收口→Owner与同事内部质量会议→明确运营主体/数据用途/合法访问与费用→咨询并判断资质/网站及APP备案→获得相应条件后才批准公网/证书/上架和受邀访问验证。本轮没有替Owner作这些决定 |

已读取任务单给出的工信部备案办法、APP备案通知及阿里云说明引用作为边界定位；**本轮未另行在线复核政策时效或作法律意见**。不通过裸IP、端口、代理、其它域名或境外资源规避现有拦截。未注册公司、购买许可、申请版号或访问Owner备案账户。

## 7. 非作者复核与交付边界

只读助手分别核查端点源码与备案材料依据，未访问服务器/API/DB、操作设备或Git写入。其关于聊天WS实际派生端口、Android明文策略范围和RTC URL约束的发现已体现在§3–4；主代理核对当前消费者，未把“WS配置函数不回退”误写成“聊天消费者已使用该字段”。

最终非作者复核由独立 GPT-6.1 Sol/high 助手 `r1_final_review` 只读执行，结论：**未发现本轮同版接续报告阻断项**。它核对了无产品差异、profile/主要命令/三次GET摘要及三项回环映射；没有自行执行服务器、网络、设备或Git写操作。其要求的debug-only范围、WS实际8081、RTC无客户端host白名单、TLS未实测与设备侧未重验均已保留。复核是内部审查，不能替代Astra。无产品差异所以原产品非作者审查继续有效，本轮重点是报告事实、配置范围和保护边界。

交付只允许精确两份Markdown，排除并保留两处既有未跟踪缓存目录；在原开发分支普通non-force发布，并通过GitHub Commit/Tree/两个Blob回读核验。该交付对象身份以本文件所在固定Commit和集中交付回执为准；LOCAL_ONLY原证追加 `delivery-*` 命令流与 `github-delivery-readback.json`，不为填写自引用SHA而改写产品源码或原实施报告。main保持原独立身份，不推进接受或集成。

**出口保持：DEV_CHANNEL_CONTINUATION_DELIVERED / EXTERNAL_ICP_GATE_OWNER_DEFERRED / AC-10.1-08_PARTIAL / VERSION_NOT_ACCEPTED。** 完成本轮后停止，等待Astra独立审阅；不恢复公网、不清理资产或审阅分支、不执行K10、不启动后继功能版本。
