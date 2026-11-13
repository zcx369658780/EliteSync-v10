# R1 证据适用性

日期 2026-11-13

## 范围与身份

本表按当前 APP 候选 `cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d`、后端工具节点 `e7b21c7fdb0991a5fbd5a9272c92c2331c0dec2d` 和沿用后端核心 `6549f02880968f99ae3f45439d15a37c1b3d5251` 判断。609 到当前候选的历史累计源码变化涉及 RTC 服务、权限/来电/通话页面、邀请与通知路由、聊天附件路径及其定向测试。本轮 R1 相对前序源码只改资格、MBTI、引导、连接页面及 SFU 开发服务工具，没有修改 RTC 客户端、聊天或通知实现。后端新差异集中于 `tools/rtc` 开发 API、authority router 与 gateway 适配。历史回执只能证明表内列出的候选、运行身份和场景。

状态区分为历史工程证据、候选间可继承、当前候选实测和受限验证。当前候选的真实撤权、未知 POST 冷启与旧通知点击已补证，结果见下文。R1-01 另有非注入超时根因 UNKNOWN，本轮为 CHANGES_REQUIRED/PARTIAL。原始 JSON、日志及安装包留在具名私有根，6张新截图按发布清单提供。

## 适用性表

| 风险与范围 | 原候选及回执 | 当前源码影响 | 可继承的实际结论 | 当前候选必要补证与边界 |
|---|---|---|---|---|
| RTC MC 撤权后停媒 | 609 `60930170e3a437da0b77e877c55ed4dd1a92f9ca`，APK SHA256 `d8af0c896ceeb43d2251c89d1080eced593392d5127b0276c95db7ba88b89b67`，`candidate609-rtc-authorization-tail-verified-20261112-private.json` | 609 到当前候选的历史累计变化涉及 RTC 服务、权限失效处理、来电和通话页面，但本轮 R1 未修改这些客户端路径，故 609 运行结果仍只归属历史候选 | 609 双端当前 JWT 有效，撤权后旧且未过期 JWT 被拒，新同意后旧房间不在且旧 JWT 仍被拒。commit 由同一主机 monotonic 时钟用最后 ACTIVE 查询起点与首个变值查询终点夹定。保守请求到双端 CAMERA 和 RECORD_AUDIO 均 inactive 上界为 4.953250 秒，含 0.015625 秒时钟分辨余量。越过 commit 后 5 秒边界的双端稳定采样无重启采集 | 当前call51已补证，COMMIT保守上界2.187250秒、Room0、旧未过期JWT和媒体拒绝、新代次不复活。详细回执与测量定义见下表及本轮摘要 |
| 未知 POST 后冷启及同 UUID 重放 | 609 同上，`candidate609-pending-completed-20261112-private.json` | 609 到当前候选的历史累计变化涉及聊天附件接管与会话入口，本轮 R1 未改该路径 | APP 正常发送一次，观察代理仅替换确认响应为 503。离线冷启隐藏草稿；在线同会话及 peer 核验后以原 UUID 明确重试。服务端返回相同消息行 109 和 200 replay。数据库仅一行密文消息，单通知与单事件。确认后冷启 pending 为空，自动 POST 计数为 0。回执保留一次 observer label 未暴露未知发送状态的失败，后续同回执字段显示原编号重试流程完成 | 当前消息125同链已补证，冷启隐藏/原UUID显式重试/单行单副作用/自动POST0。609和2d回执各保留原身份 |
| 15/30 天认证路由边界 | 后端核心 `6549f02880968f99ae3f45439d15a37c1b3d5251`，`retention-route-boundary-20261112-private.json` | 后端新工具提交不改变该回执所测 Laravel 路由核心身份 | 真实 Laravel HTTP kernel 与 MariaDB 事务，受控服务端时钟共 16 个请求。初始登录及 15 天前读/刷新为 200，15 天当日及之后为 401。30 天前、当日、之后读/刷新均为 401。失败登录为 422。刷新保持账户/设备/T0绑定及期限，夹具事务回滚且原 users/sessions/tokens 指纹不变 | 可继承软件路由的受控时钟边界。自然经过 15 或 30 天未发生，客户端时钟未改，不据此宣称自然时间验收。账户设备字段仅留本机，不在文档公开 |
| Android 加密本地缓存清理与故障恢复 | 探针候选 APK SHA256 `84d614ab6c3a44da7b81c4c40132fe273866d07e03ceb29f7aeb65c94f307f5c`，`cache-native-probe-runtime-20261112-private.json`；另有产品本地清理回执 `cache-android-cold-local-cleanup-private.json` | 当前 APP 与 RTC/会话入口存在变化，但证据为真实 Android 加密存储插件的独立探针，不是产品设备效果 | 探针独立包 UID 与 Keystore namespace，真实 Android 加密偏好插件、受控 wall/elapsed 与 synthetic receipt。7 类选择性 Dart wrapper 故障包括 object-delete、completion-write、primary-delete、recovery-delete 各单故障及连续三故障。首进程定位末步失败后 force-stop，第二 PID 冷启重试完成；原产品加密文件前后 hash 不变。另一产品清理回执为 bfb 候选 `bfbbe4eda27423acf25fdf48eb2b763102650b13`，仅通过官方 Flutter debugger 调用现有 `clearSessionWithReceipt` 清理已知对象，回执完成且已知残留为 0 | 探针结论仅为独立包 wrapper 故障路径，不能写成产品硬件或物理存储故障效果。产品清理是已知键、当前实例方法调用，不是 UI 退出，也未枚举未知存储。硬件 Keystore 和真实物理故障仍未验证。若当前实现变化影响清理入口，按当前候选补产品读回 |
| 旧通知点击与撤权路由 | 609 同上，`candidate609-stale-notification-click-20261112-private.json` | 当前邀请协调器及通知 provider、通知页有改动 | 实际点击旧通知 168 后观察到 handler detail GET。在转发 GET 前撤回 MC。真实响应清空 route、args、payload。目标 read POST 为 0，`read_at` 仍空，页面留在通知中心。恢复后双向重新同意。该回执覆盖这一个通知和场景 | 当前通知259同类实际点击补证，detail在途撤MC，导航和已读副作用均被拦截。只覆盖具名实例和时序 |
| 媒体附件并发及撤权在途 | 后端核心 609 沿用的权限协调结果与 11 月 8 日具名矩阵，见 IMPLEMENTATION_REPORT.md 引用 | 当前聊天、LiveChat、RTC 服务和通知/授权导航均有变更；后端 `MessageController` 分页及 `LiveConsentService` 开发库白名单也有变化 | 继承已具名 MariaDB 锁等待下 Block、CN 关闭、peer 禁用与 MC 撤权结果；609 有当前媒体 URL、撤权后旧 URL 拒绝及附件读取的实际结果。原 609 的附件 retry 18 秒观察窗口超时只支持正常发送，不证明明确重试成功。5af 候选明确重试证据仍归其自身 | 不能宣称完整 actor/peer、detail/mutation、APP/WS/cache 与媒体在途竞态矩阵已覆盖。当前对切号晚响应、消息或附件在途撤权、路由迟到有影响路径做定向正反例，结果由主代理补入。不要把跨候选媒体结果拼成当前候选全组合通过 |

