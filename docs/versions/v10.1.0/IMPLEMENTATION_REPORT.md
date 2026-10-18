# EliteSync v10.1.0 实施交付报告

**2026-10-18 — V10.1.0_PARTIAL_DELIVERY / AWAITING_ASTRA_REVIEW / NOT_ACCEPTED**

本版已完成隔离云端部署、专用管理员、真实 APP/API/数据库/匹配/消息/媒体/星盘/RTC 联调和受控重启读回。**AC-10.1-08 仍为 PARTIAL：当前外部域名请求收到ICP备案拦截页，Web管理员入口尚未交付。**Owner最新明确：管理员使用独立Web后台、以管理员手机号和密码登录；同事不需要服务器账号或SSH，APP旧管理员面板已抛弃，本版不恢复。Owner已进一步批准免费续期现有证书并恢复仅`/admin`的443 HTTPS；但外部ACME路径预检收到403，尚未触发实际续期或启用443。原受控SSH仅为Codex执行环境，不是同事访问方案。

这是一份集中部分交付，不申请完整功能接受或生产就绪。所有运行结论是 **CODEX_EXECUTED / LOCAL_ONLY_RAW**；内部非作者复核不是 Astra 验收。冻结 plan/task_order、旧接受记录与失败原文保持。没有合 main、清理审阅分支或启动 v10.1.1。

## 1. Authority、代码与部署身份

| 对象 | 固定身份 |
|---|---|
| 启动及交付前实时 main | `d80d3d0d1650e73e9654362d3a1491450687cdee` |
| 冻结计划 Blob | `d2123f345b9455d5db8311662be93ac69de795b6` |
| 冻结任务单 Blob | `f1a78c960b694a081a429e534bf66ea835067977` |
| v10.0.11 功能接受记录 | `513d7c3adbf49a59decad8f3c8d82510e28da8de:docs/versions/v10.0.11/acceptance.md`，Blob `e19b4fd41f5cd59f8430b1db129222446353899d` |
| 接受产品起点 | `78ab7827b258cb649920e5121f24d506dae2a93c` |
| 接受 apps / services | `fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7` / `29cedff599411c7c246ba32e62d53b5d63e28f3f` |
| 本版分支 | `codex/v10.1.0-cloud-devpilot` |
| **最终产品源码锚** | **`997af1e58e8982eb791ead54861c23e1c1a6e4a2`** |
| 产品源码 Tree | `f4d39c58785d3a1d64bccc276e6deff9fe64dae4` |
| 本版 apps / services | `a1fef5535db3e196580f437040dd5b1f86fd70db` / `7cbd25640b8c0f0c23de7e32cb60cb2e04bc9166` |
| 云端 release | `/opt/elitesync-v10.1.0-devpilot/releases/997af1e58e8982eb791ead54861c23e1c1a6e4a2` |
| 部署源包 SHA256 | `8f5ab80c8a1580337afb4a26eb8170d2b1e435d2fe5ab5c0ad016e878b394b59` |

冻结文档的 services 字符串有抄写错误；本次从接受源码和实时 main 独立读取到上表相同的完整对象，未改冻结记录。功能 acceptance 位于其固定接受分支对象，不能假设 main 当前含该文件。

2026-10-18 13:11:53 UTC 的云端实际文件回读：交付源包中 **658 个文件全部 SHA256 一致**，其中两项 Git storage 脚手架在保留的 `storage-git-scaffold` 核验。运行 storage/.env 与运行依赖单独管理，未冒充 Git 源文件。当前 vendor 位于本 release，四个实际 PHP 类 ReflectionClass 路径均落在最终 release，避免旧 vendor classmap 偷载旧类。后续报告/证据提交不改变产品源码；交付 Commit/Tree 以本文件所在 Git 对象及远端回读回执为准。

## 2. 云端隔离、管理员、备份与回滚

