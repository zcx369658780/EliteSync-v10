# EliteSync-v10｜v10.0.9 授权网关预热诊断：Astra独立离线验收

2026-10-17。**PREWARM_DIAGNOSTICS_OFFLINE_ACCEPTED_WITH_OBSERVATIONS / AUTHORITY_PREWARM_REAL_ROOT_CAUSE_UNKNOWN / NEW_OWNER_REAL_RUN_APPROVAL_REQUIRED / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED / NO_K08 / NO_NEXT_VERSION**。

## 一、固定审阅身份

Astra通过GitHub连接读取 `review/temporary-evidence-v1009-prewarm-diagnostics-20261017`、固定Commit `e843cc77f3938877814dc331d0e5c8399bd7b29e`、Tree `0c546fc6d53725dbcb18775867664a880d6fdeaf`，其唯一parent为产品开发分支 `70612d36652660e8bdd9d12017c1254ada686298`，非docs-only main。GitHub完整递归树在 `docs/_temporary_review/v1009-prewarm-diagnostics-20261017/` 下独立枚举**28个blob**且无截断；compare_commits证明此短期提交只新增这28份临时材料，未更改产品开发代码；manifest列27项实体文件，另1份是manifest本身。此前 `review/temporary-evidence-v1009-prewarm-20261017` 远端branch已由Codex一次删除且Astra直接通过GitHub API确认404。

Astra已实际读取修复报告、两份diff、四个完整新运行脚本、离线测试报告/终验流与退出回执、非作者审查、哈希/产品来源绑定及部分测试源码。独立从GitHub公开字节计算四个新增运行文件SHA256，**4/4吻合**manifest及独立审查记录：
- `prewarm_diagnostics.py`: `96187f569d2f8f8768caf4587d4025f6ae8533d3a8881eb1b9aeb591f8f05d6e`
- `prewarm_transport.py`: `941691a08b01a8fc43e2d4c10f55145b032aec71861e95332e7e01d48f8b07dc`
- `service_supervisor_prewarm_diagnostics.py`: `9eb111a9c24eb67521a3a620aaf224448b7251a3914be7c5a16d527486d61ab3`
- `window_controller_prewarm_diagnostics.py`: `49cfb9332fa7ec77577c85e69a1a8fe4a2cee3c0215099a7a7002fac8a63e58e`

Astra按声明算法独立计算以上原始文件SHA映射的JSON SHA256，得到**新四文件Bundle** `a12065a0c6c81ea24db598fd265e92b6a4b7d7acb890849c2268734fc2257b46`，与固定报告一致。原七文件真实网络Bundle `a8d52ef415ef4157052a0fa128564d36195fc235b595ae51f001e1c67b5ab4ee`保持不变。GitHub公开副本SHA一致不等于Astra有权直接查询用户Windows实时状态；实际执行前Codex必须重算现场原件并检查安全门。

## 二、离线修复覆盖及安全语义

1. `service_supervisor_prewarm_diagnostics.py`在原服务启动后，不再仅靠固定sleep(1)与`Popen.poll()`证明网关可用，而是检查本轮`authority`子进程持有的精确loopback `127.0.0.1:8002` TCP监听，再做有界TCP接受和现有Laravel `GET /up` HTTP liveness；默认最大监听等待5秒，未知/外来PID与诊断失败均fail-closed。明确区别“进程活着”和“监听/HTTP可应答”。
2. `prewarm_diagnostics.py`按严格安全阶段诊断`connect`、`request`、`response_headers`、`response_body`，操作序号、毫秒耗时、白名单异常、有限HTTP状态和体积；不输出真实地址、网关凭据、JWT或正文，诊断写入失败本身拒绝通过。
3. `prewarm_transport.py`使用同一HTTP交换的5秒单调deadline，并由真实`_DeadlineSocket`在connect前重新计算剩余、各次send/recv前重复收紧；默认最终响应体上限64KiB。独立单调计时测试涵盖HTTPConnection/HTTPResponse/SocketIO的Connection:close/生命周期及header/body慢速trickle，避免每次recv重置5秒导致无限延长。
4. `/up`是框架已有健康入口，Astra另外从固定产品开发分支实读 `services/backend-laravel/bootstrap/app.php`（`health:'/up'`）；但该入口只被用作HTTP liveness，不被当作当前DB与CN/MC业务权限充分证明。其后仍需要**恰好一次真实** `POST /api/v1/rtc-guard/sweep`，并严格检查`HTTP200`与`allowed_rooms=[]`；绝不将`sweep`替换为虚假200或固定空房间。Astra曾实读原`RtcGuardController::sweep`与`RtcAuthorityService`，该路由检查真实授权且可能根据现存过期/失效会话执行事务、撤权和事件写入，**不是无副作用的只读健康查询**。
5. 原controller对新supervisor做最小入口路径接线，其实际网络launcher、一次Run/授权、STOP、总1200秒、服务245秒与规则240秒收口预留未放宽。启动新阻塞阶段前还有可用预算门。清理`finally`按原资源归属保留，失败不得启动SFU。旧原始supervisor/controller及先前exit31/本次prewarm失败原证没有覆盖。
6. 结果`tests/final-33/offline.stderr`确实列出**33个unittest方法均ok**、尾部`Ran 33 tests in 0.484s / OK`，`offline.exit`为0、`offline.stdout`为空；unittest正常日志写入stderr，不能错误称之为stderr为空。首次28项测试/开发回执单独保留。33项包含监督脚本runpy入口的18个模拟场景与HTTPConnection/SocketIO路径5个新增场景，模拟所有系统执行器；没有实际Docker/设备/Windows/UAC/sweep请求。
7. 非作者独立审查`PASS_WITH_OBSERVATIONS`曾指出connect前没重新扣除早期启动耗时，修订后四源SHA固定并由离线测试覆盖。Astra独立阅读源码和测试，未发现本次指定范围内必须再开新开发轮的确切阻断。

