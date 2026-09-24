# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-22-ALIYUN-BACKUP-READINESS-DECISION-PACKET`

Risk Level: `LEVEL 2`（真实 DB 备份前置边界与敏感数据；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付 docs-only 候选，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-18 已接受的是备份/隔离恢复的后继任务链；AUTH-17/20 分别仅证明当次主机工具空间和部署目录 CLI 聚合元数据，不能证明实际备份或恢复可行。Owner 新决定：未来完整数据库备份仅在阿里云内加密保留 **30 天**；未来若修改后端数据库结构，须先有完整备份与可恢复性校验。AUTH-21 本地虚构登录事件预检已接受，不是部署 migration。本任务根据已接受本地证据给出**下一次真实备份动作之前的最小决策与核验清单**，供 Work/Owner 选择，不执行任何远端或 DB 操作。

## Allowed candidate and content

唯一允许新增 `EVIDENCE/AUTH-22-ALIYUN-BACKUP-READINESS-DECISION-PACKET/packet.md`。先核对 `D:\EliteSync-v10` 的 `main`、HEAD、工作区及本任务 `ISSUED`，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能和 AUTH-10/14/16/17/18/19/20/21 接受回执。不要读取 `.env`、实际配置、私钥或数据库内容。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

文档应区分已决定的“阿里云内加密、30 天保留”与仍待 Owner 明确的精确存放位置及访问边界、加密与密钥托管/轮换、备份一致性、隔离恢复目标与网络边界、到期清理执行者和失败处置。给出简短推荐选项和理由，但不得把建议写成 Owner 决定。列出在制定真实备份命令前仍需受限只读核验的目标身份、CLI/Web worker 同库、数据库与工具兼容、数据分类、估算空间余量；AUTH-20 指纹只能作为同法比较线索，不能替代实例证明。说明完整备份与可选管理员创建测试账号本地导出是不同授权；无创建来源证明不能导出。明确各个后续任务的独立停点：只读核验、备份写文件、文件完整性/可解密校验、隔离恢复验证、migration 审批及 30 天清理。不要列可直接运行的远端命令、真实路径、凭据或敏感值。

## Verification and stop

只需对新文档作只读尾随空白检查；`git diff --check` 最多 **1 次**，其结果不覆盖未跟踪新文件。不运行代码测试或构建。不得 SSH、HTTP/API、设备、远端 DB、备份、导出、恢复、migration、部署或 GitHub pull/push；不得改既有源码、证据或控制文件。作者不提交、自接受、备份或派发后继。Work 独立核对候选与来源后作 LEVEL 2 ACCEPT/REJECT；即使接受也不授权真实备份。
