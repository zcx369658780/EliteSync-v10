# 历史关键证据摘要

日期 2026-11-13

本文提供本机回执的复核定位、操作顺序与结果字段。原始文件、日志、截图和安装包仅留在 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`，不随文档发布。状态为工程自验或历史继承，不代表当前候选通过。

## 609 候选 RTC 撤权停媒与旧授权

候选 APP `60930170e3a437da0b77e877c55ed4dd1a92f9ca`，APK SHA256 `d8af0c896ceeb43d2251c89d1080eced593392d5127b0276c95db7ba88b89b67`。原回执 `candidate609-rtc-authorization-tail-verified-20261112-private.json`，原回执 SHA256 `8030cc03c56e2cfb9e3c39fc2bebe759bac2d4a7dd3e9512276f30f5d90eed8d`。

复核步骤是启动同一通话双端，先检查当前 JWT 正向有效、媒体双向有效，再记录当前同意状态与单调时钟。撤销 MC 后以普通 autocommit SELECT 轮询可见状态，不使用长事务。commit 可见区间以最后 ACTIVE 查询主机起始和首个变值查询主机结束夹定。同步采集 Android CAMERA 与 RECORD_AUDIO 原生状态，检查旧且未过期 JWT 被拒。新同意后检查旧房间消失且旧 JWT 仍被拒。

结果字段包括 `commit_measurement`、`commit_visibility_interval_seconds_since_request`、`native_stop_upper_bound_seconds`、`request_to_native_stop_conservative_upper_bound_seconds`、`within_five_seconds`、`native_stop_stability_samples`、`native_capture_stable_beyond_commit_five_second_boundary`、`old_app_jwts_rejected_while_still_unexpired`、`old_room_absent_after_new_consent` 和 `old_app_jwts_rejected_after_new_consent`。回执字段 `native_stop_upper_bound_seconds` 为请求起始到双端原生停采集上界 4.922 秒。commit 到停采集上界见 `post_commit_native_stop_upper_bound_seconds`，为 4.874250 秒，已含两倍 0.015625 秒时钟分辨率余量。请求到停采集保守上界见 `request_to_native_stop_conservative_upper_bound_seconds`，为 4.953250 秒。后两项分别按 commit 基准和请求基准对照 5 秒目标。commit 后稳定采样越过 5 秒边界，未见采集反弹。

这是模拟器原生权限状态与自有服务证据。当前候选 `cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d` 已另完成call51真实撤权链，当前结果见本轮README与EVIDENCE_SUMMARY。

## 609 未知 POST、冷启与同 UUID 重放

候选与 APK 同上。完成回执 `candidate609-pending-completed-20261112-private.json`，原回执 SHA256 `3c564823b8103990cd19141fc5e22e7fd626ed4b625d044c84817de9f6e7d473`。

步骤为正常 APP 发送一条测试消息，观察代理将真实服务端成功确认替换成 503，造成客户端结果未知。断网并冷启后确认草稿未显示。恢复在线并核验原会话及 peer，再对原编号执行明确重试。读取服务端观察结果及持久行，最后再次冷启确认 pending 清空，并检查自动 POST 计数。

结果字段 `observed_posts` 显示两次请求具有同一 client message ID，第一次 server ID 109、状态 200、非 replay，第二次同 ID 和 server ID、状态 200、idempotent replay。`send_actions` 为 1，`manual_retry_actions` 为 1，数据库匹配行仅一条，密文持久化，确认后 `confirmed_cold_empty_draft` 为 true，`auto_post_count` 为 0。回执另保留观察器最初未显示 unknown send result 的失败及修复后的原编号重试说明，不能删去该失败。

2d 候选 `2dce99ef80a74a1e24a8ea193cfff073733af406`、APK SHA256 `e24ab96eb277f68d9e9239e9006e6fbbb225bb278801afc980401a7f0d0d0888` 有两个不同回执。起始 `final-pending-post-cold-20261112-private.json` 状态为 `PARTIAL_REQUIRES_INSPECTION`，SHA256 `17f389c445582a41eaeed91f589266a9ebf86a9a9b17821d69a497e98cee8e5e`，不得引用为通过。另名完成回执 `final-pending-post-cold-completed-20261112-private.json` 状态为 `FINAL_CANDIDATE_PENDING_COLD_IDEMPOTENT_REPLAY_VERIFIED`，SHA256 `870fae7d26cb8a47959943056db11d742972da0715d390697941514e047281c0`。完成回执字段包含一次发送、一次人工重试、自动 POST 为 0、冷启草稿为空及同候选 APK 身份。该证只归属 2d，不替代 609 或当前候选证据。

## 15/30 天受控路由边界

后端核心 `6549f02880968f99ae3f45439d15a37c1b3d5251`。回执 `retention-route-boundary-20261112-private.json`，原回执 SHA256 `0a12310018362ad9634eacf30060ed4ab508c0ff17a318fa924f63480ee0285d`。

复核步骤是在真实 Laravel HTTP kernel 与 MariaDB 事务内创建虚构账户、设备和 T0 绑定，设置受控服务端时间，调用登录、私有资料读取、session verify 和 refresh，并在 15/30 天边界前、当时、之后各执行读与刷新。检查每个 HTTP 状态、refresh 后身份和期限是否固定，最后在 finally 清理受控时钟并回滚夹具，比较原 users/sessions/tokens 指纹。

结果字段 `routes` 有 16 项。失败登录 422，成功登录、初始读取、verify、15 天前读取和 refresh 均 200。15 天当日与之后读取和 refresh 均 401。30 天前、当日、之后的读取和 refresh 均 401。`refresh_kept_fixed_identity_and_deadlines`、`original_users_sessions_tokens_unchanged`、`fixture_transaction_rolled_back` 均为 true。

这是实际服务端路由和数据库事务的受控时钟证据。`client_clock_changed` 为 false，`elapsed_30_days` 为 false。自然时间没有经过，不得写成自然 15/30 天验收。

## Android 插件故障探针与产品清理

探针回执 `cache-native-probe-runtime-20261112-private.json`，探针 APK SHA256 `84d614ab6c3a44da7b81c4c40132fe273866d07e03ceb29f7aeb65c94f307f5c`，原回执 SHA256 `7ffe71ebd9f289e7b87096943ac3a678790640a1a40dba1a1db03b598698fa15`。此探针是独立包 `com.elitesync.v1015probe.v1015dev`，UID 与 Keystore namespace 独立。

步骤是在实际 Android 加密偏好插件上运行探针，采用受控 wall/elapsed 时钟和 synthetic retention receipt，在 object-delete、completion-write、primary-delete、recovery-delete 四个 wrapper 点分别注入单故障，再注入连续三故障。首进程定位末步失败后 force-stop，再由新 PID 冷启重试，并比对原产品加密文件前后 SHA256。

结果字段 `native_controlled_boundaries` 覆盖 15-before、15-at、30-before、30-at。阶段 0 记七次 wrapper 故障及 `NATIVE_FAILURES_VERIFIED_RESTART_RETRY_PENDING`。阶段 1 的 PID 不同，状态 `NATIVE_COLD_RETRY_COMPLETED`，重复删除数为 0，原产品加密文件 hash 前后相同。`hardware_keystore` 明确为 `NOT_VERIFIED`。因此这证明独立 probe 包 UID 中真实插件 API 的 wrapper 故障恢复路径，不证明产品硬件效果或物理介质故障。

产品已有本地清理回执 `cache-android-cold-local-cleanup-private.json`，APK 来源候选 `bfbbe4eda27423acf25fdf48eb2b763102650b13`，APK SHA256 `4211c5a1e2adf60570c6e87605805ce85bee098f8e831aeb41c04f275a4dfbef`，原回执 SHA256 `214f1da410899dd14e3009088db9f67c6d52c1197f4ad710957bb233d5f8e46b`。步骤是在 emulator-5580 冷离线、现有登录本地状态下，用官方 Flutter debugger 调用产品 `AuthLocalDataSource.clearSessionWithReceipt`，并读取完成回执和已知对象清单。结果为已知对象 1、剩余 0，manifest、recovery manifest、owner locator 均不存在。它不是 UI logout，未枚举未知存储，也不验证物理删除或硬件 Keystore。

## 旧通知路由的撤权点击

候选 609 及 APK 身份同上。回执 `candidate609-stale-notification-click-20261112-private.json`，原回执 SHA256 `361e071a71b60c4fecf0f2e6915d394f2068e96fe30e5a8897d0c19ac1c64275`。

步骤为实际点击通知中心旧通知，观察 handler 发出 detail GET，在转发该请求前正常撤销 MC，然后检查真实 API 返回路由数据、页面去向和目标已读副作用。结果字段 `handler_detail_request_observed`、`consent_revoked_before_detail_forward` 均为 true。`actual_detail_presentation` 的 route_name、route_args、payload 为空，通知中心保留，`target_read_posts` 为 0，`read_at_before` 和 `read_at_after` 均为空，detail 耗时约 0.281 秒。该结果只适用于这一个候选、通知和撤权时序。当前通知 provider 与协调器有源码变更，当前候选的受影响重验仍须独立记录。

## 媒体并发与回执边界

11 月 8 日的 MariaDB 锁等待证据只继承其原候选与原 actor/peer 条件，范围包括 Block、CN 关闭、peer 禁用和 MC 撤权的并发协调。609 回执另提供当前 JWT/媒体访问与撤权后旧 URL 拒绝的有限运行结果。相关材料由 IMPLEMENTATION_REPORT.md 的具名矩阵链接定位。

从 609 到当前候选的历史累计变化涉及 RTC 生命周期、权限与路由及聊天附件路径，因此旧矩阵不是当前版本全组合证明。本轮 R1 相对其前序源码只改资格、MBTI、引导、连接页面及 SFU 开发服务工具，没有修改 RTC 客户端、聊天或通知实现。当前另完成call51撤权、call53故障恢复与call54正常通话，原候选的这些历史边界继续单独记录。609 最终附件明确重试曾有 18 秒观察窗口超时，只有正常发送证据；5af 的一次明确重试是另一候选证据。不得混合候选身份作单一通过结论。
