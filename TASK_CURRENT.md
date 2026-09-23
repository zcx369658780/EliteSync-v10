# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-06-OFFLINE-RETENTION-PURE-POLICY`

Risk Level: `LEVEL 2`（登录期限与私密内容可见性判定；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPT — REAL-AUTHORITY / INTEGRATION GATE; NO ACTIVE CODEX TASK`

Assignee: `Codex`（已交付并由 Work 独立接受）。接受证据：`EVIDENCE/CACHE-06-OFFLINE-RETENTION-PURE-POLICY/summary.md`。

Next gate: 可信成功在线登录事件、可靠时间/防回拨、账户/设备身份与离线读取凭据、当前 Connection/Consent/CV 和数据权利来源均未建立。当前纯判定不得接 UI、真实缓存或清理器；真实接线另立有界任务并按最高风险审查。当前没有活动 Codex 执行单。

## Authority and objective

以 `PRODUCT_DECISIONS.md` 的 Owner 已定 15/30 天规则和已接受 `EVIDENCE/CACHE-05-SESSION-OFFLINE-RETENTION-CONTRACT/contract.md` 为上界，在 Flutter chat domain 新增一个不读取设备、不写缓存、不连接 UI/API 的纯判定器。给定**调用方声称**的可信上次成功在线登录后经过时间、账户/设备/对象与离线读取条件、已知失效状态及受控密文完整性，分别返回：15 天在线登录窗口是否尚未届满的候选结果、离线只读候选结果、30 天清理是否到期的候选结果，并给出可测试的拒绝原因。返回值一律不是受信登录证明、真实 grant 或实际清理回执。

规则必须覆盖：`0 ≤ Δ < 15 天` 可处于在线登录期但不自动获得 live read/send；`15 天 ≤ Δ < 30 天` 即使在线登录期结束，只要仍离线且其他离线门均通过，仍可只读；`Δ ≥ 30 天` 不可读并标出清理到期，但不执行删除。自动 Token 续期、应用重启、profile 更新时间不作为新的成功在线登录事件，不改变计时输入。时间证明缺失、不可信、负经过时间或异常时 fail-closed 锁定且不得误判已完成清理；登出/换账户/已知撤权必须拒绝离线展示。纯判定器不得返回在线 live read/send 授权，在线权威双输入门保持独立。

## Allowed paths

仅允许新增：

- `apps/flutter_elitesync_module/lib/features/chat/domain/offline_private_retention_policy.dart`
- `apps/flutter_elitesync_module/test/features/chat/domain/offline_private_retention_policy_test.dart`
- `EVIDENCE/CACHE-06-OFFLINE-RETENTION-PURE-POLICY/summary.md`

可只读项目控制文档、CACHE-04/05、APP-INT-07/09 和必要的 Flutter 同层纯判定器与测试。不得修改其他源码、既有测试或控制面；不得接入 provider、页面、路由、登录/Token、加密存储、旧缓存清理、网络或 backend，不读取真实账户/设备私密值，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

## Acceptance and verification budget

使用虚构输入做有针对性的单元测试，至少覆盖 15 天前后、29 天末、恰满 30 天、自动续期不能重置、未知/负/不可信时间、账户/设备/对象不匹配、已知失效、非离线状态、完整性失败，以及清理到期与清理完成之间的区别。测试不得声称真实授权、真实设备清理或生产可用。作者最多运行目标测试 2 次、对新增源/测试的定向分析 2 次、`git diff --check` 1 次；若失败，记录每次结果和修正。未跟踪新文件另作尾随空白检查。证据注明本地分支/HEAD、精确路径、检查回执及未运行项。

若实现需要自行选定可信时间/登录凭据来源、持久化/删除机制、离线媒体或撤权传播方案，则停止并列出缺口，不接线。Codex 不自接受、不提交、不备份、不派发后继。Work 按 LEVEL 2 独立 ACCEPT/REJECT；本任务没有真实设备、API、DB 或生产动作授权。
