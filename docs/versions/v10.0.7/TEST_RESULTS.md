# v10.0.7 测试与构建结果

本文件记录实际执行结果，不作独立验收或合并结论。主代理提供的本轮源码锚：commit `7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f`，tree `754b9a65b41ac9393687417836e380effc81c09b`。测试收据发生于持续修复过程；后续有针对性复测，不把较早套件结果冒称最终源码全部重跑。

本地证据根 E：`C:\Users\zcxve\.codex\visualizations\2026\10\14\01a13afa-b74f-7c11-b7e0-01a04335168d\v1007`。下表名称均相对 E；每次 `.json` 收据列命令、cwd、起止时间、exit和stdout/stderr SHA-256，同名前缀 `.stdout`、`.stderr` 为原始流。原始失败保留。

## 总览

| 证据前缀 | 实际结果 | 限制 |
| --- | --- | --- |
| `php-related-04` | 21个具名PHP文件，139 tests / 1162 assertions，exit 0 | SQLite自动测试；2项弃用仍存在，不是全PHP仓库测试。完整文件清单见收据command。 |
| `php-projection-final-02` | 5 tests / 34 assertions，exit 0 | 后续匹配投影针对性复测；2项弃用。 |
| `flutter-full-final-03` | 792通过、6失败，exit 1 | 全量Flutter测试未全绿，失败逐项见下。 |
| `dart-analyze-final-02` | 3条info，exit 1 | 位于qualification diagnostics测试，非零退出保留。 |
| `dart-lib-analyze-final-03` | `No issues found!`，exit 0 | 仅产品`lib`范围，不能替代全仓analyze。 |
| `build-07` | Android `assembleDebug` 成功，exit 0；38 tasks（4执行、34 up-to-date） | 调用`build-local.ps1`，本地恢复Dart define；产物身份及APP安装/联合重启由manifest和执行报告登记。 |

收据stdout SHA-256：

- Flutter全套：`29bed792503f663f526c5e401f5c8a3be5e81639d5b3c25b7e1047fa3bf45a1b`
- PHP相关：`a0010f22e8f01c7f27d5fa9e486cf46860c2845017ea897b451a271006a75c22`
- PHP投影最终：`22b55c6b37c190f5a7c845d055559591d5cabff861c0fb7dde3465049c3a119c`
- 全范围analyze：`d32d28fcc7c0c1865f85b368f3ca5d9b0ab03e9192978639aa37b78f5ecd5386`
- lib analyze：`a0274c2544cd6a2009fee56d4ae5400ccd4833beacb8972319d70b7ff2cdcdc9`
- build07：`b1f48197e8f28b21d7d1b6d55ecaa5741f801a3634fcf7e043429bf90753440d`

## 全量Flutter仍失败的6项

路径均相对 `apps/flutter_elitesync_module/`。

| 测试 | 原始原因 |
| --- | --- |
| `test/features/chat/data/datasource/chat_remote_data_source_send_test.dart` — mock mode returns a deterministic well-formed typed result | 预期server message ID `1`，实际`990000499`。mock身份断言与当前输出不同。 |
| `test/features/chat/presentation/conversation_access_gate_test.dart` — locked gate does not build or reveal protected content | 找不到预期文案“拉黑与举报是两个独立控制”。 |
| `test/features/match/presentation/widgets/match_round_contract_view_test.dart` — revealed state ignores supplied conversation capability | 预期不展示“你们都愿意从一次轻松对话开始。”，实际找到该文本。 |
| `test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart` — setUpAll | `Same-run PHP JSON is mandatory; no static fallback`，缺同次诊断fixture。 |
| `test/features/qualification_diagnostics/qualification_diagnostic_test.dart` — setUpAll | `Same-run PHP diagnostic fixture is mandatory`。 |
| `test/synthetic_main_loop_recovery_baseline_test.dart` — Match loading and error stay UNKNOWN and route to Match | 预期`/progress/match`，实际`/progress`。 |

