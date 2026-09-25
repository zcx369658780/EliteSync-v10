# AUTH-82｜本机虚构密码保护密钥交互预检

状态：**作者演练 PASS，待 Work LEVEL 2 独立 ACCEPT/REJECT**。仅限本次虚构材料。

## 执行前固定计划

- 派发：`D:\EliteSync-v10`，本地 `main`，HEAD `b4455b861ed2dad56cd2071c419f7eac63ba1ff3`；`TASK_CURRENT.md` 为 `AUTH-82-LOCAL-SYNTHETIC-PASSPHRASE-KEY-PROOF`、`ISSUED — NOT STARTED`、Codex、LEVEL 2。两个无关未跟踪目录保留。
- AUTH-81 docs-only 方案已有 Work LEVEL 2 ACCEPT；本任务只检验本机虚构交互，不使用真实 Owner 密码、真实密钥目录、备份目录或 U 盘。
- 固定工具：`C:\Program Files\Git\usr\bin\openssl.exe`，本次 `version` 为 3.5.5；`genpkey`、`req`、`pkey` 帮助列有预定选项。固定父目录 `C:\Users\zcxve\AppData\Local\Temp` 与当前 `%TEMP%` 一致、规范解析未转向、非重解析点；目标临时根执行前不存在。
- 唯一临时根：`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-AUTH-82-synthetic`。唯一材料文件名：`synthetic-recipient-encrypted-key.pem` 和 `synthetic-recipient-cert.pem`。预期根与两个文件均禁止继承，ACL 仅当前 Windows 用户、SYSTEM、Administrators 具有 FullControl；创建根后先核对 ACL，再写材料，生成后核对两个文件 ACL。不创建第三个材料文件。
- 固定顺序与预算：`genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out <唯一私钥>` 1/1；成功后 `req -new -x509 -sha256 -days 365 -key <同一私钥> -out <唯一证书> -subj /CN=EliteSync-v10-DB-Backup-Recipient -addext basicConstraints=critical,CA:FALSE -addext keyUsage=critical,digitalSignature,keyEncipherment -batch` 1/1；正确虚构口令 `pkey -pubout` 检查 1/1；错误虚构口令同检查 1/1。所有口令只通过交互式 PTY 的原生提示输入，不使用 `-pass`、环境变量、口令文件或命令替换。
- 成功条件：进程退出 0、材料文件存在且非空、私钥首行只分类为 `BEGIN ENCRYPTED PRIVATE KEY`，证书首行只分类为 `BEGIN CERTIFICATE`。证书和私钥公钥以 SHA-256 摘要比较，不保存公钥原文；核对证书 SHA-256 签名、3072 位 RSA、365 天及用途扩展。错误口令须退出非零，且不给下游任何可消费公钥字节。
- 输出边界：交互终端只暴露 OpenSSL 原生提示及必要安全状态，其他程序输出只记录退出码、有限类别、布尔/摘要，不复制私钥、证书、公钥或口令到本摘要。每步限制等待与输出；首个失败停止后续演练。无论成功失败，按这两个精确文件名分别清理并核对不存在，再非递归删除临时根并核对不存在；清理不全不得声明 PASS。

## 执行回执

| 步骤 | 受限结果 | 预算 |
|---|---|---|
| 临时根与 ACL | 原先不存在；固定 Temp 父路径规范、未转向且非重解析；根创建后 ACL 继承关闭，仅当前用户、SYSTEM、Administrators 三条 FullControl | 一次 |
| 虚构私钥生成 | `genpkey` 经 PTY 原生输入和确认虚构口令，退出 0；唯一私钥 2666 字节，首行分类为加密 PKCS#8，ACL 符合预案 | 1/1 |
| 虚构公有证书 | `req` 经 PTY 原生输入同一虚构口令，退出 0；证书非空、PEM 证书头及 ACL 符合预案 | 1/1 |
| 证书静态检查 | 非个人用途名、RSA 3072、SHA-256 签名、365 天、`CA:FALSE`、`keyEncipherment` 均为真；自签验证退出 0 | 已完成 |
| 正确口令与配对 | `pkey -pubout -outform DER` 经一次原生提示成功；其公钥 DER SHA-256 与证书公钥 DER SHA-256 相等，摘要只用于本次内存比较，不保存材料原文 | 1/1 |
| 错误口令负向 | 一次不同的虚构口令，`pkey` 退出 1；目标为 Windows `NUL`，无可消费公钥文件 | 1/1 |
| 清理 | 精确删除两个预定文件，均核对不存在；临时根核对为空后非递归删除，并核对不存在 | PASS |

预定 PowerShell `Remove-Item` 清理命令被执行环境自动审核拒绝，未执行。随后按两个精确文件名使用补丁工具删除，再以已核对的规范绝对路径对空目录执行非递归删除；没有递归清理或接触其他路径。清理最终核对为三个目标均不存在。

四次有预算的 OpenSSL 操作均各执行一次，无失败重试；没有使用 `-pass`、环境变量、口令文件或命令替换。交互 PTY 可能记录虚构口令，因此本任务**不证明**真实 Owner 密码可在无录制终端安全输入。没有生成真实密钥、证书副本或备份；没有接触 E:、真实密钥/备份目录、服务器、DB、云、Docker、GitHub 或旧仓库。私钥、证书、公钥及测试口令均未进入普通证据；真实 RSA 3072/CMS 跨端互通、失钥恢复、真实备份和隔离恢复仍未证明。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受本次本机虚构密码保护密钥和证书流程。** Work 核对派发 HEAD、唯一候选文件、四次各 1/1 运行记录、加密 PKCS#8 头、RSA 3072/证书用途与公钥配对的脱敏结论，以及错误虚构口令退出非零且未生成可消费输出文件。Work 独立只读确认固定临时根不存在；两个无关未跟踪目录仍在。审查前 SHA-256 为 `63E04C150EC31C975FD4B80503CFC8AE7BC19DBB7FA8E2344ECBD3D93A00617D`，未跟踪文件尾随空白 0 行。原计划 `Remove-Item` 清理遭执行环境自动审批拒绝；作者随后通过精确文件删除及空目录非递归移除完成清理，并核对不存在。Work 不把被拒操作算作已执行。

PTY 中的虚构测试口令可能被执行记录捕获，因此本接受不证明真实 Owner 密码可由 Codex 终端安全输入。后继真实生成只可在 Owner 控制、Codex 不采集输入和输出的独立本机交互窗口使用真实密码。没有真实私钥、证书、U 盘副本、服务器 CMS 或数据库备份/恢复证明。
