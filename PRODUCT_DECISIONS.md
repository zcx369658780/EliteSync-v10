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

旧缓存清理仅限已识别的旧未加密聊天草稿、会话快照/预览和搜索历史，不授权清除账户、Token 或其他类别。新离线方向允许已保存、按账户加密的会话/消息/图片视频/草稿只读；不自动要求预下载全部历史、保存搜索词/通知预览或开放离线发送。Owner 拒绝此前 24 小时缓存建议，并表达约一周至半个月的登录持续可用期望；精确登录期限、逐类缓存期限、离线可读凭据有效期及失效传播上限**尚未决定**，不能互相替代。离线时无法获知新的远端撤销，因而可见性风险必须在后继合同中明确；一旦已知撤回、关闭或失效，仍按既有合同 fail-closed，不因本地缓存恢复历史只读。当前 MVP 在线 live read/send 仍要求分别重新核验当前有效的 `CN_ACTIVE` 与独立 `MC_ACTIVE`，且 send 时重查；真实来源未建立。Phase 2/Later、AI/personality/astrology 可选信号的精确 allowlist、真实身份机制、Proposal 期限、共享内容权利等仍属待决，不能由本页自行补定。产品接受不证明相应代码、后端、DB 或发布链已完成。
