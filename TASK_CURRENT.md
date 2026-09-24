# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-29-LOCAL-MARIADB-IMAGE-READ`

Risk Level: `LEVEL 2`（本地合成恢复演练依赖的精确镜像只读核验；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付受限事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 选择本机隔离恢复演练。AUTH-28 仅证明当次本机 Docker daemon 可达，未证明 MariaDB 镜像可用。本任务只在确认当前 Docker context 仍指向本机且 daemon 仍可达后，核对**精确标签** `mariadb:10.11` 是否已在本地。若不存在，记录缺口并停，不自动下载。镜像存在也不证明网络隔离、版本兼容或恢复能力。

## Exact read-only budget

1. `docker context inspect` 最多 1 次，只将当前端点归类为 `local_named_pipe`、`local_unix_socket`、`remote_or_other` 或 `UNKNOWN`；不输出或保存原始端点、路径、主机名或证书。若非确认本机，后两项 `NOT_CHECKED`，停止。
2. `docker info` 最多 1 次，只记录 `reachable`/`unreachable`/`UNKNOWN`；不可达则镜像项 `NOT_CHECKED`，停止。不启动或重启 Docker Desktop。
3. `docker image inspect mariadb:10.11` 最多 1 次，仅记录本地镜像 `present`/`absent`/`UNKNOWN`，不输出镜像元数据。不列出其他镜像、容器、卷或网络，不访问 registry、不拉取、不运行。

任何异常、不可安全解析或依赖失败均按上述停点记录，不换 context、镜像标签或方法，不重试。原始 stdout/stderr 仅在进程内处理，不显示或落盘。

## Allowed candidate and stop

唯一允许新增 `EVIDENCE/AUTH-29-LOCAL-MARIADB-IMAGE-READ/summary.md`，记录固定三项结果、实际调用次数、停点和不能据此建立的结论。若镜像 absent，下一步需另行决定是否从官方来源下载，不能本任务自行拉取；若 present，下一步只能另立虚构数据隔离测试，不接触真实备份。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-27/28 接受记录，核对 `main`、HEAD、工作区。派发前已接受基线为 `f1e392d847443daf51508ca7eff9164d8c029e77`；当前 HEAD 应为仅下达本任务的检查点，其父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、数据库、备份目录、凭据、密钥、真实数据或业务行。不创建/启动/删除容器/VM/卷/镜像，不备份、不传输、不恢复、不改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
