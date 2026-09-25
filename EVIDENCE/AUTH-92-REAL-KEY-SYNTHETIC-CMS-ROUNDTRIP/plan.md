# AUTH-92｜真实密钥与虚构标记 CMS 往返 Phase A 候选

状态：**仅 Phase A 脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行。** 本轮未运行脚本、OpenSSL CMS、逐字节比较或密码测试，未接收密码。

## 授权与受限预检

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `6c5f4575c8f5467133c3af2b489173994e43f2d0`；`TASK_CURRENT.md` 指向 `AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个原有无关未跟踪目录保留。
- AUTH-88 的私钥生成只获受限事实，AUTH-89 的文件 ACL 修复、AUTH-90 的一次 Owner 原生密码解锁、AUTH-91 的固定用途公有证书生成与公开元数据已获 Work LEVEL 3 受限 ACCEPT。它们不证明私钥与证书配对或 CMS 往返。
- 固定私钥 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`：预检为规范非重解析普通文件，2666 bytes；只读首行是加密 PKCS#8 标记；Owner 为当前用户，ACL 继承关闭，只有当前用户、SYSTEM、Administrators 三条显式 Allow FullControl。未读取私钥正文。
- 固定公有证书 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem`：规范非重解析 X.509 文件；公开 DER SHA-256 指纹 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461`，与 AUTH-91 一致。
- 固定 `C:\Program Files\Git\usr\bin\openssl.exe` 为规范非重解析普通文件，SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，匹配 AUTH-88。三个精确虚构临时目标在写入候选前均不存在。

## 唯一脚本与执行边界

候选是同目录 `owner-synthetic-cms-roundtrip.cmd`，SHA-256 `3F6680FE7894EA005436457065F91A1A6D94D58A4B7F9368A324755B4417497A`。固定标记 `AUTH92_SYNTHETIC_ONLY_20260925` 有 30 个 ASCII 字符；CMD `echo` 后预期为 32 bytes（CRLF），脚本核对长度。脚本先核对现有私钥、证书、程序及三个目标不存在。随后对固定公有证书只调用一次 `cms -encrypt -binary -aes-256-cbc -outform DER`；以同一证书和现有私钥只调用一次 `cms -decrypt -binary -inform DER`，Owner 只在 OpenSSL 原生非回显提示输入现有密码；`fc /b` 只比较一次，原始比较输出不展示或保存。

任一预检、写入、加密、解密或比较失败，脚本报告固定 `AUTH92_FAILURE=<类别>` 并停下，保留已形成的虚构临时文件供 Work 限定检查。仅在比较成功后逐个删除并核对三个精确临时文件不存在；清理中途失败报告 `AUTH92_FAILURE=CLEANUP_FAILED`，可能已经部分清理，不能视作完整成功。全部成功才报告 `AUTH92_ROUNDTRIP_MATCH_AND_CLEAN`。所有路径共用 `pause`，Owner 按键关闭窗口。

脚本没有密码参数、环境口令、口令文件、管道传密、输入重定向、转录或日志；私钥只作 `-inkey` 输入，不是任何输出文件。OpenSSL 自身提示或错误可能在 Owner 本机前台窗口出现，不进入本证据；Owner 只回报固定类别，不发送密码、截图或原始输出。`if exist` 与输出文件打开之间不是原子排他操作；Work 临运行前必须再次核对三个精确目标不存在，不能据此宣称绝对防覆盖。

## 静态检查与停点

纯文本静态检查结果：OpenSSL `cms -encrypt`、`cms -decrypt` 与 `fc /b` 各 **1** 处，`pause` **1** 处，所有 `goto` 目标存在；禁用参数/口令来源/重试关键词命中 **0**，尾随空白 **0**。目录中仅有本候选与本计划，三个临时目标仍不存在；原有无关未跟踪目录未动。写入和删除仅指向三个指定虚构文件，无算法回退。此检查只证明候选结构，不证明 CMD 实际运行、原生密码提示、公私钥配对或 CMS 兼容。Phase B 的 encrypt/decrypt/compare 预算均为 **0/1，未放行**。

Work 须独立核对候选与固定 OpenSSL 哈希、私钥/证书受限元数据、三个目标仍不存在、Owner 在场且无录屏/共享，才可决定是否放行 Owner 从 Explorer 双击一次。任何失败不重试，后续临时文件处置由 Work 限定决定。成功也仅可说明本机固定工具链与这对材料在本次虚构标记上的往返，不证明服务端、真实备份或恢复。

本轮不写 `E:`、真实备份目录或密钥目录，不连接服务器/DB/云/Docker/GitHub，不访问旧 `D:\EliteSync`；不提交、推送、自接受或派发后继，停在 Work LEVEL 3 Phase A 审查门。

## Work Phase A 预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 3 ACCEPT 脚本候选并放行一次 Owner 手动虚构 CMS 往返。** Work 逐行审查三条精确临时路径、30 字符固定 ASCII 标记及预期 CRLF 32 bytes、唯一 `cms -encrypt`/`cms -decrypt`/`fc /b` 各一处、每步失败即停、仅比较成功才删除本次三个精确虚构文件，清理失败不宣称成功。私钥只作 `-inkey` 输入；无私钥输出、口令参数、捕获、重试、网络或真实数据。独立核对本地 HEAD `6c5f4575c8f5467133c3af2b489173994e43f2d0`、CMD SHA-256 `3F6680FE7894EA005436457065F91A1A6D94D58A4B7F9368A324755B4417497A`、OpenSSL SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，私钥仍 2666 bytes 且 ACL 受限，证书公开指纹与 AUTH-91 一致，三个临时目标均不存在。审查前候选计划 SHA-256 为 `A2F7A35AA0251A32622C508001A9A5E23342DD80F9CD5DBFE7053EEE278DA927`。

临时目标的 `if exist` 与写入之间仍无原子排他保证；在固定任务目录、临运行不存在检查及无其他预期写者的边界下接受剩余竞争风险，不宣称绝对防覆盖。Owner 此前确认在电脑前、无录屏/共享且已在本机 OpenSSL 提示输入密码，无相反状态报告。仅放行从 Explorer 手动双击固定 CMD **一次**，只在原生非回显提示输入现有密码；若现场条件已变化、提示异常、密码回显或固定失败类别，停下且不重试。放行不等于实际配对或 CMS 验收。
