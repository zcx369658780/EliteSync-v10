# v10.1.5 R1 当前完成度与 AC表

日期 2026-11-13

## 当前结论与候选

本轮结论为 **CHANGES_REQUIRED / PARTIAL**。冻结判定仍为 **10 PARTIAL / AC05 OPEN / G2 false / 真实 Push PENDING**。当前有界撤权、故障恢复、未知 POST 冷启和旧通知点击均有当前候选回执，但 SFU 部署后仍观察到一次未注入的权威查询延迟，根因 UNKNOWN。R1-01 因此未关闭，不能以只剩外部限制作为完成出口。

当前 APP 候选为 `cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d`，Debug APK SHA256 为 `311632a8c735b53d97984dc9b45f00c1d7cdc6e72f848807cb40d99f62d7fc69`。构建回执记录 v2 签名和两台模拟器安装包 hash 一致。后端工具代码为 `e7b21c7fdb0991a5fbd5a9272c92c2331c0dec2d`，后端核心沿用 `6549f02880968f99ae3f45439d15a37c1b3d5251`。

证据状态严格对应回执身份和边界。工程自验不等于独立审查、顾问接受或 Owner 接受。普通功能使用虚构测试身份和开发环境，没有真实身份供应商或生产用户资料。私有原回执只以文件名和已脱敏结果摘要引用。

## 冻结 AC 01–11

