# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-65-DEPLOYED-DB-OBJECT-INVENTORY-READONLY`

Risk Level: `LEVEL 2`（一次部署目录真实 DB 元数据只读观察；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付固定探针的单次严格 SSH 脱敏事实回执及本机解析测试，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-64 本机固定只读元数据探针获 Work LEVEL 2 接受，探针原文件 SHA-256 为 `ED8CB1CC5B3D3C4795595BE3F7E4B3B93589DBE7AAB4D66CDAB1323BB674FD4F`；它尚未运行真实数据库。AUTH-20 当次 CLI 连接报告目标指纹 `c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29` 和 43 个 `information_schema.tables` 条目。本任务只观察一次当前部署目录 CLI 连接下可见的对象计数，比较同算法目标指纹；不宣称权限完整、Web worker 同库或备份可行。AUTH-20/64 的预算不可重用，本任务有独立 SSH **1/1** 预算。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-19/20/49/64 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-65-DEPLOYED-DB-OBJECT-INVENTORY-READONLY/run.py`、`test_run.py`、`summary.md`。不得改 AUTH-64 探针、历史证据、产品源码或控制文件。运行前从工作区原始字节复核上述精确 SHA；失败即停，不连接服务器。私钥 `C:\Users\zcxve\.ssh\CodexKey.pem` 与既有 `known_hosts` 仅核对存在，不读取、显示或复制内容。
- 先静态检查唯一 SSH 调用、固定远端命令、stdin 原始探针字节、标准流上限、超时与严格输出解析。纯虚构解析测试最多 2 次，不启动 SSH、Laravel 或真实 DB；覆盖正确白名单、重复/额外键、尾随字节、畸形 UTF-8、错误类型/指纹形状、超限及异常脱敏。失败即停，不执行现场读取。
- 仅向既有 `root@101.133.161.203` 发起 **1 次** SSH，私钥只用上述指定文件，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`、`-T` 禁用 PTY；不得重试、换身份/入口或降低校验。远端唯一命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`，stdin 仅送入已锁定探针的原始文件字节，不在远端保存文件。外部等待最多 35 秒，stdout/stderr 各上限 16 KiB；超时/超限/SSH 非零/意外 stderr 立即停止。**连接问题须及时在本会话反馈 Owner**，不得自行再次连接。
- stdout 只在本机有上限内存接收，严格解析单行 UTF-8 JSON，拒绝重复键、额外键、错误类型、超限计数及尾随内容；不显示或保存原始 stdout/stderr。若探针报告安全错误类别、指纹与 AUTH-20 不同、版本不合预期或基表+视图与 AUTH-20 的 43 条当次值不同，记录差异及 `UNKNOWN`，不追加探测或改写历史。全部字段通过才报告本次可见计数；始终保留 `completeness=UNKNOWN`。
- 仅保存脱敏阶段状态、SSH/解析结果、各类固定整数计数（若全部通过）、目标指纹比较、首个失败和未解决范围。不得记录原始对象名、主机名、库名、凭据、SQL 输出、异常、业务行或错误流。 `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

不得访问旧 `D:\EliteSync`、CloudShell、云 API、Docker、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体；不得读取业务表行、执行 HTTP/API、备份、导出、恢复、删除、DDL/DML 或部署。SSH 失败、超时、解析失败或目标不符立即停；1/1 预算用完不得重试。Codex 不提交、制作 bundle、推送、自接受或派发后继。即使本次计数通过，也不证明全库完整、写入一致性、Web worker 同库、完整备份体量或可恢复性；停在 Work LEVEL 2 独立审查门。
