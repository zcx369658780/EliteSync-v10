# v10.1.5 消息可靠性、离线密文生命周期与授权通知软件实施交付

日期：2026-10-28。研发审阅分支：`codex/v10.1.5-messaging-offline-notification-software-20261028`。

**结论：DELIVERED_PARTIAL_WITH_EXPLICIT_BLOCKERS / STATIC_OR_PURE_UNIT_EVIDENCE_ONLY / AWAITING_ASTRA_INDEPENDENT_REVIEW。** 本轮交付真实业务源码、接线和测试源码；获准的31项独立PHP纯逻辑契约检查与23个变更PHP文件语法检查通过。Flutter/Dart类型检查、Laravel Feature测试、真实APP/API/DB/WS链、物理密文与清理、真实Push均未运行或未证明。不得据此声称端到端成功或v10.1.5接受。

## 权威与基线

- 唯一任务：`V10_1_5_MESSAGING_OFFLINE_NOTIFICATION_SOFTWARE_INTEGRATION_TASK_20261028.md`，Blob `b8553497a6e98f524550c4f6e89d8ccdccb79e62`。已读取全文，摘要不替代合同。
- 开工fresh main及唯一候选Parent：`6a90c05538d1de8d648e645693ef9b1bf23b78f0`；Root `f5ac305a5f9eaa04bf2346322811909ff00ef047`；ACTIVE_STATE `76bb66874bb8446b30a8f9bacdd691bb25f660ce`。
- 冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`；Astra事故裁决 `aed5280d831c812da2211282ae0795f7dccf0b48`。原冻结计划的其它AC没有删除或降级。
- 唯一已接受产品v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`；services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。GitHub递归完整回读720+700个baseline Blob/mode/path，与本地独立工作面起始manifest一致。
- 未接受参考候选 `ce3e278eae6872179153243ca3060a18f68abcfd`，参考apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。53条定点参考路径的Blob均与GitHub完整参考Tree对应；只按路径采用相关实现，再修复本轮发现的问题。未整树合并、未以未接受候选为Parent。

## SOURCE_PROVENANCE 与依赖闭合

manifest的`SOURCE_PROVENANCE`逐路径列出main Blob、参考Blob（无则null）、最终Blob、mode、字节数及采用/重写决定。当前60个产品路径变更；完整产品1440个文件，所有其它baseline文件按原Blob/mode保留，无删除。

F1采用chat页面/provider、网络会话guard、token/peer范围WS信号、服务端消息事务/授权锁等相关源码。F2采用安全存储及账号/设备namespace、可信登录receipt和退出/切号入口。F3采用通知偏好、当前presentation、TEST_ONLY注册投影与迁移/路由。其余accepted业务和安全边界保留。新增3个生产纯契约被真正服务调用，独立测试直接加载这些生产类，未另造一套模拟算法当生产证明。

明确排除参考pubspec的RTC vendor改动、无关本地数据库环境allowlist和live DB环境测试；`PlatformAccess.php`恢复为accepted原Blob。保留既有Flutter SDK约束、flutter_secure_storage及permission_handler依赖，无下载、无新provider/密钥、无Android/Gradle/RTC/vendor构建配置修改。新增两份migration仅交付源文件，未运行；不改旧migration。新增`wsBaseUrl`为可选空默认值，兼容既有AppEnv调用，未配置真实服务。

## F1 实现与限制

服务端在两个用户有序锁下读取当前账号/token和授权事实；事务内同键回读先于新附件写入校验。完整authorizeSend也用于回读，覆盖Block、Connection/MC与离开会话；同sender+clientMessageId只有一条持久化消息，同payload返回原消息，不再次建立附件或通知。指纹绑定接收方、正文与有序附件；不同payload返回冲突。既有唯一键及事务是运行前提，MariaDB真实并发结果仍未验证。

