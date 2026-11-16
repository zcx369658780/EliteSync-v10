# v10.1.18 独立顾问验收报告

日期：2026-11-16（北京时间）  
结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`  
R1：`NOT_REQUIRED` · R2：`NOT_REQUIRED`

## 一、固定验收身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.18-ui-language-match-entry-consistency-20261116`
- 唯一父基线：`507ffcbf5a5f5abd3cac27b965388c9cb7155867`
- 固定任务文档提交：`06109b33e3a3a6129c09ba33bdecf271f49e661b`
- 产品源码提交：`1afa6940c37bc1b40aa3d05ea46fb47002f6455c`
- 集中交付payload提交：`f404a7e9ad49331bb331f9460b09a98b9e183252`
- 最终固定交付/停止点：`0442335733555b38970131af7d5327a84e3dcb33`
- 候选：`10.1.18-dev / 1011804`
- applicationId：`com.elitesync.v1018dev`
- APK：124,067,297 bytes
- APK SHA256：`eaacc050f7e6fae7bc980c6a766bf1a08ba1cb723bdad6571c821a72e552ba5a`
- 签名证书 SHA256：`7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42`
- Build：`source-debug-arm64`

GitHub分支HEAD与最终固定交付提交一致。最终提交`04423357`是payload提交`f404a7e9`的直接子提交。相对唯一父基线，分支9 commits ahead、0 behind。payload同源远端回读回执记录89个文件Blob与SHA256核对通过；本轮再次读取了最终分支HEAD、报告、manifest、证据摘要、回执及14张截图。

## 二、总体结论

