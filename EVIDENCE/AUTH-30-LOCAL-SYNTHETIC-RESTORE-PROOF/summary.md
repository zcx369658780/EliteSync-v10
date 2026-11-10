# AUTH-30｜本机虚构恢复演练候选回执

状态：**作者运行失败，待 Work LEVEL 2 独立 ACCEPT/REJECT**。本任务没有完成虚构 dump/restore，更没有真实数据库恢复证明。执行日期：2026-09-24（Asia/Shanghai）。

## 前置与范围

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `e88163e9b4b7b461a7669b5578d63e478779cfe9`，父提交 `84e709575f2c4bf9d82a2e46af480fd784be1af5`，符合任务单派发拓扑。
- 执行前工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；本任务仅新增同目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-30-LOCAL-SYNTHETIC-RESTORE-PROOF`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能及 AUTH-27/28/29 的 Work LEVEL 2 ACCEPT 记录。
- 先对 `run.ps1` 做 PowerShell 静态解析，**0 个解析错误**；再只执行脚本 **1/1 次**。脚本固定唯一容器名 `elitesync-auth30-synthetic-restore`、本地标签 `mariadb:10.11`、`--pull never`、`--network none`、无端口/宿主挂载，数据、运行和临时目录声明为容器内 tmpfs。它只含虚构凭据、schema、表和三行固定虚构数据；这些设计声明不替代运行时隔离检查。

## 实际运行与最早失败

| 阶段 | 结果 | 实际执行 |
|---|---|---|
| 预检 | `PASS` | 当前 context、daemon、固定本地镜像和容器名空闲各查询 1 次。 |
| 启动 | `PASS` | 固定名称容器启动 1 次；未拉取镜像。 |
| 隔离声明检查 | `FAIL` | 对本次容器检查 1 次；最早失败 `ISOLATION_DECLARATION_MISMATCH`。 |
| 虚构 dump/restore | `NOT_CHECKED` | readiness、建库/表/行、dump、第二 schema 和 restore 均 0 次。 |
| 行数及固定内容校验 | `NOT_CHECKED` | 0 次。 |
| 精确清理 | `PASS` | 对本次创建的容器按 ID 删除 1 次；按固定名称只读核对不存在 1 次。 |

脚本报告总耗时 **7 秒**，未触及 120 秒上限。原始 inspect、stdout/stderr、容器日志、镜像元数据和数据库内容未保存；因此本回执只保留固定失败类别，**不能判断是哪一项隔离声明不符**。失败后未继续数据库步骤，未重试、换镜像、放宽校验或运行第二次。`cleanup=PASS` 只说明本次固定容器已按脚本回执清理并核对不存在；不证明其他环境状态。

完整调用账本：context 1、daemon 1、image 1、名称预检 1、run 1、隔离 inspect 1、readiness 0、setup 0、dump 0、恢复 schema 0、restore 0、validation 0、remove 1、absence check 1、异常所有权检查 0。脚本唯一标准输出为阶段、最早失败、清理状态、耗时和调用次数的固定摘要。

验证：`git diff --check` 按预算执行 1/1 次，退出码 0、无输出；该检查不覆盖未跟踪新文件，`run.ps1` 和本文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次结果不证明网络隔离、虚构恢复可行，更不证明真实备份可恢复或真实数据可安全存放。任何后续定位、脚本修订或重新演练须由 Work/Owner 根据此失败另行决定并下达独立任务；本任务的一次运行预算已用尽。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、凭据、密钥或业务数据，未进行真实备份、传输、恢复或改库。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — “本地虚构恢复证明完成”目标未达到；仅接受失败与清理的受限事实回执。** Work 核对派发 HEAD `e88163e9b4b7b461a7669b5578d63e478779cfe9`、唯一候选目录中 `run.ps1` 原 244 行、SHA-256 `D1144C5564D6E17CE4F901F9410CBEEC5C48AAF6D216721A0BED48890B6B157E`，以及本 `summary.md` 原 29 行、SHA-256 `0BCECE7B3DA32F51B37180C7764554BF3339B20897ED460C77DC24C9EC44D7DB`；两文件均 0 行尾随空白。独立运行 `git diff --check` 退出 0，该检查不覆盖未跟踪文件。Work 未重跑一次性脚本或 Docker 命令。

脚本静态可见固定容器名与镜像、禁止拉取、无网络/宿主挂载/端口声明、虚构数据、依赖失败即停及仅清理本任务容器的流程；作者回执报告启动 1 次、隔离声明检查 `ISOLATION_DECLARATION_MISMATCH` 后停止所有数据库步骤，按 ID 清理 1 次并核对同名容器不存在。原始 inspect 未保存，不能判定失败的是网络、挂载、端口、名称还是脚本对 Docker 元数据的解析。清理结果依赖作者回执；不能把脚本声明或未执行的负向用例当作隔离 PASS。下一步须另立定位任务，原任务预算不重置。
