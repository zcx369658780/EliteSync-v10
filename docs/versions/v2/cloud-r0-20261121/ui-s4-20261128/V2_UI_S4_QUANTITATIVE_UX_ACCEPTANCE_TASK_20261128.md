# EliteSync V2｜UI-S4 全 APP 量化验收任务单

**任务编号：** `V2-UI-S4-QUANTITATIVE-UX-ACCEPTANCE-20261128`  
**任务状态：** `TASK_ISSUED / CODEX_ACK_PENDING / UI_S4_NOT_STARTED`  
**执行负责人：** 现有本地 Codex 会话  
**顾问：** 网页 GPT  
**最终决策：** Owner

## 0. Owner 最新决定与任务目标

Owner 已接受 UI-S3-R 的阶段性交付及顾问复审建议，认为当前版本整体很好，并同意启动 UI-S4 全 APP 量化验收。

当前目标是完善 EliteSync 基础功能和使用体验，形成 Owner 可亲自体验、并可与同事讨论的完整开发候选。当前不讨论首测、公司注册、软著、备案、公开内测、商业运营或生产发布。

本轮不做大规模 UI 重设计。首先修复首页频道选中态对比度 FAIL，然后以一个固定 Android QA APK 对 U01–U12、文案、无障碍、性能和既有功能进行同口径验收。

UI-S4 是产品体验验收，不是发布准入验收。

## 1. 固定工程与证据基线

- 仓库：`zcx369658780/EliteSync-v10`
- 工程目录：`D:/EliteSync/development/v2-cloud-r0-20261121`
- 开发分支：`codex/v2-function-completion-20261121`
- 当前 GitHub 交付 HEAD：`b999bcb6cef2d2fe339b761b7054e36dadeeb524`
- 当前 Git tree：`f29cbfb46b214f441c73c3fc8eb8e4da0fd129e0`
- UI-S0 原始基线：`2310d0aa7ac5a9e03273952d13539bdd212ca0fd`
- UI-S3 源码：`0f051a4eb367e3978c57d8f5b4c945a0440d3184`
- UI-S3-R 源码：`d8bec8bd856a281ecf2160c4e9dfe1801f22031b`
- UI-S3-R 交付：`b999bcb6cef2d2fe339b761b7054e36dadeeb524`
- UI-S3-R tree：`f29cbfb46b214f441c73c3fc8eb8e4da0fd129e0`

UI-S3-R 原 QA APK：
- 包名：`com.elitesync.v2uis3rqa`
- versionCode：`1011817`
- SHA-256：`ac5f64efdd90ac3db229cf5b23b04861133934756308f061512313a3abb0f77b`

开工先在本地核对实际 Git 根、origin、分支、HEAD、工作区、暂存区和未提交成果；不要假设本机 HEAD 必然等于上述 GitHub 交付。保护原脏 `main`、历史 APK、UI-S0 原始成本矩阵、150 张 UI-S0 截图及 UI-S3-R 原始截图证据。

首读：
1. `AGENTS.md`
2. `docs/workflow/ACTIVE_STATE.md` 顶部当前条目
3. `docs/workflow/CURRENT_WORKFLOW.md` 顶部当前条目
4. 本任务单
5. UI-S0、UI-S3-R 报告及下列矩阵

具名材料：
- `docs/versions/v2/cloud-r0-20261121/ui-s0-20261127/V2_UI_S0_INTERACTION_AND_COPY_AUDIT_REPORT.md`
- `docs/versions/v2/cloud-r0-20261121/ui-s0-20261127/INTERACTION_COST_MATRIX.csv`
- `docs/versions/v2/cloud-r0-20261121/ui-s0-20261127/USER_VISIBLE_COPY_INVENTORY.csv`
- `docs/versions/v2/cloud-r0-20261121/ui-s3-r-20261128/V2_UI_S3_R_VISUAL_AND_INTERACTION_REFINEMENT_REPORT.md`
- `UI_S3_R_FINAL_SCREEN_COVERAGE.csv`
- `UI_S3_R_FULL_COPY_DISPOSITION_MATRIX.csv`
- `UI_S3_R_ACCESSIBILITY_MATRIX.csv`
- `UI_S3_R_FEATURE_REGRESSION_MATRIX.csv`
- `UI_S3_R_INTERACTION_SMOKE_MATRIX.csv`
- UI-S1/UI-S2 最终设计合同和背景资产清单