复用现有阿里云主机和已验证 SSH 身份；敏感主机/密钥定位只留本地。旧 `/opt/elitesync` 无 Git，旧部署 Commit **UNKNOWN**。旧 MariaDB、Redis、Nginx、FastAPI、WS、LiveKit 未被本版替换或重启；旧 WS 原已有自动重启状态不冒称稳定。

本版独立代码目录、nologin 服务用户、MariaDB 进程/datadir/schema、Redis/队列前缀、PHP-FPM、Nginx、WS、RTC 及私有媒体。数据库 `elitesync_v1010_devpilot`，专属 loopback `43330`；Redis `63330`；API `8030`；WS `8031`。新库从空表建立，迁移现为64项，未导入旧用户、出生信息、消息或媒体。

管理员原认证链无法安全交付原密码，按 Owner 决定创建新开发管理员 `id=1`，正常密码哈希，未改旧管理员密码。新库另有虚构 Alpha/Beta 账号和已禁用探针；账号不是实名验证。Alpha/Beta 为既有真实执行合同要求的正常开发账号类型，`is_synthetic=false` **不证明真实身份或真实资料**，并排除指标。新凭据在云端专属 private 文件0600，本地使用当前 Windows 用户 DPAPI 加密和受限 ACL，文件名 `owner-credentials.dpapi`；密码、token、hash及密文实体均不入 Git。附LOCAL_ONLY手动查看脚本`Show-DevpilotAdminCredentials.ps1`：默认遮蔽密码、仅当前Windows用户解密，不向终端输出凭据；仅做语法检查，未自动打开或截图。管理员权限没有扩展为任意私密星盘/媒体读取权。

| 备份/保护点 | 身份与验证 |
|---|---|
| 写入前旧管理员/必要配置备份 | `/opt/backups/elitesync-v10.1.0-20261018T114116Z-a96c95c9/administrator-config-backup.tar.gz` |
| 上述归档 | SHA256 `43285cbdbc6f9216487421b9906f04e82557423e31be0f8cdc18c97fc3d0564e`，8074 bytes，12 members全部可读；4条管理员认证记录、57条迁移记录及8项必要配置；目录0700/归档0600 |
| cadence 迁移前新开发库备份 | `shared/private/pilot-before-cadence-migration.sql.gz`，SHA256 `a157176d0043b68566bf3779314f61c692d2b2c5668bd8c5ef77ee4dc18c7140`，143264 bytes，可解压回验 |
| 最终受控重启前新开发库备份 | `shared/private/pilot-before-final-controlled-restart.sql.gz`，SHA256 `230e95022d96196f630f77387f130fe0e1a5cd9d0dff51a1922b78bd78d7724f`，156542 bytes；解压 SHA256 `897b8ca2aae3f39ea5e21d913c9bfe3f572c7c93868d14f674146111c339bc13` |
| 最终配置回滚点 | `shared/config-before-997af1e5`，此前 release及其配置备份均保留 |

最终回读：旧8项配置内容/mode、4条管理员认证记录及57条迁移记录均与起点备份一致，归档摘要与可读性保持。没有旧全库导出，不声称对未读取的旧全库或媒体作了逐字节证明。

最小回滚是只停止 `elitesync-v10100-{rtc,rtc-authority,http,websocket,queue,php,redis,database}`，撤下本版受控客户端转发，保留全部目录/数据/备份；旧资源本来未被替换。若需应用回退，先停本版写入，校验选定 release和配置备份，只切本版路径；**不要把旧管理员备份导入虚构库，不自动缩列或恢复旧生产库**。在真实 MariaDB 上调用本版 migration down，因已有超过16字符 cadence明确拒绝，拒绝前后导出完全相同。破坏性 restore/缩列/清库均 NOT_RUN；备份解压可读不等于完整灾难恢复演练。

## 3. AC-10.1-01 至 AC-10.1-10

