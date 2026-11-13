# v10.1.5 R1 补充结果

2026-11-13。工程出口为 **CHANGES_REQUIRED / PARTIAL**。R1-02 至 R1-05 已形成下列限定结果，R1-01 仍有部署独立权威池后一次非注入超时的根因缺口。顾问复核与 Owner 最终接受均为 PENDING。冻结判定保留 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。

## 候选与变体

APP 源码为 `cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d`，后端核心为 `6549f02880968f99ae3f45439d15a37c1b3d5251`，后端开发服务工具为 `e7b21c7fdb0991a5fbd5a9272c92c2331c0dec2d`。三个源码提交依次为 e7b21c7f、5e278f7d、cfdce773。准确树身份、APK 和历史修订见 [manifest](../artifact_manifest.json)。

交付包为 `com.elitesync.v1015dev`，`10.1.5-dev / 1010501`，arm64 Debug，v2 签名。APK 为 154580169 字节，SHA256 为 `311632a8c735b53d97984dc9b45f00c1d7cdc6e72f848807cb40d99f62d7fc69`。稳定目录离线构建退出码 0，耗时 38.3564155 秒，两模拟器 base.apk 与此 hash 相同。APK 在 Owner 本机 delivery 保管。

本轮对象为 `restorationLocalBuild=true` 的恢复开发包。Source Debug 的 v10.1.5 gate 和 v10.1.4 既有路由 gate 启用，API 使用本机 8021，WS 使用本机 8022，自有 SFU 经专用路由连接。`main_prod.dart`、`app_router.dart` 的条件路由决定恢复版使用真实开发消息、慢约和 LiveConnection 页面。关闭该构建门后的另一套消息、MatchShell 与 Connection 页面只保留其既有 SRC_ONLY/演示状态，本轮运行结果绑定上述开发包。资格旧组件由现有注册路由经 Debug GoRouter 打开，当前主导航“准备状态”仍按恢复版路由进入慢约旅程。

## 修复与实际验证

| 工作项 | 本轮结果 | 证据及边界 |
|---|---|---|
| 资格提交 | 失败留页保留输入并显式重试。POST 已成功而读回失败时只刷新 GET。账号、intent、登录会话和路由控制迟到结果 | 当前 cfd 组件受控响应实测，POST 共 2、状态 GET 共 3。虚构输入，供应商调用和资格数据库写入均为 0。定向测试覆盖切号、在途 provider 重建与资料更新 |
| MBTI 与引导 | 明暗主题选中项完整可读，A/B/A 重选和 3/3 提交前回看通过。引导文案指向“进展” | MBTI 为 cfd 当前包，服务端测评提交 0。独立 Android user 注册登录后的首次自动引导为 e7 包，后续差异只涉及连接页，可继承该文案与触发结果 |
| 连接 | 修复提案 envelope 字段错位，终态可显式发起新 CN/MC 生命周期，保留版本与对象校验 | C6/D7 开发链完成互选、当前 APP 请求连接、对端 API 接受、MC 请求/撤回/新请求/接受、APP 发送124，对端持久读回。提案为明确 TEST_ONLY 夹具，匹配算法未运行 |
| 撤权停媒 | call51 从真实 MC 提交到双端 CAMERA/RECORD_AUDIO 停止保守上界 **2.187250 秒**，满足 5 秒目标 | 最后 ACTIVE 查询起点与首个变值查询终点夹定 commit，区间宽 0.016 秒，加入双倍主机单调时钟分辨率余量。Room0，未过期旧 JWT403，媒体17/18双方原200/206撤权后拒绝，新代次旧 JWT403且旧房间不复活，尾窗双端无采集 |
| 未知 POST 与通知 | 当前包消息125未知 ACK 后离线冷启隐藏、在线恢复、原 UUID 显式重试，单一密文行及单副作用，自动 POST0。旧通知259点击时撤权，路由参数清空、read POST0、保持未读与通知中心 | 各为当前包实际 APP/API/MariaDB 链。通知动作后 MC 已恢复至新代次。保留先前候选证据各自身份 |
| 普通功能 | API 虚构注册与拒绝态、改密成功及错误旧密码、会话与退出已验证。正常管理表单审核及 stale revision409、APP 状态读回已验证 | 这些后端核心和开发部署未变，执行时的 APP 包按各回执记录。题库挂载缺失的两项检查在补齐现有题库后定向重跑通过，初次失败保留 |
| 好友、搭子、社区与正式关系 | 37 次实际开发 HTTP 检查含好友接受/读回、搭子建草稿/开放/邀请/请求/确认/撤回、旧 revision409、社区好友可见/收回SELF/恢复/拉黑拒绝、解除拉黑仍拒绝旧授权。正式关系 PENDING_MUTUAL→确认403→撤回读回 | 仅新虚构 C6/D7，真实身份 Provider 未配置，ACTIVE 与正式关系分享/撤回边界另沿隔离 SQLite 受控检查。普通好友与社区成功链已有实际开发持久状态 |
| 本地反馈 | 生成草稿、编辑使旧草稿失效、重新生成、原生剪贴板 Paste 读回及返回设置通过 | 当前包正常设置入口，虚构文本，服务端提交 0。辅助工具漏过短时 toast，实际复制由同 APP 字段 Paste 读回确认 |