| AC 与入口 | 当前判定 | 证据与实际结果 | 剩余项与负责方 |
|---|---|---|---|
| AC01 候选身份、源码与索引保护 | PARTIAL | 当前 cfd 候选、APK SHA256、签名及两台模拟器安装包 hash 可由 `final-build-private.json` 和 `final-installed-private.json` 复核。构建回执排除了报告、manifest 与补充文档变更 | 此身份记录不代替最终工作区/index 与原库保护摘要。主代理更新最终 manifest 并关联受影响源码；Owner 保留最终接受 |
| AC02 会话消息、冷启和草稿 | PARTIAL，当前未知 POST 有界复核通过 | 当前候选 `current-pending-cold-private.json` 记录一次正常发送的成功响应被观察代理替换为 503。离线冷启不显示草稿，联网后在原会话以原 UUID 明确重试，服务端返回同一行 125 和 200 idempotent replay，数据库只留一条密文消息，自动 POST 为 0，确认后 pending 为空。历史附件和媒体消息按原候选范围继承 | 当前 receipt 不扩大为弱网全组合或所有附件时序通过。聊天权限竞态仍按 AC03，当前消息链由 Codex 工程自验 |
| AC03 权限、连接与在途并发 | PARTIAL，关键撤权链通过 | 当前 call51 回执 `current-measured-revoke-private.json` 在真实开发 DB 查询夹定 commit 单调时钟区间，区间宽 0.016 秒。commit 后双端 CAMERA 与 RECORD_AUDIO 停止上界 2.187250 秒，符合 5 秒目标。双端 inactive，撤权后旧 JWT 为 403，新同意生成后旧 JWT 仍为 403，旧房间不存在。`ordinary-social-formal-current-private.json` 另记录 37 次本机 HTTP 与 MariaDB 操作，涵盖好友、搭子、社区、正式关系 pending、确认拒绝与撤回。block/unblock 后旧好友访问不复活 | 完整 actor/peer、消息/附件在途撤权、迟到切号和 APP/WS/cache 并发矩阵未由这些场景穷尽。主代理按当前受影响路径保留部分状态并核对剩余风险 |
| AC04 媒体与附件生命周期 | PARTIAL，当前有限恢复旅程通过 | 当前 call54 在故障恢复后双端入房并双端 CAMERA/RECORD_AUDIO active。Room 为 2 参与者。正常 APP 挂断后服务端 ended、Room0、双端采集 inactive。实际通话 261 秒。609 历史回执继续限定图片/视频关联、读取与播放范围 | 不据此宣称媒体在途撤权、全路由、长时或声学矩阵完成。主代理维护当前候选适用范围，Owner 保留实机听感与物理路由接受 |
| AC05 RTC 通话、权限失效与 SFU 恢复 | OPEN，R1-01 PARTIAL | `sfu-media-fault-recovery-private.json` 记录 call53 权威池故障后服务进入 restarting，撤权令双端采集停止，Room0，旧未过期 JWT 为 403。恢复 authority 后再次同意，旧 JWT 仍为 403。随后正常 call54 双端媒体恢复并正常清理。`finite-incoming-expiry-private.json` 记录来电到期后 missed，唤醒后显示未接通。`finite-incoming-reject-private.json` 记录正常拒绝后 rejected。有限观察回执记录工具完成耗时 1500.906 秒、采样覆盖 1500.031 秒、51 个间隔采样、同一 PID，ANR/OOM/Fatal 标记数为 0。Heap 为 120759792 到 126337216 字节，峰值 142433968。PSS 为 757743 到 734208 KiB，范围 678666 到 757743。末次 retained RTC session/event 分别为 13/15 | 独立池部署后，00:06:45 UTC 另有一次未注入的 authority query 超时。普通 PHP 与 authority PHP 同时约 6 秒延迟，具体阻塞根因 UNKNOWN。没有将 call53 故障注入恢复替代该根因调查。本轮有限观察判读已记录，非注入超时的具体根因仍待定位，R1-01 保持 PARTIAL。硬件、实机声学、AEC 与自然长时仍受限 |
| AC06 认证期限与本地时钟边界 | PARTIAL，受控路由边界通过 | `retention-route-boundary-20261112-private.json` 对真实 Laravel HTTP kernel 与 MariaDB 事务使用受控服务端时钟，16 个登录、私有读取、verify/refresh 请求覆盖 15/30 天前、当日和之后。回执记录用户/session/token 指纹不变并回滚夹具 | 自然经过 15/30 天未发生，客户端时钟未改。该项不得写成自然时间通过。历史受控结果按后端核心身份继承，主代理在总表保留限定语 |
| AC07 Android 缓存清理与故障恢复 | PARTIAL，受限范围通过 | `cache-android-cold-local-cleanup-private.json` 记录产品已知键清理完成且已知对象剩余 0。`cache-native-probe-runtime-20261112-private.json` 记录真实 Android 加密存储插件的独立 probe UID，7 次 wrapper 故障及新 PID 冷启重试完成 | 产品清理不是 UI logout，未枚举未知对象。probe 不是产品 UID、硬件 Keystore 或物理故障证明。主代理只继承原证限定范围 |
| AC08 系统通知与旧入口 | PARTIAL，当前旧通知撤权复核通过 | 当前候选 `current-stale-notification-private.json` 记录实际点击旧通知后在转发 detail 请求前撤回 MC。返回路由、参数、payload 为空，页面留在通知中心，read POST 为 0，`read_at` 仍为空 | 仅一个通知及一个时序，不覆盖全部通知类别。主代理记录当前候选边界，全部入口未重验部分继续 PARTIAL |
| AC09 真实 Push | PARTIAL，供应商送达PENDING | 当前没有真实供应商送达回执。软件通知接口证据不替代外部送达 | 仍由 Owner 按原边界决定真实供应商接入，本轮不记完成 |
| AC10 APP、API、MariaDB、Web 联合持久链 | PARTIAL，当前开发 API 与 MariaDB 切片通过 | 当前 `ordinary-social-formal-current-private.json` 记录 cfd、后端核心 6549、工具代码 e7 身份下 37 次实际本机 HTTP 与开发 MariaDB 操作。当前消息持久化与对端读回字段为 true，好友关系持久化为 true，unblock 不恢复旧关系或访问。`backend-missing-bank-retry-private.log` 记录修复题库输入后仅重跑失败的 AdminApi 两项，2 tests、26 assertions 通过 | 先前 7 个文件的整体检查曾有两项因缺题库文件报错。只重跑这两项不等同于整体 suite 全绿。当前未以一条联合旅程证明 Web、重启前后持久数据和所有管理写操作。主代理合并回执并保留这些限制 |
| AC11 交付资料、复核和接受 | PARTIAL，接受待定 | 当前候选、关键回执、未完成项和责任方已形成集中材料。两张 MBTI 当前主题截图已由主代理复核，选项内容及选中态完整可见 | 顾问验收和 Owner 最终功能接受仍 PENDING。G2 保持 false。真实 Push 保持 PENDING。最终报告与manifest已更新，Owner保留最终产品接受和发布决定 |

