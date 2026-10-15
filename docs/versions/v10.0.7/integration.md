# v10.0.7 K08 安全代码集成与本地接续

结论：**V10.0.7 K08_INTEGRATION_COMPLETE**。独立验收保持 **ACCEPT WITH OBSERVATIONS**；这是已接受成果的安全集成，不是再次验收，不修改冻结8项AC。

## 身份分开登记

| 对象 | 固定身份 |
|---|---|
| 已接受R1候选 | `cf0c359b86e35c794da389a58ba0b687c3c0bd32` / Tree `11f1d086b0c9180998a3684c0df176e1d9c4d2b2` |
| 原候选分支 | `codex/v10.0.7-app-restoration`，保留不移动 |
| 执行前实际GitHub main | `3561c51abbbda8ee4b32ec7a19eb9825aae99951` |
| GitHub产品集成commit/tree | `18c1ddb67378518b6b2c3e912e1e3b2afd394051` / Tree `4cde05f06079a8bd4879ae34a31db7ac0c30c625` |
| 本地产品接续基线 | 同上产品commit/tree，复用 `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，分支 `codex/v10.0.7-k08-integration` |
| 后续登记与最终本地HEAD | 仅追加本K08登记和安全核验；精确最终main及本地HEAD/tree见Owner集中回报和本机 `v1007/k08/publication.json`。文件不自引用自身commit。产品对象保持上行身份 |

Astra[最终验收](acceptance.md)及[复盘](retrospective.md)、固定[R1交付](https://github.com/zcx369658780/EliteSync-v10/blob/cf0c359b86e35c794da389a58ba0b687c3c0bd32/docs/versions/v10.0.7/R1_EXECUTION_REPORT.md)及现行[工作流K08](../../workflow/CURRENT_WORKFLOW.md)均在操作前实际读取。验收和复盘原文保留；其K08 PENDING是验收时历史状态，由本登记接续，不重写独立裁决。

## 集成选择与精确验证

实际main相对实施起点 `0989812c141ce892915b67c14e9291d34e3c7053` 没有apps/services代码变化。以实际main建立同一专用树中的集成分支，接入接受候选的90项Android、Flutter、Laravel、迁移、测试及题库路径，以及588项main原先没有的本版报告、必要开发运行工具和安全原证。没有整包覆盖main历史。

main已有冻结plan、Astra R1意见、acceptance、retrospective及全部其它非产品对象在产品提交时保留；当前状态、动态目录、恢复台账和版本目录只在后续登记提交前置追加K08事实，原文保留。[路径选择](integration-evidence/integration-selection.json)及[身份核验](integration-evidence/source-identity-check.json)可复核。

产品集成的完整 `apps`、`services`、`question_bank` 子Tree及 `dating_question_bank_v_1.json` Blob均与最终接受R1候选完全相同，涵盖R1 NotificationService、发送服务、controller、account.active路由与真实权限回归测试。不是仅对初始候选取代码，也不是仅检查少量具名文件。后续登记不修改这些对象；原交付及R1全部失败日志保持原Blob，不清洗、不重标。

## 本次实际检查和NOT_RUN

本次实测：

- 完整产品对象与最终接受候选一致；main既有非产品对象逐项保留核对，见[验证记录](integration-evidence/integration-validation.json)。
- 通知服务、原子发送服务、通知controller及API路由4项PHP语法检查均exit0；只解析源码，不加载应用、不连接数据库。
- 默认diff检查继承CRLF尾部提示exit2，原stdout/stderr保留；单次命令采用 `core.whitespace=cr-at-eol` 后exit0。不修改Git全局配置，不归一化已接受源码或原证。
- 本地AAR/APK重新计算物理SHA256，与接受包一致，仍仅LOCAL_ONLY：APK `fe3d9556977e5cbd34ec006a67537fd6f41efbc9d2a57e724f5d64932b102765`；AAR `76800ca93d696d8cfb0db87be930bd106927bb26edd45c4c730ec3193957acb5`。

**本次自动测试套件、Dart分析、APP构建/安装、APP/Web/API/DB业务及联合重启均NOT_RUN**：集成未产生相对接受候选的实质产品、测试、锁定依赖或运行工具差异。沿用已接受候选的真实功能证据，不冒称集成后重新运行。

已接受R1记录仍为：相关PHP27项/332断言exit0、相关Flutter36项exit0、全范围及lib分析无问题exit0；Flutter普通全量793通过/5失败exit1，带同次fixture全量821通过/3失败exit1。余3项旧Conversation文案、Match headline和synthetic UNKNOWN导航失败继续保留；缺同次fixture会再有2项输入失败。**这些是接受候选的既有结果，不能记作本次运行或全套PASS**。

## 保护及资源终态

原 `D:/EliteSync-v10` 未吸收代码、未pull/reset/clean/stash；本次HEAD/index/status及43个具名文件hash前后完全一致。历史105/109项未全量重验。无关工作树、EVIDENCE和LOCAL_ONLY未清理，没有访问历史SQL/VHDX、原3306真实库、真实用户或生产。

Docker只读核对：`elitesync-v1006-db` 与 `elitesync-v1007-db` 均exited，两个持久volume存在保留；本次未启动服务/AVD，未迁移/seed/写数据库。现有0.7私配及运行数据仍保留原R1终态，recipient12禁用、MC撤销不重置。

未运行事项及原vendor弃用、Android构建警告、旧通知开发数据明文保留政策等观察不变。后续恢复仍需Owner明确派发；本次不规划、冻结、实施v10.0.8，不执行生产发布。

原证在 `C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1007/k08`；安全核验见[索引](integration-evidence/index.json)。普通non-force推送及GitHub commit/tree回读后，Owner收到最终精确身份；本地保存发布回执。
