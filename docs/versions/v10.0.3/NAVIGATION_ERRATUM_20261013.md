# v10.0.3 冻结计划的导航勘误（仅一个相对链接）

2026-10-13。正式冻结计划仍为 GitHub commit `1ed7880a5843d2f1fe31b9d1ba254bf2792cc244` 下 `docs/versions/v10.0.3/plan.md`，Git blob `4472647408af1f972e365ac66cd8c42d127fff34`，**本文不改其原字节，不追改代码父提交、A/B/C 工作包、AC-01～AC-07、权限边界或 Owner 手动派发门**。

计划第1节 `[APP-INT-05 旧接受](../../../../EVIDENCE/APP-INT-05/summary.md)` 的相对路径上溯多一级。实际可用原文为：

- [APP-INT-05 原接受记录](../../../EVIDENCE/APP-INT-05/summary.md)，即仓库根相对路径 `EVIDENCE/APP-INT-05/summary.md`；在冻结的代码父提交 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae` 中已实际存在，Git blob `d488e1aee6080420d3694d80fe7aaea088c6ce73`。
- 其 verdict `ACCEPT — synthetic Home live-state main loop only`，不等于真实 Router 动态 Guard 已通过；依原证据范围沿用，不重新打开 APP-INT-05。

这只是阅读入口勘误，Codex 在执行前需实际读取固定 Git 对象以核实。**不需要新文件占位、不构成新的评审任务或工程修改授权。**