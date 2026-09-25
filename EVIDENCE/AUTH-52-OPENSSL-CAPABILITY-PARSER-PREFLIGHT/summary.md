# AUTH-52｜OpenSSL capability parser preflight

状态：**作者候选；待 Work LEVEL 2 独立 ACCEPT/REJECT。** 日期：2026-09-25（Asia/Shanghai）。

## 候选范围

- `parser.py`：纯内存解析接口 `parse_openssl_version(exit_code, output)` 与 `parse_aes_256_gcm_listing(exit_code, output)`；不执行进程、不读取文件、环境变量或主机状态。
- `test_parser.py`：12 项完全虚构的 `unittest` 用例；未使用或复制服务器输出。
- 本摘要：作者回执。

版本仅在退出码为零且存在唯一、明确的 `OpenSSL <数字版本>` 行时返回版本 token；空值、非零退出、普通正文、畸形或超限输入均返回 `UNKNOWN`。

算法列表结果严格分为：

| 结果 | 含义 |
|---|---|
| `LISTED` | 退出码为零，输入符合本预检接受的完整行式 cipher-list 格式，并出现大小写不敏感的完整 token `AES-256-GCM` 或显式等价 `id-aes256-GCM`。 |
| `NOT_LISTED` | 退出码为零，输入符合上述完整格式，但没有该完整 token；只说明该次已解析列表未列出，**不证明服务器不支持**。 |
| `UNKNOWN` | 非零退出、空值、超限、NUL、畸形/普通正文/疑似截断或无法按本地格式确认完整的列表；不对服务器能力作推断。 |

相似的 `AES-256-GCM-SIV`、前后拼接 token 和正文提及不能判为 `LISTED`。

## 本地验证

- targeted 测试共 **2/2** 次：第 1 次为 TDD 初始 RED，因解析器尚不存在而导入失败；第 2 次 `python EVIDENCE\AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT\test_parser.py`，**PASS，12/12**。覆盖版本成功/失败、大小写、别名、相似算法、非零退出、空/畸形/超限，以及格式有效但无目标 token。
- `git diff --check`：执行 **1/1** 次，**PASS**（退出码 0）。
- 三个新增文件只读尾随空白检查：**PASS，0 行**。

## 边界与停点

本任务未连接 SSH，未调用 CloudShell、云 API、数据库、备份、密钥、U 盘或账户资料；未读取服务器、本机真实备份或真实密钥目录。没有判定任何实际服务器 OpenSSL 版本、AES-256-GCM 支持、CMS 互通、备份或恢复能力。

AUTH-51 的 SSH 预算仍为 **1/1 已耗尽**，本解析器不得用于启动补测。作者不提交、不推送、不自接受、不派发后继；停在 **Work LEVEL 2** 门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受纯本地虚构输入的解析预检。** Work 对照已发布任务与 HEAD `5170bb515575f068135d0b0bd0ad8e4888a410d5` 静态审查三个候选文件。解析器无进程、文件、环境变量或网络调用；版本只接受唯一明确的 OpenSSL 版本行，算法名称使用大小写不敏感的完整 token 比较，非零退出、空值、超限、畸形行回落 `UNKNOWN`。`NOT_LISTED` 只指本次输入中未列出，绝非服务器不支持。

审查前 SHA-256：`parser.py` 为 `836CB2D25A08EE628DD23B962D0E6B55EC792A51A51A920CE6F147B75277DD11`，`test_parser.py` 为 `6B32528809C1F2D8FEB96BA75154056FC2755E6B141947206BA1A29894F7CE85`，本文件为 `CE66F6445B263D3561197A8BF01F3C6B288B51696E3E22AEADB4F4F8B32B30D4`。作者报告 targeted 测试 2/2 次（先 RED，后 12/12 PASS）及 `git diff --check` 1/1 PASS；Work 未重复预算内测试。三个文件独立尾随空白检查均为 0 行。测试产生的两个额外未跟踪 `__pycache__` 文件已按精确路径清理，保留无关未跟踪目录。

这里的“完整”只表示输入符合本解析器接受的行式格式；解析器本身无法证明调用方是否截断了采集流。未来服务器任务须单独固定 stdout/stderr 捕获上限、完整读取与截断失败门；否则即使返回 `LISTED` 或 `NOT_LISTED`，也不得升级为服务器结论。本 ACCEPT 不证明实际服务器版本、算法列出、CMS 互通、真实备份或恢复能力；没有使用 AUTH-51 已耗尽的 SSH 预算。