`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

v10.1.18八项AC均按各自具名工程范围通过顾问验收。本轮没有发现需要阻断接受的确定性P1/P2产品缺陷，不需要R1或R2。

本版完成Owner提出的四项UI收口：
1. 用户可见文案由开发式/程序式表达改为自然产品语言；
2. 一级第二入口由「进展」改为「匹配」，旧路由继续兼容；
3. 统一按钮和探索选项的默认、按下、选中、禁用、焦点及危险状态样式；
4. 自动化入口在「匹配」和「我的」可发现，但统一进入B2唯一规范控制页面。

同时完成说明归位、Buddy独立诊断，以及同一安装内账号切换、进程强制停止、冷启动、断网恢复和私有数据隔离验证。

## 三、八项AC最终评估

| AC | 顾问结论 | 复核依据 |
|---|---|---|
| AC18-01 历史状态与Owner反馈对齐 | ACCEPTED_IN_NAMED_SCOPE | v10.1.17原固定交付、后续顾问接受、Owner有限反馈及Owner整体PENDING的时间线分开保留；第8项仅保留“新账号未显示旧账号消息”观察 |
| AC18-02 用户可见文案收口 | ACCEPTED_IN_NAMED_SCOPE | 文案映射表覆盖Home、Match、Lifestyle、Automation、Messages、Me、Buddy和通知；未知状态保留未知，不把未知转成成功/失败 |
| AC18-03 进展→匹配 | ACCEPTED_IN_NAMED_SCOPE | 四底栏数量/顺序不变，第二入口与页面标题显示「匹配」；`/progress`、嵌套路由、通知回流和历史别名继续可达 |
| AC18-04 统一状态色 | ACCEPTED_IN_NAMED_SCOPE | 共享Theme token、浅/深主题、1x/2x字体、键盘焦点、语义及对比度测试；14张截图中复核探索选中态文字清晰 |
| AC18-05 自动化入口可发现性 | ACCEPTED_IN_NAMED_SCOPE | Match与Me入口均进入同一个`/user-state`控制页面；默认OFF、明确授权及B2授权生命周期未改变 |
| AC18-06 说明/免责声明归位 | ACCEPTED_IN_NAMED_SCOPE | 一般说明集中到Me→权限与说明；首次匹配确认复用服务端版本/profile hash，取消和确认期间切号不写入 |
| AC18-07 Buddy独立诊断 | ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS | 隔离MariaDB/HTTP与最终APP中，默认吃饭条件为空，切换学习后发现已发布活动并明确申请；Owner原手机问题确切原因继续UNKNOWN |
| AC18-08 冷启动/账号隔离 | ACCEPTED_IN_NAMED_SCOPE | 同一安装A→logout→B→force-stop→cold-start B→网络中断/恢复→logout→A；PID变化、token主体、HTTP主体、缓存命名空间、消息/通知及草稿结果互证 |

## 四、重点独立复核

### 4.1 匹配入口和业务边界

最终源码`JourneyOverviewPage`读取B2`/user-state`，验证`contract_version`和`subject_user_id`，未知action不推断替代操作。匹配页展示轮次、提案、连接、消息许可、会话和正式关系，但没有合并业务状态。

Match、Connection、Messaging Consent、Conversation、Relationship仍然独立。接受匹配不自动建立消息许可、分享资料或确立正式关系。旧`/progress`路由及通知回流继续使用原路由合同。

### 4.2 按钮状态色与可读性

`app_component_theme.dart`统一Filled、Outlined、Text及选项状态。Lifestyle选中态使用primaryContainer/onPrimaryContainer配对，保留勾选和边界。报告记录的最低文字对比度为浅色5.344:1、深色5.737:1；控件边界最低浅色4.841:1、深色4.308:1，达到本版合同门限。

定向颜色计算和Widget测试覆盖默认、按下、选中、焦点、禁用及组合状态；系统级TalkBack没有运行，不能由Widget语义测试替代。

### 4.3 自动化入口与说明

Match与Me提供自动化入口，实际都进入B2唯一`UserStatePage`，没有第二套状态或开关。自动化默认关闭，必须明确授权。暂停/撤销仍遵循B2授权范围。

一般说明移至Me→权限与说明；首次匹配资料确认复用已有服务端版本和profile hash。取消确认及确认期间切换账号均未产生写入。隐私分享、匹配接受、消息同意、Connection、Relationship及退出等明确决定仍保留在对应操作上下文。

### 4.4 Buddy诊断

Buddy与恋爱匹配使用独立服务合同。本轮隔离验证证明：
- 未开启Buddy许可时，发现接口返回403；
- 活动未明确发布时，发现列表为空；
- 发布学习活动后，学习筛选可发现该活动；
- 虚构申请者明确申请后进入REQUESTED，等待活动创建人回应；
- 没有因此建立恋爱匹配、Connection或消息许可。

这说明Buddy发现受许可、活动状态、发布和类型筛选影响。本轮没有证据支持改写Buddy算法或候选策略。Owner此前手机上“可进入但无法匹配”的确切原因仍为UNKNOWN，不得将本轮受控场景成功等同于已经解释Owner原故障。

### 4.5 冷启动与账号隔离

同一模拟器安装、同一applicationId完成A/B切换。强制停止前PID为3314，冷启动后PID为8437，停止PID缺失断言通过。

- A的`/user-state`主体为1，消息列表有权读取1个会话，通知为4条；
- B的`/user-state`主体为2，消息/会话访问返回404，通知仅返回B自己的1条Buddy提醒；
- B尝试读取A的显式user_id被API拒绝；
- A/B native token指纹集合不相交；
- 本机私有缓存namespace分别绑定账号1与账号2；
- A登出时加密聊天草稿按既有合同清理；B的参与草稿在冷启动后恢复；
- 断网时B没有显示A的消息或会话；联网恢复后重新读取B状态；
- 切回A后A有权会话恢复，B的草稿未显示。

因此AC18-08在上述具名模拟器、隔离MariaDB和真实HTTP范围内接受。它不等于所有Android设备、系统备份恢复、第三方键盘或所有外部深链均已验证。

## 五、工程验证证据

交付证据摘要记录：
- Shared Theme与Lifestyle：13项；
- Matching/Me/Automation文案：39项；
- 首次引导与路由：25项；
- 默认路由兼容：29项；
- Buddy Widget：12项；
- Notification/Message/Private Cache：122项跨受影响重跑；
- PHP Buddy与B2：34项、438断言；
- 隔离MariaDB/真实HTTP：16项；
- 受影响Dart产品文件分析：21个；
- 实际APP代表步骤：31项；
- 去敏模拟器截图：14张，已逐张视觉复核。

通知/消息/缓存联合验证的计数口径保留：联合集119项通过、3项旧文案断言失败；更新为匹配本版文案的断言后，通知40项通过。旧失败日志保留，不将其改写为从未发生。

本顾问直接复核了GitHub固定源码、任务和报告文档、manifest、结构化证据摘要、Buddy诊断、16项API/MariaDB回执、冷启动/隔离回执及14张截图。Owner本机私有原始日志未在本会话直接打开，全部测试也未由顾问在本会话重新执行。因此工程测试结论按已提交的具名证据接受，不表述为顾问重新运行测试。

## 六、非阻断观察与限制

### 非阻断开发包表现
14张模拟器截图右上角可见红色`DEBUG`斜标。源码中`debugShowCheckedModeBanner`由`env.isDev`控制，本候选为`source-debug-arm64`开发包。这是开发环境标记，不代表正式产品页面内容，也不构成当前具名工程验收阻断；但若Owner希望下一次手机评测画面更接近正式产品，可在后续候选中关闭该标记，同时保留必要调试能力。

### 继续保留的未知/未执行项
- Owner原手机Buddy失败确切原因：UNKNOWN；
- Owner手机复验：NOT_RUN / 由Owner决定；
- 系统级TalkBack：NOT_RUN；
- 真实Push：NOT_RUN；
- B1图像模型精确名称与版本：UNKNOWN；
- v10.1.16首次数据库探测逐表摘要和历史status变化原因：UNKNOWN；
- v10.1.17 Owner整体接受：PENDING；
- v10.1.18 Owner整体接受：PENDING；
- main集成、正式发布、真实运营：NOT_RUN；
- B4及阶段C：未授权。

## 七、最终决定

`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

- AC18-01至AC18-08：按具名范围接受；
- R1：NOT_REQUIRED；
- R2：NOT_REQUIRED；
- Owner整体接受：PENDING；
- Owner手机复验：由Owner决定；
- main集成/正式发布：NOT_RUN；
- B4/阶段C：未授权。

本报告不替代Owner整体接受，不授权B4、阶段C、main集成、正式发布或真实运营。
