# EliteSync v10｜TASK_CURRENT

Task ID: `APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR`

Risk Level: `LEVEL 2`（恢复权限纯判定；须由 Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。Work 在 APP-INT-07 LEVEL 2 设计合同接受后下达本任务；只交付候选与证据，不自行接受、提交、备份或发布后继。

## Objective / bounded result

为“重启后先重新核验当前有效性，再恢复私密对话/消息”实现一个**未接入产品流的纯判定器**及针对性负向测试。它只接收虚构、显式标注来源状态的 typed evidence，输出本次 live-read、live-send 的独立候选判定及失败原因；不能自己制造 authoritative 证据，也不能把输出接到 UI、发送、缓存或 provider。下一阶段接入真实来源前，这不是实际恢复授权。

## Fixed sources

先核验本地 `main`、工作区与 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`。消费 `EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md`、BA-05 两输入 live gate 接受记录、Conversation data-rights Owner 接受记录，以及现有 `product_conversation_contract.dart`。不重写既有 lifecycle 或假设真实 backend/source 已可用。

## Allowed paths

- 可新增 `apps/flutter_elitesync_module/lib/features/chat/domain/conversation_revalidation_gate.dart`，只含纯数据类型和纯函数，不依赖 Flutter widget、Riverpod、网络、存储、时钟、全局状态或真实 actor。
- 可新增 `apps/flutter_elitesync_module/test/features/chat/domain/conversation_revalidation_gate_test.dart`，用虚构 actor/context/revision 构造正负用例。
- 可写 `EVIDENCE/APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR/summary.md`，记录差异、命令次数、结果与不可证明的来源边界。
- 若现有 `product_conversation_contract.dart` 的类型阻碍最小实现，只报告阻碍和建议，不修改该文件或扩大写集。其他 `lib/`、test、后端、DB、依赖、环境、旧接受文档一律只读；保留无关 untracked 目录。

## Acceptance criteria

1. 输入显式区分 authoritative/current、synthetic、unknown/unavailable，且 Connection 与 Messaging Consent 独立给出 state、主体/参与者、aggregate/context、purpose/audience、来源/修订/currentness/freshness。类型/判定须使缺字段、来源不明、仅本地状态或旧缓存均不能获得通过结果；不得将调用方一个笼统 `valid=true` 当作完整证明。判定器只核对传入证据的内在一致性与已提供的核验结果，**不能声称验证了服务端真伪**。
2. 本次 live read 与 live send 结果分开；在当前 MVP 合同下二者都要求独立、当前有效且同一 context 的 `CN_ACTIVE` 与 `MC_ACTIVE`，但 read 不自动推出 send。调用者须在发送提交点重新调用/取得新判定；本轮不实现发送。
3. targeted tests 至少覆盖双输入 fresh-valid、loading/unknown/unavailable、synthetic、offline 缺当前证据、stale/superseded/incomparable、`MC_REVOKED`、Connection paused/closed、新 aggregate 使用旧 consent、actor/purpose/audience/context mismatch、两输入不同 revision lineage 与旧 active/新失效乱序。失败均返回拒绝及可辨原因，不复活旧权限。
4. 正例只证明在**测试夹具明确提供的核验结果**下纯函数如何判定；不证明真实身份、权威来源、跨进程保存、实际消息可见性、后端或 Android 恢复。不得新增历史只读、离线缓存展示、服务端 API/schema 或产品入口。

## Verification budget / stop conditions

优先只运行新增 targeted Flutter test；允许首次运行加一次针对失败的修正重跑。若需锁定依赖获取，仅 `flutter pub get --enforce-lockfile` 一次，不刷新版本；必要时对新增 Dart 文件执行有界 analyze。不得运行 Android build/模拟器、全量测试、PHP/HTTP/DB、真实服务或 GitHub 同步。若发现判定必须依赖未定义的真实来源证明、保留政策、历史访问或改变既有 consent 语义，停止相关实现，记录准确缺口，不用 synthetic flag 冒充 authority。交付后停在 Work LEVEL 2 独立验收门。
