# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-71-LOCAL-BOUNDED-CMS-CAPACITY-FAILURE-DRILL`

Risk Level: `LEVEL 2`（真实备份前的本机虚构容量和认证失败隔离演练；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付本机确定性虚构 CMS 容量/失败消费者门候选、targeted 测试和脱敏回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-61 只证明 21 字节虚构样本的服务器到本机正向互通；AUTH-63 只证明新生成 21 字节本机虚构密文的身份门与负向 0 字节消费者。AUTH-49 要求认证与密文身份通过前不得释放解密输出，真实备份超过内存上限时另需等价隔离设计。AUTH-68/69 的真实范围、密钥和恢复门仍未关闭。本任务仅在本机以固定 **1 MiB** 虚构明文验证有上限内存隔离的正常与失败路径，不宣称真实 dump 大小或生产可用。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-49/61/63/68 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`；不移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-71-LOCAL-BOUNDED-CMS-CAPACITY-FAILURE-DRILL/run.py`、`test_run.py`、`summary.md`。不改 AUTH-63 等历史证据、产品源码或控制文件。固定 1,048,576 字节虚构明文由程序内确定性非业务模式生成；预定长度和摘要在代码/测试中固定，不读取本机其他文件作为明文。明文、密文、解密暂存只在有上限进程内存，不写磁盘、日志或普通回执。
- 只在 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth71-bounded-cms-drill` 生成本次一次性**无密码虚构**证书/私钥及错钥；创建前核对规范化绝对路径、非重解析父目录和目标原先不存在，结束时仅清理本次精确目录并确认不存在。私钥绝不进入 SSH、真实备份/密钥目录或 U 盘。
- 固定本机 OpenSSL CMS AES-256-GCM 正向加密，记录本次内存密文长度和 SHA-256；消费者门须从**实际送解密的密文字节**重新核对身份，且只在解密退出 0、捕获完整、输出恰为 1 MiB、预定明文摘要匹配后向唯一内存消费者交付一次精确字节数。失败路径消费者 0 次/0 字节并清零隔离缓冲；不得由调用方直接传固定身份布尔值。stdout/stderr 各设明确上限，超限/超时/异常先阻止消费者。
- 纯虚构 targeted 测试最多 2 次，不运行 OpenSSL；至少覆盖正常门、篡改密文但伪造退出 0 与正确明文仍拒绝、非零退出但有暂存字节、截断、超限/超时捕获失败。完整本机运行独立预算最多 **1/1 次**：固定正常路径后按依赖门覆盖实际本机密文篡改、截断、错钥，以及明确标注的受控超限和中断模拟；失败即停，不重跑、放宽门或修改历史事实。任何适用负向路径 0/0、缓冲清零及精确清理 PASS 才可候选完整 PASS。
- 回执只保存阶段状态、脱敏长度/摘要、退出码、消费者调用/字节、缓冲清零、首个失败及清理；不得保存原始证书、私钥、明文、密文、stdout/stderr。先静态检查唯一消费者调用点、身份比较、上限和精确清理。 `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得真实备份、传输、恢复、删除或改库。Codex 不提交、制作 bundle、推送、自接受或派发后继。1 MiB 虚构 PASS 不证明真实体量、真实密码保护密钥、服务器端加密流、完整备份或隔离恢复；停在 Work LEVEL 2 独立审查门。
