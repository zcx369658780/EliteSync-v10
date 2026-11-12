# v10.1.5 软件候选实施报告

2026-11-12。状态 **V10.1.5_CANDIDATE_DELIVERED / AWAITING_OWNER_DEVICE_ACCEPTANCE**。按Owner要求完成本轮软件收口并停下，实机协助后继续相应验收。冻结判定保留 **10 PARTIAL / AC05 OPEN / G2 false / REAL_PUSH_PENDING**。产品接受由Owner决定。

## 固定交付身份

| 项目 | 固定值 |
|---|---|
| 产品分支 | `codex/v10.1.5-software-continuation-20261101` |
| APP源码提交 | `60930170e3a437da0b77e877c55ed4dd1a92f9ca` |
| 源码Root Tree | `41c8653140c77089e58e8f7822ce2ce988e0f438` |
| apps Tree | `f586b9eb5bb2f1c970cee0ec93602b407f996c1e` |
| services Tree | `d5ce843aacffb34fe8727c59aa6434d5f955ba14` |
| 后端源码节点 | `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`，services Tree与交付一致 |
| 包与版本 | `com.elitesync.v1015dev / 10.1.5-dev / 1010501` |
| 构建 | arm64-v8a Debug，离线30.3414811秒，退出0，v2签名已核 |
| APK | 154546416字节，SHA256 `d8af0c896ceeb43d2251c89d1080eced593392d5127b0276c95db7ba88b89b67` |
| 本地交付文件 | 私有根下 `delivery/EliteSync-v10.1.5-dev-60930170-arm64-debug.apk` |

交付文档提交继续引用上述源码身份。机器可读清单为[artifact_manifest.json](artifact_manifest.json)。本机API/WS/SFU及虚构持久库是此Debug候选的运行环境。实机连接配置在Owner协助阶段核定。

## 本轮修复

- RTC显式创建并登记替换轨道，暂停时覆盖inactive。持续保留Room和采集代次归属，SDK重连清空publication时仍能清理原轨道。迟到发布按自身归属清理，用户明确开麦与开摄像头分别生效。
- 通话授权失效页提供中文反馈和返回会话入口，终态去掉恢复采集提示。
- 附件上传ready后保留重试入口，直到相匹配的持久化消息attempt接管。已有其他attempt时阻止新附件点击隐式重发，重试素材从原attempt绑定取得。补充等待发送确认文案。
- 既有同会话在线核验后恢复加密草稿及原提交编号逻辑纳入最终候选。

## 检查及非作者复核

| 范围 | 实际结果及身份 |
|---|---|
| RTC/来电 | 94fd/b4源码108项定向检查通过，四文件analyze无问题 |
| RTC失权反馈 | 2dce源码27项页面检查通过，相关analyze通过 |
| 附件接管/聊天/历史/缓存 | 5af源码97项通过，两文件analyze通过，两条精确RED原证保留 |
| 最后ready文案 | 609源码1项定向检查通过，最终两文件analyze无问题 |
| 草稿冷启安全 | 3c源码109项及四文件analyze通过，按原候选保留 |
| 非作者代码复核 | Sol/high检查RTC代次与附件接管，未发现剩余确定P1/P2 |
| call22计时复核 | 非作者独立复算4.874250秒，核对隔离/事务、版本、AppOps完整性及采样尾窗，无剩余确定问题 |

上述检查按实际源码和日志分别归属。最终609仅在5af后改变一处ready文案，RTC和后端逻辑保持。非作者复核属于工程证据，Owner产品接受继续待定。最终交付材料的复核结论在本报告末尾记录。

## 最终609的实际开发链

