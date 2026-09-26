# AUTH-106｜dump 工具帮助文本严格解析候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；`D:\EliteSync-v10`、本地 `main`、HEAD `bacb48fa8d49ab6f2a33fcc7c16b980fe2d1fc10`。启动时已有 `CURRENT.md`、`TASK_CURRENT.md` 修改、AUTH-105 未跟踪目录及两个无关未跟踪目录，均保留原状。本任务仅在 `EVIDENCE/AUTH-106-DUMP-TOOL-HELP-STRICT-PARSER/` 新增 `parser.py`、`test_parser.py` 和本回执。

## 候选边界

`parse_dump_text()` 是纯函数，只接受调用方交入的 `--version`/`--help` UTF-8 **字节串**、各自 stderr、退出码及捕获完整标志。它不启动进程、不读文件、不接网。版本文本最多 256 bytes、帮助文本最多 24,576 bytes / 240 行；非零退出、非空 stderr、非 UTF-8、截断、超限、控制字符和异常布局均不产出选项肯定结论。输出限协议版本、`MATCH_10_11_TEXT`/`UNKNOWN`、固定九项选项的 `PRESENT_IN_TEXT`/`ABSENT_IN_TEXT`/`UNKNOWN`、输入字节计数和固定错误类别；不回显原文或异常。

**帮助布局是刻意狭窄的虚构语法**：同版本 banner、固定 Usage 行、`Options:`、行首双空格的独立选项定义行、`End options.`。选项仅在完整识别这个布局时标记“文本中出现/缺席”；正文示例、子串、重复行及其他布局一律 `UNKNOWN`。该语法**没有被证明是 MariaDB 10.11.14 的真实 `--help` 格式**。若将来受限现场输出不同，解析器应 fail closed，不能为取得 PASS 而临场放宽。即使 `PRESENT_IN_TEXT`，也只描述输入文本；不能证明文本来自目标主机的哪一个二进制、当前默认行为、拟备份账号权限、对象全集、dump 成功或恢复成功。调用方的主机/文件身份与采集预算必须由另一个任务独立证明。

AUTH-105 只接受 MariaDB 官方资料下的静态选项边界；AUTH-17 的 `mysqldump 10.11.14` 是旧一次主机观察，现时身份和帮助布局仍 **UNKNOWN**。本任务不把虚构测试当现场工具能力。

## 预算与验证

| 项目 | 用量 / 结果 |
| --- | --- |
| 纯虚构测试套件 | **1/1 次**；退出 0，`SYNTHETIC_CHECKS_PASS=20`。覆盖正常、选项缺席、重复、示例/子串误判、注入尾随行、布局变化、截断、非法 UTF-8、超长、版本不符、非零退出和 stderr。 |
| 静态检查 | **1/1 次**；退出 0，`STATIC_AST_PASS=2;TRAILING_WHITESPACE_LINES=0;FILES=3`。只核对两个 Python 文件语法和三个新文件的尾随空白，未运行真实工具。 |
| 真实工具/主机/DB 调用 | **0**；无现场预算授权。 |

`PRESENT_IN_TEXT` 不得转写为“目标工具支持”或备份 `PASS`；真实帮助文本若不合本语法，目标能力保持 `UNKNOWN` 并交新的设计/审查门。后继如需一次只读现场工具核验，Work 须另发固定主机、二进制身份、命令、超时、输出上限、脱敏采集和失败即停预算；真实备份另须完整对象、权限、一致性、加密/传输、隔离恢复门与 Owner LEVEL 3 单次授权。

本轮未读取 `.env`、凭据、私钥、业务数据或真实备份，未访问旧 `D:\EliteSync`；未执行 SSH、生产 HTTP/API、Laravel CLI、真实 DB、Docker、云控制台、OpenSSL、UAC、部署、dump、备份、导出、传输、停写、DDL/DML 或删除。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 审查门。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT 仅纯函数解析器的虚构输入拒绝边界。** Work 逐项审查 `parser.py`、`test_parser.py` 和本回执，并独立执行一次 `python -B test_parser.py`，退出 0、`SYNTHETIC_CHECKS_PASS=20`。解析器不启动进程、不读文件或网络；非零退出、stderr、截断、超限、畸形布局和重复选项不会给出选项肯定结论，返回值不回显输入。

其版本 banner、Usage、选项行和 `End options.` 是人为定义的虚构语法；**未证明目标主机的真实 `--help` 使用这种布局**，所以此接受不等于有可用于现场的兼容解析器，更不能把 `PRESENT_IN_TEXT` 变为工具支持或备份能力 PASS。若后继只读工具观察的帮助文本不合此语法，必须保持 UNKNOWN、重新设计并审查，不能临场放宽。Work 未运行真实工具、SSH、DB、UAC 或备份；两个原有无关未跟踪目录保留。此任务到 LEVEL 2 门止。
