# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC

Risk Level: LEVEL 2（未来只读主机回执的本地接收、格式与泄漏边界；本轮仅纯虚构字节）

Status: ACCEPTED — LOCAL SYNTHETIC PARSER ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-109 已获 Work LEVEL 2 受限 ACCEPT，仅证明本地虚构子进程内采集与投影。AUTH-107 Phase A 要求未来 SSH 标准输出最多一行 2 KiB 严格 JSON，普通回执不得带远端原始工具文本或 SSH 错误。当前尚无经验证的**本地接收解析器**；本任务只用调用方提供的虚构 stdout/stderr 字节与退出码构造拒绝边界，不启动任何进程或访问网络。

主要结果为新目录 `EVIDENCE/AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC/summary.md`，可在该目录附解析器与测试。仅允许写此新目录；其他证据和控制文档只读。保留两处原有无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、入口、AUTH-107～109、项目技能与风险门。不得读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`。
2. 实现纯函数：只接收调用方显式给出的虚构 SSH stdout/stderr 字节、SSH 退出码和远端程序退出码候选。逐流严格上限 2 KiB；任一 stderr 非空、退出非零或未知、不完整、超限立即固定失败，绝不返回原始正文。仅接受一行严格 UTF-8 JSON、终止换行、无 BOM/ANSI/控制字符；拒绝重复键、额外/缺失键、错误类型、非法类别和计数、额外行、嵌套内容或未知版本。固定 schema 与 AUTH-109 的安全字段对齐，但不能把输入 JSON 当作真实主机身份/工具能力证明。普通返回值只允许固定字段/枚举和安全有界数字，任何异常不得回显原始字节、路径或消息。
3. 用纯虚构字节覆盖正常最小回执、双重退出/完整性门、stdout/stderr 超限及 stderr 非空、重复/额外键、UTF-8/换行/多行/控制字符、秘密标记不泄漏和 UNKNOWN 选项。测试最多 3 轮，仅实际失败修复可重跑；静态检查最多 2 轮。记录各轮及未验证的 SSH 进程级、远端程序级和实际工具风险。
4. 禁止启动 SSH、任何子进程、真实 dump、DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、备份、导出、传输、停写、DDL/DML、部署或删除。交候选后停在 Work LEVEL 2 独立审查，不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 仍未放行；真实主机工具路径/别名/哈希、SSH 身份与 host-key、环境净化、运行中 Web/CLI DB 同一性、账号权限、对象全集、一致性、加密传输和隔离恢复均 UNKNOWN。真实备份须另经 Owner LEVEL 3 单次授权。可能触发 UAC 的后继动作须先等 Owner 在**当前 Work 会话**输入“我在”，再经具体任务门；此前确认不沿用。AUTH-101、AUTH-17、AUTH-107 已耗预算不重置，AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT：仅本地纯虚构字节的有界解析，Work 独立复跑 42 项通过。本任务不再处于 ISSUED，不能据此启动任何现场进程。
