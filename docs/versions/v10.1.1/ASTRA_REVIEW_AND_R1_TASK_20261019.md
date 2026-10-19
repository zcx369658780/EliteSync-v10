# EliteSync v10.1.1｜Astra独立审阅与R1同版集中返修任务

日期：2026-10-19。审阅者：Astra。

**V10.1.1_CHANGES_REQUIRED / NOT_ACCEPTED / R1_TASK_ISSUED / MANUAL_DISPATCH_PENDING / NO_PRODUCT_MAIN_INTEGRATION / NO_NEXT_VERSION**

## 1. 裁决

当前候选不接受，保留其全部已完成成果和原始证据。同一项P1权限一致性问题出现在两个使用点：MediaController::privateContent与StatusPostController::toggleLike。在报告所述MariaDB REPEATABLE READ环境中，两处均在取得协调用户锁以前建立普通读取快照，等待撤权事务完成后仍用该旧快照进行权限判断。

这是冻结AC-10.1.1-04/05内的当前受众和撤权问题，不是新增产品功能，不推迟到v10.1.5。本次只安排一次集中R1修复、必要回归和候选重交，不重开十项AC的全部实施，不要求重做所有算法或手机RTC窗口。

**证据层级：源码中的读取次序和缺少当前读由Astra直接检查；并发后果依据该源码及MariaDB官方事务语义推导，置信度高。Astra没有在用户Windows/MariaDB执行该竞态，也没有证据证明发生过真实用户泄露。R1须在既有受控开发环境完成确定性前后复现，不能把本记录写成Astra已现场复现。**

## 2. 已核验的固定身份

| 对象 | 身份 |
|---|---|
| 冻结计划所在及审阅前实时main | c4a3a524ef47980962dfc965d7bf9865037734ae |
| main Tree | bc5b75f1508f64795abf4dee86c0a08d43dfa10e |
| 冻结plan Blob | d01cf1c43c242d3a492700d71d32edea4375475b |
| 被审源码Commit | 34a0b0ed4209895cebd4ef040519ac13a8054b6c |
| 被审源码Tree | af6ee10b91d542331f682e8a6e140f12ce96dd7b |
| 完整交付Commit | 713e801345c4cb2f996fdf1338eb2d973c810359 |
| 完整交付Tree | 523698367deae057ed97790de21b961db0a18aae |
| 候选apps / services | 1ddc864a8f7f8f7e024d6102a36057252bc77bab / fe0d8f58575ceb98eca60fd47cdeb3804c7874b2 |
| IMPLEMENTATION_REPORT.md Blob | 0dc9209e630f80aae08c19e7a0a653d0d1c7032c |
| artifact_manifest.json Blob | 8e70333876a6e2580d5ee9a948d3878e7b2adc6e |
| 审阅包固定Commit | e03b4c44df328ce3ae5656009dcca7a3cba7b262 |
| 审阅包目录 | docs/_temporary_review/v10.1.1-20261019/ |

源码Commit唯一parent为冻结main。main至完整候选compare为3个后继提交、105个改变路径；主报告、制品清单、根产品树与审阅identity相互对应。没有将候选产品集成main。37个审阅文件的全量字节回读仍为Codex报告；Astra本轮读取了清单、身份、关键结果及脚本副本，并未重新逐文件计算全部37项SHA。

最终APK：com.elitesync.v10x.relationshipdev，10.1.1-dev / 1010101，ARM64＋x86_64，403852021 bytes；SHA256 5ed82741074904b8f3d91817d1d2aab5117579bf918c12036f3e79f049e6ebd9。实体、签名与设备安装pull原证仍LOCAL_ONLY，不冒称Astra重新安装。

## 3. 阻断项 B1：用户锁以前形成的旧快照仍被用于授权

### B1-A：私有封面媒体读取

固定文件：
- services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php
- Blob d9f192c58cfec9a57bf74f1084c423c23f842893
- 方法 privateContent

事务内先以ChatMessage::whereHas(...)->get(...)普通读取附件参与者，然后才User::...->lockForUpdate()。拿到用户锁后，SocialPolicy::pairAllowed、StatusPost::...->first以及SocialPolicy::friendship仍是普通读取。最后锁MediaAsset只核对资产状态，并未让先前受众、好友和block查询改用当前视图。

可验证次序：A和B原为好友，A有FRIENDS动态和一张仅作该动态封面的受控私有图片；B不是所有者，此图片没有聊天附件等独立授权。A的受众修改事务先锁用户，将该动态改SELF但尚未提交。B请求图片，在事务内附件查询建立旧视图，随后等待A的用户锁。A提交，B获得锁；用户和媒体行可完全未变化，但后续普通查询仍见旧FRIENDS，因此存在撤回先提交、等待方随后仍返回实际图片字节的路径。解除好友或拉黑可作同类反例，须确保没有其它独立合法授权使结果混淆。

