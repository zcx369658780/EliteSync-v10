# APP-HM-03｜Synthetic Home 未知 Match 输入不冒充无提案

状态：`ISSUED`；风险 `LEVEL 2`（Home/Match 展示状态语义，仅 dev synthetic 演示）；派发 Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。交付候选后停 Work 独立 LEVEL 2 审查。

## 固定入口与目标

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有工作区原样保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能，以及 APP-HM-02 的 `work-review.md`。APP-T12 对 Home 活态权威仍保留 G-08；本任务只处理当前人工演示状态，不建立真实权威来源。

在显式 synthetic Home flag 打开且 `ReadinessGuardState.ready` 时，`matchRoundProjectionProvider` 处于 `AsyncLoading` 或 `AsyncError`，现有 provider 将 Match 摘要标 unknown，却把 `matchAvailable=false` 映射为“当前没有可用的匹配提案”。加载/失败只说明 Match 结果未取得，不证明无提案。此时保留 Match summary 的 unknown，不发布 synthetic `authoritativeNextDecision`；沿用 `CalmHomeProjection.nextDecision` 现成的安全“查看进展”导航回退，文案不得宣称没有提案。已有 `AsyncData` 且确有已分类 Match 状态、准备状态 `setupRequired`/`unknown`、非演示 flag 与 APP-HM-02 已接受行为保持原样。不要把 HTTP/transport 失败归为领域无提案，不加新权威、路由或后端接口。

## Codex 允许路径与基线

只允许修改以下两文件，另新增本目录 `summary.md`：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，修改前 SHA-256 `D752B012D88178B16941E7446D56A6812DF141FA238F6AE4550C36504E7C457D`；
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，修改前 SHA-256 `9153BB0A13FEDB3A59460D57895149A14D4B8C47599A49847BB99D8B44D117CC`。

用本地虚构 provider 状态增加加载和失败的定向负例：准备状态 ready、Match summary unknown、无已判定下一决定，回退仅导航到 Progress 且不说“没有可用的匹配提案”。保留现有 flag-off、readiness unknown/setupRequired 与 ready 主循环测试。若需要检验明确的 `AsyncData` 无提案状态，只使用虚构数据且不得扩大文件集合。

## 新一次性验证预算与停点

执行前只读核对两文件哈希、`.dart_tool/package_config.json` 与本机 `dart`/`flutter` 命令；不运行 `pub get` 或下载。改动后对两文件各最多一次 `dart format` 写入，再各最多一次只读 `dart format --output=none --set-exit-if-changed`，退出 0 才可报格式 PASS。定向执行 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑一次；仅可归因于本次编辑缺陷的失败允许修正后额外复跑一次。对两文件运行 `git diff --check`。不跑完整套件、模拟器、设备、网络、后端或真实数据。

`summary.md` 记录基线/最终哈希、加载/失败与已知状态区分、检查退出码和用例数、未覆盖的真实 Home/Match 权威及回退范围。回退只撤销本任务两文件差异与摘要，保留 APP-HM-01/02 和全部无关状态。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。旧任务预算不重置。
