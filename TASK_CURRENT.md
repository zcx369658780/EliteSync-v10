# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-37-LOCAL-SYNTHETIC-AUTH-READINESS-REPLAY`

Risk Level: `LEVEL 2`（Docker Engine 恢复后，冻结虚构认证探针的一次运行；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — BOUNDED DIAGNOSTIC FACT ONLY`

Assignee: `Codex`。只交付一次受限虚构探针回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：冻结脚本在新预算下的一次运行报告 20/40/60 秒认证均失败且安全码为 `1045`，容器精确清理 PASS；作为受限观察获 LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-37-LOCAL-SYNTHETIC-AUTH-READINESS-REPLAY/summary.md`。具体认证拒绝原因、dump/restore 与真实备份恢复均未建立。一次运行预算耗尽，后继须另立任务。

## Authority and objective

Owner 已亲自重启 Docker。Work 本次只读核对当前 Docker context 是本机命名管道，daemon 回应版本 `29.6.2`；这只证明该时点 Engine 可达。截图中停止的旧容器不是本任务依赖，不得启动。AUTH-35 的一次运行在 daemon 预检失败前停止，没有创建容器或执行认证；AUTH-36 的一次启动/复核预算也已耗尽。本任务**新授权一次**执行 AUTH-35 已审查的冻结脚本，观察新的单个本机隔离虚构容器中约 20/40/60 秒认证 `SELECT 1` 的安全结果。不修改旧脚本或重置旧预算，不接触真实数据库。

## Frozen source and exact execution

- 唯一可执行脚本为 `EVIDENCE/AUTH-35-LOCAL-SYNTHETIC-AUTH-READINESS-PROBE/run.ps1`，运行前只读核对 SHA-256 必须为 `30F45B511F9E81A3665BD15A4A9C732597C4EEF839227DD78EC9E900A59B623D`，且 PowerShell 静态解析无错误；不符即停，不修订或复制脚本。该冻结脚本已在 AUTH-35 Work 审查中核对固定本机 context/daemon/镜像/容器名预检、AUTH-32 解析器哈希、无网络/端口/宿主挂载的三个 tmpfs 隔离门、最多三次同形式认证只读 SQL、安全码白名单和按自身 ID 清理。其固定唯一容器名 `elitesync-auth35-auth-probe` 仅用于本次新预算；名称预检非空即停。
- 先核对当前 `main`、HEAD、工作区、任务单及固定脚本哈希；然后脚本最多执行 **1 次**。脚本内部每个预检、启动、隔离检查、探针、清理预算保持原样。执行失败、超时或未达到目标均不得修改脚本后重跑、换容器名/密码/客户端选项、手动执行其中命令或启动截图中其他旧容器。总运行含精确清理上限 120 秒；若清理 `FAILED/UNRESOLVED`，记录并停在 Work 门，不清理其他对象。
- 只允许新增 `EVIDENCE/AUTH-37-LOCAL-SYNTHETIC-AUTH-READINESS-REPLAY/summary.md`。回执只列固定阶段、三个时间点的 PASS/FAIL/NOT_CHECKED 与白名单数字码、调用次数、耗时和清理状态；不保存原始 stdout/stderr、Docker inspect/log、SQL 内容、密码、容器 ID、真实数据或 UI 截图。若无安全码或观察不足，保持 `UNKNOWN`。成功仅证明本次虚构认证在该时间点可用；不能推断 AUTH-33 原始 setup 原因、dump/restore 或真实数据库可恢复。

## Preconditions and stop

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～36 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `ef0cdcb736ddd1deb4ef5441704ff3d1ad5397f4`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不启动 Docker Desktop、不运行写 SQL、dump/restore、真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
