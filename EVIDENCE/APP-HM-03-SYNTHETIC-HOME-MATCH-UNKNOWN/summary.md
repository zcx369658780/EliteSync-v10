# APP-HM-03 Codex 候选摘要｜2026-09-29

状态：候选已完成，待 Work 独立 LEVEL 2 审查；未自验收、提交或推送。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。既有工作区其他内容未处理。

## 边界与差异

仅在显式 dev synthetic Home flag 且准备状态为 `ready` 时，Match provider 若没有 `AsyncData` 投影（本任务的加载或失败负例），Match 摘要继续为 `unknown`，`authoritativeNextDecision` 保持 `null`，由既有 `CalmHomeProjection.nextDecision` 回退到“查看进展”/Progress；不再从未取得的 Match 结果推断“没有可用的匹配提案”。已取得 `AsyncData` 的分类与现有主循环、准备状态 `unknown/setupRequired`、非演示分支均未改变。测试新增虚构 `AsyncLoading`、`AsyncError` 两例，原有四例保留。

这只是本地 synthetic 展示语义修正；APP-T12 G-08 的真实 Home/Match 活态权威来源、真实身份/权限、设备和生产行为仍未验证或建立。回退范围仅为本任务两文件的新增差异与本摘要，保留 APP-HM-01/02 和全部无关工作区状态。

## 输入与最终 SHA-256

| 文件 | 输入 | 最终 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `D752B012D88178B16941E7446D56A6812DF141FA238F6AE4550C36504E7C457D` | `0218B56F900C4A9BB34C7AF7E592EC65FFC10A2B4F8318FC7FF09F50C2A812F3` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `9153BB0A13FEDB3A59460D57895149A14D4B8C47599A49847BB99D8B44D117CC` | `EECFF7B123DC8F794555D7AAD98E1D9AB5C835E90159D4200F3BE83D0C823778` |

执行前确认 `.dart_tool/package_config.json` 存在、`dart`/`flutter` 本地命令可用；未运行 `pub get`。

## 一次性验证回执

| 检查 | 消耗 | 结果 |
| --- | --- | --- |
| `dart format` 两文件 | 每文件写入 1/1 | 退出 0，两文件排版 |
| `dart format --output=none --set-exit-if-changed` | 每文件只读复核 1/1 | 各退出 0、0 changed |
| `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0，6/6 通过 |
| `git diff --check --` 两文件 | 1 次 | 退出 0；仅有 Git 的 LF/CRLF 提示，无差异空白错误 |

未运行全套测试、模拟器/设备、网络、后端或真实数据检查。旧任务预算不重置；交付后停 Work 独立 LEVEL 2 审查。
