# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-49-AUTHENTICATED-LOCAL-BACKUP-RESTORE-CONTRACT`

Risk Level: `LEVEL 2`（真实数据备份前的加密、认证解密与隔离恢复安全合同；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付 docs-only 合同候选，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已指定 C 盘专用空目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，实际需要密码时由 Owner 本人输入。AUTH-45 仅证明三行虚构样本跨容器内存恢复；AUTH-46 仅证明目录/ACL/空间的受限事实；AUTH-47 的证书生成失败；AUTH-48 显式配置后证书、CMS AES-256-GCM 正常加解密通过，但篡改解密退出 4 时仍留下与固定输入相同的输出。此任务只写一份可审查的**真实备份前合同**，明确密文、私钥、可信来源、认证失败输出隔离及逐项停点，不能把虚构结果升格为真实可恢复证明。

## Exact documentation scope

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-20、AUTH-25、AUTH-45～48 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD、工作区。当前 HEAD 应为仅下达本任务的检查点，父提交精确为 `aeca4caa7dd5af7357a933c55b09998c26f67e94`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。
- 合同必须分开：①真实阿里云 DB 的实例/CLI 与 Web worker 同库、完整数据范围、表类型/一致性、真实 dump 体量的**只读核验**；②服务器侧 OpenSSL/CMS GCM 兼容与公共证书来源核验；③Owner 本机密码保护的私钥生成及失钥恢复安排；④服务器在网络传输前加密完整 dump、SSH 认证传输、仅在 C 盘批准目录落密文；⑤密文长度、格式/完整性、完成时点及 30 天保留/清理责任；⑥本机隔离恢复及副本清理。每项标记已有证据、UNKNOWN、未来任务与失败停点，不以历史估算替代实测。
- **认证解密硬门**：不得将 `openssl cms -decrypt` 的 stdout 或 `-out` 文件直接接到数据库、持久盘或任何可消费目标。AUTH-48 已报告认证失败仍产生原文相同的输出。未来恢复须将明文限制在有上限的宿主进程内存或等价隔离暂存；严格等到解密进程退出 0、认证成功且密文固定身份/长度与内容校验通过后，才可送往独立隔离容器。任何非零/超时/超限立即丢弃暂存且目标容器不得消费；若无法证明上限及失败清除，保持停点。不声称 OpenSSL 会自行抑制失败时的明文输出。
- 合同必须写明备份目录不得放私钥、明文、临时 dump、日志或普通证据；真实私钥必须加密，密码只由 Owner 交互输入，不在聊天、命令参数、脚本、环境变量、Git、Git bundle 或证据中出现。私钥另处存放及丢失时恢复路径仍需 Owner 最终确认，不得自行创建真实私钥或选择不可恢复安排。
- 明确目前 OneDrive/其他自动同步边界、BitLocker 状态、服务器端 CMS 兼容、真实 DB 身份与完整范围均未通过；它们分别需要后续有界只读任务。若有未知导致内容可能上传至阿里云以外的地方，真实备份不得开始。完整数据库备份、管理员测试账号可证明子集导出、虚构恢复是不同对象，不互相授权。
- 给出最短有界后继顺序：本机同步边界及服务器/DB 只读核验 → 密码/私钥及恢复安排由 Owner 确认 → 独立虚构端到端加密与失败暂存演练 → 真实加密备份单次任务 → 密文和密码解密校验 → 本机隔离真实恢复与脱敏核对 → 获批后才可能真实改库；不得在本任务直接生成操作命令执行真实动作。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-49-AUTHENTICATED-LOCAL-BACKUP-RESTORE-CONTRACT/contract.md`；不得修改控制文件、源码或此前证据。只读读取指定文档与 `git` 状态，不访问浏览器、SSH、云 API、真实 DB、真实备份目录内容、密码/密钥、账号/Token/消息/媒体或业务数据。`git diff --check` 最多 1 次，新文档另做只读尾随空白检查。Codex 不提交、制作 bundle、推送、自接受或派发后继。无脚本运行、真实备份、解密、恢复、删除、改库或发布。
