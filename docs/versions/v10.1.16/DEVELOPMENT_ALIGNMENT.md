# v10.1.16 开发思路对齐文件

## 1. 本版仅执行B2

当前授权：V3.0阶段B2 / v10.1.16「统一用户状态与后台自动化中心」。

B1已完成并由Owner按具名范围接受，AC15-02仍PARTIAL。B3全局低操作成本重构、B4运行时AI、阶段C外部服务均未授权。

## 2. 核心思想

不是建立一张新的“大用户状态表”，而是读取已有权威状态，形成统一、私有、可解释的只读视图。不得复制并维护另一套ProfileReadiness、LifestyleDiscovery、SlowDating或Round状态。

自动化不是默认代替用户作决定，而是把用户明确授权的窄任务交给后台执行。每项scope独立授权、默认OFF、可暂停、可撤销、可到期、可审计。

## 3. 现有源码合同必须先复核

固定基线中：
- `matching_participations`是每个用户一条的参与状态，含ACTIVE/PAUSED/EXITED、generation、revision；
- `SlowDatingService::participate`的opt_in会检查Lifestyle Discovery和ProfileReadiness；
- `ProfileReadinessService::eligibleUsersQuery`要求用户具备ACTIVE参与、探索完成、资格有效且无未决proposal slot；
- `MatchingRunService`在候选冻结和finalize再次检查资格；
- `MatchingRoundService::prepare`和`AdminMatchingController`控制轮次；
- `app:matching:execute-pending --once`受matching.foundation.execution_enabled和--once保护；
- `routes/console.php`当前调度仅有账户关闭任务。

以上只是开工基线锚点，Codex必须对本地实际源码重新核验。不得绕过这些权威合同。

## 4. 每周慢约自动化边界

一次明确授权可支持后续每周持续参与，但必须确认现有opt_in文案是否已经表达此范围。若不明确，不得把旧ACTIVE账号静默转成自动化授权，必须新增单独、默认OFF的scope。

系统只能协调用户参与状态和资格；不能创建/排期轮次、触发matching run、冻结候选或揭晓。不能自动接受候选、连接、消息同意或关系确认。当前proposal按既有规则处理。

## 5. 自动化可靠性

- 代码白名单任务，不支持任意脚本；
- 幂等键、有限重试、UNKNOWN核对、lease/fencing、审计；
- 任务执行前检查授权revision和当前资格；
- pause/revoke取消未执行任务，正在执行的任务在副作用前重新核验；
- 到期或授权政策变更后停止执行；
- 使用现有Laravel设施，不引入新外部服务。

## 6. UI范围

仅在现有Me/Progress/慢约页面加最小状态摘要和自动化控制。禁止新增底部导航、重组四入口或全面重做页面。这些属于B3。

## 7. Owner实机验收

Owner整体实机验收安排在B1+B2+B3完成后。v10.1.16不得操作Owner手机或要求Owner中间版本实机签收。Codex可用模拟器与虚构账号完成工程验证。

## 8. 美术资产

B2以状态信息和控制组件为主，不为装饰而生成图片。若确有新美术素材需要，遵循Astra艺术指导 + 最新在线GPT Image生成 + GitHub固定路径/manifest，记录实际模型版本/日期/prompt/SHA256；模型身份未暴露时写UNKNOWN。保持Owner已冻结的视觉方向。
