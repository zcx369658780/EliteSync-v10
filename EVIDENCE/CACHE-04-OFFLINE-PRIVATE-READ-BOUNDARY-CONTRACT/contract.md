# CACHE-04｜离线私密只读边界合同候选

Status: `WORK LEVEL 2 ACCEPT — DESIGN CONTRACT ONLY`

类型：`docs-only`；原作者基线为本地 `main` HEAD `bcbd2f12bc261d8e83f4e790af06487b0ef07774`；本轮修订核对后的 `main` HEAD 为 `aee1e916f30ba494ab9c2b45ca3d1a333f467cd2`。本文只固化已接受方向并提出可审查的安全条件，不提供真实离线授权或实现。

## 1. 决定层级与合同优先级

- **OWNER ACCEPTED**：`PRODUCT_DECISIONS.md` 最后一项允许登录有效且设备已保存相应按账户加密内容时，在断网中（包括离线冷启动）只读本地会话/消息/图片视频，并查看已保存草稿；离线不得发送。离线编辑及持久写回草稿尚未经 Owner 决定。该决定**仅修订**旧“每次重启先在线核验才能显示缓存”的离线只读条件。在线 live read/send 仍要求权威当前 `CN_ACTIVE` 与独立 `MC_ACTIVE`，发送提交时重查。24 小时建议已被拒；约 7～15 天是登录持续方向，非精确期限，也不是每类缓存或离线凭据期限。
- **OWNER ACCEPTED / 既有上界**：按账户隔离加密，旧未加密聊天缓存不迁移；已知登出、换账户、撤权/关闭/失效须锁定或按已批准政策清除。`EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md` §§2–5 的主体、参与者、Connection aggregate/context、purpose/audience、source lineage/currentness/freshness、读发分离仍约束在线操作。`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md` D-02/03/07：缓存/路由不能恢复 live consent；revoke/pause/close 后历史只读默认不可用；保留须逐类有 purpose、owner、起止、复核与终点。
- **UNKNOWN / NOT ESTABLISHED**：`EVIDENCE/APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP/source-map.md` §§2–4、§6 未建立真实身份、Connection/Consent/CV 当前来源、受信 lineage/freshness 与新门的产品接线。`EVIDENCE/APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR/summary.md` 只有虚构调用方 claims 的纯判定。当前 `session_provider.dart#SessionNotifier.build()` 读本地 token/profile，`chat_providers.dart#conversationListProvider/chatRoomMessagesProvider` 用本地 conversationAccess 状态，`chat_remote_data_source.dart` 为 mock 或旧 v1；它们均不证明离线登录有效或曾有权威 grant。离线凭据格式、签发/撤销、可靠时间、设备绑定、密钥和系统备份策略均**未决定**。
- **PROPOSED**：下面的门、矩阵与负向用例只作为以后实现任务的验收合同候选。若新 Owner 决定与 APP-INT-07 的旧离线禁显行冲突，以本次较新的 Owner 离线只读决定为准；旧合同的在线双输入、失效与历史访问边界继续适用。`EVIDENCE/CACHE-03-PRIVATE-RESTORE-DECISION-PACKET/summary.md` 中“冷启动先在线”的问题已被部分回答，其逐类期限和权威缺口仍待解决。

## 2. 离线冷启动候选门与在线分流

