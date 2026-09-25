# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-54-OPENSSL-LIST-FORMAT-PARSER-REPAIR`

Risk Level: `LEVEL 2`（服务器能力核验前的本地格式解析修复；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — LOCAL SYNTHETIC FORMAT REPAIR ONLY`

Assignee: `Codex`。只交付本地纯解析器新版本、虚构测试和受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：虚构输入中的裸算法、OID、别名和 provider 行解析修复 LEVEL 2 ACCEPT；作者报告 9/9 targeted 测试 PASS。仅本地解析门，不更新 AUTH-53 的服务器 AES-256-GCM `UNKNOWN`。见 `EVIDENCE/AUTH-54-OPENSSL-LIST-FORMAT-PARSER-REPAIR/summary.md`。

## Authority and objective

AUTH-53 一次 SSH 成功并取得 OpenSSL 版本 token `3.0.13`，但列表未通过 AUTH-52 的行式格式门，AES-256-GCM 是否列出仍 `UNKNOWN`；其 1/1 连接预算耗尽。Work 在本机 OpenSSL 3.5.6 的只读输出中观察到 `alias => name` 和 `name @ provider` 行，这是 AUTH-52 未接受的格式线索，**不能当作 AUTH-53 服务器失败的已证根因**。本任务仅在虚构输入中修复这两类格式，同时保留严格边界。Owner 已授权继续；U 盘、密码与真实数据不在本任务内。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-52/53 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。若状态或派发不匹配，停止。
- 只允许新增 `EVIDENCE/AUTH-54-OPENSSL-LIST-FORMAT-PARSER-REPAIR/parser.py`、`test_parser.py`、`summary.md`。复制并修订已接受 AUTH-52 纯解析接口，不修改历史 AUTH-52/53 文件、产品源码或控制文件。保持 `parse_openssl_version`、`parse_aes_256_gcm_listing` 接口和 `LISTED/NOT_LISTED/UNKNOWN` 语义，后继任务可明确选择新版本。
- 仅接收调用方内存字符串与退出码，不运行进程、不读文件或环境变量。保留 65536 字符上限、非零/空/NUL/畸形回落 `UNKNOWN`、大小写不敏感完整 token 匹配。扩展接受明确的 `alias => canonical` 与 `name @ provider` 行，以及 AUTH-52 已接受的裸算法行和 `{ OID, names } @ provider` 行；含目标 token 的别名或 provider 行须能判 `LISTED`。相似后缀、前后拼接、正文提及、错误分隔符、截断/无可识别行不得误判 `LISTED` 或 `NOT_LISTED`。即使返回 `NOT_LISTED`，也仅指该次可解析列表未列出，不推断服务器不支持。调用方是否完整采集仍是独立门。
- 虚构测试覆盖四种有效格式、大小写、别名、provider、相似名字及错误行、非零、空/超限/NUL。不得复制 AUTH-53 未保存的原始远端输出或使用服务器/密钥/备份/数据库材料。本地 targeted 测试最多 2 次，`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

本任务不连接 SSH/CloudShell/云 API，不读取或改动真实数据库、备份/密钥目录、U 盘或旧 `D:\EliteSync`，不要求 Owner 输入密码。回执写清测试、候选范围、局限和 AUTH-53 仍为 `UNKNOWN`。Codex 不提交、制作 bundle、推送、自接受或派发后继；Work 独立验收前，不得据此启动新的服务器探测。后续如需补测，仍须另立固定单次预算的任务。
