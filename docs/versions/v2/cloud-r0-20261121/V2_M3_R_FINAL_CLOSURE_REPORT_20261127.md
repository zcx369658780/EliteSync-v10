# EliteSync V2｜M3-R 最终收口报告

任务 `V2-M3-R-FINAL-CLOSURE-20261127`，2026-11-27，北京时间。M3-R **阶段性 PARTIAL**。源码、独立复核及定向回归已收口。实体 24 小时自然观察已启动，待自然到期。M3 顾问限定接受及 M1、M1-R 结论沿用。总体状态为 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。

## 工程与产物身份

| 范围 | 核验结果 |
| --- | --- |
| 开工工程 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，origin `git@github.com:zcx369658780/EliteSync-v10.git`。开工 HEAD 与远端均为 `6b514b5448d44e3215f265df6b8efcbcc250f3bd`，tree `b85c0c7b3ea3a6f13b576107c242ef9bab0c7962`。暂存区为空，13 个修改及 2 个新增文件为前轮 M3 成果 |
| 前轮实机源码归档 | `90eb1bfb590ad1358606e9d3c1b70be98559563f`，tree `43e0f4660feb3d8286748d8702a99192ee8b2b29`。归档前跟踪补丁、传输分类及原迁移 SHA-256 均与 M3 报告一致 |
| 最终产品源码 | `3d60440c85511ea58509b4e5878f64ed959dd7b4`，tree `45d36153d328bc2e64ef4e663cf40ed772ebb57f`。Flutter `lib` tree `137f452906d0e27bf56ff692056a2ae5f889880c`，Laravel tree `269383217a0f1852b0384766a64932e8db337389`。GitHub 已 fetch 回读 |
| 最终迁移 | `2026_11_27_060000_add_private_image_upload_id_to_media_assets.php`，blob `aaae37eabb40cd057cc95b92a846ba275db82799`，隔离运行副本 SHA-256 `1e494b1339e7db5468734073c3c46854b1fd963de077e0f5f20cb0b0ef7b17d6` |
| M3 已装实体 QA APK | `25060RK16C`，`com.elitesync.v2m3wlanqa / 1011807`，SHA-256 `817747b534a6ddbf24a7657a342ce03e929677db5fea67d8cc213400100e6223`。沿用前轮已装回执。本轮核对归档 APK 的 ARM64 `libapp.so` 与留存 AAR 字节相同，SHA-256 `500e44954b2034aed16968c1cb9aa7517445d0d92112685fe2644c801c8c6e89` |
| M3 实机包的构建差异 | 对照归档时的 Flutter 运行源码，QA 构建加入测试包名及版本、私网 TLS 信任、阻断外部服务的端点策略、离线诊断输出。诊断改动限于聊天页与私有缓存中的布尔检查及错误类型。M3 APK 证据对应 `90eb1bfb` 的产品修复与这些 QA 差异 |
| M3-R 新构建 | 从 `3d60440c` 提取构建输入，加入既有三处 QA 包名及端点配置。复用同一专用私网 TLS 入口与证书，证书 SHA-256 `75b3ffe1627fbe8a3fae0546be092c908b948c083593d5249dc49af648dcf018`。`com.elitesync.v2m3wlanqa / 1011807 / 10.1.18-v2-m3-wlan-qa`，ARM64，APK SHA-256 `24e5728f43dc76b5b8c213409de6672936080d9ff66fa52fd2b1c8b168dd4a30`，签名证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，与前包一致。APK 与 AAR 的 `libapp.so` 字节一致，SHA-256 `602f10b5ea95e8dd5965ea50653ef3ce01da6ebe17bad9c6222074fde0fb7fd4`。Owner 具名授权后原位更新 `25060RK16C`，已装 SHA-256 回读吻合。前后 Staging 1011814 SHA-256 均为 `37b9d370dda05f737cdd5e367d12267e3572220120edd6a27ec7710d8aec18d4` |
| M3-R 实际隔离服务 | `m3r-api-runtime` 容器 ID `b626e26cf62577eec6ca4ff26465bbfc04e557f76b675a50f90cde4b0461519e`，PHP 8.4.28，基础应用镜像 `sha256:36dca749623091744991a455f2efd511c5f9ae2133738d3df7904e6a5f304c1f`。在隔离容器中复制 `3d60440c` 对应应用与迁移并回读五个改动路径的 SHA-256。镜像 digest 对应基础层，运行源码由回读绑定 |
| M3-R 实际隔离数据库 | `m3r-db-runtime` 容器 ID `74e72895c36dabcd0651153f24d1c3383cba1dac811a0837b0845ba409d2d8d1`，MariaDB 10.11.19，`server_id=2621128`，镜像 `sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab`。独立合成库及独立媒体卷 |

