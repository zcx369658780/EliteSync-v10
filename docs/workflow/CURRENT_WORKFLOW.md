# EliteSync-v10 当前工作流

2026-11-15更新。Owner当前授权任务为[v10.1.13](../versions/v10.1.13/task_order.md)，规则见[AGENTS](../../AGENTS.md)及[Owner普通工程长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。当前事实维护在[ACTIVE_STATE](ACTIVE_STATE.md)。

## 最近接受状态

v10.1.12六项AC具名代表性范围获顾问接受，R1-01 CLOSED。Owner整版接受仍单独记PENDING。R1源码为`3e0e75758acf81e1ea754f739c9687226fbfcaff`，R1源码未构建APK；原候选1011204绑定`ac7fb5b28396394e58c72002e19cc9bbad805941`，不得混淆。

## 当前任务

v10.1.13「全局集成与关键旅程可靠性收口」已授权。唯一分支`codex/v10.1.13-integration-reliability-20261115`，唯一父基线`ffddf23dd07743538c43ef8f9a6dd7f1ff580467`。顺序：R1源码进入新APK候选 → 模拟器实际TalkBack → 关键导航/已实现深链 → 最终APP受控故障恢复 → 虚构开发环境API/DB重启持久化 → 有限联合回归。

## 验证和权限

普通工程、必要Debug APK、本机开发服务、虚构数据、必要双模拟器与常规Git沿长期授权。仅对改动和本版AC定向验证，不重跑全部历史AC。真实APP/API/DB/Web、Widget、TalkBack、受控故障、重启分别记账。未运行写NOT_RUN，原因未知写UNKNOWN。

不操作Owner手机，不使用真实用户/生产数据，不接新供应商或付费服务，不合main、不正式发布、不开展公司/内测/运营。保护dirty/index、私有配置、数据库、AVD、APK与原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。集中交付后停下供顾问验收。
