# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-28-LOCAL-DOCKER-STARTUP-RECHECK`

Risk Level: `LEVEL 2`（本机现有 Docker Desktop 一次启动与只读复核；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付受限事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已选加密备份到自己的电脑或本地磁盘，并优先在本机独立环境验证恢复。AUTH-27 当次确认 Docker 上下文为本机命名管道但 daemon 不可达，未查镜像。本任务只尝试启动**已安装的** Docker Desktop 一次，并在短暂等待后只读复核 daemon 是否可达，为后续虚构数据隔离演练确定可行性。不安装、不更新、不登录、不接受新协议、不创建容器或下载镜像。

## Exact local budget and stop

1. 只检查固定路径 `C:\Program Files\Docker\Docker\Docker Desktop.exe` 是否为普通文件；不枚举其他路径。若不存在，记录 `desktop_binary=absent`，后续为 `NOT_CHECKED`，停止。不读取文件内容。
2. 若文件存在，先用 `Get-Process -Name 'Docker Desktop'` 最多一次只判断是否已有进程，不输出进程明细。已有进程则不启动；否则以固定当前 Docker 本机 context 为前提（AUTH-27），使用 `Start-Process` 对该固定程序**最多启动一次**，带 `-WindowStyle Hidden`，不传递秘密或用户数据。若需要管理员授权、更新、登录、安装组件、接受协议或安全权限，立即停下并记录待 Owner 手动处理，不自动确认。
3. 启动后外部等待总计不超过 **60 秒**，只调用 `docker info` 最多 **1 次**，只记录 daemon `reachable`/`unreachable`/`UNKNOWN`，不输出或保存 Docker 详情。若不可达即停，不重启、不换 context、不改设置、不运行 WSL。若可达，仍不查镜像或运行容器；留给后继任务。

任何异常只记 `UNKNOWN` 和对应停点，不重试、不扩大范围。若 Docker Desktop 已在运行，不重复启动，直接对现有本机端点执行一次复核；记录 `startup=already_running`。当前 daemon 状态可能随时间变化，不能将本任务结果当作永久状态。

## Allowed candidate and verification

唯一允许新增 `EVIDENCE/AUTH-28-LOCAL-DOCKER-STARTUP-RECHECK/summary.md`，只记固定程序存在性、是否启动/已运行、等待是否超限、daemon 固定结果、实际调用次数和未执行项。说明即便 daemon 可达，也不证明镜像、网络隔离、恢复能力或真实数据可安全存放。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能与 AUTH-26/27 接受记录，核对本地 `main`、HEAD、工作区。派发前已接受基线为 `4098e8980836969061db07a8f7c4a853d43c677e`；当前 HEAD 应为仅下达本任务的检查点，其父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、数据库、备份目录、凭据、密钥或真实数据。不创建/启动容器或 VM、不拉取镜像、不备份、不传输、不恢复、不删除、不改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