## 2. S4-01｜首页频道对比度修复（第一项）

**优先级：P0。**

UI-S3-R 已测得首页频道选中态文字对比度为 **3.57:1**，低于普通正文目标 **4.5:1**。已知选中背景 RGB 为 (78,105,111)，前景为黑色。

要求：
- 优先修复选中态前景语义色，保留已接受的深青色选中背景和整体首页构图。
- 检查「精选」「好友」选中及未选中状态。
- 检查浅色、深色模式和字体缩放。
- 不通过改变整个首页配色回避单个控件问题。

验收：
- 普通正文至少 4.5:1。
- 大字号粗体按适用对比度要求核验。
- 关键非文字控件至少 3:1。
- 使用最终 Android 实拍像素按 WCAG sRGB 公式测量，不以 Token 理论值代替实测。

出口：`UI_S4_01_HOME_CONTRAST_PASS`。

## 3. S4-02｜固定唯一最终 Android QA 候选

S4-01 修复后固定源码，再构建唯一 UI-S4 QA APK。

- 建议独立包名：`com.elitesync.v2uis4qa`
- versionCode：由 Codex 选择未使用的新编号并核对唯一性
- 两台隔离 Android 模拟器安装
- 记录源码 SHA、Git tree、APK 包名、versionCode、APK SHA-256、签名证书 SHA-256、Flutter/Dart、Gradle、PHP、MariaDB、后端源码和三盘引擎身份
- 两台模拟器已安装 base APK 的 SHA-256 必须与构建产物一致

后续 U01–U12、24 页面、无障碍和功能回归必须使用该固定候选。若产品源码再变化，必须重建并重核身份，不得沿用旧 APK 证据。

构建优先复用本机缓存。先核对 Gradle Wrapper 与依赖路径，避免意外下载新的 Gradle distribution。只使用隔离本地 Laravel/MariaDB、虚构数据和模拟器。

## 4. S4-03｜U01–U12 全流程同口径量化

以 UI-S0 原始任务定义为基准。每项记录起点、终点、账号状态、权限、初始数据、完成条件及：
- C：点击
- S：连续滑动/拖动手势
- I：独立输入字段、重复输入
- N：页面/弹窗/抽屉导航变化
- W：真实等待时间，剔除探针和自动化开销
- B：系统返回、页面返回和主动返回

导航不得重复计入点击；键盘逐字符输入不计为点击。首次使用、日常重复访问和失败恢复分别记账。只有起点、终点、权限和用户目标一致才计算前后降幅。

### U01｜首次打开、注册及首页
UI-S0 原首次使用基线为 20C，含普通注册、五场景、引导至首页及一次答案回改。但 R04-A 已禁止在协议正文和版本不可核实时进行普通注册。

- 普通注册保持 `BLOCKED_BY_ACCEPTED_REGISTRATION_GATE`。
- 不绕过协议门禁，不伪造协议同意，不通过直接 API 写入普通账号。
- 使用具名 TEST_ONLY 账号测量登录至首页，单列为 `U01-T`。
- U01-T 不与原普通注册 20C 直接计算降幅。

### U02｜Lifestyle 与必要问卷
分别测量五场景、20道必要问卷、一次回改、中断恢复及完成后的下一步导航。保留全部必要题目，不预置答案、不减少问题。UI-S3-R 参考值：五场景 7C/0S；20题答题 20C/0S，必须在 UI-S4 固定候选复测。

### U03｜个人资料与展示资料
测量基础资料查看修改、私人/展示资料分离、展示草稿保存、单字段修改、显式清除、重入、冷启动、失败重试和账号切换。保存反馈必须与服务端持久化一致。

### U04｜出生资料及首次三盘生成
通过实际 APP 输入出生日期、时间、地点，核对坐标精度和时区，提交真实后端计算并查看三盘。不得调用未经授权的真实百度 API；不得重复输入已保存且经用户明确选择复用的资料。

### U05｜三盘查看、切换、扩展与历史
分别测量三盘概览、完整三盘浏览、扩展、历史版本、旧版只读、出生资料修改、结果过期和重新计算。UI-S3-R 的 3C/0S 只代表三盘概览，不能替代完整 U05；UI-S0 的 27S 包含扩展与历史，必须重跑同终点完整任务。