GitHub 回读关键 Blob 如下。

| 文件 | Blob |
| --- | --- |
| `transport_error.dart` | `f11a3d2ab79f24ba9884636c1aa394a12b0d87f4` |
| `private_cache_service.dart` | `9ff992cebd34babe3c54adbc8b0b614a5cf27938` |
| `live_chat_page.dart` | `b2ede59e8587d326957165a8d1a80c350d605bfa` |
| `ConversationAtomicSendService.php` | `62eb3ad907bc5d452b95af49c5535331b10150e3` |
| `MediaAssetService.php` | `a0e79164ac08a17df5de1a5ce52769000afabc6f` |

[最终工程源码](https://github.com/zcx369658780/EliteSync-v10/commit/3d60440c85511ea58509b4e5878f64ed959dd7b4) · [前轮实机源码归档](https://github.com/zcx369658780/EliteSync-v10/commit/90eb1bfb590ad1358606e9d3c1b70be98559563f) · [M3 固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/6b514b5448d44e3215f265df6b8efcbcc250f3bd/docs/versions/v2/cloud-r0-20261121/V2_M3_COMMUNICATION_MEDIA_RELIABILITY_REPORT.md)

## 独立安全复核与修复

两位非作者 GPT-6.2 Astra/high 分别核对服务端及客户端。初审和一次复审均提出修正，最后一轮在各自范围内确认闭合。独立审查为源码检查，运行验证由本地 Codex 单列。

| 范围 | 修复与复核结论 |
| --- | --- |
| 上传与文件摘要 | 重试键绑定当前账号。隔离复测先复现落盘后事务失败、同键重试留下第二个文件。已改为账号和上传键派生的固定私有路径，临时文件经服务端 SHA-256 核验后转正，已转正对象只能按匹配字节恢复。外层事务回滚后同键重试得到一条资产、一次注册和一次处理。不发布有上传编号的私有快照。无编号旧客户端沿用原流程 |
| 上传状态 | 仅就绪、文件可见且摘要相符返回成功。处理中或私有存储暂不可见返回可重试错误并保留上传编号。逻辑删除、终态失败或摘要冲突拒绝。客户端在确定的终态拒绝后结束该选择 |
| 唯一索引与回滚 | MariaDB 加列及唯一索引走单条 DDL，已加列或已完整执行的状态可重入。10.11 使用原生可空 `UUID`。首次实际回滚失败，MariaDB 报 1553，复合索引接替了隐式外键索引。修复在同一条回滚 DDL 中按需补足外键索引。定向检验保留旧资产和处理记录 |
| 明确拒绝与传输 | 消息发送或已读确认收到明确拒绝即撤销本代读授权。识别传输中断后，先关闭图片、预览与写入，再等待安全存储核验文字。后台列表的迟到同代响应保持已获离线阅读。其他对端换代只撤销对应授权 |
| 时钟与代际 | 登录及在线恢复在进入本地串行持久化队列前捕获成对墙钟和单调计时。选图与重试沿用原会话代际，前台读取发现换代时清除旧选择。消息的可选 `expected_room_key` 在双方用户锁内校验。旧代待确认请求即使服务恢复也只能按服务器当前权限处理 |

固定路径可在同键重试时收敛。如果进程写入中断后既没有提交数据库也永远没有重试，私有存储中的待恢复文件没有业务读取入口。该情形的长期清理由后续专门的存储治理证据覆盖。

## 定向回归与出口

| 出口 | 状态 |
| --- | --- |
| `M3_FINAL_SOURCE_AND_ARTIFACT_IDENTITY_BOUND` | **PASS**，前轮实机包、最终工程和本轮装机候选各有固定身份 |
| `M3_FINAL_INDEPENDENT_SECURITY_REVIEW_PASS` | **PASS**，两位非作者对本轮修复作定向源码复查 |
| `M3_FINAL_CANDIDATE_TARGETED_REGRESSION_PASS` | **PASS**，Flutter、PHP、隔离 MariaDB/HTTP 和具名手机的发送故障窗口 |
| `M3_OFFLINE_LEASE_24H_PASS` | **RUNNING**，期内只读已核对，自然到期与重新授权待观察 |

- **Flutter 144/144，Dart 分析通过。** 覆盖确证拒绝后的离线拒读、选图遇换代、并行列表验证的双对端隔离、安全存储待决时关闭预览、登录排队计时和续用授权、发送重试与账号切换。原预览测试夹具因设备绑定不符拒绝读回，修正夹具后重跑通过。
- **PHP 45/45，567 断言。** 覆盖上传响应重放、处理写入失败后落盘恢复、对象消失和复现后的同键读回、处理状态、逻辑删除、同代消息与隐私回归。历史 409/200 修订保留在 `0ec0a19f128fff8b8681b66b05ae5df27fd5d5c7`。当前同值重放和陈旧异值冲突语义沿用。 [历史断言修订](https://github.com/zcx369658780/EliteSync-v10/commit/0ec0a19f128fff8b8681b66b05ae5df27fd5d5c7)
- **MariaDB／真实 HTTP 6/6，28 次有状态响应。** 覆盖空库迁移、历史空编号及外键关联、完整和中断后重入、消息体中断零写入后原键恢复、已提交后丢响应并按原键读回唯一消息、PNG 重传、并发 JPEG 幂等、撤权及换代后拒绝旧请求并保留原件。首次隔离服务端口不在本地业务允许列表内，停于前置检查，未产生 HTTP 写入。修复端口绑定并更正回滚 DDL 后重跑。
- **最终 APK 实体发送故障 2/2。** WLAN 上经专用 TLS 网关注入故障。中断窗口读取 8 字节，零上游请求、零初始写入。手机点击原编号重试后数据库一条、界面读回。响应丢失窗口上游 200、向手机转发零响应字节，点击原编号重试后消息 ID 和编号一致，仍一条。同 APK 在只读 AVD `emulator-5570` 安装、已装哈希与启动验证通过。模拟器未再跑手机的两种故障
- M3 前轮 Flutter 158/158、PHP 21/21、MariaDB／HTTP 4/4，以及多个具名 APK 上的真实 WLAN 回执保留原范围。本轮本机 TCP/HTTP 故障注入和模拟器记录单列。本轮实体发送故障使用 WLAN 上的专用入口，手机无线电保持开启。实体移动网络及最终 APK 重新执行图片选择和上传丢响应实测为 `NOT_RUN`，相应兼容性由本轮组件及 HTTP 覆盖。

原始回执留在 `v2-m3-local-20261126`。私有索引为 `m3r-flutter-final.private.log`、`m3r-local-http-e398a224.private.json`、`m3r-install.private.txt`、`m3r-handset-7c21efb6.private.json`、前序失败回执及候选构建记录。GitHub 交付包括脱敏报告、产品源码、迁移及必要测试。

## 实体 24 小时自然观察方案

当前状态 **RUNNING**。Owner 已就 `25060RK16C`、固定 APK `24e5728f…`、短测及以下观察方式具名授权。服务端在北京时间 **11 月 27 日 07:30:38** 签发并送达授权，**11 月 28 日 07:30:38** 到期。启动阶段已核对同一 QA 进程、虚构本代文字仍可读、图片预览不可见与发送不可用。专用入口已记录零上游转发。到期前后和恢复联网待采样。若观察未提前结束，入口预定在北京时间 **11 月 28 日 07:33:38** 恢复转发。进程及界面去敏检查记录在本机 `m3r-lease-observation.private.jsonl`。

1. 使用独立 QA 包、两个虚构账号与本机隔离服务。先复核 APK、QA 包与现装 Staging 的身份。服务端通过当前会话最新窗口签发一次授权，记录签发、到期、脱敏的账号与设备绑定、登录上下文、`room_key`、手机进程及起点。验证授权从签发起 86,400 秒。
2. 仅在固定 QA 私网入口暂停该测试流量的上游转发并记录计数。保留手机日常网络与其他 App 访问。该方式为 **QA 入口级隔离**。取得可识别的传输超时后读回本代文字和文字引用，核对图片、附件、通知正文及发送均关闭。
3. 始终以原签发时点为准，记录期间收到的服务端授权数量为零。保留同进程身份并记录到期前后界面和可信时钟检查。系统休眠、回收进程、重启、登录变化、新授权续发或时钟自检异常打断证据时，将该次标为 `PARTIAL` 或 `INVALID`。
4. 对比到期前可读与到期后旧正文拒绝。完成后恢复 QA 转发，核对重新联网后当前代际与新授权，另记冷启动和 30 天密文保留。真实时间、自动化 TTL 和短时网络断开各自记账。

## 顾问复审范围

请网页 GPT 顾问基于固定源码、此报告和前轮 M3 实机回执，复核上传恢复与迁移、授权收敛、候选身份及定向回归范围。实体自然到期仍在观察。历史公网 443 限定来源结果保持 FAIL、根因 UNKNOWN。真实移动网络、独立 Chrome 及双实体专项沿用待验。共享 Staging、共享私信、WSS、公开注册、生产 RTC 和 main 保持既有发布边界。本报告供 Owner 按现行工作流转交，顾问结论与 Owner 决策均待回执。
