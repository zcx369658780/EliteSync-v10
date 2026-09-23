# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-05-SESSION-OFFLINE-RETENTION-CONTRACT`

Risk Level: `LEVEL 2`（登录、离线私密读取与加密内容清理边界；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付文档候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

Owner 于 2026-09-24 决定：在线登录持续 15 天；设备在第 16～30 天仍离线时，可以继续只读符合其余条件的本地已保存、按账户加密的会话/消息/图片视频/草稿；离线不能发送，草稿编辑/写回未授权。最后一次**成功在线登录**满 30 天、期间未再次成功在线登录时清理这些加密私密内容，清理后不可离线阅读。自动 Token 续期不重置 30 天计时；离线阅读不另设更短的独立时间上限。以 `PRODUCT_DECISIONS.md` 新决定及已接受 CACHE-04 合同为上界，不把合同旧 7/15 天待选建议继续当现行产品期限。

编写一份可由 Work 独立审查的期限与失效技术合同，精确区分：15 天在线登录期、30 天新加密私密内容清理计时、第 16～30 天离线只读资格，以及在线 live read/send 的既有双输入当前权威门。说明“成功在线登录”的可信事件、自动 Token 续期、设备重启、断网、时间回拨/跳变、账户切换、登出、已知撤权、到期和清理失败的候选处理规则；未由 Owner 决定的实现机制标记 `PROPOSED` 或 `UNKNOWN`，不得将 Token 存在或本地时间戳直接等同于有效性证明。

合同逐类列出本决定覆盖的已保存加密会话信息、消息、图片/视频、草稿及可控缩略图/临时副本的范围和 30 天终点；对系统备份、第三方播放器缓存、真实设备擦除能力及未获准类别写明未建立边界。30 天新加密内容清理不扩张 CACHE-02 的旧明文键清理范围，不授权删除账户、Token 或其他缓存。纳入最小负向用例、清理失败时防展示与重试的候选原则、断网无法获知远端撤权的残余窗口、真实身份/可信时间/离线凭据/Connection/Consent/CV 当前来源停点。明确区分静态代码、synthetic 测试、设备观察和生产结论。

## Allowed path and verification budget

唯一允许新增：`EVIDENCE/CACHE-05-SESSION-OFFLINE-RETENTION-CONTRACT/contract.md`。可只读核对本地项目文档、既有证据及必要的现有 Flutter 静态路径；不修改其他文件或产品代码，不读取真实账户、Token、设备私密值，不访问生产 API/DB 或旧 `D:\EliteSync`，不拉取/推送 GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

作者只运行一次 `git diff --check`，并对唯一新文件做尾随空白检查；不运行 Flutter/Android、设备、HTTP/API、DB、网络或全量测试。回执记录执行时本地分支/HEAD、读取来源、精确文件路径与未核验项。若发现 Owner 新决定与既有受保护数据权利冲突，只列出冲突并停在 Work/Owner 门，不自行放宽。

## Acceptance and stop

候选必须可逐项追溯 Owner 已定值、旧合同仍有效的在线门和未建立的实现条件；尤其不能把第 16 天写成离线私密内容锁定或清理，也不能以自动 Token 续期延长 30 天。Codex 不自行接受、提交、备份或派发后继。Work 对唯一候选作 LEVEL 2 独立 ACCEPT/REJECT；真实授权机制、设备数据和生产动作另行审议。
