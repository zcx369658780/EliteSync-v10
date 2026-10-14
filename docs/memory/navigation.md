---
title: navigation
type: note
permalink: elitesync-v10-local/navigation
---

# EliteSync-v10 记忆导航

## 当前检查点：v10.0.6 正式冻结，等待Owner手动派发

2026-10-14，Codex集中执行方案已接收。Astra依据其报告与GitHub实际源码核查冻结[城市持久化＋独立Web管理员禁用闭环](../versions/v10.0.6/plan.md)。代码起点 `3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`，Tree `59969abfc9d04185769b22af5f7ea5d629007a33`；允许复用当前专用工作树及连续版本提交，不强制新树/单提交。正式计划发布不等于Owner已经派发或本机环境已经运行。

本版复用原APP登录/资料页，独立保存城市到users.city，不触发完整星盘重算；Laravel Blade提供管理员登录/查询/禁用，服务端严格role与名单、共享禁用动作、token/session/refresh失效。真实APP、浏览器、API和持久数据库同账号关联与重启验证是终验目标，不用mock或静态组件替代。

正式派发时一次授权计划中的专用开发环境：现有Docker Desktop、独立MariaDB10.11容器/volume及 `elitesync_v1006_dev`（127.0.0.1:43316）、Laravel/Web本地8000、三个虚构账号、依锁依赖安装/缺失包下载、已有Android36.1镜像的专用AVD、指定ADB reverse、当前源码AAR/debug APK构建安装及浏览器操作。Docker当前管道不可用只是Codex回报的待解决事项，不能冒称成功；普通环境问题同版处理，额外系统级变更只提出具体需要。

原3306 MySQL、历史SQL gzip/VHDX内容、真实账号、生产及费用不纳入本版。备份仅有存在性/大小的元数据回报，表/业务记录/媒体完整性UNKNOWN，不导入、挂载或解密；历史恢复单列但不阻塞虚构数据的真实服务链。

## 最近已知本地现场（CODEX_REPORTED）

专用路径 `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，原分支 `codex/baseline-v1005-be0636e`，HEAD3a78c2c、CLEAN。已完成九份路线文档同步；原 `D:/EliteSync-v10` 启动根八正文一致，AGENTS保留有效本地补充。原dirty HEAD/index未动，同步回执证明对应范围与105项保护，不能无条件延伸成旧109项的永久门。

Astra实际读取GitHub源文件，不直接访问C:/D:原件；环境版本、备份、工作树保护仅按Codex回报登记。新的远端纯文档提交不自动移动本地HEAD。本版源码/环境实施尚未开始，精确状态见[CURRENT_STATE](../../CURRENT_STATE.md)。无需再次安排九文件同步、全树哈希或索引治理。

## Owner现行方向与工作方式

v10.0核心仍为**选定原版APP的前端、后端、数据库和主要功能恢复＋独立可用Web管理面板**。[Owner决定](../../PRODUCT_DECISIONS.md)、[路线图](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[单份恢复台账](../architecture/RESTORATION_CAPABILITY_MATRIX.md)优先于旧不复现9.x、长期synthetic小页面和忽略后台的排程。已实现原版功能不得被旧Later标签静默排除，未实现设想后置；历史源码按需复用，不全量考古或覆写原件。

Astra规划/独立终验，Codex冻结模块内自主实现，Owner手动派发和关键取舍；旧Work不恢复。未来阶段仍为主要APP功能、后台模块、跨端联合验证、完整软件/算法说明，不提前启动。内测半年至一年为Owner运营窗口，不由开发版本数推出公开日期。

[CURRENT_WORKFLOW](../workflow/CURRENT_WORKFLOW.md)是现行流程；knowledge.md旧K08～K12及历史停止预算只按原时点解释。版后安全集成/本地接续保持，但无需每轮新工作树或重复历史审查。原V57/H1/H2/D0不复活、BE-12消息代码本版不改，授权开发运行不等于生产许可。

## 最少读取与检索回退

[动态目录](../../DOC_INDEX_CURRENT.md) → 当前状态 → 本版正式计划和所需台账；旧算法/环境才按需读[knowledge.md](knowledge.md)、[environment.md](environment.md)、[归档说明](archive-20261012.md)。不重建session/图谱库。

既有本地检索路由仅是历史已配置事实，不表示本轮复测覆盖：
- Basic Memory使用 `--project elitesync-v10-local --local`，进程配置 `BASIC_MEMORY_CONFIG_DIR=D:/EliteSync-v10/.local-memory-state/basic-memory`、`BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false`，只覆盖部分历史，不改共享default或下载模型。
- QMD的named index/collection均为elitesync-v10-memory，显式指定；原docs/memory索引不假定自动跟随新树，不为本版重建。
- 图谱D-EliteSync-v10若未命中，直接读取指定实际源码；未命中不证明不存在。不涉及HANK/Zotero等其他项目。

[冻结前记忆导航](https://github.com/zcx369658780/EliteSync-v10/blob/98649e89e223b92c5e7817b8f0f0361242c6c476/docs/memory/navigation.md)保留此前身份与同步信息。历史接受/拒绝/原始失败不重写；旧SOURCEONLY不提升为真实APP/数据库恢复。
