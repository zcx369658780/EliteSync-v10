# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-59-LOCAL-SYNTHETIC-FD-CMS-FAILURE-DIAGNOSIS`

Risk Level: `LEVEL 2`（本机虚构 fd/CMS 失败分阶段定位；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — X509 FD FAILED; CMS NOT CHECKED`

Assignee: `Codex`。只交付一次有界本机虚构诊断脚本与脱敏回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：本机虚构证书生成及 Git Bash fd 3 字节读回 PASS；OpenSSL `x509` 从 `/dev/fd/3` 读取退出 1，脱敏类别 `OTHER`、根因 `UNKNOWN`，CMS 加密未执行，完整分阶段目标 LEVEL 2 REJECT。固定临时目录清理获受限事实接受，见 `EVIDENCE/AUTH-59-LOCAL-SYNTHETIC-FD-CMS-FAILURE-DIAGNOSIS/summary.md`。旧本地 1/1 预算已耗尽。

## Authority and objective

AUTH-58 本机虚构证书生成成功，但 Git Bash/OpenSSL fd CMS 加密退出 1；原始 stderr 未保存，原因 `UNKNOWN`，本机与服务器无落盘路径均未建立，旧 1/1 预算耗尽。Owner 已授权沿路线图继续。此任务仅通过新的本机一次性虚构证书，分开观察 **Git Bash fd 3 可读、OpenSSL 从 fd 3 读证书、CMS 固定虚构加密** 三个阶段，记录脱敏退出码与安全错误类别；不连接服务器、不修改真实数据。U 盘与 Owner 密码不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-48/49/50/57/58 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-59-LOCAL-SYNTHETIC-FD-CMS-FAILURE-DIAGNOSIS/run.ps1`、`summary.md`。先静态核对 PowerShell 语法、固定命令、进程限量采集、失败分类、固定临时路径与精确清理；不得改源码、旧证据或控制文件。
- 固定虚构输入仍为 ASCII `AUTH57-SYNTHETIC-001\n`（21 字节）。只在 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth59-fd-cms-diagnosis` 存放本次一次性无密码虚构证书/私钥；创建前核对规范化绝对路径、非重解析父目录、目标原先不存在，结束时只清理本次精确目录并核对不存在。证书与私钥不得进入真实备份/密钥目录、Git、聊天或普通回执。
- 单次本地运行最多 1/1。证书生成成功后，按依赖顺序各至多执行一次：① Git Bash 内 fd 3 的固定公有证书字节可读性/长度或摘要核对；② Git Bash OpenSSL `x509` 从 `/dev/fd/3` 接受同一虚构证书；③ 若前两门 PASS，尝试 AUTH-58 固定 21 字节的 `cms -encrypt -aes-256-gcm` fd 证书输入并只把 DER 密文暂存在有上限内存。前一门 FAIL 则后续 `NOT_CHECKED`。不做解密、不改变目标为普通临时文件、不增加命令变体或重试。
- stdout/stderr 只在本机内存有上限采集；不得显示或保存原始证书、私钥、明文、密文、stderr 或路径清单。错误只可分类为预先列明的 `FD_UNREADABLE`、`CERT_PARSE`、`CMS_OPTION_OR_RECIPIENT`、`OTHER`、`UNKNOWN`，不得把非零退出单独定为根因。回执只保存阶段 `PASS/FAIL/NOT_CHECKED`、退出码、脱敏类别、固定长度/匹配布尔、首个失败、清理状态。所有失败即停，内存缓冲清零。
- `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。不得运行 Docker/WSL 容器、SSH、CloudShell、云 API、数据库或真实备份/恢复；不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、U 盘、Owner 密码或业务数据。

## Stop and review

即使本机三阶段 PASS，也只证明本机虚构路径，不证明服务器 OpenSSL 3.0.13 可行、跨端 CMS 互通或真实备份恢复。旧 AUTH-58 结果不追溯改写。Codex 不提交、制作 bundle、推送、自接受或派发后继；一次运行后停在 Work LEVEL 2 独立门，后继服务器动作须新任务。
