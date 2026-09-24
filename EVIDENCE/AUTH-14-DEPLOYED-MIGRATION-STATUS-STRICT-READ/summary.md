# AUTH-14｜部署目录迁移状态严格只读观察

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `9f2cc3af2737c78a8351c79eb66517c2bb9dee32`。类型：一次受限远端 Laravel CLI 迁移账本视图；没有数据库写入、备份、导出、恢复或结构变更。

## 前置门与一次远端读取

- 本地仅检查指定私钥与既有 `known_hosts` **存在**，均存在；未读取其内容。AUTH-13 已接受解析器文件存在；先运行精确 `python -B -m unittest test_migration_status_parser.py` **1/1 次**，退出码 0，**12 tests OK**，均为合成输入。测试通过后才连接远端。
- SSH 进程调用 **1/1 次**，使用任务指定主机/用户与私钥，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码与键盘交互并以 `-T` 禁用 PTY；外部等待上限 30 秒。唯一远端命令是 `cd /opt/elitesync/services/backend-laravel && php artisan migrate:status --no-interaction --no-ansi`。未追加 `--database`、`--pending` 或其他探测。
- 本地内存并行接收 stdout/stderr，合计上限 128 KiB；本次 stdout **4,712 bytes**、stderr **0 bytes**，无超时或超限，SSH 进程退出码 **0**。原始 stdout/stderr 未打印、未落盘、未进入普通回执；stdout 原样交给 AUTH-13 已接受的 `parse_migration_status()`，**完整解析成功**，没有临时修改解析器或放宽条件。

| 精确迁移名 | 本次 CLI 连接视图状态 |
|---|---|
| `0001_01_01_000000_create_users_table` | `Ran` |
| `2026_03_11_144705_create_personal_access_tokens_table` | `Ran` |
| `2026_03_23_200000_add_synthetic_flags_to_users_table` | `Ran` |
| `2026_04_09_120000_add_account_layer_fields_to_users_table` | `Ran` |

本次完整解析的迁移行总数 **57**，已运行 **57**，待运行 **0**。这些只是在本次部署目录 CLI 所选连接和 migration 文件集合下的账本视图；不证明实际表/字段/索引与本地 migration 一致，也不证明 Web worker 使用同一数据库配置、账号范围、备份可恢复性、真实 `T0` 或生产行为。AUTH-11 那次 stdout 的失败原因仍不可追溯；本次是 AUTH-14 新派发的一次读取，不是 AUTH-11 预算重试。

## 范围与检查

本地仅读取控制文件、AUTH-11～13 接受记录、解析器/合成测试及四条精确 migration 文件；远端仅执行上述获准的迁移账本 CLI 读取。未读取 `.env`、私钥内容、实际配置值、账号或业务数据行、Token、日志或用户/媒体内容；未运行 HTTP/API、设备、数据库写入、备份、导出、恢复或迁移，未访问旧 `D:\EliteSync` 或 GitHub。唯一允许新增文件为本 `summary.md`；原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。

`git diff --check` 按预算运行 **1/1 次，exit 0、无输出**；该命令不覆盖未跟踪新文件。本文件另作只读检查 24 行，尾随空白 **0 行**；无 tracked 改动。作者不提交、备份、推送、自接受或派发后继；候选停在 Work LEVEL 2 独立 ACCEPT/REJECT。未来备份、恢复演练或 schema 变更须另立精确任务并过相应 Owner 高风险门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本次部署目录 CLI 迁移账本视图的受限事实。** Work 核对发布基线 `9f2cc3af2737c78a8351c79eb66517c2bb9dee32`、唯一新增路径、24 行无尾随空白和 AUTH-13 已接受解析器的固定四目标/全量拒绝边界。作者回执记载先通过 12 项合成测试，再以新任务的一次 SSH 执行精确 `migrate:status --no-interaction --no-ansi`，退出 0、stderr 0 字节、stdout 4,712 字节且严格解析成功；由此报告四条目标均 `Ran`，总数 57、已运行 57、待运行 0。Work 未再次连接服务器，原始 stdout 未保存，因此不能离线重算；远端执行与解析成功细节依赖作者的一次性回执。

本接受不证明这些 migration 对应的表、字段和约束真实完整，不证明 Web worker 使用相同 DB、账号只有测试数据、备份可恢复或生产已就绪。AUTH-14 的 SSH 预算已耗尽；后续若确需改库，仍须先对实际目标做另行授权的只读 schema/数据范围核验、完整备份与隔离恢复校验，再审查精确 migration。
