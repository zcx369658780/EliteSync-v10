# AUTH-99｜E: 私钥虚构 CMS 往返 Phase A 候选

状态：**仅可见入口与固定脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行。** 本轮未运行入口/脚本、UAC、BitLocker 查询或 OpenSSL 加解密，也未要求 Owner 输入密码。

## 授权与只读预检

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `3bc07e10dc156a1baa2550208d160e6fbe71cdae`；`TASK_CURRENT.md` 为 `AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY; NO RUN OR PASSWORD`、LEVEL 3。两个原有无关未跟踪目录保留。
- AUTH-92 只证明旧时点 C: 私钥对虚构标记的本机 CMS 往返；AUTH-95 只证明旧时点 E: 保护状态；AUTH-97 只证明两份 E: 加密恢复副本与本机源字节相等；AUTH-98 获 Work LEVEL 3 ACCEPT 的 A/B/C 方案仅为设计输入。这些旧预算均不转为 AUTH-99 的运行许可。
- 本轮只读 E: 身份门通过：唯一 `Kingston DataTraveler Duo` USB Removable、25～35 GiB、分区/卷映射唯一。精确 `E:\elitesync-v10-db-backup-recipient-20260925.key.pem` 是非重解析普通文件、2666 bytes，仅读加密 PKCS#8 首行；同前缀 `.cert.pem` 是非重解析普通文件、1541 bytes，公开 DER SHA-256 指纹与 AUTH-91 的 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461` 一致。没有计算或输出私钥哈希、读取私钥正文或枚举 U 盘目录。本轮**没有查询当前 BitLocker 状态**。
- 固定 `C:\Program Files\Git\usr\bin\openssl.exe` 为非重解析普通文件，SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，与 AUTH-88 固定值相符；`C:\Windows\System32\fc.exe` 存在。
- 三个虚构临时目标仅在已有的 `C:\Users\zcxve\AppData\Local\Temp` 下，分别为 `elitesync-auth99-synthetic-marker.txt`、`elitesync-auth99-synthetic-cms.der`、`elitesync-auth99-synthetic-decrypted-marker.txt`。本轮只读核对该目录存在且非重解析、三个精确目标均不存在；该目录不在 E:、真实备份目录或 Git 仓库内。没有创建临时文件。

## 候选控制流

本目录仅有 `owner-visible-usb-cms-entry.cmd` 与 `owner-usb-cms-roundtrip.ps1` 两个执行候选，以及本计划。CMD SHA-256 为 `BFA0BDC1CBAD9E26206BF2E18A1A3970E533C23D7C4065A2EBF12EDA6EFFA604`；PowerShell SHA-256 为 `04727B2C060017A6091C5FCF157A21CFC2F62EDA6C232A45CDBC5A23FE946B8F`。Owner 只在 Work 放行且本人到场时从 Explorer 双击 CMD **一次**。入口先静默核对固定 PS 文件非重解析及 SHA-256，失败则显示有限类别并停在可见窗口；通过后在同一窗口只调用固定 PS 脚本一次，显示其有限结果和退出码，所有分支最终等待 Owner 按键关闭。

PS 主进程先核对自身路径、E: 唯一身份、仓库外临时目录与三个目标不存在、固定 OpenSSL 身份，然后只启动一次隐藏的提权**只读子过程**供 Owner 核对 Windows PowerShell UAC。子过程再核对 E: 身份，唯一一次 `Get-BitLockerVolume -MountPoint 'E:'` 必须取得唯一对象并满足 `Unlocked/On/FullyEncrypted/100`，之后才读取 E: 私钥的加密 PEM 首行及公有证书公开指纹。任何失败返回有限类别，主进程不进入 OpenSSL。成功后主进程再核对 E:、两精确文件、OpenSSL 与临时目标，才在本地 Temp 用排他创建写入固定 30 字符 ASCII `AUTH99_USB_KEY_A_ONLY_20260925` 加 CRLF（32 bytes）。

主进程仅一次运行固定 OpenSSL `cms -encrypt -binary -aes-256-cbc -outform DER`，收件人证书仅为 E: 同前缀证书；再仅一次运行 `cms -decrypt -binary -inform DER`，`-recip` 同一 E: 证书且**唯一 `-inkey` 是字面绝对路径 `E:\elitesync-v10-db-backup-recipient-20260925.key.pem`**。脚本文本不含 C: 私钥路径、候选列表、通配符或回退分支。Owner 只能在 OpenSSL 本机原生非回显提示输入现有私钥密码；脚本不接收、存储、传递密码，不使用 `-passin`、环境变量、口令文件、管道或输入重定向。只有加密、解密分别退出 0 且目标出现，才用一次固定 `fc /b` 逐字节比较两个虚构标记文件。

