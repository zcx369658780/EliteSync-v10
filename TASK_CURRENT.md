# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR`

Risk Level: `LEVEL 3`（真实 E: 加密私钥副本的虚构解密演练入口；本轮仅候选）

Status: `ACCEPTED — AUTH-101 PHASE B LIMITED SYNTHETIC RESULT; ALL ONE-SHOT BUDGETS SPENT`

Assignee: `Codex` 新接续执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 3 临运行审查和最终验收。旧执行会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 已过长，不再派发。

交接时，Work 已在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/plan.md` 独立 LEVEL 3 **ACCEPT 静态候选**，Phase B 当时未放行，手动启动、UAC/BitLocker、OpenSSL 加解密和比较使用量均为 0/1。当前单次放行仅依据下方新的 Work 临运行裁决；旧 AUTH-99 拒绝候选仍禁止运行。

## 已完成派发 — 临运行只读复核，不含 Phase B 执行

新 Codex 会话已完成只读交接。只在同一 AUTH-101 下收集临运行新鲜事实，交 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/pre-run-recheck.md` 给 Work 审查；此派发不授权手动启动、UAC、BitLocker 查询、CMS 加解密、`fc /b` 或密码输入。

1. 核对实时 `D:\EliteSync-v10` 的 `main`、HEAD、工作区及两份候选文件 SHA-256，要求 CMD `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C`、PS1 `5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`；固定 `C:\Program Files\Git\usr\bin\openssl.exe` SHA-256 要求 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`。任何不符立即停止并报告，不修改候选。
2. 最多一轮普通权限只读核对：`E:` 是否唯一对应 `Kingston DataTraveler Duo` USB Removable、单一分区/卷且设备容量 25～35 GiB；两份精确 E: 副本是否普通非重解析文件，私钥 2666 bytes、公有证书 1541 bytes。私钥只读加密 PKCS#8 首行，不读/计算私钥正文或哈希；公有证书只核对 DER SHA-256 指纹 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461`。设备不存在、歧义、文件不符或读取失败即止，不尝试解锁、修复或重试。
3. 核对固定任务 Temp 目录 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth101-synthetic` 不存在；只读重审候选的唯一 E: `-inkey`、OpenSSL stderr 可见、失败即止及 `mkdir` 与 OpenSSL `-out` 打开之间的并发覆盖余量。明确记录该余量是否仍存在及其影响，不改脚本、不运行脚本。
4. 回执仅记录检查时间、逐项 PASS/FAIL/UNKNOWN、无秘密的有限元数据、当前工作区和剩余风险；不记录私钥正文、密码、恢复密钥、窗口输出或截图。只允许新增/修改上述 `pre-run-recheck.md`，其他文件只读；保留两个无关未跟踪目录。不提交、推送、自验收或派发后继。

Work 另行核对新鲜证据、Owner 是否本人在电脑前及剩余并发风险后，才可裁决 Phase B。回执通过不自动放行。旧 AUTH-99 入口继续禁止运行；手动启动、UAC/BitLocker、CMS encrypt/decrypt、compare 各自一次预算均仍为 **0/1**，不得因交接或本次只读复核重置。

Work 已在 `pre-run-recheck.md` 独立 LEVEL 3 **ACCEPT 仅有限只读回执**：候选/固定 OpenSSL 哈希再核对一致，作者本次单轮 E: 有限元数据与证书指纹通过，Temp 当时不存在；并发覆盖余量已明确记录。Owner 本人在电脑前的状态尚未核实，Phase B 仍未放行，Codex 不得继续执行本任务或派发后继。临运行动态条件须在放行时仍成立，旧回执不保证未来状态。

## Phase A — revised candidate only

1. 核对本地 `main`、HEAD、工作区和 AUTH-92 成功的 Owner 可见 CMD 原生 OpenSSL 调用、AUTH-97 恢复副本接受范围、AUTH-99 拒绝点、AUTH-100 有限提示通道事实。只读核对固定 E: 身份、两个精确副本有限元数据、固定 OpenSSL 哈希及虚构临时目标不存在；不读私钥正文/哈希，不查询 BitLocker，不运行 OpenSSL 加解密或 UAC。保留无关未跟踪目录。
2. 只在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/` 准备新的 Owner 从 Explorer 单次双击、窗口停留到按键的 `.cmd`、必要的只读保护检查脚本与 `plan.md`。优先沿用 AUTH-92 已在 Owner 窗口成功的人机路径：CMD 在前台直接调用固定 Git OpenSSL，OpenSSL 标准错误**留在 Owner 本机可见控制台**供原生非回显密码提示使用，不重定向或保存其原文。Owner 只报告预定义最终类别与退出码，勿发送窗口原文/截图。不能以 `-passin`、脚本参数、环境、管道、文件、剪贴板或 PowerShell `Read-Host` 接收真实密码。静态核对唯一 CMS 解密调用显式 `-inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem"`，公有证书固定 E: 同前缀 `.cert.pem`，不得有 C: 私钥、回退、通配符或候选列表。
3. 任何读取 E: 私钥前，必须有独立提权只读子过程经 Owner UAC 后对当前固定 Kingston E: 执行最多一次 `Get-BitLockerVolume`，要求唯一对象 `Unlocked/On/FullyEncrypted/100`；失败即止。普通进程和提权进程都复核唯一 Kingston USB Removable 身份、分区/卷映射、25～35 GiB、两精确 E: 文件非重解析及长度/加密首行/公开证书指纹。固定脚本/工具身份门在调用前检查。设计 ASCII 固定虚构标记、AES-256-CBC CMS 加密与解密各最多一次、`fc /b` 一次；虚构临时目标在仓库外精确任务 Temp 目录，须确保不覆盖既有文件，成功只清理本任务所建三个虚构文件及空目录并核对不存在，失败保留现场。不得触碰真实备份/DB/用户数据。
4. 静态检查 Windows PowerShell/CMD 转义、输出与退出码、UAC/BitLocker 门、唯一 E: 私钥输入、Owner 可见原生提示、Temp 目标非覆盖与精确清理、失败即停及无自动重试。重点解释 AUTH-100 三次虚构调用非零只说明无人机/输入方式未建立，不否定 AUTH-92 的 Owner 原生窗口成功；也不能据此预判 AUTH-101 成功。**Phase A 禁止运行任何新入口/脚本、UAC、BitLocker 或 OpenSSL 加解密**。只交候选和有限证据，停在 Work LEVEL 3 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — single Owner manual launch completed and accepted

