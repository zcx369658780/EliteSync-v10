# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-61-SERVER-TO-LOCAL-SYNTHETIC-CMS-GCM-POSITIVE`

Risk Level: `LEVEL 2`（真实服务器虚构 CMS 加密与本机正向解密互通；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次有界虚构正向互通候选和脱敏回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-56 只证明当次服务器算法列表列出 AES-256-GCM；AUTH-60 只证明当次服务器 OpenSSL 可从 fd 3 读取公有虚构证书。CMS 实际加密及本机解密互通仍未建立。AUTH-57 方法要求服务器不落盘、使用固定虚构输入，解密输出在认证成功前隔离。Owner 已授权沿路线图继续；本任务只验证**一次正向虚构样本**，不涉及真实密钥、数据库、备份或恢复。AUTH-60 的 1/1 SSH 预算已耗尽，本任务有独立新预算。U 盘与 Owner 密码不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-48/49/50/56/57/60 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-61-SERVER-TO-LOCAL-SYNTHETIC-CMS-GCM-POSITIVE/run.py`、`test_run.py`、`summary.md`。先静态核对固定命令、标准流/分帧、限量捕获、认证隔离、路径与清理。纯虚构本地 targeted 测试最多 2 次，测试不得连接 SSH 或生成证书。
- 固定虚构明文为 ASCII `AUTH57-SYNTHETIC-001\n`，精确 21 字节。仅在固定 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth61-synthetic-cms-positive` 创建一次性无密码**虚构**证书/私钥；预先验证规范化绝对路径、非重解析父目录和目标原先不存在。仅公有证书字节进入 SSH stdin，私钥始终留本机临时目录。结束时只清理本次精确目录并核对不存在，不把证书、私钥或密文保存到普通证据、真实备份/密钥目录或 U 盘。
- 向既有 `root@101.133.161.203` 只允许 **1 次** SSH 连接，私钥仅 `C:\Users\zcxve\.ssh\CodexKey.pem`，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`；不重试、换入口或降低校验。SSH 连接失败/超时立即停止并在本会话向 Owner 反馈。
- 远端固定 shell 只保留 SSH stdin 为 fd 3，将固定 21 字节虚构明文经进程管道送一次 `openssl cms -encrypt -binary -aes-256-gcm`，收件人公有证书只从 `/dev/fd/3` 读取，输出选择经本地静态预检固定的 ASCII PEM CMS 格式或等价有界 ASCII 封装；远端不创建文件、不读取真实业务文件或 DB、不运行密钥生成、解密、Laravel、服务重启或云 API。标准错误流只在本机有上限内存采集并丢弃，远端 stdout 仅包含唯一严格分帧的 CMS 字段长度、命令退出码与密文 ASCII；不保存或显示原始密文/错误。
- 本机完整读取 SSH 进程后严格核对 SSH 退出 0、远端 CMS 退出 0、唯一帧、长度上限、ASCII/PEM 格式与无额外字节；任何超时/截断/混帧/超限/非零/格式异常立即 FAIL，不尝试解密或追加探测。只有完整密文通过门，才用本次本机虚构私钥执行**一次** `openssl cms -decrypt`；stdout 只进有上限、隔离的本机内存缓冲。仅当解密退出 0 且缓冲精确匹配固定 21 字节及预先固定 SHA-256，才记正向互通 PASS；否则清零并 FAIL。不得将解密流直连任何消费者、文件、容器或数据库。本任务不声明认证失败消费者门或负向路径通过。
- `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。回执只保存阶段 `PASS/FAIL/NOT_CHECKED`、必要退出码/长度/摘要、首个失败、连接预算和清理状态；不得保存真实或虚构的原始证书、私钥、明文、密文及 stderr。不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、真实 DB、账号/Token/消息/媒体、U 盘或 Owner 密码。

## Stop and review

即使正向虚构互通 PASS，也不证明单字节篡改、截断、错钥、超限和中断时消费者 0 字节，不证明真实密钥保管、完整备份或恢复能力。真实密码保护私钥、U 盘恢复副本、数据库读取/传输/恢复/改库均需各自任务与风险门。Codex 不提交、制作 bundle、推送、自接受或派发后继；SSH 1/1 耗尽后停在 Work LEVEL 2 独立审查门。