私有原证根为 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`。清单只记录原证文件名、摘要和SHA256，原始内容保留本机。

| 子链 | 本次实际观察 | 私有回执 |
|---|---|---|
| 双端身份 | 5580实际B/user2、5582实际A/user1，两端安装base.apk字节SHA一致 | `candidate609-installed-20261112-private.json` |
| 未知POST冷启 | 一次正常APP发送109，真实200确认被本机观察代理替换503。离线冷启隐藏，在线同会话/peer核验恢复原UUID。明确原编号重试返回同109和200 replay，一条密文、一通知、一事件，确认后冷启pending为空，自动POST为0 | `candidate609-pending-completed-20261112-private.json` |
| 视频/图片 | 正常APP上传并发送视频110/asset12、图片111/asset13，真实DB关联和文件hash正确，视频播放至0:02，图片预览及对端读取 | `candidate609-image-video-runtime-20261112-private.json` |
| 系统通知拒绝 | A的POST_NOTIFICATIONS为denied，实际通知设置提示核心入口可用。一条正常A→B文字112持久化为密文、单通知/事件，B正常冷启读取，原权限状态恢复 | `candidate609-notification-denied-message-20261112-private.json` |
| 旧通知真实点击 | B实际点击通知168的打开动作，已观察到handler发出的detail GET。转发该GET前正常撤MC，真实API响应清空route/args/payload，含撤权耗时0.281秒。APP留在通知中心，目标read POST为0、read_at保持。正常双向重新同意至generation13 | `candidate609-stale-notification-click-20261112-private.json` |
| RTC当前/旧权限 | call22双端当前JWT验证200，旧JWT在未过期时撤权后及新同意后均403。当前图片/视频双方full200/Range206、字节/hash相符，撤权后旧URL拒绝。旧房间消失 | `candidate609-rtc-authorization-tail-verified-20261112-private.json` |
| RTC原生停媒 | 同一主机monotonic时钟，以最后ACTIVE查询开始/首REVOKED查询结束夹住commit。autocommit1、无活动事务、RR普通SELECT，revision/generation对应。CAMERA/RECORD_AUDIO统计行完整。commit后保守停止上界4.874250秒，包含时钟余量。随后15次双端inactive采样覆盖约2.016秒并越过commit上界后5秒，尾窗内未见反弹 | 同上 |
| 持久服务重启 | APP先暂停，仅原四个owner匹配容器按SFU→WS/API→DB停止，DB→API/WS→当前authority就绪→SFU启动。4用户、112消息、13媒体及指定全体snapshot事实前后相同 | `candidate609-controlled-services-restart-20261112-private.json` |
| 重启后APP | 两端同包正常冷启重读112，B打开持久图片、视频播放到0:02，零发送，指定持久事实继续保持 | `candidate609-post-restart-app-readback-20261112-private.json` |
| 独立Web | 重启前后分别完成真实HTTP登录、搜索、详情、列表、退出9项，业务突变0。既有浏览器渲染证据按原节点保留 | `final-web-before-restart-20261112-private.json`、`final-web-after-restart-20261112-private.json` |

重启比对包括原用户、原1–104消息不可变字段、原7媒体、CN/MC、session/token/T0、所有新增消息与附件绑定、每逻辑消息通知/事件数量及媒体文件hash。正常消息已读时间属于可变字段。MC观察与恢复在重启基线前完成，重启时保持同generation13。

## 可信期限与原生故障的验证范围

- 实际Laravel HTTP kernel和MariaDB事务内受控服务端时钟16项通过。真实密码登录生成账户/设备/T0绑定，verify/refresh保持原期限，15/30天前/当/后路由权限符合预期。finally清除受控时钟并回滚，原users/sessions/tokens指纹相同。回执 `retention-route-boundary-20261112-private.json`。
- 独立包 `com.elitesync.v1015probe.v1015dev` 使用真实Android加密存储插件、独立UID与Keystore namespace。受控wall/elapsed及synthetic receipt覆盖15前/当、30前/当，四单故障和连续三故障，共7次选择性wrapper故障。locator末步失败后真正force-stop，新PID冷启重试完成，原产品加密文件hash保持。回执 `cache-native-probe-runtime-20261112-private.json`。
- 自然经过30天、物理磁盘故障和硬件Keystore的实机验证仍待完成。受控边界与插件故障证据的范围按上述条件保留。

## 沿用证据及原始失败

- 同键200/不同payload409和单副作用在相同后端源码25bc真实核验，消息105。ready附件一次明确重试、一次上传/消息108在5af候选实际通过。最终609的18秒延迟观察窗口超时，正常发送已完成110，该记录只支持正常发送，609的明确附件重试实际观察仍UNKNOWN。5af后的附件逻辑保持，原候选与最终候选的实际观察分别记录。
- 既有Block、CN关闭、peer禁用和MC撤权的MariaDB锁等待证据按11月8日原候选保留。当前授权协调核心沿用，MessageController新增分页、LiveConsentService新增43326开发库白名单。本轮未重跑完整actor/peer、所有detail/mutation、APP/WS/cache及媒体在途竞态矩阵，AC03继续PARTIAL。相关[MC并发记录](../../workflow/V1015_MESSAGE_CONCURRENCY_DUPLICATE_MC_VERIFIED_20261108.md)和[Block/CN/peer禁用记录](../../workflow/V1015_MESSAGE_PERMISSION_MATRIX_BLOCK_CN_DISABLE_VERIFIED_20261108.md)保留。
- call15前台返回采集再次active、call20 request-start停止上界5.078秒且缺commit真点、call19观察工具GBK失败和先前UI/时序助手错误均保留。call20保持未获得5秒资格，call22按独立commit夹测结论记录。heartbeat仍2秒。
- 2d候选曾上传ready视频asset9后丢失重试入口，该未关联素材继续保留为失败原证。两条RED及5af修复均有独立记录。
- 账户/问卷隔离、资料/头像、好友/动态/搭子/合成活动、三盘/动态盘、UI首轮及传输封装按[PROGRESS](PROGRESS.md)中具名候选沿用。地图/地点与其他旧附件恢复UNKNOWN，语音留言OUT_OF_SCOPE/NOT_IN_SCOPE，依据冻结F5的有界来源判断。

## 冻结AC与Owner实机入口

| AC | 保留判定 | 当前结论及待补范围 |
|---|---|---|
| 01 | PARTIAL | 代码/原库/index保护、候选和私有原证已记录，最终接受待定 |
| 02 | PARTIAL | 最终pending冷启、正常双向文字、旧候选并发/附件重试有效，弱网与时序覆盖有界 |
| 03 | PARTIAL | 历史真实消息权限并发及当前JWT/URL/通知重验有效，完整权限/在途竞态矩阵仍有未测路径 |
| 04 | PARTIAL | 最终同包图片/视频发收、撤权及重启读回有效，全部媒体故障/竞态覆盖待扩充 |
| 05 | OPEN | 模拟器RTP/画面、采集停媒与旧JWT有证据，实机音质、AEC、路由/后台体验待Owner协助 |
| 06 | PARTIAL | 真实认证路由受控时钟边界通过，实机时钟/设备恢复和自然时间运行待观察 |
| 07 | PARTIAL | 真插件受控多故障及新进程重试通过，硬件Keystore/物理故障待验证 |
| 08 | PARTIAL | 最终拒绝通知权限仍可消息、旧通知真实点击重验通过，全部类别/主体界面覆盖按原范围保留 |
| 09 | PARTIAL | provider/token契约已有，真实Push供应商与送达PENDING |
| 10 | PARTIAL | 最终APP/API/MariaDB/Web及四服务重启旅程完成，跨设备总体接受待定 |
| 11 | PARTIAL | 唯一报告/manifest、固定APK及非作者有界复核交付，Owner功能接受待定 |

Owner实机阶段优先核安装/登录与权限体验、双端文字图片视频、通话听感/AEC/音频路由、前后台与撤权、加密存储及设备重启。硬件条件和真实Push分别按实际权限处理。独立精度/解释AI沿后续路线保留。

## 停下时状态

两端APP正常force-stop，AVD、登录及数据保留，两模拟器保持运行。DB/API/WS/SFU四自有服务保持运行，房间0且双方采集停止。原主库255项dirty、index差异0字节的只读快照保留，本轮对此根写入0。产品无关 `%SystemDrive%/` 保留，当前分支只提交具名源码及文档。手机、默认5037和历史STOP/已耗记录保持原边界。最终本地/远端HEAD及资源实读结果写入日期化私有保存回执。

## 最终交付材料复核

非作者Sol/high已核对固定源码/Root/apps/services、APK字节数/SHA及16份具名原证hash，检查候选归属、609明确附件重试UNKNOWN、原失败、受控边界和硬件实机范围、冻结AC与隐私发布边界，未发现确定P1/P2。随后主代理补齐最终资源实读和当前私有节点，原主库以相同porcelain-v1 NUL格式核验与先前摘要相同，255项dirty/index差异0字节。最终Git身份由日期化私有保存回执补齐。
