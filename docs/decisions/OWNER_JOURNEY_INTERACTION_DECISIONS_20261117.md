# Owner决策补充：首次探索与连续关系引导

日期：2026-11-17（北京时间）  
状态：`OWNER_CONFIRMED / DESIGN_ONLY / NO_IMPLEMENTATION_AUTHORITY`  
前置总冻结：[OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md](OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md)  
目标旅程：[ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_V0_2.md](../product/ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_V0_2.md)

## 一、Owner正式确认的新增决定

### J-01 注册后的首次Lifestyle引导 — OWNER_CONFIRMED

- **完成注册后自动出现一次可跳过的Lifestyle探索欢迎页。**
- 用户可开始五场景Lifestyle探索，也可选择跳过并继续使用内容首页。
- 注册阶段Lifestyle不是硬门槛；主动进入正式真实匹配参与前必须完成Lifestyle（此前Owner决定继续有效）。
- 注册后不以MBTI、出生时刻、出生地点、星盘结果或完整匹配资料作为访问首页前置条件。

### J-02 Connection与消息许可 — OWNER_CONFIRMED

- **采用连续引导、分别作出明确决定**的用户体验。
- 匹配提案接受、建立Connection、Messaging Consent及正式Relationship仍然为不同业务决定和服务端权限合同。
- 只有当前业务事实确认可以进入下一阶段时，界面才显示该阶段操作；上一阶段接受不得自动同意下一阶段。
- 同一条连续体验路径不应要求用户重复寻找Connection和Messaging Consent入口。
- 任何一方尚未同意、拒绝、撤回、过期或当前权限不明时，必须准确显示待处理/不可用及恢复路径，不自动推进聊天。

## 二、与既有决策的组合

- Home：访客仅能阅读平台公开精选；登录后按权限使用站内公开作品与好友动态。
- Matching：正式真实匹配须具备Lifestyle、真实身份核验及其他必要资格，并由本人选择一次性报名或独立授权自动参与。
- 星盘：资料及用途授权充分时自动生成，非匹配资格门槛。
- Messages：聊天/通知双频道、默认聊天、未读独立；通知当前有效待办优先，普通通知按时间排列。
- Me：个人事实/形象/工具的资料可复用但受用途与受众权限制约，主头像昵称仅自动更新使用默认形象的本人预览；对外匹配展示版本仍独立受控。

## 三、顾问建议而非Owner批准的细节 — OPEN/ADVISOR_PROPOSAL

- “仅一次”采用账号级、跨设备一致的首次引导记录，避免每次登录重复弹出；具体存储/迁移方案尚未批准。
- 保存已作答进度，跳过/中途退出后将后续问题恢复到未完成处；保存失败停留当前题目并重试，动画时序待实测。
- 匹配双方同意后按当前结果显示下一步Connection；双方Connection成功后提示独立Messaging Consent；双方许可有效后提供直接进入有权聊天。
- 同一连续页面可渐进引导，但**各业务独立提交、各方独立同意、各自可撤回**；具体UI页数、确认措辞、条件检查和版本号需后续设计。
- 操作成本预算只可作为未来测试目标，不是当前1011804已测得的成绩。

## 四、权限与实施门禁

真实身份供应商仍未接入；1011804不存在已完成的真实用户端到端新链。Codex、API、Flutter、数据库和真实用户测试均不因本决策自动获得实施授权。

当前仅允许顾问与Owner进一步完善完整旅程及可视化设计；不得把此设计决策当成v10.1.19开发任务或产品代码验收。