定向 Flutter 集合分别为联合53项、资格在途修补22项、连接终态14项、最终 envelope22项，以及反馈/改密错误/引导路由11项。集合有重叠，分别保留日志与源码身份。对应 analyze 无问题。SFU Python8项通过。后端76项初次两项因题库挂载缺失报错，补齐现有挂载后只重跑该两项，通过26断言。非作者静态审查覆盖资格会话/回执与连接契约，最后未发现新增 P1/P2，作者测试和助手静态审查分别记账。

## SFU 与有限持续观察

历史公共 PHP 工作池全部暂停可复现权威响应超时、SFU fail-closed 和重启。独立内部8082权威池使用同一 Laravel kernel、DB 与 guard，公共8080工作池暂停后 SFU 保持运行且重启增量0。内部权威端口未发布至主机，合法 guard200、缺失或错误 guard404、错误方法及其他路由404。1秒响应期限和3.5秒独立 watchdog 沿原配置。

部署后仍有 **2026-11-13 00:06:45.631 UTC** 一次非故障注入的 `authority_sweep / TimeoutError / 1079ms`。相邻公共与权威 PHP 请求同时出现约6秒的 Accepted→Closing 延迟。当前原证只能定位权威查询依赖与共同延迟，CPU、容器调度、数据库或锁的具体阻塞原因仍为 **UNKNOWN**。独立池已解决可复现的公共工作池占用机制，R1-01 的整体稳定性仍为 PARTIAL。

当前包 call53 双方实际媒体与采集成立后，对权威 PHP 工作进程组请求暂停1.8秒，原回执记录该暂停操作窗口保守上界3.110秒，同时通过公共 API 撤 MC。诊断记录 `authority_sweep / TimeoutError / 1003ms`，SFU fail-closed 并有限重启，双端采集停止、Room0、恢复后未过期旧 JWT403、新同意后旧 JWT403。随后正常 call54 两参与者、双端采集成立，服务端 started_at 至 ended_at 为 **261秒**，正常 UI 挂断后 Room0、双端采集停止。首轮 call52 因启动期控制查询与 gateway HTTP 就绪时差中断观察，原失败保留，后续 call53 完成同机制链。辅助工具的初始房间计数和合并语义控件定位问题均保留在回执，最终结论采用实际稳定读回及可见挂断按钮。

最后候选另完成 **1500.031秒采样窗口 / 1500.906秒工具总耗时**，30秒间隔51个采样、同一 B进程 PID5915。覆盖后台轮询、页面进退、call48自然过期、call49正常拒绝、熄屏20秒与恢复。显式 GC 仅在首尾。Dart heap120759792→126337216字节，运行峰142433968。PSS757743→734208KiB，区间678666至757743。最终保留13个会话与15个事件，历史94份快照累积在该窗口未复现。进程日志 ANR/OOM/fatal 标记0。后续 RTC 故障链位于该观察窗口之后，按单独回执记录。模拟器以 headless/no-audio 配置运行，物理听感与硬件音频证据沿 Owner 原具名反馈范围。

## 材料与剩余项

