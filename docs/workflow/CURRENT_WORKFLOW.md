# EliteSync-v10 当前工作流

2026-11-14更新。Owner授权的当前任务为[v10.1.11](../versions/v10.1.11/task_order.md)，规则见[AGENTS](../../AGENTS.md)及[Owner普通工程长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。当前事实只维护[ACTIVE_STATE](ACTIVE_STATE.md)，历史小步记录从Git历史查询。

## 当前交付状态

v10.1.10六项AC及手机实机普通功能链补证均获顾问按声明范围接受，无R1/R2；Owner整版最终接受仍PENDING。证据和候选身份见ACTIVE_STATE及v10.1.10报告。Owner本次明确授权v10.1.11，不追溯修改v10.1.10的Owner状态。

v10.1.11「账号支持与功能质量收口」工程集中交付，等待新顾问验收。报告、最终候选1011101与限定恢复能力见[实施报告](../versions/v10.1.11/IMPLEMENTATION_REPORT.md)。任务分支`codex/v10.1.11-account-support-quality-20261114`，唯一父基线`96a2125370677d5d508710b590a808f44e50a119`，原工程固定提交`3888c6eb63ecfb6798a80387f4b27cd891a10457`。本地任务文档同步已完成，实际记录见ACTIVE_STATE的LOCAL_DOCS_SYNCED。

R1-01仅修正AGENTS当前版本指令并核对三份入口文档一致性，验证范围为文档内容、链接、差异与Git身份。保存到原v10.1.11分支并固定回读后，停下供顾问文档差异与治理复核。v10.1.12仍未授权，不得自动启动。

## 工作顺序

真实后端、持久化与必要APP/Web操作 → 对应功能及必要安全收口 → v10.1.12集中UI/信息结构/文字 → 产品整体验收。普通功能版只需真实可操作界面和准确反馈，不做全局视觉重设计。

## 验证、记录与授权

按当前改动和风险做定向验证；真实APP/API/DB/Web链与Widget/单元测试分开记账。未运行写NOT_RUN，未核实写UNKNOWN，不把工程自测、顾问验收、Owner接受、main集成和发布混为一体。普通实现、必要开发库迁移、Debug APK、本机独立开发服务、虚构数据、必要双模拟器及常规Git沿Owner长期授权；不逐动作申请。保护本地未提交成果、index、私有配置、数据库、AVD、APK与原始证据。不盲pull/reset/rebase/stash/clean/prune，不force push。

不操作手机，不接新供应商或付费服务，不用真实用户/生产数据，不合main、不正式发布、不开展公司/内测/运营。真实Push及历史SFU/RPC根因按既有状态保留。v10.1.11集中交付后停下供顾问验收，不自动进入v10.1.12。
