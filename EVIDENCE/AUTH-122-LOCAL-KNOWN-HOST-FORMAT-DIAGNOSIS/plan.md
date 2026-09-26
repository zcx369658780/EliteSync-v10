# AUTH-122｜本机 known_hosts 格式诊断 Phase A 虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26，本地 `D:\EliteSync-v10`、`main`，启动 HEAD `77b5d57a7562b436a53426bc9708e1a89a19f43a`。仅新增本目录四个文件；原有 `CURRENT.md`、`TASK_CURRENT.md` 修改及两个无关未跟踪目录保留。

AUTH-121 单次真实本机读取在固定入口下返回 `REJECTED / FORMAT_INVALID`、退出 1、没有指纹候选；Work 仅接受该有限失败事实，旧 1/1 预算耗尽。具体格式原因 `UNKNOWN`，本任务不从旧结果推断内容。Owner 已选择先做本机格式诊断；Phase A 仍只用纯虚构字节。

## 候选与边界

`format_diagnostic.py` 纯函数依照固定 AUTH-120 校验顺序，调用其已认证的私有格式验证函数，停在第一处异常。普通结果仅有固定阶段/类别、异常前已完整检查的条目计数（最多 256）、异常前是否曾有可解析固定目标候选（`YES_CANDIDATE|NO`）、端口与 host-key 信任均 `UNKNOWN`。没有行号、主机名、原始行、公钥 blob、指纹、盐、哈希、文件路径或异常文字。`YES_CANDIDATE` 不是现时主机身份或可信指纹证明。诊断不跳过错误、不修复条目、不放宽 AUTH-120；若 AUTH-120 原解析结果不是 `REJECTED / FORMAT_INVALID`，入口只给 `SOURCE_RESULT_MISMATCH` 固定失败。

`local_format_entry.py` 是未来一次本机只读的**未放行候选**，没有路径参数。它先固定字节哈希加载 AUTH-121 入口（SHA-256 `E58812A8FCA60859899DAE8F4D87046583068BB383E92538B5AD7C2994005ABE`）与本诊断纯函数（SHA-256 `7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA`），从已核对的内存字节执行，避免依赖隔离模式下的同目录导入。然后复用 AUTH-121 的普通文件/非重解析、大小、前后元数据一致性和单次打开读取门来加载 AUTH-120 依赖（SHA-256 `2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346`）及唯一目标 `C:\Users\zcxve\.ssh\known_hosts`。目标最多 65,536 bytes，一次打开，内存中先获原解析固定类别再诊断；失败清空诊断肯定字段。父路径检查后替换、同元数据替换及 Windows 重解析/时间精度差异仍是并发余量，不能把候选称作严格对象绑定。解释器与入口本身的实际字节、未来文件元数据及权限还须临运行复核。

有效 SSH 端口仍 `UNKNOWN`，不能由无端口匹配推定 22。即使未来诊断成功，也只得到结构类别，不得到服务器独立可信指纹或 SSH/DB/备份权限。未来 Phase B 须 Work 在独立审查后固定入口/依赖/解释器哈希、精确文件有限身份、单次预算与脱敏输出，另作临运行裁决；任何不符即止，不重试、不换路径，不借 AUTH-121 旧预算。

## 验证与停点

| 文件 | 最终 SHA-256 |
| --- | --- |
| `format_diagnostic.py` | `7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA` |
| `local_format_entry.py` | `896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928` |
| `test_format_diagnostic.py` | `9F317C5EA9D2D79552D32443C37383AEEB594CDD410959D9BE1F7CCB95E58AE9` |
| `plan.md` | 最终哈希在作者交接回执中给出，正文不包含自身哈希。 |

作者纯虚构测试 **3/3 轮**：第 1 轮退出 0、`SYNTHETIC_CHECKS_PASS=19`；复核隔离模式导入边界后把诊断模块改为固定哈希内存加载，第 2 轮退出 0、19 项；新增纯虚构固定源码加载正/负用例后，第 3 轮退出 0、`SYNTHETIC_CHECKS_PASS=21`。覆盖首个结构异常、全局输入门、此前已完整解析的目标候选、已检查条目数、AUTH-120 原结果不符、带端口拒绝、秘密标记不回显及固定源码哈希失败。测试只使用虚构字节与指定已接受的 AUTH-120 源码，不调用真实入口、不开新进程或网络。

静态检查第 **1/2 轮**：三个 Python 文件 AST 可解析，四文件严格 UTF-8 可读、无 NUL、以 LF 结尾、尾随空白 0 行；`git diff --check` 退出 0（不覆盖未跟踪新文件），新文件已逐个核对。工作区仅新增 AUTH-122 候选目录，既有两处文档修改和两个无关未跟踪目录保留。最终文字修订后再用第 2/2 轮复核；静态检查不证明真实文件系统身份或运行行为。

本轮没有读取真实 `known_hosts`，没有运行真实入口、SSH、阿里云控制台、真实工具/DB、UAC、密码、备份或恢复。Phase B 本机真实读取预算 **0/1 未放行**；AUTH-121 旧 1/1 不重置，AUTH-107 Phase B 仍未放行。Owner 当前“我在”只确认到场。作者不提交、推送、自接受或派发后继；停在 Work LEVEL 2 独立审查。

## Work LEVEL 2 Phase A 独立审查（2026-09-26）

