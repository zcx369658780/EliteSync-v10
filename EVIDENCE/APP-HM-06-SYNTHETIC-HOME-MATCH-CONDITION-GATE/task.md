# APP-HM-06｜Synthetic Home 不把 Match 传输/关闭不确定性当无提案

状态：`ISSUED`；风险 `LEVEL 2`（Home/Match 展示状态语义，仅本地 synthetic/dev）；派发新 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。该会话已完成只读交接，旧会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca` 因 31 turn 停用。交付候选后停 Work 独立 LEVEL 2 审查。

## 固定入口与候选行为

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能和 `EVIDENCE/CODEX-HANDOFF-20260929-APP-HM/handoff.md`。新会话交接只读核对已完成，旧一次性预算不重置。

在显式 dev synthetic Home flag 下，准备状态 ready，Match `AsyncData` 已返回时，`CanonicalMatchLifecycleAdapter.fromRound` 对 `MatchRoundBusinessState.failed` 给出 `transportUnavailable`，对 `closed` 给出 `closedWithoutCompletionEvidence`；这两类都不能证明“当前没有可用的匹配提案”。现有 Home 将它们当 `matchAvailable=false` 并输出该负向描述。只在这两类 condition 下让 Home Match summary 为 unknown、`stateCode=null`、不发布 synthetic `authoritativeNextDecision`，沿用既有“查看进展”安全回退。已知 `noRound`/`noCandidate`、可用 revealed/active 主循环、APP-HM-01～05 已接受边界和非演示分支保持。

不得编辑 `CanonicalMatchLifecycleAdapter`、产品状态词、真实权威、后端、路由或 Match writer；本切片不建立 APP-T12 G-08 的真实来源，不把传输失败变成领域结果。

## Codex 允许路径与基线

只允许修改下列两文件，另新增本目录 `summary.md`：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，输入 SHA-256 `ACCB6E0BD61CCAEF00FEB33C8CEF6E1E23EF19999DDF347695A843B487A7BBD4`；
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，输入 SHA-256 `12B6810CD661AA1ED1D38601332CD17D30C0F27FB04270948C14430591F5E593`。

以虚构 `failed` 与 `closed` 两种 Match 投影各增一条负例，核对适配器 condition、Home unknown summary、无已判定下一决定和安全回退文案。另用一条已知 `noCandidate` 或 `noRound` 用例守住其现有“查看匹配”导航，不把明确分类误改为 unknown。保留原八条定向测试。

## 新一次性验证预算与停点

执行前只读核对两文件哈希、`.dart_tool/package_config.json` 与本机 `dart`/`flutter` 可用性；不运行 `pub get` 或下载。修改后两文件各最多一次 `dart format` 写入、各最多一次只读 `dart format --output=none --set-exit-if-changed`，退出 0 才可报格式 PASS。执行 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑一次；仅本次编辑缺陷可修正并额外复跑一次。对两文件运行 `git diff --check`。不运行完整套件、模拟器、设备、网络、后端或真实数据。

`summary.md` 记录前后哈希、两种不确定 condition 与已知无候选分类的区别、各检查退出码/用例数、未证实的真实权威及回退范围。回退只撤销本任务两文件新增差异及摘要，保留 APP-HM-01～05 和全部无关状态。不得访问旧 `D:\EliteSync`、SSH、云/生产 API、真实 DB/备份/密钥；不得提交、pull、push、自验收或启动后继。旧预算不重置。
