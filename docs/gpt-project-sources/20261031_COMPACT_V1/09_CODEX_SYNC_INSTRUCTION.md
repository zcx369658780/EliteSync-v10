# 给Codex的项目源同步指令｜Owner已授权文档治理
本文件仅授权Project Sources/治理文档同步，不授权任何产品代码或运行操作。

1. fresh读取GitHub main、AGENTS.md、ACTIVE_STATE顶部、CURRENT_WORKFLOW、TASK_DISPATCH_CLOSURE_PROTOCOL、PROJECT_SOURCE_COMPACTION_POLICY、archive manifest及本次最新handoff。
2. 核对Owner手动替换后的本地Project Sources目录：应仅包含本ZIP完整清单，不保留旧18份文件的叠加副本；逐文件核对SHA-256和UTF-8；确认ZIP manifest一致。
3. 按本地项目约定将新Project Sources镜像同步到GitHub日期化目录；保留原历史快照，不删除旧附件、Git对象、分支、备份或证据。更新必要导航指针，不复制巨型ACTIVE_STATE/CURRENT/TASK_CURRENT。
4. 形成一个简短同步报告：本地镜像路径/文件清单/哈希、GitHub commit/tree/blob、逐文件readback、旧文件归档映射、未完成项。不得声称已替换ChatGPT Project附件（Owner手动操作）或模型Memory。
5. 同步完成后STOP，等待Astra核验。不得创建/启动v10.1.5开发任务，不运行Gradle/ADB/构建/设备操作，不消费G2/APK预算，不触碰产品apps/services、运行库、系统策略、外部供应商或费用。Owner此前对G2与新APK/USB的授权留待后续单独正式任务执行。
