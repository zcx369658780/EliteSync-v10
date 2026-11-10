# AUTH-17｜阿里云备份主机工具与空间一次只读核对

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `d38c5931f4eb082d5472d742ca231ba6ffa926e2`。类型：远端主机工具和 `/var/backups` 候选目录只读事实；未访问数据库。

## 前置门与一次远端读取

- 本地确认任务仍为 `ISSUED` 且指派 Codex；指定私钥及既有 `known_hosts` 均存在，仅检查存在，未读取内容。AUTH-10/14/16 接受记录保持各自的设计、CLI 账本和固定结构投影边界。
- SSH 进程 **1/1 次**：指定用户、主机和私钥；`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互，`-T` 禁用 PTY。唯一远端命令为 `command -v mysqldump && mysqldump --version && df -Pk /var/backups && test -d /var/backups && test -w /var/backups && printf 'AUTH17_OK\n'`。外部等待上限 20 秒，stdout/stderr 合计上限 16 KiB；没有追加命令或重试。
- 本次 SSH 退出码 **0**，stderr **0 bytes**，stdout **229 bytes**，未超时或超限。原始 stdout/stderr 仅在本地进程内接收，未保存或全文显示。stdout 经严格 UTF-8、固定五行结构、唯一末尾标记、版本号及 `df -Pk` 表头/数字格式检查后，只保留下列脱敏事实。

| 固定检查 | 当次观察 |
|---|---|
| `mysqldump` | 存在；报告版本号 `10.11.14` |
| `/var/backups` | 目录存在；当前 SSH 用户的 `test -w` 通过 |
| `/var/backups` 所在文件系统可用空间 | `27,151,868 KiB`（`df -Pk` 当次报告） |

未报告设备名、挂载点或完整工具路径。`/var/backups` 仅是候选，当前任务不授权在那里写入。可用空间不是数据库大小或完整备份可存放证明；工具存在和目录可写也不是备份、隔离恢复或生产数据库能力证明。目标 DB 实例、数据范围及备份可恢复性仍 `UNKNOWN`。

## 范围与停点

仅新增本 `summary.md`。`git diff --check` 按预算运行 **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。本文件另作只读检查，尾随空白 **0 行**；无 tracked 改动。未读取 `.env`、私钥内容、连接串、DB schema/行、账号、Token、日志或媒体；未执行 DB 命令、备份、导出、恢复、迁移、HTTP/API、设备或部署操作。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。实际备份、恢复演练、账号导出或结构变更须另立精确任务及 Owner 高风险门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受一次主机工具与候选目录的只读事实回执。** Work 核对发布基线 `d38c5931f4eb082d5472d742ca231ba6ffa926e2`、唯一新增路径和原候选 21 行无尾随空白。作者回执记载一次 SSH 运行任务所列精确只读命令，退出 0、stderr 0 字节、stdout 229 字节，并从受限输出中得到 `mysqldump` 版本号 `10.11.14`、`/var/backups` 存在且 `test -w` 通过、当次文件系统可用 `27,151,868 KiB`。Work 未再次连接服务器；原始 stdout 未保存，远端执行和解析细节依赖作者的一次性回执。

本接受不说明数据库大小或 dump 工具与实际服务端版本兼容，更不证明 `/var/backups` 可安全存放完整备份、备份已执行或能够恢复。目标数据库身份、数据范围、备份位置的权限/保留策略与隔离恢复目标仍需单独核定；AUTH-17 的 SSH 预算已耗尽。
