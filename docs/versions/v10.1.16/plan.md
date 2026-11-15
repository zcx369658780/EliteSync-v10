# v10.1.16计划：统一用户状态与后台自动化中心

## 1. 产品目标

让用户表达一次明确意愿，系统在授权范围内自动完成状态汇总、资格检查、准备、协调、执行和反馈。用户不再重复填写或确认已经表达过的内容；涉及隐私、分享、匹配选择、消息同意、Connection、Relationship和不可逆行为仍由用户决定。

本版先建设可信的状态底座和有限自动化，不做全APP UI减法重构。

## 2. 先审计，不先建表

当前源码已有多处权威状态：
- users/ProfileReadiness；
- lifestyle_discoveries/LifestyleDiscoveryService；
- matching_participations/SlowDatingService；
- dating_rounds、dating_round_user_states、match_proposals；
- notification preferences；
- Laravel scheduler和Jobs。

先建立source map，确认每个状态域唯一权威来源。能通过服务聚合读取的，不重复落库。自动化授权是用户委托，匹配参与状态是业务事实，两者只有在合同完全等价时才可复用，不能把它们混成一个模糊字段。

## 3. 用户状态中心

默认使用只读实时聚合API。每个状态域有明确来源、更新时间/revision、状态码和下一步动作。只返回当前用户自己的必要信息。状态中心不做新的业务裁决，不替代ProfileReadinessService或LifestyleDiscoveryService。

最小APP呈现放在现有Me/Progress/慢约会页面，不新建全局导航。

## 4. 自动化授权与任务

每项自动化独立授权、默认OFF。用户能查看、暂停、恢复、撤销。任务有唯一幂等键、有限重试、执行记录、UNKNOWN结果核对、审计和到期状态。任务只从代码白名单中选择，不能成为任意脚本执行器。

本版首个试点是每周慢约会持续参与：
- 明确的一次授权可用于后续每周轮次；
- 当前ACTIVE状态是否已表达持续授权，必须从现有UI文案与后端合同核实；
- 如不清楚，旧用户不静默迁移，增加单独默认OFF授权；
- 每轮检查Lifestyle Discovery、ProfileReadiness、账号、proposal和授权状态；
- 只协调用户参与状态，不创建轮次、不触发匹配运行、不自动接受候选；
- 用户可随时暂停/撤销未来参与。

## 5. 执行器与调度

先检查当前Laravel scheduler、数据库队列、锁与部署方式。复用已有设施；任务执行应有锁、lease/fencing、attempt count、backoff、reconciliation。未知结果先核业务事实再重试。不能用新的Redis、云服务或付费依赖来解决本地调度问题。

现有`app:matching:execute-pending --once`和管理员轮次操作继续受原保护开关与权限约束，B2不得自动触发。

## 6. 推荐实施顺序

1. 同步V3.0与本版任务文件，创建ROADMAP_ALIGNMENT_ACK；
2. 只读审计现有状态域、慢约参与语义和后台调度；
3. 固定source map与state API合同；
4. 实现自动化授权与任务ledger；
5. 实现唯一试点及pause/revoke/expiry/unknown处理；
6. 接入最小APP状态/自动化控制；
7. 定向真实API/DB/APP测试和模拟器回归；
8. 构建1011601或顺延候选，集中交付。

## 7. 成功定义

用户能在现有入口查看准确的个人状态和下一步动作；用户可对持续参与等具体自动化作出一次明确授权，系统之后在每轮既有资格条件下自动协调参与；用户可以暂停/撤销；任务结果可追溯且不会重复执行。匹配轮次仍由既有运营流程管理，候选接受和后续关系行为仍由用户决定。
