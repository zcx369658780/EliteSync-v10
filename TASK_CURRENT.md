# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-08-TRUSTED-LOGIN-ANCHOR-OFFLINE-CREDENTIAL-CONTRACT`

Risk Level: `LEVEL 2`（认证、离线凭据与隐私计时设计合同；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPT — DESIGN CONTRACT ONLY`

Assignee: `Codex`。docs-only 实现前合同已交付并获 Work 独立接受；见 `EVIDENCE/AUTH-08-TRUSTED-LOGIN-ANCHOR-OFFLINE-CREDENTIAL-CONTRACT/contract.md`。当前无活动 Codex 执行单；真实 auth、设备凭据、时间与密文库仍未获实现证明。

## Authority and objective

Owner 已确认：`T0` 必须由服务端确认的成功交互登录事件建立；同账户、同设备获得可验证的离线凭据；自动 Token 续期不重置 `T0`；设备无法可靠判断经过时间时先锁定私密内容，联网核验后才恢复符合当前权限的访问。既有 Owner 决定仍为 15 天在线登录、最后一次成功在线登录后第 16～30 天有条件离线只读、满 30 天清理已保存加密私密内容；离线不得发送、草稿只可查看。权威见 `PRODUCT_DECISIONS.md`，边界合同见 `EVIDENCE/CACHE-05-SESSION-OFFLINE-RETENTION-CONTRACT/contract.md`、`EVIDENCE/AUTH-07-LOCAL-LOGIN-REFRESH-T0-GAP-MAP/summary.md`。现有真实机制未建立。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能，以及上述两份证据和 APP-INT-07/09 对在线当前权限与来源的边界。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：为后继实现写一份可验收合同，明确以下彼此独立的事实和门：服务端成功交互登录事件与 `T0` 的账户/设备绑定及事件顺序；登录回执与 Token 轮换的不同语义；15 天在线登录边界；最长至 `T0+30 天` 的离线只读凭据、内容和对象范围；时钟可信度不足时先锁定、联网重验后恢复；已知登出/换账户/撤权、凭据伪造/重放、跨账户/设备/对象、时间回拨/前跳、清理失败的负向结果。在线 live read/send 仍须当前 Connection、独立 Messaging Consent、CV 与数据权利；离线凭据不授权在线发送或历史只读。用表格区分 **OWNER ACCEPTED**、**PROPOSED 实现合同**、**UNKNOWN/需来源证明**，不臆定具体加密算法、硬件安全能力、设备标识、数据库 schema、远端撤权即时传播或物理擦除保证。

## Scope and verification

唯一允许新增 `EVIDENCE/AUTH-08-TRUSTED-LOGIN-ANCHOR-OFFLINE-CREDENTIAL-CONTRACT/contract.md`。只读范围限上述控制文件、CACHE-04/05/06、APP-INT-07/09、AUTH-07，以及为准确引用所需的精确 Laravel AuthController/Sanctum 和 Flutter session/offline pure policy 源码。不做全仓泛搜。合同应给后继任务建议的分片顺序与每片最小可核验反例，但**不下达实现任务**。只运行一次 `git diff --check`；新文档另作尾随空白检查。无需产品测试或构建。

不连接服务器，不使用 SSH、HTTP/API、DB、设备或真实数据；不读 `.env`、私钥、实际 Token、日志、用户/媒体内容；不修改源码、现有合同或产品决定，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；合同不授权真实身份、密文库、生产部署或对用户可见的离线恢复。