| AC | 结果 | 实际证据与限制 |
|---|---|---|
| 01 云端身份与隔离 | **PASS** | 实际release/类路径/658文件核验；独立DB/Redis/目录/服务；旧资源保护回读；RTC最终独立network namespace。初次SFU暴露监听失败另见下文，不抹去。 |
| 02 备份与管理员 | **PASS** | 先备份再新建；真实浏览器后台登录/退出、普通用户拒绝、旧cookie退出后302；既有管理员session角色降级后403，角色已恢复并退出；禁用探针旧token401/403。 |
| 03 APP/API | **PASS（受控转发范围）** | 独立实装APK→ADB reverse→既有加密SSH→云Nginx/Laravel→独立MariaDB；真实登录、本地退出再登录、资料输入/保存/读回。不是本地Laravel/mock。APP退出沿用清本地session合同，服务端logout endpoint不存在，不声称logout撤销token；refresh旧token拒绝已实测。 |
| 04 匹配与关系 | **PASS** | 两虚构账号各20道真实有效答题、管理员运营审核、prepare/request/queue consumer/reveal；run3 2 candidates/1pair。Match时CN_NONE/MC_NONE且消息404；分别request/accept后CN_ACTIVE/MC_ACTIVE，无自动同意。 |
| 05 对话与媒体 | **PASS（已测类型）** | 真实文字发送/幂等/历史/已读、WS实时投递；合成图片/2秒H264/AAC视频上传ready、peer取回字节一致、匿名404、private/no-store；浏览器实际图片/视频解码，APP显示图片、播放视频并发送文字。撤MC后读/发、图片/视频GET和Range均404，已开WS关闭，显式新代同意才恢复。其它媒体类型NOT_RUN。 |
| 06 星盘与算法 | **PASS（部署复用，不重验天文真值）** | 本命八字/紫微/西占full；未变输入cache、改时间revision/signature变化；synastry/comparison/transit/solar_return/lunar_return真实云计算、非本人404；APP改时间并存库到revision4。重启后本命及五种动态详情读回。全部保留实际 `COMPUTED_UNVERIFIED`。 |
| 07 视频与实时 | **PASS（受控双方客户端）** | 同一call7双方视频实际解码+非零PCM，断开重入均恢复；end200后独立DB ended与ListRooms=0。call10另补APP↔浏览器双向视频，APP入站截图与浏览器解码25帧。权限桥SIGSTOP后本版SFU 1.308秒关闭，恢复成功。无真人听辨/AEC证明。 |
| 08 管理后台/受邀访问 | **PARTIAL** | 执行环境真实浏览器后台及权限/失效均通过；最新目标为独立Web后台，不是APP面板或SSH。Owner已批准受限HTTPS恢复；外部验证请求实际403/`Non-compliance ICP Filing`，故暂停公网子项。未续证、未启用443、不绕过拦截。 |
| 09 持久化与重启 | **PASS** | 先备份、停本版writer，只重启专属8服务，PID均改变；重启DB/Redis前后无writer的完整dump摘要相同。APP与后台重新登录，消息/媒体/三盘/动态盘/匹配/CN/MC读回；旧SFU ID/StartedAt未变。 |
| 10 集中交付 | **PASS（部分交付记录）** | 本唯一报告、产品Blob清单、最小脱敏机器回执与两张合成场景截图；非作者复核；源码/部署/APK/备份与命令流关联。AC08未闭合，因此不把整版写为完整候选。 |

## 4. APP、算法与RTC实证摘要

APK `com.elitesync.v10100pilot`，版本 `10.1.0-devpilot` / code `1010000`，214435684 bytes，SHA256 **`a19ea2a365ae4c7a1976dbb55c6cc208aa465c0bf9a46c2a37e272a842fcb0a7`**。构建起点 `d7593d97bfc8ed6544a9c131bfbdde318095c475`；其完整apps与最终源码apps都为 `a1fef5535db3e196580f437040dd5b1f86fd70db`，后续仅后端/RTC改变，未用旧源码APK冒充最新apps。仅安装已核实受控AVD `Pixel_6_Pro_2`，未触其它设备或全局SDK/JDK/Gradle。

