# 当前入口 2026-11-15 v10.1.13已授权，等待本地Codex同步并开工

**V10113_TASK_ISSUED**。v10.1.12六项AC具名代表性范围已获顾问接受，R1-01 CLOSED，无R2。Owner整版接受状态继续单独记PENDING。Owner已授权v10.1.13「全局集成与关键旅程可靠性收口」。

任务：[task_order](../versions/v10.1.13/task_order.md)；[plan](../versions/v10.1.13/plan.md)；[CODEX_START_PROMPT](../versions/v10.1.13/CODEX_START_PROMPT.txt)；Owner决定：[decision](../decisions/OWNER_V10_1_12_ADVISOR_ACCEPTANCE_AND_V10_1_13_AUTHORIZATION_20261115.md)。

分支：`codex/v10.1.13-integration-reliability-20261115`。唯一父基线：`ffddf23dd07743538c43ef8f9a6dd7f1ff580467`。v10.1.12 R1源码：`3e0e75758acf81e1ea754f739c9687226fbfcaff`；v10.1.12原候选1011204仅绑定旧源码`ac7fb5b28396394e58c72002e19cc9bbad805941`，不含R1。API源码`47e1b4fd8fad3dd8165d1be6dc9f059095290e75`；Web视图`e2448e2c4d630fad31168e3c0b70d3831011215f`。

## v10.1.13范围

质量收口，不新增大型业务：R1源码进入新候选；模拟器真实TalkBack；四入口/已实现深链与通知目标；反馈/文字消息最终APP受控结果未知恢复；虚构开发库API与MariaDB重启持久化；有限跨模块联合回归。

## 继续保留的边界

Owner手机、RTC硬件矩阵、真实Push/身份供应商、算法独立精度、全社交/排盘矩阵不属于本版。对应历史状态NOT_RUN、REAL_PUSH_PROVIDER_PENDING、UNKNOWN或UNVERIFIED继续保留。不得使用真实用户/生产数据，不接新供应商/付费服务，不合main、不正式发布、不开展内测/运营/收费。

集中交付后停下供顾问验收，不自动启动下一版本。
