# 已有功能实际测试结果

本文件保留2026-11-12原验收包及原候选范围。2026-11-13当前修复、普通功能补证和限制见 [R1补充结果](../supplement-r1-20261112/README.md)，当前完成度以其AC表与manifest为准。

当前提供顾问复核资料，整体冻结验收仍有未完成项。每条结果按具名候选和实际操作范围记录，完整冻结AC结论沿实施报告。

| 现有功能/问题 | 实际步骤与结果 | 候选/证据 | 状态 |
|---|---|---|---|
| 通知偏好 | 手机静默/消息类别切换，后端读回、页面再入保持，恢复原设置 | 5e，notification-preferences-runtime-private.json | 该流程通过 |
| 昵称独立保存 | 手机改名、保存并读回、重入保持、恢复原名，其余资料响应完全相同 | 5e，nickname-runtime-private.json | 该流程通过 |
| 版本误降级 | 原10.1.5-dev提示强更旧0.07.04，修后真实HTTP及手机同包检查均无该提示 | 后端6549，9项54断言，version-check-fix-private.json | 已修复并实机通过 |
| 通知页闪烁 | 原2秒共享数据失效导致loading与scroll重建，改为独立来电读取与单次页面加载 | 通知45项、受影响analyze及限定非作者复核 | 工程检查通过 |
| 通知正常交互 | 手机滚动跨后台扫描周期保持，单条已读使真实未读数50→49 | 8216，notification-fixed-runtime-private.json | 该流程通过 |
| 通知失败及重试 | 最终手机包受控503后停住错误态，恢复服务仍保持，明确UI重试恢复真实列表 | e5aa，notification-failure-runtime-private.json | 该流程通过，Owner确认正常且按钮可用 |
| 通话音频 | 5e call44明确开麦后Owner反馈很清晰，采集保持与输出选择按原回执 | 原5e，当前RTC媒体源码沿用，来电扫描有本次定向回归 | 沿用具名通过范围 |
| 双向文字 | 手机A与模拟器B正常UI各发送一条，两端显示，真实消息115/116各一条 | e5aa，phone-emulator-text-runtime-private.json | 该流程通过 |
| 原生选图返回后自动发送 | e5aa上传asset14后草稿核验阻挡，明确重试复用asset14完成117。bd4c成功短GET后核验草稿，image/video生命周期延迟历史回归先RED后GREEN | 33项、受影响analyze、非作者静态复核，picker-resume日志 | 已修复 |
| 图片与短视频实机 | bd4c同包正常选取，一次自动发图片118/asset15、视频119/asset16，手机预览图片并播放到0:02/0:02，重试0 | phone-emulator-media-bd4c07e7-runtime-private.json | 该流程通过 |
| MBTI可选测评 | 手机虚构账号正常UI选三题A并提交，服务端结果ENFP已确认 | bd4c，截图049至051 | 该流程通过 |
| 三盘本命 | 手机填写虚构出生日期/时间/坐标和算法性别，正常UI保存一次，版本1/1读回，四柱/十二宫/十主体，B原数据及正式用户行相同 | bd4c，phone-natal-runtime-private.json | 软件链通过，独立准确性UNVERIFIED |
| 私有动态双盘 | 两盘明确读取本人虚构本命快照，正常UI保存Synastry，版本1/1与44相位读回，B原历史相同 | bd4c，phone-dynamic-chart-runtime-private.json | 该流程通过，算法独立核验待完成 |
| 独立Web管理面板 | 隔离Chrome登录，用户/详情/举报/匹配/账号安全/审计/搭子/平台/问卷/版本真实页面采图，登出后受保护页面回登录 | 后端6549，admin-readonly-current-runtime-private.json及长页补图回执 | 读取与登出链通过，管理写操作沿具名历史范围 |
| 其它现有页面/设置/问卷/关系/图盘 | 已采集部分当前界面，控件逻辑继续按源码盘点及实际页面验证 | SCREENSHOTS、UI_NAVIGATION_AND_CONTROLS | 进行中 |
| 最终资料完整性与顾问总验收 | 功能说明、各UI截图、按钮/导航、证据与限制归档 | 本目录 | 待完成 |

此前自然期限、硬件故障、蓝牙、真实Push及完整权限并发等范围按冻结标准与实际条件保留。外部独立总验收与Owner最终接受另行记录。

## 最新RTC实机补充

| 项目 | 实际结果 | 来源与范围 |
|---|---|---|
| 后台历史快照累积 | 大批旧FutureProvider快照保留已切断，17项及4选择器通过。26c实际240.906秒观察0→4会话/事件对象，处于新来电时取末样 | rtc-memory-fixed-observation-private.json |
| 最终包内存短观察 | 0bad实际120秒，端点GC后65会话/120事件保持，堆140628224→140298784。中间仅读内存 | rtc-memory-final-0badb31c-observation-private.json，长时未完成 |
| 熄屏恢复 | 最终模拟器熄屏20秒，唤醒后既有对话读回与设置滚动通过，当前PID OOM0 | final-emulator-sleep-resume-private.json |
| 来电过期 | 原45需手动刷新。最终46自然30秒过期后自动未接通，接听拒绝撤去，无手动刷新 | incoming-expiry-final-phone-runtime-private.json |
| 正常拒绝 | 最终47手机正常拒绝，真实rejected及结果页 | 同上，未执行接听/音质复测 |
| 代码与复核 | 来电15项、analyze及限定非作者静态复核通过 | 该改动不扩大其它物理故障与长时结论 |

## 条件与未完成项

自然15/30天、硬件密钥库与物理故障、完整权限/并发/停媒/长通话及复杂AEC、蓝牙、真实Push、正式构建变体和部分条件叶页仍有NOT_RUN/UNKNOWN。媒体服务本轮再次出现monitor TimeoutError并恢复，根因UNKNOWN。算法独立准确性UNVERIFIED。管理写入依具名历史证据。顾问总验收和Owner最终接受PENDING。
