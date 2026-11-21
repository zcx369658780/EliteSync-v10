# EliteSync V2｜网页GPT顾问会话交接｜P0.4.1限定验收完成，P0.4.2待Codex交付后集中验收

日期：2026-11-21（Asia/Shanghai）
治理分支：`governance/home-matching-product-freeze-20261117`
本交接写入前固定治理HEAD：`411e6d91a77106944aa953ce2c391c24d1eafec6`
产品开发分支：`codex/v2-function-completion-20261121`
P0.4.1实机报告提交：`e4d1588acee62d8f8f166042c328e26cc951c14a`
P0.4.1实机源码HEAD：`00ca46f6b020afa25ce472509c2fd3227f74c461`

## 1. 新会话固定首读

先从GitHub读取治理分支最新HEAD，再按顺序读取：

1. 本文件：`docs/workflow/SESSION_HANDOFF_20261121_V2_P0_4_1_ADVISOR_ACCEPTANCE_P0_4_2_PENDING.md`
2. `docs/workflow/ACTIVE_STATE.md` 顶部最新CURRENT ENTRY，遇第一个历史分隔线停止。
3. `docs/workflow/V2_P0_4_1_ANDROID_1011806_ADVISOR_SCOPED_ACCEPTANCE_20261121.md`
4. `docs/versions/v2/V2_P0_4_2_CONVERSATION_GENERATION_HISTORY_ISOLATION_AND_DEVICE_GAP_CLOSURE_TASK_20261121.md`
5. P0.4.1 Codex报告：`docs/versions/v2/cloud-r0-20261121/V2_P0_4_1_ANDROID_1011806_DEVICE_AND_SHARED_HTTPS_REPORT_20261121.md`，固定报告提交`e4d1588acee62d8f8f166042c328e26cc951c14a`。
6. 仅在需要时读取操作手册：`docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md`，同样固定于P0.4.1报告提交。

Owner已接受的权威：
- `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`（main，D-03历史默认策略）。
- `docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md`（main，Conversation访问基础fail-closed合同）。

不要递归历史handoff，不重做阶段A/B/C/D或V2-Q验收，不恢复网页GPT逐个小任务派单制度。

## 2. 当前阶段和验收结论

### 2.1 P0.4.1

Codex固定报告：
- 提交：`e4d1588acee62d8f8f166042c328e26cc951c14a`
- 分支：`codex/v2-function-completion-20261121`
- 实机产品源码HEAD：`00ca46f6b020afa25ce472509c2fd3227f74c461`
- P0.4.1交付提交只新增实机报告、修订操作手册，没有产品源码变化；报告相对实机源码比较为ahead 3 / behind 0。
- 报告列出145项证据SHA-256。顾问核对了GitHub报告、哈希表条目数量和源码/合同，但没有取得本机145个原件重算哈希，也没有重新连接手机复演；手机/APK实测事实仍明确标记为Codex报告证据，不冒充顾问独立重测。

顾问限定结论：
`1011806_INSTALL_PASS_ON_AUTHORIZED_RETRY / DEVICE_E2E_PARTIAL_WITH_P0_HISTORY_PRIVACY_FAIL / OWNER_D03_HISTORY_DEFAULT_FAIL_CLOSED / PHOTO_PICKER_UPLOAD_NOT_RUN / REAL_WIRELESS_OUTAGE_NOT_RUN / SHARED_HTTPS_NOT_DEPLOYED / REAL_ADMIN_NOT_RESTORED / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`

顾问记录：[P0.4.1限定验收报告](V2_P0_4_1_ANDROID_1011806_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)。

### 2.2 已报告且限定接受的设备旅程

- 1011806在此前1011805实测的同一台Android 16实体手机重试安装成功；手机拉回APK的包名、versionCode、大小、签名证书和SHA-256与固定候选一致（均为Codex报告证据）。1011805及原数据保留。
- 冷启动/登录态恢复、A/B/A切号、退出、前后台、昵称资料保存、三盘未知时刻输入和持久读回、消息UNKNOWN独立fresh GET恢复、双向Block生效期间旧内容与控件失权有具名实机证据。
- 三盘状态仍是`COMPUTED_UNVERIFIED`，不能解释为算法正确性全面通过。
- 慢约候选、手机端Connection/消息同意完整双方操作、正式关系双确认、Buddy双方申请/确认/退出仍部分未跑。
- Photo Picker可打开，但未取得选图返回；手机PNG/JPEG上传、上传失败重试未跑。
- SELF/FRIENDS、旧媒体链接有部分主机合成数据证据；新好友/退出好友、缩略图缓存和完整设备旧URL复核未完成。
- URI/通知为PARTIAL，真实过期链接、独立跨账号对象待补。
- WLAN关闭时ADB reverse仍可访问本机HTTPS并返回200，因此真实手机到后端无线断链未验证；请求前、提交前、提交后丢响应、读取中四个无线故障窗口均NOT_RUN。USB reverse故障注入不能冒充真实Wi-Fi断链。
- W01–W04 Web后台截图NOT_RUN。操作手册仍是1011805主文加1011806独立附页的登记准备稿，不是软著定版。

