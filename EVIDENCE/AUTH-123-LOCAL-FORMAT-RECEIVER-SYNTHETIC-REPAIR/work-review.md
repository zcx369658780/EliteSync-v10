# AUTH-123 Work LEVEL 2 独立审查

2026-09-26，**ACCEPT，仅 Phase A 本机虚构接收层候选**。本地 `main` HEAD `8c463dbe2c0d507736e3b9a65cb129fecfa7c3d3`；作者测试 3/3、静态检查 2/2 均已耗尽，作者最终版本未复跑。Work 独立运行最终 `test_receiver.ps1` 得 `SYNTHETIC_CHECKS_PASS=50`、退出 0；此前补修前版本分别通过 46 项、在回收断言 45 失败，均不替代最终回执。

Work 检查 `receiver_core.ps1` SHA-256 `BF91E4A663581AC4636EB1A1E1A8846603D3574E6C2AAFEBBF40A55CDFA1E08F`、`launch_candidate.ps1` SHA-256 `D60F031E4DDA90B7CE31A1252F7A8E0A37135DFAA414AD9EA95E2BE72BB85B75`；启动候选锁定了最终接收核心与 AUTH-122 入口哈希 `896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928`，与本地文件相符。PowerShell 三文件最终解析错误均为 0。虚构进程观察证实 Windows Python 文本 stdout 的单个末尾 CRLF 可接受；LF 可接受，其他 CR、多行、重复结尾及非法 JSON 字段/计数拒绝。虚构超时和溢出用例观察到主进程退出，普通投影不包含原文。

这不是固定启动候选的真实运行验收。`Process.Start()` 阻塞上限、终止后所有子孙进程退出、真实 Windows 文件与运行环境仍未证明。**Phase B 本机真实读取 0/1，未放行**；AUTH-121/122 的各 1/1 已耗尽，不重跑。下一步须在独立临运行门复核最终字节、文件身份、环境与回收风险，才可决定是否另给一次真实本机只读诊断预算。无 SSH、阿里云控制台、DB 或备份授权；独立可信 host-key 来源及有效 SSH 端口仍 UNKNOWN。

## Work Phase B 临运行裁决

2026-09-26，Work 在本地检查点 `ae1fd832e289068f08b611cd72accd08df4b70cd` 后重新核对：固定启动候选、接收核心、Python 解释器、AUTH-122 入口/诊断模块与 AUTH-121/120 依赖共七份文件，均为普通非重解析文件，SHA-256 全部匹配候选锁定值；精确目标 `C:\Users\zcxve\.ssh\known_hosts` 仅查有限元数据，存在、2,744 bytes、`Archive`、非重解析且无 LinkType，未读正文。工作区仅保留原有两个无关未跟踪目录。Owner 在当前 Work 会话确认“我在”；本次入口为本机普通权限只读 Python，不请求 UAC、密码或连接服务器。

**RELEASE，仅 AUTH-123 Phase B 一次本机只读格式诊断**：新预算 0/1 → 最多 1/1，只允许固定 PowerShell 7 `-NoProfile -File` 启动 `launch_candidate.ps1` 一次，不传参数；候选内部只能以 `-I -B` 启动固定 Python 入口。执行前由 Codex 再核对上述七份哈希及精确目标有限身份；任何不符即停，不消耗启动预算，也不得换路径、重试或修补后继续。启动后只交固定 `receiver_status/reason/stage/category/checked_entries/prior_target_candidate/port/host_key_trust/exit_code` 脱敏回执；不得保留或显示原始 stdout/stderr、文件正文、其他主机、公钥或指纹。首次失败即停，1/1 用完后绝不重跑。固定 Python 入口无子进程调用，但 `Process.Start()` 阻塞上限及操作系统终止边界未获完整证明，这一并发/生命周期风险在本次单次本机只读观察中保留；若启动异常，记 UNKNOWN 并停。此放行不及 SSH、阿里云、AUTH-107 Phase B、DB 或备份。

## Work Phase B 独立结论

**ACCEPT，仅本次单次本机格式诊断的受限回执。** Work 核对最新 Codex 会话 `01a0dc31-b629-76a3-85fd-f71566b03056` 中启动前七份哈希/目标有限身份检查 `PASS`，及唯一一次固定 `launch_candidate.ps1` 启动记录：脱敏 JSON 为 `receiver_status=ACCEPTED_CANDIDATE`、`reason=NONE`、`stage=INPUT_CR`、`category=FORMAT_INVALID`、`checked_entries=0`、`prior_target_candidate=NO`、`port=UNKNOWN`、`host_key_trust=UNKNOWN`、`exit_code=0`，外层退出 0。作者 `execution.md` 与该记录一致；Work 未再运行候选或读取目标。AUTH-123 Phase B 启动/真实本机读取 **1/1 已耗尽**，不重试。

`INPUT_CR` 只证明固定诊断器在本次读取字节上报告首个格式异常类别；不暴露或推定具体行、主机、公钥或指纹，也不能建立服务器独立可信 host-key 来源、有效 SSH 端口或 SSH 权限。现有本机历史信任记录不能作为下一次真实服务器连接的已验可信来源。后继须另立具体任务解决可信来源和端口，且不能复用 AUTH-121/122/123 的真实读取预算。无 UAC、密码、阿里云、SSH、DB 或备份动作。
