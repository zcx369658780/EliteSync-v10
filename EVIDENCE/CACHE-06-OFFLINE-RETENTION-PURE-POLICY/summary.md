# CACHE-06｜离线私密内容期限纯判定候选

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发及实现基线 HEAD `66f1eaacf5aec1214051c41be7855ad47d53c438`。

## 结果与边界

仅新增以下三条允许路径：

- `apps/flutter_elitesync_module/lib/features/chat/domain/offline_private_retention_policy.dart`
- `apps/flutter_elitesync_module/test/features/chat/domain/offline_private_retention_policy_test.dart`
- `EVIDENCE/CACHE-06-OFFLINE-RETENTION-PURE-POLICY/summary.md`

`OfflinePrivateRetentionPolicy.evaluate()` 只处理调用方声明。返回三个相互独立的候选值：上次成功在线登录后是否仍在 15 天时间窗、是否符合离线只读条件、是否到达 30 天清理期限；离线拒绝原因可枚举。`0 ≤ Δ < 15 天` 的时间窗不授予在线 live read/send；`15 天 ≤ Δ < 30 天` 在仍离线且绑定、已保存内容、离线读取声明、完整性和已知失效门通过时可只读；`Δ ≥ 30 天` 拒绝读取并标记清理到期。到期信号不执行删除，也不确认删除完成。离线只读仅代表查看已保存内容及草稿的候选资格，不包含草稿编辑、写回、发送或任何网络操作。

时间证明缺失、不可信、异常、负经过时间均锁定，且不据此误标清理到期；登出、换账户、已知撤权/关闭等失效、账户/设备/对象绑定不符、非离线、无已保存内容或密文完整性失败均拒绝离线展示。Work LEVEL 2 预审指出原候选未把计时锚绑定至账户：现增加调用方声明的成功在线登录账户及设备标识，必须同时匹配当前与已保存内容的账户及设备。计时锚绑定缺失或不符时，15 天窗口、离线只读与 30 天清理到期候选均为 false，避免借用其他账户的登录时间开门或误标清理到期。自动 Token 续期、应用重启和 profile 更新时间不是判定输入，调用方必须继续使用最后一次真正成功在线登录的同一计时锚。15 天窗口值只是时间范围，登出等失效后的实际会话有效性仍须由其他权威门裁决。

没有选择或实现可信登录事件、可靠计时、防回拨、离线凭据签发、撤权传播、加密存储、媒体副本或清理机制。所有输入都可由调用方构造；本判定器不能认证其真实性。它没有接入 provider、UI、Token、网络、backend 或旧缓存清理，不产生真实私密读取权、在线读发权或设备擦除证明。

## 验证回执

- 目标测试：首轮 `flutter test test/features/chat/domain/offline_private_retention_policy_test.dart` 退出 0，7 项合成测试通过；预审修正后第二轮 `flutter test --no-pub test/features/chat/domain/offline_private_retention_policy_test.dart` 退出 0，**8 项通过**。累计 **2/2** 次。覆盖 15 天两侧、29 天末和恰满 30 天、刷新/重启/profile 不重置、未知/负/不可信/异常时间、账户/设备/对象及登录计时锚不匹配或缺失、登出/换账户/已知失效、非离线、未保存/离线声明/完整性失败，以及清理到期不等于清理完成。
- 新增源与测试定向分析 `dart analyze ...`：首轮及预审修正后第二轮均退出 0，`No issues found!`；累计 **2/2** 次。
- `git diff --check`：修正前运行 **1/1** 次，退出 0；预算耗尽，修正后未重跑。该命令不覆盖未跟踪新文件。三份新文件另行只读检查尾随空白，均为 **0 行**。

未运行 Flutter 全量测试、Android/设备、HTTP/API、DB、生产或真实数据验证。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送或派发后继；候选停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立验收（2026-09-24）

**LEVEL 2 ACCEPT — 隔离纯判定与合成测试。** Work 核对发布基线 `66f1eaacf5aec1214051c41be7855ad47d53c438`、三条允许新路径及无关未跟踪目录。预审发现原候选可借用其他账户的登录计时锚；作者在同一范围内加入登录事件账户/设备绑定及负向测试，修订后的最终源和测试由 Work 独立静态审查。Work 在修订前独立复跑目标测试 7/7 PASS，修订后再跑 8/8 PASS；作者报告两轮定向分析均 0 issues。三个新文件尾随空白均为 0；暂存差异检查见本地接受提交。

验收只证明给定虚构调用方声明时的 15/30 天边界判定。`onlineLoginTimeWindowCandidate` 只是时间窗，`offlineReadOnlyCandidate` 不是设备授权，`thirtyDayPurgeDueCandidate` 不是清理动作或完成回执。可信 T0、时间防回拨、账户/设备身份、离线凭据、当前 Connection/Consent/CV 与数据权利、媒体副本和真实删除仍 **NOT ESTABLISHED**；不得将本结果直接接入 UI 或存储清理。
