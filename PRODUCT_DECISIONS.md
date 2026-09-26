# EliteSync v10｜PRODUCT_DECISIONS

这里只记录已接受的产品方向，不把实现、候选或旧代码当作产品接受。下表共同来源为 `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`（2026-09-12 Owner ACCEPT，指向设计 blob `b72ed9ec851d44aba7be65883186cb275fab22d1`）及其所接受的 `ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`。重开条件适用于每项：Owner 的新明确决定，或足以改变该项正确性的隐私、安全、法律、运行证据；普通实现偏好和旧代码存在不构成重开。

| Decision | Status | Evidence / reference | Reopening condition |
|---|---|---|---|
| Relationship Decision Support System；不作为关系真相、罪责或 AI 裁判，也不以停留/消息数为目标 | Owner accepted | Owner acceptance §3；设计正文 §1 | 上述共同条件 |
| MVP 顶层 `Home | Progress | Messages | Me`；Home 为 Calm State Hub 只读投影，呈现状态、下一决定、可选支持 | Owner accepted | Owner acceptance §2(1)；设计正文 IA/Home | 上述共同条件 |
| Discover 转为 Phase 2 secondary Explore / Support Library | Owner accepted | Owner acceptance §2(2) | 上述共同条件 |
| `Match != Connection != Conversation != Relationship`；Match 不自动创建 Connection；Connection 不自动授权 Conversation；消息需独立双方同意 | Owner accepted | Owner acceptance §2(3–6)；设计正文 lifecycle | 上述共同条件 |
| Relationship 为 Phase 2 双方 opt-in；不能由聊天频率、内容或 AI 自动推断 | Owner accepted | Owner acceptance §2(6–7) | 上述共同条件 |
| MVP 无 globally public Profile；Private Identity、Matching Inputs、Readiness、Showcase 分用途；Showcase 默认有受众范围 | Owner accepted | Owner acceptance §2(8)；设计正文 Profile-purpose | 上述共同条件 |
| Readiness 为 named checklist，解释 required/optional 的原因、可见范围、修改/撤回与过期；参考信号非强制项 | Owner accepted | Owner acceptance §2(12)；设计正文 Readiness | 上述共同条件 |
| 无单一权威 Compatibility 总分；Match 解释保留理由、来源、约束、不确定性与用户控制 | Owner accepted | Owner acceptance §2(9)；设计正文 Match/Explainability | 上述共同条件 |
| AI 仅作 advisory；用户声明、AI 推断、安全材料不能冒充已验证事实或普通匹配证据；Conversation 不默认进入 AI、训练或排序 | Owner accepted | Owner acceptance §2(10)、§3；设计正文 Explainability | 上述共同条件 |
| Privacy、Safety、User Control 优先；Block、Report、Allegation、Finding 不互相等同，UNKNOWN 不等于 safe/false | Owner accepted | Owner acceptance §3 | 上述共同条件 |
| 通知默认 privacy-minimal；point-of-use consent 与 central privacy controls 并存；可选提醒默认关闭 | Owner accepted | Owner acceptance §2(12)；设计正文 Notifications | 上述共同条件 |
| Canonical Match 为未来产品路径；legacy participant-linked Match 仅在 consumer inventory、replacement contract 和 rollback/cutover gate 后退休 | Owner accepted | Owner acceptance §2(11)；设计正文 Legacy fate | 上述共同条件 |
| 重启后允许恢复对话、消息等信息，但须先重新核验其当前有效性；恢复并非由本地缓存、旧会话或旧同意自动授权 | Owner direction accepted, 2026-09-23；其中“每次重启先在线核验”对已保存内容的离线只读部分由下方新决定修订 | 原 Owner 决定；既有两输入 live gate 见 `ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md` §3–5，数据权利边界见 `ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md` D-02/03 | Owner 的新明确决定，或足以改变有效性/隐私/安全判断的证据 |
| 恢复方案选择 B：允许设备保存加密的私密缓存；重启后必须先在线重新核验当前有效性，核验通过前不显示缓存内容 | Owner direction accepted, 2026-09-23；其中离线冷启动只读门由下方新决定修订 | 原 Owner 从 A/B/C 中明确选择 B；APP-INT-07 恢复核验合同、APP-INT-09 权威来源缺口映射 | Owner 的新明确决定，或缓存/权限/隐私安全证据改变正确性 |
| 本地私密缓存采用按账户隔离的加密存储；登出、换账户或权限撤销时隔离或清除；旧未加密聊天缓存不迁移，升级清理时允许丢失未发送草稿 | Owner accepted, 2026-09-23 | 本次 Owner 同意所述通用方案及 Work 的旧缓存清除建议；`EVIDENCE/APP-INT-10-LOCAL-PRIVATE-CACHE-AUDIT/summary.md` | Owner 的新明确决定，或实施/设备证据显示数据损失与隐私边界需重开 |
| 允许登录有效且设备已保存相应加密内容时，在断网中（包括离线冷启动）只读本地会话信息、已保存消息与图片/视频，并查看已保存草稿；离线不得发送草稿或其他消息。离线编辑及持久写回草稿尚未经 Owner 决定。在线 live read/send 仍须当前权威核验，send 提交时重查；离线缓存不是当前在线权限或撤销后历史只读权威。 | Owner direction accepted, 2026-09-23，修订上方两项的离线缓存展示条件 | 本次 Owner 明确要求离线可用并举出已保存会话、图片视频和草稿；先前 24 小时建议被拒绝。具体本地登录有效性证明、离线可读凭据与撤销传播、逐类字段及媒体边界由后继合同限定。 | Owner 的新明确决定，或足以改变离线访问/隐私安全正确性的证据 |
| 在线登录持续 15 天；登录期届满后，如设备仍离线且本地已保存内容符合其余离线只读条件，可继续只读至最后一次成功在线登录满 30 天。自动 Token 续期不重置这 30 天计时。连续 30 天没有成功在线登录时清理已保存的按账户加密私密内容，清理后不可离线阅读；离线阅读不另设比该清理期限更短的时间上限。 | Owner accepted, 2026-09-24；修订 CACHE-04 中 7/15 天待选建议 | Owner 明确选择 15 天登录、30 天清理，并在后续确认第 16～30 天仍可离线只读、计时从最后一次成功在线登录起算、自动 Token 续期不重置。实现所需的可靠时间、登录证明、清理范围和失败处理仍待合同与真实来源核定。 | Owner 的新明确决定，或足以改变账户安全、私密内容保留和离线撤权风险判断的证据 |
| `T0` 由服务端确认的成功交互登录事件建立，并向同一账户、设备提供可验证的离线凭据；自动 Token 续期只轮换 Token，不更新 `T0`。设备无法可靠判断经过时间时先锁定私密内容，联网核验后才恢复符合当前权限的访问。 | Owner accepted, 2026-09-24；细化上一项的可信来源与时间异常处理 | Owner 明确同意 Work 基于 AUTH-07 静态缺口提出的服务端登录锚、账户/设备绑定凭据和时间异常锁定方向。凭据格式、签发/撤销协议、设备绑定实现、可靠计时/防回拨和恢复流程仍待合同、实现与验证。 | Owner 的新明确决定，或实现证据显示该机制无法兼顾已接受的离线可用性和隐私边界 |

