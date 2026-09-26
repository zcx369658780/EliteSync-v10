# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-119-LOCATOR-RECEIPT-STRICT-PARSER-SYNTHETIC

Risk Level: LEVEL 2（生产主机定位回执接收边界；本轮仅本机纯虚构字节）

Status: ACCEPTED — LOCAL SYNTHETIC PARSER ONLY; NO SSH

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-118 只接受未来单次主机工具定位的静态合同，尚无固定脱敏回执解析器。实现一个**纯函数**，对调用方提供的虚构字节和单一 SSH 退出候选做拒绝式解析，仅输出 AUTH-118 固定类别，不泄露输入原文。此任务不产生现场命令，也不证明主机、程序或工具身份。

主要结果为 `EVIDENCE/AUTH-119-LOCATOR-RECEIPT-STRICT-PARSER-SYNTHETIC/summary.md`；可在同一新目录新增 `locator_parser.py` 和 `test_locator_parser.py`。仅允许写这三个文件；其余项目文件和证据只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、项目技能及 AUTH-110、AUTH-113、AUTH-117/118 的已接受证据。不得读 `.env`、凭据、私钥、`known_hosts` 正文、真实业务行、备份或旧 `D:\EliteSync`。
2. 纯函数仅接收调用方传入的虚构 stdout/stderr 字节、两流完整性及一个本地 SSH 退出候选；本轮不启动任何进程或连接。按 AUTH-118 的固定脱敏字段设计一个最小严格协议：每流至多 2 KiB、stdout 一行 LF 终止的严格 UTF-8 JSON，拒绝重复/额外/缺失键、BOM、控制字符、非法类型、未知枚举、非零或未知退出、stderr 非空、流不完整与协议矛盾。成功也只标记 `PATH_CANDIDATE_UNVERIFIED`，不得返回路径、路径哈希、环境值、指纹、原始文本或异常；失败清空肯定字段。
3. 用纯虚构字节覆盖正常、失败和秘密标记不泄漏；测试不得启动子进程。作者测试套件最多 3 轮，静态检查最多 2 轮。记录最终文件 SHA-256、预算、通过项及 `UNKNOWN`。候选交 Work LEVEL 2 独立审查，不提交、推送、自接受或派发后继。
4. 禁止 SSH、远端程序、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、密码输入、部署、备份、导出、传输、停写、DDL/DML 或删除。AUTH-17/101/107 等旧预算不重置，AUTH-99 禁止运行。

## 停点

Owner 已在当前 Work 会话回复“我在”，仅确认当前到场，不放行任何 UAC、密码或生产动作。现时可信 host-key 来源、远端启动语义、工具路径/身份仍 `UNKNOWN`；AUTH-107 Phase B、真实 SSH/DB/备份均未放行。真实备份须独立前置门及 Owner LEVEL 3 单次授权。

Work 已在 `EVIDENCE/AUTH-119-LOCATOR-RECEIPT-STRICT-PARSER-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT；本任务不再 ISSUED。作者测试 3/3、静态检查 2/2 已耗尽；Work 独立复跑最终 42 项通过。本接受仅涉及虚构字节解析，不授权现场连接。
