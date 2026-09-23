# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-04-OFFLINE-PRIVATE-READ-BOUNDARY-CONTRACT`

Risk Level: `LEVEL 2`（Owner 已修订的离线私密只读方向之技术/数据边界；Work 独立审查，产品细节仍归 Owner）

Status: `WORK LEVEL 2 ACCEPT — OWNER/REAL-AUTHORITY GATE; NO ACTIVE CODEX TASK`

Assignee: `Codex`（已交付）。Owner 已明确允许登录有效时离线冷启动只读设备已保存的加密会话、消息、图片/视频及草稿；离线不允许发送。离线草稿编辑/持久写回尚未获 Owner 决定。此决定修订旧“每次重启先在线核验”的缓存展示条件，不取消在线 live read/send 双输入门。Owner 拒绝 24 小时建议并希望登录持续约一周至半个月；精确登录/缓存/离线可读期限尚未决定。本任务的设计合同已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/CACHE-04-OFFLINE-PRIVATE-READ-BOUNDARY-CONTRACT/contract.md`。

Next gate: Owner 需分别定登录会话、逐类加密缓存和离线可读凭据的精确期限及断网撤权窗口；身份/Connection/Consent/CV 当前来源、离线凭据和媒体受控存储仍需独立真实证据。当前无已下达的后继 Codex 执行单，不授权实现。

## Objective / allowed path

基于 `PRODUCT_DECISIONS.md` 新决定、`EVIDENCE/APP-INT-07-*/`、`APP-INT-09-*/`、`CACHE-01`～`03`、Owner 数据权利接受记录及当前 Flutter/后端静态代码，形成可供 Work/Owner 审查的离线只读边界合同。至少分别定义：

- 设备曾在线获得有效主体、当前 Connection 与独立 Messaging Consent 后，哪些受绑定的已保存内容可成为离线候选；离线冷启动如何证明本地登录仍在有效期、账户/设备绑定、上次有效核验与离线可读凭据，不能把仅存在的 Token、缓存或旧 consent 当作证明。
- 会话索引/名称/预览、消息文字、已下载图片/视频、缩略图与临时文件、未发送草稿各自的加密和账户/对象绑定、存储位置、系统备份/媒体缓存边界、删除/隔离触发、失效处理；不得把“本地已有”扩写为预下载全部历史。搜索词、通知预览不因本决定自动获准保存。
- 区分登录会话有效期、加密缓存保留期与离线只读凭据有效期；以 7～15 天产品期望为输入，列出可审议的明确期限选项与相应撤权不可及时获知的窗口，不自行选择精确值。已知撤权/关闭/账户切换须锁定或清除；断网期间无法获知远端新撤权的残余风险必须显式标明。
- 离线只读（含查看已保存草稿）与在线 live read、send 分离；离线发送、排队自动发送、旧消息本地操作冒充成功均禁止。离线草稿编辑/持久写回仅列为待 Owner 决定选项，不纳入已接受离线权限。重新联网时如何先锁定、重验、协调本地草稿与新状态，仍以既有双输入/数据权利合同为上界。
- 列出最小负向测试矩阵、回退/清理边界，以及真实身份、有效期、Connection/Consent/CV 权威来源尚未建立导致的实现停点。将静态代码、synthetic 测试、设备观察和生产结论分开。

唯一允许新增：`EVIDENCE/CACHE-04-OFFLINE-PRIVATE-READ-BOUNDARY-CONTRACT/contract.md`。可只读查项目文档、源码和已接受证据；不修改任何既有文件或代码，不读取真实账户、Token、设备私密值、生产 API/DB 或旧 `D:\EliteSync`，不拉取/推送 GitHub。

## Acceptance criteria / verification budget

合同明确标记 `OWNER ACCEPTED`、`PROPOSED`、`UNKNOWN/NOT ESTABLISHED`，不将建议期限或离线凭据机制写成已接受实现。内容类别、可见/可发、退出/撤权/过期矩阵须能回溯本地精确来源。只运行一次 `git diff --check`，并对唯一未跟踪新文件做尾随空白检查；不运行 Flutter/Android、设备、HTTP/API、DB、网络或全量搜索。回执记录执行时本地分支/HEAD、读取来源和未核验项。

## Stop conditions / review

若需要选定精确会话/缓存/凭据期限、真实离线授权方案、法律例外、账户/Token 生命周期、撤权后历史权利或媒体生产存储设计，列出 Owner/责任方决策点并停止，不自行批准。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；Codex 不提交、备份或派发后继。候选停在 Work LEVEL 2 独立验收门。