## 三、独立裁决及不能越界的观察

**`PREWARM_DIAGNOSTICS_OFFLINE_ACCEPTED_WITH_OBSERVATIONS`**：本轮只对具名本地脚本副本和模拟离线测试作接受，不构成“先前真实TimeoutError已解决”的证据，更不构成 `AC-09-03` 或 v10.0.9 整版接受。旧Run第一次超时究竟卡在connect、发送、接收头还是body，以及PHP内部为何未回应仍`UNKNOWN`。服务端原stream本就`DEVNULL`，不可补造。新脚本在真实Windows上能否识别正确进程监听、Laravel`/up`及真实带凭据的`sweep`仍没有验证；本轮没有修改Laravel和Flutter、没有启动真实服务或触及原持久卷。

**下一门是Owner新一次性真实受控运行授权**；前一次20分钟窗口已到期且不得复用。真实测试前必须由Codex按固定身份重新核对原七文件网络Bundle、四份新诊断脚本SHA及其Bundle、新Run UUID/精确Owner授权、Docker与DB/SFU归属及持久卷、原四具名规则在ActiveStore/PersistentStore全0、准确WLAN/来源，双设备最终APK、进程独立监督与245/240秒收口预留。Owner现场试听准备需开麦前再次确认。若就绪门无法通过，必须停止、保留故障阶段并安全收口，绝不无限重试、超窗或扩大权限。若就绪成功，也仍须同一新call中完成Owner听辨的模拟器→手机、手机→模拟器及同时双向三个阶段后才能提出AC-09-03关闭。无Owner新许可**不能执行**UAC、创建或删除Windows规则、Docker服务/网关/sweep或设备操作。

不合main产品、不执行K08或后继版本；旧R1/R3/R4已关闭门不重做全量开发。

## 四、短期审阅分支清理

本正式结论归档后，按Owner已批准的临时审阅协议，仅对`review/temporary-evidence-v1009-prewarm-diagnostics-20261017`按固定HEAD做普通**非force快进**提交，恢复其自己的父提交`70612d36652660e8bdd9d12017c1254ada686298`之Tree，而**不能**用main的树。回读确认最新临时目录不存在后，再由Codex按精确的新清理HEAD仅删除该短期远端分支引用一次；Astra核验GitHub API404。不得宣称已擦除历史Git对象或缓存；原LOCAL_ONLY资料不变。

## 五、短期审阅文件树清理实绩

Astra在本轮实际执行并通过GitHub独立回读：临时分支`review/temporary-evidence-v1009-prewarm-diagnostics-20261017`在HEAD为审阅Commit `e843cc77f3938877814dc331d0e5c8399bd7b29e`时，以唯一parent执行普通non-force快进清理Commit **`ef66a9aeda69888252bbbfdd5ea7246b6466acaa`**；清理后Tree **`6dccb9f4339e7656883bc7594fbb8a8cc11f5636`**，精确等于**开发分支的父树**（不是docs-only main树）。GitHub独立回读分支HEAD及Commit身份一致，原临时目录的`PREWARM_DIAGNOSTICS_REPORT.md`在新HEAD返回404。28份审阅文件已从该短期分支最新树移除。

**当前：`TEMP_TREE_CLEANED / TEMP_BRANCH_DELETE_PENDING`。** 远端branch引用尚待Codex在重新核对精确HEAD为`ef66a9aeda69888252bbbfdd5ea7246b6466acaa`后仅删除这一个具名短期分支一次，再由Astra查询API404。Git历史/缓存中可能仍有固定历史对象，不能宣称彻底擦除。清理时main（审阅文档写入后`51fa71ab9b7141f02d76bdf173b08d41cc6871fa`）与产品开发分支`70612d36652660e8bdd9d12017c1254ada686298`均未被此清理动作更改。