| 场景 | 候选可见/可发边界 | 证据性质 |
|---|---|---|
| 在线首次取得内容 | 先由未来受信来源核验当前主体、同一 Connection context 的独立 `CN_ACTIVE`、`MC_ACTIVE`、权威 CV lifecycle 与该 subject/audience/purpose 的 live-read grant；只有获准且实际保存的类别才可成为离线候选。在线发送仍另行提交点重验 live-send。 | **PROPOSED 接线前提**；权威来源和实现 **NOT ESTABLISHED**（APP-INT-09）。 |
| 离线冷启动 | 在展示任何私密字节前，本地须能独立证明：登录尚在获批有效期、相同账户和设备、已保存内容绑定同一参与者/Conversation/Connection context、上次在线核验的范围与版本、离线可读凭据未过期/未被已知失效事实覆盖、密文完整可解。缺一项即锁定并给非私密占位；只存在 token、profile、缓存、旧 `CN_ACTIVE/MC_ACTIVE`、synthetic flag 或本地时间戳均不足。通过时仅读已保存且仍在获批保留期内的类别；不向服务器发读写请求。 | **PROPOSED 必要证明集合**，不指定签名、密钥、时钟、防回滚或离线授权机制；这些均 **UNKNOWN**。离线无法证明远端从上次同步后未撤权。 |
| 离线期间 | 可查看获批的已保存会话、消息及图片视频，并查看同账户同对象已保存草稿。不得编辑或持久写回草稿、发送、上传、自动排队发送、标记旧消息本地操作为服务端成功，或把只读门转作新 live grant。离线编辑与写回如有产品需要，须先另获 Owner 决定。 | 离线查看与禁发为 **OWNER ACCEPTED**；编辑/写回权限为 **UNKNOWN／未授权**。 |
| 已知登出、换账户、撤权/关闭/失效、凭据或登录过期 | 当本机已知时，先锁定对应内容和发送，再按逐类已批准清除/隔离政策处置密文、缩略图和临时副本；不得靠旧缓存打开历史只读。 | 锁定及历史默认禁用为 **OWNER ACCEPTED / D-03**；精确清除与隔离方案 **UNKNOWN**。 |
| 重新联网 | **PROPOSED** 先暂停离线展示，重新取得可信主体、当前 Connection/Consent/CV 和数据权利；对新 revision、撤权、关闭、账户变化或冲突做协调。只有重验通过的对象才恢复在线 live read；send 仍在每次提交时重查。已保存草稿若对象或权限变了，不自动发送或跨账户合并；失败保持锁定，处置待定。 | 不把离线凭据升格为在线 authority；真实接线 **NOT ESTABLISHED**。 |

断网期间若远端新撤权，本机无法及时获知；在获批准的离线有效窗内可能继续显示已经保存的内容。这是 Owner 新方向的残余风险，**不能**声称实时撤权保证。已知撤权后仍显示则不在本合同许可范围。离线到期、可靠时间不可证明或密文不可验证时按锁定处理；本页不选择具体证明机制。

## 3. 内容类别、存储及清理边界

“可候选”只指此前经过受信在线权限与数据权利核验、确实保存且属于同一账户/对象的密文；不要求预下载全部历史，不把设备某处有文件视为可读授权。各类保留期限与具体字段仍待 Owner/数据责任方决定。

| 类别 | OWNER ACCEPTED 的离线用途与 PROPOSED 绑定/存储条件 | UNKNOWN / 停点 |
|---|---|---|
| 会话索引、名称、预览 | 可只读**已保存**的会话信息。候选密文须按账户、设备及当前 Connection/Conversation 对象绑定；列表每一行独立核对，不能由一行许可解锁其他行。当前 `conversation_list_page.dart` 取 `conversationListProvider`，CACHE-01 已移除旧 `messages_conversation_snapshot_v1` 的页面读写。 | 字段 allowlist（身份、名称、预览、未读是否包括）、实际加密位置、保留期和逐行失效粒度未定。旧快照不可作为离线库。 |
| 消息文字 | 可只读已保存且获准的正文；候选按账户、Conversation、消息标识、来源版本/用途绑定。当前 `chat_room_page.dart` 有 `_localMessages` 内存，`chat_providers.dart#chatRoomMessagesProvider` 走 mock/旧 v1 数据源；没有可用的新加密持久路径证据。 | 哪些消息保存、正文/附件元数据字段、删除终点及编辑/撤回后的本地协调未定；不能把本地乐观消息当服务端已接受。 |
| 已下载图片/视频 | 只读以前获准且实际下载并纳入受控加密存储的媒体；消息和媒体主体/对象/版本须一致。`chat_media_gateway.dart#PlatformChatMediaGateway.pick/upload()` 使用 picker 路径，`video_message_preview_page.dart#_buildController()` 可从本地文件或网络 URL 播放，这些是现有静态路径，**不是**加密离线下载库或设备观察。 | 下载范围、文件密文位置、解密临时文件寿命、播放器/网络/插件缓存、系统相册及 OS 备份边界 **UNKNOWN**；不能把 URL 可达或 picker 原件当已保存。 |
| 缩略图、临时文件、媒体缓存 | **PROPOSED** 与主媒体同等私密，受相同账户/对象/期限/锁定清理约束；授权失效时不从缩略图、转码文件、播放器缓存或系统备份侧漏。 | 插件及 OS 的实际文件/备份行为、可控制的清理边界 **UNKNOWN**；若不能证明隔离和删除，媒体离线实现停下。 |
| 未发送草稿 | 仅可离线查看已保存草稿，不得离线编辑、持久写回或发送。候选应按账户、Connection/Conversation/peer 与草稿版本绑定。CACHE-01 已停用旧 `chat_draft_*` 页面读写，CACHE-02 只建立旧键精确清除路径。 | 新草稿存储、期限、登出/换账户/撤权时清除或隔离、重连后与服务器状态协调 **UNKNOWN**；旧明文草稿不迁移。离线编辑/加密写回只可作为未来另行请求 Owner 决定的选项，不在本合同当前许可范围。 |
| 搜索词、通知预览 | 本次 Owner 离线许可未自动涵盖这些类别；仍遵守 CACHE-03 待决及隐私最小化边界。 | 若以后需保存，须另外逐类 Owner/数据权利决定，不从会话或媒体许可推定。 |

