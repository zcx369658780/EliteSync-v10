# AUTH-101｜临运行只读复核回执

检查时间：2026-09-25 20:01 CST（12:01 UTC）。本回执只记录当前一次普通权限只读观察和静态复核；不构成 Phase B 放行或执行验收。

| 项目 | 结果 | 有限事实 |
| --- | --- | --- |
| 任务权限 | PASS | `TASK_CURRENT.md` 为 `ISSUED — PRE-RUN READ-ONLY RECHECK ONLY; PHASE B NOT RELEASED`，交新 Codex 会话，LEVEL 3；唯一允许写入本回执。 |
| 本地 Git | PASS | `D:\EliteSync-v10`，`main`，HEAD `c54ece3887d95829fc7fbfd090a37464565d9305`。检查前已有修改：`AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`；两个既有无关未跟踪目录保持原状。 |
| 候选 CMD SHA-256 | PASS | `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C`，与任务单一致。 |
| 候选 PS1 SHA-256 | PASS | `5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`，与任务单一致。 |
| 固定 OpenSSL SHA-256 | PASS | `C:\Program Files\Git\usr\bin\openssl.exe`：`21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，与任务单一致；未运行 OpenSSL。 |
| E: 身份与映射 | PASS | 一轮普通权限读取：E: 对应 `Kingston DataTraveler Duo`，USB、Removable；磁盘 28.82 GiB，磁盘上一个分区、一个带盘符卷。此观察不证明 BitLocker 当前保护状态。 |
| E: 两精确副本 | PASS | 指定私钥和证书均为普通非重解析文件，分别 2666 / 1541 bytes。私钥仅核对首行 `-----BEGIN ENCRYPTED PRIVATE KEY-----`，未读后续正文、未计算私钥哈希。证书 DER SHA-256 为 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461`。 |
| 固定任务 Temp | PASS | `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth101-synthetic` 在检查时不存在。 |
| 候选静态控制流 | PASS，附剩余风险 | CMD 中唯一 CMS 解密调用显式 `-inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem"`；加密使用固定 E: 证书。两次 OpenSSL 调用均未重定向 stderr，原生提示将流向 Owner 前台窗口。保护脚本在其设计路径中先检查设备、工具与 Temp，再经 UAC 子过程查询 BitLocker；各非零分支停止，不自动重试；失败保留已建虚构现场，比较成功后才精确清理。此为静态判断，未执行候选。 |
| 并发覆盖余量 | **仍存在** | 即使先确认任务目录不存在并由 `mkdir` 创建，OpenSSL `-out` 不是排他创建；同一用户的其他进程可在输出文件存在性检查与 OpenSSL 打开之间插入同名文件。影响范围是任务 Temp 目录内固定虚构 CMS/解密输出，不能声称完全排除覆盖。设备/文件身份检查与后续打开亦非原子事务。交 Work LEVEL 3 临运行门裁决。 |
| Owner 在场、BitLocker 当前状态、CMS 往返 | UNKNOWN / NOT RUN | 本次没有核实 Owner 是否在场；没有启动入口/保护脚本、UAC、BitLocker 查询、CMS 加解密、`fc /b` 或密码输入。 |

Phase B 仍未放行。手动启动、UAC/BitLocker、CMS encrypt/decrypt、compare 的各一次预算均保持 **0/1**。旧 AUTH-99 候选仍禁止运行。Work 须独立审查本回执和剩余风险，并自行核实 Owner 在场后裁决；本回执通过不自动放行。

## Work LEVEL 3 只读回执审查（2026-09-25）

**ACCEPT 本次有限只读复核回执；Phase B 仍未放行。** Work 对照任务单、作者回执和工作区，独立重算两份候选与固定 OpenSSL 的 SHA-256，均与上述固定值相等；独立确认固定任务 Temp 目录当时不存在，重读 CMD/PS1 的固定 E: 输入、UAC/BitLocker 先行门、OpenSSL stderr 直达前台、失败即止与成功精确清理路径。`git diff --check` 通过；未执行入口或保护脚本。E: 身份、两文件有限元数据与证书指纹是作者本次单轮普通权限观察，Work 接受为有时点限制的回执，不将其升级为 BitLocker 现时证明。

同一用户在 `mkdir` 与 OpenSSL `-out` 打开之间插入同名文件的余量仍存在；其已知影响限于本任务固定虚构 Temp 输出，不能宣称排他创建或完全无覆盖风险。设备、脚本与文件检查到实际打开之间也非原子。此风险经 Work 审查记录，可在 Owner 到场、临运行状态仍匹配且脚本自身所有保护门通过时，作为一次虚构手动演练的受限剩余风险接受；它不授权覆盖任何既有文件或触碰真实备份。Owner 是否本人在电脑前仍 `UNKNOWN`，故此处不作 Phase B 放行。所有一次运行预算保持 0/1；不得凭本回执自动启动或重试。

## Work LEVEL 3 临运行裁决（Owner 到场后，2026-09-25）

Owner 在当前 Work 会话确认本人在电脑前，现场无录屏或屏幕共享，可亲自核对 UAC，仅在 OpenSSL 原生非回显提示输入现有私钥密码。Work 重新读取 AUTH-92、AUTH-97～101 的本地验收边界及原 Codex 会话最近的 AUTH-101 停点：AUTH-92 已证明 C: 私钥对虚构标记的一次本机 CMS 往返；AUTH-97 已证明当时 E: 副本与源字节相同；AUTH-98 只接受 A/B/C 分开的设计；AUTH-99 的隐藏提示候选被拒；AUTH-100 的三次虚构调用均未成功解锁。因此旧演练不能代替本次从 E: 固定私钥副本解密，任何旧一次预算也不重置。

Work 再次独立只读核对：本地 `main` HEAD `c54ece3887d95829fc7fbfd090a37464565d9305`；CMD、PS1 与 OpenSSL SHA-256 分别为 `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C`、`5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`、`21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`；唯一 USB 为 `Kingston DataTraveler Duo`、28.82 GiB、E: 分区/可移动卷映射唯一；两精确文件非重解析且分别 2666/1541 bytes，私钥加密首行匹配，公有证书 DER 指纹 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461`；固定任务 Temp 目录不存在。未读私钥正文/哈希，未查询当前 BitLocker 状态，未启动脚本或 OpenSSL CMS。

**RELEASE 仅一次 Owner 从 Explorer 手动双击本目录 `owner-visible-usb-cms-entry.cmd`。** 脚本自身须先经 Owner UAC 下的唯一只读 BitLocker 查询，满足当前 `Unlocked/On/FullyEncrypted/100`，再读 E: 私钥与进入 CMS；任一失败即停。Work 在仅固定虚构 Temp 输出、运行前目录不存在、成功精确清理、失败保留现场的范围内接受已记录的非原子并发余量，不宣称绝对排他。Owner 仅在原生非回显提示输入密码，只报告最终固定类别与退出码；窗口/提示异常、密码回显、任何失败均不重试，不改路径/参数，也不运行 AUTH-99。此放行不等于执行或验收；放行时手动启动、UAC/BitLocker、CMS 加密/解密/比较预算均为 0/1。
