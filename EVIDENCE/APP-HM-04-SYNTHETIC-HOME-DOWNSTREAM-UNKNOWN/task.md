# APP-HM-04｜Synthetic Home 下游状态未建立时不冒充负向结论

状态：`ISSUED`；风险 `LEVEL 2`（Connection/Conversation 展示状态语义，仅本地 synthetic/dev）；派发 Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。交付后停 Work 独立 LEVEL 2 审查。

## 固定入口与候选行为

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，保留既有 dirty/untracked。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能和 APP-HM-03 `work-review.md`。当前执行会话 29 个实际 turn，低于 30 条交接阈值；不得自行派发后继。

在显式 synthetic Home flag 下，准备状态 ready、Match 已取得且可用时：

1. Connection presentation 没有 synthetic development 状态（`notYetEstablished`）时，Home 当前会说“连接尚未激活”，但该状态未建立。保留 Connection summary 的 `notYetEstablished`，不发布由该缺口推导的 synthetic `authoritativeNextDecision`，沿用既有“查看进展”安全导航回退。
2. Connection 已知为 synthetic `CN_ACTIVE`，但 Conversation access 没有 synthetic development 状态（`notYetEstablished`）时，Home 当前会说“消息同意尚未完成”，同样不能由未建立状态推断。保留 Conversation summary 的 `notYetEstablished`，不发布由该缺口推导的 synthetic 下一决定，沿用“查看进展”回退。

已知 synthetic `CN_NONE`/`CV_LOCKED` 的旧演示主循环、APP-HM-01～03 的 unknown 边界、非演示分支均保持。不得把路由、Match、Connection 或本地 mock 当成真实同意/权限，不新建后端来源、状态 writer、API 或产品规则。

## Codex 允许路径与基线

只允许修改下列两文件，另新增本目录 `summary.md`：

- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`，输入 SHA-256 `0218B56F900C4A9BB34C7AF7E592EC65FFC10A2B4F8318FC7FF09F50C2A812F3`；
- `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart`，输入 SHA-256 `EECFF7B123DC8F794555D7AAD98E1D9AB5C835E90159D4200F3BE83D0C823778`。

新增两条独立人工负例，分别核对 Connection 未建立、Conversation 未建立时的 summary、无已判定下一决定与安全导航文案；保留原六个定向测试，尤其 known `CN_NONE` 和 `CV_LOCKED` 的 ready 主循环。测试只构造本地虚构 provider 状态，不调用网络、真实账号或后端。

## 新一次性验证预算与停点

执行前只读核对两文件哈希、`.dart_tool/package_config.json` 及 `dart`/`flutter` 命令；不运行 `pub get` 或下载。修改后两文件各最多一次 `dart format` 写入、各最多一次只读 `dart format --output=none --set-exit-if-changed`，退出 0 才可报格式 PASS。定向 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑一次；仅可归因于本次编辑缺陷的失败可修后额外复跑一次。对两文件运行 `git diff --check`。不运行完整套件、模拟器、设备、后端、网络或真实数据。

`summary.md` 记录前后哈希、两个未建立状态与已知状态区别、所有检查退出码/用例数、未证实的真实权威及回退范围。回退只撤销本任务两文件新增差异及摘要，保留 APP-HM-01～03 和无关状态。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。旧预算不重置。