旧缓存清理仅限已识别的旧未加密聊天草稿、会话快照/预览和搜索历史，不授权清除账户、Token 或其他类别；这与新加密内容的 30 天清理决定属于不同范围。新离线方向允许已保存、按账户加密的会话/消息/图片视频/草稿只读；不自动要求预下载全部历史、保存搜索词/通知预览或开放离线发送。15 天在线登录期、最后一次成功在线登录起算的 30 天新加密内容清理期限和离线只读门分别核对；第 16～30 天离线只读不恢复在线登录或发送权限。可信 `T0` 来源、账户/设备绑定离线凭据方向及时间异常先锁定已由 Owner 确认；逐类字段与副本范围、凭据协议、可靠计时与防回拨实现、清理失败处置和远端撤权传播上限仍待定，不能由产品决定推定已有实现。离线时无法获知新的远端撤销，因而可见性风险必须在后继合同中明确；一旦已知撤回、关闭或失效，仍按既有合同 fail-closed，不因本地缓存恢复历史只读。当前 MVP 在线 live read/send 仍要求分别重新核验当前有效的 `CN_ACTIVE` 与独立 `MC_ACTIVE`，且 send 时重查；真实来源未建立。Phase 2/Later、AI/personality/astrology 可选信号的精确 allowlist、真实身份机制、Proposal 期限、共享内容权利等仍属待决，不能由本页自行补定。产品接受不证明相应代码、后端、DB 或发布链已完成。

## 数据库备份与密钥保管的 Owner 决定

- Owner 于 2026-09-26 在当前 Work 会话明确接受：为**继续准备**一次受限只读诊断候选，可按阿里云命令助手可能长期留存无秘密脚本和严格白名单结果、可见者及期限未知的风险边界设计。此决定不是现场调用、实例内命令、默认 root、SSH、DB、dump、传输或恢复授权；实际脚本、实例技术绑定、权限/异常输出和单次预算仍须新任务与 LEVEL 3 审查，Owner 对具体现场动作另行决定。AUTH-128 页面 1/1 与其他旧预算不重置。
- 本次“完整数据库备份”的目标范围**只包含数据库内的数据与对象**；服务器上的上传图片、视频等数据库外文件不纳入本次备份目标。此范围决定不证明数据库对象全集、实际 dump 完整性或应用整体可恢复性；若恢复依赖外部文件，须另行标明缺口，不把数据库备份称为整站备份。Owner 于 2026-09-26 明确选择“只备份数据库”。
- 完整数据库备份加密保存到 Owner 自己的电脑，存放在 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，自备份完成日起保留 30 天；该目录不采用云同步或云备份。此前 OSS/KMS 优先及阿里云内保存的方向已由 Owner 改定。真实改库前仍须先备份并验证可恢复。这个决定不代表已经生成真实备份或验证恢复。
- 私钥与备份分离保管在 `C:\Users\zcxve\EliteSync-v10-DB-Keys`；加密私钥的恢复副本放在 Owner 的固定 Kingston `E:` BitLocker U 盘。Owner 本人保管并输入私钥密码和 U 盘解锁密码；私钥密码另有纸质副本，BitLocker 恢复密钥已由 Owner 纸质抄写、核对，并与电脑/U 盘分开放置。任何密码、恢复密钥或私钥正文不得进入聊天、Git、普通证据或脚本参数。
- Owner 允许使用这只 32GB U 盘，曾在加密前授权必要时快速格式化；实际未因根目录系统元数据而格式化。AUTH-97 已独立验收加密私钥与公有证书在 E: 的字节相等副本；它不证明纸质恢复密钥能解锁或真实数据库恢复。失钥演练、真实备份和恢复须分别通过任务和高风险门。
- 恢复演练优先在 Owner 电脑上的独立隔离环境进行；真实数据库、密钥、备份、恢复和改库依各任务的具体权限与风险门实施。Owner 授权 Work 在无待决决策时沿路线图下达、验收连续本地任务；此前约 20 张任务复用一个 Codex 会话的安排已由根 `AGENTS.md` 的新会话规则取代。本次长会话已由 Owner 指示在 AUTH-101 候选验收后交接。
