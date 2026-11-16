# v10.1.17 B3 实施报告

2026-11-16。原工程交付结论为 `PASS_IN_NAMED_SCOPE`，交付时 GPT 顾问独立验收与 Owner 整体产品接受均为 `PENDING`。后续 GPT 顾问已接受该固定交付的具名工程范围，NO_R1/NO_R2，见 [顾问验收](ADVISOR_ACCEPTANCE_20261116.md)。Owner 整体产品接受仍为 PENDING。

## 后续 Owner 实机评测

Owner 已在本会话追加授权安装与登录，并提供有限实机反馈。首页状态与主按钮、生活方式探索及 Me 入口获得正向观察；文案开发痕迹、选项配色、自动化入口及“进展→匹配”的建议列入后续 UI 收口。第 8 项补注记录新账号未显示旧账号消息，关闭重开等完整场景仍待测试。详见 [Owner 原文与逐项范围](OWNER_DEVICE_FEEDBACK_20261116.md)。以下工程验证及 NOT_RUN 字段为原交付时快照，后续记录在该反馈中接续。

## 固定身份

- 任务分支 `codex/v10.1.17-low-operation-cost-journey-integration-20261116`。
- 唯一父基线 `99a05c6f6d509c0607d8bff0d63b122d5cc84eec`，固定任务文档 `8117980c8f2b2e8ada61db52450a9aca7b643e13`。
- 最终 APP 源码 `1953582093d3469a48cd7275864309cb09eb0e53`。产品源码与固定提交一致。
- 最终候选 `10.1.17-dev / 1011703`，包名 `com.elitesync.v1017dev`，arm64 source-debug。
- APK SHA256 `729be2af7d215f4701c49e494d1767e59d350b1aee5bf83ecb553910f050f8ea`。
- 签名证书 SHA256 `7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42`。安装包路径及大小见 [manifest](artifact_manifest.json)。

## 编码前审计

20 份路线及任务文件逐 Git Blob 核验为 `LOCAL_DOCS_SYNCED`。四份编码前审计材料与同步回执在 `f22871c0` 一次性提交，随后开始产品源码变更。原 Prompt 内历史任务 hash 差异已写入回执。

[现有旅程](CURRENT_JOURNEY_INVENTORY.md)、[冻结成本基线](B3_OPERATION_COST_BASELINE.md)、[目标信息架构](TARGET_INFORMATION_ARCHITECTURE_V1.md)、[路线确认](ROADMAP_ALIGNMENT_ACK.md) 和 [同步回执](LOCAL_DOCS_SYNC_RECEIPT.json) 构成审计入口。

## 八项 AC

以下 PASS 限于本报告具名代表范围。

| AC | 工程结果 | 实际交付与证据 |
|---|---|---|
| AC17-01 | PASS | 四入口、路由、权限与状态来源盘点，1011601 真实九项基线，在编码前固定。 |
| AC17-02 | PASS | 保留四底栏。原别名、typed chat、通知和受限 Buddy 路径回归。认证后的默认冷启动进入 Home，显式深链继续优先。见路由地图。 |
| AC17-03 | PASS | Home 读取 B2 `/user-state`，核对 contract 与本人 subject，按服务端排序只映射首个既有 next action。未知 code 提示刷新，失败、切号、后台及路由重入清除旧投影。 |
| AC17-04 | PASS | Progress 分开呈现准备、偏好、参与、自动化、轮次、提案、CN、MC、Conversation 与正式关系。读取失败保持未知。合法 peer 的连接独立读取，候选期限过去仍能依据现行 CN/MC 进入有权会话。 |
| AC17-05 | PASS | 消息页新增独立站内通知入口。实际通知回到有权对话，通知未读 5→4，聊天与通知各自处理已读。虚构 E→D 消息显示与原显式 ACK 合同回归通过。 |
| AC17-06 | PASS | Me 按资料/偏好、隐私/账号、可选工具、参与记录分组。私密及展示资料直达既有编辑器，工具、头像、通知、动态、准备与申诉能力可达。自动化链接同一规范页。 |
| AC17-07 | PASS | 已完成 Lifestyle 改选后直达保存摘要，其余答案保留。授权、受众、发布和提案选择仍由本人明确触发。沿用原私有缓存、账号隔离、revision 与幂等合同。既有美术与权限按用途触发路径沿原实现。 |
| AC17-08 | PASS | 九项成本、定向 Widget/Dart/PHP、隔离 MariaDB/HTTP、实际 APP 切号/通知/后台结果/冷启动、候选签名和安装身份已核验。 |

## 操作成本与导航

总动作 **53 → 35，减少 34.0%**。六项减少无必要页面跳转，五项总动作减少至少 20%。J7 保持单步，J8 保留输入、受众选择和发布。J4 原编码前 OFF 基线保留，另用原 1011601 从 REVOKED 补测，同候选逻辑状态下仍为 7 动作。

[完整对比](B3_OPERATION_COST_COMPARISON.md)、[逐动作回执](B3_OPERATION_COST_COMPARISON.json) 和 [实际路由地图](B3_ROUTE_FUNCTION_MAP.md) 记录步骤、跳转、状态归一及历史保留方式。

B3 主要修改 11 个 Dart 产品文件与 Android 候选配置。后端产品服务、API、业务表和状态机沿现有实现。另修复两份 PHP 测试准备/断言，以实际完整准备和显式消息 ACK 验证现有合同。

