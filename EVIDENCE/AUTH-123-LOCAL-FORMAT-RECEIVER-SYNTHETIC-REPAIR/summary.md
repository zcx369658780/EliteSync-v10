# AUTH-123｜本机格式诊断接收层纯虚构修复候选

**作者候选，待 Work LEVEL 2 独立审查；最终套件 `NOT_VERIFIED`。** 2026-09-26，本地 `D:\EliteSync-v10`、`main`，启动 HEAD `8c463dbe2c0d507736e3b9a65cb129fecfa7c3d3`。仅新增本目录五个文件；原有 `CURRENT.md`、`TASK_CURRENT.md` 修改及两个无关未跟踪目录保留。

AUTH-122 的一次真实入口退出 0、stderr 空，但旧外层接收给 `OUTPUT_INVALID`，没有可接受的阶段或类别；其 1/1 本机读取预算已耗尽。Work 用虚构 JSON 指出旧接收把 PowerShell `ConvertFrom-Json` 正常得到的 `System.Int64` 错误限为 `[int]`。本轮作者亦用纯虚构 JSON 复现 `checked_entries=3` 为 `System.Int64`、`-is [int]` 为 False。这解释旧接收设计的缺陷，**不能证明它是 AUTH-122 当次唯一失败原因**，因为原始输出未保存。

`receiver_core.ps1` 候选从 JSON 原始数字文本严格识别 0～256 的十进制整数，拒绝布尔、字符串、浮点、负数、超限；用 `System.Text.Json` 检查单行末尾 LF **或** CRLF、重复/额外/缺失字段、固定阶段/类别与退出码关系。末尾之外的 CR/LF、多行和重复结尾拒绝。普通投影仅固定阶段、类别、封顶计数、异常前候选标志、`UNKNOWN` 端口/信任和退出码；失败清空候选字段。`Invoke-Auth123BoundedProcess` 候选用两流并发字符读取、每流 2,048 字符的内存上限、15 秒总等待和固定失败类别，不向普通输出转发原文或异常。`launch_candidate.ps1` 无位置参数，启动前检查接收核心、固定 Python 解释器及 AUTH-122/121/120 代码哈希，未来仅以 `-I -B` 调用固定 AUTH-122 入口；**本轮没有运行此启动候选**。进程启动本身的阻塞和真实 Windows 环境仍未验证；进程树终止与子孙进程回收也未得到完整证明。

## 验证回执

| 文件 | 最终 SHA-256 |
| --- | --- |
| `receiver_core.ps1` | `BF91E4A663581AC4636EB1A1E1A8846603D3574E6C2AAFEBBF40A55CDFA1E08F` |
| `launch_candidate.ps1` | `D60F031E4DDA90B7CE31A1252F7A8E0A37135DFAA414AD9EA95E2BE72BB85B75` |
| `test_receiver.ps1` | `62EAC0C71D9A5C73C95C92C26AD5BE9499806BA31E2432100618059678B818E4` |
| `fake_emitter.py` | `3762656BC4D96AF8B1921C135E3C75B13EB2A1CDBA75DBCBD3A314F9C779BBB0` |
| `summary.md` | 最终哈希在作者交接回执中给出，正文不包含自身哈希。 |

作者虚构验证预算 **3/3 已耗尽**。第 1 轮单独复现 PowerShell 7.6.6 `ConvertFrom-Json` 的整数类型为 `System.Int64`。第 2 轮完整测试在正常 JSON 的初始接收断言处退出 1。第 3 轮有限诊断再次复现该断言，并确认当时的接收返回 `REJECTED / FRAME_INVALID`；旧换行判断已改为检查唯一 LF 位于字符串末尾。修订后**未复跑**，所以最终接收、拒绝分支及虚构发射器的进程级限额/超时测试均为 `NOT_VERIFIED`，不能宣称通过。`test_receiver.ps1` 的虚构发射器仅位于本目录，不触碰 SSH 文件；但完整套件在发射器用例前已停止。

