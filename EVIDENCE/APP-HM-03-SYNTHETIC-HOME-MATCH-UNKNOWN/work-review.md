# APP-HM-03 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定本地 synthetic Home 在 Match 加载/失败时的展示语义。** Work 独立核对两处允许文件差异、作者摘要 SHA-256 `AE3F99EFA4BDABD1C934AF07AF7AA68AFF20AC3B0AC08F4B8FCD025017CB3EFC` 及最终文件哈希：provider `0218B56F900C4A9BB34C7AF7E592EC65FFC10A2B4F8318FC7FF09F50C2A812F3`，定向测试 `EECFF7B123DC8F794555D7AAD98E1D9AB5C835E90159D4200F3BE83D0C823778`。

差异只在显式 synthetic flag 且准备状态 ready、Match 投影未取得时清空 `authoritativeNextDecision`；Match summary 继续 unknown，既有 `nextDecision` 回退为“查看进展”，不再把加载/失败解释成无提案。新增 `AsyncLoading` 与人工 `AsyncError` 两例；已取得 Match 状态、APP-HM-02 的 readiness 边界、非演示分支和 ready 主循环保留。

作者两文件各一次格式写入退出 0、后续各一次格式复核退出 0；定向 Flutter 测试首跑退出 0、6/6 tests passed；两文件 `git diff --check` 退出 0。Work 未复跑测试或重用一次性预算。此接受仅证明指定本地人工状态行为，不建立 APP-T12 G-08 的真实 Home/Match 活态来源、设备运行或生产权限。AUTH-170 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、真实 CMS 认证/隔离恢复及账号回填仍 `NOT_READY`。

本地 `main` HEAD 未移动；既有工作区保留，无提交、pull、push、真实数据或恢复动作。后继须另立任务。
