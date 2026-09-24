# AUTH-42｜扩大 tmpfs 后的本机虚构恢复回执

状态：**无密码 socket 查询失败，恢复链未启动；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `a389aa3bfec2abc7fc624a1c13f8a628d25dad37`，父提交 `028987f7eab96b86d1c91fcee6d23f07bf05b864`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-42-LOCAL-SYNTHETIC-EXPANDED-TMPFS-RESTORE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32～41 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，静态禁止项检查通过。脚本固定本机 `mariadb:10.11`、唯一容器、无网络/端口/宿主挂载，三处 tmpfs 精确为数据 512 MiB、运行 16 MiB、临时 64 MiB；隔离通过后先无密码 socket 查询，再以至少 131072 KiB 可用空间为写入门。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、含 tmpfs 大小的隔离 inspect | `PASS` | 各 1 |
| 启动至少 45 秒后无密码 socket `SELECT 1` | **`FAIL`**；进程退出码 1、唯一提取错误码 1045 | 1 |
| 数据 tmpfs 空间 `df -Pk` | `NOT_CHECKED`，投影 `UNKNOWN` | 0 |
| 源 schema、原表、三行、容器内 dump、目标 schema、导入、内容核验 | 均 `NOT_CHECKED` | 各 0 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

最早失败 `SOCKET_SELECT_FAILED`。脚本报告总耗时 **51 秒**，低于 180 秒上限；固定计数与内容布尔均 `NOT_CHECKED`。错误码 1045 是本次虚构容器无密码 socket 查询的安全投影；原始 stderr 未保存，不能判定认证配置原因，也不能用 AUTH-38 的另一次成功替代本次结果。空间门未运行，不能宣称扩大后的可用 KiB 或建表效果。隔离与清理状态属于作者运行回执，尚待 Work 独立审查；未复跑设备动作。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次未执行写 SQL、dump/restore 或内容核验；不证明同容器或独立容器恢复、加密本地备份可恢复、真实 DB 身份/结构或生产就绪。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未操作其他容器。脚本不修改、不重跑、不尝试其他认证方式或手动补步骤；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — 扩容后同容器虚构恢复目标未达到；接受无密码 socket 失败与清理的受限回执。** Work 核对派发 HEAD `a389aa3bfec2abc7fc624a1c13f8a628d25dad37`、父提交 `028987f7eab96b86d1c91fcee6d23f07bf05b864`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 366、26 行，SHA-256 `163C2033AC00A7FABE5E9BCAC8989C271B390318A8A3E0D2A308EDDB0CAEC7D8`、`FBC2518F99BD1D9E25717FAFC5D65CF5838C1DBFF080EC93D3FD8B542093D3B8`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未重跑一次性容器脚本。

脚本静态限定本机固定镜像、无网络/端口/宿主挂载、三处扩大 tmpfs、AUTH-32 解析器哈希、无密码 socket 前置、空间门、虚构 SQL/dump/restore 与按自身 ID 清理。作者一次运行报告预检和固定隔离声明通过，45 秒后的无密码 socket `SELECT 1` 返回安全码 `1045`，按失败即停；`df`、建表及恢复均 0 次，按 ID 清理并核对不存在。原始错误和容器状态未保存，具体认证机制未知；AUTH-38 在不同容器和 128 MiB 数据 tmpfs 下的无密码成功不能转移至这次扩容容器。两种空间配置下的现象可能与初始化完成度有关，但这只是待检验假设，不能写成根因。旧预算耗尽，后继须新任务。
