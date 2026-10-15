# v10.0.7 R1-02／R1-03 定点测试归因

2026-10-15。依据固定独立审查提交 `657c1af73749c2925dd4fd8a7b3a63350f86cb79` 的全文执行；本文件不改冻结计划、初始报告或原始失败，不作最终接受结论。

## 固定比较与执行隔离

- 实施起点：`0989812c141ce892915b67c14e9291d34e3c7053`。
- 初始候选：`69b3f26c6ed28a7306e4ba6b902aac2475bfe103`。
- E：`C:\Users\zcxve\.codex\visualizations\2026\10\14\01a13afa-b74f-7c11-b7e0-01a04335168d\v1007`；本次证据在 `E/r1/`。
- 起点同条件基线在独立临时package `E/r1/baseline-package`执行。全部固定`lib/assets`、pubspec/lock/analysis_options/.metadata及下列5份原测试从起点Git对象导出；不读取原dirty根，不带.env，不创建worktree，不替换专用树产品源码。`baseline-export-manifest.json`列441个导出源文件的Git Blob、SHA-256及执行后逐字节比对；全部一致，包括基线lock。
- 使用同一 `D:/flutter/bin/flutter.bat`、现有锁及缓存，`pub get --offline`后`test --no-pub`，不提供诊断fixture，与初始失败的缺fixture条件相同。路径变化是临时package隔离的必要差异，不声称整个历史APP或完整历史套件重跑。
- `fixed-object-comparison.json`记录16条具名对象比较；`.receipt.json`记录实际命令/cwd/退出码/流hash。receipt_created_utc是事后登记时间，不冒充命令起止时间；`.stdout/.stderr/.exit`保留实际执行流和退出码。

## 六项失败的逐项判定

下列路径相对 `apps/flutter_elitesync_module/`。

| 初始失败 | 固定对象与实际复测 | 本次处理 |
| --- | --- | --- |
| `test/features/chat/data/datasource/chat_remote_data_source_send_test.dart`：mock typed ID预期1、实际990000499 | test Blob起点`966f08ce32bdc0f24e52039e2ca8696498276d71`、候选`5a8cdca0e74bc418289756b57bfaa5a823f23d56`。两版差异仅fake API的CancelToken签名；`expect(...,1)`在起点已存在。产品datasource两版同Blob `b6c8c281aabb45e3dcbfa6bb00b27d41ca35a2a6`，固定mock确实返回990000499。 | 属继承错误断言，但该文件本轮已触及且候选须修。仅改确定ID为990000499，保留typed ID、client key、消息内容、conversation和重播相等全部断言；不改真实ID/权限/幂等产品语义。 |
| `test/features/chat/presentation/conversation_access_gate_test.dart`：缺“拉黑与举报是两个独立控制” | test同Blob `e32f6f0d932919c0c896b85829ff396e0685ba31`，widget同Blob `fb09ca4ed76590c78c889eccba49b26a4a33f259`；固定起点实际复现相同缺文案失败。 | 本版未引入的legacy文案合同不一致，未删断言或改产品。该测试失败前的protectedBuilder=0、私密内容不存在、匹配不自动开对话断言仍执行通过；缺文案不能解释成已授权聊天。 |
| `test/features/match/presentation/widgets/match_round_contract_view_test.dart`：reveal显示给定headline | test同Blob `8caeda9c28a14b1f584e803967d721a3d2740b4b`，widget同Blob `a88d36f68809c79686fc700c260692759cc972cb`；固定起点实际复现同样headline可见失败。 | legacy展示断言不一致，不是本版改动。旧widget直接渲染headline，该文本不构成可信服务端Connection/MC证据；不靠改文案或删断言证明权限。真实live权限应以独立CN/MC及服务器拒绝回归为准。 |
| `test/features/qualification_diagnostics/qualification_diagnostic_test.dart`：setUpAll缺同次PHP JSON | test同Blob `3e67da81d5844fdefddfd20b05e278a078f37d95`，领域解析器同Blob `1d5a4cc16040d73432a0548f4cb57b85fc5bef58`；固定起点无fixture执行复现相同错误。 | 必需运行输入缺失，非本版产品退化。保留无fixture fail-closed；另用真正同次纯PHP输出执行通过，不引入static fallback。 |
| `test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart`：setUpAll缺同次PHP JSON | test同Blob `bd598ba850b789510739e661aa0e330e16cf2766`，preview同Blob `47533fbec5acb8b0e02c962fba408bb5d1966f7c`；固定起点复现相同缺输入失败。 | 同上，另有带同次fixture成功证据，未修改测试fixture门。 |
| `test/synthetic_main_loop_recovery_baseline_test.dart`：预期`/progress/match`，实际`/progress` | test同Blob `4129fd6ab23cb87cc26640e11ee714e06d037710`；calm provider同Blob `a07e0863573db74fd7705a4657cdedc3295ba91c`，projection同Blob `b253b9f87990f9140d495ad6fa6a733b329842ac`，route names亦相同。固定起点完整lib依赖下复现相同route差异。 | 不是本版router变动造成的失败；保留legacy synthetic UNKNOWN导航合同缺口，未擅改产品或测试期望。 |

