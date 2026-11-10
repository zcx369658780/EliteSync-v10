# APP-INT-07｜重启恢复前的当前有效性重新核验合同

**状态：WORK LEVEL 2 ACCEPT — DESIGN CONTRACT ONLY。** 作者基线为本地 `main` `95bee3df0a0ebd87fa8ce1ebc2dbe4306350b18e`。本文件只把 Owner 的条件恢复方向及已接受的 live gate、数据权利边界组合成可审查的恢复合同；不实现持久化、服务端来源、身份机制或恢复 UI。

## 1. 来源、已决定边界与当前差距

| 来源（本地 main blob） | 本候选消费的决定或观察 |
|---|---|
| `PRODUCT_DECISIONS.md` `57bd67fe78f2a1ba4158b7eb3bbd7fbdffd21df3` | Owner 允许重启后**先重新核验当前有效性，再恢复**对话、消息等信息；缓存、旧会话、旧同意本身不是授权。 |
| `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md` `a133285b0a1923d5d2965ced989d1c8b1dbf8e49` §§2–6 | 独立 `CN_ACTIVE` 与 `MC_ACTIVE` 两输入；各自 owner/provenance、participant、audience、purpose、revision/currentness、freshness、context 绑定；live read/send 分离，send 时重查；撤销、重启、冲突与乱序 fail-closed；无历史只读权限。 |
| `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md` `7f8e98b0d82ff666db401964e32f80deb08d7e15` D-01～03、D-07～10 | 缓存行、路由、未读数不恢复同意；撤回、暂停、关闭后历史只读默认不开；保留须逐类有目的、owner、触发和终点；私密内容用途受限，不能假称权利能力已经实现。 |
| `EVIDENCE/APP-INT-06-RECOVERY-BASELINE/summary.md` `e4ffb6eede8637b583d0b688c3f9c4d521d40050` | 已接受的一次 synthetic/debug 观察：进程退出前 `CN_ACTIVE/CV_ACTIVE`，冷启动后重新 seed 为 `CN_NONE/CV_LOCKED`；不证明未来应清除、保存或能恢复。 |
| Flutter Connection/Conversation contract（`07b0beff…` / `a226f717…`）、presentation provider（`8c5fe6ee…` / `a652a342…`）、Home projection（`605a0689…`） | 当前 `syntheticDevelopment` 只推进本地内存状态；Home 只读这些展示状态。`CV_ACTIVE`、mock identity、旧 provider 值和本地 token 均不是 authoritative `MC_ACTIVE` 或当前 live grant。 |

上述接受记录决定**安全门**，没有决定真实服务端证据来源、重启后的本地保存范围或法律适用性。实现时必须消费精确的新任务与来源，不从本候选推断接口/schema。

## 2. 恢复门：先锁定，后分别授予

| 阶段 | 候选行为合同 | 证据地位 |
|---|---|---|
| 进程/会话重新进入 | 私密列表、详情、正文、草稿、未读数和发送控件先保持不可用；可以显示不含对方身份、消息预览和数量的占位。已保存材料只能作为**待核验候选**，不得先闪现内容。 | fail-closed 展示次序是本任务建议；私密内容不得先于 live-read 门可用是既有接受边界。 |
| 身份与绑定 | 由未来经授权的来源确认当前主体身份、参与者集合，且同一当前 Product Connection aggregate/context 与当前 Conversation/consent 对象相互匹配；匿名、旧账号、旧 aggregate 或只有本地 session seed 均不能通过。 | participant/context 绑定已接受；真实身份来源、session/证据获取协议未决定。 |
| Connection 输入 | 独立取得当前、参与者绑定的 authoritative `CN_ACTIVE`。核对 owner/provenance、audience/purpose、独立 revision/currentness、freshness 和 aggregate/context；旧 `CN_ACTIVE` 不抵消较新的非 active/terminal 事实。 | BA-05 §§3、5 已接受。具体数据模型/来源与 freshness 阈值未决定。 |
| Messaging Consent 输入 | 独立取得当前、相同参与者/purpose/当前 Connection context 绑定的 authoritative `MC_ACTIVE`；同样核对 owner/provenance、audience、独立 revision/currentness、freshness。历史 `MC_ACTIVE` 不抵消当前 `MC_REVOKED`；新 Connection aggregate 必须有新的 consent lifecycle。 | BA-05 §§2–5 已接受；不得从 `CV_ACTIVE`、Connection active 或本地布尔值推定。 |
| live read | 两输入均通过后，仍分别评估本次 live-read grant 与当前 Conversation lifecycle；仅在该 grant 有效的对应 subject/audience/purpose 范围内请求/展示私密内容。read 不推出 send。 | 两输入、读写分离与 pause/close 后无默认历史只读已接受；精确 grant 接口待设计。 |
| live send | 用户提交时对两输入及独立 live-send grant **重新核验**；失败则拒绝，不以页面先前可读、旧授权、缓存、乐观排队或到达顺序继续发送。 | BA-05 §§4–5、D-02 已接受；具体并发协议待后端设计。 |
| 失效 | 任一输入经当前核验判定撤销、暂停/关闭、变旧、不可比、来源不可用或 context 不符时，关闭本次 live 可见性和发送能力；若要显示历史，须另有明确历史访问权限。 | fail-closed 与 D-03 已接受；跨设备变更传播时效及本地清除/加密/保留方式尚未决定。 |

