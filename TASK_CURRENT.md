# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-30-LOCAL-SYNTHETIC-RESTORE-PROOF`

Risk Level: `LEVEL 2`（本机容器隔离与虚构 MariaDB dump/restore 测试；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付虚构数据候选与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已决定完整数据库备份加密保存到自己的电脑/本地磁盘，恢复演练优先在本机独立环境，先核验安全隔离与恢复能力。AUTH-29 仅确认本机 daemon 当次可达、`mariadb:10.11` 标签存在。本任务只用**完全虚构的数据库、表与少量固定行**验证在单个本机临时容器内可 dump、导入到另一个虚构 schema 并核对内容，同时验证容器声明的无网络、无宿主挂载/端口。它不接触阿里云、项目真实 DB、真实账号或任何现有备份；成功也不证明生产库可恢复。

## Exact local execution scope

- 只使用本机当前 Docker context；执行前只读确认端点仍为本机、daemon 可达、固定本地镜像标签存在。任一不符即停，不启动 Docker Desktop、不换 context、不拉取镜像。
- 唯一允许创建的容器名：`elitesync-auth30-synthetic-restore`。先确认该名称不存在；若已存在即停，不覆盖或删除既有容器。启动**最多一次**，镜像固定 `mariadb:10.11`，`--pull never`、`--network none`、不发布端口、不挂载宿主目录或命名卷。数据目录、运行目录和临时目录仅用容器内 tmpfs；不得把容器数据导出到宿主机。仅用虚构凭据，避免与任何真实密码相似或复用。
- 仅在刚创建的容器内建立固定虚构 schema/table/少量行，执行一次 dump，导入第二个虚构 schema，核对行数及固定内容校验。检查 Docker HostConfig 的网络模式为 `none`、无 bind mounts、无 published ports；检查失败即停止测试并清理本任务刚创建的容器。不得访问宿主文件、真实配置或网络。
- 不论成功失败，在 `finally` 中仅对**本任务确实创建的同名容器**进行精确清理，最多一次；随后只读核对容器不存在。清理失败必须报告 `CLEANUP_FAILED`、停止，不对其他容器/镜像/卷做操作。不得使用 Docker 广泛 prune/clean/reset。所有执行步骤和清理均最多一次，不因失败重试。
- 总运行等待上限 120 秒。只在证据中保存固定布尔/计数/校验状态、阶段和最早失败；不保存数据库 dump、容器日志、原始 stdout/stderr、镜像元数据、凭据或虚构行内容。任何超时、状态不符或输出不可安全解析即停。

## Allowed candidate and verification

只允许新增 `EVIDENCE/AUTH-30-LOCAL-SYNTHETIC-RESTORE-PROOF/run.ps1` 与同目录 `summary.md`。脚本必须固定容器名、镜像、虚构数据和输出白名单，具有失败即停与精确清理；先静态检查脚本，再执行最多 1 次。回执写清预检、启动、隔离声明检查、虚构 dump/restore、校验、清理每阶段的 PASS/FAIL/NOT_CHECKED，明确测试限制。若脚本不能安全满足所有边界，不运行而交付原因，不为通过测试扩大权限。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-27/28/29 接受记录；核对 `main`、HEAD、工作区。派发前已接受基线 `84e709575f2c4bf9d82a2e46af480fd784be1af5`；当前 HEAD 应为仅下达本任务的检查点，父提交须为基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，对新文件另作只读尾随空白检查；无需 Flutter/Laravel 产品测试或构建。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实数据库、备份目录、凭据、密钥、账号/Token/消息/媒体或业务数据行。不安装软件、不拉取镜像、不修改项目源码、不提交、不制作 bundle、不推送、不自接受或派发后继。实际本地加密备份与真实恢复仍须独立 Owner 高风险门。
