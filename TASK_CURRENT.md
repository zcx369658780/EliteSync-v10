# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-62-LOCAL-SYNTHETIC-CMS-FAILURE-CONSUMER-MATRIX`

Risk Level: `LEVEL 2`（认证失败明文消费者隔离与负向矩阵；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付本机虚构 CMS 消费者门脚本、虚构测试与一次运行回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-61 已获 Work LEVEL 2 ACCEPT：固定 21 字节虚构样本的服务器 CMS AES-256-GCM 加密、本机隔离解密正向互通成功；旧 SSH 1/1 预算已耗尽。AUTH-48 曾观察到认证失败仍可能输出明文，AUTH-49 合同要求消费者在退出 0、认证和固定内容核对之前接收 0 字节，AUTH-50 只验证正常/单字节篡改的小样本。此任务用**本机新生成的虚构 CMS** 完成正常、篡改、截断、错误私钥、超限与中断/超时负向矩阵，验证消费者门；不连接服务器，不做真实备份或恢复。无需 Owner 密码或 U 盘。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-48/49/50/57/61 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD 和工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-62-LOCAL-SYNTHETIC-CMS-FAILURE-CONSUMER-MATRIX/run.py`、`test_run.py`、`summary.md`。不得修改产品源码、旧证据或控制文件。先静态检查固定命令、缓冲上限、消费者唯一调用点、错误/异常清零、临时路径与清理。
- 固定虚构输入为 ASCII `AUTH57-SYNTHETIC-001\n`（21 字节）。仅在 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth62-cms-failure-matrix` 生成本次一次性无密码虚构证书/私钥及错误私钥；先核对规范化绝对路径、非重解析父目录、目标原先不存在，结束时只清理本次精确目录并确认不存在。证书/私钥外不得在该目录或其他磁盘写入明文、密文或解密输出；OpenSSL stdout/stderr 只进入有上限本机内存。
- 本地一次完整运行最多 **1/1 次**：先生成配对虚构 CMS AES-256-GCM 密文并固定长度/摘要，再按顺序各至多一次覆盖正常、单字节篡改、截断、错误私钥、超限、受控中断/超时。正常解密进程退出 0、密文身份及固定 21 字节内容/摘要均通过后，内存消费者仅调用 1 次且精确接收 21 字节。每个负向路径即使 OpenSSL 暂存了明文字节，消费者必须 **0 次/0 字节**，缓冲须清零；异常、非零退出、超时、超限或未匹配均 fail-closed。超限和中断可以采用明确标注的本地受控模拟，不得将模拟宣称为 OpenSSL 真实大规模或系统中断行为。
- 纯虚构 targeted 测试最多 2 次，须覆盖消费者门的放行与拒绝，不运行 OpenSSL/服务器。执行回执对每一矩阵项保存进程退出码或 `NOT_APPLICABLE`、是否观察暂存字节、消费者次数/字节数、清零结果、首个失败与清理状态；不得保存原始证书、私钥、明文、密文、stdout/stderr。完整矩阵目标只有所有适用负向路径 0 次/0 字节且清理 PASS 才可候选 PASS。
- `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。不得连接 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`。

## Stop and review

本机虚构矩阵即使 PASS，也不证明 AUTH-61 的历史密文经过这些负向处理、真实数据规模或真实恢复目标隔离；完整数据库身份/范围、一致性、密钥保管、传输与恢复仍未建立。Codex 不提交、制作 bundle、推送、自接受或派发后继；停在 Work LEVEL 2 独立审查门。