客户端将一次逻辑发送的键与payload保留用于手动重试；超时、5xx/408/429和错误确认身份不标成功。ChatRoom核对外层/嵌套确认身份；LiveChat保留未知attempt与草稿，当前查询可以重新确认。session/token/关系epoch、前后台与页面生命周期guard阻止晚响应和旧WS污染。服务端WS保持当前token/peer授权，帧只作为当前读取的失效信号。数据库落盘、实际网络响应丢失后的恢复、真实WS撤权竞态均NOT_RUN。

## F2 实现与限制

成功密码在线登录产生服务端T0、user/device/session与固定15/30天截止；注册不冒充成功登录，refresh不改变T0。客户端只在receipt匹配账号/设备并满足绝对截止关系时建立进程内单调时钟；墙钟仅用于发现异常。重启从锁定态开始，不以保存的token/profile自动登录或信任跨重启时钟。此保守边界意味着本轮不承诺重启后无需联网的离线访问。

本地私密值经现有平台安全存储接口，按账号+设备namespace、session/object/login envelope及当前read grant隔离；同进程断网后只读既有grant，15天后在线写入不可用，30天后拒读并按owned manifest清理。manifest≤128对象、键≤256字符、单envelope≤512KiB；写队列捕获generation，防止旧账号写借用新namespace。错账号、损坏envelope和异常时间锁定。退出同步清空可见session/锁cache/使未完成登录失效；成功登录持久化、可见凭据写入和退出删除共用同一AuthLocal队列，清理在调用时入队，等待旧写结束后删除双凭据并读回核验，不越过下一次登录。异步清理返回明确receipt，失败维持未登录并给出通知；profile晚写需再次核对intent和session。两种held credential write与logout交错的回归源码均已加入，但Dart执行仍NOT_RUN。

平台安全存储的物理密文、系统keystore、真实设备删除/恢复、跨进程生命周期未验证。注入15/30天属于`SIMULATED_CLOCK_ONLY`的测试设计，客户端测试本轮亦未执行；`ELAPSED_TIME_NOT_PROVEN / PHYSICAL_DEVICE_CLEANUP_NOT_PROVEN`。没有读取旧SQL或个人缓存进行测试。

## F3 实现与限制

通知设置入口按账号读取分类/静默偏好；换号清空旧偏好，恢复前台重读OS权限。拒绝权限不阻断站内业务。系统权限不会制造token注册或真实送达。本轮没有接入Push provider或后台处理SDK。

服务端TEST_ONLY device注册保留token hash并绑定user/device/session/generation；当前资格检查先于去重回执，logout/revokeAll撤销相应device。投影正文固定最小标题/正文，仅含notification_id定位符，不含peer/私信/Safety详情。当前通知点击新GET端点按owner查询、no-store；presentation统一拒绝过期/分类关闭，消息、平台活动和本人Safety入口继续各自当前授权。客户端先fresh查通知，再查询目的地，并在await前后核对session/关系epoch。真实Push、OS后台/锁屏送达和系统撤销回调链仍`REAL_PUSH_PROVIDER_PENDING / NOT_RUN`；TEST_ONLY不是系统送达证明。

## TEST_CASES：正反合同与运行层次