起点5文件实测：**20通过／5失败，exit1**（`baseline-five.*`）。三项legacy与两项缺fixture逐项复现，不能将其报成全绿。typed ID不在该5文件基线执行范围，继承性结论来自固定源码行差异与实际mock常量，不冒称做过typed历史运行。

## R1-03窄修与结果

起点与候选pubspec.yaml同Blob `1b807ccdcced1e3166fd6e5378865ecb5bba4708`、lock同Blob `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`。起点临时package实际`analyze --no-pub`复现同3条info并exit1：两诊断测试直接import未声明crypto，另`qualification_diagnostic_test.dart:221`拼接建议插值（`baseline-analyze.*`）。这是具名范围实测，不是完整历史测试树的analyze。

本次仅：

1. pubspec增加已锁定`crypto: 3.0.7`为dev_dependency；offline解析后lock唯一变化为`transitive`→`direct dev`。crypto版本3.0.7、包SHA及其余依赖均不升级。
2. 第221行超深JSON测试字符串改等价插值；不改变生成内容或嵌套拒绝断言。preview测试无需改源码，直接依赖声明消除其info。
3. typed mock ID断言按固定datasource修正。

当前专用树全范围 `flutter analyze --no-pub`：**No issues found，exit0**，见`r1-analyze.*`。这是本次运行时工作区结果；最终候选需由主代理固定源码身份，原`dart-analyze-final-02 exit1`仍保留。

## 同次诊断fixture与定点成功证据

纯PHP exporter：`services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php`。该入口明确不加载Laravel、Composer、.env或服务；本次没有Http fake、真实API、数据库或权限写入。其12个虚构scenario／930 checks通过；输出3229 bytes，SHA-256 `334b71e018915aedac38385d4b328bca2b6514572f90c41a8888897bba5e8ad9`，实际文件bytes/hash与exporter回执一致。

执行方法（在专用仓库，E为上列证据根）：

```powershell
php services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php > "$E/r1/same-run-diagnostic.json" 2> "$E/r1/same-run-diagnostic.stderr"
# 先核exporter exit0及输出hash，再在Flutter模块运行：
flutter test --no-pub "--dart-define=QUALIFICATION_DIAGNOSTIC_FIXTURE=$E/r1/same-run-diagnostic.json" test/features/qualification_diagnostics/qualification_diagnostic_test.dart test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart test/features/chat/data/datasource/chat_remote_data_source_send_test.dart
```

本次三文件 **36项通过，exit0**（`r1-fixed-tests.*`）；测试打印的实际输入hash与上述PHP输出一致。仅虚构合同诊断，不代表正式资格、真实消息或APP业务闭环。该成功不覆盖仍保留的三项legacy失败，亦不将初始Flutter792／6失败原证改为通过。

## 边界

本轮未修改Flutter产品、原执行报告或原测试结果文件；不删测试、减断言、skip或修改基线断言。不commit/push，不连接真实API/DB，不操作受保护根、生产、历史备份或第三方服务。R1-01通知隐私由主代理独立处理，本文件仅交付R1-02/03归因及窄修证据，等待主代理集成和Astra独立复核。