固定构建端点为 `http://127.0.0.1:8030/` 和 `ws://127.0.0.1:8030/`。这是明确的云端SSH转发，不是公网交付URL。Android与Flutter双门校验；实际冷启Intent、运行中Intent及bootstrap文件覆盖尝试均未向受控恶意接收端发送请求；原文件原不存在，探针文件和临时reverse已撤回。当前聊天仍按旧客户端HTTP→8081派生WS，实测使用本版专属8081→云8031转发；没有声称消费了独立bootstrapWS字段。

合法云端运行时为新Python3.12.3 venv、Skyfield1.55及固定闭包、Node24.14.0、iztro2.5.8锁定闭包、原准入DE440s和Lowell Chiron文件。Linux wheels逐项核官方PyPI hash，Node核官方SHA256，npm核接受lock integrity并离线安装/禁scripts；没有启用Swiss/pyswisseph/Kerykeion受限环境。Linux部署身份单独记录，不宣称Windows锁证明Linux兼容。媒体探测使用独立FFmpeg7.0.2 GPL3服务端进程，未链接APP或对外分发，来源/许可证/包hash留证；未全局安装。lunar/iztro等原产品算法与许可合同未重开，Chiron世纪精度、同谱系参考、流派与科学限制继续有效；未将玄学信号新加入匹配硬筛选或客观关系结论。

同一call7初次双方：320×240，38/36 decoded frames，PCM RMS 0.08375/0.08431；重入后37/35帧，RMS 0.08564/0.08315。两边均真实接收合成媒体，`human_audibility=NOT_TESTED`。call10是另一通APP补测，浏览器收到APP 180×320/25帧；APP显示合成“Cloud peer 94”视频与本机预览。call10模拟器麦克风入站RMS=0，不能据此宣称双向有声；call7独立保留两端非零音频证据，不拼接为人耳听辨。

RTC使用从旧已核容器只读复制的LiveKit1.11.0二进制，新独立keys；二进制SHA256 `1b9a92c6c5fe604544c8917cfc0e91bab01cae33252a7bacc2495c0eb9f012ac`。最终SFU在PrivateNetwork=yes独立namespace，host无8032/8033/8034监听；信令/媒体/authority经过三个0600专属Unix socket，目录0750，仅本服务用户及现有特权SSH路径可用。Nginx RTC访问日志关闭以避免JWT query落日志。断桥测试不是systemd Requires联动停止：精确核归属后SIGSTOP authority进程，观测子SFU关闭，再SIGCONT及重启本版RTC恢复。

## 5. 必要源码修复、测试与原始失败

本版没有重开发星盘算法。必要改动：独立pilot包/固定端点；新增开发库隔离门；week_tag 16→120无损兼容真实cadence；WS运行文件转专属storage；Workerman5.1.9实际Request握手解析；专属RTC Unix桥、namespace部署适配与失败清理。源码差异仅下表20路径。

| 实际验证 | 结果 | 原始manifest（LOCAL_ONLY，同名前缀另有stdout/stderr） |
|---|---|---|
| PHP动态门/动态API/输入 | exit0，47项/267 assertions，deprecation保留 | `pilot-dynamic-gate-regression-7f4bea87.json` |
| PHP共享门/live consent | exit0，73项/350 assertions，deprecation保留 | `shared-pilot-gates-and-live-contract-regression-90a9a44e.json` |
| PHP cadence/RTC/round定点 | exit0，36项/130 assertions，**排除未关闭integrated smoke** | `cadence-rtc-and-round-regression-scoped-392d20a2.json` |
| PHP原生Workerman Request+会话能力 | exit0，19项/113 assertions | `native-workerman-request-and-chat-capability-regression-0a132cf6.json` |
| Python gateway | exit0；stderr `Ran 9 tests ... OK`，含启动失败/早期SIGTERM | `rtc-adapter-transport-regression-a8132db2.json` |
| Flutter固定pilot端点 | exit0，3 tests | `pilot-flutter-actual-gate-fixed-f801b3eb.json` |
| Flutter旧端点/router/socket定点 | exit0，10 tests | `pilot-flutter-legacy-endpoint-router-socket-regression-0d88b4fa.json` |
| 独立APK构建 | exit0，BUILD SUCCESSFUL；不是测试 | `build-v10100-pilot-apk-a252c204.json` |
| 最终真实重启/迁移拒绝/读回 | 包装命令exit0，远端各操作exit已保存 | `cloud-final-owned-services-restart-and-persistence.{json,stdout,stderr}` |