[完成度与AC表](COMPLETENESS_AC.md)、[证据适用性](EVIDENCE_APPLICABILITY.md)、[历史关键摘要](HISTORICAL_EVIDENCE.md)及 [本轮去敏摘要](EVIDENCE_SUMMARY.json)共同定位当前、继承、受控和受限结论。历史 ba 与5e的源码/APK错挂已依据原构建安装收据修正，修订前值留在 manifest。原120图保留原候选身份，本轮只附 [6张必要补图](SCREENSHOTS.json)。旧材料编制已完成，本轮补充材料已形成，顾问复核仍待进行。

R1-01 上述非注入超时根因由 Codex 后续诊断，需保留本轮未关闭结论。真实 Push、自然15/30天、蓝牙、硬件Keystore/物理故障、完整权限并发与实机音频/AEC矩阵、独立盘面精度继续按明确限制记录。Owner没有蓝牙耳机。G2false对应历史门及退役执行链，其历史状态与本轮已成功的离线构建分别记录。

本次集中材料保存后交 Owner/顾问复核讨论。最终分支提交及同步结果见交付回执，当前本地进度由 ACTIVE_STATE 顶部定位。原始私有回执、凭据、SQL、日志、APK与许可证在 Owner 本机保管。

最终资源实读为2026-11-13 09:20:51中国时间，DB/API/WS/SFU四服务运行、Room0、双端无采集。两APP已正常force-stop，模拟器与原用户0数据保留，5582隔离user10虚构测试数据保留。SFU累计重启3次，其中本轮两次为具名权威池故障注入，一次为部署后非注入超时。

## 实际修改文件

本轮16个工程文件及20个资料文件逐项列在下方。两份Owner附件与6张补图计入资料文件。

```text
apps/flutter_elitesync_module/lib/features/connection/presentation/pages/live_connection_page.dart
apps/flutter_elitesync_module/lib/features/onboarding/presentation/first_use_onboarding_page.dart
apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart
apps/flutter_elitesync_module/lib/features/verification/presentation/pages/verification_submit_page.dart
apps/flutter_elitesync_module/lib/features/verification/presentation/providers/verification_provider.dart
apps/flutter_elitesync_module/test/features/connection/live_connection_page_test.dart
apps/flutter_elitesync_module/test/features/me/presentation/pages/readiness_purpose_page_test.dart
apps/flutter_elitesync_module/test/features/onboarding/presentation/first_use_onboarding_page_test.dart
apps/flutter_elitesync_module/test/features/profile/mbti_center_page_test.dart
apps/flutter_elitesync_module/test/features/verification/verification_submit_page_test.dart
services/backend-laravel/tools/rtc/README.md
services/backend-laravel/tools/rtc/authority_router.php
services/backend-laravel/tools/rtc/rtc_gateway.py
services/backend-laravel/tools/rtc/serve_development_api.py
services/backend-laravel/tools/rtc/test_development_api.py
services/backend-laravel/tools/rtc/test_rtc_gateway.py
docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md
docs/versions/v10.1.5/acceptance/APP_FUNCTIONS.md
docs/versions/v10.1.5/acceptance/README.md
docs/versions/v10.1.5/acceptance/TEST_RESULTS.md
docs/versions/v10.1.5/artifact_manifest.json
docs/versions/v10.1.5/supplement-r1-20261112/COMPLETENESS_AC.md
docs/versions/v10.1.5/supplement-r1-20261112/EVIDENCE_APPLICABILITY.md
docs/versions/v10.1.5/supplement-r1-20261112/EVIDENCE_SUMMARY.json
docs/versions/v10.1.5/supplement-r1-20261112/EliteSync_v10_1_5_Advisor_Review_R1_20261112.md
docs/versions/v10.1.5/supplement-r1-20261112/EliteSync_v10_1_5_Supplement_Task_R1_20261112.md
docs/versions/v10.1.5/supplement-r1-20261112/HISTORICAL_EVIDENCE.md
docs/versions/v10.1.5/supplement-r1-20261112/README.md
docs/versions/v10.1.5/supplement-r1-20261112/SCREENSHOTS.json
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/current-connection-consent-active.png
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/first-automatic-onboarding.png
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/mbti-selected-dark.png
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/mbti-selected-light.png
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/qualification-controlled-confirmed.png
docs/versions/v10.1.5/supplement-r1-20261112/screenshots/qualification-failure-inputs-retained.png
docs/workflow/ACTIVE_STATE.md
```
