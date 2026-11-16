# v10.1.16 B2 第二轮顾问独立复核

日期：2026-11-16（北京时间）  
结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

## 一、固定审阅身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.16-user-state-automation-center-20261115`
- 唯一父基线：`b981796e68ca512beeed2a18b40aeb8b09e26bc2`
- 首次产品源码：`00cec7843911bb3341304c004059de0a91e12f16`
- R1修正源码：`4bfa9245f06548197532ecec2d5da0397ba8d33d`
- 本次固定交付提交：`51c58ddc7dc3561a6c4902519b8379ed1c84b51e`
- 候选APK：`10.1.16-dev / 1011601`
- 原APK SHA256：`ac86f8df05d1e39abfead445ba5d6e23bcb457b6c73030c02fa38d2d2cedb055`

已核对任务分支HEAD与固定交付提交一致；R1源码提交是交付提交的直接父提交。R1源码只修改两个后端服务、既有定向测试及新增隔离HTTP fixture；APP源码未变化。产品源码同源origin fetch与ls-remote回读为PASS。

## 二、最终决定

`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

首轮P1问题R1-01已按任务合同修正并通过第二轮复核。AC16-01至AC16-07均在各自具名验证范围内接受，保留原报告、manifest和证据摘要列出的NOT_RUN、UNKNOWN及历史失败。

- R1-01：CLOSED，第二轮顾问复核PASS。
- R2：NOT_REQUIRED。
- 新增已确认P1/P2：无。
- Owner整版接受：PENDING，仍由Owner决定。
- main集成、正式发布、真实运营：NOT_RUN。
- B3、B4、阶段C：仍未授权。

## 三、R1-01修正复核

### 3.1 自动化停止范围

`AutomationAuthorizationService::pauseParticipation()`现在按用户、授权记录ID和参与状态ACTIVE选择委托参与。它不再仅凭ACTIVE状态暂停所有参与。暂停/撤销命令及到期调度均传入授权记录ID。

到期路径先推进授权revision，再按授权记录ID识别此前绑定的参与，因而不会因授权revision变化漏掉真正委托的记录。未绑定的手动ACTIVE参与不匹配此查询，保持完整业务行。

### 3.2 参与来源revision与effect receipt

`AutomationService::apply()`读取当前参与行，并比较授权ID、授权revision及round ID。只有绑定字段确实发生变化时才增加参与revision并更新updated_at；相同绑定重复执行不重复增加版本。

effect receipt写入绑定后的最终参与revision。新增测试同时检查UserState聚合的delegated、source_revision、source_updated_at与数据库当前行一致。

### 3.3 当前提案和权限边界

已委托参与暂停/撤销/到期时，当前proposal和slot保持原值；accept仍受现有参与资格门禁拒绝，用户明确withdraw仍可执行。自动化没有获得自动接受、自动拒绝、管理员轮次创建或匹配算法执行权限。

### 3.4 R1定向证据

GitHub结构化证据摘要记录：

- PHP/API：27项、267断言PASS；其中10个新增R1参数化case。
- 修复前RED复现：10个场景，6项复现原缺陷，4项其他预期通过；原RED记录保留。
- 隔离MariaDB：10个场景、36次真实回环HTTP请求PASS。
- 四项worker可靠性：提交前SIGKILL、提交后回执前SIGKILL、双worker并发、claim后撤销竞态均PASS。
- 受影响PHP语法：4个文件PASS。
- 隔离运行文件与固定R1源码身份匹配PASS。
- 原APK未重建，1011601文件SHA256复核PASS。

上述原始测试日志和部分运行回执存放在Owner本地私有证据目录；GitHub manifest记录文件大小与SHA256，结构化测试摘要已提交。本顾问未直接访问Owner本地私有日志文件，因此不将其表述为本会话重新执行的测试；本轮独立判断依据包括固定源码复核、远端结构化证据、哈希清单和工程报告。

## 四、七项AC最终状态

| AC | 第二轮最终结论 |
|---|---|
| AC16-01 权威状态来源盘点 | ACCEPTED |
| AC16-02 统一只读状态API | ACCEPTED_IN_NAMED_SCOPE |
| AC16-03 自动化授权生命周期 | ACCEPTED_IN_NAMED_SCOPE，R1 CLOSED |
| AC16-04 有限、可靠、可审计执行 | ACCEPTED_IN_NAMED_SCOPE |
| AC16-05 每周慢约持续参与 | ACCEPTED_IN_NAMED_SCOPE，R1 CLOSED |
| AC16-06 APP状态与自动化入口 | ACCEPTED_IN_NAMED_SCOPE |
| AC16-07 集成与集中交付 | ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS |

## 五、仍然保留的限制

以下事实不因R1通过而改变：

- 首次数据库探测误连主开发库；迁移返回Nothing to migrate，业务fixture被隔离名称guard拒绝；前后逐表摘要继续UNKNOWN。
- 十二项固定基线旧测试失败继续FAIL；全量回归NOT_RUN。
- 主开发APP新开放轮次报名、真实跨周等待NOT_RUN。
- 最终备份独立恢复NOT_RUN。
- 新自动化表真实擦除集成专测NOT_RUN。
- 主开发环境R1部署验证NOT_RUN；原DB/API/WS在本轮保持停止。
- B2调度在API容器重启后需按运行手册手动恢复。
- Owner手机及整体实机验收NOT_RUN，按Owner决定延期至B1+B2+B3完成。
- 1011601原APK沿用，R1没有重建APK；APP源码本轮没有变化。
- 真实用户、生产数据、main集成、正式发布和真实运营均未使用/未执行。

## 六、Owner权限与下一步

本报告只记录GPT顾问独立验收，不替代Owner整版接受。

v10.1.16 B2顾问验收现已通过。是否接受v10.1.16、是否开始讨论并授权v10.1.17/B3，仍由Owner决定。本次不自动启动B3，不进行main集成或发布。
