# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS`

Risk Level: `LEVEL 2`（真实私钥生成失败后的本机交互入口定位；只读/虚构，无真实密码）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex + Owner`，复用现有本地执行会话。Codex 仅做固定的无秘密窗口探针与脱敏记录；Owner 只报告是否看见窗口，不输入任何密码。Work 独立 LEVEL 2 审查。

## Authority and fixed boundary

AUTH-83 的真实生成目标已被 Work LEVEL 3 REJECT：经预运行审查放行的一次脚本启动父进程退出码 1，Owner 未见可报告的窗口失败类别，精确真实私钥文件不存在；旧启动预算已耗尽。原因、子窗口是否可见及是否进入 OpenSSL 均 `UNKNOWN`。本任务只定位 Windows PowerShell 独立可见窗口/控制台条件，不运行 AUTH-83 脚本、OpenSSL 或任何密钥操作，不要求 Owner 输入密码。

## One bounded result

1. 核对 `D:\EliteSync-v10` 本地 main、HEAD、工作区及 AUTH-83 接受的失败边界，保留两个无关未跟踪目录。只读核对固定真实私钥目标仍不存在；若出现则停止并升级 Work，不读内容。
2. 在唯一允许路径 `EVIDENCE/AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS/` 准备一个**无秘密、无写入目标目录**的 `probe.ps1`。它只在新窗口输出固定可见标记 `AUTH84_VISIBLE_PROBE`，检测 `UserInteractive`、`ConsoleHost`、三种 Console 重定向布尔，并以预定有限退出码传回类别；为 Owner 观察最多保持 15 秒。父进程仅记录退出码/固定类别，不捕获子窗口原始流。静态核对脚本没有 OpenSSL、`genpkey`、`pkey`、真实密钥路径写入、密码来源或删除命令。
3. 仅启动**一次**固定 Windows PowerShell 可见窗口探针，Owner 只报告是否实际看到固定标记或窗口（不发截图）。探针无密码、密钥、U 盘、服务器或 DB 操作。若窗口不可见、退出码异常或父/子状态矛盾，记录 `UNKNOWN` 并停，不改启动参数重试。窗口运行预算 **1/1**。
4. 将可见性、控制台布尔、父进程结果及 AUTH-83 可能原因的有限推断写入 `EVIDENCE/AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS/summary.md`，明确不能追溯证明 AUTH-83 子进程具体失败。作者停在 Work LEVEL 2 独立审查门，不提交/推送/自接受/派发后继。

禁止运行或修改 AUTH-83 `launch.ps1`，不得重试 AUTH-83 或生成/读取/删除真实或虚构密钥，不得写 E:、真实密钥/备份目录、连接服务器/真实 DB/云/Docker/GitHub 或访问旧 `D:\EliteSync`。若需要 Owner 从 Explorer 手动启动后继，只能在新任务中固定目标与停点。