测试数存在重叠，不相加为独立覆盖总数。最终未改产品源码，按影响范围复用已过检查；没有再跑全量算法/历史PHP/旧RTC验收。PHP8.5 PDO常量、旧docblock等deprecation没有隐藏。

必须保留的真实失败与观察：

1. 最初仅设置LiveKit顶层bind_addresses仍真实出现host `*:8033`，立即停止本版SFU；**不能宣称全过程从无新监听**。后改独立PrivateNetwork及Unix转发，最终无host RTC监听；未改防火墙/安全组或旧SFU。
2. 早期云计算503：星历路径配置和运行时身份探测失败诊断保留，修正本版专属路径/依赖后真实算法及APP重算成功。随后动态测试脚本误断言`CALCULATED_UNVERIFIED`，而实际为`COMPUTED_UNVERIFIED`，原`cloud-chart-results.json`仍含FAIL。后续专门动态计算与本次详情读回是独立成功证据，不把原脚本改写为全通过。
3. 匹配run1/2因week_tag长度失败；原行保留。真实cadence落库超过16字符，扩列后run3成功，最终独立查询最大长度19。
4. Composer复用旧release vendor导致旧类classmap加载问题已修：最终release单独install，ReflectionClass和源hash实证；原过程保留。
5. WS原握手关闭及测试EOF忙循环原证/exit1保留；Workerman真实Request API修复、9项原生报文测试与真实101/消息/撤权关闭复验成功。
6. RTC call1/2/4的SDK2.23.0 `/rtc/v1`与接受parser不兼容，403；call3仅validate200/WS101诊断，不能计媒体。测试客户端固定合法Apache-2.0的2.15.13后，call5/6视频已有而音频节点GC使RMS0；修harness保留音频节点后call7成功。APP call8等待超时、call9英文权限弹窗未被脚本操作导致超时均保留；call10修正测试操作后视频通过。所有通话终止/超时行保留。
7. `cadence-migration-and-matching-regression-38a053ce.json` exit2/9 failed（users.phone NOT NULL等测试环境条件）；其后`cadence-rtc-and-matching-regression-fixed-9c228a09.json` exit1/1 failed，继承的AdminMatchingOperationalTruthLoopIntegratedSmokeTest stale响应缺`current_state_version`。正确queue后仍期望2实际null，**尚未修复**；scoped通过不包含它。原全量PHP16项历史失败继续保留，没有重跑或声称修复。
8. 初次Flutter组合命令exit1：目标router测试文件不存在，且空userinfo `https://@...`未拒绝；源码修正后分别3项端点与10项现存回归通过，原组合命令未重跑。中途Python mock缺少set_blocking和signal测试失败亦保留，最终9项通过。
9. 云端缺ffprobe的包闭包探索触预设cap，未全局安装；改合法独立进程后合成视频真实就绪/播放。原失败保持。
10. 本次读回脚本曾调用不存在的`/api/v1/auth/logout`得到404/exit1；核对接受源码确认APP原本仅清本地session，未偷偷新增服务端注销合同。APP真实退出/重登录已完成；服务端注销撤销token为NOT_IMPLEMENTED，不能写成PASS。

11. 本次SSH接续的原失败继续保留：本地工具缺Windows用户名环境使getpass尝试导入pwd失败；识别远程转发被拒时脚本未捕获ChannelListenError；修正harness后浏览器等待登录跳转超时。它们未形成受邀管理员成功证据，随后路径因Owner更正整体撤回。测试工具仅隔离安装本地，官方wheel hash验证，无全局Python/产品依赖升级。
12. HTTPS验证路径从外部得到403而脚本原预期200，包装命令exit1保留；后续同文件内外路径诊断证明上文具名拦截。未触发实际证书续期、启用443或修改公网规则来“追绿”。

