# APP-INT-08｜纯恢复核验门候选回执

**状态：WORK LEVEL 2 ACCEPT — PURE CANDIDATE EVALUATOR ONLY。** 作者本地基线 `main` `b79566d2d6328ecab45b30182465e83ddf48fb0a`。作者只新增以下两个 Dart 路径与本回执；未自行提交、推送、备份、接受或派发后继。

| 新增路径 | 本轮最终 Git blob | 用途 |
|---|---|---|
| `apps/flutter_elitesync_module/lib/features/chat/domain/conversation_revalidation_gate.dart` | `080f1a2efb9ec941e93e7dfd53506f2cd06bb6e8` | 无 widget、Riverpod、网络、存储、时钟或全局状态的纯判定器。 |
| `apps/flutter_elitesync_module/test/features/chat/domain/conversation_revalidation_gate_test.dart` | `f10c814dc4ab35d31beb5e0496a1011e08ec52f8` | 全部使用虚构 actor、aggregate、context、revision 与调用方核验回执。 |
| `EVIDENCE/APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR/summary.md` | 交付时以本地文件为准 | 本执行回执。 |

## 行为与证据等级

判定器接收独立 Connection 和 Messaging Consent 输入；各输入显式带有 claimed origin、state、主体/双方参与者、Connection aggregate/context、purpose/audience、source owner/provenance、独立 lineage 与**不透明** revision、currentness、freshness，以及 identity/participants/provenance/purpose-audience/revision/freshness/context 七项调用方核验结果。缺字段、来源 unknown/synthetic、任何核验未通过或绑定不一致都失败。只有测试夹具同时提供 `CN_ACTIVE`、`MC_ACTIVE` 与各项通过回执时，才可能得到候选结果。

live-read 与 live-send 分开计算。普通 read 时不产生 send 候选；send 仅在 `sendSubmission` 调用点重新评价时可能产生。两者各有独立的调用方 scope check，read 结果不推出 send。输出命名为 `Candidate`，不是真实权限或可展示/可发送指令；函数没有能力验证服务器签名、真实身份、当前修订真伪或 source owner。调用方若把旧证据错误标为 current，本函数无法纠正；可信来源、比较及并发 reconciliation 必须由未来另行授权的边界完成。

该纯门不消费 `CV_ACTIVE/CV_PAUSED/CV_CLOSED` 的当前 authoritative Conversation lifecycle，也不实现 APP-INT-07 要求的最终 UI 遮蔽/数据类别权限。未来实际 live read/send 仍须独立核验 Conversation lifecycle、数据权利与目标操作。不得把本门的 positive candidate 直接接到列表、正文、草稿、未读、发送或恢复缓存。

## 验证回执

- 既有 `.dart_tool/package_config.json` 可用；本轮 `flutter pub get` **0 次**，依赖未更新。`pubspec.lock` 前后 Git blob 均为 `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`。
- 精确命令：`flutter test --no-pub test/features/chat/domain/conversation_revalidation_gate_test.dart`。实际 **2/2 次**，两次均为 13 tests PASS；第一次 PASS 后静态复核发现把 revision 假定为正整数没有接受来源，遂改为不透明非空标识，第二次验证了最终代码。没有第三次运行。
- 覆盖：双输入 fresh-valid（虚构回执）、loading/unavailable/unknown、synthetic/unknown origin、offline 无当前证据、stale/superseded/incomparable、freshness 未通过、`MC_REVOKED` 及其他非 active 同意、Connection paused/closed、新 aggregate 使用旧 consent、actor/participant/purpose/audience/context mismatch、缺字段/缺核验、独立 revision lineage、旧 active 被标 superseded 后乱序到达、read 后 send 前失效。
- 未运行 analyze、全量测试、Android build/模拟器、PHP、HTTP、DB 或真实服务。尾随空白检查无命中，`pubspec.lock` 未变，未修改现有 `product_conversation_contract.dart` 或其他 tracked 路径。原有无关 untracked 目录保留原状。

## 未决与停点

真实身份/session、authoritative Connection/Consent 证据来源、revision/currentness/freshness 的核验方法、Conversation lifecycle 来源、本地私密数据保存与加密、保留/删除、离线历史以及跨设备撤销传播均不由本任务决定。本候选没有建立后端、缓存、UI、发送或重启恢复能力；停在 Work LEVEL 2 独立审查门。

## Work 独立审查（2026-09-23）

Verdict: **ACCEPT — BOUNDED PURE EVALUATOR AND NEGATIVE TESTS ONLY**。Work 核对作者交付的三个新增路径、源码 blob `080f1a2efb9ec941e93e7dfd53506f2cd06bb6e8`、测试 blob `f10c814dc4ab35d31beb5e0496a1011e08ec52f8`，没有其他 tracked 变更。静态阅读确认函数无 Riverpod、网络、存储、时钟或状态副作用；缺字段、synthetic/unknown、非当前、核验未通过、主体/上下文不一致及非 active 状态均不能得到候选通过。read/send 分开，send 仅在 `sendSubmission` 时可能通过。13 项测试覆盖合同要求的主要正负矩阵；作者因修改 revision 类型后按预算第二次运行，两次均报告 PASS。Work 未重复运行测试或 analyze，故运行结果依赖作者回执。

此代码只对**调用方声称的**证据和核验回执做一致性判断。`authoritativeClaim`、`passed` 和 source owner 字段可由调用方构造，不能证明真实服务端真伪、当前修订或有效身份；`liveReadCandidate/liveSendCandidate` 绝不可直接用于展示或发送。尚未消费权威 Conversation lifecycle、保存/数据权利或实际恢复路径。下一步须先找出并审查真实来源及核验边界，不能以本接受跳过它们。
