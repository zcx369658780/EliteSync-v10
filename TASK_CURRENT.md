# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-46-LOCAL-BACKUP-DESTINATION-READINESS`

Risk Level: `LEVEL 2`（本机真实备份目标目录的只读安全与工具预检；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — LOCAL DESTINATION FACTS ONLY`

Assignee: `Codex`。只交付一份脱敏本机事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：精确目录存在、为空、ACL 继承关闭且只有当前用户/SYSTEM/Administrators 显式 FullControl、C 盘可用空间及 OpenSSL/SSH 工具事实获 LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-46-LOCAL-BACKUP-DESTINATION-READINESS/summary.md`。GPG 版本、BitLocker、OneDrive 前缀及其他自动同步仍 UNKNOWN；未完成加密/传输或真实备份安全门。

## Authority and objective

Owner 允许在 C 盘建立加密数据库备份目录，并要求实际需要密码时由本人输入。Work 已建立**空**目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，将其 ACL 收紧为当前用户、SYSTEM、Administrators 的显式 FullControl；这不是备份。AUTH-45 仅证明三行虚构样本的分离容器恢复。本任务只读核验该精确目标的路径、权限、容量与本机加密工具可用性，为后续设计提供事实；不得生成密钥、要求密码或接触真实数据。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-25、AUTH-26、AUTH-45 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD 和工作区。当前 HEAD 应为仅下达本任务的提交，父提交精确为 `803706d3ebe2ae6129bee2cebb8d82e977dcafba`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。
- 对精确目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 各只读核对一次：存在且是普通目录；自身与父目录均非重解析点；目录为空；规范化绝对路径仍是该精确路径；ACL 继承为关闭，Allow 主体只含当前 Windows 用户 SID、SYSTEM 与 Administrators 且权限为 FullControl、没有 Deny 或其他主体；C 盘当前可用字节为非负整数。任一字段无法判断记 `UNKNOWN`，不推断安全。
- 只读查询本机 `openssl`、`gpg`、`ssh` 命令是否可解析及版本各最多一次；不运行加密、生成密钥或安装工具。只读查询 C 盘 BitLocker 保护状态最多一次，失败记 `UNKNOWN`，不尝试修复或启用。只用目标路径与系统报告的 OneDrive 根路径作字符串前缀核对；未发现前缀关系只说明该项，不能证明不存在其他自动同步。
- 输出只含上述路径/空目录/ACL 布尔、允许主体类别、可用字节、工具存在与版本、BitLocker `ON/OFF/UNKNOWN`、OneDrive 前缀布尔或 UNKNOWN、每项查询次数与首个失败；不得记录其他目录内容、用户名之外的 SID、环境变量原文、密钥、凭据、数据库行或敏感文件名。不得修改目录 ACL、写文件、删除、启动容器或访问网络。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-46-LOCAL-BACKUP-DESTINATION-READINESS/summary.md`；不得修改控制文件、源码或此前证据。每项固定查询最多一次，失败不换方法、不重试。`git diff --check` 最多一次，新文件另做只读尾随空白检查。Codex 不提交、制作 bundle、推送、自接受或派发后继。Work 独立验收后才更新状态。

不得访问旧 `D:\EliteSync`、浏览器、SSH 远端、云 API、真实 DB、备份文件、真实密钥/密码、账号/Token/消息/媒体或业务数据；不做真实备份、传输、恢复、改库、清理或部署。本任务通过只说明此时本机目标可作为后续方案输入，不能证明完整加密备份可做、磁盘故障可恢复或真实 DB 身份。
