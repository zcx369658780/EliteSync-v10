# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-100-SYNTHETIC-OPENSSL-PROMPT-CHANNEL-DIAGNOSIS`

Risk Level: `LEVEL 2`（AUTH-99 高风险运行门所需的完全虚构本机工具行为诊断）

Status: `ISSUED — SYNTHETIC-ONLY LOCAL DIAGNOSIS`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 2 审查与后继任务发布。

## Objective and scope

确定本机固定 Git OpenSSL `C:\Program Files\Git\usr\bin\openssl.exe` 在 Windows PowerShell 5.1 中对**虚构密码保护私钥**请求密码时，提示究竟经哪个通道出现，以及 `2>$null` 和 `$ErrorActionPreference='Stop'` 的组合会否让 Owner 看不到提示或提前失败。只使用新生成、可丢弃的虚构测试材料；不访问或读取真实 C: 私钥、E: 或真实备份，不触发 UAC 或 BitLocker 查询。

允许在 `EVIDENCE/AUTH-100-SYNTHETIC-OPENSSL-PROMPT-CHANNEL-DIAGNOSIS/` 写脚本和有限 `summary.md`；固定虚构临时文件只放在仓库外 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth100-synthetic/`，创建前核对该精确目录不存在且父目录为非重解析本地目录。可生成一次 RSA 2048 虚构加密 PEM，使用固定无保密价值的测试口令 `AUTH100_SYNTHETIC_ONLY`，并用受限子进程比较：A. PowerShell 5.1 原生调用的标准错误正常流向；B. `2>$null`；C. `$ErrorActionPreference='Stop'` 对本机原生 stderr 的影响。必要时用重定向的标准输入提供**测试口令**，不得对 Owner 提示或记录任何真实密码。记录提示是否出现在各通道、退出类别、是否有意外截断；不保存完整 OpenSSL 错误或虚构私钥正文。结束后只删除本任务精确虚构临时文件与目录，并核对不存在；若测试失败，停止并保留虚构现场供 Work 审查，不扩大或重试。

执行前核对本地 `main`、HEAD、工作区、AUTH-99 REJECT 边界、OpenSSL 固定文件与哈希；预算为一次虚构密钥生成和最多三种有限调用各 1/1。结果若不确定，明确 `UNKNOWN`，不能凭猜测解除 AUTH-99 门。检查脚本没有 E:、真实私钥路径、UAC、BitLocker、网络、DB、云或用户密码通道。交付差异、有限测试回执与 `summary.md`，停在 Work LEVEL 2 独立审查；不提交、推送、自接受或派发后继。

禁止修改或访问真实密钥、U 盘和备份，访问旧 `D:\EliteSync`，连接服务器/DB/云/Docker/GitHub，或将任何真实敏感材料纳入 Git、Git bundle、证据或输出。保留无关工作区目录。