上述逐项原因来自最终原始stdout，不把它们统称已证明的“旧baseline失败”。本次未在未修改基线重跑这些6项，因此历史归因未证实；也未删除测试、跳过断言或以数量替代真实业务验收。

全范围analyze的3条info：两个qualification diagnostics测试引用未直接声明的`crypto`依赖（各第4行）；`qualification_diagnostic_test.dart:221`字符串拼接建议插值。产品lib最终独立分析通过；测试info仍保留。

## 失败、修复及有限回归

- 问卷合同：`questionnaire-contract/red.*`原3项失败，暴露索引当答案及version硬编码、draft无实际写入；修复后focused 7项通过。后端snapshot、stale bank/version、legacy答案格式绕过分别新增回归；`php-stale-snapshot-red.*`保留旧snapshot失败，`php-stale-snapshot-green.*`1项18断言通过。完整问卷`legacy-guards-full.*`12项107断言通过。
- 每题推进：`questionnaire-contract/durable-provider*`4项provider测试通过并限定analyze通过，验证服务端draft保存成功才推进、失败原位、保存/提交期间重复点击不重复请求。仅自动测试替身，不是APP实测。
- 私有媒体：`media-tests/corrected.*`保留真实`Cache-Control: no-store, public`失败；产品修复后`ordered-lock-green.*`4项32断言通过。PNG上传、附件URL、接收者下载、第三人/未登录/撤销拒绝、恶意alias覆盖、public disk注入及漏配置拒绝均有测试。原`initial.*`含测试JSON斜线比较错误；另重复运行触发429亦保留，最终fixture使用独立虚构身份/IP而未绕middleware。
- 八字来源：`bazi-provenance/repeat-time.*`6项53断言通过，实际lunar引擎，无HTTP算法fake；包括已知四柱、默认午时降级、重复保存仍unknown、明确补时后替换旧来源、非法输入无写、经度跨日。`initial.*`中的factory原始属性未包含DB默认字段导致比较失败已保留，修复的是测试比较基准。
- 隔离门：`isolation-gate/unit.*`17项17断言通过，Connection mock不建立DB连接；覆盖production/flag/driver/db/host/socket/3306/43316/不匹配端口拒绝及正确本地配置。
- 匹配说明：`matching-explanation/focused.*`2项27断言通过，真实MatchingEngine及SQLite持久pair，验证natal/ziwei/pair weight0、score0、degraded及MBTI/personality排除。匹配通知`match-notification/initial.*`记录首次mutual无成功通知失败，修复后`green.*`1项24断言通过；like仍不授予消息许可。
- Flutter fixture：最初`flutter-full-01`781通过、13失败。6个router重复dispose失败修复测试所有权，EditProfile fixture补AppEnv及虚构登录态，不放宽资料保留断言。`fixture-repair/targeted.*`保留当时产品CancelToken方法编译错误，`targeted-green.*`保留缺登录fixture失败；最终`authenticated-green.*`四文件35项通过。其余6项在最终全套仍失败，见上表。

本节bounded收据有的采用`.stdout.txt/.stderr.txt/.exit.txt`三件流，必须以实际文件名核对；不把各轮数量相加成独立覆盖数。PHP最终相关套件已包含大部分上述文件，重复执行不是新增测试数。

## 构建与未执行事项

`build-01/03/04/05/06/07`收据exit均0；`build-02`exit1原因为PowerShell脚本执行策略拒绝加载，原错误保留，没有伪装成Gradle成功。build07 stdout保留`libapp.so`无法strip、按原样打包的警告；stderr保留Flutter资源下载来源提示。成功构建不表示无警告。

本文件编写只读证据，不启动服务、不连接真实数据库、不重跑测试、不安装APP，不核验生产或第三方服务。SQLite/Widget/provider测试不能替代冻结AC要求的APP/API/MariaDB持久链、权限正反例及联合重启；这些结论需查看执行报告、业务原证和产物manifest。本文件不对候选作ACCEPT，也不启动后继版本。
