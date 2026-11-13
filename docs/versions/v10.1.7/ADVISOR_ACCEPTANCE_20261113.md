# v10.1.7 顾问验收

日期：2026-11-13（北京时间）。  
固定交付：`e6bc14f6456421e006d1073dfe64d3b28c243102`。  
结论：**ACCEPTED_SCOPED_V10_1_7 — 六项 AC 在约定开发范围内接受；本轮无需 R1 补修。**

## 1. 结论与停止点

依据 [版本任务](task_order.md)、[冻结计划](plan.md)复核当前实现、受影响测试设计、[实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/docs/versions/v10.1.7/IMPLEMENTATION_REPORT.md)及[交付清单](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/docs/versions/v10.1.7/artifact_manifest.json)，本次未发现要求继续补修的实质阻断。接受婚恋输入、实际筛选排序、普通候选生成与选择、参与恢复、本人历史及交付身份的已声明范围。

工程自验 PASS、顾问本次范围接受、Owner 最终接受分别记录。Owner 最终接受仍为 **PENDING**，不由本报告代替。Codex 保持集中交付后停止；后续讨论 v10.1.8 通信与通知范围，再具体下达任务。本次不自动开启下一版、合 main 或发布。

## 2. 验收绑定身份

| 项目 | 固定身份 |
|---|---|
| 仓库 / 分支 | `zcx369658780/EliteSync-v10` / `codex/v10.1.7-matching-journey-20261113` |
| 稳定根 | `D:\EliteSync-v10-product-v1015-20261101` |
| 任务发布 | `a33ee96c373ca7ccc5827f456106098325a0dc8b` |
| 本轮交付 | `e6bc14f6456421e006d1073dfe64d3b28c243102` |
| 后端源码 | `0229e9d8018296701236f8a9b5fc919fd66096d2` |
| APP 源码 | `44d4b96daa7e84d2f92c4385b258159de1c45dc1` |
| APK | `10.1.7-dev / 1010703 / com.elitesync.v1015dev / arm64-v8a`，123730978 字节 |
| APK SHA256 | `1afe17fff97fae81153e8de7e2ffeed174a48d639de55e42f77b45f7cf7d8a5e`，本机 APK/安装身份沿 Codex 报告 |

顾问独立核对：实施报告为 11,307 字节，其 SHA256 `bf7fd5fc69efcae7895c3471f5ca18eeba42477021929d8c400016ae025f5424` 与 manifest 一致；清单内 22 份必要部署文件的固定 Git Blob、字节数、SHA256 全部匹配；8 个 APP/后端子树 ID 全部匹配。

`44d4b96d → 0229e9d8` 仅修改后端结果标记和长度回归，APP 子树未变；`0229e9d8 → e6bc14f6` 仅增加报告、manifest 与 ACTIVE_STATE。最终 APP、后端和报告的组合身份成立。本次验收记录为后续文档提交，不改变已审产品代码。

## 3. 逐项验收

| AC | 顾问判断 | 依据与接受范围 |
|---|---|---|
| **AC17-01 输入与持久化** | **接受** | 本人输入具备 revision、确认版本、基本资料及目标题摘要；统一以本人关系目标派生匹配语义。非法区间/枚举拒绝，未确认与明确不限分开；可选字段默认私密、可清除，保存与报名分开。APP 真实保存/重登及旧值处理与报告一致。 |
| **AC17-02 实际筛选与排序** | **接受** | 双方年龄/地域、成年、用途及当前资格进入后端；当前启用题目和有效选项用于双向加权均值，零分母取中性值，实际选择与 rank_score 一致。普通路径不再调用星盘计算。输入摘要、问卷/规则指纹与参与代际覆盖 freeze/finalize/reveal，揭晓前变化进入可恢复失败。 |
| **AC17-03 真实普通候选链** | **接受** | 报告具名区分正常账号注册、真实 Web 运营批准、逐题问卷、本人输入确认及主动报名，现有 job 实际调用 consumer。run4 普通无候选、run5 故障注入、run6 普通数据库缺陷与修复后 run7 正常成功分别留账；最终 APP 双向独立接受及重读属于已报告开发链。 |
| **AC17-04 状态与操作恢复** | **接受** | 暂停保留未结提案、原期限和撤回能力；退出/当前资格失效释放未结槽位，不伪造对方拒绝。重报名遵守旧提案与代际约束，决策在锁内复核资格，幂等重放返回当前投影；等待揭晓、无候选、业务失败及请求失败有不同反馈。 |
| **AC17-05 历史与权限** | **接受** | 本人历史由持久提案产生，按认证 actor 限定并分页，详情越权 404，历史强制只读。每项重新经过当前提案和 Showcase 受众判断；无权资料不误封合法提案。APP 切号/恢复先清理旧投影并防迟到响应，具名撤回及旧详情/图片读取与实现一致。 |
| **AC17-06 可复核交付** | **接受** | 两项迁移、实际配置、报告、固定源码与最终候选可对应；报告保留失败及中间包身份。Git 身份核验通过，必要持久化/重启/最终 APP 行为按 Codex 具名运行范围接受。未涉及外部限制仍列账。 |

