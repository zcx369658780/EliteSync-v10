# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-98-USB-KEY-SYNTHETIC-RECOVERY-DRILL-DESIGN`

Risk Level: `LEVEL 3`（真实加密私钥恢复副本的后继演练设计；本轮仅文档）

Status: `ISSUED — DOCS-ONLY CANDIDATE; NO KEY USE OR UAC`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 3 审查、验收及后继任务发布。

## Objective and allowed path

在 `EVIDENCE/AUTH-98-USB-KEY-SYNTHETIC-RECOVERY-DRILL-DESIGN/plan.md` 写一份可审查的最小失去本机私钥时 U 盘恢复能力演练方案。此轮只写该文档，不创建/运行脚本，不触发 UAC，不请求 Owner 输入密码或恢复密钥，不修改源私钥、E: 或其他文件，不做真实数据库备份/解密/恢复。允许只读查看 AUTH-69/88～92/95～97 的既有回执、现有固定路径和本机工具命令帮助；不得读取私钥正文、计算或输出私钥哈希，不枚举 U 盘目录。

## Required plan boundaries

1. 明确区分三项目标：A. E: 上已加密 PEM 私钥副本能在本机以 Owner 现有私钥密码解锁并对**固定虚构内容**完成 CMS 往返；B. U 盘拔出重插、锁定后 Owner 本人密码解锁的可重复性；C. 纸质 BitLocker 恢复密钥在忘记密码时的恢复能力。A/B/C 不得互相代证；本任务仅设计优先演练 A 的后继可执行任务，B/C 只能列为独立后续门，不得要求本轮实际操作。
2. A 的设计须强制 OpenSSL 解密输入为精确 `E:\elitesync-v10-db-backup-recipient-20260925.key.pem`，并在执行时确保不可能隐式回退到 C: 源私钥；证书采用已经接受的公有证书或 E: 上字节相等的副本。仅固定虚构标记，无真实 DB/用户数据。密码仅由 Owner 在 OpenSSL 本机非回显提示输入，不写到聊天、脚本参数、环境变量、日志或证据。定义临时文件位置、失败保留/清理规则、单次预算、有限输出和 Work 事后可独立核对的证据。
3. 审查现有 AUTH-92 的虚构 CMS 演练边界并提出适合 A 的最小可执行步骤、负向停点及剩余风险。指出 A 成功仍不证明真正删除/丢失本机源、纸质密码准确、BitLocker 恢复密钥有效或真实备份恢复。不得把 AUTH-97 的副本字节相等直接写成 A/B/C 已完成。
4. 核对 `main`、HEAD、工作区、AUTH-97 LEVEL 3 ACCEPT 与旧 1/1 预算，保留两个无关未跟踪目录。只交付 plan 候选及文档静态检查；不提交、推送、自接受或派发后继，停在 Work 独立审查门。

禁止连接服务器、DB、云、Docker 或 GitHub，访问旧 `D:\EliteSync`，读取 U 盘其他文件，复制/删除/解密真实私钥或备份，将密钥、密码或敏感哈希纳入 Git、Git bundle 或普通证据。
