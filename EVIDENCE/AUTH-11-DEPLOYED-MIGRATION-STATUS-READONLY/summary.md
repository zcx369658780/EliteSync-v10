# AUTH-11｜部署目录迁移状态一次只读观察

状态：`BUILDER FACT CANDIDATE — TERMINAL OUTPUT_UNSAFE_OR_UNPARSEABLE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发及执行基线 HEAD `84b42b0dbfc593b330598e310ff633cf84e9ae90`。类型：远端 Laravel CLI 迁移账本只读观察；未执行备份、导出、恢复、迁移或数据库写入。

## 已执行事实与停止原因

- 本地只检查 `C:\Users\zcxve\.ssh\CodexKey.pem` 和既有 `known_hosts` **存在**，均存在；未读取内容。
- SSH 进程调用 **1/1 次**，使用任务指定的 `root@101.133.161.203`、私钥、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，并禁用密码与键盘交互。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php artisan migrate:status --no-interaction`，外部等待上限 30 秒。
- 本地进程以内存接收 stdout/stderr，并按合计 128 KiB 上限处理；未超时、未触发输出上限。SSH 进程退出码为 **0**，stderr 为空。stdout **未通过预设的安全格式解析**，本地只输出错误类别 `OUTPUT_UNSAFE_OR_UNPARSEABLE`，未显示或保存原始 stdout/stderr。该类别不判定具体内容是格式差异还是敏感值；不能据此宣称迁移账本可读。
- 按任务“输出无法解析即停止”执行，**没有第二次 SSH**，没有改用远端命令、重定向、SQL 或配置读取。

| 指定迁移名 | 本次可披露状态 |
|---|---|
| `0001_01_01_000000_create_users_table` | `UNKNOWN — OUTPUT_UNSAFE_OR_UNPARSEABLE` |
| `2026_03_11_144705_create_personal_access_tokens_table` | `UNKNOWN — OUTPUT_UNSAFE_OR_UNPARSEABLE` |
| `2026_03_23_200000_add_synthetic_flags_to_users_table` | `UNKNOWN — OUTPUT_UNSAFE_OR_UNPARSEABLE` |
| `2026_04_09_120000_add_account_layer_fields_to_users_table` | `UNKNOWN — OUTPUT_UNSAFE_OR_UNPARSEABLE` |

迁移总数、已运行数、待运行数均为 **UNKNOWN**。零退出码只说明本次 CLI 进程退出状态；未取得可安全解析的迁移行，因此不证明任一 migration 已应用、实际表结构、Web worker 的 DB 配置、数据分类或备份恢复能力。AUTH-10 的未来改库前备份和恢复门未在本任务执行或解除。

## 范围与检查

只读核对本地控制文件、AUTH-10 接受记录和四个精确迁移文件。未读取 `.env`、私钥内容、实际配置值、数据库行、Token、日志或用户/媒体数据；未执行 HTTP/API、设备或真实数据库写入，未访问旧 `D:\EliteSync` 或 GitHub。唯一允许新增文件为本回执；原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。未运行产品测试或构建。

`git diff --check` 按预算运行 **1 次，exit 0、无输出**；该命令不覆盖未跟踪新文件。本文件单独只读检查 25 行，尾随空白 **0 行**；无 tracked 改动。作者不提交、备份、推送、自接受或派发后继；停在 Work LEVEL 2 独立 ACCEPT/REJECT。后续若需再查迁移状态，须由 Work/Owner 新发精确任务和预算，不能把本次一次性 SSH 预算重置。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受一次 SSH 的终止回执；目标迁移状态未完成。** Work 核对本地基线 `84b42b0dbfc593b330598e310ff633cf84e9ae90`、唯一新增候选文件、25 行无尾随空白和无其他任务改动。作者记录指定远端命令一次退出 0、stderr 为空，但 stdout 未通过预设安全解析，并在 `OUTPUT_UNSAFE_OR_UNPARSEABLE` 处停下；未保存原始输出，Work 无法离线复核其内容或四条迁移状态。没有第二次 SSH、数据库备份、导出或结构变更。

Work 独立查本地 Laravel `StatusCommand.php`：`migrate:status` 使用终端双栏输出，状态为 `Ran` 或 `Pending`，`Ran` 前有批次号；这说明固定行格式解析需要预检，但不证明本次远端输出失败的具体原因。四条目标迁移及总数仍为 `UNKNOWN`。AUTH-11 的一次性 SSH 预算已耗尽；任何新读取必须另立明确任务，不能把本回执当作可恢复性或改库许可。
