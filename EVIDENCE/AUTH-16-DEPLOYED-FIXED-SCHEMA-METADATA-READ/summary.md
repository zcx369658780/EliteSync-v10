# AUTH-16｜部署目录固定 schema 元数据一次只读观察

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `6425bdce0ecab04896540aaf46155e6c35057610`。类型：本次部署目录 Laravel CLI 配置下的固定结构布尔投影；不代表 Web worker 连接同一数据库。

## 前置门与唯一远端读取

- 已接受 AUTH-15 探针的本地 SHA-256 精确为 `E290D5126EE59CFFEB752E75987DB6D5A2BE6D81A8F91F37AE6BD9EB82235E82`，与任务单一致。指定私钥及既有 `known_hosts` 仅检查存在，均存在；未读取其内容。先运行虚构 adapter 测试 **1/1 次**，退出码 0，**19 checks PASS**，未连接真实数据库。
- SSH 进程 **1/1 次**：指定用户、主机和私钥；`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互，`-T` 禁用 PTY。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`，stdin 仅送入上述探针的原始文件字节；未在远端保存文件或追加探测。外部等待上限 30 秒，stdout/stderr 合计上限 64 KiB。
- 本次 SSH 退出码 **0**，stderr **0 bytes**，stdout **475 bytes**，未超时或超限。原始输出仅在本地进程内接收，未打印或持久化。stdout 通过单行严格 UTF-8 JSON、重复键拒绝、固定键与布尔类型、driver 白名单、无额外字段和 `schema_complete` 一致性检查。

## 固定布尔投影

| 检查 | 当次 CLI 观察值 |
|---|---|
| `ok` / DB driver | `true` / `mysql` |
| 表 `users`、`personal_access_tokens`、`migrations` | 均 `true` |
| `users.id/phone/password/disabled/role/account_type/is_synthetic` | 七项均 `true` |
| `personal_access_tokens.id/tokenable_type/tokenable_id/token/created_at/last_used_at/expires_at` | 七项均 `true` |
| 单列唯一索引 `users.phone`、`personal_access_tokens.token` | 两项均 `true` |
| `schema_complete` | `true`，**仅指上述固定检查项全部存在** |

这不证明整表或整库 schema 完整、目标数据库身份、Web worker 使用同一连接、账号/关联数据范围、备份可恢复性、真实 `T0` 或生产就绪。AUTH-14 的四条迁移 `Ran`、57/57 仍仅是其当次 CLI 账本视图；本次是 AUTH-16 新派发的结构投影，未重置或重跑 AUTH-14 预算。

## 范围与停点

仅新增本 `summary.md`。`git diff --check` 按预算运行 **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。本文件另作只读检查，尾随空白 **0 行**；无 tracked 改动。未读取 `.env`、私钥内容、实际配置值、账号/Token/日志/媒体或其他业务数据行；未运行 HTTP/API、设备、数据库写入、备份、导出、恢复或迁移。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。未来备份、恢复演练或结构变更须另立精确任务和 Owner 高风险门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本次部署目录 CLI 配置下的固定 schema 元数据投影。** Work 核对发布基线 `6425bdce0ecab04896540aaf46155e6c35057610`、唯一新增回执路径、已接受探针文件的 SHA-256 `E290D5126EE59CFFEB752E75987DB6D5A2BE6D81A8F91F37AE6BD9EB82235E82` 和原候选 26 行无尾随空白。作者回执记载虚构测试 19 项通过，随后一次 SSH 以精确 stdin 探针读取，退出 0、stderr 0 字节、stdout 475 字节，完整 JSON 白名单校验通过；由此报告 MySQL、三张固定表、14 个固定字段及两个单列唯一索引均存在。Work 未再连接服务器，原始 stdout 未保存，远端执行与解析细节依赖作者的一次性回执。

`schema_complete=true` 仅代表上述固定项目齐备，不是整表/整库结构完整。数据库实例身份、Web worker 配置、实际账号与关联数据分类、备份和恢复能力仍 `UNKNOWN`；本接受不授权账号导出、数据库写入、迁移或生产发布。AUTH-16 的 SSH 预算已耗尽。
