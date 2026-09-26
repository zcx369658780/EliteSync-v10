# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-108-BOUNDED-TOOL-CAPTURE-SYNTHETIC

Risk Level: LEVEL 2（未来主机工具只读观察的输出隔离与失败门；本轮仅本地虚构子进程）

Status: ACCEPTED — LOCAL SYNTHETIC CAPTURE ONLY; NO HOST PROBE RELEASED

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 依据与目标

AUTH-107 获 Work LEVEL 2 受限 ACCEPT 的只有 Phase A 静态调用边界；其 `projector.py` 完整虚构套件 NOT_VERIFIED，且没有可运行 SSH/远端受限采集器。当前 Work 会话交接建议已被 Owner 纠正并撤回，不影响 AUTH-107 的测试和预算事实。本任务是新的**受限采集实现与虚构验证**，不重跑 AUTH-107 已耗的测试，也不放行现场。

主要结果为 `EVIDENCE/AUTH-108-BOUNDED-TOOL-CAPTURE-SYNTHETIC/summary.md`；可在该新目录放候选源码和纯虚构子进程测试。仅允许写此新证据目录，其他项目文件/证据只读；保留两个既有无关未跟踪目录。

## 允许工作

1. 核对本地 Git、入口、AUTH-105～107、项目技能与风险门。只读参考 AUTH-107 的 `--no-defaults` 首参数、原始帮助不可泄漏、固定输出和预算设计；不得读取 `.env`、密钥、凭据、真实业务数据、备份或旧 `D:\EliteSync`。
2. 实现一个**只接受调用方显式传入的可执行路径与参数数组**的有界双流采集核心；不含 SSH、网络、数据库或真实 dump 逻辑。必须并发排空 stdout/stderr，限制各流字节与整体时间，保留子进程真实退出码，超限/超时可靠终止并等待子进程；不将原始 stdout/stderr、异常文字、执行路径或环境内容写日志或普通返回值。对捕获不完整、非零退出、stderr 非空、超限和终止失败分别给固定安全类别。
3. 提供窄门适配示例：将来如调用 dump 工具，`--no-defaults` 必须是工具首参数，其后只许 `--version` 或 `--help`；任何路径/别名身份和环境净化未独立锁定时不得调用。示例不能默认发现系统中的 `mysqldump`，不能包含真实主机/账号/密码/路径。与 AUTH-107 `projector.py` 的接口关系须说明，不能把虚构文本的 `PRESENT_IN_TEXT` 当作现场支持。
4. 只用临时生成的纯虚构子进程检验：正常、小输出、stdout/stderr 同时突发、非零、超限、超时、恶意控制字符、原始秘密标记不泄漏、子进程退出/清理。测试过程不得启动真实工具、shell、SSH、OpenSSL、Docker 或网络。测试最多 3 轮套件，仅可为实际发现的失败修复后重试；记录每轮与最终结果。静态检查最多 2 轮。若环境无法可靠证明终止和限额，交出 UNKNOWN 而非伪造 PASS。
5. 禁止生产 HTTP/API、Laravel CLI、真实 DB、云控制台、UAC、部署、dump、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 审查，不提交、推送、自接受或派发后继。

## 停点

此本地虚构候选即使通过，也不授权 SSH 或目标主机工具调用；未来现场任务仍须锁定单一主机、身份、host-key、工具绝对路径/哈希、参数、脱敏回执、时限与一次预算。真实备份的目标/对象/权限、一致性、认证加密/密文传输和隔离恢复门仍 UNKNOWN，Owner LEVEL 3 单次授权另需。可能触发 UAC 的任何后继步骤在触发前停下，待 Owner 在当前 Work 会话输入“我在”；此前确认不沿用。AUTH-101、AUTH-17、AUTH-107 已耗预算不重置，AUTH-99 仍禁止运行。

Work 已在 `EVIDENCE/AUTH-108-BOUNDED-TOOL-CAPTURE-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT：仅当前 Windows 虚构子进程的有界采集核心，独立复跑 10 项通过。终止失败、子孙进程和其他系统行为未验证；没有 SSH、真实工具或 DB 证据。本任务不再处于 ISSUED，不能自行执行现场任务。