## R1-03 普通功能补充

| 入口 | 当前状态 | 证据与结果 | 剩余项与负责方 |
|---|---|---|---|
| 资格提交与状态读回 | 当前候选受控 UI 与定向测试通过 | `qualification-controlled-current-ui-private.json` 绑定 cfd 和当前 APK。实际控制响应覆盖提交失败保留输入、重试接受、接受后读回失败继续留在表单，之后 GET-only 确认。提交未调用身份供应商，也未写真实资格数据库。联合53项及后续资格22项分别通过，相关analyze无问题，重叠集合分别记账 | 仅验证本地受控 UI 状态处理，不证明真实身份认证或审核。由 Codex 主代理收口材料 |
| MBTI 选项可读性 | 当前候选实机截图已观察并复核 | `mbti-readability-current-private.json` 绑定 cfd。暗色和亮色截图均完整显示题干及 A/B 选项，3/3 的 A/B/A 选择可读。主代理已复核两图 | 服务端提交动作数为 0，不声称测评服务端读回。此样式项可按当前截图证据记录 |
| 注册、登录、改密与退出 | 受控 API 回执，候选绑定有限 | `ordinary-authentication-private.json` 记录 15 次本地 API 检查，涵盖注册、重复注册拒绝、错密码拒绝、成功登录、错误旧密码拒绝、改密后旧密码拒绝、新密码登录、既有会话状态、退出和已退出 token 拒绝 | 原回执未写APP身份。部署时序将实际API关联到6549核心/e7开发工具，APP UI结果按另外回执记录。仅虚构账户 |
| 首次自动引导与跳过 | 隔离 Android user 受控观察 | `isolated-first-use-private.json` 记录虚构注册、登录后首次引导自动出现，跳过后回到首页并指向进展入口。未清除原 Android user 数据 | 原回执缺少源码字段，经构建/安装时序关联e7包，cfd后续只改连接，继承首次引导文案及触发结果。仅此隔离用户和入口 |
| 问卷和参与状态 | 本地开发 API 受控证据 | `journey-participation-private.json` 记录两名虚构对象各答完 20 题，参与状态可 active、paused、resumed，旧 revision 返回冲突 | 部署时序关联相同6549核心/e7工具，证明虚构账号问卷与参与软件状态。真实招募和身份验证另行记账 |
| 连接同意与切号反馈 | 当前候选 UI 与开发 API 受控 | `connection-lifecycle-current-ui-private.json` 绑定 cfd，记录发起连接、对端 API 接受、请求消息同意、撤回、重新请求、接受和读回。当前 connection 页 22 项测试和生命周期测试 14 项通过，相关 analyze 无问题 | 不替代完整连接和消息权限并发矩阵。主代理将测试结果与 AC03 合并 |
| 好友、搭子、社区和正式关系 | 当前候选、本机 HTTP 与 MariaDB 实际回执 | `ordinary-social-formal-current-private.json` 绑定 cfd 和后端身份，37 次操作覆盖好友请求及接受、搭子、社区动态可见性、正式关系 pending/确认拒绝/撤回、block/unblock。旧好友访问不会因解除屏蔽复活 | 只覆盖虚构测试对象及具名流程，不等于所有权限矩阵。留在 AC03/AC10 的 PARTIAL 范围，由主代理保留边界 |
| 本地反馈草稿 | 当前候选本地流程通过 | `feedback-current-private.json` 绑定 cfd。帮助与反馈入口实际生成草稿，修改使旧稿失效，原生剪贴板 Paste 验证复制内容，返回设置页。服务端提交动作为 0 | 回执未观察到复制提示反馈，不影响 native Paste 的剪贴板读回结论。无服务端提交功能，不记为线上反馈发送 |
| 管理审核旧表单 | 新建虚构对象的受控操作 | `admin-review-current-private.json` 记录审核状态读回及 stale revision 409 | 部署时序关联6549核心/e7工具，实际管理表单写入及状态读回有效。真实身份供应商仍未配置 |