### 2.3 P0隐私失败——必须优先处理

实机观察：第一代Connection/MC期间产生4条消息；双方Block后旧消息在Block生效期间不可读；解除Block并建立第二代Connection和双方新消息同意后，第一代4条旧消息重新出现在手机中。

顾问已抽查固定实机源码：
- `SocialPolicy::revokePair()`会关闭pair已有Connection（`CN_CLOSED`）并撤销相关`MC_ACTIVE/MC_PENDING`。
- `ConversationDomainService::roomKey(a,b)`仅以双方用户ID生成稳定pair room key，`ensureDirectConversation()`按该key复用同一Conversation。
- `MessageController::listAuthorized()`只检查当前pair的`canRead`，随后按稳定pair room_id读取消息，没有按Connection generation/context或独立history authority过滤。
- 因此第二代live CN/MC重新开放pair级读取时，旧代消息一起被读出。

这与Owner已接受的D-03冲突：
- revoke、Connection pause/close之后，只读Conversation历史默认不可读；
- 除非未来为明确主体、受众、用途、保留状态和适用法域建立独立history-access authority；
- fail-closed不代表历史数据已删除或擦除。

APP-T07也规定：既有Conversation行、消息历史、peer ID、route、Match identity等本身不能创造read/send authority。

顾问判定：**P0隐私/授权边界FAIL**，不是可接受的正常“重新同意后恢复历史”，也不能仅归类为Flutter缓存。旧消息及附件保留在数据库，不物理删除、不宣称已擦除。第二代live会话默认只读第二代内容；旧代消息/媒体/通知/预览/搜索/未读/回复引用/旧链接必须默认不可读，除非未来单独建立history authority。

## 3. 下一任务：P0.4.2

固定任务单：
`docs/versions/v2/V2_P0_4_2_CONVERSATION_GENERATION_HISTORY_ISOLATION_AND_DEVICE_GAP_CLOSURE_TASK_20261121.md`

当前状态：
`LOCAL_REMEDIATION_AUTHORIZED / CODEX_DELIVERY_PENDING / NEW_APK_INSTALL_REQUIRES_NEW_OWNER_AUTHORIZATION / CLOSED_BETA_NO_GO`

任务范围：
1. P0优先修复Conversation历史代际隔离：第二代Connection/MC只能读取第二代live上下文消息，不能因pair级room key复用而继承第一代历史。
2. 服务端/数据库模型必须隔离；不能只在Flutter端过滤。
3. 覆盖消息列表默认/latest/after_id/before_id/分页/搜索、read/ack、reply summary、通知、旧Conversation detail/route、last-message preview、unread count、附件和媒体URL。
4. A/B两端双向测试：第1代旧消息不可读，第2代新消息正常收发/已读/附件；旧行仍保留且未修改或删除。
5. 补Photo Picker选图返回、合成PNG/JPEG手机上传、SELF/FRIENDS受众、原好友/新好友/退出好友/Block、缩略图缓存、旧链接撤权。
6. 外部URI、通知、真实无线断链按任务单继续；如果固定回环端点不能形成真实无线测试路径，明确NOT_RUN，不伪造PASS。
7. 更新同版操作手册和中文综合报告，保持历史FAIL账、UNKNOWN和NOT_RUN。
8. 提交到非main分支，等待网页GPT顾问集中验收。

### 新APK和设备授权边界

- 1011805和1011806均保留，及其数据均不得清除。
- Owner此前明确授权的安装对象是1011806；该授权已经使用，不是对后续版本的永久安装授权。
- Codex可本地修改源码、迁移、PHP/Flutter/API测试和构建新候选（例如1011807），并固定包名/version/signature/SHA/native+Dart endpoint/TLS。
- **未取得Owner对新versionCode/APK的明确安装授权前，不得在手机安装/覆盖新候选。** 先完成本地回归并提交报告，必要时请求单独设备授权。
- 真实历史消息删除/擦除未授权；P0.4.2仅做默认不可读隔离。

