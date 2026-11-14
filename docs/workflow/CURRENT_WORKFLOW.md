# EliteSync-v10 当前工作流

2026-11-14更新。Owner授权的当前任务为[v10.1.12](../versions/v10.1.12/task_order.md)，规则见[AGENTS](../../AGENTS.md)及[Owner普通工程长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。当前事实只维护[ACTIVE_STATE](ACTIVE_STATE.md)，历史小步记录从Git历史查询。

## 当前交付状态

v10.1.11顾问接受六项AC的声明工程范围，AC11-02按未接入验证供应商的限定能力接受；R1-01 CLOSED。Owner已接受上述范围并授权v10.1.12。原报告中的NOT_RUN/UNKNOWN、真实Push待接入和历史SFU/RPC根因未知均保留。

v10.1.12「集中UI、信息结构与文案完善」已下达。唯一任务分支`codex/v10.1.12-ui-information-architecture-20261114`，唯一父基线`2f3058d39a936063768ffb895f577d97a088e04c`。APP/后端源码基线为`47e1b4fd8fad3dd8165d1be6dc9f059095290e75`，当前无产品源码变更；本版主要在APP体验层，必要时收口独立Web管理页面。

## 工作顺序

我的/设置 → 消息/聊天 → 首页/进展 → 匹配/社交/特色工具 → 必要Web页面。先建立代表页面和共享组件规则，再扩展到关键页面；保留真实功能、权限与后端合同。

## 验证、记录与授权

按实际改动和风险做定向分析/测试及有限代表性联合回归；不重跑全部历史AC或全设备矩阵。真实APP/API/DB/Web链与Widget/单元/受控反例分开记账。未运行写NOT_RUN，未核实写UNKNOWN，不把顾问验收、Owner接受、main集成和发布混为一体。

普通工程、必要Debug APK、本机开发服务、虚构数据、必要双模拟器和常规Git沿Owner长期授权。不操作手机，不用真实用户/生产数据，不接新供应商或付费服务，不合main、不发布、不开展公司/内测/运营。保护本地未提交成果、index、私有配置、数据库、AVD、APK与原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。

集中交付后停下供新顾问验收，不自动开始下一版。
