# v10.1.5 消息权限矩阵登录输入停止与修正候选｜2026-11-08

**MATRIX_FIXTURE_LOGIN_422_STOP / SPENT_1_REMAINING_0 / THREE_SCENARIOS_NOT_RUN / CANDIDATE_STATIC_ONLY / G2_FALSE**

Owner当前“可以请继续”与同类普通本机工程委派下，新建任务`V1015_MSG_CONCURRENCY_20261108_02`，计划严格串行验证Block、CN关闭、管理员禁用peer三组真实GET/POST锁交接，以及提交后的旧键重放；禁用组另验证旧Bearer拒绝。该任务不是前次已完成双同键/MC撤权范围的重试或退款；全部旧claim/STOP保持封存。

## 改动与实际结果

[公开探针](../../tools/acceptance/v1015_messaging_concurrency/README.md)增加三组明确场景，固定源码`ac867637ea22aa02d7da549fdc2020fffddb7f3d`。复用精确独立会话锁等待观察、真实HTTP kernel和持久MariaDB；新增CN/MC revision、pair Block、disabled及令牌/活动会话捕获。非作者复核发现404旧键重放可能夹带成功消息身份而未被拒绝，已统一拒绝响应判据并加入负例。32项公开纯检查、2项私有held-ID纯检查通过，内存中反转Block判据会被检查拒绝；这类检查不是运行并发证据。

产品APP、鉴权与消息服务源码未修改；apps树`b673913a4ff0ff1a8bfc83ca98951ff1556a2f23`、services树`4530ae85754a2f3698d073182a47038708f2cb55`保持。沿用726文件只读服务快照和114包vendor，无新复制、下载、升级或许可接受。

实际新空库迁移93表、单事务4个虚构账号及三pair friendship、PHP8.4.27/Laravel13.39.0、API健康200与WS监听就绪。随后第一个`fixture-login-a`请求返回422，探针立即停止。尚未取得登录令牌，CN/MC构造及三组baseline/锁等待/权限变更/旧键/旧Bearer验证全部**NOT_RUN**。`backend_controller_exit=0`只表示控制程序完成收尾，`verified=false`，不表示场景通过；不归为产品并发或鉴权缺陷。

冻结私有driver为a/b生成`matrix`+actor，设备ID长度7；真实AuthController登录规则要求min8/max128，确认存在本轮新增输入缺陷。422具体校验响应body未留存，不宣称这是唯一运行原因。原driver、输入、claim与STOP未改；同节点保存非执行文本候选，将前缀改为`v1015matrix-`，四个ID长度13/13/17/17，3项静态检查通过。修正候选实际登录及三场景仍NOT_RUN，无后继scope/grant/claim，不自动重试或换目录续额。

## 限额、收尾与复核

独立一次范围保持合计2GiB、启动3072MiB、1800秒/共享45秒收尾、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及DB restart0，离线不下载。完整fresh核验只在既有入口执行一次，可用7002MiB、卷空闲354999029760字节为本次历史值，不供下次启动。后端claim后55.5秒，**已耗1、余0，无重试**。

自有WS/API/DB均停止、PID0、无OOM，退出0/137/0，cleanup_errors为空；API137不追加原因。新卷和网络保留。158个既有容器完整State事后与事前相同且均停止；现有共享引擎保留运行，本轮没有新引擎启动。无手机/ADB/SDK/AAR/APK/安装、云端、外部服务、真实数据、费用、Push或RTC操作。原dirty根255项状态及index保持，%SystemDrive%不动；保护ledger承接19805项，仅追加本节点原证与上一最终回执，不重扫旧SDK/AVD/Sources。

非作者Codex源码/输入复核及停止原证/候选复核分别记录，不是外部独立验收。当前产品图谱仍未索引，仅按具名模块/测试targeted定位。LOCAL_ONLY根名`v1015-messaging-permission-matrix-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`messaging-probe-failure-private.json`、`backend-session-outcome-private.json`、`corrected-login-input-candidate-private.json`及最终回执；私有配置、令牌、原始日志和SQL不上GitHub。

## 继续入口

修正候选已具体化；实际再运行需要Owner为该候选另授一次，不能把当前已耗余额复用。待授权后另作当前输入/资格和既定一次fresh检查，不恢复旧STOP、不自动启动现有引擎。其余已授权普通工程可继续。

前次双同键POST和MC撤权的实际通过证据保留，未在本次重测。完整AC03仍缺其余权限并发、旧JWT/room/media URL、跨账号迟到结果和设备缓存直接证据；本三场景尚未补齐。整版仍**10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**；媒体、离线15/30天、通知、合格RTC/AEC和同一最终候选集中验收未闭合。不合main/发布、不启v10.1.6。
