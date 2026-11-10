# EliteSync-v10｜v10.0.4 正式冻结计划

> FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED
>
> 冻结日期：2026-10-13。Owner批准进入v10.0.4，Astra根据Codex READY_WITH_FINDINGS 的只读调查与实际GitHub源核实收敛。本计划**不代表执行授权**，Owner须手动将固定链接和实施命令派发Codex。**代码候选唯一父提交**：`5728251c6345ba17524fb323dac8a02573d8d8c6`。本文件首次发布commit及Git Blob是冻结唯一权威，之后不得追改目标或AC。
>
> **唯一切片：现有 Me→Readiness 页面中的动态状态来源说明、正式必要条件集合未知的解释、两个兼容设置恢复入口的用途提醒。** 不新增假清单、不新增资格判断、不接生产HTTP。

## 1. 已接受资产与真正缺口

- `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart` 当前 Blob `614d412f417d7ce2e6385ac5324c4fd79660b788`：Me五用途与Readiness整体状态/两个兼容按钮已存在，但用户看不到清楚的“条件集合尚未确定”解释；其私有`_readinessPresentation`在异常注入非Dev READY时会声称“已由权威来源确认”，却无佐证。
- `navigation_guard_provider.dart` Blob `f15eb57367349664dbc057424bae66bf5287473b`：认证是独立状态；仅明确Dev synthetic flag可形成演示READY；不修改Guard、AppRouter、Match权限。
- 已接受后端RuntimeReadiness evaluator`1d5918d890d5eb753032b24540a4a133107c811f`、adapter`9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`、HTTP controller`3a74ae1da7a752de61c47f055c4fab1a8b900e4c`仍仅synthetic。专用HTTP成功响应五字段为`readiness_classification`、`reason_categories`、`materialized_projection_usable`、`condition`、`synthetic_dev_test_only`；没有具名成员、required/optional、成员有效期或纠正路径。`GET /api/v2/app/readiness`是基础设施状态，不是用户资格。
- Owner已接受的目标设计确实要求可解释具名Readiness，但正式 prerequisite-set、身份保证要求、launch准入仍未决定；不能先用静态UI伪造。APP-T04和APP-INT-02接受仅限现有Me/Guard和Dev演示，不扩大。
- Codex报告旧clean基线`C:/Users/zcxve/.codex/worktrees/elitesync-main-64a098f/EliteSync-v10`仍CLEAN，和代码父之间只差五份文档；原`D:/EliteSync-v10` dirty main HEAD`4bebc8f...`/默认index`2be660...`、43 tracked/208 untracked、109具名保护保持。原根Readiness和问卷LOCAL_ONLY差异未经接受，不吸收。

## 2. 唯一代码白名单和显示合同

**MODIFY ONLY** `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart`，且仅ReadinessPurposePage及同文件专用私有展示辅助；不得改变其它Me purpose页、现有路由名/入口。
**CREATE ONLY** `apps/flutter_elitesync_module/test/features/me/presentation/pages/readiness_purpose_page_test.dart`。
证据仅新增于`docs/versions/v10.0.4/`。

- 在现有Readiness页新增实际可读、可重建的“当前状态来源/正式条件尚未确定”只读解释区，明确总体Guard显示 != 具名正式条件资格。UNKNOWN不等于不合格，setupRequired不等于已知缺少哪个成员；不能展示虚构必需/可选项、百分比、年龄/身份证明、成员时效、真实认证结论或“资格全部满足”。
- 仅`state==ready && env.isDev && env.useSyntheticReadinessProjection`显示醒目的**Synthetic/开发演示/不是正式资格**。非Dev/关flag情况下即使测试强制注入`ready`，也**不得写“由权威来源确认”**，保守显示来源未确认。Guard从synthetic READY切换为unknown/setupRequired/unauthenticated时旧成功说明必须立即消失；AppEnv是固定配置，flag关闭用不同安全fixture测试，不为模拟动态flag重写Router。
- 两个按钮继续走既有`verificationStatus`和`questionnaire`路由，分别提示“兼容验证状态查看”和“兼容问卷继续设置”，仅查看/恢复，不自动生成正式资格、最低核验保证、Match同意或Conversation许可。兼容验证页保留既有旧文案；本版不能将其变成新的强制条件。不得预读取个人数据、发送请求、提交/写入新业务状态。
- `Readiness`显示只读，不修改Guard、Router、Home、Progress、Verification/Questionnaire provider、后端、Connection、Chat或v10.0.3已接受修复。

