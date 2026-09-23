# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-03-PRIVATE-RESTORE-DECISION-PACKET`

Risk Level: `LEVEL 2`（私密恢复、在线权威与离线访问的待决产品边界；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。CACHE-01～02 已由 Work 独立 ACCEPT 并进入本地 `main`。本任务仅汇集可核对的决策材料，不作 Owner 政策选择，不实现新缓存或恢复能力；交付候选后停在 Work LEVEL 2 门。

## Objective / allowed path

在既有 Owner 决定 B（按账户加密保存、重启后先在线重新核验、通过前不显示）之内，整理下一步实现所缺的逐类决定。以 `PRODUCT_DECISIONS.md`、`EVIDENCE/APP-INT-07-*/`、`EVIDENCE/APP-INT-09-*/`、`EVIDENCE/APP-INT-10-*/`、CACHE-01～02 验收和当前 Flutter/后端静态代码为证据，分别列出对话列表/预览、消息正文、未发送草稿、搜索历史等候选类别：现有存储或来源、可用的当前有效性权威、缺失证据、保存与否、保留期限、登出/换账户/撤权处理、核验后离线访问及历史只读的待决问题。区分已决定、候选建议和 UNKNOWN；不得由旧代码存在推定真实服务端权威。

唯一允许新增：`EVIDENCE/CACHE-03-PRIVATE-RESTORE-DECISION-PACKET/summary.md`。可只读检查所需项目文档、源码和既有证据；不修改任何既有文件或代码，不读取设备现存私密值、账户、Token、密钥、真实数据、生产 API/DB，也不访问旧 `D:\EliteSync`。不拉取或推送 GitHub。

## Acceptance criteria / verification budget

- 一份简短的决策矩阵，每项给出可核对的本地路径/符号或证据指针；若真实权威来源未建立，明确写 `UNKNOWN`，不得以 synthetic/mock/provider 或本地缓存冒充在线重验。
- 明列需要 Owner 回答的最小问题集及每个答案对缓存范围/期限/离线访问的影响；不得填入自选默认值，也不得把历史只读在 revoke/pause/close 后开放。
- 标明 CACHE-02 只建立精确清除代码路径、没有设备擦除观察；CACHE-01 不提供加密、恢复或重验。区分静态代码、既有 synthetic 测试、设备观察和生产证明。
- 核对新增路径范围与一次 `git diff --check`；不运行 Flutter/Android 构建、测试、设备、HTTP/API、DB 或网络。回执写明执行时本地分支/HEAD、读取来源、未核验项和限制。

## Stop conditions / review

若材料要求作新的隐私产品决定、开放真实历史权限、读取真实/设备数据、确认生产来源或扩大到实现，则停止并报告具体问题，留给 Work/Owner 决策。根目录无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状；Codex 不提交或备份。候选停在 Work LEVEL 2 独立验收门。
