# BE-15 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅限任务单指定的 `conversation_capability` 与 `user_action` 两项投影修复；整个投影的消息动作声明尚未关闭。** 作者 `summary.md` SHA-256 `395442068643ECA99E288785B62C17CC62710C144A94D28CCA4C7AAB33235DAB`。候选修改后哈希：`MatchRoundProjectionService.php` `AF4C6A35FBA03D071D82270E3D5854806209BFF33AECEFA13E09571D39734F06`，`MatchingTruthSliceIntegratedSmokeTest.php` `F422FE7D6FC381D99E036096F27B005A1D180F87B758996D900853C67B619ABE`，`C2LocalRuntimeIntegrationTest.php` `8C1F2F558498C834C6A00658B49B82C55A09ADFEAF028360B0507219E0CB9D6E`；均与摘要一致。

独立差异审查确认：revealed 不再调用旧 `ConversationCapabilityService`，仍返回 match/peer 结果；`conversation_capability=null`，revealed/closed 的 `user_action=refresh`。两份允许测试相应改断言，MatchingTruth 继续核对真实会话路由统一拒绝及无写入。生产路由哈希 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`、BE-12 未旁路保护测试哈希 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8` 未变。作者三份语法检查退出 0；四份定向 Feature 首跑分别 1/31、6/79、7/83、2/24，合计 **16 tests/217 assertions**，各有 2 deprecations，无复跑。Work 未重复运行；完整套件 `NOT_RUN`。

残留缺口：`MatchRoundProjectionService` 仍透传持久化 `next_action_code`；revealed synthetic 场景可返回 `open_conversation`。该字段在 BE-15 任务单中属于保留的其他 match 字段，因此本验收不覆盖它。它仍可误导客户端，须 BE-16 有界修复与独立审查。匹配状态持久化的 `conversation_eligible` 及其他出口也未由本任务证明安全。不得以本接受宣称整个投影或生产消息能力已就绪。

未接触 SSH、真实 DB、备份/恢复、部署、提交或 GitHub 同步。BE-15 旧验证预算不重置。