不得发明全局 revision、缓存 TTL 代替 authoritative freshness、last-write-wins、客户端时间戳或消息到达顺序作为权限裁决。重新核验的结果必须绑定本次请求的主体、对象和用途；一次成功不能成为跨对象或长期通行证。

## 3. 数据类别与可见/可发边界

| 类别 | 重新核验前或失败时 | 通过当前 live-read 门后 | 另需决定 |
|---|---|---|---|
| Conversation 索引/对方身份/预览 | 隐藏；只显示非私密占位 | 仅展示本次 grant 覆盖的行和字段 | 索引字段、缓存范围与局部失效粒度。 |
| 消息正文/附件元数据 | 不加载、不展示，不短暂显示旧缓存 | 仅展示获准的当前 live 内容 | 本地保存、加密、保留、删除及附件规则。 |
| 草稿/输入框旧文本 | 视为受保护私密数据；不自动回填 | 读取权限足够也不自动给出发送权；恢复草稿需另定保存/归属规则 | 是否保存、跨设备同步、失效时清除或隔离。 |
| 未读数/通知预览 | 不显示旧数或私密预览 | 仅在本次 grant 与数据来源一致时显示 | 通知渠道、后台刷新与撤销传播。 |
| 发送动作 | 禁用 | 仍须在每次提交点重验 live-send grant | 失败后的用户反馈与幂等/重试协议。 |

“缓存里有”只说明字节存在，不证明内容仍保留合法、当前可读、可发，或可用于其他目的。此表不决定数据实际应保存多久，也不把 D-03 的历史只读默认禁用解释成内容已删除。

## 4. 负向矩阵与最小测试建议

| 输入/事件 | 期望合同结果 | 后续测试建议 |
|---|---|---|
| fresh-valid：同一当前主体/aggregate/context，独立当前 `CN_ACTIVE`、`MC_ACTIVE`，purpose/audience/revision/freshness 均通过 | 分别计算 live read 与 live send；不互相推导 | 双输入同源对象绑定；分别断言列表/正文和发送。 |
| loading、timeout、source unavailable、UNKNOWN | 仅非私密占位；read/send 均不开 | 延迟/失败/超时注入，验证无旧缓存闪现。 |
| offline，无法证明两输入仍当前有效 | 不靠本地旧 grant 开 live read/send；历史只读仍未建立 | 离线重启、断网后恢复；不得把缓存命中当 PASS。 |
| 任一输入 stale/superseded/incomparable | 整体 live gate 关闭；另一输入不能补救 | 分别变旧 Connection 与 consent，并测试不可比 revision。 |
| 当前 `MC_REVOKED`；或 `MC_PENDING/DECLINED/WITHDRAWN` | 关闭 live read/send；旧 `MC_ACTIVE` 无效 | 撤销与终态覆盖旧缓存，验证请求顺序无关。 |
| `CN_PAUSED/CN_CLOSED` 或其他非当前 `CN_ACTIVE`；Conversation pause/close | 关闭 live read/send；不默认显示历史 | 暂停/关闭后立刻隐藏详情、草稿、未读及按钮。 |
| participant、purpose、audience、Connection context 不匹配 | 关闭；不可跨主体/用途复用 | 各绑定字段单独变异。 |
| 新 Product Connection aggregate，旧 consent 仍 active | 关闭；需新 aggregate 下重新走 consent lifecycle | 同参与者但新 aggregate 的负向测试。 |
| 冲突、重复、乱序证据或 send intent | 不按到达顺序/LWW 判成功；等待 authoritative current revision reconciliation | permutation 与并发回执，检验旧 active 不复活。 |
| 发送期间被撤销、关闭或 revision 前进 | 提交点重新检查；无当前 grant 不发、不排队为未来自动发送 | 在 read 成功后、send 前插入失效事件。 |

