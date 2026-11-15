# EliteSync-v10 当前工作流

2026-11-15更新。当前任务为[v10.1.13](../versions/v10.1.13/task_order.md)，规则见[AGENTS](../../AGENTS.md)及[Owner普通工程长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。当前事实只维护[ACTIVE_STATE](ACTIVE_STATE.md)，历史小步记录从Git历史查询。

## 当前交付状态

v10.1.11顾问接受六项AC的声明工程范围，AC11-02按未接入验证供应商的限定能力接受；R1-01 CLOSED。Owner已接受上述范围并授权v10.1.12。原报告中的NOT_RUN/UNKNOWN、真实Push待接入和历史SFU/RPC根因未知均保留。

v10.1.12五阶段基线已交付，六项AC具名代表性范围获顾问接受，R1-01 CLOSED。Owner整版接受仍单独记录PENDING。R1源码`3e0e75758acf81e1ea754f739c9687226fbfcaff`，27项定向Widget、4文件分析PASS；R1 APK构建和设备验证NOT_RUN。原候选1011204绑定旧源码`ac7fb5b28396394e58c72002e19cc9bbad805941`。Web原证已明确关联#3/#4写入与#3随后只读复核，false原值保留。实际验证、基线资源与限制见[manifest](../versions/v10.1.12/artifact_manifest.json)。

v10.1.13「全局集成与关键旅程可靠性收口」已完成集中工程交付，六项AC按具名范围自验PASS，顾问及Owner接受均PENDING。分支`codex/v10.1.13-integration-reliability-20261115`，唯一父基线`ffddf23dd07743538c43ef8f9a6dd7f1ff580467`。最终APP源码`2b4fdcc9f342b972a37b35de74fbf099827a7c2e`，候选1011303，包含R1。八份开工文档逐份LOCAL_DOCS_SYNCED。

## 本版完成范围

新候选 → 真实TalkBack → 现有导航/站内通知 → APP受控结果未知恢复 → API/DB重启持久化 → 有限联合回归。详细范围、固定源码、APK及原失败见[实施报告](../versions/v10.1.13/IMPLEMENTATION_REPORT.md)和[manifest](../versions/v10.1.13/artifact_manifest.json)。

API独立重启读回PASS。DB重启后发生共享网络命名空间依赖故障，通过重启原API/WS容器恢复，原记录读回一致。自动透明恢复为NOT_RUN。原主库HEAD/index/跟踪差异指纹匹配，status指纹差异原因为UNKNOWN。模拟器已停止、数据保留，DB/API/WS运行，SFU exited。当前等待顾问验收，后续版本授权NOT_GRANTED。

## 验证、记录与授权

按实际改动和风险做定向分析/测试及有限代表性联合回归；不重跑全部历史AC或全设备矩阵。真实APP/API/DB/Web链与Widget/单元/受控反例分开记账。未运行写NOT_RUN，未核实写UNKNOWN，不把顾问验收、Owner接受、main集成和发布混为一体。

普通工程、必要Debug APK、本机开发服务、虚构数据、必要双模拟器和常规Git沿Owner长期授权。不操作手机，不用真实用户/生产数据，不接新供应商或付费服务，不合main、不发布、不开展公司/内测/运营。保护本地未提交成果、index、私有配置、数据库、AVD、APK与原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。

集中交付后停下供新顾问验收，不自动开始下一版。
