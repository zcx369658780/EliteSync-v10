# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-114-EXECUTABLE-IDENTITY-BOUNDARY-SYNTHETIC

Risk Level: LEVEL 2（未来只读主机工具与远端程序的路径/字节身份门；本轮仅本地虚构文件）

Status: ACCEPTED — LOCAL SYNTHETIC FILE IDENTITY ONLY; NO EXECUTION

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-107/112/113 均要求现场前锁定工具绝对路径、别名/符号链接关系与完整字节，现仍没有候选路径和身份绑定证据。AUTH-109 只验证调用方所给 SHA-256 的格式，不哈希可执行文件；AUTH-111 只哈希已接受解析器源码。本任务建立**本地纯文件身份门**的候选和虚构验证，供未来远端固定程序/工具来源设计参考；它不启动任何程序，也不能单独证明未来实际运行进程来自该文件。

主要结果为新目录 `EVIDENCE/AUTH-114-EXECUTABLE-IDENTITY-BOUNDARY-SYNTHETIC/summary.md`，可附候选源码和测试。仅允许写此新目录；其他证据、控制文件只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-107/109/111～113、项目技能与风险门。只读所需已保存证据；不得读 `.env`、凭据、私钥、真实业务行、备份、真实 `mysqldump` 文件或旧 `D:\EliteSync`。
2. 实现纯文件身份函数，仅接受调用方显式提供的绝对路径、预期 SHA-256、精确允许的文件名和固定上限；拒绝相对路径、目录、符号链接/重解析点、非普通文件、空文件、过大文件、读取错误和哈希不等。以受限分块读取计算哈希，不向普通结果/异常回显路径、文件字节或原始错误；成功只返回固定候选状态与有限大小/哈希相等结论。Windows/Linux 文件系统差异和文件在核验后被替换的竞争风险必须标 `UNKNOWN`，不能宣称已绑定未来执行进程。
3. 仅用任务临时目录内的虚构文件、目录及可用时的符号链接测试正常、错误哈希、大小边界、路径类型、重解析、读失败和秘密标记不泄漏。最多 3 轮套件，仅实际失败修复可重跑；最多 2 轮静态检查。符号链接创建若需 UAC 或权限不可用，不提权、不请求 UAC，记为 `NOT_TESTED` 并保留风险。
4. 禁止启动任何子进程、SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。仅可由测试临时目录机制自动清理本任务生成的虚构文件；不碰项目其他文件。交候选后停在 Work LEVEL 2 审查，不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 未放行；文件哈希候选不证明运行中进程、远端程序、工具功能或数据库备份能力。Owner 已决定本次只备份数据库，内部对象全集仍 UNKNOWN。真实备份还需目标、权限、一致性、加密传输和隔离恢复门及 Owner LEVEL 3 单次授权。可能触发 UAC 的后继步骤须先等 Owner 在**当前 Work 会话**输入“我在”；旧到场确认不沿用。AUTH-101、AUTH-17、AUTH-107 旧预算不重置，AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-114-EXECUTABLE-IDENTITY-BOUNDARY-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT：仅本地虚构普通文件字节核对，独立复跑 13 项通过，符号链接用例 `NOT_TESTED`。本任务不再处于 ISSUED；不能据此核对真实工具或启动现场调用。
