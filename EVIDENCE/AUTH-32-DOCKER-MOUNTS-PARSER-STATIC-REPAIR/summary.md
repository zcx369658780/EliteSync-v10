# AUTH-32｜Mounts 解析器纯本地修正回执

状态：Codex 候选，待 Work LEVEL 2 独立 ACCEPT/REJECT。执行日期：2026-09-24（Asia/Shanghai）。

## 前置与范围

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `35ab258c3d3bd4824de01ac358031775393a5235`，父提交 `d050792c90092b6f8b4549528dd8b28e7f652f83`，符合任务单派发拓扑。工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；仅新增本目录的三个文件。
- `TASK_CURRENT.md` 为 `AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能及 AUTH-30/31 的 Work LEVEL 2 REJECT 与失败记录。旧两次容器运行预算未重置。

## 候选与一次测试

`parse_mounts.ps1` 提供纯函数 `Parse-Mounts`，只接收调用方传入的 Mounts 值，返回 `count`、`all_tmpfs`、`destinations_allowed`、`parse_ok`。null 与空数组安全返回 `count=0`；此时两个安全布尔值均为 `false`，不能把空集合单独作为隔离 PASS。非数组输入返回 `count=UNKNOWN` 且拒绝；非对象、缺失字段、非字符串字段、bind/volume、超出三个固定目标及重复目标均使 `parse_ok=false`。数组长度在访问前经过类型核对，不使用 `$null.Count`。

两个脚本的 PowerShell 静态解析均为 **0 个错误**。`test_parse_mounts.ps1` 按预算执行 **1/1 次**，回执 `PASS`、**14/14** 个虚构断言通过、最早失败 `NONE`。覆盖 null、空数组、三个及单个合法 tmpfs、bind、volume、额外目标、缺 Type、缺 Destination、标量对象、畸形标量、畸形数组元素、重复目标及严格模式下 `if` 空数组赋值后的安全计数。负向用例明确拒绝；测试未调用 Docker、WSL、SSH、云或数据库。

验证：`git diff --check` 按预算执行 1/1 次，退出码 0、无输出；该检查不覆盖未跟踪新文件，三个文件另作只读尾随空白检查，均为 0 行。

这只证明解析器在所列虚构输入上的本地语义。AUTH-30/31 当次 Docker `Mounts` 的实际值仍为 `UNKNOWN`；也不证明 HostConfig.Tmpfs、Binds、端口、网络及 ID/名称共同满足隔离，更不证明恢复能力。未来若需真实容器诊断或虚构恢复，须另立任务与新预算。本任务未访问旧仓库、浏览器、Docker、SSH、云、真实 DB、备份目录、凭据、密钥或业务数据，未备份、传输、恢复、删除或改库。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受 Mounts 解析器的纯本地语义及 14 项虚构测试回执。** Work 核对派发 HEAD `35ab258c3d3bd4824de01ac358031775393a5235`、唯一候选目录中 `parse_mounts.ps1` 原 73 行、SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974`，`test_parse_mounts.ps1` 原 54 行、SHA-256 `7727BF52EC89BF14DD61B2D30C2FC5A9C1F75344BF43A8F338D0201522CC6F69`，本 `summary.md` 原 18 行、SHA-256 `542E8EDF360EE3C7F161C924751E00CF471106ED557BCB27CEC79B43911E8C8F`；三文件均无尾随空白。独立运行 `git diff --check` 退出 0，不覆盖未跟踪文件。作者报告脚本各 0 个解析错误、一次测试 14/14 PASS；Work 未重复消耗一次性测试预算。

静态审查确认函数在访问长度前区分 null、数组与畸形值；空集合返回 count 0，但安全布尔值为 false，不能单凭空集合过门；bind、volume、额外/重复目标和缺字段均 fail-closed。此接受不证明 AUTH-30/31 的原始 Docker inspect 内容或完整隔离，也不授权真实数据恢复。
