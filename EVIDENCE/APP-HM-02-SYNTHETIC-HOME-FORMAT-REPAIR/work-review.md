# APP-HM-02 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受 Flutter synthetic Home 未知准备状态修正及格式收口。** APP-HM-01 的历史 REJECT 和一次性预算保持原样；本次新任务只对其保留候选做格式写入与定向回归。

Work 独立核对源码差异与作者摘要 `3564D051AC4DB7F87A7808919C733E2A9650AEB1EB59CDC49CE85506AD62C672`。两份最终文件 SHA-256 与摘要一致：provider `D752B012D88178B16941E7446D56A6812DF141FA238F6AE4550C36504E7C457D`，定向测试 `9153BB0A13FEDB3A59460D57895149A14D4B8C47599A49847BB99D8B44D117CC`。APP-HM-02 相对 APP-HM-01 候选只作 formatter 排版；组合差异在显式 synthetic flag 下将 `ReadinessGuardState.unknown` 保留为 unknown、不给已判定的 synthetic 下一决定，调用现有安全导航回退。`setupRequired` 的旧提示、ready 演示主循环及非演示分支保持。

作者新预算两文件各一次 formatter 写入退出 0，写入后各一次只读格式复核均退出 0；`flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 首跑退出 0、4/4 tests passed；两文件 `git diff --check` 退出 0。Work 未复跑测试或重用旧预算。此证据只覆盖本地人工演示与指定用例，不证明真实 Home 活态来源、设备构建、真实账号/权限或生产运行。APP-T12 G-08 仍保留；AUTH-170 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、CMS 认证/隔离恢复及账号回填仍 `NOT_READY`。

本地 `main` HEAD 未移动，既有工作区保留；本次无提交、pull、push、真实数据或恢复动作。后续工作需另立有界任务。
