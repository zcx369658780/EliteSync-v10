# EliteSync v10.1.5 R1 补充验收结论

日期：2026-11-13（北京时间）  
固定材料提交：c86d0de92baf00c5bcc61addf762dd8608f6eb1d  
结论：**已完成修复与限定证据予以分项接受；整体仍为 CHANGES_REQUIRED / PARTIAL。下一轮只处理剩余 SFU 问题及资料校正。**

本结论对应Owner要求的R1复核，不重新迁移工作流，不恢复旧冻结执行器或逐动作顾问审批，不启动v10.1.6。

## 1. 候选与审阅范围

| 对象 | 核对结果 |
|---|---|
| 当前授权分支 | codex/v10.1.5-software-continuation-20261101 |
| 远端分支HEAD与保存提交 | c86d0de92baf00c5bcc61addf762dd8608f6eb1d，远端读取一致 |
| APP源码 | cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d |
| APP源码Root Tree | e80b50c4cd00af50cdb3972cd2e129e3cf3ce378 |
| apps Tree | ce9a68ba47807e496764d80980593958b094b2ba |
| services Tree | 72edf681992d8f80910addb5858bd15a5bb7bca3 |
| 后端核心 / 开发工具 | 6549f02880968f99ae3f45439d15a37c1b3d5251 / e7b21c7fdb0991a5fbd5a9272c92c2331c0dec2d |
| APK | EliteSync-v10.1.5-dev-cfdce773-arm64-debug.apk；154580169字节 |
| APK SHA256 | 311632a8c735b53d97984dc9b45f00c1d7cdc6e72f848807cb40d99f62d7fc69 |
| 交付变体 | restorationLocalBuild=true；com.elitesync.v1015dev；10.1.5-dev / 1010501；arm64 Debug |

cfd至c86只有20个资料文件变更；两个提交的apps/services Tree相同。16个工程文件的变化已经审阅。APK安装一致性、签名和构建结果依据具名工程回执，本次没有取得APK二进制或操作Owner本机重新验证。[材料入口][readme]；[manifest][manifest]；[源码提交][source]；[保存提交][saved]。

本轮实际完成：

- 阅读20/20份去敏结果摘要、当前完成度表、适用性表、历史关键摘要与manifest。
- 检查16个工程变更文件及相应测试源码，重点覆盖资格会话/迟到响应、连接契约及SFU服务工具。
- 获取并查看6张补图原图；逐张SHA256和字节数与SCREENSHOTS.json一致，均为720×1280且可解码。
- 核对上一轮顾问报告与任务单的远端副本：分别21692、13900字节，与原交付文件逐字节一致。
- 复算当前证据摘要原始字节的SHA256与Git Blob，发现一处manifest引用陈旧，见第4节。

这是只读材料、源码和截图复核，没有在本轮运行APP、模拟器、开发服务或产品测试，也没有把私有回执hash当成独立运行证明。没有对原120张截图、全部历史代码或完整权限矩阵重做审阅。

## 2. R1各项裁决

| R1项 | 本轮结论 | 保留边界 |
|---|---|---|
| R1-01：公共工作池隔离 | 接受具名子问题修复 | 公共PHP池暂停时SFU持续运行、重启增量0；两池仍共享资源和数据库 |
| R1-01：内存有限观察 | 接受本轮有界观察 | 25分钟窗口未复现旧快照失控累积，不扩大为永久无泄漏 |
| R1-01：故障收尾与恢复 | 接受具名故障恢复链 | call53故障注入、call54恢复后正常通话，不替代非注入故障归因 |
| R1-01：非注入超时根因 | **未关闭** | 独立池部署后仍有共同PHP延迟，具体阻塞来源UNKNOWN |
| R1-02：关键权限与证据继承 | 接受限定补充范围 | 当前撤权、未知POST和旧通知已补；不宣称全组合权限矩阵通过 |
| R1-03：具体缺陷与已有主要交互 | 接受具名修复与已记录的软件链 | 受控资格响应、API对端、TEST_ONLY提案及真实身份未接入的边界保留 |
| R1-04：历史身份与构建变体 | 原ba/5e错挂已修复，变体说明可接受 | 另一套正式构建页面仍不是本次交付实测对象 |
| R1-05：集中交付 | 结构与主要内容已形成，需小幅资料校正 | manifest摘要hash必须修正；AC04证据归类及数值可复算字段可从原证补齐 |

完整版本结论继续为CHANGES_REQUIRED/PARTIAL。以上“接受”是顾问对具名修复或证据范围的判断，不代表Owner最终产品接受、合main或发布批准。[完成度表][completion]；[证据适用性][applicability]。

## 3. 可以关闭的修复与证据

### 3.1 资格提交、MBTI、引导及连接

**资格提交：** 新实现明确区分confirmed、failed、unconfirmed、obsolete，页面只在成功确认且路由/账号/登录会话仍相同时退出。提交失败保留输入；POST成功但GET失败时保留确认标记，后续只GET，不重复POST。同一认证下的资料更新或provider重建保留回执，切号或认证意图改变则隔离迟到响应。受控运行记录为POST共2、状态GET共3，供应商调用和资格库写入均0，截图支持失败留页和输入保留。可以关闭原错误分支问题，不外推为真实身份认证通过。[资格provider][verification-provider]；[资格页面][verification-page]；[摘要][evidence]。

