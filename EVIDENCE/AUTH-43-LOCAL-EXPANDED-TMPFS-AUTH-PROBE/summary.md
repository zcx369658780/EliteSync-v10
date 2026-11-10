# AUTH-43｜扩大 tmpfs 虚构密码认证与空间回执

状态：**环境变量密码 `SELECT 1` 成功，待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `066b1ef2de8a04fa417ab416099893098bff514a`，父提交 `f2ae6f108d3a0e166341f28885b0f4c012e94586`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-43-LOCAL-EXPANDED-TMPFS-AUTH-PROBE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32～42 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，受限路径和无写 SQL 边界检查通过。脚本限定本机固定镜像、唯一容器、无网络/端口/宿主挂载、三处精确 tmpfs，先核对虚构初始化密码布尔、隔离和空间，再最多两种条件认证。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、隔离 inspect | `PASS`；本次 ID/名称、虚构密码环境变量精确匹配、无网络/端口/Binds、三个 tmpfs 目标及大小均为 true；`Mounts=0` 且解析通过 | 各 1 |
| 数据 tmpfs 固定 `df -Pk` | `PASS`；size 524288、used 151736、available **372552 KiB** | 1 |
| 同一虚构密码经 `MYSQL_PWD` 的 `SELECT 1` | **`PASS`**；退出码 0、stdout 严格为 `1` | 1 |
| 仅在首种失败且唯一错误码 `1045` 时的显式密码对照 | `NOT_CHECKED`；退出码和错误码均 `NOT_CHECKED` | 0 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

最早失败 `NONE`；脚本报告总耗时 **51 秒**，低于 150 秒上限。首种认证成功即按任务停止，不能把第二种方式写为 PASS。隔离、空间和清理为作者一次设备运行回执，尚待 Work 独立审查；未复跑。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次未用无密码连接，未运行写 SQL、dump/restore 或真实备份；这只说明本次虚构容器在该时点的密码认证和空间投影，不证明 AUTH-42 失败的根因、真实 DB 认证、建表或备份可恢复。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未操作其他容器。脚本不修改、不重跑、不补做显式密码方式；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本次扩大 tmpfs 的虚构容器密码认证和空间投影。** Work 核对派发 HEAD `066b1ef2de8a04fa417ab416099893098bff514a`、父提交 `f2ae6f108d3a0e166341f28885b0f4c012e94586`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 326、26 行，SHA-256 `D913CE46DE440A7D49909ACA9FF30E1BFD326B6A3D1683DBB6A46AC6C528FC51`、`4AC9A62FB797E6799BC67D99610996668AF8EA77F07C585D66CFD99085610F98`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未重跑一次性容器脚本。

脚本静态核对本机固定镜像/唯一名称、无网络/端口/宿主挂载、精确 tmpfs 大小、AUTH-32 解析器哈希、虚构密码只在内存比较的布尔、`df` 整数投影、最多两种条件认证和按本次 ID 清理。作者回执报告 `MARIADB_ROOT_PASSWORD` 与本次虚构值匹配，数据 tmpfs `size=524288`、`used=151736`、`available=372552` KiB，环境变量密码方式首次 `SELECT 1` PASS；第二种方式按条件 0 次，按 ID 清理并核对不存在。原始 inspect 和 Docker 输出未保存，资源、隔离及清理仍是作者设备回执。此 ACCEPT 不确定 AUTH-42 的 1045 细因，更不证明写入或恢复。旧预算耗尽；后继须新任务。
