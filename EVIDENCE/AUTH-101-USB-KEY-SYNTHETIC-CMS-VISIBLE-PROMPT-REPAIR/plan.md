# AUTH-101｜E: 加密私钥副本虚构 CMS 往返可见提示修订候选

**状态：Phase A 候选，待 Work LEVEL 3 预运行审查；Phase B 未放行。** 本轮没有运行本目录入口或保护脚本，没有 UAC、BitLocker 查询、OpenSSL 加解密、密码输入或临时文件创建。

## 授权与只读预检

- 本地 `D:\EliteSync-v10`，`main`，启动 HEAD `db00067903df62a076356e96a6ad0ce6b13a4dbd`；`TASK_CURRENT.md` 为 `AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR`、`ISSUED — PHASE A REVISED CANDIDATE ONLY; NO RUN OR PASSWORD`、LEVEL 3，交 Codex 准备候选。
- AUTH-92 经 Work LEVEL 3 接受的是 Owner 前台 CMD 原生 OpenSSL 提示下的本机虚构 CMS 成功分支；AUTH-97 接受 E: 固定加密私钥和公有证书恢复副本的本次字节身份。AUTH-99 因 `2>$null` 可能隐藏原生提示而 REJECT、不得运行。AUTH-100 仅接受虚构观察 A/C 的提示在 stderr、B 抑制提示；三次无人机调用非零且有失败即停偏差。这些非零调用不能否定 AUTH-92 的 Owner 原生窗口成功，也不预判 AUTH-101 会成功。
- 当前只读核对 E: 为唯一 `Kingston DataTraveler Duo` USB Removable，28.82 GiB，E: 分区/卷唯一对应；两精确副本是非重解析普通文件，私钥 2666 bytes、公有证书 1541 bytes。仅读加密 PKCS#8 首行；公有证书 DER SHA-256 指纹 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461`，与 AUTH-91 固定值一致。未读私钥正文或计算私钥哈希。本轮未查询当前 BitLocker 状态。
- 固定 `C:\Program Files\Git\usr\bin\openssl.exe` 是非重解析普通文件，SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`；任务专用 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth101-synthetic` 运行前不存在。

## 候选控制流

- `owner-visible-usb-cms-entry.cmd` 供 Work 放行后 Owner 从 Explorer **单次双击**。它在前台窗口核对固定 `usb-preflight.ps1` 非重解析普通文件与 SHA-256，再只调用该保护脚本一次；无论成败都给出固定最终类别和退出码，并停留到 Owner 按键。保护脚本不接收密码。
- 保护脚本先只读核对唯一 E: USB 身份、OpenSSL 哈希、固定 PowerShell/`fc.exe` 普通文件、非重解析 Temp 父目录以及任务临时目录不存在。随后只启动一次独立提权只读子过程；由 Owner 亲自核对 UAC。提权子过程先重核 E: 身份，再执行唯一 `Get-BitLockerVolume -MountPoint 'E:'`，仅唯一 `Unlocked/On/FullyEncrypted/100` 可继续，随后核对两精确 E: 文件长度、非重解析、私钥加密首行与公有证书指纹。普通进程得到子过程退出 0 后，再次核对 E: 身份、两文件及工具/Temp。任何非零都停止，不进入 CMS。
- 保护门通过后，CMD 用 `mkdir` 创建**原本不存在**的任务专用 Temp 目录；若目录已存在或创建失败就停止。它在新目录以 `FileMode.CreateNew` 写固定 ASCII 标记 `AUTH101_USB_KEY_ONLY_20260925` 加 CRLF，预期 31 bytes。CMS 输出文件在目录创建后和各次调用前再次检查不存在。CMD 直接在 Owner 前台调用固定 OpenSSL：AES-256-CBC CMS 加密一次、解密一次；解密唯一私钥输入是显式 `-inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem"`，公有证书固定 E: 同前缀文件。OpenSSL 标准错误**直接流向本机可见窗口**，没有重定向、捕获或保存；Owner 只在原生非回显提示输入密码，不向 Codex/Work 提供密码、原始输出或截图。
- 加密、解密各自退出 0 且目标存在后，固定 `fc.exe /b` 比较标记与解密结果一次。任何阶段失败立即给固定类别并保留已建虚构现场；只有比较成功才逐一删除三个精确虚构文件、核对各自不存在，再移除空目录并核对不存在。清理中途失败不会宣称成功。最终成功类别为 `AUTH101_RESULT=A_MATCH_AND_CLEAN;EXIT=0`。

