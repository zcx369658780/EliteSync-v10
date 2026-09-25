# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-70-LOCAL-BACKUP-KEY-DIRECTORY-READINESS`

Risk Level: `LEVEL 2`（真实密钥与备份前的固定本机目录安全边界只读复核；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付两处固定目录的脱敏只读元数据回执及必要的本机静态检查，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已指定分离目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups`（未来仅完整密文）及 `C:\Users\zcxve\EliteSync-v10-DB-Keys`（未来密码保护私钥）。Owner 确认前者不受云同步/云备份覆盖。AUTH-46 的旧时点目录/空间事实不能继承为当前 PASS；AUTH-69 合同要求生成真实私钥前复核精确路径、ACL 和同步边界。本任务只观察当前本机目录元数据，不生成/读取真实材料，不使用 U 盘或密码。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-46/49/69 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-70-LOCAL-BACKUP-KEY-DIRECTORY-READINESS/summary.md`；不写脚本、真实目录或其他路径。只读核对两处**字面固定路径**及必要父路径：存在、目录类型、规范化绝对路径、是否重解析点、所属卷、当前可用字节、ACL 主体/继承的脱敏归类。不得递归、不枚举文件或文件名、不读取目录内任何内容或 ACL 中账户详细标识；只报告是否仅 Owner/系统/管理员必要主体可访问或为 UNKNOWN。两目录须分别判断，不能用备份目录旧事实推导密钥目录。
- 固定查询预算每目录每项至多一次，异常/访问拒绝即标记 UNKNOWN 并停受影响项，不提权、不改 ACL。只读查询固定目录是否位于已知同步根或重解析路径；Owner 关于备份目录无云同步的声明作为产品决定记录，当前配置若无法从不读取内容的元数据可靠核实，则 `sync_boundary=OWNER_DECLARED_NOT_IN_CLOUD / TECHNICAL_UNKNOWN`，不得改写为技术 PASS。密钥目录同步边界单独核对，未知则不批准真实密钥生成。
- 可只读核对 C 盘卷级加密保护状态和当前可用空间，但不得显示/保存恢复密钥、保护器 ID、卷序列号或原始命令输出；若工具不可用则 UNKNOWN。不得以卷加密状态代替私钥密码保护或 U 盘加密。只保存脱敏布尔/状态、字节数、查询时点、失败类别；不保存完整 ACL、目录内容、用户名或敏感路径外的新位置。
- `git diff --check` 最多 1 次，新未跟踪文件另做只读尾随空白检查。回执区分作者观察与 Work 验收，明确不证明真实密钥存在、备份容量充足、完整备份或恢复。Codex 不提交、制作 bundle、推送、自接受或派发后继。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得创建/更改目录、ACL、密钥、备份、加密卷、恢复副本或执行生产操作。停在 Work LEVEL 2 独立审查门。
