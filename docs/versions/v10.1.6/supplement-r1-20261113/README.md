# v10.1.6 R1 补修结果

2026-11-13。R1-01、R1-02工程补修完成，顾问复核PENDING。顾问对222923bd的CHANGES_REQUIRED结论保持其固定候选身份。

稳定根为 `D:\EliteSync-v10-product-v1015-20261101`，分支为 `codex/v10.1.6-backend-productization-20261113`。本地核验后以fast-forward接续任务文档64a09b2b，源码保存为 `69b95628a35ceae6fb7a3f726b5034ddb0d1750a`。

## R1-01 当前发布与受众判定统一

修复前，SlowDatingService只检查public_display_eligible并直接投影介绍和标签。具名回归构造当前有效、未到期匹配，匹配对象没有好友或正式关系授权。修复前9个权限用例中7个失败，实际journey、decision及有效重放返回了应隐藏的Showcase。

ShowcaseWorkflow现在集中判断当前账号、拉黑、合法关系上下文、发布状态、public_display_eligible及本人选择的audiences。详情、图片和慢约摘要共同使用该判定。旧发布缺少显式audiences时保持不可见，私有草稿保持独立。

SlowDatingService在无Showcase权限时返回showcase=null，并保留合法提案状态、解释、接受/拒绝/撤回及连接资格的现行条件。JourneyStore的有效命令重放继续重新投影当前发布与权限。

同时修正轮次消费者对Showcase存在性的依赖。服务端明确投影candidate_available，MatchRoundProjectionService据当前合法候选状态提供原有轮次信息，合法候选的轮次状态继续为revealed。资料字段隐藏后，APP现有提案和决策控件仍按独立状态消费。

实际修改了3个服务、1个新增回归文件及2个既有测试夹具。既有发布重放用例补齐明确好友范围与关系；轮次矩阵夹具补齐当前提案和参与上下文，保留原矩阵与只读断言。后者在旧MatchRoundProjectionService上同样失败，修复前基线结果已保存。

## R1-02 三文件精确字节对齐

固定Git Blob与原工作树/容器的差异已逐字节确认。三个文件此前所有行均为LF，最后一个换行为CRLF，各多出一个CR字节。确定性关系为 `before == git_blob[:-1] + b'\r\n'`。Git的text=auto/eol=lf清理会消除该字节，解释了原工作区显示干净的情况。

旧manifest数值精确对应当时工作树和容器字节，并与前轮私有部署回执一致。当前已把三份工作树文件写为固定Git Blob的精确字节，既有绑定挂载中的容器文件同步一致。三文件均无逻辑差异。

| 文件 | 原工作树及容器 字节数 / SHA256 | 当前Git Blob、工作树及容器 字节数 / SHA256 |
|---|---|---|
| ProfileShowcaseDraftController.php | 3019 / `868da4744bde6e301ef25ce1c98c7d5f71c356871ae06671acc6eb52685c5dd9` | 3018 / `e3ddf8654e2a8d06107be18367bca92617cb5b46e2423621035768c9f6a9d02f` |
| ProfileShowcasePublicationController.php | 2248 / `a3a38511d7bbe5a95e4ab8b4a1ef0cd7bf713b7d86bb93f1ccad7cc51753567c` | 2247 / `b1c5e8402623bb5e1c903eace94ca5546520823ce95bc38e1cde4613ab5890aa` |
| AdminShowcaseController.php | 3774 / `277fc02b4c63ab82517b2962bb6ece369467d250d32ef728c25cbbb54df422fc` | 3773 / `d07a286a83f4370313dbde5f994fd688ec575aff0354ff340097bc8deb36253b` |

最终清单逐项记录Git提交、Blob对象、字节数、SHA256、工作树字节、实际容器字节及相等关系，同时保留旧声明和确定性转换。新增或变更的3个服务也已绑定最终Git与部署字节，检查总计8份相关部署文件。

## 本轮实际验证

- PHP8.4.27隔离环境的49项定向测试、790条断言通过。范围为journey/decision/重放、好友/contacts/正式关系、撤回、受众收紧、无显式受众、账号受限、拉黑、参与换代，以及受影响的轮次和资料工作流。
- 在当前API容器、Laravel HTTP kernel与现行MariaDB上执行8次具名权限夹具请求，直接命中GET journey、POST decision和有效重放。friends/relationship反例隐藏、contacts正例可见、撤回后重放隐藏，合法轮次及决策状态保留。使用显式夹具认证及事务回滚，所有夹具业务行回滚，自增序号可自然前移。此证据归权限回归。
- 现有普通Bearer会话完成9次真实HTTP只读检查。本人草稿8、发布5及好友读取一致，无关系账号的详情/两张图片被拒，好友图片可读，journey正常。原业务数据与私有照片保留。
- 三份控制器在实际PHP8.4容器中语法检查通过。最终Git Blob、工作树和容器的8份相关文件逐字节相同。非作者Codex定向源码复核未发现剩余修复项。

原APP/Web普通审核发布成功链、照片排序移除、反馈重提、断网保存、撤回拉黑、切号及重启持久化成果，按222923bd及其具名源码范围继续继承。原报告62项PHP、57项Flutter结果保持原时点，本轮新增验证单列。

APP源码子树与fe9360b7一致，继续使用 `10.1.6-dev / 1010601 / com.elitesync.v1015dev / arm64-v8a`。APK为123715466字节，SHA256 `444da1b6361734bcfd589ef2983add1fa823abb5709b6e7bfee238ca3db6bbf8`，对应APP源码fe9360b7。本轮APK构建、安装及设备操作均为NOT_RUN。

## 资源与交付

资源实读为 `2026-11-13T17:05:32.754024+08:00`。DB/API/WS运行，SFU为exited，房间UNAVAILABLE，原因OPEN/UNKNOWN。SFU结转至后续通信工作，当前RTC源码与任务基线一致。本轮设备及手机无动作，原15:57设备停止和数据保留回执继续作为具名历史状态。

私有原证位于Owner本机 `EliteSyncDev/v1015-current-dev/v1016-current/supplement-r1`，包含修复前后测试、控制器原字节与三方对齐、当前部署验证及资源回执。凭据、原始日志、数据库和APK继续由Owner本机保管。

本轮原主库dirty/index和无关%SystemDrive%/保持保护。源码、此R1结果、manifest及ACTIVE_STATE按同版分支普通同步并回读。最终交付提交由本分支Git历史及私有交付回执定位，交付后停下供顾问R1验收。
