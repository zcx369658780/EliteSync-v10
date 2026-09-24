# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-50-LOCAL-SYNTHETIC-AUTHENTICATED-CONSUMER-GATE`

Risk Level: `LEVEL 2`（虚构 CMS 认证失败明文隔离与消费者零字节验证；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次本机虚构探针候选与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-48 本机虚构 CMS AES-256-GCM 正常解密成功，但篡改解密退出 4 时仍产生与原文相同的输出；完整任务被 Work 拒绝。AUTH-49 已接受 docs-only 合同：认证成功前不得让恢复消费者接收明文。Owner 已指定分离的 C 盘密文/密钥空目录及亲自输入密码、加密 U 盘恢复副本方向；本任务**不使用真实密码或目录中的数据**。新授权一次虚构探针，证明即使底层 OpenSSL 在篡改时输出原文字节，受限缓冲和退出码门也使下游消费者得到 0 字节。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-46～49 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD、工作区。当前 HEAD 应为仅下达本任务的检查点，父提交精确为 `fd667a7c50471348342e68a8735751c07a849a75`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。
- 预检本机 OpenSSL 3.x，可执行文件固定为当前解析路径；固定配置 `C:\Users\zcxve\miniconda3\Library\ssl\openssl.cnf` 是普通非重解析文件，SHA-256 `A65A2CB9F4EE8FFDC7EF4F0AC600C0BDAFB95B7B1AB457188AC610A62F5AD6B3`。固定临时目录 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth50-synthetic-gate` 不存在，父为本机非重解析 Temp；两个专用目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 与 `C:\Users\zcxve\EliteSync-v10-DB-Keys` 只读核对为空。任一不符即停。
- 只在固定临时目录生成一次性**无密码虚构** RSA 3072 私钥、自签证书、固定 UTF-8 字节 `AUTH50-SYNTHETIC-ONLY`、CMS DER 密文及篡改副本。证书生成用 AUTH-48 已观察成功的显式 `-config` 形式，每步最多 1 次。加密只用 `openssl cms -encrypt -binary -stream -outform DER -aes-256-gcm`，正常/篡改解密各最多 1 次。原始密文、证书、私钥和原文不得显示或写入备份/密钥专用目录、Git 或普通证据。
- 解密进程的 stdout 必须作为**字节**进入最多 65536 bytes 的受限内存缓冲，不能写主机持久文件或直接连接消费者；若超限、超时、进程非零退出或异常，清零/丢弃缓冲，消费者调用次数必须为 0。只有退出 0 且输出严格等于固定字节时，才把缓冲交给本脚本的**内存虚构消费者**一次，消费者仅记录收到字节数和固定内容匹配布尔；不得启动 Docker/数据库。若底层在篡改时输出与原文相同的字节，也必须仍记录消费者 0 字节。截断/篡改测试可选其一，本任务固定只做 AUTH-48 对应的单字节篡改，禁止额外变体或重试。
- 篡改副本固定翻转 CMS DER 末尾附近的一个有效负载/认证字节，不改变原密文；运行后记录解密退出码、是否出现缓冲字节布尔、消费者调用次数与字节数。完整 PASS 需要正常解密退出 0 且消费者收到精确固定字节，以及篡改解密非零退出且消费者调用 0、收到 0 字节、缓冲被清除；否则 FAIL。不得仅凭非零退出或文件哈希宣称通过。
- 输出仅保存固定阶段 `PASS/FAIL/NOT_CHECKED`、调用次数、OpenSSL 版本、固定配置哈希匹配、正常与篡改进程退出码、是否观察到暂存字节布尔、缓冲上限和清理布尔、消费者字节数/固定内容匹配、首个失败与临时目录清理结果。不得保存或显示原始 stdout/stderr、明文、密文、证书、私钥、密码或容器/数据库内容。总运行含清理不超过 120 秒。
- 结束时仅对本次创建、路径规范化后精确等于上述固定目录且仍位于非重解析 Temp 父目录内的临时目录执行一次递归清理，并核对不存在；归属或路径不明不删，报 `CLEANUP_UNRESOLVED`。不得清理其他目录或触碰备份/密钥目录内容。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-50-LOCAL-SYNTHETIC-AUTHENTICATED-CONSUMER-GATE/run.ps1` 与同目录 `summary.md`；不得改旧任务、控制文件或源码。先 PowerShell 静态解析、字节缓冲上限及路径清理边界检查，再最多运行 **1 次**；失败不修改后重跑或手动补步骤。`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。Codex 不提交、制作 bundle、推送、自接受或派发后继。

不得访问旧 `D:\EliteSync`、SSH、浏览器、云 API、真实 DB、真实备份/密钥/密码、账号/Token/消息/媒体或业务数据；不安装软件、不生成真实私钥、不要求 Owner 输入密码，不做真实备份、传输、恢复、删除或改库。虚构 PASS 只说明本机内存消费者门在固定样本下工作，不能证明服务器兼容、真实数据规模或真实恢复可用。
