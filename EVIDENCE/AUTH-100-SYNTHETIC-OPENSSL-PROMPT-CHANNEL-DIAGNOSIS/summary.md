# AUTH-100｜虚构 OpenSSL 密码提示通道诊断

**作者结论：仅保留提示通道的有限观察，提交 Work LEVEL 2 判定；本次执行存在停止条件偏差。** 在本机固定 Git OpenSSL 与 Windows PowerShell 5.1 的一次受限子进程观察中，A（标准错误正常流向）和 C（`$ErrorActionPreference='Stop'`）只在标准错误检出密码提示，B（`2>$null`）在标准输出和标准错误均未检出提示。因此 AUTH-99 的 `2>$null` 风险有本机虚构证据支持，AUTH-99 的 REJECT 和禁止运行边界继续有效。三模式均返回原生命令非零，固定无保密价值测试口令经重定向标准输入送入也未使调用成功；具体失败原因 `UNKNOWN`。C 本次没有进入 PowerShell `catch`，不能推断所有 OpenSSL 错误在该设置下都不会终止。

## 范围和预检

- 本地 `D:\EliteSync-v10`，`main`，启动 HEAD `61882c7e61f59bee46c2a0338b94a37e67305739`。`TASK_CURRENT.md` 为 `AUTH-100-SYNTHETIC-OPENSSL-PROMPT-CHANNEL-DIAGNOSIS`、`ISSUED — SYNTHETIC-ONLY LOCAL DIAGNOSIS`、LEVEL 2，交 Codex。AUTH-99 候选已被 Work LEVEL 3 REJECT，未运行。
- 固定 `C:\Program Files\Git\usr\bin\openssl.exe` 是非重解析普通文件；SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，符合 AUTH-88 固定值。固定 Windows PowerShell 为 5.1.26100.9444。
- 仓库外 `C:\Users\zcxve\AppData\Local\Temp` 是非重解析目录；精确 `elitesync-auth100-synthetic` 目录运行前不存在。仅新建一次虚构 RSA 2048 加密 PEM，固定测试口令 `AUTH100_SYNTHETIC_ONLY` 无保密价值。
- `probe-child.ps1` 与 `run-diagnosis.ps1` 的 PowerShell 语法解析错误均为 0。静态文本检查未见 E:、真实 C: 私钥/备份路径、UAC、BitLocker、网络、DB、云、Docker 或 Owner 密码调用。运行时只输出有限分类；完整 OpenSSL 标准输出/错误与虚构私钥正文均未写入证据。

## 一次运行回执

| 调用 | 退出类别 / 子进程退出码 | 提示检出通道 | 输出上限 | 预算 |
| --- | --- | --- | --- | --- |
| 虚构密钥生成 | PASS | 不适用 | 通过 | 1/1 |
| A：标准错误正常流向 | `NATIVE_NONZERO` / 10 | stdout 否；stderr 是 | 通过 | 1/1 |
| B：`2>$null` | `NATIVE_NONZERO` / 10 | stdout 否；stderr 否 | 通过 | 1/1 |
| C：`$ErrorActionPreference='Stop'` | `NATIVE_NONZERO` / 10 | stdout 否；stderr 是 | 通过 | 1/1 |

每个子进程有 15 秒超时和每通道 8192 字符上限；本次无超时、无超限。提示通过受限正则识别，未保存提示原文。上述退出码 10 是子脚本对 OpenSSL 非零结果的有限分类，不是 OpenSSL 原始退出码。由于三次原生命令均非零，本次没有证明密码输入被 OpenSSL 接受或私钥可成功解锁；更不能据此放行 E: 真实私钥调用。

**停止条件偏差：**脚本把 A 的 `NATIVE_NONZERO` 当作可记录的诊断结果，继续运行 B、C 并在最后清理；按任务单“若测试失败，停止并保留虚构现场”的严格读法，应在 A 非零时停止并保留现场。三个调用各只执行一次，没有重试或扩大到真实材料，但 B/C 和清理已发生，不能追溯修正。本次候选不声称满足全部执行条件，请 Work 将此偏差纳入独立 REJECT/ACCEPT 裁决；不在 AUTH-100 再运行。

## 清理和交接

全部三模式完成后，脚本核对临时目录仅含本次虚构密钥，精确删除该文件和空目录并逐项核对不存在，回执 `CLEANUP=PASS;TEMP_DIR_ABSENT=TRUE`。未访问 E:、真实 C: 私钥、备份、旧仓库、服务器或数据库，未触发 UAC/BitLocker，也未请求 Owner 密码。两个原有无关未跟踪目录保留。本任务不提交、推送、自接受或派发后继；由 Work 独立复核此证据和后续入口的可见提示设计。

## Work LEVEL 2 独立审查（2026-09-25）

**REJECT 任务要求的完整合规诊断；ACCEPT 受限的本机虚构提示通道事实。** Work 审查脚本控制流与回执，独立确认固定 Temp 目录事后不存在，未发现 E: 或真实私钥路径调用。审查前 summary SHA-256 `05A891A375A86732D3958DE83B429174CE082D8278CB1F299BB8C9D1CB50108B`；两个执行脚本 SHA-256 分别为 `828CF7EB6BBBC6FB66D85C4F072EE234FE7A62216B956E172C253AEAC2C8390E` 和 `55C725EEEEBB319BE75E427CE33BA88BBD59D4B099EB5D4E91DDEBD140759164`。静态可见主循环在 A 返回 `NATIVE_NONZERO` 后继续 B/C 并清理，与任务单的失败即停和保留现场冲突。三模式各 1/1 已用尽，不重跑。

受限事实仅为本次虚构子进程的正则分类：A/C 在标准错误检出提示，B 使用 `2>$null` 后两通道未检出；该证据支持 AUTH-99 的提示不可见风险。三次调用均非零，固定测试口令是否被 OpenSSL 接收及真实交互成功仍 `UNKNOWN`；不能据此放行真实 E: 私钥演练。后继必须重新设计 Owner 可见的原生提示通道，避免将标准错误重定向为空；实际运行仍需新任务和 LEVEL 3 预运行审查。
