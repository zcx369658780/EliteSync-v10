# AUTH-155 Phase A｜本机隔离目标与能力预检命令静态候选

**状态：docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；工作区原有 modified/untracked 保留。本文件的命令均为**后继候选文本，本轮 0 次执行**，不授权 Phase B、创建目标、启动 Docker/WSL/VM、读取密文/密钥或恢复。

Work 提议的一次性仓库外目标仅为 `D:\EliteSync-v10-Restore-Isolation-20260927`。发单前观察称该精确路径不存在、`D:\` 存在，Docker/WSL 名称可解析、Podman 不可解析；这是旧时点候选，不是当前复核，也不证明目标 ACL、daemon、镜像或隔离能力。候选路径**不是明文落盘许可**。

## 1. Phase B 候选只读白名单与共同执行门

以下 PowerShell 表达式仅使用固定字面路径，不递归、不枚举目录、不展开环境变量、不访问仓库外其他位置。它们是**待 Work 审查的命令内容**；尚无经核验的普通权限监督器能强制每项 10 秒、总计 120 秒及 stdout/stderr 上限，故整组目前 `NOT_READY_TO_RUN`。后继任务须逐字固定 PowerShell 可执行文件身份、版本/签名、非交互启动参数、监督器的启动/终止/双流有界捕获和禁止 UAC/服务自动启动证明；不可先运行再补这些条件。建议每项 stdout 上限 256 字节、stderr 上限 512 字节，合计输出上限 2,048 字节；超过、超时、启动/终止不确定即 `ERROR` 并停，不重试、不改用替代工具。普通回执只留表列白名单状态，不留原始对象、ACL、路径展开或配置全文。

| 顺序与最多次数 | 候选精确 PowerShell 表达式（未运行） | 唯一允许输出与失败停点 |
| --- | --- | --- |
| 1；1 次 | `$p='D:\EliteSync-v10-Restore-Isolation-20260927'; try { $i=Get-Item -LiteralPath $p -Force -ErrorAction Stop; if (($i.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { 'EXISTS_REPARSE' } else { 'EXISTS_NONREPARSE' } } catch [System.Management.Automation.ItemNotFoundException] { 'ABSENT' } catch { 'ERROR' }` | 仅四个枚举值。仅 `ABSENT` 才能继续目标候选审核；任何存在、重解析、权限/其他异常即停，不进入或查看目标内容。实际目标若被并发创建，后续不能沿用旧观察。 |
| 2；1 次，仅上项 `ABSENT` | `$r=Get-Item -LiteralPath 'D:\' -Force -ErrorAction Stop; $f=([System.IO.DriveInfo]::new('D:\')).DriveFormat; if (($r.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { 'ROOT_REPARSE' } elseif ($f -in @('NTFS','ReFS')) { 'ROOT_'+$f } else { 'ROOT_OTHER' }` | 仅 `ROOT_NTFS/ROOT_ReFS/ROOT_REPARSE/ROOT_OTHER/ERROR`；表达式异常由监督器归 `ERROR`。卷格式只是候选，不能证明目标 ACL、无同步或防落盘。`ROOT_REPARSE/ROOT_OTHER/ERROR` 停。 |
| 3；1 次，目标父路径 ACL | **`NOT_FIXED`，无可执行命令。** 预期的 Owner/SYSTEM/管理员及普通用户/继承排除清单、主体 SID、目标创建后的有效 ACL 与安全比较器均未获审定。不得运行裸 `Get-Acl` 并输出原始 ACL，也不得创建目标来探 ACL。 | `ACL_NOT_FIXED`。D: 根 ACL 与未来新目录的有效 ACL 不等价；未固定清单时 Phase B 到此停，不把“可读取”当 PASS。 |
| 4；1 次，pagefile 配置类别 | `$v=(Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles -ErrorAction Stop).PagingFiles; if ($null -eq $v) { 'PAGEFILE_UNKNOWN' } elseif (@($v).Count -eq 0) { 'PAGEFILE_NONE_CONFIGURED' } else { 'PAGEFILE_CONFIGURED' }` | 仅三个枚举值或 `ERROR`，不输出配置中的路径。此项仅静态配置类别，不证明运行时锁页、进程内存不换页或无其他落盘渠道。读取注册表若需提升或触发提示，提示前停。 |
| 5；1 次，系统崩溃转储类别 | `$v=(Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name CrashDumpEnabled -ErrorAction Stop).CrashDumpEnabled; if ($v -eq 0) { 'SYSTEM_DUMP_DISABLED_CONFIGURED' } else { 'SYSTEM_DUMP_CONFIGURED' }` | 仅两个枚举值或 `ERROR`；不输出转储路径。此项不覆盖 WER/应用进程转储、休眠、杀毒缓存或其他副本，也不是无明文落盘证明。 |

表中第 1/2/4/5 项只提出表达式，不证明 PowerShell provider、注册表权限或监督器在该主机上符合无 UAC/不启动服务/硬超时要求；任一证明缺失时不运行。第 3 项为硬停点，因此这些候选并未构成可连续执行的完整 Phase B 白名单。需要明确审定的目标 ACL 预期与安全比较器后，才能补一条精确的有限输出命令并重新作 LEVEL 3 审查。

## 2. Docker、镜像与隔离能力：无获批命令

Work 的“Docker/WSL 命令名可解析”仅说明名称解析，不证明客户端可执行文件身份、daemon 已运行、CLI 不会自动启动 Docker Desktop/WSL/服务，也不证明本地镜像。当前**不给 `docker version/info/image ls/inspect`、`wsl` 或 Podman 的运行白名单**，状态 `DAEMON_SAFE_READ_NOT_FIXED`。若后继通过独立本地静态证据证明具体 CLI 不自动启动服务、固定其可执行文件身份和仅本地 endpoint，且从**已运行** daemon 安全取得至多四个 MariaDB 候选的固定身份，才可另审一次有界的版本/存储驱动及逐候选只读摘要查询；不得先列出全部镜像再过滤、超过四个继续、输出其他镜像、联网 pull 或为查询启动 daemon。摘要缺失、标签可变但无可信来源、daemon 不可达/状态不明均 `NOT_FIXED/UNAVAILABLE`，不临场扩大观察。

静态文档中的无网络、零发布端口、零宿主挂载/卷、2 GiB 内存、2 核、128 进程与 2 GiB 可写层都是拟审目标。候选命令即使将来可读出配置，也只能报告 `STATIC_SUPPORTED/NOT_SUPPORTED/UNKNOWN`，不能证明限制**可强制**、镜像默认卷、实际容器状态或应用不可连接。启动后零网络/端口/挂载、资源实际生效和应用隔离均 `NOT_TESTED`；本轮及建议 Phase B 均不得启动容器/VM 或触及 Docker/WSL。无法证明 2 GiB 可写层等限额可强制，就停在能力门，不先用真实明文尝试。

## 3. 256 MiB 认证前明文暂存硬门

pagefile/系统 dump 的有限配置类别不等于防落盘。仍需单独审定：256 MiB 有界捕获实现及锁页权限/工作集余量、锁页失败处理、pagefile/休眠/WER/进程转储/安全软件副本、stdout/stderr 完整捕获、异常/中断清理和实际缓冲区零化；这些实现与证据来源当前 `NOT_FIXED`，不能通过注册表两个值升级为 PASS。不得在本任务运行明文程序或改系统配置。

AUTH-153 的认证状态机继续是硬门：认证与完整捕获明确成功、实际输入字节与获批密文身份匹配、同一封存字节集一次性放行前，唯一数据库消费者必须为 **0 次/0 字节**。认证失败、超时、超限、截断、捕获不完整或放行前清理失败均不放行；放行后失败须报告实际消费，不能谎称 0。真实私钥密码只能 Owner 现场原生非回显输入。任何后继动作可能触发 UAC，先在**当前 Work 会话**等 Owner 输入“我在”，且还需具体任务授权和动态复核；旧到场确认不沿用。

## 4. 停点与静态回执

顺序只可为 **本 Phase A 静态计划 → Work LEVEL 3 独立审查 → 另发固定命令/预算的 Phase B 本机只读预检 → 再审真实隔离与认证恢复**。本候选因 ACL 预期、Docker 自动启动证明、镜像摘要、强制资源能力及防落盘实现未固定，**Phase B 当前 `NOT_READY_TO_RUN`**。Phase B 即使将来通过，也不授权 AUTH-153 真实 CMS 解密/恢复、AUTH-154 逐对象账号审计、真实账号行读取或生产迁移。此次导出时独立逐对象源清单及无冲突 DDL 证据仍 `UNKNOWN`。

固定来源静态核对 **2/2 轮**：核对 cwd/ref/HEAD/dirty，实际读取当前 `TASK_CURRENT.md`、AUTH-155 `task.md`/`task-draft.md`、AUTH-154 `work-review.md`，并对列明的治理/交接/AUTH-153/154 文件作定点哈希；本会话先前已读根治理文件、workflow 技能、双库交接和 AUTH-153/154 方案，本轮没有扩展到其他位置。列明的 `EVIDENCE/AUTH-153-LOCAL-ISOLATED-RESTORE-PREFLIGHT/work-review.md` **在精确路径不存在**，未搜索替代路径；其独立接受状态仅据当前 `TASK_CURRENT.md`/AUTH-154 review，缺失文件不当作已读证据。本任务唯一写入为新增 `plan.md`；无关修改未触碰。

来源 SHA-256：`TASK_CURRENT.md` `FAE9E6D331C293D85A3F43F8C0B6B8937E4D4271E14FEA82FC7BBB2C59E7DAD5`；AUTH-155 `task.md` `BF4732501BEB1FC55EF46E3BAD7AF64EB1F3FD79372EC54E085C14A19E2041CE`、`task-draft.md` `065D6CB8444586BB9062C8F679C62441EA942485E2D052AEB13A1`；AUTH-153 `plan.md` `22D3ABED9378F0A80A4C8BE6F647C7CD1232929D4B32EFECD281F50F26970A6C`；AUTH-154 `plan.md` `83FA0F8FD99EB480657E6090810A81F3F1C02A5EE8B6EC025CED4896AAFF856B`、`work-review.md` `5B2D6F993911EE8D28A4249AAD2208DDBBF3552EEEBD0010DCDBA156B989ECBC`；双库 `handoff.md` `E099209BB01CE1432C0EA7E8C1EA651A41886A7134A28A5A81654E356886A5D2`。缺失的 AUTH-153 `work-review.md` 无 SHA-256。

`NOT_RUN`：表内所有候选表达式、任何实际只读本机预检、Docker/WSL/VM/OpenSSL/DB、容器/服务启动、UAC、密文/密钥目录/真实 CMS、解密、恢复、账号行、SSH/云/生产系统、Git commit/pull/push。未访问 `.env`、旧 `D:\EliteSync`、私钥或业务值。AUTH-152/153/154 旧预算不重置；作者停在 Work 独立 LEVEL 3 审查，不自接受、不执行 Phase B。
