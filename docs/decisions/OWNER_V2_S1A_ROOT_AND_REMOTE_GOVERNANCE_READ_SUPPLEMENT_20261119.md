# EliteSync V2｜Owner S1-A补充授权：唯一审计工程根与GitHub固定治理文档只读访问

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_S1_A_ROOT_PINNED / OWNER_REMOTE_GOVERNANCE_READ_ONLY_APPROVED / S1_READ_ONLY_AUTHORIZED / S1_SOURCE_HANDOFF_PENDING / V2_IMPLEMENTATION_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 1. 本次Owner原始确认与精确适用范围

前序[Owner S1-A具名只读审计授权](OWNER_V2_S1A_BOUNDED_READ_ONLY_CODEX_GAP_AUDIT_AUTHORIZATION_20261119.md)已生效。本地Codex在身份预检中返回`IDENTITY_UNRESOLVED`且未执行R1–R5；其报告：

- 会话原目录 `D:\EliteSync-v10`：`main` / `4bebc8f394248e254c1368a06fbdee5d2c883301`，43项未暂存修改、213个未跟踪；暂存区空。
- 另一个本地根 `D:\EliteSync-v10-product-v1015-20261101`：`codex/ui-current-state-audit-20261116` / `1d8b485bf4f314d42431bb62a293a3fef9e9c8af`，1个未跟踪条目，暂存区空。
- 两者remote均为`zcx369658780/EliteSync-v10`，本地未含2026-11-19的最新S1-A治理文档；本轮仅做只读身份核对，不运行R1–R5。

网页顾问随后**单独请求**Owner确认：

> 是否同意将 `D:\EliteSync-v10-product-v1015-20261101` 指定为本次S1-A唯一工程审阅根，并允许Codex只读访问GitHub上述固定提交中的治理文档？

Owner明确答复：

> 我同意，请给我一个新的codex用任务单启动prompt

因此本次新批准的**恰好两个补充条件**：

1. **唯一允许深入审计的工程根**：`D:\EliteSync-v10-product-v1015-20261101`。会话原目录`D:\EliteSync-v10`不作为本次R1–R5的源码审阅目标；其未提交/未跟踪内容不能迁移、清理、切换、覆盖或修改。
2. **允许只读访问固定GitHub治理文档**：仓库`zcx369658780/EliteSync-v10`，原S1-A治理已回读固定提交`832686829c64dce91f6b9dcff0f6d2404c9da078`，并允许只读读取本次补充Owner决定及新Codex启动Prompt所在的固定治理快照。仅允许受授权工具的只读`GET`/GitHub连接器读取文件；不`git fetch/pull/clone`，不向本地工作树下载/落盘，不改变任何Git引用或文件，不允许外部供应商/业务服务联接。

**这不是第二次开发授权，也不要求另开Codex会话。** 已因身份不唯一而暂停的S1-A，可在上述补充条件满足后由Owner手动给**现有Codex项目会话**启动一次R1–R5静态只读核查。此次文本未证明新的代码或动态结果。

## 2. 固定身份核验条件与差异处理

目标工作树由Owner按路径**明确指定**，但其上一次被本地报告的分支和HEAD只是**当时的只读身份快照**，并非现在一定未变化：

- 上次基准：`codex/ui-current-state-audit-20261116`，HEAD `1d8b485bf4f314d42431bb62a293a3fef9e9c8af`；原报告为暂存区空、1个未跟踪。
- 新启动时必须对**目标绝对路径**再次只读取得Git顶层、origin仓库身份、branch/HEAD、暂存区与dirty/untracked摘要，并将本轮实际身份和上次基准作对照。
- 如果实际Git根与Owner指定路径不一致、remote不是该仓库、缺少目标目录，或出现来源不明/无法判断是否为合法活动根的身份冲突：立刻停为`S1_PAUSED_IDENTITY_DRIFT`并回报，不猜测或自动切换；仅工作树dirty数量变化不应自动当作错误，但必须报告并保持绝对只读。
- 不得因为GitHub治理文档提交与本地工程HEAD不同而拒绝审阅：它们本来就分属**产品治理权威与实际工程证据**两种身份。

## 3. 允许范围与禁止边界保持

继续仅S1-A：从指定工作树中以无副作用静态方式阅读APP/API/Web/DB **schema与迁移定义**、已有测试源码及必要非敏感文档，核R1–R5，交付一份`PRESENT/PARTIAL/ABSENT/UNKNOWN`脱敏源码证据报告。可使用绝对路径`git -C`与只读文件检索而不改变会话原目录；不对原目录和其它worktree做R1–R5扫描。

禁止任何工作树写入、git checkout/fetch/pull/merge/commit/push及远端改动、项目脚本执行、测试、构建、数据库/服务/模拟器/手机、真实核验/Push/RTC供应商、公开隐私或读取秘密值。若GitHub只读文件无法访问，不用切分支或克隆解决，应报告`GOVERNANCE_SOURCE_UNAVAILABLE`并列出缺项；若直接从Owner消息获得官方确认范围，能独立追溯的部分可标已核，无法追溯部分标`CONTRACT_SOURCE_NOT_CHECKED`，不猜测。

最终报告**仅返回现有Codex会话**，不写入本地文件或GitHub。外部/法域、动态G01–G10`NOT_RUN`、旧候选`10.1.18-dev / 1011804`的历史`UNKNOWN/NOT_RUN`、原43PNG`PENDING_BINARY_UPLOAD`与F-01`READABILITY_PARTIAL`不变。A6仍`DEFERRED`，V2开发/设备/发布仍`NOT_AUTHORIZED`。