仅在比较退出 0 后，脚本逐一删除并核对上述**三个精确虚构临时文件**不存在，才返回 `A_MATCH_AND_CLEAN`。任一早期失败立刻停下并保留可能生成的虚构临时文件，供 Work 另行限定检查；清理中途失败可能已形成部分清理，不宣称完整成功，也绝不删除或改写 E: 的私钥/证书。OpenSSL 的标准输出与标准错误在候选中均被抑制，证据只允许固定类别及退出码，不保存原始错误、私钥正文、密码或私钥哈希。

## 静态检查、交互风险与停点

- Windows PowerShell 5.1 语法解析错误 **0**；固定 BitLocker 查询 **1** 处、CMS encrypt/decrypt 各 **1** 处、字面 E: `-inkey` **1** 处、C: 私钥路径 **0** 处、`fc /b` **1** 处。成功清理只循环三个字面固定虚构路径。CMD 中固定脚本哈希检查 **1**、`-File` 调用 **1**、`pause` **1**，所有跳转标签存在，尾随空白 **0**。没有网络、真实备份或数据库读写、BitLocker 修改、密码参数或日志路径。
- **预运行必须裁决的提示通道风险：**为满足“不回显 OpenSSL 原始错误”，候选把 decrypt 的标准错误重定向到空输出；OpenSSL 原生密码提示是否仍可见，单靠静态检查不能证明。Work 若不能在不动用本任务真实预算的受限无秘密方法中建立提示可见性，应拒绝此候选并另立修订门，不能让 Owner 在看不到原生提示时盲输密码，也不能临场移除错误抑制或改用 `-passin`。本轮未作任何提示试跑。
- E: 身份/保护查询与随后文件读取不是不可分割事务，三个临时目标的不存在检查与 OpenSSL 输出打开也不是原子排他操作。排他创建只覆盖标记文件；Work 须在放行前裁决这些剩余并发风险并重新核对固定路径。任何目标已存在、设备或状态不符、UAC 未确认、原生提示异常、命令非零、比较失败或清理不全均停止，不换目录、证书、算法、密钥或重试。

Phase B 的 Owner 手动启动、提权查询、encrypt、decrypt、compare 各预算 **0/1，均未放行**。成功后也仅可证明本机本次从 E: 加密私钥副本对固定虚构标记的 CMS 往返；不能证明本机源私钥物理丢失、B 重插密码解锁、C 纸质 BitLocker 恢复密钥、真实数据库备份或恢复。Work 须独立复核有限回执、三临时目标清理及 E: 副本有限元数据后作 LEVEL 3 ACCEPT/REJECT。本轮不提交、推送、自接受或派发后继。

## Work LEVEL 3 Phase A 独立审查（2026-09-25）

**REJECT 当前脚本作为 Owner 可运行候选；Phase B 不放行。** Work 逐行核对 CMD/PS1 控制流：固定 E: 私钥唯一 `-inkey`、固定证书、单次 BitLocker 查询、固定虚构临时目标与成功清理等静态边界成立；入口和脚本哈希分别为 `BFA0BDC1CBAD9E26206BF2E18A1A3970E533C23D7C4065A2EBF12EDA6EFFA604`、`04727B2C060017A6091C5FCF157A21CFC2F62EDA6C232A45CDBC5A23FE946B8F`。审查前 plan SHA-256 `02E9D1E56EDC2D6D9631035BC9E6332964EDC2102B98627CD5452D0ACF5DB5CA`。候选未运行，真实启动/UAC/BitLocker/OpenSSL 预算均 0/1。

阻断点在 `cms -decrypt` 后的 `2>$null`：OpenSSL 原生私钥密码提示通常使用标准错误通道。静态审查不能证明 Owner 可看见提示，当前脚本可能把提示一并隐藏，Owner 不能盲输密码；且 Windows PowerShell 5.1 对原生标准错误和终止行为需明确处理。另有固定 Temp 输出目标在不存在检查与 OpenSSL 打开之间的并发覆盖余量，后继修订应收紧。先另立完全虚构的提示通道诊断，查明本机 OpenSSL/PowerShell 交互表现，再重新制作候选。不得在 AUTH-99 内为诊断运行真实脚本、移除抑制后临场尝试或借用旧预算。无关未跟踪内容保留。
