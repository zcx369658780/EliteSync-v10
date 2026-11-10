# AUTH-21｜登录事件本地虚构持久化预检

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `e4edabef0c8e6bdc1f170d90ab31a56fa3b41eca`。类型：仅本地内存 SQLite 的 auth/未来数据模型样例；不作为 Laravel migration、产品写入器或真实权限来源。

## 三条候选与来源

仅新增 `EVIDENCE/AUTH-21-LOGIN-EVENT-LOCAL-PERSISTENCE-PREFLIGHT/schema_candidate.php`、`EVIDENCE/AUTH-21-LOGIN-EVENT-LOCAL-PERSISTENCE-PREFLIGHT/test_schema_candidate.php`、`EVIDENCE/AUTH-21-LOGIN-EVENT-LOCAL-PERSISTENCE-PREFLIGHT/summary.md`。只读核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能、AUTH-08/09/10/20 接受记录，以及本地 `users`/Sanctum Token migration、`AuthController.php` 和 `User.php`。本地静态源码中 register、login、refresh 均可签发 Token，现有 Token/用户时间戳不能代替服务端确认的成功交互登录事件；AUTH-20 聚合元数据不建立真实登录持久化。

样例每次只打开新的 `sqlite::memory:`，用抽象 `account_ref`、`device_ref`、`event_key`、虚构顺序与 `t0_tick`。事件键全局唯一，同账户/设备/顺序另有唯一约束；外键只约束虚构账户。记录操作在本地事务中拒绝非交互事件、调用方声明的失败/未确认、禁用或不存在的账户、旧/冲突顺序与倒退时间；完全相同的事件键与内容返回 `DUPLICATE`，不新增行。锚由同账户/设备的最新事件推导，不另存可被覆盖的锚；无事件返回 `UNKNOWN`。这些输入的成功与来源确认仍只是**虚构调用方声明**，本样例没有验证身份、设备或可信时间。

## 验证回执

| 检查 | 实际结果 |
|---|---|
| 本机 SQLite 能力 | `php -m` 显示 `pdo_sqlite`、`sqlite3`；未安装或更换依赖。 |
| `php -l schema_candidate.php`、`php -l test_schema_candidate.php` | 两文件各 **1/1 次**，均无语法错误。 |
| `php test_schema_candidate.php` | **1/1 次**，退出码 0，**26 fictional SQLite checks PASS**。覆盖首次 `UNKNOWN`、幂等重复不增行、事件键跨账户/设备冲突、设备/账户锚隔离、同序与旧序冲突、时间倒退、失败/未确认登录、注册/refresh/Token rotation、禁用或不存在账户均不写事件。 |
| `git diff --check` | **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。 |
| 三个新增文件尾随空白 | 分别只读检查，均为 **0 行**；无 tracked 改动。 |

上述是单进程顺序操作的 SQLite 内存预检，不证明多进程并发、MySQL/MariaDB 兼容、Laravel 集成或现场库结构。没有签发离线凭据、建立在线读发权限或执行 15/30 天期限与私密内容清理；不授权部署 migration。

## 生产 schema 未决项与停点

- 账户与设备的受信绑定证明、设备轮换/丢失及真实身份来源；本样例的文本引用不是设备证明。
- 服务端成功交互登录的可信时间、跨节点可比较顺序、幂等键生成者及重试/并发事务策略；`t0_tick` 和顺序均为虚构输入。
- 账号删除、事件保留/删除、数据权利、已知撤权/登出/禁用的持久化与传播；样例外键不决定生产清理政策。
- 目标数据库上的字段类型、索引与并发冲突处理、旧用户缺可信事件时的 `UNKNOWN` 迁移/兼容、回退及经备份和隔离恢复验证后的真实 migration 门。

本轮未读取 `.env`、真实配置、私钥、账号/Token/日志/媒体或业务数据行；未 SSH、HTTP/API、设备、远端 DB、备份、导出、恢复、migration 或部署。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、推送、自接受或派发后继；候选停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地虚构 SQLite 持久化预检。** Work 在 `e4edabef0c8e6bdc1f170d90ab31a56fa3b41eca` 基线上核对恰好三条允许候选、无其他 tracked 改动，并逐项审查建表约束、事务插入、同键幂等、账户/设备隔离、较旧或同序拒绝、非交互事件拒绝及无锚 `UNKNOWN`。三文件独立只读尾随空白检查均为 0 行；作者回执报告两次语法检查各 1/1、虚构 SQLite 测试 1/1 且 26 项 PASS、差异检查 1/1 PASS。Work 未重跑这些一次性命令，运行结果依据作者回执；静态源码与测试覆盖经 Work 独立核对。

本接受不证明服务端成功登录来源、设备绑定、可信时间、并发事务、MariaDB 兼容、撤权/删除政策或线上 schema。样例不进入 Laravel 生产路径，不签发离线凭据，不授权在线读发、服务器备份、恢复或 migration。上述未决项须在后继精确任务与相应风险门解决。