### B1-B：动态点赞／取消点赞及响应正文

固定文件：
- services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php
- Blob 75b9141d74ac667d502040a592653a49e1d900db
- 方法 toggleLike；相关 visibleFeedQuery / visibleStatusQueryForPost / shapePost

事务第一条普通查询是StatusPost::whereKey(...)->value('author_user_id')，之后才锁用户。等待后visibleStatusQueryForPost仍是普通查询；返回前所谓fresh再次调用同一普通查询，并未刷新REPEATABLE READ视图。撤回或解除好友先提交时，旧视图可能继续允许互动，并把动态title/body及封面定位返回请求方。

本项要求同时验证敏感响应和数据库副作用；只证明最终好友状态已变、通知被隐藏，不能证明点赞入口没有越权。

### 共同依据与已有修复对照

SocialPolicy::pairAllowed / friendship（Blob ceedad119a908c1022148f3cc8db0e52538fb59f）使用普通读取；相关路由没有为上述两入口建立一个先取得协调锁的外层事务。EnsureAccountActive的owner-private writer锁不覆盖GET media内容和status likes路径。

本版SocialController::store已经明确将邀请候选定位移出事务，注释说明避免在用户锁等待前形成RR旧快照；transition也在用户锁后锁定重读。该有效修复保留，但其成功不证明媒体和动态入口已采用相同纪律。

技术依据，仅用于核验数据库语义：MariaDB官方SET TRANSACTION及REPEATABLE READ说明，RR事务的普通一致性读取复用第一次读取建立的快照；给另一张表加FOR UPDATE并不自动刷新后续普通读取。
- https://mariadb.com/docs/server/reference/sql-statements/administrative-sql-statements/set-commands/set-transaction
- https://mariadb.com/docs/server/reference/sql-statements/transactions/transactions-repeatable-read

R1实测必须记录实际服务版本、连接隔离级别和相关snapshot设置，不能用SQLite顺序测试替代，也不能为复现或追绿悄悄改全局隔离配置。若实际调用链已有能够排除该次序的机制，提交该机制、真实请求与确定性屏障证据；不得伪造失败，也不要求为了满足审查预期而错误改代码。

## 4. 不被本次返修抹去的成果与观察

1. 独立请求／好友与CN／MC、受众默认收窄、账号设备家族、注销登记门及保留共享／证据的实现和执行材料继续保留。既有相关通过记录不归零，但不等于已覆盖B1竞态。
2. call14：公开结果记录手机／AVD音频字节增长、0.719／0.704秒停止事件、旧JWT validate和真实WS重连拒绝。Owner在报告记载的同call确认AVD合成音→手机可听；Astra没有亲自听辨。反向人工听辨、最终手机视频和AEC未获证明。
3. 上述停止时长由审阅脚本以宿主采集的room_disconnected/leave_complete事件相对block请求开始计算，并检查5秒后没有相应RTC_MEDIA_RTP日志；不是Astra测得的声学延迟或独立抓包最后一个RTP包时间。
4. call7是较早x86 APK的合成AVD音视频；不与call14拼成同一最终包的真机视频证据。保存旧JWT来自官方issuer的受控夹具，不冒称实际APP内提取的旧token。
5. 原报告明确后续Owner另行批准手机和一次20分钟精确UDP窗口。其细节授权属于报告所述本地回执；临时规则与映射已撤、窗口已结束。R1不自动续窗或扩大设备／网络权限。
6. Windows三个保护根、云端未触及、服务停机、备份及安装原证仍CODEX_REPORTED / LOCAL_ONLY。审阅的resources-final列明本版容器／监听停止、规则和映射撤除，不能据此声称Astra今天现场核查所有资源。
7. 原PHP/Flutter、CRLF、RR双201、构建/手机安装/TCP媒体失败，以及注销FAILED_RETRYABLE等都保留。旧测试集合重叠不汇总成通过率，worker exit0不等于擦除成功。

## 5. R1综合任务：范围内一轮完成

Owner手动将本文件转交Codex后，按原v10.1.1功能授权执行以下集中返修。不再重复请求是否进入同版修复，不启动下一版。

### 5.1 保留原候选，先确定性回归

核验实时main、固定候选和当前专用工作树。保留713e801…报告、34a0b0…源码、e03b4c…原审阅包、原始测试／失败和本地checkpoint。不得reset/clean/stash原dirty根、覆盖其它候选或强制新建完整worktree。

