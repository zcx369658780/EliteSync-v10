# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR`

Risk Level: `LEVEL 2`（服务器补测前的本机格式解析门；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — LOCAL FORMAT PROOF ONLY`

Assignee: `Codex`。只交付纯解析器新版本、虚构测试、本机只读格式核验及受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：花括号别名解析修复与当次本机完整列表格式核验 LEVEL 2 ACCEPT；作者报告虚构测试 12/12 PASS，本机列表命令退出 0、9010 字符、解析 `LISTED`。此结果不更新服务器 `UNKNOWN`，见 `EVIDENCE/AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR/summary.md`。

## Authority and objective

AUTH-53 的服务器 AES-256-GCM 列出状态仍 `UNKNOWN`，其 SSH 预算 1/1 已耗尽。AUTH-54 虚构格式解析获接受后，Work **仅对本机** OpenSSL 3.5.6 算法列表作只读内存核对：命令退出 0、9010 字符，但 AUTH-54 仍返回 `UNKNOWN`；本机有 7 行 `{ name, alias } @ provider` 无数字 OID 格式未获识别。这是本地格式缺口，不证明远端 AUTH-53 失败原因。本任务修复该格式，并验证本机实际列表可解析后才考虑另立服务器补测。Owner 已授权继续；U 盘与密码此阶段不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-53/54 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR/parser.py`、`test_parser.py`、`summary.md`。复制并修订 AUTH-54 接口与严格边界，不改动 AUTH-52～54 历史证据、产品源码或控制文件。
- 解析器只处理输入内存字符串与命令退出码，不运行进程、不读文件/环境变量；保持 65536 字符上限、完整算法名的大小写不敏感匹配、`LISTED/NOT_LISTED/UNKNOWN` 三态、非零/空/NUL/畸形回落 `UNKNOWN`。在原四类有效行之外，接受 `{ name, alias [, ...] } @ provider` 无数字 OID 行；只从花括号内完整算法名匹配，provider 名不得影响结论。空花括号、错误分隔符、相似后缀、截断或正文提及不得误判。`NOT_LISTED` 仍仅指所给可解析列表未列出，不推断服务器不支持；调用方完整采集为独立门。
- 纯虚构 targeted 测试最多 2 次，覆盖新格式正反例和既有格式回归。代码定稿后可对**本机** `openssl list -cipher-algorithms` 做最多 1 次只读内存格式核验，输出仅本机命令退出码、字符数、解析三态及若失败的第一个不合格式行类别；不得保存完整本机列表，更不得读取/复用服务器原始输出。`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

不得连接 SSH、CloudShell 或云 API；不读取或改动真实 DB、备份/密钥目录、U 盘、Owner 密码、业务数据或旧 `D:\EliteSync`。本机解析通过仍不证明服务器 AES-256-GCM 列出、CMS 互通或真实备份恢复。回执保留 AUTH-53 `UNKNOWN`、候选范围、测试与停点。Codex 不提交、制作 bundle、推送、自接受或派发后继；Work 独立验收后才可另立新的一次服务器任务。
