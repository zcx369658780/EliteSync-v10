# APP-HM-01｜Synthetic Home 未知准备状态候选回执

**作者候选已交付，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。本任务仅修改以下两个允许文件并新增本摘要。

| 文件 | 修改前 SHA-256（任务单基线已核对） | 修改后 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `2048C09B0D5DB1BD558DED6432711FF51D655A89164B4544DB22CBD1D1E34A11` | `CCE29A835FBC910BEA917285FB7335BFF22DC0B3D1CA5941C1C2CC71DE859678` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `4B2F3ECB57D9CB7C75C3F3D4465FF3C604EC4A26A4E5FE759E41316BA4124283` | `1595DA1CEEC5A5ACDF0582E5FDC8062C3D5D8C36DFA55B6606BC48BF49C5FDDB` |

## 行为边界

仅在显式 dev synthetic Home flag 已开启的 provider 分支，`ReadinessGuardState.unknown` 使准备状态 summary 和 `readinessAuthority` 为 `HomeProjectionAuthority.unknown`、`stateCode=null`、`authoritativeNextDecision=null`。`CalmHomeProjection.nextDecision` 因而使用既有回退，仅导航到准备状态页，文案为“准备状态尚未建立”，不再把未知说成“尚未就绪”。`setupRequired` 仍保持 synthetic 状态及既有“尚未就绪”提示，`ready` 的 Match → Connection → Messaging consent → Conversation 主循环照旧。非演示分支仍返回 `CalmHomeProjection.current`；未改四栏 IA、后端、路由或权威状态来源。

新增两个定向测试分别检查 `unknown` 的未知 authority、无 synthetic 下一决定与安全导航，以及 `setupRequired` 的旧提示；原有 flag-off 和 ready 主循环测试保留。本候选**不**关闭 APP-T12 G-08 真实 Home 活态来源缺口，也不从路由、缓存、Match 或 Connection 推断 readiness。

## 一次性验证回执

- 执行前只读核对两个基线 SHA-256 均与任务单一致；`.dart_tool/package_config.json` 存在，`flutter`、`dart` 命令可用。未执行 `pub get` 或下载。
- `dart format --output=none --set-exit-if-changed` 对 provider **1/1 次，退出码 1**；对测试文件 **1/1 次，退出码 1**。两次均报告将改变格式，且 `--output=none` 未写文件；之后未修改这两份源码。按一次性预算未重跑，最终格式检查仍为 **FAILED**，不能报格式 PASS。
- `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` **首跑 1/1 次，退出码 0**，4/4 tests passed：flag-off、unknown、setupRequired、原 ready 主循环。未使用修复后复跑预算。
- 对两个目标文件的 `git diff --check` 退出码 `0`；仅提示 Git 未来可能将 LF 转为 CRLF，无尾随空白错误。

没有运行完整套件、模拟器/设备、网络、后端或真实数据。回退只撤销本任务在两个目标文件中的差异及本摘要，保留既有工作区。作者不自接受、不提交/pull/push、不派发后继；停在 Work LEVEL 2 `ACCEPT/REJECT`。AUTH-170、AUTH-155 Phase B、真实 CMS 认证/隔离恢复/账号回填与 Home live projection 状态均不因本候选改变。
