# AUTH-23｜阿里云备份主机三项命令存在性一次只读观察

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `1c72bada811caedd8f3acbc90ad808faf4142cb9`。类型：当前部署主机 shell 对三个固定命令名的解析结果；没有运行这些工具或云 API。

## 前置门与一次远端读取

- 核对本任务仍为 `ISSUED` 且指派 Codex；本地 `main`、HEAD 与工作区符合派发。指定私钥及既有 `known_hosts` 均存在，仅检查存在，未读取内容。只读核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能及 AUTH-17/18/20/22 接受回执。
- SSH 进程 **1/1 次**：指定用户、主机及私钥；`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互，`-T` 禁用 PTY。唯一远端命令只依次以 `command -v` 检查 `ossutil`、`aliyun`、`openssl`，各自结果仅通过固定 `printf` 行输出；`command -v` 结果路径重定向丢弃。没有调用三个工具本身。外部等待上限 30 秒，stdout/stderr 合计上限 8 KiB。
- 本次 SSH 退出码 **0**，stderr **0 bytes**，stdout **45 bytes**，未超时或超限。原始 stdout/stderr 仅在本地进程内接收，未保存或全文显示；stdout 严格匹配固定顺序的三行 `present/absent`，无其他输出。

| 固定命令名 | 当次 `command -v` 结果 |
|---|---|
| `ossutil` | `absent` |
| `aliyun` | `absent` |
| `openssl` | `present` |

`absent` 仅表示当前 shell 的命令解析未找到该名称；不证明主机没有其他安装方式，更不证明阿里云私有 OSS、受管密钥或账户资源不可用。`present` 也不证明工具版本、配置、权限或加密能力。Owner 选择的私有 OSS/受管密钥优先核验、阿里云内隔离恢复和 30 天保留仍是后继设计方向；本观察不证明 bucket、密钥权限、备份上传、生命周期或隔离恢复可用。若需实际资源与权限核验，须另立精确任务和输出白名单。

## 范围与停点

仅新增本 `summary.md`。`git diff --check` 按预算运行 **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。本文件另作只读检查，尾随空白 **0 行**；无 tracked 改动。未读取 `.env`、私钥内容、云配置、环境变量、真实配置值、账号/Token/日志/媒体、文件清单或业务数据行；未运行云 API、HTTP/API、数据库操作、备份、导出、恢复、migration 或部署。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本次主机 shell 三个命令名的存在性事实回执。** Work 核对基线 `1c72bada811caedd8f3acbc90ad808faf4142cb9`、唯一候选路径、原文 21 行及 0 行尾随空白。回执中的固定三行总长度与所报 stdout 45 bytes 一致；作者报告一次 SSH 退出 0、stderr 0 bytes、固定格式解析通过，`ossutil=absent`、`aliyun=absent`、`openssl=present`。Work 未再次连接服务器，远端原始输出未保存；远端执行细节依赖作者的一次性回执。

此接受不证明 OSS/KMS 账户资源、权限、bucket、密钥、30 天生命周期或隔离恢复环境是否存在。主机没有解析到两个 CLI 名称，也不排除其他调用方式；不得据此安装工具、调用云 API、备份或改库。后继实际资源核验须有单独范围和访问入口。