Work 随后独立复跑最终虚构套件，正常 JSON 仍被判 `FRAME_INVALID`。Work 的只读合成核对定位到另一个问题：PowerShell 的 `$Stdout.StartsWith([string][char]0xFEFF)` 使用文化相关字符串比较，可能把无 BOM 的普通字符串判为 BOM。作者现将该门改为**首字符数值码点精确等于 `0xFEFF`**，并同步更新未来固定启动候选内的接收核心哈希。作者测试 **3/3** 与静态检查 **2/2** 均已耗尽，修订后没有复跑；最终运行结论仍为 `NOT_VERIFIED`，等待 Work 独立验证。未运行真实 AUTH-122 入口或读取任何 SSH 文件。

Work 又以纯虚构本机发射器独立确认，正常 Windows Python 文本 stdout 末尾码点为 **13、10**（单个 CRLF），进程 `COMPLETE`、退出 0、stderr 空；此前接收器仍将它判为 `FRAME_INVALID`。任务单据此只允许单个末尾 LF 或 CRLF。作者现改用字符码点检查最后一个 LF、可选的紧邻 CR，并逐字符拒绝正文内任何 CR/LF；增加 CRLF 正常、重复结尾和正文 CR 负向用例，并同步更新启动候选锁定哈希。**本次修订未运行作者测试或静态检查**；上述新代码和用例均为 `NOT_VERIFIED`，交 Work 独立 LEVEL 2 复核。AUTH-123 Phase B 仍为 0/1 未放行。

静态检查 **2/2 轮已耗尽**：修订 BOM 判定前，三个 PowerShell 文件解析错误 0，虚构 Python 发射器 AST 可解析；五文件严格 UTF-8 可读、无 NUL、以 LF 结尾、尾随空白 0 行。`git diff --check` 当次退出 0（不覆盖未跟踪新文件）。**本次 BOM/哈希/回执修订后未再做静态检查**；旧静态结果不验证最新字节，也不证明 PowerShell 运行行为。

本轮未读取真实 `known_hosts` 或任何 SSH 文件，未运行真实 AUTH-122 入口，未连接 SSH/阿里云、触发 UAC/密码、运行真实工具/DB 或备份。AUTH-123 Phase B 本机真实读取预算 **0/1 未放行**；AUTH-121/122 的 1/1 各已耗尽且不重置。独立服务器 host-key 来源、有效 SSH 端口、AUTH-107 Phase B、DB 和真实备份仍 `UNKNOWN`/未放行。候选停在 Work LEVEL 2 独立审查；不提交、推送、自接受或派发后继。

## 前次进程回收补修与本次竞争条件修正

Work 对最初接收候选曾独立复跑纯虚构套件 **46 项 PASS**，且三个 PowerShell 文件解析错误为 0；该结果仅对应进程回收补修前的字节。Work 随后指出，超时或任一流超限时仅调用 `Kill()`，未有界等待确认回收。前次补修在这些分支及正常收尾等待超时、捕获异常分支增加 `Kill($true)` 与最多 2 秒主进程退出确认；内部采集结果的 PID 和回收布尔值供虚构测试观察，固定 launcher 对外仍只投影脱敏字段。`test_receiver.ps1` 的超时、超限用例已增加回收标志与 PID 不再存在的检查。

Work 对前次补修候选独立虚构复跑在断言 45（overflow 固定状态）失败：overflow 返回 `TERMINATION_FAILED/reaped=false`，但 PID 观测已退出；timeout 返回 `TIMEOUT/reaped=true` 且 PID 已退出。原因是主进程在读取到超限内容前已经自行退出，旧回收辅助函数把 `HasExited=true` 直接判作失败。本次修正为：若主进程已退出，仍有界调用 `WaitForExit(2000)` 确认；若进程在 `HasExited` 检查与 `Kill($true)` 之间退出，捕获该竞争并同样确认退出。仅在无法确认主进程退出时返回固定 `TERMINATION_FAILED`，不回显捕获内容或异常。launcher 锁定哈希已同步；现有虚构用例已覆盖 overflow/timeout 状态及 PID 退出观察，无需改动。

**本次最新候选 `NOT_VERIFIED`**：未运行作者测试、静态检查或固定 launcher；作者预算仍为虚构测试 **3/3**、静态检查 **2/2**，不补跑。`Process.Start()` 阻塞无法由此严格限时；主进程已先退出时，也无法凭其 `WaitForExit` 证明所有子孙进程退出。须由 Work 对最终字节独立复核，且 AUTH-123 Phase B 仍为 **0/1 未放行**。