在本版独立开发库及只含虚构数据的受控测试中，优先给B1-A/B各补真实MariaDB两连接／双进程回归：
- 明确first-read、等待用户锁、撤权COMMIT、授权继续四个时点；用可重复屏障或数据库锁等待证据，不能只用sleep推测时序。
- 被测执行走实际产品HTTP入口或Laravel HTTP kernel／原产品服务，不重写一个不同授权算法冒作产品测试。
- 起始正例：FRIENDS、未block、非所有者且无其它媒体授权时，合法读取／点赞可以成功。
- 负例：FRIENDS改SELF、解除好友、拉黑分别先提交，再让等待中的media GET／like路径继续；撤权后应得到具名权限拒绝，不返回图片字节或动态正文，不产生新的无权like／通知副作用。取消点赞按相同权限合同核实。
- 补充先撤权再新请求和正常允许两类控制；仅500、死锁或测试进程异常不能算安全通过。
- 原source的实际结果如实保留；若未复现，解释隔离级别、屏障命中和实际调用路径差异，不编造漏洞已执行。

### 5.2 修复两入口的同一根因

采用正确的统一锁序和当前授权读取。可以将纯候选定位移出事务，再在协调锁后重新核定身份和授权；或对完整授权事实使用合适当前读及写方一致的协调协议。具体实现由Codex决定。

不得只对最终MediaAsset加锁就声称受众已刷新；不得仅重命名fresh变量；不得留下事务外候选身份／附件关系变化后未经复核的另一个漏洞。审查实际first consistent read的位置，包括外层事务、Eloquent关系查询和被调用helper。

只针对本版新增／修改的相同权限使用点做有界类比检查；若发现同根因直接覆盖的路径，一并修复和列明。不要扩为全仓全历史形式化审计或新增功能包。

不得降低隔离级别、移除权限断言、删除失败测试、恢复公开封面URL、让管理员绕过受众，或把撤权后的旧内容解释成新的合法授权以追绿。

### 5.3 有限验证与环境

复用原计划允许的本地MariaDB开发库elitesync_v10_1_1_dev／loopback43322、相关Laravel和必要已获准AVD。先确认资源归属、端口与必要恢复点；仅启动本R1实际需要的资源。保护保留卷、备份、已有虚构记录和旧验收环境，不重seed旧库。

完成新并发回归、受影响Feature／单元及媒体／动态／撤权／注销交互的必要检查。非作者复核重点检查锁序、当前事实、返回正文和副作用，不重新要求无关模型评审。

后端修复若不改apps对象，可以复用现有APK，并明确其旧构建身份与新后端源码组合；用既有获准AVD完成受影响的实际APP读取／撤回最小链。若客户端代码变化，则构建绑定新源码的独立开发APK并做相应安装读回，不能用旧APK证明新客户端。

call14听辨和已完成媒体证据按原时点保留，不重做手机麦克风、20分钟UDP窗口、系统防火墙／DNAT／提权。没有新的这类授权；确实需要时只暂停该子项。若修复影响共享RTC授权，优先原允许范围的本地受控回归，不擅自恢复已结束的窗口。

不操作阿里云试点、公开入口、证书、备案、真实身份/Push/支付/AI供应商或真实用户数据。无关算法oracle及整版全套重跑均不要求；未执行逐项NOT_RUN。完成后停止本R1启动的专属服务，保留数据与原证。

### 5.4 单次集中交付

沿用单份docs/versions/v10.1.1/IMPLEMENTATION_REPORT.md，在后继候选中清楚追加R1修复与结果；旧固定提交及原时点结论保持。机器证据可新增必要文件，不另开多轮只读任务。

交付固定新源码Commit/Tree、最终报告Commit、apps/services、改变路径；说明APK复用或重建、后端组合、前后竞态证据、实际数据库设置、响应／数据库副作用、必要APP读回、非作者结果、原失败、所有NOT_RUN和资源终态。

在本版本候选／R1专用分支普通non-force发布并独立回读，不合main、不force、不覆盖已发原证。审阅副本按现有协议一次集中发布，保留原审阅固定Commit，不自动删除原分支；新脚本执行原件与脱敏副本hash分开。关键新回归的安全stdout/stderr/exit与断言结果应可审阅，秘密、数据库实体、设备标识及原私密材料仍LOCAL_ONLY。

完成出口：**V10.1.1_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**。

## 6. 当前项目状态

- v10.1.1本候选：CHANGES_REQUIRED / NOT_ACCEPTED；AC04/05的B1须关闭。
- 本版其它有效实现与执行证据保留；本记录不把其逐项正式接受，也不要求全部重做。
- 已接受main产品仍为v10.0.11，本记录仅新增审阅与任务文档。
- v10.1.0原PARTIAL和外部AC08延期保持。
- 原plan和10.x路线原文不修改；不启动K08产品集成或v10.1.2。
- Astra本次未执行产品代码、测试、数据库或设备操作。R1待Owner手动转交Codex后实施。