原v10.0.9回声/AEC、call65未独立终态读回、旧/up内部超时根因UNKNOWN，以及v10.0.10/11科学/许可和动态盘未建立能力等历史观察全部延续；本版call7的独立终态证据不能倒填call65。

## 6. 非作者复核、保护及实际终态

专用连续工作树尚未被代码图谱索引，本次所需入口按该树当前源码直接读取，未用原dirty根的陈旧图谱替代。

独立非作者助手（GPT-6.1 Sol/high，`pilot_source_review`）只读复核最终`997af1e…`相对启动main的源码，结论：**未发现新增源码级阻断**。Workerman解析仍走原token/actor/peer/能力检查；此前SFU初始化/SIGTERM清理P1关闭。其要求的真实Unix权限路径、断桥failclosed、namespace/监听、MariaDB拒绝保护、持久化与最终源身份均由主代理补证，不反称助手自己执行了远端测试。它特别要求保留call7合成媒体、非人耳/非APP证据边界，报告已分开call10说明。内部审查不能替代Astra。

原 `D:/EliteSync-v10` HEAD仍`4bebc8f394248e254c1368a06fbdee5d2c883301`；index SHA256仍`2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`；porcelain状态摘要仍`2ad56cde4151ea497ea97755fbe31a0b257b616e4fe725e243628ad03e71758d`。三者与起点一致。**没有全量dirty/ignored/untracked字节初始表，不声称所有资产逐字节复验**。其它worktree/卷/旧媒体/私钥/备份/审阅分支未清理；专用树两个untracked `__pycache__`原样保留、不提交。

最终专属database/redis/php/http/websocket/queue/rtc-authority/rtc均active，未设置开机自启（authority为static，其余disabled）。旧LiveKit容器仍为原ID，StartedAt `2026-10-07T10:05:28.840899721Z`；本版受控重启前后均一致。本地仅本版独立APK安装及专属转发继续可用，受控AVD未清除；未无授权修改全局环境。依赖的本地SSH会话结束后转发将不可用，这不是已建立的同事长期访问设施。

## 7. 最新Owner口径、已撤回SSH和真实外部阻塞

本节覆盖首份交付中“推荐具名SSH”的方案。Owner先选择SSH，随后明确更正并最终确认：**管理员只使用独立Web管理后台，以管理员手机号和密码登录；不要求同事登录后端服务器，APP端旧管理员面板已抛弃，本版不恢复或扩建。**不再需要同事名单、公钥或服务器账号。

Owner另已明确批准：先备份，免费续期`slowdate.top`现有证书，恢复该域名443 HTTPS，仅公开本版隔离Web后台`/admin`；不购买服务、不改安全组/系统防火墙、不改旧业务路由。该授权仍保留，不因本次网络阻塞反复请求同一普通技术权限。

### 本次接续实际执行