Work 独立审查脚本及临运行状态、Owner 在场后才可决定是否放行一次手动启动、本人 UAC 与 OpenSSL 原生非回显密码输入。任何失败立即停止，不临场改参数/路径或重试；成功仍须 Work 核对虚构临时文件清理、E: 两文件有限元数据与源私钥 ACL 未变后作受限验收。A 成功不证明 U 盘重插密码解锁、纸质恢复密钥或真实数据库备份/恢复。

Work 已在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/pre-run-recheck.md` 记录本次 LEVEL 3 临运行裁决。Owner 确认本人在电脑前、无录屏/屏幕共享、可亲自核对 UAC 并只在 OpenSSL 原生非回显提示输入现有私钥密码。只放行 Owner 从 Explorer **单次双击**固定 `owner-visible-usb-cms-entry.cmd`；任何身份/保护门失败、窗口/提示异常、密码回显或非零类别立即停止，不重试、不临场更改。Owner 只回报最终 `AUTH101_RESULT` 类别与 `EXIT` 数字，不发送密码、原始窗口输出或截图。放行前手动启动/UAC/BitLocker/CMS encrypt/decrypt/compare 使用量均为 **0/1**；实际消耗须按结果逐项记录，不能从放行推定已执行。

Owner 随后报告唯一手动启动的最终 `AUTH101_RESULT=A_MATCH_AND_CLEAN;EXIT=0`。Work 已按 `plan.md` 的 Phase B 独立验收记录核对候选/工具哈希、固定 E: 副本有限身份、成功清理及本机源私钥 ACL，LEVEL 3 **ACCEPT 仅本次 E: 私钥副本虚构 CMS 往返**。手动启动、UAC/BitLocker、CMS encrypt/decrypt、`fc /b` 各一次预算按成功分支均为 **1/1，已耗尽**。Codex 不得再执行 AUTH-101 或 AUTH-99；B 重插密码解锁、C 纸质恢复密钥及真实备份/恢复仍未证明，须另受任务与风险门约束。

禁止修改真实密钥、BitLocker、卷、E: 副本或备份，删除/覆盖其他文件，连接服务器、DB、云、Docker 或 GitHub，访问旧 `D:\EliteSync`，将任何真实敏感材料纳入 Git、Git bundle 或普通证据。
