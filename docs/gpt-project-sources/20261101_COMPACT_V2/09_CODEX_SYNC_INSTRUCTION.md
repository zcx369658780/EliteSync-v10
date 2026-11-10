# 给Codex的Project Sources同步指令｜按Owner单独派发执行

本文件只是可复用操作说明。**只有Owner另行手动派发明确的文档同步任务时才执行；本文件本身不构成授权。** 不授权产品代码、运行库、构建、Gradle、ADB、设备、系统策略、供应商或费用操作。

1. Fresh读取live `main`、`AGENTS.md`、`ACTIVE_STATE.md`最新CURRENT ENTRY、最新handoff及本次同步任务引用的规则。
2. 核对Owner提供的完整ZIP、SHA256 manifest、UTF-8正文和唯一文件清单；不得把旧包与新包叠加。
3. 在GitHub新增日期化完整快照目录；保留旧快照、原文件、Git对象、分支、备份和LOCAL_ONLY原证，不删除或覆盖历史。
4. 更新必要导航指针；不复制完整`ACTIVE_STATE`、`TASK_CURRENT`、`CURRENT`或全量日志。
5. 提交简短同步报告：ZIP/manifest身份、文件清单与SHA256、GitHub commit/tree/blob、逐文件readback、未完成项。不得声称已自动替换ChatGPT Project附件或模型Memory。
6. 完成后STOP，等待Astra独立核验。Owner手动替换Project Sources附件；GitHub、Project附件和账户Memory分别记账。