## 4. 当前云端、管理员和发布状态

- 1011806仍连接本机`https://127.0.0.1:18444/`，通过本轮USB reverse到专用本机Docker/HTTPS/MariaDB；不是阿里云共享后端，也不能供外地同事使用。
- 本轮USB reverse已撤销、Wi-Fi已恢复；专用本地测试服务/数据卷按Codex报告保留。不得擅自停止、清卷或全局Docker清理。
- 阿里云共享HTTPS尚未部署；旧上海机2vCPU/2GiB并行容量未获证明，独立Staging上海账号实际结算价仍UNKNOWN；当前无新增云支出。
- 真实旧管理员身份尚未恢复：真实候选、真实记录读取、备份解密、V2导入、持有人本人异地登录均NOT_RUN。Owner此前已决定旧管理员身份恢复是封闭内测硬门，但这不是立即读取真实行/云写/采购的授权。
- 封闭内测`NO_GO`，生产`NO_GO`；未合main、未正式申报软著、未发布生产。

## 5. Owner决策和授权记录

### 已明确的既有Owner决定

- Owner确认1011806可在此前同一台Android设备安装并执行P0.4实机测试；本次已完成重试安装。此授权不延伸至新APK。
- Owner接受Conversation数据权利D-01至D-10，其中D-03选择保守默认：revoke/pause/close后历史只读不默认开放，必须有独立history authority。
- Owner要求旧管理员身份恢复成为封闭内测硬门，原因是同事要在外地使用既有账号标识/手机号，不应重新注册。
- Owner确认内测后可以考虑更换服务器；当前先完成产品功能以推进软著和内测准备。当前不因迁移服务器而中断本地功能开发。
- Owner同意P0.4.2任务方向：先修复历史代际隔离，再补实机剩余项（本交接记录的是当前任务状态，不将此解释为新APK安装、云写、真实管理员数据或内测授权）。

### 本次会话没有新增的Owner授权

- 没有新授权1011807或其它新APK安装。
- 没有新授权读取/解密/迁移真实管理员数据。
- 没有新授权阿里云部署、云端写入、采购、开公网或旧服务变更。
- 没有授权合main、正式软著递交、封闭内测或生产发布。

## 6. 工作流和治理规则

- Owner保留最终产品和重大决策权。
- 本地Codex负责日常工程开发、版本计划、实现、自测和交付报告。
- 网页GPT顾问负责战略/产品合同、独立源码抽样、阶段集中验收；不恢复逐个小任务派单制度。
- GitHub治理分支保存治理状态、Owner决策、交接和脱敏报告；本地Codex工作树是工程实际工作区。GitHub治理/报告提交不自动代表产品源码同步或生产部署。
- P0.4.1报告提交只新增报告/手册，不含产品源码变更；实机源码固定在`00ca46f6b020afa25ce472509c2fd3227f74c461`。
- 每轮保留明确证据分层：Codex报告、顾问独立核实、Owner最终决定、生产准入不得混为一谈。FAIL、UNKNOWN、NOT_RUN不得升级为PASS。
- 新APK安装、真实管理员数据、云写/采购/公网变更、main合并、内测和生产发布均需各自独立Owner授权。
- 交接后下一节点是：Owner将Codex完成P0.4.2后的固定GitHub交付报告和commit发到新会话；新会话按本交接和任务单做集中顾问验收，不重新派发P0.4.2的小任务，不重做P0.4.1验收。

## 7. 新会话待办

1. 首读本交接和固定权威，确认治理HEAD及开发分支实际HEAD。
2. 不要预判P0.4.2通过；等待Owner提供Codex固定交付报告/commit。
3. 收到后核对真实源码基线、交付HEAD、差异和工作区/分支状态。
4. 抽查代际隔离数据模型、迁移、消息读写/附件/通知/预览/搜索/未读/引用等关键路径和测试断言。
5. 核对第1代历史仍保留但默认不可读、第2代消息正常读写；检查历史FAIL、NOT_RUN、UNKNOWN和真实设备证据边界。
6. 对P0.4.1未完成的Photo Picker、媒体受众/缓存、URI、无线链路按具名证据逐项验收。
7. 形成P0.4.2集中顾问验收结论；必要时归档GitHub治理分支。阶段D/共享Beta/真实管理员恢复/软著定版/封闭内测仍按各自Owner门处理。

---

**交接停点：P0.4.1已限定验收；P0.4.2任务单已固定，等待Codex工程交付。封闭内测与生产均NO_GO。**