## 集中验证

- B3 定向 Widget 213 项唯一 case 在定向集及修复后的受影响复核中通过。联合集初次 197 PASS、7 个旧路由 wrapper 期望失败，修正构建门期望后相关 13 项通过。随后新增登录路由回归和八项 Splash 检查。默认构建兼容另按模式验证 23 项，通过。计数与日志哈希见证据摘要。
- 11 个受影响 Dart 产品文件分析通过。各源码片段仅复核受影响部分。
- PHP 共 50 项唯一 case。B1/B2 35 项通过，消息/同意及当前聊天语义 15 项通过。原旧 fixture 缺少现行准备及 GET 自动已读断言的失败日志完整保留。
- 新隔离 MariaDB 与真实 HTTP 的 13 次具名检查通过，包括本人隔离、伪造 subject 拒绝、合法 CN/MC/会话与无权读取拒绝、有限 Buddy/社区和可选工具。普通状态读取前后授权、effect 与 matching_run 数量一致。
- 实际 APP 从 A 切 B 再切 D，旧账号投影清空，新账号未授权及待探索状态正确。九项代表旅程通过，候选冷启动恢复当前登录并进入 Home。
- D 经 APP 明确授权后，具名后台 tick 只处理一项，结果为 `SKIPPED / ROUND_NOT_OPEN`，effect 为 0、matching_runs 仍为 3 个受控 fixture。撤销后独立手动 ACTIVE 参与保持，delegated 为 false。
- 受控关闭 D/E 候选信息期限后，既有服务保留 `MUTUALLY_ACCEPTED` 历史，返回 candidate_available/connection_eligible=false。CN_ACTIVE、MC_ACTIVE 和当前会话访问保持独立，实际 APP 仍可进入有权聊天。
- 非作者静态审查覆盖最终源码提交。发现的连接摘要依赖提案资格问题已闭环，路由及生命周期补审未发现新增确定缺陷。原工程交付时顾问独立验收记 PENDING；后续顾问已接受原固定交付的具名范围，见 [顾问验收](ADVISOR_ACCEPTANCE_20261116.md)。Owner整体接受仍为PENDING。

原始日志、完整 API 回执、截图、配置及 QA 口令为本机私有资料。公开交付包含九张经检查的虚构模拟器代表截图和去敏 JSON。[证据摘要](EVIDENCE_SUMMARY_20261116.json) 与 [集成回执](evidence/INTEGRATION_RECEIPT.json) 可直接复核。

## 原失败与候选迭代

1011701 登录后首页使用重定向前地址判断可见性，状态读取未启动。定向 RED→GREEN 后，1011702 改用解析后路由；冷启动还沿旧默认准备页。1011703 完成 B3 默认 Home 冷启动并通过实际恢复验证。三份 APK、对应身份和失败原证均留在本机，1011601 独立包及原 SHA256 保留。

隔离服务初建出现 storage 卷属主、受控 fixture 唯一键和私有实例资格配置问题，均在新 B3 测试环境恢复。原 J8 默认 SELF 试做、旧通知测试的异步 build 签名、默认 wrapper 与本地构建门期望、UI dump 启动等待和测试启动目录错误均保留日志并完成相应修复。期限探针首次误期望已接受历史变成 EXPIRED，随后依据既有服务的历史状态与 candidate_available 合同复核，未改写业务状态机。

补测复用了私有基线汇总文件。按原 Windows CRLF 序列化恢复为独立副本后，SHA256 `43dcbab6e79f30138f05ba646639dfdc18972d87aea407659d2ff55a70a1ee0d` 与编码前冻结值完全一致。补测汇总继续保留。九项原数据、已提交逐动作回执及各项独立起止 UI 回执亦逐项一致，见 [基线完整性核对](evidence/BASELINE_INTEGRITY_RECEIPT.json)。初次 LF 重建未匹配的诊断结果保留，该项哈希限制已闭环。

## 保护、运行态与停止点

稳定根为 `D:\EliteSync-v10-product-v1015-20261101`。原 `D:\EliteSync-v10` 的 HEAD、branch、origin、porcelain-v2 status、tracked diff、cached diff 与 index 字节指纹均与本版开工保存一致。曾用 v1 对 v2 比较产生的诊断差异已单独保留。历史 v10.1.16 首次误连探测逐表摘要及历史 status 变化原因仍为 UNKNOWN。

本版 DB/API/WS 位于新隔离测试环境，API 回环端口 18021，WS 为 18022。旧开发 DB/API/WS/SFU 保持 exited。模拟器已停止，AVD、数据及两套应用安装保留。完整私有资料位于 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev\v10117-current`。

本版真实手机、系统级 TalkBack/全部权限矩阵及全设备覆盖为 NOT_RUN，Owner 手动整体检查为 PENDING，见 [检查表](OWNER_DEVICE_CHECKLIST.md)。B1 图像模型精确名称/版本 UNKNOWN 与既有范围限制沿原接受记录保留。本轮使用现有美术。

源码已完成同源远端固定回读，集中文档提交后再核最终交付 HEAD。main 集成、正式发布与真实运营为 NOT_RUN。原工程交付后按当时停止点等待 GPT 顾问独立验收；后续顾问已完成具名范围接受，见 [顾问验收](ADVISOR_ACCEPTANCE_20261116.md)。Owner整体接受仍为PENDING。
