# EliteSync v10｜TASK_CURRENT

Task ID: `APP-INT-10-LOCAL-PRIVATE-CACHE-AUDIT`

Risk Level: `LEVEL 2`（私密数据本地存储与访问门静态审计；Work 独立审查，Owner 保留政策决定）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。Owner 已选择方案 B：允许加密本地私密缓存，重启后在线核验通过前不显示。此任务只查现状与决策缺口，不授权实现加密缓存、迁移已有数据或更改产品政策。

## Objective / Why now

在规划真实恢复前，确定当前 Flutter 代码是否已在设备持久保存私密 Conversation 相关数据，实际使用哪种存储、何时写入/读取/展示、如何随账户与权限变化失效。Work 限定静态检查已见 `chat_room_page.dart` 的草稿写入 `LocalStorageService`，该服务使用 `SharedPreferences`；不能据此推断所有路径的运行可达性或设备上的实际存储内容。输出一份按类别的可审查审计表与最小修复优先级。

## Allowed paths / source scope

只可新增 `EVIDENCE/APP-INT-10-LOCAL-PRIVATE-CACHE-AUDIT/summary.md`，作为唯一主要结果；必要时同目录可新增一份短静态检索回执。只读消费 `PRODUCT_DECISIONS.md`、APP-INT-07/09 证据、Conversation data-rights Owner 接受记录，及 Flutter `apps/flutter_elitesync_module/lib/core/storage/`、`features/chat/`、`features/auth/`、`shared/providers/` 中与本地存储、路由和门控相关的源码与已有测试。不得修改源码、测试、依赖、配置、DB、旧接受文件或控制文件；保留无关 untracked 目录。

## Acceptance criteria

1. 逐类列出草稿、Conversation 索引/对方身份、消息正文/附件、预览、未读/通知、路由与账户缓存的实际读写路径、key、后端类型、是否有加密证据、账户/Conversation 绑定、写入与读取时机。区分内存快照、`SharedPreferences`、`flutter_secure_storage`、远端/Mock；路径不存在写 `NOT FOUND IN SCOPE`，不能把注释标签当加密证明。
2. 检查首次启动、重启、logout、账户切换、Connection/Consent 失效、页面销毁与异步回填期间，内容是否可能在未重新核验当前双输入前被读取、进入内存、显示或用于发送。按静态证据标为确定、可能、UNKNOWN；不得以本任务声称设备复现。
3. 对照方案 B 和 D-02/03/D-07：明确哪些现有路径与“加密缓存、在线重验前不显示”有冲突或缺证，哪些只属于旧 v1 兼容路径。对每项给出最小 containment 建议、负向测试建议、数据迁移/既存草稿处理风险、回退条件；不直接选择逐类 retention 期限、离线历史权限或清除政策。
4. 给 Owner 一张简短决策表：哪些类别建议第一版缓存、哪些应暂不缓存、核验失败/退出登录/切换账户后的候选处理选项。标明建议与已有接受政策的区别，指出需 Owner 最终决定的最少问题。

## Verification budget / stop conditions

只做本地限定静态检索与定点阅读；可用代码图谱优先，结果不足时用限定目录 `rg` 并说明。不运行 Flutter/Dart/Gradle、模拟器、HTTP/API、DB、网络、真实数据，也不读取 app-private data；不访问旧 `D:\EliteSync` 或同步 GitHub。若发现明确的私密内容未加密落盘或越过访问门，优先精确记录路径、触发条件及静态证据，立即报告 Work；本任务仍不擅自实施清理或迁移。交付后停在 Work LEVEL 2 独立审查门；Codex 不自接受、提交、备份或发后继。
