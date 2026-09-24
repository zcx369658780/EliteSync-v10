# AUTH-44｜本机同容器虚构恢复候选回执

状态：**三行虚构样本在同一容器内导入第二 schema 并核对一致；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `4fd07a06154476d8dc096e240a54c4d2b22892de`，父提交 `7e1e511c2606d89fb68f88fbd5935c6c83ed8f94`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-44-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32、AUTH-39～43 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，受限路径与安全边界检查通过。脚本限定本机固定镜像/唯一容器、无网络/端口/宿主挂载、三处精确 tmpfs、虚构密码布尔、空间门、固定三行及容器 `/tmp` tmpfs 内的 dump/import。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、隔离 inspect | `PASS`；本次 ID/名称、虚构密码匹配、无网络/端口/Binds、三个 tmpfs 目标及大小均为 true；`Mounts=0` 且解析通过 | 各 1 |
| 数据 tmpfs 固定 `df -Pk` | `PASS`；size 524288、used 151736、available **372552 KiB** | 1 |
| 同一虚构密码经 `MYSQL_PWD` 的 `SELECT 1` | `PASS` | 1 |
| 虚构源 schema、唯一表、三行插入 | 均 `PASS` | 各 1 |
| 源端精确三行计数与按 id 排序的固定内容 | `PASS`；计数为 3、固定内容布尔 true | 1 |
| 本次容器 `/tmp` tmpfs 内 dump | `PASS` | 1 |
| 虚构目标 schema、从容器内 dump 导入 | 均 `PASS` | 各 1 |
| 目标端精确三行计数、固定内容及源目标一致 | `PASS`；计数为 3、两个布尔均 true | 1 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

最早失败 `NONE`；失败退出码与 MariaDB 错误码均 `NOT_CHECKED`。脚本报告总耗时 **53 秒**，低于 210 秒上限。原始 stdout/stderr、inspect、dump、行内容、虚构密码及容器 ID 未保存或显示。隔离、数据核验和清理均是作者一次设备运行回执，尚待 Work 独立审查；未重跑。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次只证明固定三行虚构样本在**同一个容器内**由源 schema 导出并导入目标 schema 后内容一致；没有独立容器/环境恢复、真实数据库身份或结构、完整加密本地备份可恢复、生产就绪或发布证明。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未向宿主导出 dump、未操作其他容器。脚本不修改、不重跑、不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受三行虚构样本的同容器导出、导入与固定内容一致的受限回执。** Work 核对派发 HEAD `4fd07a06154476d8dc096e240a54c4d2b22892de`、父提交 `7e1e511c2606d89fb68f88fbd5935c6c83ed8f94`，候选仅本目录 `run.ps1`、`summary.md`。审查时脚本 SHA-256 `5356031872C7F0766B5D8FDD83352D24EC200BA2149FCB0A0998B0D3A87E4376`，摘要审查前 SHA-256 `029504052D8F359B8283446896EC7C2CC2155028BEB6BDCD59F7FE436873C376`；脚本 PowerShell 静态解析 0 错误，两文件尾随空白 0 行，`git diff --check` 退出 0。Work 未重跑一次性容器脚本。

脚本静态限定本机固定镜像、唯一名称及 nonce 所有权、无网络/端口/Binds、三处精确 tmpfs、AUTH-32 解析器哈希、131072 KiB 空间门、经 `MYSQL_PWD` 的单次认证、固定虚构 SQL、容器 `/tmp` tmpfs 内 dump 和按 ID 清理；无宿主持久 dump 路径。作者报告所有固定阶段 PASS、源和目标三行内容匹配、53 秒完成及清理 PASS。Work 另只读检查固定容器名当时不存在。原始 inspect、SQL 与 Docker 输出未保存，因此隔离、内容与清理的细节仍依赖作者回执；容器名不存在不能单独证明历史执行过程。本 ACCEPT 不证明独立环境恢复、真实完整备份可恢复或改库前置条件达成。旧一次运行预算耗尽。
