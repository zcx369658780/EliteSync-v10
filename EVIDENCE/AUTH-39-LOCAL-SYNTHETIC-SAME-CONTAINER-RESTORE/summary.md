# AUTH-39｜本机同容器虚构恢复候选回执

状态：**建表阶段失败，待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。同容器 dump/restore 目标未完成；本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `3729c117154dda1f5de53183baf2c81d2fb0395c`，父提交 `80096abab5ddbadc3a3eeb63a392d739476bde8b`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。只新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-39-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32～38 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，静态禁止项检查通过。脚本限定固定本机镜像、唯一容器、无网络/宿主挂载/端口、三个 tmpfs、启动至少 45 秒后无密码 socket 查询、后续按序且各最多一次的虚构 SQL/dump/import，以及可验证归属后按本次 ID 清理。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、隔离 inspect | `PASS` | 各 1 |
| 启动至少 45 秒后无密码 socket `SELECT 1` | `PASS` | 1 |
| 虚构源 schema 创建 | `PASS` | 1 |
| 虚构源表创建 | **`FAIL`；最早失败 `SOURCE_TABLE_FAILED`** | 1 |
| 三行插入、容器 `/tmp` 内 dump、目标 schema、导入、内容核验 | 均 `NOT_CHECKED` | 各 0 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

脚本报告总耗时 **51 秒**，低于 180 秒上限；固定行数和内容核验均 `NOT_CHECKED`。建表失败仅表示该次命令未成功，原始 stderr/stdout 未保存，具体原因 `UNKNOWN`。Docker 字段与清理状态属于作者一次运行回执，尚待 Work 独立审查；未重跑设备动作。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次未插入虚构行、未 dump、未导入、未核验恢复内容；不证明同容器或独立容器恢复、加密本地备份可恢复、真实 DB 身份/结构或生产就绪。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未导出到宿主机或操作其他容器。脚本不修改、不重跑、不手动补步骤；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — 同容器虚构 dump/restore 目标未达到；接受到建表失败为止的受限事实回执。** Work 核对派发 HEAD `3729c117154dda1f5de53183baf2c81d2fb0395c`、父提交 `80096abab5ddbadc3a3eeb63a392d739476bde8b`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 313、27 行，SHA-256 `4B7D129813CFF8C0E24045274D77DA47E1000245FEFC43AF51161010F3EF7E45`、`19708ACC975B0CDB2159E94B2A72E419FFC12DC12599A87992E30B4781D0B3DD`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未重跑一次性容器脚本。

脚本静态限定本机固定镜像/容器、无网络/端口/宿主挂载、三个 tmpfs、已接受解析器哈希、无密码本机 socket、固定虚构 SQL 与容器内 `/tmp` dump，并有失败即停及按自身 ID 清理。作者回执报告预检与隔离声明通过、`SELECT 1` 和源 schema 创建成功，源表创建命令失败，后续插入、dump、导入、校验均 0 次；按 ID 精确清理并核对不存在。原始建表错误未保留，不能确认是 SQL 语法、权限、状态或其他问题；Docker 字段和清理仍是作者设备回执，不是 Work 独立复跑。旧预算耗尽，任何进一步定位需要新任务。
