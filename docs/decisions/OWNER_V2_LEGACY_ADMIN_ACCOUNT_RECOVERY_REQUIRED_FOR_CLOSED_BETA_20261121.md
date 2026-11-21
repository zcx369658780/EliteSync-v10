# Owner决定｜旧管理员账号恢复是V2封闭内测的强制准备门

日期：2026-11-21（Asia/Singapore）。状态：**`OWNER_LEGACY_ADMIN_IDENTITY_CONTINUITY_REQUIRED_BEFORE_CLOSED_BETA / NO_RE_REGISTER_EXPECTED / SHARED_REMOTE_V2_ACCESS_REQUIRED_FOR_OUT_OF_TOWN_COLLEAGUES / REAL_DATA_EXTRACTION_AND_CLOUD_WRITE_GATED / PRODUCTION_NO_GO`**。

## Owner最新明确决定

Owner同意“把阿里云旧管理员恢复列为内测准备阶段的明确任务”，并说明：“我的同事测试APP就是在外地使用旧的管理员账号登录（如果不恢复的话他们还要费劲去重新注册）。”

本决定将旧管理员恢复从一般后续优化提升为**封闭内测准入前必须完成的工作**。目标是让Owner及经确认的同事继续使用既有管理员账号身份/登录标识进入V2测试环境，不必在V2通过公开注册流程重新创建另一套账号。

## 必须达成的产品结果

1. 仅恢复Owner明确指定、且其实际持有人仍确认使用的既有管理员账号；不是导入旧库中所有role=admin用户。
2. 尽可能保留原账号的登录标识（现行V2以手机号作为唯一登录字段）；具体号码只在私有受控渠道核对，绝不写入公开GitHub或普通日志。
3. V2中分配新的user ID，并保留旧ID到新ID的私有可审计映射。不得直接复用旧主键或与现有V2账号冲突。
4. 恢复账号的admin角色必须同时满足V2实际门禁：账号未禁用、role=admin、手机号在V2服务器端`ADMIN_PHONES`受控允许名单中。名单通过服务器私有环境/Secret配置，绝不写入源码、GitHub或截图。
5. 不走普通公开注册流程；由受控恢复CLI/迁移工具完成，账号持有人使用V2新发的一次性激活/重设凭据登录。**旧密码哈希、旧访问/刷新Token、Sanctum token、Web session、MFA秘密和API key不迁移**。保留登录标识/账号连续性，不承诺继续使用旧密码。
6. 同事从外地通过同一个受限V2 HTTPS测试入口登录。每位账号持有人可登录APP；被明确授权的管理员可登录独立Web后台。测试期间仅授予明确所需管理权限并审计。

## 对此前Owner决定的补充解释

- 2026-11-21先完成既定功能，再准备软著资料、封闭内测，服务器更换可在内测后考虑的优先级仍然有效。
- 现在明确：**旧管理员恢复是封闭内测准备阶段的强制门**，而不是要求当前立即更换服务器。内测准备时应优先评估复用现有上海阿里云服务器部署受限V2测试环境；是否能安全复用须由资源容量、旧业务隔离、备份和回滚证明决定。若不能，提供额外资源及预算选择，未经Owner批准不购买。
- 当前1011805本地USB reverse不是远程共享环境。为同事异地测试，封闭内测准备阶段必须有稳定、受限、可达的V2 HTTPS后端；不能把本机127.0.0.1/ADB reverse称为共享服务。
- 本决定确认恢复目标与Beta门禁，不等于授权任意解密/导出旧数据库个人信息、直接写入阿里云生产库、创建云资源、开放公网、支付费用或迁移全库。

## 真实数据操作仍需具名数据门

此前Owner授权文件`OWNER_V2_GRADUAL_ALIYUN_RESTORE_AND_ADMIN_ACCOUNT_RECOVERY_AUTHORIZATION_20261121.md`规定：真实个人信息读取/解密/迁移须具名来源、最小字段、合法持有人/操作者和隔离恢复目标，写入前交Owner集中审阅。该保护仍然有效。

因此：
- 可以立即完成源码审计、schema映射、只读元数据盘点计划、合成账号迁移演练、恢复CLI和强制密码重设机制、受限V2远程环境方案。
- 真实旧管理员记录的提取/解密/复制、真实V2库写入、阿里云部署和公网入口变更，必须在一个集中决策包中列明来源、被选账号（公开文档使用不可逆代号）、字段、目标、操作者、成本、网络范围和回滚，经Owner具名确认后才执行。
- 若真实旧记录来源或账号持有人无法确认，则该账号保持`BLOCKED`，不能通过把数据库中任意admin标记复制到V2来冒充恢复；封闭内测不得以“管理员已恢复”对外宣称。

## 固定技术合同

源码抽查固定于P0.2产品提交`362abd618a1f670e313b365b60b5dfe1f6ab71b8`：
- `AdminAccess::allows()`要求$user存在、未disabled、`isAdminRole()`且手机号在`config('app.admin_phones')`。
- `config/app.php`由私有`ADMIN_PHONES`环境变量生成名单。
- Web管理员登录按手机号查询用户，校验密码，再调用`AdminAccess`；成功后轮换Web session ID并写入管理员会话审计；登录有速率限制，退出撤销会话并轮换CSRF token。
- `users.phone`为唯一登录字段，密码字段使用Laravel hashed cast。
- 以上只是当前源码合同，不证明旧数据库实际有哪些管理员、哪些仍有效或哪些同事仍控制原手机号。

详细实施见[Beta共享后端与旧管理员恢复综合任务书](../versions/v2/V2_BETA_PREP_SHARED_BACKEND_AND_LEGACY_ADMIN_RECOVERY_CONSOLIDATED_TASK_20261121.md)。

**本决定不启动封闭内测；仅将真实旧管理员身份连续性设为其强制准入条件。**
