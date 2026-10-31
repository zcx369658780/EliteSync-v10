# EliteSync v10.1.5｜最终设备/RTC/WS/H264专项集中结果

日期：2026-10-31。状态：**PARTIAL_WITH_EXPLICIT_G2_DEVICE_PROVIDER_GATES / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING**。

本轮已完成有实质源码和测试支持的WS生命周期/入口加固，并新增一批真实浏览器最小Web验证；没有本轮APK、Android密文、真实Workerman、完整视频或RTC声学/5秒停媒成功。交付仅是非main研发候选，等待Astra独立验收。

## 固定对象与选择性来源

Task ID `V1015_FINAL_DEVICE_RTC_WS_H264_GATE_20261031`；Task Blob `e9dee55a80ae274456edb8da109206e5d05183c6`；冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。

开工fresh main/唯一Parent `ea682562c148166dcf502a048c7e47a4e136fb8f`；Parent Root `f3de1943893c608cda7dbd59f44cc657ea531f4d`。发布前fresh main仍相同；主线产品apps/services仍 `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `049a8676cc90b3b830e32a524c172720e800fa37`。

接受来源 `b441d1808bb366dbffebbecc03180b7bedd197f7`，Root `11b73b2d3bca69d5212dc11fb7a4f109ca126c35`，Manifest Blob `f8df511f0f99ca223ccda0ee17ae3fb4589b8fd1`；Astra Review Commit/Blob `923d248385c46d7bcecc1b29dced6f307b1dcb87` / `fe1d22b21fddfd7ec5a0bf427faddd7d219be0df`仅作接受依据，不是研发Parent。

84项接受输入已逐项原生mode/Blob/bytes精确接续。最终81项保持一致，3项WS来源修正；另10项为dev/prod接线、端点验证及本轮测试/CLI夹具。共94项源/测试，加本Result和新Manifest共96项。没有整树合并、旧报告覆盖、依赖锁或vendor入Git。

两份文档加入前源码Root `77762d5c220ec25c8d9efad6b81d8f31590aff67`；最终产品apps Tree `2526e6ec86b4e054a2d712aab41f5cd6dd5a38a8`，services Tree `7634b4755a41f08641e00948f684c06efb12d8fe`。最终Commit/Root以GitHub原生对象和发布后回读为准，不把自身Hash嵌进报告造成循环身份。

## 实际修复

- ChatSocketDataSource在任何异步profile/token/upgrade前绑定身份与取消；session/账号/status/授权epoch变化主动close，取消frame与identity订阅、HTTP upgrade、身份定时器和重连Timer。每次连接有独立代际，超时后晚到的旧socket会关闭；每个观察最多首次加5次重连，不允许旧token无限重试。合法当前连接仍能收取scoped invalidation。
- LiveChatPage在切号、授权变化、拒绝、后台和dispose时显式cancel旧订阅。旧事件用当前session/epoch守卫，不能触发新账号读回；恢复前台须当前HTTP再验证后才订阅。
- dev/prod现有bootstrap接入WS配置。仅允许API同主机的显式WS端口；HTTPS禁止降级WS；明文仅限dev的受控loopback/既有模拟器宿主桥。HTTPS无覆盖时继承WSS及非默认端口，本地缺覆盖保留既有8081 gateway。旧未资格化公网HTTP不再推断Bearer WS目标；配置非法即终止该观察，不通过禁用所有合法连接报PASS。

## 本轮真实测试与保留失败

| 本轮检查 | 结果与证据边界 |
|---|---|
| Flutter定向5文件 | 47 tests，exit0；含新服务/Widget/URI/bootstrap正反例及受影响既有聊天可靠性。Socket和SecureStorage为软件夹具，不是设备或服务器E2E |
| Flutter分析 | 初次exit1/3 info保留；修正2处大括号和1个重复下划线后exit0、No issues。无suppress、删断言或skip；后续仅上述样式修正 |
| PHP8.4.27 / PHPUnit12.5.42 | 10 tests/58 assertions/exit0；新8项WS当前权限/真实服务Token轮换/MC/CN/Block/失效session，加既有2项缺视频验证器fail-closed。使用独立SQLite内存库，非Workerman/MariaDB媒体成功 |
| 当前执行器PREPARE | 实际当前执行器9负例：logger、真正event.flush、真正event.fsync × write/revise/process，未准备目标副作用0；故障只落标记.fixture测试数据，未污染唯一真实账本或倒签旧缺口 |
| 新独立MariaDB最小Web实例 | 应用实际目标/grants合格，迁移前0表及空库SQL读回恢复点；单次迁移和单次合成seed后93表、2虚构用户/1管理员。APP_DB_CONNECTION=mysql真实覆盖故意的DB_CONNECTION=sqlite。没有重做旧93表163行重启任务，DB重启0 |
| Windows loopback API | 实际健康200、缺鉴权401。初次内部网络没有有效发布端口而连接拒绝，原失败保留；仅任务自有无IP masquerade front桥修复精确127.0.0.1发布，无防火墙/全局改动 |
| 真实IAB Web视觉 | 原浏览器选择成功，单批真实渲染/截图与操作：登录页、具名管理员CSRF登录、同库2账号、审计页、退出、旧session拒绝、普通用户拒绝，共8项。浏览器请求16交换、两跳32 HTTP单位；无改Web产品源码/私聊正文访问 |
| 非作者有界复核 | 独立Sol/high只读复核六源、三个Dart回归及PHP授权/新库夹具；受检范围内无剩余具体P1/P2。不是Astra终验 |

初次管理员登录因本任务env漏设精确ADMIN_PHONES，被既有安全门正确拒绝；仅将新合成管理员加入任务私有allowlist，以第二且最终API进程启动完成同一连续GUI批，普通账号仍拒绝。原失败和配置修正均保留。离线pub setup的缓存命名空间错误、UTF8控制读取错误、资源名守卫误匹配自己的测试容器及containerd size=null解析失败也保留；修复未安装或升级工具。pub输出的Downloading packages是--offline下已有缓存处理，不是新增外部供应。

历史网络元数据定位中曾附带返回旧合成密钥字段；没有使用或公开该值，并停止进一步此类旧凭据元数据查询。源/报告扫描无私密值及本机绝对路径。所有Bearer、Cookie、SQL、原始HTTP/设备/媒体、配置和账本均LOCAL_ONLY；公开Manifest仅有最小摘要、Hash和对象映射。

## AC01–AC11

| AC | 本轮分类与边界 |
|---|---|
| AC01 | SOURCE_VERIFIED / CODEX_REPORTED_LOCAL_RUNTIME；fresh main/Root and accepted84 native objects bound; new empty MariaDB effective target/grants checked; protected dirty252/refs527 and backup11066 bounded verification passed |
| AC02 | SOFTWARE_REGRESSION_PASS / REAL_WS_AND_APP_NOT_RUN；47 new-task Dart tests include valid scoped invalidation and finite reconnect; b441 API120/message idempotency remains historical accepted input, not rerun |
| AC03 | SOFTWARE_AUTHORIZATION_PASS / TEST_INJECTION / WS_REAL_RUNTIME_NOT_RUN；account/logout/epoch close idle sockets and cancel subscriptions; timeout generations and late events covered; PHP actual token rotation and MC/CN/Block current authorization; no running Workerman proof |
| AC04 | VIDEO_API_VERIFIER_GATE_CLOSED / PLAYER_NOT_RUN；no existing trusted ffprobe found in bounded approved inputs; two PHP verifier negatives passed; no new real H264 upload, READY, Range or player claim; b441 valid fixture retained only as history |
| AC05 | OPEN / NOT_RUN_GATE_CLOSED；one named historical Review retained; no currently qualified dual devices/MIC/CAM/SFU/shared timebase, no fresh AEC or COMMIT-to-last-media <=5s measurement |
| AC06 | ACCEPTED_SOURCE_RETAINED / SOFTWARE_RETENTION_REGRESSION；trusted T0 inputs unmodified; targeted live-chat software time/cache regressions passed; physical15/30days NOT_RUN |
| AC07 | DART_SOFTWARE_SUPPORTED / ANDROID_NOT_PROVEN；new session lifecycle isolation plus inherited private-cache source; fake SecureStorage widget harness is not actual Android encrypted bytes/cold start/deletion |
| AC08 | ACCEPTED_NOTIFICATION_SOURCE_RETAINED / OS_NOT_RUN；no new device/OS notification permission or delivery evidence; no weakening of accepted notification current-read/privacy |
| AC09 | TEST_ONLY_SOURCE_RETAINED / REAL_PUSH_PROVIDER_PENDING；no external supplier/SDK/credentials/fee/real Push operation |
| AC10 | NEW_WEB_BROWSER_MINIMAL_PASS / APP_DEVICE_E2E_NOT_RUN；single real IAB batch: admin login, same new DB two fictional actors, audits, logout/current denial, ordinary-user denial; loopback API health200/missing-auth401; no new DB restart or whole old regression repeated |
| AC11 | SOURCE_MAPPING_AND_BOUNDED_REVIEW_COMPLETE / CANDIDATE_READBACK_REQUIRED；94 source/test paths with native mode/blob/sha256, two new docs, process exit/stdout/stderr hashes; final commit/sole-parent/Root/products and96 blobs fresh readback required before permanent STOP |


## 未运行门及最小下一许可包

现存已接受PHP镜像实际pcntl/pcntl_fork=false，限定可信输入未发现ffprobe。**WS_REAL_RUNTIME_NOT_RUN / VIDEO_API_VERIFIER_GATE_CLOSED**。未启动Workerman，未本轮重制影片或运行真实H264上传/READY/Range/撤权；未弱化探测器、伪写READY或从旧PNG/旧影片拼PASS。

G2 false，Gradle/ADB/设备/USB/额外音视频预算0；无本轮构建/安装/APK/package/signature/hash。Android真实密文落盘、冷启、OS通知及同源APP链NOT_RUN/NOT_PROVEN。测试Token轮换不是客户端真实refresh流程或设备证明。

AC05仅一次核对固定Review Blob `5e5851cc54185d488490706e99deaed57cb67802`并核实名单：沿用PCM/Room、call4/call5与旧token403有限接受，历史10.125秒不是5秒/AEC证明。缺现行合格双端、MIC/CAM/SFU/网络和同步测量点，**AC05仍OPEN**。真实Push PENDING；物理15/30天、逻辑DB恢复等未运行。

下一门只需一次集中决定：①具名G2/Gradle/SDK/cache及指定设备/ADB/USB/app namespace权限；②来源/许可/ABI/Digest完整的pcntl与ffprobe输入，若现存没有则另获准的有界供应/私有copy；③AC05具名双端、媒体/SFU/guard和同步COMMIT→最后有效媒体/AEC对照资源。三个条件相互独立，不需要重做Laravel13迁移、114包安装或本轮已通过软件测试。

## 预算、保护、资源与回滚

文档冻结单调用时约53.1分钟，硬窗口90分钟。Flutter批3/4（含失败分析）、PHP批1/3、DB启动1/2、API启动2/2、迁移1/1、seed1/1、DB重启0/1、真实WS0/1、WS真实旅程0/1、H264真实API0/1、浏览器GUI1/1。HTTP预留计费83/100；实际两跳/直连尝试35单位，含1次连接拒绝；未用48单位池预留仍消费、不继承。

任务根logical 2,556,897,267字节、allocated保守上界 2,696,720,384字节；新DB卷du 229,288KiB；含6个只读容器日志/元数据额外384MiB保守预留，工作面合计上界 3,334,164,480字节，小于8GiB。containerd的SizeRw/SizeRootFs为null，未伪作0；不声称OS全局VHDX硬配额强制已证。终端总量随STOP封存LOCAL_ONLY。

新增外部供应、Composer安装/solver、Docker pull/build、Gradle/ADB/设备/音视频采集、全局PATH/ACL/Firewall/策略及费用均0。单一全新root、attempt-0001、持久账本，成本动作先PREPARE/flush/fsync；旧STOP余额不复活。旧PREPARE缺口及WINDOWS_E_NOTIMPL、跨attempt、旧fixture恢复、限制身份/OS enforcement等历史观察不清零。

旧Laravel11.48默认根、dirty252、refs527及原index/HEAD保护通过；11,066文件/240,617,393字节备份元数据和160 SHA样本通过，Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。b441旧封存ledger SHA256 `a36dc49159a7f6885344d94fa4af20a437768cd9417bf0d2ef639850f2c98ec0`不变，具名更早历史封存保留。这是实际触及范围核验，不是全盘审计或新的旧版恢复证明。

6个任务容器、回环代理及临时浏览器页已停/关闭；新卷、恢复点、源文件和全部旧资产保留，没有删除、移动、默认入口切换或旧数据库访问。回滚是保持现main与旧默认入口，不集成本候选；不对任何旧库执行down/清空。

最终发布单个non-force非main候选，sole Parent固定开工fresh main；96项path/mode/Blob/正文、Commit/Parent/Root、完整apps/services及最新main须fresh回读后永久STOP。不得自签FUNCTION_ACCEPTED/INTEGRATION_ACCEPTED，不合main、不放行G2或未证AC05、不启动v10.1.6。等待Astra独立验收。