### U06｜社区浏览、点赞、回复
覆盖好友动态、长列表、作品详情、点赞/取消、评论/回复、返回原位置、分页/刷新及冷启动。必须补齐社区长列表滚动位置恢复。使用具名合成作品，不公开测试正文。

### U07｜发布作品
覆盖发布入口、标题正文、合成图片、受众选择、发布、回看、修改受众和撤下。必要隐私确认单独计量。

### U08｜消息与附件
覆盖消息列表、合法会话、文字、图片选择上传与发送、明确拒绝、丢回执原编号核对、同编号异载荷冲突、冷启动、对端读图、撤权拒绝和账号切换。Connection、Messaging Consent、附件权限、Block 各自独立。

### U09｜匹配准备与关系旅程
使用具名 TEST_ONLY 合成账号及合法发布快照，覆盖资料准备、缺失项定位、候选正文、双方独立决定、Connection、独立 Messaging Consent 和关系进度。不把合成资格转为真实身份核验，不自动接受候选或开启聊天。

### U10｜Buddy
覆盖活动发现、详情、创建、申请、接受/拒绝、取消/撤回、本人活动和切号。Buddy 与恋爱匹配、私信授权独立。

### U11｜隐私与设置
覆盖个人中心、隐私用途、展示授权、对象级数据权利入口、Block、通知偏好、安全设置和账号设备入口。真实对象删除渠道继续按 D4-A 不可用。

### U12｜退出与重新登录
从首页进入我的、找到退出、独立确认、返回登录页、TEST_ONLY 重登、资料和三盘读回、跨账号隔离。保留必要退出确认。

## 5. S4-04｜1230条可见文案最终核验

UI-S0 原始文案清单共 1230 条。UI-S3-R 处置为：
- KEEP 722
- REWRITE 60
- MOVE_TO_DETAILS 10
- UNVERIFIED 438

本轮对原始 1230 条逐条完成最终核验/处置，不要求盲目重写全部。特别对438条 UNVERIFIED 逐条对照最终 APK、Android 实际可见文字、无障碍语义树、源码和页面状态，归类为：
`VISIBLE_VERIFIED`、`SYSTEM_CONTROL`、`NOT_CURRENTLY_VISIBLE`、`REPLACED`、`NOT_APPLICABLE`、`COPY_REWRITE_CANDIDATE` 或 `NOT_RUN`。

不得把未运行路径标为已核实。检查工程英文状态码、按钮动作、错误恢复指引、重复说明、注册协议提示、三盘专业术语、中英文混排和系统默认英文控件。保留算法精度、隐私、权限、双方同意及真实服务不可用等必要信息。文案大规模改写不属于本轮，修改候选单列。

输出 `UI_S4_COPY_FINAL_AUDIT.csv`，覆盖原始1230条，每条有最终处置或明确 NOT_RUN 原因。

## 6. S4-05｜无障碍完整矩阵

覆盖 360dp、标准屏、默认/1.3×/2×字体、键盘、安全区、长文、空态、错误态、浅色/深色。

### 对比度
测正文、大字号、按钮、选中/未选中、失权/错误、各主题盘面及深色模式。普通正文目标至少4.5:1，关键非文字控件至少3:1。首页频道3.57:1必须关闭。

### 触控
建立全部关键控件矩阵，关键高频控件原则上至少48dp。复杂盘面图形可提供等效、易操作的替代选择。

### TalkBack
实际启用 Android TalkBack，验证焦点顺序、控件名称、按钮动作、选中/开关状态、图片替代说明、盘面数据替代阅读、弹窗、返回焦点恢复、失权和错误播报。不能只凭源码语义标记 PASS。

### 键盘焦点
使用模拟器键盘检查 Tab/Shift+Tab、Enter/Space、焦点可见、焦点不被装饰/弹窗遮挡。

输出 `UI_S4_ACCESSIBILITY_FINAL_MATRIX.csv`。

## 7. S4-06｜社区长列表与通知深链失权

社区验证长列表加载、进入详情、点赞回复、返回原位置、分页刷新、切号。

通知验证正常跳转、目标仍有权限、目标失权、Block、撤下、不存在及返回通知列表。失权后不得展示旧正文或私有附件。提供具名 HTTP 和模拟器证据。

