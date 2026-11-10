# APP-HM-01｜Synthetic Home 未知准备状态不冒充未就绪

状态：`ISSUED`；风险 `LEVEL 2`（Home 状态语义，仅本地 synthetic/dev 演示）；派发既有 Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。交付候选后停 Work 独立审查。

## 依据与边界

唯一实时仓库 `D:\EliteSync-v10`，当前本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 86 条 `git status --short` 原样保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md` 和本地 workflow/runtime 技能。APP-T12 已接受的静态矩阵保留 G-08 Home 活态来源缺口；本任务只修演示状态描述，绝不建立 G-08 的权威来源。

当前 `calmHomeProjectionProvider` 在 `ReadinessGuardState.unknown` 时把 `readinessReady=false` 映射成“准备状态尚未就绪”，并把 summary/decision 标成 syntheticDevelopment；未知不等于 `setupRequired`。仅在明确 synthetic Home flag 的分支修正：`unknown` 的准备状态 summary 为 `HomeProjectionAuthority.unknown`，不发布已判定的 synthetic 下一决定；利用现有 `CalmHomeProjection` 的安全导航回退到准备状态页，文案仅说状态尚未建立。`setupRequired` 和 `ready` 的既有演示主循环、非演示分支与四栏 IA 保持行为。不得从路由、缓存、Match 或 Connection 推断 readiness，也不得把这项演示修正称为真实 Home live projection。

## Codex 允许路径与基线

仅可修改以下两文件，新增本目录 `summary.md`：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，修改前 SHA-256 `2048C09B0D5DB1BD558DED6432711FF51D655A89164B4544DB22CBD1D1E34A11`。
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，修改前 SHA-256 `4B2F3ECB57D9CB7C75C3F3D4465FF3C604EC4A26A4E5FE759E41316BA4124283`。

代码只处理 `ReadinessGuardState.unknown`。新增定向测试应核对 synthetic flag 打开且准备状态未知时 summary 为 unknown、没有 synthetic `authoritativeNextDecision`、下一步仅安全导航且不声称未就绪；原有 ready 主循环仍通过。不要修改 backend、域合同、路由、产品文档或其他测试。

## 一次性验证预算和停点

执行前只读检查目标文件哈希、`.dart_tool/package_config.json` 和 `flutter` 命令可用性；不运行 `pub get` 或下载依赖。对两文件各一次 `dart format --output=none --set-exit-if-changed`；运行 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 最多一次。仅当失败能归因于本任务编辑缺陷时，修正后允许该测试额外复跑一次，并在摘要记清首跑与复跑。若工具/依赖不可用则记 `NOT_RUN`，不自行修环境。对两文件运行 `git diff --check`。不跑完整套件、模拟器、设备、网络或后端。

`summary.md` 记录前后哈希、差异、每项检查退出码和测试数、未知/已知状态对照、未证实的真实权威与回退范围。回退只针对本次两文件差异及摘要。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或自行验收/派发后继。旧 AUTH 预算不得复用。