## 4. 几个关键判断

### 排序是本版实际执行规则

[MatchingEngineService](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/services/backend-laravel/app/Services/MatchingEngineService.php)按当前问卷方向分均值选择候选，保留未取整的实际 rank_score，并以稳定用户顺序处理并列。旧运行环境 core 权重 0/0/1 虽仍有记录，本版普通路径不读取其结果，也不先调用星盘服务。本次接受的是约定的可解释开发规则和真实接线，不包含推荐质量、关系成功率或全局最优分配的实证结论。

[CurrentQuestionnaire](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/services/backend-laravel/app/Services/CurrentQuestionnaire.php)同时检查当前启用题、本人选项和可接受选项。现行后台的题目启停保留历史题义和选项，仍有效的原答可以继续使用；提交版本及生成指纹按现有锁和版本合同处理，符合复用现有问卷的范围。

### 普通成功链与失败测试分开

run5 是具名缺失 digest 配置的故障注入，仅作为失败恢复证据。run6 恢复正常配置后出现 MariaDB 1406：21 字符结果标记超过 varchar16。当前源码改用 13 字符 `questionnaire`，有长度回归，随后 run7 通过正常 Web 重试及实际 consumer 成功。该普通缺陷已关闭，原始失败保持其历史身份。

当前 queue driver 为 sync，[ExecuteMatchingRun](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/services/backend-laravel/app/Jobs/ExecuteMatchingRun.php)通过 afterCommit job 调用实际 `app:matching:execute-pending`，符合本版复用真实开发 consumer 的要求。

1010701 的初始问卷/输入操作按未变业务范围继承；1010702 明确仅构建、安装 NOT_RUN；1010703 重新覆盖输入保存、重登、反馈、双向接受、历史与撤回恢复。没有用中间包身份替代最终包的整条声明。提案冻结输入 A3/B1 与接受后保存的 A4/B1 分列，历史生成依据没有被最终输入回填。

### 历史继续服从当前权限

[SlowDatingService](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/services/backend-laravel/app/Services/SlowDatingService.php)的历史读取复用当前投影，再关闭历史写操作。当前 [ShowcaseWorkflow](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/services/backend-laravel/app/Services/ProfileShowcase/ShowcaseWorkflow.php)保持 v10.1.6 R1 同一 Blob；有效重放也重新投影，不返回旧 Showcase 缓存。本人接受/拒绝等过程事实可以保留，对方资料须仍满足当前展示条件。

APP 的 [历史页](https://github.com/zcx369658780/EliteSync-v10/blob/e6bc14f6456421e006d1073dfe64d3b28c243102/apps/flutter_elitesync_module/lib/features/slow_dating_v1012/matching_history_page.dart)复用会话与恢复防护；相关测试包含分页、无资料时保留本人事实、切号迟到响应和恢复前台撤权。本次未发现新增历史入口绕过 R1 受众规则。

## 5. 证据等级与实际未复演范围

本次顾问独立完成固定 Git 内容回读、受影响源码及测试设计审查、报告/manifest 一致性和必要 Git 文件/子树身份核验。

以下仍属于 **Codex 具名本机运行报告**：39 项 PHP / 479 条断言、22 项 Flutter、工作树/容器原始字节、APK 签名及双模拟器安装字节、普通 APP/Web/MariaDB 操作、撤权旧链接结果、重登和 DB/API/WS 重启。顾问没有操作 Owner 的 Windows、容器或模拟器，也没有重新执行 PHP/Flutter 测试。

manifest 索引的 24 份原始记录及必要截图为 LOCAL_ONLY，公开实施报告已提供本轮去敏操作摘要；按本地工作流接受此证据安排，不要求为同一验收复制原始数据库、凭据、APK或重复制作整套截图。

## 6. 保留事项与后续方向

- 最近资源回执为 **2026-11-13 19:38:46.598446 北京时间**：DB/API/WS 运行；SFU exited / UNAVAILABLE / OPEN / UNKNOWN。该时间快照不冒充此刻实时状态，SFU 继续进入 v10.1.8 通信工作。
- 两个模拟器已回 user0，本包进程停止，隔离测试用户 11/12 与数据保留；手机动作 NOT_RUN，沿 Codex 本轮报告。
- 自然 168 小时等待 NOT_RUN；受控时钟期限回归按其限定范围有效。真实 Push、外部实人供应商、硬件及独立算法精度保持原账。
- 整个 v10 仍以真实功能、体验与 UI 完善为目标；集中 UI/文字为 v10.1.12，相识后新增工具仅接口。公司、内测及发布不由本次验收触发。

**本轮关闭 v10.1.7 顾问验收，无补充工程任务。等待 Owner 接受及下一版本范围讨论。**
