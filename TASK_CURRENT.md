# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-149-OWNER-MANUAL-PATH-PROBE-DETAIL

Risk Level: LEVEL 3（生产命令助手单条路径结果只读查看）

Status: COMPLETED — EXIT=ZERO; AUTH147=OK; THREE PATH SHAPES VALID

Assignee: Work 负责临运行只读核对、GO/NO-GO 和结果投影；Owner 本人负责 GO 后的唯一手动详情点击。Codex 不派发现场动作。

## Owner 授权与单次边界

AUTH-148 经 Owner 手动提交一次，当前页面新增唯一同名记录，控制面状态“执行完成”；退出码与路径结果尚 `UNKNOWN`。Owner 明确授权**由本人在 Work 复核并给 GO 后**，对这条 AUTH-148 记录手动点击“查看命令详情”一次。AUTH-148 执行预算 1/1 不重置；本任务只读详情点击单独 `0/1`，不含执行命令、SSH、PEM、DB、dump 或备份。

Work 只在当前阿里云官方上海轻量实例命令助手页面做一次临运行只读核对：目标 URL/地域与 AUTH-148 相同，表中恰有一条 `AUTH-148-readonly-tool-path-probe`，状态“执行完成”，且该行可见“查看命令详情”。旧 AUTH-140 行不得误点。若目标、名称、唯一性或状态不符，或出现登录、密码、真人识别、权限/UAC 提示，点击前 `NO-GO`。不刷新、导航、改页、打开别的记录或调用隐藏 API。

复核通过后 Work 可向 Owner 发出仅该行的一次手动详情 GO。Owner 点击该行“查看命令详情”动作开始即本任务详情预算 `1/1`，页面无变化也不重试。Work 在 Owner 报告点击后仅只读当前详情一次：核对明确退出码 `ZERO|NONZERO|UNKNOWN`、结果是唯一一行 `AUTH147=OK` 或固定 `ERR_*`，成功行三个路径均为绝对路径形态、ASCII 字符/长度限制、无 `..`、无缺失/重复/额外输出；异常时只记类别并停。不得向聊天或普通证据输出、保存或哈希任何路径原值、脚本原文、实例/账号标识/IP、截图或平台错误全文。三个路径原值只在阿里云当前受保护详情页内短暂查看，其留存风险已由 Owner 在 AUTH-148 前接受。

本轮 Work 核对 `1/1`、Owner 手动详情点击 `1/1`。唯一主要结果 `EVIDENCE/AUTH-149-OWNER-MANUAL-PATH-PROBE-DETAIL/summary.md`。即使成功，仅为当前命令助手 Shell 的受限名称解析路径候选，不证明文件/链接目标/字节身份、服务运行、host-key 信任、有效 SSH 端口、DB 结构或备份就绪。旧预算不重置；保留两个无关未跟踪目录，不访问旧仓库，不自动 pull/push。

## Work LEVEL 3 临运行裁决

当前官方上海实例页面与 AUTH-148 同目标；表中 AUTH-148 同名“执行完成”记录恰好一条，其本行详情入口可见。旧 AUTH-140 行仍存在，已与新行区分；当前无打开的详情。Work 只读核对 `1/1` 已耗尽，LEVEL 3 **GO：仅 Owner 本人可在 AUTH-148 行手动点击“查看命令详情”一次**。GO 发出时未收到本次点击回报，手动详情预算仍 `0/1`；若页面变化或出现登录/权限提示即停，不点旧行、不重试。

## Owner 手动详情与最终审查

Owner 报告详情已打开，本任务手动详情预算 `1/1` 耗尽。Work 对当前详情只读投影：Shell，明确退出码 `0`；执行结果唯一一条非空行，完整符合 `AUTH147=OK` 和 `SSHD/SYSTEMCTL/SERVICE` 三个受限绝对路径形态，三个值均在 2～120 字符、允许 ASCII 集合内且不含 `..`。没有额外非空输出行；未在普通证据记录或哈希路径原值。Work LEVEL 3 **ACCEPT 仅三个当前名称解析路径的形态候选**。它们不证明普通可执行文件、符号链接终点、字节哈希、服务正在运行、host-key、有效端口或 DB；不得据此 SSH、读取 DB 或备份。