## 仍需处理

| 具体入口与条件 | 当前动作或能力 | 未覆盖条件及原因 | 负责方 |
|---|---|---|---|
| `/formal-relationships` 申请后确认 | 当前MariaDB中申请、Provider未配置时403、撤回已测；ACTIVE及分享/撤回/拉黑软件逻辑有SQLite受控证据 | 当前开发库缺双方真实有效身份凭据，ACTIVE与正式关系资料共享未做真实供应商流程 | Owner保留真实身份供应商决定，Codex维护软件证据 |
| 我的→隐私控制，RELATIONSHIP_SHARED字段 | 自有资料与受众策略按既有受控检查，好友社区FRIENDS/SELF本轮真实开发链已补 | 正式关系ACTIVE下的资料共享需要上行条件；不把好友社区可见性扩为正式关系共享 | Codex及Owner按身份条件分工 |
| `/status/author/:userId` 作者页 | 当前APP固定无权态，按既有界面能力登记 | 无可用公开作者资料展示；该占位没有成功作者页承诺 | 后续功能取舍由Owner决定 |
| Discover兼容直达→内容详情→稍后查看 | “稍后查看”只提供当前提示，本地书签持久化能力未建立 | 正式变体或具体内容资源的详情状态保留SRC_ONLY；对应控件/路由见原验收导航表 | Owner后续取舍，Codex维护现状说明 |
| 关闭restorationLocalBuild后的Messages/MatchShell/Connection | 源码条件路由和演示态按原清单登记 | 本轮交付为恢复开发包，另一变体的运行/持久链为NOT_RUN | Owner后续选择交付变体 |
| 设置→反馈及星盘/版本等带来源反馈入口 | 设置入口生成/修改失效/原生复制/返回已测，其他来源映射沿现有定向检查 | 每个来源入口逐台截图未重拍，服务端提交能力未建立 | Codex保留具名入口证据 |
| 设置→账号安全→账号注销 | 原回执空态按11月12日候选保留 | 本轮未执行注销写入或不可逆账号清理 | Owner保留不可逆操作决定 |
| 来电/通话页首次权限拒绝、系统撤权与恢复 | 当前MC提交停媒已测，已有权限窗口/采集恢复定向测试及Owner原音频反馈按候选继承 | 手机首次授权、系统撤权重授和硬件路由完整组合未在本轮双模拟器矩阵穷尽 | Codex维护软件覆盖，Owner协助具名实机条件 |
| 搭子邀请到期、社交冷却与15/30天期限 | 软件受控时钟/版本拒绝及本轮正常邀请生命周期分开记录 | 自然期限尚未经过，长时设备观察和自然到期动作按原边界待验 | Codex记录自然时序，Owner按条件协助 |

上述条目的原入口与控件可由[既有导航清单](../acceptance/UI_NAVIGATION_AND_CONTROLS.md)定位，原120图按11月12日各候选身份引用。

主代理继续定位未注入 authority query 超时的共同 PHP 延迟根因并完成 R1-01 判定。当前撤权停媒 5 秒链、call53 故障恢复、call54 正常呼叫和 25 分钟级观察均保留各自证据，不合并成根因关闭结论。完整并发矩阵、自然 15/30 天、硬件 Keystore、物理故障、复杂 AEC、真实 Push、顾问验收和 Owner 接受仍按原边界记录。本轮总状态继续为 **CHANGES_REQUIRED / PARTIAL**。
