# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-40-LOCAL-SYNTHETIC-TABLE-FAILURE-DIAGNOSIS`

Risk Level: `LEVEL 2`（本机隔离虚构建表失败的安全码与单变量诊断；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次虚构容器诊断候选与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-39 的本机虚构运行在源 schema 创建之后、原 `CREATE TABLE` 命令处失败；stderr 未保存，具体原因 `UNKNOWN`，插入与 dump/restore 未运行，旧预算已耗尽。本任务**新授权一个**无网络虚构容器，复现该固定建表 SQL 一次并仅提取安全数字错误码。只有唯一识别为 MariaDB 语法错误 `1064` 时，才在同一虚构 schema 中试一次只把字段名 `label` 改成 `item_text` 的对照建表。此结果只定位小样本建表阶段，不处理真实数据库、不运行 dump/restore。

## Exact execution boundary

- 预检 Docker context 本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth40-table-probe` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据/运行/临时目录仅用 `/var/lib/mysql`、`/run/mysqld`、`/tmp` 三个 tmpfs；容器初始化密码只用本任务虚构值。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 与经 AUTH-32 解析后的 Mounts；任一安全字段未知或不符即停。不启动截图中的旧容器或项目服务。
- 隔离通过后等待到本次容器启动至少 45 秒，以不传密码的本机 socket `mariadb -uroot` 各最多一次执行 `SELECT 1` 与 `CREATE DATABASE auth40_source`；任一失败即停。随后仅一次执行 AUTH-39 原 SQL 的等价版本：`CREATE TABLE sample_items (id INT PRIMARY KEY, label VARCHAR(32) NOT NULL, amount INT NOT NULL);`，目标为 `auth40_source`。若 PASS，记录并停止，不继续建第二张表；若失败，只在内存解析唯一 `ERROR <数字>`，输出仅限白名单 `1064`、`1005`、`1030`、`1114`、`1044`、`1049`、`1142`、`1050` 或 `UNRECOGNIZED/UNKNOWN`，不保存原始错误。只有安全码唯一为 `1064` 时才尝试一次 `CREATE TABLE sample_items (id INT PRIMARY KEY, item_text VARCHAR(32) NOT NULL, amount INT NOT NULL);`，其他情况不试。对照步骤也只记录 PASS/FAIL 与同一白名单安全码，不再重试。
- 不插入任何行、不运行 dump/restore。原始 stdout/stderr、虚构密码、环境变量、进程参数、容器 inspect/log、SQL 输出和容器 ID 均不得保存或显示。无论结果，只对本任务确实创建且归属可验证的容器按 ID 精确清理最多一次，再按固定名称只读核对不存在；归属不明不删除，报 `CLEANUP_UNRESOLVED`。不得操作其他容器/卷/镜像或 broad prune。总运行含清理不超过 150 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-40-LOCAL-SYNTHETIC-TABLE-FAILURE-DIAGNOSIS/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～39 或控制文件。先 PowerShell 静态解析和安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑、不手动补命令。摘要列固定阶段 PASS/FAIL/NOT_CHECKED、安全码、调用次数、耗时、隔离声明和清理结果。若对照建表 PASS，只说明本次虚构容器里这个字段名变更与成功同时出现，不单凭一次对照推断 AUTH-39 的唯一根因或真实 DB 规则。Work 独立审查，作者结果不自接受；任何后继需新任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～39 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `41764d7935838f1bf0f5340f2b009820c060b6f3`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
