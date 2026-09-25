# AUTH-70｜本机备份与密钥目录只读边界回执

状态：**作者受限观察候选；待 Work LEVEL 2 独立 ACCEPT/REJECT**。查询时点：2026-09-25 12:32:01 +08:00。

## 授权与范围

- 本地仓库 `D:\EliteSync-v10`，分支 `main`，执行前 HEAD `29501a36c4ee4dcf47155183a5e1bedeee50a723`。`TASK_CURRENT.md` 为 `AUTH-70-LOCAL-BACKUP-KEY-DIRECTORY-READINESS`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2；已核对项目入口、风险门、本地 workflow 技能及 AUTH-46/49/69 验收。
- 执行前仅有两个无关未跟踪目录：`EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`。两者保留原状；本任务仅新增本文件。
- 固定目标仅为 `C:\Users\zcxve\EliteSync-v10-DB-Backups`（备份密文候选）与 `C:\Users\zcxve\EliteSync-v10-DB-Keys`（密码保护私钥候选）。没有枚举文件名、读取目录内容或保存完整 ACL、账户标识与原始命令输出。

## 固定只读元数据

| 观察项 | 备份目录 | 密钥目录 |
|---|---|---|
| 固定路径存在、为目录、规范化绝对路径精确匹配 | 是 / 是 / 是 | 是 / 是 / 是 |
| 目标为重解析点 | 否 | 否 |
| ACL Owner 归类 | 当前用户 | 当前用户 |
| ACL 继承 / 已继承 ACE | 关闭 / 无 | 关闭 / 无 |
| ACL 主体归类 | 仅当前用户、SYSTEM、Administrators；三类均出现；无其他或无法解析主体、无 Deny | 仅当前用户、SYSTEM、Administrators；三类均出现；无其他或无法解析主体、无 Deny |
| 已知 OneDrive 根前缀判断 | `UNKNOWN` | `UNKNOWN` |
| 完整自动同步/云备份覆盖边界 | `TECHNICAL_UNKNOWN` | `TECHNICAL_UNKNOWN` |

必要父路径 `C:\`、`C:\Users`、`C:\Users\zcxve` 各查询一次：均存在、为目录、规范路径匹配且非重解析点。两处目标的路径对象与 ACL 各查询一次；以上 ACL 结果只证明本次返回的主体和继承归类，不证明未来权限不变或其他软件无法访问。未读取 ACL 中的账户详细标识，也未检查目录内部。

同一次 C: 卷级只读查询报告可用 **642974105600 bytes**；这是当次余量，不是完整备份容量 PASS。BitLocker 保护状态为 **`UNKNOWN`**（查询失败类别 `BITLOCKER_QUERY_FAILED`，未重试）。已知 OneDrive 根路径在本次进程中未形成可判断的根集合，故两目录的前缀判断分别为 `UNKNOWN`；未扩大到软件清单、目录内容或其他位置搜索。Owner 对备份目录“不受云同步/云备份覆盖”的声明记录为 **`OWNER_DECLARED_NOT_IN_CLOUD / TECHNICAL_UNKNOWN`**；密钥目录无对应技术确认，仍为 **`TECHNICAL_UNKNOWN`**。当前观察不能批准真实私钥生成或真实备份。

## 验证与停点

本任务没有使用 U 盘、密码、密钥、备份或真实数据库，没有修改目录、ACL、卷、同步配置或其他路径；未连接服务器、云服务或 Docker，未访问旧 `D:\EliteSync`。`git diff --check` 按预算执行 **1/1 次，退出码 0**；它不覆盖未跟踪新文件，本文件另作只读尾随空白检查，**0 行**。上述均为作者观察，Work 尚未独立验收。本回执不证明真实密钥存在、私钥密码保护、失钥恢复、备份容量充足、完整备份或真实恢复。作者不提交、制作 bundle、推送、自接受或派发后继，停在 **Work LEVEL 2 独立 ACCEPT/REJECT** 门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受当次固定本机目录元数据的受限事实回执。** Work 核对派发 HEAD `29501a36c4ee4dcf47155183a5e1bedeee50a723`、唯一候选文件和 AUTH-46/49/69 的历史范围；作者回执限定为两个固定目录及必要父路径的非重解析、规范路径、ACL 归类、C: 当次空间。Work 未重新查询本机权限或卷，原始系统对象未保存；因此只接受作者当次脱敏观察，不把它外推为长期权限或容量。作者 `git diff --check` 1/1 退出 0；Work 对未跟踪新文件另查尾随空白 0 行。审查前本文件 SHA-256 为 `31A574DE735D3F85F90E3391778A3C1A1535702BDDEB70856514996838E99F32`。

同步技术覆盖和 C: BitLocker 保护均为 `UNKNOWN`。Owner 对备份目录的无云同步声明继续有效，但密钥目录同步边界须单独确认。接受不授权生成私钥、写 U 盘、真实备份或恢复；无真实密钥、备份或失钥恢复证明。两处无关未跟踪目录保留。