## 8. S4-07｜性能 Profile

固定模拟器、分辨率、字体、账号、数据量、缓存状态及 APK。至少5次有效采样，区分冷启动/热启动，测启动、首页、三盘切换、西洋标签绘制、长列表、素材加载、页面重建、内存、帧耗和卡顿，报告 p50/p95 和异常样本。

区分 Android host、Flutter AAR 与 Flutter Profile 构建。不得用10帧宿主 gfxinfo 宣称 Flutter 帧性能通过。没有正式预算时如实报告，不自造 PASS 阈值。

输出 `UI_S4_PERFORMANCE_PROFILE_REPORT.md`。

## 9. S4-08｜既有功能回归

依据 UI-S3-R 功能回归矩阵逐项核对 F01–F11、R01–R03、R04-A 和账号切换。每项记录实际运行、账号、权限、结果及缺口。PARTIAL 不得自动改为 PASS。

不得因 UI-S4 重新开放 KYC、Push、对象删除受理、真实匹配或访客转载。既有产品合同继续有效：
- Match ≠ Connection ≠ Messaging Consent ≠ Conversation ≠ Relationship。
- Buddy 独立于恋爱匹配。
- 减少操作不等于自动分享、自动接受候选或自动同意聊天。
- 旧排盘 POST 409、新本命入口和有限只读兼容继续。
- R04-A 普通注册协议门禁继续；TEST_ONLY 登录不等于普通注册。

## 10. S4-09｜量化对照与缺陷处置

输出 UI-S0/UI-S4 同口径 C/S/I/N/W/B 对照、绝对变化、百分比、首次使用、日常访问、失败恢复及必要确认成本。不同起终点、权限、账号或数据不可比较。U01 普通注册保持 BLOCKED，U01-T 单列；U05 完整任务不得用3C/0S概览替代。

输出：
- `UI_S4_U01_U12_INTERACTION_COST_MATRIX.csv`
- `UI_S4_DEFECT_DISPOSITION.csv`
- `UI_S4_FEATURE_REGRESSION_MATRIX.csv`
- `UI_S4_ANDROID_SCREEN_COVERAGE.csv`

本轮只授权 S4-01 对比度修复及必要测试适配。其他发现记录缺陷，不擅自进行大规模修复。阻断单项时保留证据并继续其他可执行项。

## 11. 权限边界与交付

允许：本地 Flutter 构建、独立 Laravel/MariaDB、两个隔离模拟器、虚构 TEST_ONLY 账号、UI 自动化、TalkBack、键盘测试、Profile 测量、脱敏 GitHub 开发分支同步。

禁止：绕过普通注册门禁、真实用户/账号、实体手机、共享 Staging、公网探测、真实百度 API、KYC/Push/供应商、真实数据外发、main 合并、正式内测和生产发布。

沿用 LOCAL-FIRST。普通工程范围内 Codex 自主连续执行，不逐项等待 Owner；超出边界的事项只暂停相关路径。

集中交付：
- `V2_UI_S4_QUANTITATIVE_UX_ACCEPTANCE_REPORT.md`
- `UI_S4_U01_U12_INTERACTION_COST_MATRIX.csv`
- `UI_S4_COPY_FINAL_AUDIT.csv`
- `UI_S4_ACCESSIBILITY_FINAL_MATRIX.csv`
- `UI_S4_FEATURE_REGRESSION_MATRIX.csv`
- `UI_S4_PERFORMANCE_PROFILE_REPORT.md`
- `UI_S4_ANDROID_SCREEN_COVERAGE.csv`
- `UI_S4_DEFECT_DISPOSITION.csv`

固定源码、Git tree、最终 APK SHA、签名、两台模拟器安装核对、24页面状态、U01–U12、文案、无障碍、性能和功能回归全部可追溯。更新 ACTIVE_STATE、CURRENT_WORKFLOW 和必要索引。交付后停止，等待网页 GPT 顾问独立复审。

最终出口：
- `UI_S4_QUANTITATIVE_ACCEPTANCE_PASS`
- 或 `UI_S4_QUANTITATIVE_ACCEPTANCE_PARTIAL`

不得将 UI 验收完成等同于发布准入。

总体发布状态继续：
`R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`
