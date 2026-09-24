# AUTH-12｜`migrate:status` 本地解析预检

状态：`BUILDER SPEC CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。类型：`docs-only`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `13532768529ff721039173d1013b2cde50c2c4b3`。本文件只约束未来若另行授权的只读观察；AUTH-11 的一次 SSH 预算已耗尽，四条目标迁移状态与总数仍为 **UNKNOWN**。

## 1. 本地源码事实与 AUTH-11 的证据限度

| 本地来源 | 直接可见事实 | 对解析的影响 |
|---|---|---|
| `vendor/laravel/framework/src/Illuminate/Database/Console/Migrations/StatusCommand.php:53–91` | 命令先检查迁移仓库是否存在；不存在时报错并返回 1。通常从 migration 文件与仓库已运行列表、批次映射得到行；有行时先 `newLine()`、输出双栏标题、逐行输出双栏、再 `newLine()`。若无行，可输出 `No pending migrations` 或 `No migrations found`。 | 空行是正常形状；零退出码不自动证明已有行。输出是本次 CLI 所选连接和文件路径的视图，不是实际表结构或 Web worker 配置。 |
| 同文件 `:101–115` | 行第一栏是 migration 文件名；第二栏为着色的 `Ran` 或 `Pending`。已运行时在 `Ran` 前拼接 `[`批次号`] `。 | 应从右侧识别状态和正整数批次，不能把 `Ran` 当作单独固定列，亦不能用 Token 或用户数据推断。 |
| `Console/View/Components/TwoColumnDetail.php`、`Console/resources/views/components/two-column-detail.php` | 双栏组件经 mutator 与 Termwind 渲染；模板以 `flex`/`max-w-150` 布局，两个 span 之间用 `content-repeat-[.]` 生成点线。标题与状态含样式标记。 | 点线数量、前后空格和终端宽度不是稳定接口；是否出现 ANSI 样式或宽度折行取决于最终输出环境。不能用固定 `\.{2,}` 或固定列宽作为唯一接受条件。 |
| 本地 `php artisan migrate:status --help` | 本轮运行 **1/1** 次、退出 0；帮助列出 `--no-ansi`、`--no-interaction`、`--database`、`--pending`、`--path` 等选项。 | 下一次若另获授权，可明确禁用 ANSI、保持非交互；不要用 `--pending` 做迁移总数/已运行数统计。`--database` 对应哪一个实际目标仍须另行只读确认。 |

AUTH-11 已接受回执只证明：那次唯一 SSH 的远端命令进程退出 0、stderr 为空、未超时或超输出上限，stdout 未通过当时的安全解析；原始 stdout/stderr 未保存。**无法追溯**究竟是点线、ANSI、空白、宽度、版本差异、非预期文本还是其他因素导致拒绝。本地 vendor 源码也不证明远端正在运行相同 Laravel 版本或相同输出环境；不得补填四条迁移状态。

## 2. 后继若另行授权的安全输出与接受合同（**PROPOSED**）

1. **先固定授权对象**：新任务单需写明远端目标、用户、主机密钥规则、唯一命令、外部超时、输出字节上限、精确迁移名和一次性 SSH 预算；先在本地用纯虚构样例验证解析器，再执行任何远端读取。AUTH-11 的 SSH 不能重试或转作新预算。
2. **降低输出变化**：建议未来命令仍为只读 `migrate:status`，显式 `--no-interaction --no-ansi`，不分配 PTY；如使用 `--database`，须事先确认具体目标配置且获得任务授权。不加 `--pending`，否则已运行数和总数的口径改变。即使禁 ANSI，仍不可假定点线长度或终端宽度固定。
3. **接收与保密**：在本地进程内并行、有界接收 stdout/stderr；超时、非零退出、超字节预算、stderr 异常、解码失败或出现未批准内容就停止。原文不落盘、不进日志或普通回执。仅在整份输出通过白名单解析后，披露四条精确迁移状态及总数/已运行/待运行数量；不得披露其他迁移名、DB 标识、内部地址或账号值。
4. **整份输出验收**：先限制可接受的 UTF-8/行结束符与控制序列；若允许 ANSI，只剥离明确白名单内的 SGR 颜色序列，拒绝其他转义或控制字符。标题仅接受来源所示的 `Migration name` 与 `Batch / Status`；允许前后空行和可变空格。每一数据行必须含一个合规 migration 文件名、可变的布局分隔、右端精确 `Pending` 或 `[`正整数`] Ran`；不凭点数计数。行折返、额外非空行、重复名称、缺标题、无行、未识别状态或四条目标名缺一均拒绝，**不输出部分结果**。解析后校验 `total = ran + pending`。
5. **语义上限**：通过解析仅证明该次 CLI 连接视图中这些 migration 文件的账本状态和行数。即使显示 `Ran`，也不证明表与字段真实存在、数据范围、可恢复备份、Web worker 使用同一配置、真实 T0 或生产就绪。若本地与远端版本/宽度使完整白名单解析不可稳定，停止并另行审查结构化的只读迁移元数据接口；不能以宽松全文匹配或原始输出转储换取结果。

**解析顺序建议**：先验证整份输出不含未批准内容，再识别标题和每一行；对行从右端提取 `Ran`/`Pending` 与批次，对左端提取合规文件名，中间只作为布局分隔而不依赖长度。标题和行不能折返或互相拼接。仅在所有行都过关后统计并投影四条精确名称。该建议仍需针对将来获准的目标版本做纯本地合成预检，不是已验证的远端解析器。

## 3. 纯虚构最小样例（文档样例，未运行解析）

正例的两个文件名均为虚构值，点线长度只用于说明可变布局：

```text
Migration name ........................ Batch / Status
2026_01_02_030405_create_demo_alpha ... [2] Ran
2026_01_03_040506_add_demo_beta ....... Pending
```

预期仅在整份文本被接受后得到 `total=2, ran=1, pending=1`；若任务的四条目标名未出现在此虚构样例中，真实任务解析器仍必须返回 `TARGET_MISSING`，不能把样例当现场结果。

| 纯虚构负例 | 必须拒绝的原因 |
|---|---|
| `2026_01_02_030405_create_demo_alpha ... [2] Ran` 出现两次 | 重复 migration 名，不能双计数或择一。 |
| `2026_01_03_040506_add_demo_beta ... [x] Ran` | 批次非正整数。 |
| `2026_01_03_040506_add_demo_beta ... Applied` | 状态不在 `Ran/Pending` 白名单。 |
| 任一行中夹带非 SGR 控制序列、连接串、额外提示行或发生折返 | 无法完整安全分类，停止且不披露部分结果。 |
| 只有标题或 `No migrations found`、缺目标名 | 无法给出四条目标状态；不能把缺失默认为 Pending。 |

## 4. 本轮执行与停点

仅读取本地控制文件、AUTH-10/11 接受记录、指定 `StatusCommand.php` 与其直接调用的双栏组件、模板和必要 mutator；本地 `php artisan migrate:status --help` 运行 **1 次**。没有运行 `migrate:status` 本体、解析 AUTH-11 旧 stdout、SSH、HTTP/API、DB、设备、测试或构建；未读取 `.env`、凭据、日志、数据库行、Token 或用户/媒体内容。唯一候选写入是本 `spec.md`；原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。

`git diff --check` 按预算运行 **1/1 次，exit 0、无输出**；该命令不覆盖未跟踪新文件。本文件另作只读检查 50 行，尾随空白 **0 行**；无 tracked 改动。作者不提交、备份、推送、自接受或派发后继；停在 Work LEVEL 2 独立 ACCEPT/REJECT。下一次服务器读取必须由 Work/Owner 另立精确任务和预算。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地输出解析预检合同。** Work 核对发布基线 `13532768529ff721039173d1013b2cde50c2c4b3`、唯一候选路径、50 行无尾随空白，并复读本地 Laravel `StatusCommand.php` 与 `TwoColumnDetail.php`、双栏模板。源码确实生成 `Ran`/`Pending`、已运行批次号、双栏点线和可变空白；文档正确把这些格式因素列为可能性，没有将其说成 AUTH-11 的已证原因。正反例保持虚构，缺失目标、异常行、重复与无法完整解析时拒绝部分披露。没有服务器或数据库访问，也没有对真实迁移状态作新结论。

本接受仅确立下一次**另行授权前**应实现并在本地验证的解析边界；文档中的解析器尚未编码或运行，远端版本、输出形状、四条迁移状态仍 `UNKNOWN`。AUTH-11 一次性 SSH 预算仍已耗尽。
