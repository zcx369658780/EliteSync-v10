# EliteSync-v10｜v10.0.9 真实四规则成功、授权网关预热TimeoutError：Astra独立审查

2026-10-17。**REAL_NETWORK_RULE_LIFECYCLE_PASS_WITH_OBSERVATIONS / AUTHORITY_PREWARM_TIMEOUT_PARTIAL / FIRST_TIMEOUT_SUBOP_UNKNOWN / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED / REAL_WINDOW_EXPIRED / NO_K08**。

## 1. 固定对象、来源与独立证据边界

Astra已通过GitHub连接真实读取独立短期审阅分支`review/temporary-evidence-v1009-prewarm-20261017`、固定Commit `58c58173ce01a12c235dc9f152379ad2d4dbc9f4`、Tree `9c5b7d231e0b04e7363d0ffa5e66d19e34396df6`，它的唯一父提交是产品开发分支`70612d36652660e8bdd9d12017c1254ada686298`，**不是main**。GitHub递归树列出`docs/_temporary_review/v1009-prewarm-20261017/`下8个blob、未截断，比较父提交确认此临时提交只新增8份审阅证据，没有改动产品源码。

Astra直接读取了完整8份文件：`FAILED_WINDOW_REPORT.md`、`NETWORK_RESULT_SAFE.json`、`RUNTIME_EVENTS_SAFE.json`、`EXIT_RECEIPTS_SAFE.json`、`FINAL_SAFETY_SAFE.json`、`PRECHECK_SAFE.json`、`PREWARM_SOURCE_EXCERPT.txt`与`MANIFEST.json`。独立计算7份实体证据文件的UTF-8 SHA256，**7/7**与manifest声明`review_sha256`一致；清单文件本身另行读入，未将其作为自引用哈希核验。源私配/真实IP/设备serial、声音及原工作树均未纳入公开副本。真实Windows运行事实均为`CODEX_REPORTED`，Astra没有物理访问Windows或独立调用PowerShell。

## 2. 真实网络窗口的限定成功

Run `1db58ad8-e2ed-46a6-a084-66dcea00ede5`，Owner一次性已授权、现场声称已准备试听，窗口北京时间2026-10-17 11:19:57.505241开始，最迟11:39:57.505241，实际上提前停止；并未续窗或二次UAC。原始七文件实际身份回执`a8d52ef415ef4157052a0fa128564d36195fc235b595ae51f001e1c67b5ab4ee`（Codex本地重算），固定私有网络参考不变，WLAN/原宿主/63项Block与3项Allow合同不扩大。

固定R3顺序修复在**真实Windows**中取得：4条精确防火墙规则Create、Query/所有权收编及验证成功，随后**自动Remove 4条**，`NETWORK_RESULT_SAFE`记录`exit0, SUCCESS, created_count4, removed_count4, remaining_count0, final_query ZERO`；共28次实际PowerShell操作（Create序号3/6/9/12，Remove序号18/21/24/27，余为Query）均记录exit0；子进程和外层`GetExitCodeProcess`记录0，父层独立读回ZERO。最终另行对Windows ActiveStore和PersistentStore四条名字逐项回读都为0，查询exit0。原exit31失败证据继续保留。本Run未保存原始数组成员顺序，不能声称观察到此次确实重排，但完整真实规则生命周期有效。

按上述直接审阅的安全回执，**仅此网络规则生命周期可判定`REAL_NETWORK_RULE_LIFECYCLE_PASS_WITH_OBSERVATIONS`**。不是RTC媒体/业务AC通过，也不表示原自动收口在所有强杀/系统挂起条件下必然硬实时成功。

## 3. 首次失败定位与未知边界

`RUNTIME_EVENTS_SAFE`记录：11:20:28.949723原DB start exit0、11:20:29.862571 DB health exit0；约11:20:29.90起依次启动php/front/authority/bridge/worker五个自有进程；在11:20:35.940765出现`TimeoutError`，未记录`authority-prewarm`成功事件；随后停止两端测试APP与全部自有进程、DB，服务监督exit1并导致controller exit1。受控SFU未启动，未创建call/room，CN/MC当次现行资格未检验，A/B/C全为NOT_RUN。

已实读来源脚本的安全摘录：启动后固定`sleep(1)`，确认5进程未退出，之后通过`http.client.HTTPConnection(...,8002,timeout=5)`向`POST /api/v1/rtc-guard/sweep`发送带内存中网关凭据的请求，等待响应、读JSON并要求HTTP200且`allowed_rooms=[]`。现有回执**无法指出异常发生在connect、request、getresponse或read的确切子句**；5进程启动后存活不证明8002已经监听/请求处理成功。五进程原标准流被重定向到DEVNULL，没有可追溯的PHP服务端原始错误输出，不能补造。

