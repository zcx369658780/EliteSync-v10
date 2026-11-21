# V2-CLOUD-R0｜原EliteSync本地Codex会话一次性启动指令

你是当前EliteSync V2唯一活动的本地工程执行会话。Owner最新决定：**PC清理正式停止；逐渐恢复到阿里云真实后端服务器（含已有管理员最小身份恢复），然后重做真实手机测试。** 顾问已设置可审计的安全阶段门，不是新一轮探索性咨询。

先从**当前治理分支固定HEAD（交接消息提供）**按需读取以下四处：
1. `docs/decisions/OWNER_V2_GRADUAL_ALIYUN_RESTORE_AND_ADMIN_ACCOUNT_RECOVERY_AUTHORIZATION_20261121.md`
2. `docs/versions/v2/V2_CLOUD_R0_GRADUAL_BACKEND_ADMIN_AND_PHONE_CONSOLIDATED_TASK_20261121.md`
3. `docs/workflow/ACTIVE_STATE.md`顶部CURRENT ENTRY，遇第一道分隔线即停。
4. `AGENTS.md`顶层约定（仅相关段落）；产品固定R1工程`585a8c21aeab103daac166338f881ef343c8af99`、最近清理文档`716e74d92c7b9e9a10f6dc474e8300a222f0357b`作为锚。

在合法干净隔离工程里连续执行**单一综合任务G0–G3**：云实例与旧业务只读核身；Linux PHP8.4/FPM+MariaDB10.11/锁定三盘依赖的可复现独立Staging准备和定向验证；旧管理员备份来源及schema最小映射与合成演练；条件满足后在阿里云隔离Staging上实施并用单台获准手机真实连云验证。所有已通过步骤自行继续，无需每一小项请求Owner或额外写大量文档。

核心不得误判：
- 历史阿里云云目标为上海轻量应用服务器，不是已证实ECS；历史IP、host-key及备份都不可当作今天的事实；先核控制台/实例身份和旧服务保护面。无可信SSH身份不执行远端命令。
- 现有本地Docker Linux daemon未运行；Composer `php ~8.4.0`，旧Dockerfile `php:8.5.3-fpm`不匹配；不得直接上传旧Docker运行环境声称PASS。三盘Python/Node/iztro/DE440s实际Linux运行身份必须封闭验证。
- 本机2026-05-08备份manifest/gzip只见格式/校验元数据，旧9.0-C GPG流程中断；历史其它加密备份线索分开验证。真实管理员的身份、来源、最低字段、归属和授权仍需单一敏感数据门；不得全库导入/恢复旧密码和token。V2管理权限需当前启用账户+admin角色+允许名单共同成立，管理入口必须正反例。
- 允许先完成**合成**管理员在隔离库与云端Staging的完整验证。如果真实个人信息来源或操作权限未明确，则真实恢复`BLOCKED_OWNER_DATA_GATE`，不能为了实现目标猜测、解密或赋权。
- 只允许完全独立的V2 staging，避免碰原旧业务Nginx、生产库与容器卷；不重置系统镜像、不购买资源或改公网防火墙；真实云端费用/生产写入/恢复账号门未满足时停对应操作，集中提出一个精确Owner决策包。环境成立时再逐步推进，不因一项被阻而中断其它安全的本地工程。
- 旧盘A/B/C、注册可信离线T0 P1仍未决，不改变fail-closed；PC清理白名单0，一切目录与旧数据库保留。

最后交付**一份中文综合工程报告**：云实例、Docker/运行身份、PHP8.4/MariaDB及三盘HTTP的正反回执；备份版本与管理员合规恢复情况（脱敏）；隔离云端Staging真实健康/迁移/回滚；真实手机云端HTTPS具名测试或NOT_RUN；未解决的旧失败、Owner集中待批门；固定非main提交和脱敏SHA证据。报告完成后停止在Owner集中验收，不自动合main、对外发布或将Staging升为生产。
