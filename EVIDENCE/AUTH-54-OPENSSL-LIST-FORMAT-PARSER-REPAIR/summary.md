# AUTH-54｜OpenSSL 列表格式解析修复

状态：作者候选，待 Work LEVEL 2 独立 ACCEPT/REJECT。日期：2026-09-25（Asia/Shanghai）。

## 入口与候选

- 本地 `D:\EliteSync-v10`，`main`，执行前 HEAD `21826dbc4de5eb9bb87fcbf9f734cab6d93b7e9b`。`TASK_CURRENT.md` 为 `AUTH-54-OPENSSL-LIST-FORMAT-PARSER-REPAIR`，`ISSUED — NOT STARTED`，指派 Codex，LEVEL 2。
- 已重新核对项目入口、产品决定、任务单、风险门、本地工作流技能及 AUTH-52/53 验收。无关未跟踪目录保留原状。
- 只新增 `parser.py`、`test_parser.py` 和本文件。`parser.py` 保留 AUTH-52 的 `parse_openssl_version`、`parse_aes_256_gcm_listing` 接口与 `LISTED/NOT_LISTED/UNKNOWN` 语义，接受额外的 `alias => canonical` 和 `name @ provider` 行；只从明确算法名字判定目标，不从 provider 标识判定。

## 本地验证

- 纯虚构 targeted 测试 **1/2 次，9/9 PASS**。覆盖原裸行、OID 行、新别名行、新 provider 行、大小写、别名两侧目标、相似名字、正文、错误分隔符、截断样式、非零退出、空值、NUL、超限和仅有 section 的输入。
- `git diff --check`：1/1 次，退出码 0；此命令不覆盖未跟踪新文件。
- 三个新增文件只读尾随空白检查：均为 0 行。

## 结论边界

本任务仅验证纯内存解析逻辑；没有读取真实服务器输出，也不能证明调用方完整采集。`NOT_LISTED` 仅表示所给可解析列表未列出，不等于服务器不支持。AUTH-53 当次服务器 AES-256-GCM 是否列出仍为 `UNKNOWN`；本地发现的新格式线索不是其失败根因证明。未连接 SSH/CloudShell/云 API，未接触真实密钥、备份、数据库、U 盘或 Owner 密码。没有修改旧证据或控制文件，没有提交、推送、自接受或派发后继；停在 Work LEVEL 2 门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受虚构输入下的本地列表格式解析修复。** Work 对照派发 HEAD `21826dbc4de5eb9bb87fcbf9f734cab6d93b7e9b`、任务单与候选范围，静态核对接口、四类可接受行、完整算法名比较和异常回落。新解析器只从别名/算法名判断目标，不把 provider 名称、相似后缀或普通正文计为目标；`NOT_LISTED` 不代表服务器不支持。作者报告 1/2 次 targeted 测试 9/9 PASS，`git diff --check` 1/1 退出 0；Work 未重复预算内测试。三文件独立尾随空白检查均为 0 行，无关未跟踪目录保留。

审查前 SHA-256：`parser.py` 为 `3E7D736F60A638DEC277D6C47640BE029AF071A7FC6DAA6CD439DBE34706FCAF`，`test_parser.py` 为 `9B15A0E449E431BF63CAE462920E80B9D2A2C8AD350DE7AAB0CF6FF9861687CF`，本文件为 `71A44BF14727EE4B628D8D2B05EB64F32DF64DF683238187CE0F9BCE37AB2AA1`。本次未观察服务器或原始 AUTH-53 列表，故不能判定 AUTH-53 失败的具体格式，更不更新其 `UNKNOWN`。后继若再采集服务器列表，须另立连接预算并保留完整采集、截断失败与独立验收门。
