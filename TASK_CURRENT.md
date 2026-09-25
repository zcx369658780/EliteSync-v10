# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-69-OWNER-KEY-USB-RECOVERY-PREFLIGHT`

Risk Level: `LEVEL 2`（真实备份私钥及加密 U 盘恢复副本实施前合同；真实创建另设 Owner 高风险门）

Status: `ACCEPTED — CLOSED`（Work LEVEL 2；仅 docs-only 密钥与 U 盘恢复副本合同，见 `EVIDENCE/AUTH-69-OWNER-KEY-USB-RECOVERY-PREFLIGHT/plan.md`）

Assignee: `Codex`。只交付一份 docs-only 候选实施前合同，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已决定完整数据库备份加密存到本人电脑，自完成日起保留 30 天；密码保护的真实私钥与密文分离，另在加密 U 盘留恢复副本，密码只由 Owner 本人输入。固定分离目录已建立：`C:\Users\zcxve\EliteSync-v10-DB-Backups` 与 `C:\Users\zcxve\EliteSync-v10-DB-Keys`；Owner 确认备份目录不被云同步/备份覆盖。Owner 表示有 32GB U 盘可用，尚未指定或接入本任务。AUTH-49/68 的合同不证明真实私钥、配对证书、U 盘副本或恢复。此任务准备可由 Owner 最后审查的具体分段操作门，不生成真实材料。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-46/49/60/61/63/68 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 和 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`；不移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-69-OWNER-KEY-USB-RECOVERY-PREFLIGHT/plan.md`。不修改历史证据、控制文件、源码、配置。此为 docs-only：不得实际查看备份/密钥目录内容、枚举 U 盘、运行 OpenSSL、创建密钥、证书或加密卷。
- 写清未来独立任务的顺序和每一步的可核验停点：本机只读核对目录 ACL/同步/空间、准确识别 Owner 提供的 U 盘且不格式化既有数据、确定加密卷及恢复口令/恢复信息由 Owner 亲自保管、在独立密钥目录生成密码保护私钥与公有证书、证明证书/私钥配对与证书指纹、将私钥恢复副本置于加密 U 盘并验证可用性、演练失钥恢复路径、清理临时副本。任何真实创建/写入/解锁/复制及验证均须另立任务、具体授权、预算和风险门；本合同不授权自动执行。
- 密码与加密卷恢复信息仅由 Owner 在本机可信交互界面输入和保管，不进入聊天、命令参数、脚本、环境变量、剪贴板自动化、普通证据、Git、Git bundle、日志或第三方云。说明如何只保存脱敏状态、指纹和失败类别。不可因已创建文件或复制成功就宣称失钥恢复可行；须独立证明实际恢复副本可解锁、私钥可用且与证书配对，同时不暴露密钥。
- 区分虚构无密码证书/私钥和未来真实密码保护材料；说明 AES-256-GCM CMS 仅为已接受的虚构正向兼容线索，真实备份仍须通过 AUTH-49 的密文身份、认证后消费者门和真实隔离恢复。明确加密 U 盘容量 32GB 不代表真实完整备份可装入或已批准存备份密文；U 盘当前只作为私钥恢复副本候选。
- 本轮只做文档检查：`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。回执注明未使用 U 盘、未要求 Owner 输入密码、未触碰真实目录内容。作者不提交、制作 bundle、推送、自接受或派发后继。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得备份、传输、恢复、删除、DDL/DML、部署。停在 Work LEVEL 2 独立审查门。
