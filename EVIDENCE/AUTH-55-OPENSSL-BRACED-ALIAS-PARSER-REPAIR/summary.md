# AUTH-55｜OpenSSL 花括号别名格式解析修复

状态：作者候选，待 Work LEVEL 2 独立 ACCEPT/REJECT。日期：2026-09-25（Asia/Shanghai）。

## 入口与候选

- 本地 `D:\EliteSync-v10`，`main`，执行前 HEAD `5c04a07e7004576a8fa02bd78c6d3d5790bfc883`。任务 `AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR` 为 `ISSUED — NOT STARTED`，指派 Codex，LEVEL 2。
- 已核对项目入口、产品决定、任务单、风险门、本地工作流技能及 AUTH-53/54 验收。原有无关未跟踪目录保持原状。
- 仅新增 `parser.py`、`test_parser.py` 和本文件。解析器沿用 AUTH-54 纯内存接口与严格边界，并接受 `{ name, alias [, ...] } @ provider` 无数字 OID 行；仅检查花括号内完整算法名，忽略 provider 名称。

## 验证回执

| 阶段 | 状态 | 受限事实 |
|---|---|---|
| 纯虚构 targeted 测试 | PASS | 1/2 次，12/12。覆盖新格式正反例及旧格式回归。 |
| 本机完整列表只读核验 | PASS | 1/1 次；本机 `openssl list -cipher-algorithms` 退出码 0，stdout 9010 字符，新解析器结果 `LISTED`，首个不合格式行类别 `NONE`。完整列表未保存或显示。 |
| `git diff --check` | PASS | 1/1 次，退出码 0；不覆盖未跟踪的新文件。 |
| 新文件尾随空白 | PASS | 三个文件均为 0 行。 |

本机 `LISTED` 仅指这次本机完整采集的可解析列表列出 AES-256-GCM；不证明服务器状态、CMS 加解密互通或真实备份恢复能力。AUTH-53 服务器 AES-256-GCM 是否列出继续为 `UNKNOWN`，且其 SSH 预算已耗尽。本地格式缺口不能回推为 AUTH-53 远端失败根因。

本任务没有连接 SSH、CloudShell 或云 API，没有触碰真实数据库、备份、密钥、U 盘、Owner 密码或旧仓库。没有修改旧证据和控制文件，也未提交、推送、自接受或派发后继；停在 Work LEVEL 2 门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受本地解析修复及当次本机列表格式核验。** Work 对照派发 HEAD `5c04a07e7004576a8fa02bd78c6d3d5790bfc883`、任务单与三个候选文件，静态确认新花括号别名行仅取算法名，provider 不参与目标判定；原有完整 token、异常回落及三态接口保留。作者报告 1/2 次虚构测试 12/12 PASS，本机列表核验 1/1 次返回 0、9010 字符、解析 `LISTED`；`git diff --check` 1/1 退出 0。Work 未重复预算内测试或本机列表命令，独立尾随空白检查三文件均为 0 行。

审查前 SHA-256：`parser.py` 为 `704A755D9785E24C0C2FFE3814E0B907BDFD04885BCFE09C93BD6DA14B8B2C8C`，`test_parser.py` 为 `CAFC8B50AA595510BCCB150DAA994999DC2850E50053C51F5CF42129FE2C05BD`，本文件为 `CAC782AC54ED2F511B04F3C19A71025F2D8249838430B5550270F39A7D43BD2A`。未保留原始本机列表；命令结果依赖作者受限回执。本机 `LISTED` 不能证明远端格式相同，AUTH-53 的 AES-256-GCM 列出状态仍 `UNKNOWN`。未来远端观察须另立连接预算、完整采集与独立 Work 审查；本验收不授权真实密钥、备份或恢复。
