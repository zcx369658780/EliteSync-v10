# AUTH-40｜本机虚构建表失败定点诊断回执

状态：**原建表再次失败，安全码 `UNRECOGNIZED/UNKNOWN`；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。条件对照未执行，本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `7b76bf53ec60abf4be50cc869aa42e2613980a2b`，父提交 `41764d7935838f1bf0f5340f2b009820c060b6f3`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-40-LOCAL-SYNTHETIC-TABLE-FAILURE-DIAGNOSIS`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32～39 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，静态禁止项检查通过。脚本限定本机固定镜像与容器、无网络/端口/宿主挂载、三个 tmpfs、启动至少 45 秒后的无密码 socket、固定原建表 SQL，以及只有唯一安全码 `1064` 才执行的字段名对照。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、隔离 inspect | `PASS` | 各 1 |
| 启动至少 45 秒后无密码 socket `SELECT 1` | `PASS` | 1 |
| 虚构源 schema 创建 | `PASS` | 1 |
| AUTH-39 原建表 SQL 等价版本 | **`FAIL`；安全码 `UNRECOGNIZED/UNKNOWN`** | 1 |
| 仅在原命令唯一安全码 `1064` 时允许的 `item_text` 对照 | `NOT_CHECKED`；安全码 `NOT_CHECKED` | 0 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

最早失败 `ORIGINAL_TABLE_FAILED`。脚本报告总耗时 **52 秒**，低于 150 秒上限。安全码未能唯一识别为白名单数字；原始 stdout/stderr 未保存，不能据此判定是否为语法错误或说明 AUTH-39 的具体根因。隔离与清理状态属于作者运行回执，尚待 Work 独立审查；未复跑设备动作。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次未插入任何行、未运行 dump/restore，也未执行字段名对照；不证明该字段名是唯一根因、虚构或真实备份可恢复。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未操作其他容器。脚本不修改、不重跑、不手动补命令；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — 提取具体建表安全码与条件对照的目标未达到；接受原建表再次失败与对照未运行的受限回执。** Work 核对派发 HEAD `7b76bf53ec60abf4be50cc869aa42e2613980a2b`、父提交 `41764d7935838f1bf0f5340f2b009820c060b6f3`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 304、27 行，SHA-256 `57E6E337FD865E0C71B7B56310CB4944D106F0E002A96D9B657CED971FD2B274`、`6ED5F9D7560EDE63627131ACC2A50F36EF3D62E118D6F3D52BA5A62D0D58CFCC`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未复跑一次性容器脚本。

脚本静态限定本机固定镜像、无网络/端口/宿主挂载、三个 tmpfs、AUTH-32 解析器哈希、无密码 socket、固定原建表和仅在唯一 `1064` 时运行对照，且按本次 ID 精确清理。作者一次运行报告预检、隔离声明、`SELECT 1` 和源 schema 创建通过，原建表失败且安全码 `UNRECOGNIZED/UNKNOWN`，对照 0 次，按 ID 清理并核对不存在。原始错误未保存，不能将失败定性为语法、空间、权限或连接问题；隔离及清理为作者设备回执。AUTH-40 运行预算耗尽，任何扩展观察须另立任务。
