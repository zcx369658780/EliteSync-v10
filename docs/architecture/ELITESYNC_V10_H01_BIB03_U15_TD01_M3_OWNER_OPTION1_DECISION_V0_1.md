# EliteSync v10｜M3 Owner 选项1决策记录 v0.1

Decision: `OWNER APPROVED — OPTION 1: ZERO-EXTERNAL-NETWORK ISOLATED EVIDENCE SCOPE`

日期：2026-09-07（Asia/Singapore）。

Owner 在 ChatGPT 验收 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md` 后明确选择报告 §4 的选项1。

批准的下一步范围：

- 对具名 Flutter / Java / Android SDK / pub / Gradle 输入进行有限、定点、只读绑定；
- 用当前 `D:\EliteSync-v10` 本地 HEAD 的已提交 Git 对象形成不可变 Flutter module 来源快照，不读取/复制 dirty、untracked、staged 工作区内容；
- 专用宿主根：`D:\EliteSync-M3-readiness-v02`，仅不存在时创建；存在未知内容则停止，不覆盖；
- 准备 Windows Sandbox 或等价已批准 OS 隔离；隔离客体外部网络授权为零；
- 不写原 `D:\EliteSync-v10`，不映射旧仓库或用户主目录为可写位置；
- 可把具名已有工具/缓存作为只读输入 seed，复制到隔离客体内部专用可写位置；不输出 seed 内容，不自动安装/下载；
- 完整命令、输入 manifest、工具路径、隔离控制、attempt ID 与 output locator 全部闭合后，可在同一后续任务执行一次顶层 M3；30 分钟上限，无自动重试；
- attempt 后仅执行一次与该新 attempt 绑定的定点产物存在性检查；不复用历史 M1 lane；
- 任一前置条件未闭合则停止依赖步骤并报告，不自动扩大权限。

该批准不产生 M2 成功、产品实现、Backend/Database 设计、LC-03/04、Phase36、真实用户/数据或旧 v9 代码继承权限。

`OWNER OPTION 1 APPROVAL != M3 SUCCESS`

`ISOLATED M3 ATTEMPT != M2 SUCCESS`

`OLD V9 FUNCTIONAL FACT != V10 IMPLEMENTATION AUTHORITY`
