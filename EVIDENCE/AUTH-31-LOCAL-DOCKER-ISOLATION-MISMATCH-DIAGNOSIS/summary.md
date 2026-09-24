# AUTH-31｜本机 Docker 隔离字段定点诊断回执

状态：**作者诊断未完成，待 Work LEVEL 2 独立 ACCEPT/REJECT**。本任务没有重跑 AUTH-30，也未运行 MariaDB、SQL、dump 或 restore。执行日期：2026-09-24（Asia/Shanghai）。

## 前置与执行预算

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `d7c5db5be1b34f1734edced3e29d6a262301f428`，父提交 `e1bc29e20840c095017dd5d0c11e954edb3bf896`，符合任务单派发拓扑。工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；仅新增本目录的 `run.ps1` 和本文件。
- `TASK_CURRENT.md` 为 `AUTH-31-LOCAL-DOCKER-ISOLATION-MISMATCH-DIAGNOSIS`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能、AUTH-29 接受记录及 AUTH-30 Work LEVEL 2 REJECT 记录。
- `run.ps1` 静态解析为 **0 个解析错误**，随后执行 **1/1 次**。唯一容器为 `elitesync-auth31-isolation-probe`；固定本地 `mariadb:10.11` 镜像以 `/bin/sh -c 'sleep 75'` 入口启动，`--pull never`、`--network none`、无宿主 bind/volume 与端口参数，沿用三处容器内 tmpfs；未传密码或 SQL。

## 固定结果与最早失败

| 项目 | 当次回执 |
|---|---|
| context、daemon、固定镜像、容器名空闲预检 | `PASS`；各查询 1 次 |
| 固定 sleep 容器启动 | `PASS`；1 次 |
| ID 与名称匹配 | `true` |
| `NetworkMode=none` | `true` |
| `PortBindings` 为空 | `true` |
| `Binds` 为空 | `true` |
| `HostConfig.Tmpfs` 三目标匹配 | `true` |
| `Mounts` 数量 | `UNKNOWN` |
| `Mounts` 类型均为 tmpfs | `UNKNOWN` |
| inspect 阶段 | `FAIL`；最早失败 `ISOLATION_UNPARSEABLE` |
| 精确清理 | `PASS`；对本次容器按 ID 删除 1 次，按固定名称只读核对不存在 1 次 |

脚本报告总耗时 **7 秒**，未触及 90 秒上限。调用账本：context 1、daemon 1、image 1、名称预检 1、run 1、inspect 1、异常所有权检查 0、remove 1、absence check 1。原始 inspect、端点、镜像元数据、容器日志及 stdout/stderr 未保存或显示。

**原因边界**：本次只能确认前五项谓词为真，不能判定 `Mounts` 实际数量或类型，因此不能定位 AUTH-30 的具体不符项。只对 PowerShell 表达式做的独立语义核对确认：在严格模式下，`$value = if (...) { @() } else { ... }` 的空分支会赋成 `$null`，随后访问 `$value.Count` 报错。`run.ps1` 的 Mounts 分支存在相同写法，这与本次 `ISOLATION_UNPARSEABLE` 一致；但未保存原始 inspect，不能据此断言本次 Docker `Mounts` 为空，也不能把脚本解析错误解释为隔离安全通过。执行脚本保持原样，不修订后重跑；一次预算已耗尽。

验证：`git diff --check` 按预算执行 1/1 次，退出码 0、无输出；该检查不覆盖未跟踪新文件，`run.ps1` 和本文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本回执不反证 AUTH-30 当次失败，也不证明本机网络隔离、镜像安全或恢复能力。后续若要核实 Mounts 字段和旧失败原因，需由 Work/Owner 决定独立任务及新预算。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、凭据、密钥或业务数据；未备份、传输、恢复或改库。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — 定位全部隔离谓词的目标未完成；仅接受前五项谓词、最早失败和清理的受限事实回执。** Work 核对派发 HEAD `d7c5db5be1b34f1734edced3e29d6a262301f428`、唯一候选目录中 `run.ps1` 原 202 行、SHA-256 `8D1A0F22225D026379A49205E974FCCBDC6A794598C424049E6E3F3B260211AD`，本 `summary.md` 原 33 行、SHA-256 `69734DCB385D7A4A56C844707AFBB5E79A991863051C9ADDEED47190F2FF10E3`；两文件均 0 行尾随空白。独立运行 `git diff --check` 退出 0，不覆盖未跟踪文件。Work 未重跑容器；作者报告一次启动、一次 inspect、`ISOLATION_UNPARSEABLE` 后按 ID 清理并核对不存在，数据库操作为零。

Work 另以不涉及 Docker 的 PowerShell 严格模式小表达式核对：`$sample = if ($true) { @() } else { @(1) }` 得到 `$null`，随后访问 `$sample.Count` 抛错。候选脚本 Mounts 分支使用同类赋值，足以解释本次解析失败的一种代码路径；原始 inspect 未保存，不能反推 Mounts 实际为空，也不能把其余谓词提升为完整隔离 PASS。任何修正和再次执行须另立任务；AUTH-31 一次运行预算不重置。