**回退/清理上界**：CACHE-01 的旧页面禁读写屏障和 CACHE-02 的启动/账户边界精确旧键清除路径保持有效；CACHE-02 的 synthetic tests 16/16 PASS 不等于实际设备擦除。新离线库若不能验证密文、账户绑定或媒体临时副本，回退为锁定/非私密占位，不能重新启用旧明文快照/草稿/搜索历史读取。已知失效要覆盖内存视图及全部受控副本；清除还是隔离、失败重试和系统备份处置须另获明确政策与设备证据。

## 4. 三种时钟与待选期限

**OWNER ACCEPTED**：24 小时建议被拒；“登录约一周至半个月”仅为方向。**UNKNOWN**：精确登录会话有效期、每类密文保留期、离线可读凭据有效期及撤权传播上限。三者不能互相替代；保留较长不产生读权。以下只是 **PROPOSED 比较选项**，不选值、不规定统一保留期：

| 独立期限 | 供 Owner/责任方审议的明确选项 | 撤权不可及时获知的含义 |
|---|---|---|
| 登录会话 | 从经受信登录/续期起 **7 天** 或 **15 天**；续期、设备重置及可靠计时方法待定。 | 它只限制本地“登录仍有效”的一个前提；不能单独证明 Conversation 权限。 |
| 各类加密缓存 | 对上表每类分别选择自获准保存/最近权威同步起 **7 天** 或 **15 天**，或其他经明确决定的期限与终点；D-07 要求各类独立目的和起止。 | 密文可以仍在而访问凭据已到期；这不延长离线可见性。删除/备份残留窗口另需证明。 |
| 离线可读凭据 | 从最后一次可信在线权限核验起 **7 天** 或 **15 天**，或另一个明确期限；不得由 token TTL、缓存 TTL 或客户端时钟直接推定。 | 若离线期间远端在核验后立即撤权，最坏情况下本机在断网且仍满足其他条件时可见至凭据期限：候选 7 天即至多约 7 天、15 天即至多约 15 天；重连或已知失效应更早锁定。实际界限还受较短的已批准登录/类别期限限制。 |

任何期限都不能靠可回拨的本地时钟或未验证 token 直接证明；防回滚与可信过期证据为 **UNKNOWN**。以上窗口是设计讨论的上界形状，不是已验证设备保证、法律保留期或生产 SLA。

## 5. 最小负向测试矩阵（PROPOSED，未运行）