1. 实时main仍`d80d3d0d1650e73e9654362d3a1491450687cdee`；接续前开发分支仍`f077875e83c7a7124e04b70fcfd3cebc8379b633`。两份正式文档Blob未变，已接受产品对象再次核对一致。2026-10-18 13:29:09 UTC，云端658文件再次核验零不匹配，8专属服务active，旧8配置/管理员备份hash保持，原dirty根HEAD/index/status摘要与起点一致。因产品代码未变，复用既有真实联调和非作者审查，没有重复部署、建管理员、构建或全量测试。
2. 在Owner当时选择SSH期间，曾备份SSH配置、对独立虚构测试账号应用具名限制并正常reload，未重启sshd。候选和实际配置均证明root/nobody有效配置不变；仅允许转发本版8030/8031，禁止旧DB/HTTP、Unix socket、反向转发、shell与SFTP。测试浏览器路径未完成登录，不把API200算后台成功。Owner纠正后已撤回：**SSH主配置逐字节恢复原SHA256 `233de7bf77edb119c8d8acae8a88e3c2966066a796fc5b02bfa5543608b284d6`；root/nobody有效配置恢复；探针公钥清空，账号锁定并过期；sshd MainPID不变。**新建配置/锁定探针与原失败保留作证，不删除旧账号/密钥，不再作为访问方案。
3. SSH操作前受控备份：`/opt/backups/elitesync-v10.1.0-ssh-before-20261018T133546Z/sshd-before-access.tar.gz`，SHA256 `b492a1e40343609aa96134378b648d804637f44d4710f80ed13ff59c108cfe60`，归档0600且可读。撤回回执原reason曾写“administrators use APP”，仅代表当时那条更正；**其后Owner明确的独立Web后台口径才是当前目标**。没有据旧reason恢复APP面板。
4. HTTPS写入前已完成证书/Nginx/本版必要配置备份：`/opt/backups/elitesync-v10.1.0-https-before-20261018T135207Z/certificate-nginx-pilot-config.tar.gz`，SHA256 **`e236ef4766989ccac97266c67eca00ccfc83c3c24ba9bf97be1e703126fa0e4d`**，13347 bytes，25 members/19 regular files可读，目录0700、归档0600。含现有证书链/私钥及必要配置，仅留受控服务器，不进入Git或本地公开证据。
5. 已确认该域名DNS仍指向已核云主机，Certbot2.9.0已存在；原证书notAfter仍2026-08-16。准备了只代理`/admin`及`/admin/`的新站点候选，其它路径404，不公开API注册、RTC或其它业务。非作者指出的HTTPS scheme/port、独立Secure/HttpOnly/SameSite cookie与Host/CSRF验证仍列为**实际激活后的必测项**，不是已实现或已通过。
6. 使用本任务独立随机文件预检现有HTTP-01验证路径。执行环境从外部请求得到 **HTTP403，Server `Beaver`，HTML标题 `Non-compliance ICP Filing`**；云主机内loopback及域名访问同一文件均200，内容SHA256均为 `e5afdbed693f9d2814c9f30d50c24959fda56fcadffb8e221f8d1e82eb709bb4`。这证明当前外部测试路径遇到备案拦截，不能误判为Laravel管理员认证失败，也不推断所有地区或CA节点都已测过。
7. 外部预检未通过，按边界暂停受影响公网子项：**Certbot实际续期NOT_RUN，新的HTTPS站点NOT_INSTALLED，443仍无监听；安全组/防火墙/费用/旧业务路由均未变。**没有通过IP、其它端口、其它域名或代理规避该拦截。临时公开验证文件已精确核hash后移入同一受控备份目录保留原件；仅撤销本次新建的空验证目录，未清理既有资产。13:54:37 UTC终态回读证明证书及配置仍与HTTPS前备份hash相同，8专属服务均active。

### 真正需要Owner处理的剩余事项

请在阿里云账户核实并处理`slowdate.top`的ICP备案/接入备案状态及该拦截。当前只证实拦截页，未访问Owner云控制台，也不擅自断言具体备案记录或原因。**解除并确认现有域名可以正常从外部访问后，可在本版原已批准范围继续免费续证、恢复受限443并真实验证网页登录/权限/安全Cookie。**无需再选择SSH或重新派发普通工程任务。

若该云资源/域名因资质等原因无法合法解除拦截，任何新托管地区、付费资源或数据合同变化都需Owner另行决定，本次未购买、未迁移。未对ICP备案作法律认定，不通过技术绕行伪造AC08 PASS。

## 8. 最小审阅证据与产品Blob清单

[脱敏机器回执](evidence/EVIDENCE.json)记录源对象、APК、同call媒体、断桥、备份/重启、命令exit与stdout/stderr摘要、LOCAL_ONLY原证文件索引。仅提供可公开安全的最小副本；原始SSH输出/API响应/配置/数据库/凭据/出生输入不进Git。两张截图均为本版虚构账号及合成内容：

- [APP接收云端合成视频及本机预览（call10）](evidence/app-cloud-rtc-call10.png)
- [全部服务重启并APP重登录后的持久消息/图片](evidence/app-persistent-conversation-after-restart.png)