## 3. 实际测试与交付

- 新测试必须在**真实 appRouterProvider + MaterialApp.router + AppShell → Me → Readiness**环境下验证非Dev UNKNOWN、Dev Synthetic READY、异常非Dev READY、setupRequired/unauthenticated、同一次mounted Guard更新后旧success立即消失、两兼容目的路由与返回，以及窄屏/放大文字可读。对不能在真实路由安全演示的状态，使用同文件纯展示层测试补证，但不得把stub router叫真实路由通过。
- 用虚构Guard、内存Storage、禁用RTC/watch、隔离目标Verification/Questionnaire页可能的provider副作用；网络/API/安全存储/业务写入设置可验证有效的拒绝哨兵并断言0出站/0写入。无效localhost并非充分证明。若不可在白名单内安全完成，停止风险调用并报告NOT_RUN/BLOCKED，不擅改额外产品源码。
- 测试新文件、既有`test/synthetic_readiness_match_integration_test.dart`及直接必要的小量Me/Router用例，`dart analyze`限上述两文件；保存真实exit/原失败及修复/源码身份/NOT_RUN。使用已有Flutter SDK与依赖图，不下载升级、启真实用户或设备，不机械跑PHP294、Router42。
- 单父独立候选GitHub commit/tree，给Astra可读两产品文件、有限manifest与已检查安全的原始收据。原dirty工作树及此前clean基线HEAD/index/status和109保护不变；不全仓pull/reset/rebase/clean/stash或复制未经接受LOCAL_ONLY。

## 4. 冻结验收 AC-01～AC-07

| AC | PASS标准 |
|---|---|
| AC-01 基线保护 | 单父固定为`5728251c6345ba17524fb323dac8a02573d8d8c6`；源身份/未决集合准确，两旧树及109文件前后保护回执一致，不吸收旧root未经接受修改 |
| AC-02 真实用户页 | 原Me→Readiness有动态来源和条件集合未确立的解释、两个兼容恢复路径用途提示；保留原UI入口与其它Me用途 |
| AC-03 失败关闭 | UNKNOWN≠NOT_READY；Dev READY标Synthetic；非Dev/关flag异常READY不得冒称权威；Guard动态变化即时移除旧成功；不伪造必需清单/完成率或授权 |
| AC-04 真路由安全验证 | 真实AppShell/Router的Me/Readiness及两个兼容路由/返回、状态切换、窄屏测试可观察；受控外部/业务写哨兵0且无真实数据 |
| AC-05 有限回归 | 最终新测试+旧synthetic Readiness/Match及必要相关测试exit0，源码/测试窄分析无问题；真实失败与NOT_RUN完整记录 |
| AC-06 可独立验收 | GitHub固定candidate/tree、源码/测试/安全回执及有限manifest可逐路径读回，未越代码白名单 |
| AC-07 收尾 | Astra独立终验/复盘；Acceptance、远端定点集成、Codex本地新基线、集成后回归分开登记，不自动v10.0.5 |

## 5. 保护与人工门

正式required/optional、地区/年龄门槛、最低身份保证、真实撤销/过期来源、用户Message/Match权限均未授权，禁止发明。BE-12消息路由默认404，V57/H1/H2/D0仍暂停，M6/生产/设备/认证/数据不放开。不可更改此范围以求绿灯；需其它代码或服务权限则停止越界并报告`BLOCKED_SCOPE_DECISION`。

**仅Owner在发布后手动派发冻结计划时Codex才可执行；其余常规编码/诊断/重测Codex自主处理。候选交付后停止，待Astra终验，按已有K08规则定点安全集成及手动本地接续。**

`V10.0.4 FROZEN — READINESS_SOURCE_EXPLANATION_AND_SAFE_RECOVERY — AWAITING_OWNER_MANUAL_DISPATCH`
