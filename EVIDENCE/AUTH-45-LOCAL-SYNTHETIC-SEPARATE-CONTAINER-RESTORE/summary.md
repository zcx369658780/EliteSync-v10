# AUTH-45｜本机分离容器虚构恢复候选回执

状态：**源容器清理后在新目标容器中导入三行虚构样本并核对一致；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `2de547b5b90dd4e9d9290aaba51d6ac64c3ff6d2`，父提交 `27c2d86d5c164d309352f51255905697d3702a8f`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-45-LOCAL-SYNTHETIC-SEPARATE-CONTAINER-RESTORE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32、AUTH-43～44 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，固定无网络/端口/宿主挂载、三处精确 tmpfs、双名称预检、分别的 nonce 所有权与清理门、内存 dump 上限及目标 stdin 导入均在静态检查范围内。静态检查后执行 **1/1 次**。

## 一次顺序演练回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、两个名称空闲预检 | `PASS` | 各 1 |
| 源容器启动、隔离 inspect | `PASS`；本次 ID/名称/nonce、虚构密码、无网络/端口/Binds、三个 tmpfs 目标及大小均匹配；`Mounts=0` 且解析通过 | 各 1 |
| 源容器 `df -Pk` 与密码 `SELECT 1` | 均 `PASS`；size 524288、used 151736、available 372552 KiB | 各 1 |
| 源 schema、唯一表、三行插入、精确计数及按 id 排序的固定内容 | 均 `PASS`；计数为 3、内容布尔 true | 各 1 |
| 源端 `mariadb-dump` 到宿主进程内存 | `PASS`；UTF-8 **2039 字节**，非空且低于 262144 字节限额 | 1 |
| **源容器按 ID 清理、按名称核对不存在** | **`PASS`；此后才启动目标** | 删除 1、核对 1；额外所有权检查 0 |
| 目标容器启动、隔离 inspect | `PASS`；对应固定隔离字段匹配，`Mounts=0` 且解析通过 | 各 1 |
| 目标容器 `df -Pk` 与密码 `SELECT 1` | 均 `PASS`；size 524288、used 151736、available 372552 KiB | 各 1 |
| 目标 schema、通过 `docker exec -i` stdin 导入内存 dump | 均 `PASS` | 各 1 |
| 目标端精确三行计数、固定内容、与源一致 | `PASS`；计数为 3、两个布尔均 true | 1 |
| 目标容器按 ID 清理、按名称核对不存在 | `PASS` | 删除 1、核对 1；额外所有权检查 0 |

最早失败 `NONE`；失败退出码和 MariaDB 错误码均 `NOT_CHECKED`。脚本报告总耗时 **100 秒**，低于 300 秒上限。内存 dump 在目标导入后清除，未写宿主或容器文件；原始 stdout/stderr、dump、SQL 行内容、inspect、密码和容器 ID 未保存或显示。隔离、内容及清理细节均属于作者一次设备运行回执，尚待 Work 独立审查；未重跑。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次只证明固定三行虚构样本在源容器消失后，可由进程内存 dump 导入另一新容器并核对一致；不证明真实数据库身份、完整加密持久备份、真实数据兼容、生产或发布就绪。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未操作其他容器。脚本不修改、不重跑、不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受固定三行虚构样本在源容器清理后，经宿主进程内存导入另一新容器并核对一致的受限回执。** Work 核对派发 HEAD `2de547b5b90dd4e9d9290aaba51d6ac64c3ff6d2`、父提交 `27c2d86d5c164d309352f51255905697d3702a8f`，候选仅本目录 `run.ps1`、`summary.md`。审查时脚本 SHA-256 `956C790FB3E303A1B1FE992B036DA9295FC066B039F2F13C98F0CE88A4436EE2`，摘要审查前 SHA-256 `19F035D506F9FA73BC7DD6C344FBDBA9A9406885A85DD3EB25B8E6B35B325AAC`；脚本 PowerShell 静态解析 0 错误，两文件尾随空白 0 行。Work 未重跑一次性容器脚本。

脚本静态核对两个名称的预检、每个容器的本机/无网络/无端口/无 Binds/三处 tmpfs 及 nonce 所有权门、131072 KiB 空间门、各自虚构密码认证、固定源数据与目标核对、dump 262144 字节上限，以及源容器按 ID 清理 PASS 才能启动目标。目标导入使用 `docker exec -i` 的 stdin，未设宿主或容器 dump 文件路径；内存字节在导入后或失败清理中清零。作者报告两次隔离及清理 PASS、dump 2039 字节、两端三行一致、总耗时 100 秒。Work 另只读检查两个固定容器名当时均不存在。原始 inspect、SQL 和 Docker 输出未保存，执行细节仍依赖作者回执；容器名不存在不能单独证明历史顺序。本 ACCEPT 不证明真实数据库身份、完整加密持久备份或真实数据可恢复，旧一次预算耗尽。