| ID | UI/调用触发 | API/持久化/权限预期 | 本轮证据 |
|---|---|---|---|
| F1-01 | 提交已成功但响应丢失，点击重试 | 同clientMessageId、同接收方/正文/附件顺序；返回原持久化消息，不新增附件关联或站内通知 | PHP pure fingerprint/replay PASS；V1015MessagingTest 和客户端 widget 源码 NOT_RUN |
| F1-02 | 同键改正文、接收方或附件顺序 | 当前授权先检查；不同payload冲突409；不发布假成功 | 纯契约 PASS；API/DB NOT_RUN |
| F1-03 | 已提交消息的附件后来变成failed | 先回读已提交事实；只有新提交进入附件锁定预检；实际媒体内容仍经当前权限接口 | 新增 Feature 源码 NOT_RUN |
| F1-04 | Block/Connection/MC撤销、成员离开、账号禁用、token注销后重试 | 同键回读也需要当前完整发送授权；旧token/旧WS/晚响应不能污染新页面 | 纯撤权布尔契约 PASS；交易锁并发/WS/客户端源码 NOT_RUN |
| F1-05 | 发送收到502、408、429或无可用确认 | 保留原attempt和payload，显示未知；手动同键确认；echo身份不符不得成功 | LiveChat/ChatRoom 回归源码 NOT_RUN |
| F2-01 | 真实密码登录成功；失败密码/注册/refresh | 只有成功登录提供可用T0；refresh保持原T0及15/30天截止，不续期 | 纯UTC绝对时刻/不续期规则 PASS；登录API/DB NOT_RUN |
| F2-02 | 同进程断网，合成时间跨15天至30天 | 既有账号/设备/对象读grant下只读；在线保存和发送关闭；到30天锁定并精确清理 | PrivateCache 注入时钟测试源码 NOT_RUN；真实经过15/30天 NOT_PROVEN |
| F2-03 | 重启、时间回拨/跳变、坏密文、换号、登出 | 不以持久化token/SDDL/设备墙钟恢复信任；重启锁定；坏记录锁定；精确namespace清理失败保持不可读 | 客户端测试源码 NOT_RUN；物理加密/删除 NOT_PROVEN |
| F3-01 | 更改分类偏好、静默、拒绝或撤销OS权限 | 不阻断消息/匹配；偏好由当前账号API保存；系统权限仅显示当前状态，不制造provider注册或送达 | 纯分类/资格规则 PASS；客户端/Feature 源码 NOT_RUN |
| F3-02 | TEST_ONLY token轮换、换号、logout、过期家族 | 哈希token，账号/设备/session/generation绑定，去重；撤销和当前资格先于既有投影回执 | 纯guard与最小正文 PASS；持久化/并发 NOT_RUN |
| F3-03 | 点击旧通知：已过期/被Block/已撤权/换号中 | 先按当前owner查通知，再由当前presentation与目的地API授权；空payload不得导航；异步切号响应丢弃 | 新 GET owner-only 及平台/安全旧入口测试源码 NOT_RUN |

实际运行：现有PHP 8.5可执行文件（SHA256 `e120479f40a9b7b90e779cb845d1d13a9a4e7923e7681cbb851f41bc139f3971`），`-n`禁用ini扫描，任务私有cwd/HOME/TEMP/AppData/cache，open_basedir限任务根；禁用进程/网络函数和URL读取；独立脚本不bootstrap Laravel、不加载vendor、不访问DB/网络。31项细分为消息指纹/回读10、可信绝对时间/不续期7、通知分类/资格/最小投影14；退出0。23个变更PHP文件`-l`均退出0。最后结果stdout SHA256 `02b3350583ce5221ed1e01e7bd7906786e6a2f90630e3e71f2fff2330f49305a`。这些运行是`CODEX_REPORTED_LOCAL_EXECUTION`，GitHub源码回读不是本地执行的独立见证。

静态检查：所有变更Dart文件的本包/相对import目标存在、无产品删除、无构建依赖文件改动；**这不是Dart语法/类型编译**。非作者独立Sol/high只读审查发现并复核修复了附件预检顺序、回读授权、5xx未知状态、通知expiry、同步logout和profile晚响应；最终两处小guard也经过复核并补mounted检查。独立代码审查不是Astra验收。

| 检查/运行 | 状态 | 原因或实际层次 |
|---|---|---|
| 独立PHP生产纯契约31项 | PASS，exit0 | 无框架/DB/网络；不证明并发或E2E |
| 23个变更PHP语法检查 | PASS，均exit0 | 不执行框架逻辑/迁移 |
| Dart本包/相对import及静态审查 | 已完成有限文本核对 | 类型/编译NOT_RUN |
| Flutter/Dart test/analyze/format/pub/build | NOT_RUN_ENV_GATE_CLOSED | 本轮CLI预算0 |
| Laravel Feature/PHPUnit、SQLite/MariaDB、迁移 | NOT_RUN_ENV_GATE_CLOSED | DB/工程运行预算0 |
| 真实API/HTTP/WS、持久化/附件/通知并发 | NOT_RUN | 服务与网络端到端预算0 |
| OS权限GUI、平台密文、15/30天物理时长/清理 | NOT_RUN / NOT_PROVEN | 无设备与物理时间证据 |
| Push供应商、APK/ADB/RTC、Gradle/JVM/AAR/POM/G2 | NOT_RUN，0运行 | 未授权且未启动 |

