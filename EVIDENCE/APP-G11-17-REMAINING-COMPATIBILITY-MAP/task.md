# APP-G11-17｜G-11 剩余兼容债的当前代码复核

状态：`ISSUED`；风险 `LEVEL 2`（身份/通知兼容，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` 的 G-11、APP-G11-04 的接受映射及 APP-G11-05～16 的 `work-review.md`。唯一允许新增本目录 `plan.md`；不改源码、测试或 authority 文档。

最多两轮本地静态核对：第一轮恢复 G-11 原始欠账与 APP-G11-01～16 已接受/拒绝的精确覆盖；第二轮仅核对尚未闭合的通知名称、Chat 直达/列表/详情身份、Laravel 输出与 Flutter 消费及其它直接相关消费者的当前代码/定向测试。用当前文件正文而非旧计划宣称现状；图谱可定位但结论须定点读源。列出已局部修复项、仍有当前代码证据的可安全本地修复项、需要真实权威或 Owner 决策的项。只推荐**一张**无需真实数据、独立预算且不重做 APP-G11-01～16 的下一软件切片；若没有，明确 `NO_SAFE_LOCAL_SLICE_FOUND` 及原因。不把人工测试当作真实兼容或权限证明。

## 新一次性预算与停点

两轮只读静态预算 2/2，不运行测试、构建、设备、网络、DB、备份、SSH、云/生产 API。`plan.md` 记录每轮来源与范围、目标文件 SHA-256、证据分层、未证项和唯一后继建议。不得访问旧 `D:\EliteSync`、真实数据/密钥；不得提交、pull、push、自接受或启动后继。旧任务预算不重置；live 404、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
