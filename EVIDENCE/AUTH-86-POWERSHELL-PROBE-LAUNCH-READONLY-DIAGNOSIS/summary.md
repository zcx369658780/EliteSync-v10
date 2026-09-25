# AUTH-86｜PowerShell 探针启动只读诊断

状态：**作者只读候选，待 Work LEVEL 2 独立审查**。没有运行任何旧探针或窗口。

## 固定范围与前置事实

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `8e6efe31a9ffaddec6077b09cecb61d80a14af47`；`TASK_CURRENT.md` 为 `AUTH-86-POWERSHELL-PROBE-LAUNCH-READONLY-DIAGNOSIS`、`ISSUED — NOT STARTED`、LEVEL 2。两个无关未跟踪目录保留。
- AUTH-83 LEVEL 3 REJECT：唯一真实密钥脚本启动失败，精确目标不存在；子窗口及 OpenSSL 阶段 `UNKNOWN`。AUTH-84 LEVEL 2 REJECT：Owner 只看到窗口闪过，未见标记，约 0.98 秒提前退出；控制台位解码无效。AUTH-85 LEVEL 2 REJECT：Owner 双击一次只看到 `PROBE_LAUNCH_EXCEPTION`、PowerShell 退出 1、包装器非零分类及按键提示，未见探针标记；宽泛异常原因 `UNKNOWN`。三项旧运行预算均已耗尽。
- 本轮仅以 `Test-Path` 再次核对固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` **不存在**，未读取或修改目录材料。

## 一次只读策略查询与固定文件元数据

`Get-ExecutionPolicy -List` 本轮 **1/1 次**，当前 PowerShell 会话返回：`MachinePolicy=Undefined`、`UserPolicy=Undefined`、`Process=Undefined`、`CurrentUser=RemoteSigned`、`LocalMachine=RemoteSigned`。这是本会话所见作用域，不能自动证明 Owner 当时 Windows PowerShell 子进程的 Process 作用域或其他应用控制状态。

| AUTH-85 固定文件 | 大小 | 属性与来源流 | SHA-256 / 放行值比较 |
|---|---:|---|---|
| `owner-visible-probe.cmd` | 813 bytes | 常规文件、`Archive`、非重解析；`Zone.Identifier` **不存在**，未读取流内容 | `2BEF93FA817E584E86EA7E9AF5D374EF0DDD411F9ECC7D3D97F6092A861BC206` / 相同 |
| `probe.ps1` | 620 bytes | 常规文件、`Archive`、非重解析；`Zone.Identifier` **不存在**，未读取流内容 | `4DDE4076CBAB0F4C6F81F689E5A0876A259064E1EADF1A89EA087EC7DCF39B48` / 相同 |

## 静态调用范围与判断

AUTH-85 `.cmd` 先检查固定 Windows PowerShell 程序和探针文件是否存在，再用 `-NoLogo -NoProfile -Command` 在同一前台控制台执行包装命令。该命令设置 `$ErrorActionPreference='Stop'`，在外层 `try` 中以 `&` 调用固定 `probe.ps1`；外层 `catch` 只输出 `AUTH85_FAILURE=PROBE_LAUNCH_EXCEPTION` 并退出 1。`.ps1` 自身在 `try` 的第一条输出才打印 `AUTH85_VISIBLE_PROBE`，其内部 `catch` 输出另一个固定类别 `PROBE_EXCEPTION`。当前会话对 `.ps1` 的 PowerShell AST 解析为 **0 错误**，但没有运行 Windows PowerShell 5.1 探针。

Owner 看到的外层类别与探针标记缺席，支持**在脚本调用链发生了被外层捕获的终止性异常**，与探针主体未正常完成一致；不能凭此定位异常发生在执行策略检查、脚本解析、进入主体前，或主体/内部异常处理期间。当前 `RemoteSigned` 加两个固定文件未观察到 `Zone.Identifier`，**未提供“来源标记触发 RemoteSigned 阻止”的正向证据**；也不排除 Owner 当时进程范围差异、其他执行策略/应用控制、文件访问、宿主启动或包装命令问题。AUTH-83/84 的具体失败不由本任务追溯判定。

若 Work 需要进一步定位，后继应另立**无秘密**任务，固定一次 Owner 可见的前台入口，仅把 PowerShell 终止异常映射为预审过的有限类别并保持窗口供观察；先审查脚本与预算，再运行。不得复用 AUTH-83/84/85 已耗尽预算或以 `-ExecutionPolicy Bypass` 试错。

本轮没有修改执行策略、注册表、AUTH-83/84/85 文件或真实密钥；没有启动脚本、窗口、OpenSSL、网络或服务器连接。没有写 E:、真实密钥/备份目录或访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT 限定只读诊断；不接受具体根因已确定的说法。** Work 对照任务单审查策略、文件元数据与固定调用结构，独立核对本地 HEAD `8e6efe31a9ffaddec6077b09cecb61d80a14af47`、AUTH-85 两文件哈希仍匹配、真实私钥目标仍不存在。审查前候选摘要 SHA-256 为 `1BEF17037BB278CE67DA3D1C180C3C8087850167136D5E2B91FC627EFEE64BD8`，尾随空白 0 行，`git diff --check` PASS。

当前观察没有支持来源标记触发 `RemoteSigned` 阻止的正向证据；Owner 当时的异常原文未保存，执行策略、应用控制、调用包装等原因仍不能定性。后继可绕开 PowerShell 脚本入口，另立无秘密的纯 `.cmd` 可见性预检；这不是对旧失败的追溯诊断，也不得跳过真实密钥任务的风险门。