## 失败、预算与保护

原始失败均保存在LOCAL_ONLY：纯契约red阶段在生产类未创建时require失败（exit255），后续生产实现后green退出0；早期GitHub整Root递归响应缺结构、archive参数拆分失败、archive换行转换与immutable bytes不一致（写入前已按Blob逐项归一）、两次源编辑辅助脚本部分完成后分别因GBK解码和错误route形状查找退出。已修正对应普通源码/准备问题；没有将一次聚合命令的exit0冒充其中失败脚本成功，没有重做ACL/child实验。初始red/lint/green原日志保留，后续检查使用独立时间戳日志，未覆盖失败。

本任务目录观测：logical `136871626` bytes、allocated `139835928` bytes，分别小于268435456；包括独立源码工作面、两份原archive、定点reference、脚本与日志，无SDK/cache副本。allocated用只读FileStandardInfo.AllocationSize逐文件核算，检查无文件hardlink/reparse；前后观测及最终回执另存LOCAL_ONLY，不把离散快照称为连续峰值监测。报告/manifest和远端回读预计不足数MiB，最终仍需复核上限。

受保护dirty根未作为写面。只读Git元数据观测local main `4bebc8f394248e254c1368a06fbdee5d2c883301`、527 refs、43条tracked dirty项；完整列表LOCAL_ONLY。未清理/重置/写入该根、refs、历史原证或Seed。没有为本轮软件开发再枚举旧18件/事故树ACL或重新hash全部Seed；历史身份保护沿用固定原证，不能以本轮文本核对声称其OS安全状态重新通过。

| 操作 | 本轮次数 |
|---|---:|
| ACL/DACL/SACL写入、旧18件修改/恢复/删除/移动/重建、新fixture | 0 |
| restricted/对照child、14项OS矩阵 | 0；14项NOT_RUN |
| G2 Popen/claim、旧预算账本写入、Gradle/JVM/Flutter CLI | 0 |
| DB/API服务/SQL执行、设备/APK/RTC/Push、生产/第三方运营动作 | 0 |
| 候选 | 唯一普通non-force研发分支，main集成0 |

Owner封存事实完整保留：`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`；历史A/B共2树6后代、父DACL变更/恢复各2次相对1/3/1/1超限。不得退款或重置。旧18件严格SD恢复、历史瞬时副作用/峰值未证明，旧APK/G各1/1耗尽、旧A关闭；条件性G2余额不是本次运行授权。原始Windows路径、SID/SDDL/binary、用户资料、DB与密钥不在本交付内。

## 制品身份与最终回读

预期完整apps Tree `61c0dd9a70fcd56af00053f1d055884cecf052f0`；services Tree `cc61686579f4a89ac092f3f557ba1f8191471528`。manifest逐文件final Blob可独立复核；两份文档之外只发布任务相关产品源码/测试。最终GitHub回读Commit唯一Parent/Root、完整双产品Tree、所有60个变更源码Blob以及report/manifest原字节；候选自引用身份在提交后completion receipt记录，避免在自身Blob中循环声明。`DIRECT_GITHUB_READBACK`仅用于实际远端对象/内容核验；LOCAL_ONLY原始日志不上传。

后续真实验证必须由Owner另行冻结DB/Flutter/设备/Push/OS/G2权限和预算，本轮没有创建或实施后继任务。当前只将此集中候选交Astra独立验收并STOP，不merge main。

永续状态：`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE / CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。