Astra额外实读产品开发分支源码`services/backend-laravel/app/Http/Controllers/Api/V1/RtcGuardController.php`、`app/Services/RtcAuthorityService.php`及`routes/api.php`：`sweep`是具名内控路由，读取活动RTC会话并执行实时授权检查；针对无权/过期会话可能在事务/锁下执行`invalidate`改变会话状态和事件。因此**sweep不是无副作用的普通healthcheck**。目前没有证据把本次超时归因于数据库锁、冷启动、端口未监听、请求连接或防火墙，也不能把这次失败归类为Laravel产品代码bug、SFU错误或设备问题；根因保留`AUTHORITY_PREWARM_TIMEOUT_PARTIAL`。

## 4. 本阶段裁决与下一任务

- 接受本次**真实网络规则自动收口成功**的限定证据；**服务预热门FAILED**，v10.0.9仍`NOT_ACCEPTED`，唯一产品AC-09-03仍`NOT_PROVEN`。此前R1-1/R1-2及离线R3源码通过结论不重开，不需要再重复网络源码修复/全量回归。
- 下一步仅允许同版**本地只读归因＋最小监督脚本的离线诊断/准备度机制修订和mock验证**：读取真实`service_supervisor_order_current.py`整体启动序列、8002进程创建/端口监听/依赖、实际`sweep`业务路径、已有时间与错误记录；采用不泄露凭据、私网地址或响应正文的阶段/耗时/异常类型记录，安全区分连接、发送、响应头、响应体；建立独立无副作用的进程/监听/只读liveness准备就绪门，再调用**原有真实sweep**验证授权语义，保持fail-closed；离线替身模拟冷启动、拒绝连接、阻塞响应、网关拒绝、DB未就绪、sweep实际非空房间/503以及超时失败收口；全程复用绝对20分钟/245秒服务与240秒规则收口保护，不通过一味延长HTTP超时掩盖未知原因。
- 不得把`POST sweep`伪装成只读探针、直接改返回200/`[]`、移除鉴权/撤权或绕开冻结AC；本阶段**禁止真实启动DB/SFU/PHP、发送sweep请求、修改Windows防火墙、UAC、设备、APK、真实音频或新Run**。真正要执行真实端到端检查需Owner**再次明确授权**，之前的唯一系统窗口已结束。
- 如果源审查发现必要修复位于Laravel产品代码或新增权限/资源，先交付精确影响与候选方案，不在此次无系统权限任务中擅自实施。保留原dirty root、持久volume、媒体、私配和所有失败，不合main产品、不执行K08/后继版。

## 5. 临时证据处理

审阅完8文件后，依据Owner已批准`docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md`，允许Astra仅在`review/temporary-evidence-v1009-prewarm-20261017`上执行非强制快进清理，**恢复它自己的父提交`70612d36652660e8bdd9d12017c1254ada686298`的Tree**，切勿将`main`树覆盖到由开发分支派生的临时分支。确认HEAD及临时目录不再存在后，仅由Codex精确删除该短期远端branch引用、Astra读回API404；删除不能保证Git历史/外部缓存完全消失。

## 6. 临时审阅文件清理实际回读

Astra已对本次短期分支`review/temporary-evidence-v1009-prewarm-20261017`执行且验证**non-force fast-forward**纯树清理：新Commit `6d908a0ddcfe7449b686b61d5c81c873eb6b0f36`，唯一parent为原审阅Commit `58c58173ce01a12c235dc9f152379ad2d4dbc9f4`；新Tree精确恢复`6dccb9f4339e7656883bc7594fbb8a8cc11f5636`（即从产品开发分支派生时的父树），不是main的产品树。GitHub独立回读临时分支HEAD正确，原审阅文件`docs/_temporary_review/v1009-prewarm-20261017/FAILED_WINDOW_REPORT.md`在清理HEAD返回404；8个临时文件不再位于最新工作树。

**尚未删除短期远端branch引用。** 当前阶段`TEMP_TREE_CLEANED / BRANCH_DELETE_PENDING`；Codex只在重新只读核对远端分支HEAD正是`6d908a0ddcfe7449b686b61d5c81c873eb6b0f36`后，一次性普通删除该精确远端branch；Astra再独立查API404，之后另行更新闭环状态。原固定审阅Commit的历史对象不能因清理而声称永久擦除。

清理后`main`仍含本审查文档，开发分支为`70612d36652660e8bdd9d12017c1254ada686298`，不改产品源或冻结AC。
