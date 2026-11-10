# AUTH-83｜真实加密私钥运行器 Phase A 候选

状态：**仅脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行**。本轮没有启动脚本或可见窗口，没有生成真实私钥或要求 Owner 输入密码。

## 本地边界与只读核对

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `77f3af31746344fa7c0df01b0893e155379c858b`；任务单为 `AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个无关未跟踪目录原样保留。
- 固定目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 当次不存在；`C:\`、`C:\Users`、`C:\Users\zcxve`、固定密钥目录均为规范、非重解析目录。密钥目录所有者为当前 Windows 用户，ACL 禁止继承，仅当前用户、SYSTEM、Administrators 三个主体各一条显式 FullControl，无拒绝 ACE。
- 当次 Windows 配置来源中，HKLM SyncRootManager 的两个可规范化同步根均不覆盖固定目标；当前进程 OneDrive 环境变量、HKCU OneDrive Accounts 的 `UserFolder` 及 HKCU SyncRootManager 未给出额外可用根。这只是已观察配置来源，不是所有第三方同步或设备备份软件的全局排除证明。Owner 的密钥和备份不使用云同步声明另行成立。
- 固定 `C:\Program Files\Git\usr\bin\openssl.exe` 为规范、非重解析文件；本次 `version` 为 OpenSSL 3.5.5。独立窗口程序 `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` 存在，当前本地脚本执行策略为 RemoteSigned。

## 候选运行方式与一次性预算

唯一脚本为同目录 `launch.ps1`。它的入口先核对 `TASK_CURRENT.md` 的精确状态行必须为 ``Status: `ISSUED — PHASE B RELEASED` ``；Work 若批准 Phase B，须在任务单中写入这一精确状态并核对脚本哈希、独立可见窗口和 Owner 无录制/共享条件。当前 Phase A 状态不会通过脚本门。Codex 未来仅能启动脚本一次；脚本以 `Start-Process` 打开独立可见 Windows PowerShell 5.1 窗口，并等待该子进程。子窗口不重定向 stdin/stdout/stderr，脚本不启用 transcript、日志或密码参数/变量；Codex 仅能得到子进程退出码，不能采集 Owner 在子窗口的密码或 OpenSSL 原始流。Owner 本人确认无录制/共享，亲自在原生提示输入并确认密码，另行写好分开保管的纸质副本。

子窗口写入前重新核对目录及父路径、目标不存在、目录 ACL、脚本/任务/固定 OpenSSL 路径，并要求交互式未重定向 ConsoleHost。随后仅调用一次 `genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out <精确目标>`，预算 **1/1**；不使用 `-pass`、环境变量、口令文件、输入重定向或 Codex PTY。生成退出 0 后才检查文件存在、长度非零、显式受限 ACL 和加密 PKCS#8 首行布尔。只有以上均通过，才调用一次 `pkey -in <精确目标> -noout`，由 Owner 再次在原生提示输入密码，预算 **1/1**。脚本只向可见窗口输出有限退出码、布尔和失败类别；不写普通日志或结果文件。

首个失败立即终止后续步骤。若生成失败或校验失败且目标文件存在，脚本保留受限目录及文件，绝不自动删除、重试、换路径/算法或产生无密码私钥；Work 再决定精确处置。作者不把脚本的 PASS 当成 Work 接受。本次只做 Phase A 语法、静态安全和路径检查；Phase B 的启动命令和真实一次预算均 **0/1 未消耗**。本任务不创建证书或 U 盘副本，不连接服务器、DB、云、Docker、GitHub 或旧 `D:\EliteSync`，不提交、推送或派发后继。

## Phase A 检查

本次只调用 PowerShell AST 解析器读取脚本，**0 个解析错误**；静态检查为 `Start-Process` 1 处，`Start-Transcript`/`Read-Host`/删除命令均 0，`-pass` 选项、`$env:` 引用及输入重定向均未发现。固定目标再次核对为不存在。`launch.ps1` SHA-256：`ED3DCD63A3DC4B50EE32C1763BA47C2BD0569A9514C06D07E3372B0260692F20`。这些是语法/文本检查，不证明窗口实际可见、系统录制状态或真实交互安全；脚本和窗口均未运行。

## Work Phase A 预运行审查与放行（2026-09-25）

**ACCEPT 脚本候选，放行本任务 Phase B 的单次可见窗口执行。** Work 逐项阅读 `launch.ps1`：固定绝对路径、任务精确状态门、写入前目录/ACL/目标不存在检查、独立可见 PowerShell 子窗口、未重定向的 ConsoleHost、OpenSSL 原生密码提示、一次 `genpkey` 与一次 `pkey -noout`、失败即停且不自动删真实材料。脚本没有真实密码来源、`-pass`、环境变量取密、转录或向 Codex 回传子窗口流；父进程仅回传子进程退出码。Work 独立 AST 解析为 0 错误，SHA-256 与作者值一致，当前精确私钥目标仍不存在；本机密钥目录 ACL 当次为三条显式 FullControl、继承关闭、Owner 为当前用户。

Owner 已在 Work 会话确认人在电脑前、没有录屏/共享屏幕、纸张已准备好，并已决定私钥密码纸质副本与电脑/U 盘分开放置。Work 只读核对 HKLM/HKCU 的 Windows PowerShell Transcription 策略键均未配置；这不排除其他系统级或第三方采集。基于独立可见窗口不由 Codex 捕获及 Owner 的现场确认，本轮仅放行一次固定脚本的真实私钥生成和一次原生提示解锁检查；若窗口、提示、目标或口令记录方式异常，Owner/Codex 立即停止。Work 放行不等于生成成功或最终 LEVEL 3 接受。