公开摘要和截图能支持审阅，不构成Astra已独立复跑。命令原始stdout/stderr/exit保留本地，不能只因wrapper exit0推断其内部历史断言全绿；上文逐项区分。云端部署包含源包选定后端、RTC、接受gateway/watchdog与题库，APP单独构建；未把整候选仓库当云端敏感部署包。

以下20个产品/测试路径的Blob属于最终产品源码锚；报告/脱敏证据是文档交付，不改变这些Blob：

| 路径 | Blob SHA |
|---|---|
| `apps/android/app/build.gradle.kts` | `1bc9038b4a6b4461c8da9070c188d67bc380cc8c` |
| `apps/android/app/src/main/java/com/elitesync/MainActivity.kt` | `edff7ec4bc03b22e35c10f41faeb17b8578725d0` |
| `apps/flutter_elitesync_module/lib/main_prod.dart` | `6c56df6bb7898154716534a18e70d061076c8f8b` |
| `apps/flutter_elitesync_module/test/v10100_pilot_endpoint_test.dart` | `ab63605630f79dc34798602b542d40007df290ee` |
| `services/backend-laravel/app/Console/Commands/ChatWebsocketServerCommand.php` | `00e3bc14a66198b169d5ac1bd843d4a74bb81c65` |
| `services/backend-laravel/app/Http/Middleware/PrivateDynamicCharts.php` | `dfc2a2fd4f2c865949db4143fdfee2d21cb9684c` |
| `services/backend-laravel/app/Services/ChatWebsocketAuthorizationService.php` | `db63a5505788baecf20ae29ef363e5f2aec6abba` |
| `services/backend-laravel/app/Services/DynamicChartService.php` | `3aa49b2a77b31a7e20d7cce4d7fb8e3f31e35f66` |
| `services/backend-laravel/app/Services/LiveConsentService.php` | `95e7c30c91e6cf77511d4c8b08122f7327923efa` |
| `services/backend-laravel/app/Services/RtcAuthorityService.php` | `6c519c63166206a8f36a33c46d9b09cf2ddf9e68` |
| `services/backend-laravel/config/dynamic_charts.php` | `7db0268287b24a236e1cc2cade9db3d08f66b1e6` |
| `services/backend-laravel/database/migrations/2026_10_18_000001_widen_match_week_tag_for_round_cadence.php` | `91f81553543725a423bde305b3f6914214811ecd` |
| `services/backend-laravel/tests/Feature/V10100CadencePersistenceTest.php` | `08d8f4b0b47f85385be877dfda783ddcb66b65a4` |
| `services/backend-laravel/tests/Unit/V10100DevpilotConsentGateTest.php` | `cb736cd7d3fe7a1a8ac4a55bed80ba046348bc3c` |
| `services/backend-laravel/tests/Unit/V10100DevpilotDynamicGateTest.php` | `0bc014604100c211de3b281f08214200a4127727` |
| `services/backend-laravel/tests/Unit/V10100DevpilotRtcGateTest.php` | `494710687da6e11c9f4c70c6eabd0e131fe8186b` |
| `services/backend-laravel/tests/Unit/V10100WorkermanHandshakeTest.php` | `f28923dfaced7e9fb254afb975de1db673c21f14` |
| `services/rtc-devpilot/authority_bridge.py` | `3018803c5397ad7d4e7412668f8aebfba47321a7` |
| `services/rtc-devpilot/gateway.py` | `fb46d8563b21ef5702c87c98db2b71842154fe16` |
| `services/rtc-devpilot/test_gateway.py` | `2b382967c2ce1efbf21b3f8db5da9c3fb371884c` |

**出口：V10.1.0_PARTIAL_DELIVERY / AC-10.1-08_PARTIAL / AWAITING_ASTRA_REVIEW / NOT_ACCEPTED。**保留已经完成的隔离试点与所有原始失败，等待Astra独立审阅及Owner核实域名备案拦截；不自动进入生产或v10.1.1。
