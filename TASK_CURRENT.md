# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-48-LOCAL-EXPLICIT-CONFIG-CMS-PROBE`

Risk Level: `LEVEL 2`（虚构证书显式配置与 CMS GCM 本机预检；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次虚构探针候选与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-47 在一次性虚构证书生成时退出 1，原始错误未留存，CMS 未运行；旧预算耗尽。Work 后续只读观察到本机 OpenSSL 3.5.6 报告默认配置目录 `C:\Program Files\Common Files\ssl`，该目录下未见 `openssl.cnf`；固定已安装配置文件 `C:\Users\zcxve\miniconda3\Library\ssl\openssl.cnf` 存在，SHA-256 为 `A65A2CB9F4EE8FFDC7EF4F0AC600C0BDAFB95B7B1AB457188AC610A62F5AD6B3`。这只是线索，不证明 AUTH-47 原因。本任务新授权一个虚构临时目录，在唯一证书生成调用中显式指定该固定配置文件；若成功再测试 CMS AES-256-GCM 正常解密与篡改拒绝。不得修改 OpenSSL 全局配置或降级算法。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-46～47 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD、工作区。当前 HEAD 应为仅下达本任务的检查点，父提交精确为 `cbf16cd9d39b8e96c023607539555474dd70ce15`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。
- 预检本机 `openssl` 可执行文件与版本 3.x；只读核对固定配置文件的路径、普通文件类型、非重解析点和上述 SHA-256。固定临时目录 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth48-synthetic-cms` 必须不存在，其父为当前用户本机 Temp、非重解析点；C 盘备份专用目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 仍为空。任一不符即停，不搜索替代配置或路径。
- 只在固定临时目录内生成一次性**无密码虚构** RSA 3072 私钥、自签收件证书、固定 UTF-8 输入 `AUTH48-SYNTHETIC-ONLY`、CMS DER 密文、正常解密与篡改副本。证书命令最多 1 次，较 AUTH-47 唯一预先指定的改动是给 `openssl req` 加 `-config C:\Users\zcxve\miniconda3\Library\ssl\openssl.cnf`；其余核心参数保持 RSA 3072、`-x509 -newkey -nodes -keyout -out -days 1 -subj`。若失败即停，安全记录退出码与 `CONFIG/PROVIDER/PATH/OTHER/UNKNOWN` 唯一类别（无法唯一分类则 UNKNOWN）；原始 stdout/stderr 不保存、不显示，不做另一证书尝试。
- 仅在证书 PASS 后，使用 `openssl cms -encrypt -binary -stream -outform DER -aes-256-gcm` 加密固定输入最多 1 次；配对私钥正常解密最多 1 次并严格比较固定字节；将密文副本的最后一个有效负载/认证字节翻转一次，篡改解密最多 1 次，要求非零退出且不得得到固定输入。任何失败即停，不换算法、工具、参数或重试；不能把证书 PASS 当作 CMS PASS。
- 输出只留固定阶段 `PASS/FAIL/NOT_CHECKED`、调用次数、OpenSSL 版本、固定配置哈希匹配布尔、密文长度整数、正常明文匹配和篡改拒绝布尔、安全退出码、首个失败及清理结果；不得保存/显示证书、私钥、密文、原文、原始 stdout/stderr、环境变量原文或敏感路径内容。总运行含清理不超过 120 秒。
- 结束时只对本次创建且规范化绝对路径仍严格等于上述固定临时目录、并经核对位于固定非重解析 Temp 父目录下的目录执行一次精确递归清理，再核对不存在；归属或路径不明则不删并报 `CLEANUP_UNRESOLVED`。不得清理其他目录，C 盘备份专用目录不写入。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-48-LOCAL-EXPLICIT-CONFIG-CMS-PROBE/run.ps1` 与同目录 `summary.md`；不得修改旧脚本、旧证据、控制文件或源码。先 PowerShell 静态解析和路径/清理边界检查，再最多执行 **1 次**；失败不得修改后重跑或手工补步骤。`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。Codex 不提交、制作 bundle、推送、自接受或派发后继。

不得访问旧 `D:\EliteSync`、SSH、浏览器、云 API、真实 DB、备份文件、真实凭据/密钥或业务数据；不安装软件、不生成真实备份密钥、不要求 Owner 密码、不做真实备份、传输、恢复或改库。虚构 PASS 也只证明本机当前 OpenSSL 形式可用，不证明服务器兼容、密码输入流程或真实数据可恢复。
