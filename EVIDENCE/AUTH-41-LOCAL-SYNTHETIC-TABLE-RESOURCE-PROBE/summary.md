# AUTH-41｜本机虚构建表资源投影回执

状态：**建表前固定 tmpfs 可用空间为 0 KiB；建表失败，后续诊断提前中断；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `8139fbf58221eaa067764c9cfe1f13316a162e9a`，父提交 `38702e41635efb229c6aa9806469f5be86788651`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-41-LOCAL-SYNTHETIC-TABLE-RESOURCE-PROBE`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-32～40 回执；旧任务预算未重置。
- AUTH-32 解析器 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 匹配。新脚本 PowerShell 静态解析 0 错误，静态禁止项检查通过。脚本固定本机镜像与容器、无网络/端口/宿主挂载、三个 tmpfs、无密码 socket、原建表 SQL，以及受限的资源与错误投影。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 解析器、本机 context、daemon、固定镜像、名称空闲预检 | `PASS` | 各 1 |
| 固定容器启动、隔离 inspect | `PASS` | 各 1 |
| 启动至少 45 秒后无密码 socket `SELECT 1` | `PASS` | 1 |
| 虚构源 schema 创建 | `PASS` | 1 |
| 建表前固定 tmpfs `df -Pk` | `PASS`；size 131072、used 131072、available **0 KiB** | 1 |
| AUTH-39 原建表 SQL 等价版本 | **`FAIL`**；进程退出码 1、提取数字错误码 3 | 1 |
| 错误类别 | `NOT_CHECKED`；脚本在提取阶段提前中断 | 0 个完成的分类结果 |
| 建表后 `df -Pk` 与固定 State inspect | 均 `NOT_CHECKED`，投影 `UNKNOWN` | 各 0 |
| 本次容器清理 | `PASS` | 按 ID 删除 1、按名称核对不存在 1；额外所有权检查 0 |

最早失败 `ORIGINAL_TABLE_FAILED`。脚本报告总耗时 **52 秒**，低于 150 秒上限。建表前固定 tmpfs 的 0 KiB 可用空间是本次资源投影事实；错误类别、建表后资源与 State 因脚本在类别提取阶段中断而未形成回执。数字错误码 3 只是脚本按固定范围提取的结果，原始 stderr 未保存；不能单凭该码或一次空间投影确定建表的唯一原因。静态可见类别提取函数使用与 PowerShell 自动 `$Matches` 变量同名的 `$matches`，这可能导致中断，但本次未保存异常详情，具体中断机制未获运行确认。隔离与清理状态属于作者运行回执，尚待 Work 独立审查；未复跑设备动作。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次未插入行、未运行 dump/restore、未改变 SQL 或 tmpfs 配置，不证明虚构或真实备份可恢复。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未操作其他容器。脚本不修改、不重跑、不手动补命令；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — 完整资源与错误类别诊断未完成；接受建表前 tmpfs 数值和失败/清理的受限回执。** Work 核对派发 HEAD `8139fbf58221eaa067764c9cfe1f13316a162e9a`、父提交 `38702e41635efb229c6aa9806469f5be86788651`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 367、29 行，SHA-256 `B04A1E2D7222FE3F725AB1D3DDB1075CD1463A290B72B11EA32F039487081674`、`9EE8C5029D9A374611DCF5DC1682FCD4996FBC182FE7295AF7BA8F22749F0706`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未重跑一次性容器脚本。

脚本静态限定本机固定镜像、无网络/端口/宿主挂载、三个 tmpfs、AUTH-32 解析器哈希、固定无密码 socket/SQL、固定 `df -Pk` 数值投影和按自身 ID 清理。作者回执报告建表前 `/var/lib/mysql` `size=131072`、`used=131072`、`available=0` KiB，随后建表退出码 1，数字码 3，按 ID 清理并核对不存在。错误类别、建表后资源、容器 State 未形成；脚本的类别函数使用与 PowerShell 自动变量 `$Matches` 同名的 `$matches`，是静态可见的缺陷风险，不能据此重建未保存的运行异常。0 KiB 是该虚构容器的资源观察，强烈提示空间约束，但未证明它是唯一建表原因。旧预算耗尽；下一步若扩大 tmpfs，须用新任务和新容器。