**MBTI：** 已配对选中态前景与背景，明暗主题原图均能读到完整选项。截图呈现最终A/A/A状态；A→B→A属于重选操作序列，来自具名过程记录与测试，不能把静态图说成过程回放。本轮服务端测评提交0。原文字消失问题关闭。[补图索引][screenshots]；[MBTI源码][mbti]。

**引导：** 文案已改为从“进展”查看慢约进度。首次自动引导证据属于e7候选，后续相关实现不变，可以继承，不能改标为cfd实测。

**连接：** 当前proposal envelope与peer_id读取已修复；proposal键存在时不回退旧partner；正常无匹配与请求失败分开，空态不再显示Bad state。终态允许显式重新请求CN/MC，并保留对象和版本校验、写后GET及会话切换防迟到。当前开发链补到了CN_ACTIVE、MC_ACTIVE与消息124持久读回。对端部分操作由API完成，提案为明确TEST_ONLY夹具，没有运行匹配算法，也不是双端自然匹配全流程。[连接源码][connection]；[连接测试][connection-test]；[入口说明][readme]。

16个工程文件定点复核未发现新的确定工程缺陷；新增测试对准原问题，未见通过自动同意、放宽guard或自动重放提交取得结果的做法。测试执行结果采用Codex的具名回执，本轮没有重新执行测试。

### 3.2 当前撤权、未知POST与通知

call51绑定cfd及当前APK。摘要给出COMMIT可见区间宽0.016秒，双端CAMERA/RECORD_AUDIO停止的保守上界2.187250秒，低于5秒目标；Room0，未过期旧JWT在撤权和新代次后均403，旧房间不复活。媒体17/18双方撤权前full200/Range206，撤权后均404。身份和结果之间没有发现矛盾，接受其具名工程证据范围。[当前证据摘要][evidence]。

**数值边界：** 当前去敏摘要给出了计算后的上界，未展开monotonic端点和完整尾窗范围。本轮没有独立复算2.187250秒。为方便最终复核，可从已有私有回执提取提交区间、停采集样本上界、时钟余量及尾窗范围，无需重新进行实验。

消息125已有未知ACK后离线冷启隐藏、在线原UUID显式重试、单行密文与单副作用、自动POST0；旧通知259点击时撤权，路由参数与payload清空，read POST0，维持未读和通知中心。这些已把上一轮关键补证落到当前候选。

历史609的4.874250秒是COMMIT基准，4.953250秒是请求基准；新历史摘要已解释口径差异，两者没有构成相互矛盾，不追加历史重测。[历史摘要][historical]。

### 3.3 25分钟观察与故障恢复

| 指标 | 本轮记录 |
|---|---|
| 采样窗口 / 工具耗时 | 1500.031秒 / 1500.906秒 |
| 采样 / 进程 | 30秒间隔、51点、同一PID5915 |
| Dart heap | 120759792→126337216字节；峰142433968字节 |
| PSS | 757743→734208KiB；区间678666—757743KiB |
| 最终保留RTC对象 | 13个会话、15个事件 |
| ANR/OOM/fatal标记 | 0 |

显式GC仅在首尾，期间覆盖后台轮询、页面进退、来电过期/拒绝、熄屏和恢复。heap净增约5.32MiB、PSS下降约22.98MiB，结合期间生成的会话/事件，未见旧94份快照的失控累积。它满足R1提出的有限观察要求；若下一轮仅改后端且不影响客户端相关依赖，不再重复该25分钟观察。[摘要][evidence]；[R1结果][readme]。

call53的权威池暂停请求为1.8秒，操作窗口保守上界3.110秒，记录1003ms超时；SFU有限重启、双端采集停止、Room0，恢复后旧JWT及新代次中的旧JWT均被拒。随后call54双参与者与双端采集成立，通话261秒，正常UI挂断后Room0和双端停止。这条恢复链接受其范围。

模拟器为headless/no-audio，本轮不证明物理音质或AEC；原Owner听感继续保留原候选身份。

### 3.4 普通功能与身份材料

注册/登录/改密/退出有15次虚构开发API检查；首次自动引导有隔离Android user观察；管理旧表单有审核持久读回和stale revision409。好友、搭子、社区及正式关系pending/确认拒绝/撤回补了37次实际开发HTTP检查；本地反馈补了生成、修改失效、原生剪贴板Paste及返回。

这些是各具名链的补充，不等于所有入口均由APP实际点击。真实身份未配置，正式关系ACTIVE及资料共享继续区分受控软件证据和真实Provider条件；占位作者页、非持久“稍后查看”和另一构建变体已有明确说明，不扩成R2新功能。

历史ba/5e的源码—APK错挂已按原回执校正，并保留原值及修订理由；上一轮这一问题关闭。[完成度表][completion]；[manifest][manifest]。

## 4. 仍需完成的事项

### 4.1 唯一工程主项：非注入SFU超时归因

