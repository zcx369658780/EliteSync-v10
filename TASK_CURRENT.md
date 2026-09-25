# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY`

Risk Level: `LEVEL 2`（一次部署目录 DB 引擎元数据只读观察；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付固定探针的单次严格 SSH 脱敏事实回执与本机解析测试，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-66 本机固定引擎聚合探针获 Work LEVEL 2 接受，工作区原文件 SHA-256 为 `5E0BCB9C4AE7EA2A90A23E12759BFE7804C090B5BA0E0B7E9B96D5844DA2DB9D`，尚未运行现场。AUTH-65 当次 CLI 连接可见 43 张基表、0 视图，目标指纹为 `c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29`；权限完整性与备份一致性仍 UNKNOWN。此任务只观察一次当前 CLI 连接可见基表的引擎分布。AUTH-65 的 SSH 1/1 已耗尽；本任务有独立新预算 **1/1**。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-20/49/65/66 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/run.py`、`test_run.py`、`summary.md`。不得修改 AUTH-66 探针、历史证据、源码或控制文件。连接前从工作区原始字节复核上述精确 SHA，失败即停。指定私钥 `C:\Users\zcxve\.ssh\CodexKey.pem` 和既有 `known_hosts` 只核对存在，不读取、输出或复制内容。
- 先静态检查唯一 SSH 调用、固定远端命令、stdin 原始探针字节、标准流上限、超时和严格解析。纯虚构解析测试最多 2 次，不启动 SSH/真实 Laravel/DB；至少覆盖白名单正常、重复/额外/缺失键、尾随字节、畸形 UTF-8、错误类别畸形、版本/指纹不符、计数类型/超限、43/0 与分项不一致及异常脱敏。测试失败即停，不执行现场读取。
- 仅向既有 `root@101.133.161.203` 发起 **1 次** SSH；只用上述私钥与既有 `known_hosts`，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`、`-T` 禁用 PTY；不得重试、更换身份/入口或降低校验。远端唯一命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`，stdin 仅送入已锁定探针原始文件字节，远端不保存文件。外部等待最多 35 秒，stdout/stderr 各上限 16 KiB；超时、超限、SSH 非零或意外 stderr 立即停止。**SSH 连接问题及时反馈 Owner**，不得自行再连。
- stdout 只在本机有上限内存接收，严格解析单行 UTF-8 JSON，拒绝重复/额外键、错误类型、尾随内容或超限。原始 stdout/stderr 不显示、不保存。安全错误、指纹/版本与 AUTH-65 不符、基表/视图与 43/0 不符时记录脱敏差异并停止，不追加探测。全部通过才记录固定五项计数；始终保留 `scope_completeness=UNKNOWN` 与 `backup_consistency=UNKNOWN`，任何引擎分布都不得被写成完整备份一致性 PASS。
- 只保存脱敏阶段状态、SSH/解析结果、固定计数、目标比较、首个失败与未解决门；不保存表名、原始引擎名、主机/库名、凭据、SQL 输出或错误流。`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

不得访问旧 `D:\EliteSync`、CloudShell、云 API、Docker、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体；不得读业务表行、执行 HTTP/API、dump、备份、导出、恢复、删除、DDL/DML 或部署。失败即停；SSH 1/1 用尽不得重试。Codex 不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立审查门。