本矩阵是**候选验收用例**，不是已经运行的测试，也不规定新的服务器错误码、刷新周期或可用性承诺。

## 5. 决定层级与开放问题

| 层级 | 内容 |
|---|---|
| 已由接受合同决定 | Owner 的条件恢复方向；独立当前 `CN_ACTIVE` + `MC_ACTIVE` 两输入；participant/context/purpose/audience/provenance/revision/currentness/freshness 绑定；live read/send 分离、send 时重查；失效 fail-closed；撤回/暂停/关闭后无默认历史只读；逐类保留治理与私密用途边界。 |
| 本候选建议，待 Work LEVEL 2 独立审查 | 重启时先占位再重验的展示次序；受保护类别的 UI 遮蔽表；上述负向矩阵与分片顺序。它们未形成已接受接口或实现。 |
| 仍需 Owner/法律/后端 authority | 真实身份/session 与 authoritative evidence 来源；本地保存哪些索引/正文/草稿/未读，何种加密与账户隔离；各类 retention 起止/审查/终点；离线历史是否、何时、以何独立 authority 可看；撤回/关闭后的清除、隔离与对方可见效果；地域适用与权利请求；后台刷新与通知；跨设备及并发协议、错误/重试策略。 |

本候选不给开放问题选择默认政策。可选方向仅为：不落地本地私密缓存、仅落地受保护的最小候选索引、或在权利/保留/加密与来源均获批后落地更多内容；任何方向均须单独审查和任务授权。不得把“Owner 允许条件恢复”扩写成允许离线历史查看或无限期本地留存。

## 6. 后续最小切片（仅排程建议，未派发）

1. **合同验收**：Work 对本候选作 LEVEL 2 ACCEPT/REJECT；若绑定字段或当前性语义有冲突，先收口冲突，不写代码。
2. **纯判定与负向测试**：另立精确任务实现输入判定、read/send 分离和失效矩阵，优先只用虚构 typed evidence；因权限语义按 LEVEL 2 审查。不得由 synthetic provider 自报 authoritative。
3. **来源与保存决策**：Owner/后端/法律按数据类别和部署范围明确身份、current evidence、保存/加密/retention/离线历史；LEVEL 2 或触及生产/不可逆时 LEVEL 3。未决时仅可做无私密缓存的占位路径。
4. **受权集成与设备回归**：在来源和数据决策完成后，另立有界 backend/client 任务分别接入 live read、send-time 重查和失效遮蔽，再做重启/并发/撤销的目标平台验证；按实际最高风险重新分类，不能用 synthetic debug 结果替代真实 authority。

## 7. 本轮静态回执

仅读取本地 task、已接受文档 §§2–6/D-01～03、D-07～10、APP-INT-06 回执及所列 Flutter 合同/provider。已按本地 `HEAD` 核对四份主要来源路径及 blob；新增路径只有此 `contract.md`，无 tracked diff，原有无关 untracked 目录保留；尾随空白检查无命中。逐表核对两输入、read/send、失效和数据类别与来源相容。未运行 Flutter、Gradle、模拟器、PHP、HTTP、DB、网络或真实数据操作；未修改任务源文件或产品代码。待 Work 独立审查；本段不自称独立 ACCEPT。

## 8. Work 独立审查（2026-09-23）

Verdict: **ACCEPT — BOUNDED RECOVERY REVALIDATION DESIGN CONTRACT ONLY**。Work 逐项核对作者原候选 blob `c3d3b1d44fc2813c34894ed4066061da553f80d9`、九个引用源码/文档 blob 与本地 `main`，确认只新增本合同，无产品、依赖、后端或 DB 差异。两输入的独立当前性、绑定、撤销与新 aggregate 约束符合 BA-05 接受记录；D-02/03 的实时读写和历史只读边界得到保留。负向矩阵覆盖未知、离线、失效、撤销、乱序和发送时失效；没有把缓存、旧同意或 synthetic provider 提升为 authoritative。Work 将失效一行的“立即撤销”收窄为“经当前核验判定时关闭”，避免把尚未设计的跨设备传播时效写成已保证能力。

本接受只固化设计合同和后续测试方向。真实身份/session、权威证据来源、各类本地保存/加密/保留与离线历史仍未决定；没有实现或运行恢复机制，没有运行 Flutter/Android/后端测试，亦没有建立真实服务端或生产权限。
