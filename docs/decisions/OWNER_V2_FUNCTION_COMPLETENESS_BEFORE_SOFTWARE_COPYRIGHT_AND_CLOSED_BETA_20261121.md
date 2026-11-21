# Owner决定｜V2先完成功能，再准备软件著作权及封闭内测；云迁移延后

日期：2026-11-21（Asia/Singapore）。状态：**OWNER_FUNCTION_FIRST_PRIORITY / EXISTING_FEATURE_COMPLETION_AUTHORIZED_WITHIN_DEFINED_PRODUCT_SCOPE / CLOUD_MIGRATION_DEFERRED / G0B_REPORT_LOCAL_ONLY_UNREVIEWED / PRODUCTION_NO_GO**。

## Owner最新原文

“你好我先补充一个简单原则：在内测之后会考虑更换服务器，但是现在让我们先完成功能开发，这样才能推进到注册软件著作权并且开启内测阶段。（如果功能都不全，是无法内测的）”

这项**后续明确的Owner优先级**优于此前“优先开独立云Staging和反复补备份门”的阶段建议；并不取消此前G0只读核身的真实证据或允许自动删除旧资源。

## 立即生效的产品推进顺序

1. **现有明确范围内核心功能闭环**：按已冻结EliteSync V2产品语义和A–D/R1/R0代码，从真实用户旅程出发修复、补足、连通APP/API/Web/隔离数据库。缺失功能不因为旧回归用例冲突而无声退役；新增未决业务规则/合规现实由Owner统一裁定。
2. **功能整体验收及候选固定**：用户可见APP+独立Web管理操作、后端真实持久、权限与撤销、已知/未知失败、Android受控设备及必要质量门清晰可测。不以局部Widget或R0隔离测试代替整机功能完成。
3. **软件著作权登记材料准备**：在可追溯固定源码、产品版本及功能截图/说明与权属资料的基础上整理软件描述、操作手册和必要版本证据；登记材料准备不等于申请已提交或取得登记证书，具体申报材料以适用官方要求和权利主体确认。
4. **Owner批准范围内封闭内测**：明确测试人员、设备、账号、数据与许可、准入和停止机制；未具名授权前不公开招募真实用户或用TEST_ONLY身份宣称真实KYC/Push/RTC/法定删除受理。
5. **内测之后再评估生产服务器替换或升级**。现阶段保留旧阿里云目标、已有SSH/DB/备份元数据和本地PHP8.4/MariaDB/Linux Docker能力；不让新服务器采购或真实管理员迁移成为开发阻塞。

## G0b最新交付的正确证据状态

- Owner提供本机报告路径`D:/EliteSync/development/v2-cloud-r0-local-runtime-20261121/evidence/V2_CLOUD_R1_G0B_DECISION_REPORT_20261121.md`和摘要：独立上海Staging候选2vCPU/至少4GiB/40–60GiB，费用UNKNOWN；五月3份本地备份与远端声明元数据一致；下一SSH命令、只读哈希尚待批准；管理员来源优先现时旧MariaDB、历史五月备份备选；无新SSH/云写/管理员读取。
- 网页顾问尝试查找上述**具体报告原文**，当前会话无上传原件、该本机路径不可读取，查询固定GitHub开发/治理路径未找到该文件。因此**当前只能把上述内容标为OWNER_FORWARDED_CODEX_REPORT，不能写独立文件验收PASS**。不因这个缺口阻断新的功能工程；未来可由Codex将去敏报告在非main推送或由Owner直接上传供再验。

## 产品与安全不可被新优先级覆盖

- EliteSync的`Match ≠ Connection ≠ Messaging Consent ≠ Conversation ≠ Relationship`、Block覆盖当前读写、对象受众/原历史权限与AI解释不冒充事实等全部现行语义保持。
- 旧排盘A/B/C兼容、注册自动可信离线T0 P1仍Owner待决；不凭“功能要全”就恢复无依据自动排盘、缺时刻默认午时、绕过实名/关系/隐私权限。可完善独立手填、清晰说明、受控合成环境中的正向闭环。
- 工程自主开发限既定功能和安全隔离测试、修复；新增产品方向、真实用户/管理员数据读取、供应商/付费、生产迁移、main整合、公开发行、真实法律受理及不可逆删除仍另行授权。
- PC13项清理已经结束，白名单0；旧阿里云Nginx、LiveKit、MariaDB、Redis、备份、登录信息全部保留，不再把G0b远端补证、管理员真实迁移或独立服务器购买作为当前阶段必做项。

下一阶段使用[功能优先集中任务](../versions/v2/V2_FUNCTION_COMPLETION_TO_SOFTCOPYRIGHT_AND_CLOSED_BETA_CONSOLIDATED_BRIEF_20261121.md)，交由现有本地Codex自主推进、阶段性集中报告。