**ACCEPT，仅限纯虚构字节第一处格式拒绝分类及固定本机入口候选。** Work 核对 `format_diagnostic.py` SHA-256 `7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA`、`local_format_entry.py` SHA-256 `896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928`、测试 SHA-256 `9F317C5EA9D2D79552D32443C37383AEEB594CDD410959D9BE1F7CCB95E58AE9`，独立运行最终 21 项虚构检查退出 0。诊断先要求原 AUTH-120 解析器返回 `REJECTED / FORMAT_INVALID`，再按同一校验顺序投影固定阶段/类别、封顶计数和异常前候选标志；不回显原文或指纹。固定入口从哈希匹配的内存源码加载依赖，目标读取沿用 AUTH-121 的精确只读门。

本接受不证明真实文件触发哪一阶段，也不消除 Windows 文件系统并发余量。AUTH-121 的 1/1 仍已耗尽；**本接受尚不放行 AUTH-122 Phase B**，真实读取预算 0/1。SSH、阿里云控制台、AUTH-107 Phase B、DB 与备份均未放行。

## Work LEVEL 2 Phase B 临运行裁决（2026-09-26）

Work 重新核对固定入口 `local_format_entry.py` SHA-256 `896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928`、诊断模块 SHA-256 `7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA`、AUTH-121 入口 SHA-256 `E58812A8FCA60859899DAE8F4D87046583068BB383E92538B5AD7C2994005ABE`、AUTH-120 解析器 SHA-256 `2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346`，均匹配。固定解释器 `C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe` SHA-256 `5F7B89A612C9B8AF1D6456CDFCD1DBE5CA630849E79AEBCED9BEE9A6694952EC` 匹配；精确目标 `C:\Users\zcxve\.ssh\known_hosts` 存在、2,744 bytes、Attributes=`Archive`、无 LinkType。以上仅是启动前快照，不消除身份检查与读取间的并发余量。

**RELEASE，仅 AUTH-122 Phase B 一次本机只读诊断。** 只允许固定解释器以 `-I -B` 执行固定 `local_format_entry.py` 一次，不传参数；仅保留固定阶段/类别、封顶已检查条目数、异常前候选标志、`UNKNOWN` 端口/可信度及退出码。不得保留原始行、公钥、指纹、其他主机、异常或路径。新预算 0/1 → 最多 1/1；失败即停、不重试、不改文件或工具。AUTH-121 旧预算保持 1/1 已耗尽；SSH、阿里云控制台、UAC、密码、AUTH-107 Phase B、DB 和备份均未放行。

## Phase B 作者单次受限回执（2026-09-26）

启动前独立复核：本地 `main` HEAD 仍为 `77b5d57a7562b436a53426bc9708e1a89a19f43a`；固定解释器、AUTH-122 入口/诊断模块及 AUTH-121/120 依赖的五项 SHA-256 均与上方裁决匹配。精确目标当时仍存在、**2,744 bytes**、`Archive`、无 `LinkType`、非重解析点。这些只是启动前有限元数据，不消除入口检查与读取之间的并发余量。

固定解释器以 `-I -B` 和唯一固定入口**启动一次**，无附加参数。入口进程退出码 **0**，标准错误为空；本地脱敏接收层返回固定 `OUTPUT_INVALID`，自身退出 1，因此**没有可接受的阶段、类别、已检查计数或异常前候选标志回执**，均记 `UNKNOWN`。原始 stdout 未保存或显示，不能由进程退出 0 推断具体诊断类别、目标条目或文件内容；本地接收层为何拒绝亦 `UNKNOWN`，不得临场放宽或重取。端口与独立 host-key 信任仍 `UNKNOWN`。

AUTH-122 本机真实读取/启动预算 **1/1 已耗尽**，失败即停，未重试、换路径、换解释器或改代码。AUTH-121 已耗 1/1 不重置。仅交此有限失败事实供 Work LEVEL 2 独立验收；无 SSH、阿里云控制台、UAC、密码、AUTH-107 Phase B、DB、备份或恢复授权。

## Work LEVEL 2 Phase B 独立结论（2026-09-26）

**REJECT，未取得可接受的格式阶段/类别回执；仅接受单次入口退出 0、stderr 空而外层接收 `OUTPUT_INVALID` 的受限事实。** Work 核对临运行固定哈希、任务证据及 Codex 会话中唯一的固定解释器 `-I -B` 入口启动；未重读真实 `known_hosts`、未重跑入口，也未查看原始 stdout。Phase B 新预算 1/1 已耗尽，不得在 AUTH-122 内重试或放宽接收条件。

Work 对**接收命令本身**作只读审查，发现它把 `ConvertFrom-Json` 后的 `checked_entries` 限定为 PowerShell `[int]`；Work 用虚构 JSON `{"checked_entries":0}` 核验该字段实际类型为 `System.Int64`。因此该类型条件会拒绝正常 JSON 数字，是一个确定的本地接收层缺陷。由于原始 stdout 未保存，不能证明当次实际被拒的唯一原因，也不能恢复真实诊断阶段或猜测文件内容。后继如修复接收层，须先独立虚构进程级验证，再以**新任务、新预算**审查是否允许一次真实读取。有效端口、独立 host-key 来源、SSH、AUTH-107 Phase B、DB 与备份仍 `UNKNOWN`/未放行。
