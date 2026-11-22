# EliteSync V2｜ADMIN-TEST-01 旧账号个人资料恢复与格式对齐任务

日期：2026-11-22（中国标准时间）

## 1. Owner授权与唯一范围

Owner明确要求：将自己原 EliteSync 账号中已填写、但在 V2 登录后未恢复的昵称、生日等个人资料，从旧数据库恢复到当前阿里云 V2 Staging 后端。

本任务授权范围严格限定为唯一已恢复账号：

- 候选：`ADMIN-TEST-01`
- 当前V2内部账号代号：`V2-ADMIN-01`
- V2目标数据库：`elitesync_v2_beta_staging`
- MariaDB：10.11
- `server_id=2621124`
- 当前云端业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`
- 当前开发分支：`codex/v2-function-completion-20261121`
- 当前治理交付基线：`0418a13e66e2d8fe03024e371a38d51673b2de22`

本任务只恢复Owner本人账号的用户自填个人资料。不得扩展到其他旧管理员、普通用户、测试用户或全库批量迁移。

Owner已经授权对上述唯一账号执行格式核对、dry-run，以及对无歧义且有准确目标字段的个人资料进行实际恢复。若字段语义、来源、格式或跨库优先级存在歧义，只隔离该字段并提交Owner决策，不猜测、不覆盖。

## 2. 首读和身份绑定

先核对本地工程根、remote、分支、HEAD、工作区/index；遵守AGENTS与当前工作流。GitHub本任务单仅为治理记录，不替代本地工作树。

读取：
- 最新 V2 ADMIN-TEST-01 恢复与账号盘点报告；
- V2云端旧栈退役/备份报告；
- 固定业务源码中的 `legacy_admin_mappings`、`legacy_admin_batches`、`legacy_admin_restore_audits`；
- 当前 `User`、`ProfileController`、`AuthController`、`UserAstroProfile`、`UserNatalProfile` 模型与实际迁移；
- 旧数据库私有归档清单、来源元数据及相关配置归档。

唯一旧账号映射必须从当前V2 `legacy_admin_mappings` 中读取，并同时核对：
- candidate = `ADMIN-TEST-01`
- state = `active`
- batch_id 与 source_system
- legacy_user_id
- user_id（当前V2目标用户）
- 关联batch的 source_system / snapshot / target / manifest_hash
- 关联审计

必须先证明该映射唯一且完整，再使用其 `source_system + legacy_user_id` 读取旧资料。不得仅凭手机号、姓名、昵称、生日、模糊匹配或相似字段查找并合并账号。不得新建第二个V2用户，不得修改现有映射。

## 3. 旧来源只读与跨库冲突

旧数据库及备份必须只读访问。所有旧库、旧媒体、旧配置、ADMIN_PHONES来源、APP_KEY归档、V2数据库/媒体备份、候选清单、Manifest、签名、审计与历史APK继续保留，禁止删除、覆盖、清理或重命名。

如有多个旧数据库/备份来源：
1. 首先以V2已批准mapping记录中的 `source_system` 和 `legacy_user_id` 锁定主来源。
2. 同一账号在同一来源内的重复字段，按已被Owner接受的同账号规则和当前源码证据核对。
3. 不得把已知的同库字段优先级扩展为“两个旧数据库之间”的优先级。
4. 若另一旧库也出现同一账号或相似账号，且字段值冲突，单独记录来源和冲突状态；不拼接、不覆盖、不自行选新旧库优先级。
5. 若唯一mapping指向的旧来源缺失、记录不唯一或身份不匹配，停止该账号全部数据写入并报告。

任何源值不得输出到普通终端、聊天、GitHub、报告、测试日志或命令参数。真实资料只在服务器root私有目录和受控进程内处理，目录0700、文件0600。

## 4. 字段发现与格式映射

先生成私有字段清单，列出旧来源表/列、目标表/列、源类型、目标类型、语义、格式转换、空值策略、冲突、是否可自动恢复。去敏报告只列字段名、状态和数量，不列实际值。

以当前V2 API和实际数据库schema为准，不按旧字段名猜目标。

重点核对以下字段：

| 资料 | 当前V2候选目标 | 强制规则 |
|---|---|---|
| 昵称/显示称谓 | 当前 `ProfileController::saveNickname` 写入的 `users.name` | 只允许从旧库中语义明确的显式昵称/显示名恢复。旧 `users.name` 若可能是实名/姓名，不能自动等同昵称；需核对旧端字段标签、写入API和页面语义。若有独立nickname和name且不同，保留冲突，不静默覆盖。 |
| 生日 | `users.birthday` | 目标为DATE；仅接受明确的公历日期并严格转换为 `Y-m-d`。不得把时间戳按服务器时区直接截取；不得从生肖/年龄反推。无效、模糊或农历/公历语义不清时隔离。 |
| 性别 | `users.gender` | 仅按旧字段的明确枚举语义映射到当前允许值；未知、空值或语义不等价时不猜。 |
| 当前城市 | `users.city` | 这是当前居住/展示城市，不等于出生地点。核对长度、编码和语义。 |
| 关系目标 | `users.relationship_goal` | 只映射到当前API明确允许的枚举；同义词必须有明确映射表和测试，不得随意转写。 |
| 出生时间 | 核对实际存在的 `users.private_birth_time` 或当前模型指定私有字段 | 目标格式如 `HH:mm` 时必须严格验证；不得因时区或日期时间转换改变钟表时间。若旧值带时区/秒/未知精度，先记录并隔离。 |
| 出生地点 | 优先核对 `users.private_birth_place` | 同一旧账号内若同时存在 `users.private_birth_place` 与 `user_astro_profiles.birth_place`，按既有同账号规则优先前者、缺失才回退后者，并保留冲突标记。此规则不得扩展到跨旧数据库。 |
| 出生经纬度 | `users.private_birth_lat` / `users.private_birth_lng` | 验证纬度[-90,90]、经度[-180,180]、DECIMAL精度与成对关系；合法0值必须保留，不能当空值。 |
| 其他用户自填字段 | 逐字段核对当前V2 API/模型/迁移 | 只有语义、受众、数据类型和目标字段完全一致时才列入自动恢复；否则列为待定。 |

当前V2模型/接口已知事实仅作为起点，必须对照实际云端schema再次核实：
- `users.birthday` 为date；
- `users.gender`、`city`、`relationship_goal` 有长度/枚举约束；
- 当前个人资料昵称保存接口使用 `users.name`；
- 出生输入由私有字段承载；
- `user_astro_profiles`、`user_natal_profiles` 是独立资料/计算上下文。

### 4.1 不自动迁移的字段

除非有独立的Owner授权及精确契约，不自动恢复：
- password、旧密码哈希、明文密码、remember token、API token、Sanctum token、设备会话、refresh token；
- phone/email登录标识；
- role、admin权限、disabled、account_status、verify/实名状态、审核/风控字段；
- admin映射、恢复Manifest、激活哈希及审计身份；
- social关系、Connection、消息同意、Conversation、私信、Block、Match、通知；
- 媒体文件、头像、私有对象存储key及media_asset_id（媒体恢复需单独核对对象存储和ID映射）；
- 由生日/出生地/时间计算出的生肖、星座、八字、紫微、星盘、真太阳时、大运、流年、评分和旧缓存；
- 旧数据库中的派生JSON、历史计算结果、展示快照或未经确认的Showcase内容。

生日等原始输入恢复后，不得自动将旧派生结果标记为当前有效。若需重算，先按当前引擎和已有计算合同另行安排。

### 4.2 加密与格式转换

- 检查旧字段是否为Laravel encrypted cast、应用层密文、JSON字符串、序列化内容或普通文本。
- 若需旧APP_KEY解密，只允许在root私有运行环境中内存解密；不复制旧APP_KEY到V2，不写入GitHub/日志。
- 若V2目标字段要求加密，必须使用当前V2 APP_KEY重新加密，绝不把旧密文直接写进新密钥环境。
- JSON只接受可解析且结构满足当前schema的对象/数组；不得双重编码、静默丢字段或将对象强转字符串。
- UTF-8、长度、枚举、日期、时间、坐标精度均必须逐字段验证。
- 任何有损、猜测、时区不确定、字符截断或无法证明的转换都标记 `CONFLICT/UNSUPPORTED_FORMAT`，不得写入。

## 5. 目标库写入保护

目标只允许当前已存在的V2用户行，不创建用户、不改用户ID、不重新执行管理员恢复。

写入前：
1. 只读核对目标实例、Compose项目、`APP_ENV=staging`、HTTPS origin、数据库schema、MariaDB版本、server_id、CURRENT_USER、PDO读写连接。
2. 确认目标仍为 `elitesync_v2_beta_staging / server_id=2621124`。
3. 生成V2目标数据库可恢复备份，校验备份文件SHA-256及恢复演练证据；旧备份全部保留。
4. 对目标账号资料行生成私有前态快照和SHA-256。
5. 核对当前目标字段值。若目标字段非空且与旧值不同，默认保留V2当前值并标记冲突；不得用旧资料覆盖Owner在V2登录后新填写的值。
6. 若目标字段为空且源字段唯一、语义明确、格式验证通过，则列为可恢复字段。

### 5.1 Dry-run

先运行私有dry-run，至少输出：
- 唯一mapping核验状态；
- source_system/legacy_user_id与target user_id是否唯一匹配（仅私有原证保存ID）；
- 每个字段的 `MATCH / READY / ALREADY_EQUAL / SOURCE_MISSING / TARGET_CONFLICT / SEMANTIC_UNKNOWN / INVALID_FORMAT / DECRYPT_FAILED / UNSUPPORTED_TARGET`；
- 计划更新字段数、跳过字段数、冲突字段数；
- 目标备份和前态快照摘要。

dry-run不得输出真实值、手机号、生日、地点、经纬度、昵称、密文、哈希或密钥。

只有身份唯一、目标身份正确、备份可恢复、待写字段全部通过语义/格式校验且没有目标值冲突时，才允许对这些字段apply。冲突字段单独跳过，不阻止无冲突字段恢复。

### 5.2 Apply

- 使用事务与目标用户行锁。
- 更新前再次核对目标字段仍为空或与dry-run时一致，防止并发覆盖。
- 仅更新已列入READY且Owner已授权的资料白名单。
- 不改 `password`、`phone`、`email`、`role`、`disabled`、`account_status`、`realname_verified`、设备会话、token、恢复映射或任何权限字段。
- 记录字段级审计：source_system、源表列、目标表列、转换规则版本、结果状态、源值指纹/哈希、执行者和UTC时间；审计不得存储明文资料。
- 可使用现有 `legacy_admin_restore_audits` 的关联mapping记录 `profile_restore` 动作，或使用等价root私有审计文件；不得为审计创建包含明文资料的公开表。
- 事务提交后只读回验目标字段与API投影。

若事务中途失败，整组写入回滚；保留失败证据，不删除任何备份。若只有个别字段格式不支持，允许其余独立字段恢复，报告逐字段状态。

## 6. 验证

在不公开真实资料的前提下验证：
1. V2数据库中ADMIN-TEST-01对应用户行仍唯一、active、role=admin。
2. 原有登录凭据/新密码仍有效，不重置、不回显。
3. `GET /api/v1/profile/basic` 返回已恢复的本人资料字段，日期、时间、枚举、地点和坐标格式符合当前API。
4. Flutter现有资料页面使用当前mapper读取正确，不把name/昵称、city/出生地点、出生时间/时区混淆。
5. 重启V2应用容器后资料仍能读回。
6. Web/APP登录会话不被本次资料恢复撤销。
7. 其他旧来源映射数量保持0，不触碰其他账号。
8. 不将旧派生星盘/八字结果伪装为当前引擎计算结果。

真实资料只可由Owner本人在APP/Web界面核对。Codex不应把资料值写进验收报告或截图；需要截图时先遮蔽所有个人信息。

## 7. 交付与停点

提交中文报告：
`V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_REPORT_20261122.md`

附脱敏字段映射矩阵、dry-run/apply回执、前后SHA-256、备份恢复验证、API/APP回读结果和逐字段PASS/CONFLICT/NOT_RUN。

报告必须区分：
- 旧来源读取证据；
- 格式映射与语义核对；
- dry-run；
- 实际apply；
- API/APP读回；
- 未恢复字段及原因。

不得将个人资料值、手机号、生日、出生地点、经纬度、旧密码哈希、APP_KEY、token、密文或数据库导出提交GitHub。

完成后同步原非main开发分支并等待网页GPT集中复验。所有旧备份和证据永久保留；不得合main、不得更改公网HTTPS/WSS、不得宣布封闭内测或生产GO。