## 静态检查与剩余门

- PowerShell 5.1 语法解析错误 0；CMD 跳转目标均存在，`pause` 1 处；BitLocker 查询 1 处，CMS encrypt/decrypt 与 `fc.exe /b` 各 1 处，显式 E: `-inkey` 1 处。无 `-passin`、脚本/环境/管道/文件/剪贴板密码输入、PowerShell `Read-Host`、C: 真实私钥路径、网络、DB、云、重试或回退。CMD 的 `2>nul` 仅用于静态哈希检查、目录/标记操作、比较与清理；**两次 OpenSSL 调用均无标准错误重定向**。
- 候选 CMD SHA-256 `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C`；保护脚本 SHA-256 `5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`，CMD 内固定核对后者。此为静态候选身份，Work 临运行前仍须复核。
- 新建任务目录拒绝任何预先存在的目录与文件，比 AUTH-99 在共享 Temp 使用固定裸文件路径更收紧非覆盖边界；OpenSSL 的 `-out` 本身仍不是原子排他创建。若同一用户的其他进程在目录创建后、输出打开前主动插入同名文件，仍有并发覆盖余量；脚本的调用前检查不能证明完全消除此竞态。Work 须在预运行审查中明确裁决这个剩余风险，不得把本候选自认作已获 LEVEL 3 放行。
- 固定脚本哈希/文件与设备状态检查到实际文件打开之间也不是单一原子事务。Owner 若未到场、UAC 未亲自核对、原生提示不可见或出现回显、任何类别失败，均停止且不重试。Phase B 手动启动、UAC/BitLocker 查询、encrypt/decrypt/compare 预算仍 **0/1，均未执行或放行**。A 成功也只可能证明本次 E: 加密副本对虚构内容的本机往返，不证明重插解锁、纸质恢复密钥或真实数据库备份/恢复。

本轮保留两个无关未跟踪目录，不提交、推送、自接受或派发后继；交 Work LEVEL 3 预运行审查。

## Work LEVEL 3 Phase A 独立验收与交接停点（2026-09-25）

**ACCEPT 修订候选的静态设计；Phase B 未放行、未执行。** Work 对照 AUTH-92 的 Owner 前台 CMD 成功路径、AUTH-99 拒绝点、AUTH-100 的有限提示通道事实，逐行审查本次 CMD/PS1。独立核对保护脚本 Windows PowerShell 语法错误 0、唯一 `Get-BitLockerVolume`、CMD 各一次 CMS 加密/解密与 `fc /b`、唯一字面 `-inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem"`，不存在 C: 私钥路径；OpenSSL 两次调用均没有标准错误重定向。独立核对任务 Temp 目录当前不存在。CMD/PS1 哈希分别为 `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C` / `5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`；审查前 plan SHA-256 `C592DE4A537EF2F134595F3BD1622D2830EC5DED6FF39FEA95FF9E2574C4897F`，`git diff --check` PASS。

本次接受只说明静态候选适合在**下一 Work 会话**重新做临运行高风险审查；它不是运行授权，也不证明 Owner 密码提示、BitLocker 现时状态或 E: 私钥实际 CMS 解锁成功。临运行前须再次核对本地 HEAD/工作区、候选文件哈希、OpenSSL 身份、E: 固定设备/两文件、Temp 目录不存在及 Owner 在场；Work 再决定是否放行一次 Owner 手动启动。`mkdir` 与 OpenSSL 输出打开之间仍有同用户并发插入同名文件的余量，且设备/状态核查与读取不是原子操作。此余量只涉及固定虚构临时材料，Work 在此记录并留给临运行门复核；任何真实保护或文件身份失败均停止。Owner 要求当前会话完成验收后立即交接，因此本会话不触发 UAC、密码提示或派发后继任务。