独立池部署后，**2026-11-13 08:06:45.631北京时间（原回执00:06:45.631 UTC）**仍出现一次authority_sweep / TimeoutError / 1079ms。相邻公共与内部PHP日志均有约6秒Accepted→Closing延迟。现有证据只能定位到权威查询依赖及共同延迟，尚未确定是排队、Laravel/DB、锁、共享CPU/容器调度或响应完成迟延。

源码中的http()没有connect、drain、read的分别计时或安全请求关联号；monitor输出的elapsed_ms是一次reconcile循环的总时间。当前日志不足以进一步区分上述原因。测试中模拟TimeoutError可以验证诊断字段与停服行为，不能证明真实超时的根因。[gateway源码][gateway]；[开发服务工具][dev-server]；[摘要非注入事件][evidence]。

下一轮应围绕这一事件补最小关联诊断，定位可行动原因，再修复或实施有证据支持的环境缓解。不能直接把约6秒共同延迟判成数据库锁，也不能因后续短时未复发便把UNKNOWN改成已修复。当前1秒响应期限和3.5秒watchdog是诊断基准；若证据要求调整内部参数，应说明最坏时序影响，并定向证明既定5秒停媒目标、独立监控及原鉴权约束未变弱，不以无限重启或仅延长阈值代替处理。

### 4.2 一处必须校正的资料hash

manifest.evidence[0]引用EVIDENCE_SUMMARY.json的SHA256与固定c86原文件不符：

| 项目 | 值 |
|---|---|
| manifest登记值 | 1a73117957ce8d531dee461817e06ebb02d2c7a654f5e24dca2d96477932500c |
| 固定c86实际SHA256 | 54fac6656ac970c7e946972695b15a59344cb43cdad19ef68d4703f3efeb7aab |
| 实际字节数 | 33566 |
| 实际Git Blob SHA1 | 2a90eda226b8dc51fd339654a6fd0748b694009a，与GitHub返回一致 |

该结果由原字节复算并交叉核对，属于陈旧清单引用，不是传输换行差异，不据此推断运行回执失真。修正时以最终保存文件重算；若同时补充摘要字段，上述54fac…只是旧c86文件的hash，不能照抄为新文件值。[manifest][manifest]；[摘要原文件][evidence]。

同时将完成度表AC04的主要证据从call54 RTC恢复改为当前call51资产17/18的200/206→404，加原26c图片/视频上传播放继承；call54归AC05。这是证据归类修正，不增加媒体实验。

## 5. 下一步与停止条件

已出具R2定向补充任务：工程仅剩非注入SFU超时诊断及必要修复；资料只做上述hash、证据归类和既有测量数值补齐。R1已接受的软件、截图和有限观察结果继续有效，只有具体改动影响到它们时才补相应验证。

真实Push、自然15/30天、蓝牙/硬件/物理AEC、真实身份、独立盘面精度及未穷尽的完整并发组合保留具名限制。本轮不把它们自动转换成全量必做项。历史G2 false与当前实际成功构建分别记录，旧执行链不恢复。

若非注入故障的触发链已得到可复核解释，必要修复/缓解及受影响验证完成，资料准确，可提交补充范围完成，停下给Owner/顾问复核与讨论。若在有界诊断后仍无法归因，应明确已排除和未确认环节、影响及下一步，不自行标为外部限制或PASS。

目前仍未达到整版任务全部完成的条件，因此本次不规划下一版本、不合main、不发布。普通工程沿本地长期授权继续，后续设备验证使用既有双模拟器，不占用Owner手机。[当前入口][active]；[工程约定][agents]。

[readme]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/README.md
[manifest]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/artifact_manifest.json
[source]: https://github.com/zcx369658780/EliteSync-v10/commit/cfdce773d94e75af13fcc12d17f56a9cf9ab1f8d
[saved]: https://github.com/zcx369658780/EliteSync-v10/commit/c86d0de92baf00c5bcc61addf762dd8608f6eb1d
[completion]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/COMPLETENESS_AC.md
[applicability]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/EVIDENCE_APPLICABILITY.md
[evidence]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/EVIDENCE_SUMMARY.json
[historical]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/HISTORICAL_EVIDENCE.md
[screenshots]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/versions/v10.1.5/supplement-r1-20261112/SCREENSHOTS.json
[verification-provider]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/apps/flutter_elitesync_module/lib/features/verification/presentation/providers/verification_provider.dart
[verification-page]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/apps/flutter_elitesync_module/lib/features/verification/presentation/pages/verification_submit_page.dart
[mbti]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart
[connection]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/apps/flutter_elitesync_module/lib/features/connection/presentation/pages/live_connection_page.dart
[connection-test]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/apps/flutter_elitesync_module/test/features/connection/live_connection_page_test.dart
[gateway]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/services/backend-laravel/tools/rtc/rtc_gateway.py
[dev-server]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/services/backend-laravel/tools/rtc/serve_development_api.py
[active]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/docs/workflow/ACTIVE_STATE.md
[agents]: https://github.com/zcx369658780/EliteSync-v10/blob/c86d0de92baf00c5bcc61addf762dd8608f6eb1d/AGENTS.md
