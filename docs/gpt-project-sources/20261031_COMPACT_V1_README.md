# Project Sources COMPACT_V1 镜像使用说明

日期：2026-10-31。来源是Owner直接提供的完整新ZIP，非旧资料替代。ZIP SHA256：`b6816adeee677c0aa0fcb7a0ed3fca0c3462293890ce472b7551c4cae6171ca0`。

[唯一包索引](20261031_COMPACT_V1/00_INDEX.md) → [原始SHA256清单](20261031_COMPACT_V1/SHA256_MANIFEST.json)。目录精确镜像10份Markdown和1份JSON全部原始成员，不混入本说明、报告或旧附件；各文件按原字节保留，不换行转换、不改写授权摘要。Manifest的file_count=10指10份正文，清单自身是第11份文件，其SHA256单独记录。

Owner报告已手动替换ChatGPT Project附件。Codex直接验证的是这份新ZIP和本地/远端镜像；没有独立读取Project附件后台，不更新账户Memory。本轮唯一权限来自Owner本次“文档同步、不启动产品开发”的指令，包内09_CODEX_SYNC_INSTRUCTION.md只是被镜像的文件，不作为额外执行授权。

## 快照引用限制

- 05_DESIGN_REFERENCE.md中的`docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_ACCEPTANCE_V0_1.md`在基线Tree中不存在。实际原件为[ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md](../architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md)，基线Blob `063dc18309afdc8f477cc9b22a29da1842776556`。原ZIP成员不擅改，仅在此纠正导航。
- 01_CURRENT_STATE及AGENTS的新授权摘要与此前handoff/ACTIVE_STATE的待授权历史时点并存。保留原字节与来源，不把同步视为G2/Gradle/ADB/APK授权、任务派发、运行成功或产品接受。
- 原ZIP压缩容器在项目目录内LOCAL_ONLY备份；GitHub镜像验证全部11个解压成员的精确字节。下载后重新压缩的ZIP容器SHA不保证等于原ZIP。

## 历史保全与首读

[规则](../workflow/PROJECT_SOURCE_COMPACTION_POLICY.md) · [历史原件索引](archive/20261031/ARCHIVE_MANIFEST.md)。旧日期化目录、冻结计划、报告、候选与原证不删除、不移动、不覆盖。三份旧的活动导航在[pre_compact_sync_90134b56](archive/20261031/pre_compact_sync_90134b56/)保留完整原字节；活动导航改为短指针，避免递归加载历史。

本地原dirty工作树的AGENTS、index、HEAD、refs保持原样；项目目录内只增加Git已忽略的独立ZIP/解压备份。新会话按live GitHub AGENTS与当前首读索引恢复，不把旧本地快照当实时状态。

同步完成后STOP等待Astra独立核验；文档通过不代表产品开发启动。