## 当前判定

历史范围内的 609 停媒、未知 POST 冷启、受控期限、Android 探针和旧通知点击各自有可定位回执。当前补证覆盖下表所列变化支线。自然时间、硬件 Keystore、物理故障、完整并发组合和实机声学范围按各自未验证或受限状态记录。

## 当前候选补证与精确依赖

| 路径 | 候选间影响及继承 | cfd 当前结果 |
|---|---|---|
| 未知 POST、冷启与重放 | 609至cfd的 AuthLocalDataSource、PrivateCacheService、UUID后端幂等核心无变化。LiveChat 在 bd4c 修改 picker 返回后当前授权和草稿核验，已有 attempt 时保留原请求。chat_room 的相关差异涉及通话 intent。原609服务端幂等事实保留其身份 | `current-pending-cold-private.json` 实际消息125完成 ACK503、离线冷启隐藏、联网同UUID显式重放、单一密文行/单副作用、自动POST0与确认后冷启清空。新证覆盖当前恢复支线 |
| 通知协调器与旧路由 | 历史累计修改独立数据源、当前 user/epoch、autoDispose、失败停住及显式重试。后台扫描与页面加载的定向检查分别覆盖，原609服务端权限拒绝仍可继承 | `current-stale-notification-private.json` 当前旧通知259实际点击，detail转发前撤MC，route/args/payload清空、read POST0、未读保持、留通知中心。随后恢复新同意代次 |
| RTC 授权与采集 | 609之后客户端生命周期有累计变化，本轮只修改后端工具。历史609保守COMMIT上界4.874250秒、请求基准含余量上界4.953250秒分别保留 | `current-measured-revoke-private.json` call51真实DB提交区间0.016秒，COMMIT停采集保守上界2.187250秒，旧未过期JWT与媒体URL拒绝，新代次旧房间不复活。call53故障恢复与call54正常结束另见结果报告 |
| 原生清理 | 609至cfd的上述加密存储/清理实现无变化，保留已知键方法与独立probe wrapper语义。产品历史bfb和独立probe的UID/候选分别记录 | 沿用具名产品清理和7类wrapper故障，不新增同实验。当前UI硬件密钥库、未知键枚举及物理擦除范围仍未验证 |
| 15/30天 | 后端核心6549保持一致，本轮差异仅开发RTC工具，与期限路由/服务无交集 | 继承16项真实HTTP kernel/MariaDB受控时钟边界。自然时间单列 |
| 资格与连接晚响应 | 本轮新增/修复的回执holder、会话intent、provider重建、连接proposal envelope及新生命周期有当前定向正反例 | 资格受控APP失败/重试/GET-only确认通过。切号/登录/资料更新/POST在途重建/连接迟到结果由定向测试覆盖。当前真实MC停媒和通知在途撤权补证，完整消息/附件并发矩阵保留具名历史范围 |

当前回执的去敏字段与原件hash见 [EVIDENCE_SUMMARY.json](EVIDENCE_SUMMARY.json)，历史原证的完整顺序与字段见 [HISTORICAL_EVIDENCE.md](HISTORICAL_EVIDENCE.md)。
