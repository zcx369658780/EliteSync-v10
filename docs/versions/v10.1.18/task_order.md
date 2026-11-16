# v10.1.18任务书：UI表达与交互一致性收口

日期：2026-11-16（北京时间）  
状态：`OWNER_AUTHORIZED`

## 一、固定任务身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.18-ui-language-match-entry-consistency-20261116`
- 唯一父基线：`507ffcbf5a5f5abd3cac27b965388c9cb7155867`
- 上一版Owner实机反馈固定提交：`507ffcbf5a5f5abd3cac27b965388c9cb7155867`
- v10.1.17产品源码：`1953582093d3469a48cd7275864309cb09eb0e53`
- v10.1.17原工程交付：`93cb9e4db01ed5262d100f5982b5e01bf4799015`
- v10.1.17顾问验收：`f0e31d8ae9d00f5f10d18b932390ad721dec903c`
- 建议候选：`10.1.18-dev / 1011801`，构建前核验versionCode、applicationId和签名占用，不覆盖1011703/1011601。

## 二、开工前强制同步

Codex不得直接开始改文案或颜色。先完成：
1. 核本地稳定工程根、origin、branch、HEAD、dirty/index、数据库、AVD、私有配置、测试账号和证据。
2. 只读本地`AGENTS.md`、`ACTIVE_STATE.md`当前入口、`CURRENT_WORKFLOW.md`。
3. 从本任务分支固定父基线逐Blob同步：
   - V3.0路线图与v10.1.18补充决定；
   - v10.1.17 Owner原始实机反馈；
   - v10.1.17原工程报告、顾问接受报告、manifest、证据摘要和Owner检查表；
   - 本版task_order、plan、DEVELOPMENT_ALIGNMENT、UI_AND_MATCH_CONSISTENCY_CONTRACT和CODEX_START_PROMPT；
   - 更新后的AGENTS、ACTIVE_STATE、CURRENT_WORKFLOW。
4. 保护原dirty/index、数据库、AVD、凭据、媒体和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。
5. 逐Blob核对并记录`LOCAL_DOCS_SYNCED`或`PENDING_LOCAL_SYNC`。
6. 在源码修改前完成`OWNER_FEEDBACK_TRACEABILITY.md`和`ROADMAP_ALIGNMENT_ACK.md`：逐条映射Owner反馈→改进目标→页面/组件→验证证据；确认Buddy独立、冷启动定义、B4/C未授权、Owner手机不操作。
7. 检查并标注v10.1.17报告/manifest中“顾问验收PENDING”的历史表述：只做时间线澄清，不能改写原验收或把Owner整体接受改成PASS。完成前不得修改产品源码。

## 三、八项验收标准

### AC18-01 历史状态与Owner反馈对齐
- 保留v10.1.17原固定交付、顾问报告、Owner反馈及其时间顺序；
- 对实施报告中交付时“顾问验收PENDING”的历史语句添加时间标注，明确后续顾问已接受原固定工程交付；
- 明确Owner整体接受仍PENDING，有限实机反馈不等于整版接受；
- 第8项仅记录“新账号未显示旧账号消息”的观察，冷启动仍NOT_RUN；
- 不改写v10.1.17的原AC范围或测试事实。

### AC18-02 用户可见文案收口
- 全面盘点首页、匹配、生活方式、自动化、消息、Me、Buddy、社区的程序式/开发式/重复文案；
- 替换“账号可用”“本轮暂无候选，不代表被拒绝”等不自然表达；
- 未知状态仍准确表达未知，不能为了简洁暗示成功/失败；
- 将一般持续说明和长免责声明集中到权限/说明页面；
- 首次参与匹配保留一次必要的简短说明，必要权利确认仍在上下文中；
- 提供文案映射表：旧文案、问题、最终文案、状态来源、使用页面。

### AC18-03 一级入口「进展」调整为「匹配」
- 四个底部入口保留，第二入口展示为「匹配」；
- 页面聚焦匹配状态、轮次、候选/提案、历史结果和本人待决定事项；
- 不把恋爱关系主观体验包装为APP决定的“关系进度”；
- 旧progress路由、深链、通知跳转、历史入口兼容；
- Match、Connection、Messaging Consent、Conversation、Relationship仍独立；
- 不改匹配算法、排序、资格和后端业务合同。

### AC18-04 统一按钮/选项状态色
- 统一default、pressed、selected、disabled、destructive等状态；
- 修复生活方式选中/按下后文字不清；
- 优先使用共享Theme/token，不允许各页继续硬编码冲突颜色；
- 保持低刺激低饱和几何色块；
- 对比度满足合同中的可读性标准；
- 验证正常/放大字体、现有主题模式、键盘/无障碍焦点与状态提示；
- 不生成新美术素材。

### AC18-05 自动化入口可发现性
- 解决Owner本轮未找到自动化入口的问题；
- 在「匹配」和「我的」提供清楚入口/上下文链接；
- 所有入口指向B2唯一规范UserState/Automation控制页；
- 默认OFF、明确授权、pause/resume/revoke和revision合同保持；
- 不新增第二套开关，不增加频繁提醒/推送。

### AC18-06 说明/免责声明合理归位
- 将持续性说明、用途说明和一般免责声明集中到「我的→权限/说明」；
- 首次参与匹配时可展示一次必要简短说明；
- 复用已有同意/版本记录，避免重复弹出；
- 不移除隐私分享、匹配接受、消息同意、Connection、Relationship、删除/退出等必要确认；
- 不把静默执行包装为用户授权。

### AC18-07 Buddy匹配独立诊断
- 使用虚构账号与隔离数据重现Owner报告的“可以进入但无法匹配”；
- 检查UI/路由、用户资格、Buddy专属筛选、请求参数、API响应、候选池、部署配置和后台任务；
- Buddy与恋爱匹配独立；
- 可修复证据明确的UI/路由/配置/接口接线缺陷；
- 若根因属于算法、权重、候选策略或新业务规则，提交诊断报告并标记UNKNOWN/OWNER_DECISION_REQUIRED，不擅自重写算法。

### AC18-08 冷启动/账号隔离与集中交付
- 同一安装内A→logout→B→force-stop→cold-start B→logout→A完整测试；
- 检查Home状态、匹配、消息、通知、私有缓存、草稿和离线恢复；
- 使用token主体、HTTP主体、缓存命名空间、DB主体和UI可见内容相互印证；
- 至少一轮网络中断/恢复，确认旧账号缓存不会被新账号读取；
- Owner手机不由Codex操作；交付Owner手动复验表；
- 完成定向Widget/Dart/API/DB和模拟器真实APP验证，构建1011801或核占用后顺延；
- 交付实施报告、manifest、证据摘要、文案映射表、Buddy诊断、账号隔离/冷启动回执、去敏截图和APK身份。

## 四、明确禁止

- 不改变恋爱匹配算法、候选排序、ProfileReadiness、SlowDating资格判断和关系状态机；
- 不把Buddy并入恋爱匹配；
- 不自动接受候选、分享资料、发送消息或确立Relationship；
- 不新增运行时AI、身份核验、征信、芝麻信用、蚂蚁积分、真实Push、支付或外部供应商；
- 不生成新美术素材，不重开视觉风格会议；
- 不操作Owner手机；
- 不使用真实用户/生产数据；
- 不合main、不正式发布、不开展真实内测/运营；
- 不自动启动B4或阶段C。

## 五、交付与停止

完成八项AC具名范围工程交付，固定提交并完成同源远端回读后停止，等待GPT顾问独立验收。Owner整体接受与真实手机验收由Owner在候选交付后决定。