| 注入情形 | 期望结果 |
|---|---|
| 离线冷启动只有 token/profile、旧缓存、synthetic `CN_ACTIVE` 或旧 consent，无受信且未过期的账户/设备/对象凭据 | 私密列表、正文、媒体、草稿锁定；非私密占位。 |
| 凭据与账户/设备/参与者/Connection aggregate/Conversation 不符，或登录/类别/凭据任一期限过期、时间证明异常 | 仅受影响对象锁定；不得跨账户、跨对象回填或用客户端时间延长。 |
| 某消息或媒体未获准保存、密文校验失败、只有 URL/picker 原件/缩略图/临时文件 | 不显示私密内容，不回退至未保护文件或网络缓存。 |
| 任何离线草稿编辑、持久写回或静默改写草稿版本 | 拒绝且旧草稿内容不变；查看权限不得推导为写权限。未来若需编辑，先取得单独 Owner 决定。 |
| 任何离线发送、附件上传、自动发送队列或“本地发送成功”标记 | 拒绝；已保存草稿仍只是只读候选，不转为 send intent。 |
| 本机已知 revoke、pause、close、logout、换账户、权限冲突或新 aggregate | 先锁定受影响内容和草稿；按后续逐类政策清除/隔离；不启用历史只读。 |
| 远端断网期间撤权，本机尚未知；稍后重连 | 明示离线残余窗口；重连先锁定并重验，发现失效后不闪现旧缓存、不自动发送草稿。不能声称断网时已实时阻断。 |
| 在线重验超时、来源未知、revision 不可比或 CV lifecycle 未证实 | 保持锁定；离线凭据不升级为 live-read/live-send grant。 |
| 回退到旧应用/清理失败/播放器残留 | 不恢复旧明文读取；仅在获准且可证实的受控密文边界内显示，失败保留可重试的非私密回执。 |

## 6. 实现停点与本轮回执

真实身份及登录有效性证明、可信上次在线核验、独立 Connection/Consent 和 CV 当前来源、离线可读凭据签发与撤销、可靠时间/设备绑定、逐类保存期限、媒体加密与系统备份/临时文件处置都 **NOT ESTABLISHED**。在这些 Owner/后端/安全/数据责任方边界未明确前，本合同不能授权实现、设备读取或生产恢复；不把旧 v1、synthetic 测试或纯 evaluator 当作真实来源。

本轮只读核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能、APP-INT-07/08/09、CACHE-01～03、Owner D-02/03/07，以及当前 Flutter `session_provider.dart`、`app_bootstrap.dart`、`local_storage_service.dart`、chat provider/页面/remote data source/media gateway/video preview。静态代码、既有 synthetic 测试、APP-INT-06 的一次 debug 冷启动观察和生产证明分开：本轮**未运行**产品测试或设备操作；该既有观察是重新 seed 后回到 `CN_NONE/CV_LOCKED`，不是离线恢复证明。未读取真实账户、Token、设备私密值、API/DB 或网络；未修改任何既有文件或代码。

验证回执：原作者在 `bcbd2f12bc261d8e83f4e790af06487b0ef07774` 基线已按任务预算运行 `git diff --check` **1 次，exit 0**；它不覆盖未跟踪新文件。本轮依据 Work 更新后的 `PRODUCT_DECISIONS.md`、`TASK_CURRENT.md` 和新 HEAD `aee1e916f30ba494ab9c2b45ca3d1a333f467cd2`，只修订同一 `contract.md` 的草稿权限、负向用例及基线，不重跑已耗的 `git diff --check`。修订后本文件只读尾随空白检查为 **0 行**；`git status --short` 只列本合同目录及原有无关未跟踪目录，没有 tracked 改动。未运行 Flutter/Android、设备、HTTP/API、DB、网络或产品测试；作者未提交、备份、推送或派发后继。

## Work 独立验收（2026-09-23）

**LEVEL 2 ACCEPT — 仅离线私密只读设计合同。** Work 核对 `main` 基线、`PRODUCT_DECISIONS.md` 的最新 Owner 方向、APP-INT-07/09、CACHE-01～03 与当前 Flutter 静态路径；唯一新增文件在允许路径内。预审发现最初草稿“查看”被误扩为“编辑/写回”，Work 已先收窄产品决定和任务单，作者随后修订合同；最终版本仅把离线查看草稿列为已接受，离线编辑/写回和发送均不获授权。合同分别标出离线冷启动的候选证明、在线 live read/send 既有权威门、媒体与系统副本风险，以及远端撤权在断网期间不可及时获知的窗口；7/15 天只是待选期限，未被写成 Owner 已决定的值。

Work 独立检查本文件尾随空白为 0，精确暂存后 `git diff --cached --check` 退出 0。本验收不建立真实身份/离线凭据、加密媒体库、设备运行或生产恢复证据；不授权实现代码或撤权后历史只读。
