# EliteSync v10.1.5｜已响应Docker Linux引擎资格重核＋Laravel13/12批量迁移＋真实API/DB集中回归｜Owner综合接续任务

**状态：OWNER_REQUESTED_FRESH_CONTINUATION_AUTHORIZATION / ONE_NEW_TASK / MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / NO_DESKTOP_REACTIVATION / NO_MAIN_INTEGRATION**

日期：2026-10-30（Asia/Singapore）。正式仓库：`zcx369658780/EliteSync-v10`。

## 0. 本次授权边界和原STOP的不可恢复性

2026-10-30前一综合任务已按启动1/1失败安全停止，并向Astra交付候选`debe4a11d19f25179efef1d90d04e346980c2867`。随后Owner报告**等待21秒后对当前引擎进行只读重试**：Docker Desktop`4.97.0`、Engine`29.9.2`、`linux/amd64`、查询exit0，没有第二次启动引擎，也没有PHP/Composer/DB测试。Owner明确表示前任务已封存、不可用旧余额，并要求Astra冻结新的接续授权。Astra已对debe候选作有界独立审查，审查Commit`af29749f8850a89c88aed6ba5a80fedbc7e13e47`、审查Blob`5f077c38bb3216de30e9b7fa46cd202fd06bf799`，结论`DEBE4A11_BLOCKED_DOCKER_ACTIVATION_AND_SAFE_STOP_ACCEPTED_WITH_OBSERVATIONS`。这不是完整runtime通过。

**本任务为新授权、新task_id、新task-owned根、唯一attempt-0001、全新ledger和独立预算；绝不恢复前轮STOP、重启前轮root、挪用未消费次数或将前轮BLOCKED倒填PASS。** 仅授权先**只读复核当前已经响应的引擎**，满足全部门禁后在同一任务内真正迁移后端。现有Engine报告是`OWNER_REPORTED_POST_STOP`，尚不是Astra直接本机验证，也不是版本/许可/隔离合格。任务发布不等于Codex派发或运行，Owner仍手动派发。

新task_id：`V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030`。唯一新根basename：`v1015-running-docker-engine-laravel-batch-20261030`，attempt`attempt-0001`，持久原始ledger及封存回执；不得跨会话重建根或续旧计时。

## 1. 固定研发Authority与产品边界

- **唯一研发sole Parent：`debe4a11d19f25179efef1d90d04e346980c2867`**；Parent Root `5cc585d5344e9a8e00b7512863e3169f662ad52b`；apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services Tree `1b1100808cf275d881a6dd8dde9c0155a7fc2a32`。它仅添加受阻报告/工具链锁与Manifest，继承已核的静态预包；不是已合main。审查Commit、后继task/main文档Commit均不能作为研发Parent。
- 旧正式任务`docs/versions/v10.1.5/V10_1_5_EXISTING_DOCKER_LINUX_ACTIVATION_BATCH_LARAVEL_API_DB_E2E_TASK_20261030.md`，Blob`7bd4323e8f3f31a3404657b3eab6690e2710fc89`，已STOP。旧报告`docs/versions/v10.1.5/LINUX_EXISTING_DOCKER_ACTIVATION_LARAVEL_BATCH_API_DB_RESULT_20261030.md`，Blob`ec705096262efe6cc2a39a79d984dca787ce830d`；Manifest Blob`85ab2fe57428961e5cf2f499f3c10e1eec21c807`。Astra审查路径`astra/v10.1.5-debe4a11-docker-activation-blocked-review-20261030:docs/versions/v10.1.5/DEBE4A11_DOCKER_ACTIVATION_STOP_ASTRA_INDEPENDENT_REVIEW_20261030.md`，Blob`5f077c38bb3216de30e9b7fa46cd202fd06bf799`。
- 开工fresh读取live`main`、Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文/Blob、`docs/workflow/CURRENT_WORKFLOW.md` Blob`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结`docs/versions/v10.1.5/plan.md` Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`和原AC01–11及15场景。
- 签发前main`d8a66b8f69dc9252651754626ff6b3c940f9a3cb`、Root`f5a873c70d4024348e4e344bd067f96a5120b41f`。唯一产品main已正式接受并集成v10.1.4：apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`，services`0cb1f9d19659291a462488b3686fd0a07a6698ac`。后继文档推送使main HEAD变化，不改变两产品Tree。
- 永久保护旧18、两ACL树、122原证、五根、527 refs、3183 Seed，所有本地dirty/claims/ledger/旧预算/历史失败/事故；保留`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`，Windows API-set E_NOTIMPL不因Linux回归更改。

## 2. 资格门：已响应Docker只读重核，不再次激活共享引擎

1. 使用**已经运行的**Desktop/本地Docker Linux引擎，先仅执行受控、具名、只读的daemon/WSL/本机版本与权限核查；在任务独立、无凭据空context与指定**local Linux endpoint**下确认server版本`29.9.2`是否仍真实响应、platform`linux/amd64`、API/engine身份与正常退出码，排除remote context、TLS环境污染及指向生产。**本轮Docker Desktop再次启动、重启、修复、shutdown、WSL启动或重启配额均为0；发现未运行即STOP，不得为了通过资格自行启动**。
2. **必须调查两时点的版本来源冲突**而非简单称“已经升级”：旧停止报告Desktop`4.95.0.242831`和精确安装目录CLI`29.8.2`、当时server=null；Owner随后报告Desktop`4.97.0`与Engine`29.9.2`。CLI/Engine/GUI版本本来可能不同，但4.95与4.97 Desktop也不应未经证据合并。只读记录实际安装文件路径、签名/hash、进程启动时间、server和client独立版本、WSL关联、合法许可/现有用户账号状态及允许的更新历史；**不能推断Owner已授权更新、隐瞒自动更新或将另一来源/上下文的Engine冒作本机合格实例**。缺关键身份或不明权限即STOP。
3. 保持Owner之前确认的小企业免费许可及无受保护自动启动工作负载作为`OWNER_REPORTED`合同输入；仅核当前实际配置是否出现新EULA、登录/收费/功能限制和共享服务风险，不反复向Owner询问已决定事项。需要新许可接受、费用、UAC、全局配置、清理/更改Secrets Engine socket/ACL/服务、升级软件或触碰其他项目容器/volume时STOP，只给一次明确需要的变更/风险/回退清单。
4. 只读确认可用资源、引擎可稳定响应及本任务可创建单独隔离容器/专属端口的资格。前轮Secrets Engine的`engine.sock` rename失败保留历史事实，新响应**不代表已定位或修复根因**。没有第二次Docker/WSL host启动授权。
5. 通过资格门后无需等待Astra逐项微批准，直接在本任务预算内继续第3–5节。资格失败只产出一次BLOCKED集中候选，不重复Windows VC/DLL工作线。

## 3. 独立Linux工具链、来源和计量先行

- 目标：受支持Linux PHP **8.4**真实patch及扩展、官方稳定Composer **2.x**、MariaDB **10.11 LTS**（精确patch要实核）；Laravel **13 + PHP8.4**优先长期候选，真实兼容阻断可在**本任务内**回退Laravel **12 + PHP8.4**。不在此冻结Owner最终产品基线。Ubuntu 24.04兼容环境应实核；不能把发行版已注册或官方Debian/Alpine镜像称为Ubuntu24.04已经运行。
- 先实施有效task-owned/least-privilege OCI wrapper：可信镜像及Digest/平台/版本、只读Parent源码、任务私有可写源码暂存/vendor/Composer cache/数据库卷/日志、受限专属loopback端口/网络和UID，无privileged、host network、Docker socket mount或已有项目资源挂载。不修改宿主全局PHP/apt/Composer、镜像cache或Docker配置。独立新空MariaDB及合成账户，不触碰真实用户/生产/旧数据库；检查`APP_DB_CONNECTION`优先和全部`APP_DB_*`/`DB_*`/URL/socket/port，严禁连接已有3306或旧43349/43359及任何占用端口。
- **先完成实际可执行的供应计量**，方可拉镜像/Composer包：计入agent发起的所有响应体（含layer、redirect、失败/重试）和真实请求次数，独立不可变Digest及官方来源Hash；对每次成本执行前PREPARE+fsync，不能只数命令、按估计字节或用无核实“0”占位。若无合法受控代理/计量实现，动态有成本供给STOP，集中说明困难；禁止绕过透明计量直接pull/install。不得外传真实私密数据；真正镜像及Composer凭据LOCAL_ONLY。
- PHP/Composer/MariaDB/Redis/Nginx精确patch仅凭实际可信镜像/可执行结果冻结，Redis/Nginx按必要性而非默认扩软件种类。运行时对外网络最小化；业务服务不得出站到真实云/生产接口。

## 4. 统一Composer求解、批量后端兼容修复

- 以Parent`services/backend-laravel/composer.json` Blob`d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56`与旧`composer.lock` Blob`66327f584d3961c2b53391bb012047dda9cc9d23`作为原始输入。旧锁仍Laravel11.48.0，必须实际Composer solver重新生成content-hash/lock，再安装私有vendor；禁止手工伪造lock、ignore-platform-reqs、`config.platform`虚报扩展。继承既有13/12预包但它们只是solver INPUT。
- 先按官方Laravel13升级指南和实际包依赖尝试PHP8.4/Laravel13，审查Tinker/PHPUnit/Collision、Sanctum/Workerman/lunar-php及全部transitives。如果Laravel13真实求解或业务兼容经授权范围内修复仍无法成立，保留失败原证，在**同root/预算内**切Laravel12/PHP8.4回退；不能混合两版本lock/vendor。Composer scripts/plugins禁用，避免自动artisan/迁移/不受信运行。
- Codex可在本次一轮综合任务中自主修改Laravel后端必要composer/lock、bootstrap/provider、middleware/Sanctum/auth/session、队列/缓存/Workerman、Eloquent/upsert/事务、日期时区、通知/私有存储、测试，集中修普通失败。保持原F1相同消息键重试/异payload冲突、CN/MC/Block、旧token/媒体撤权、F3可信T0/refresh、F4通知最小披露以及Activity/Safety访问边界；Laravel13 session serialization`php`已在静态预包写入但真实cookie/旧session登录连续性**未运行**，这次须具名正负例验证。禁止削弱SQLite通用TestCase或把授权负例改成永久404通过。

## 5. 真实PHP→Laravel→MariaDB/API闭环

- 合格引擎与可信供给均成立后，实际执行PHP `-v/-m`、composer validate/solver/vendor、PHP lint、相关Laravel Feature/Unit，使用**本任务独占新空MariaDB 10.11**迁移/合成seed，执行真实回环HTTP→Laravel→DB并受控重启再读取，核原业务消息幂等、权限拒绝/合法访问、T0/refresh、通知、私有媒体及Session cookie连续性。记录真实退出码、stdout关键摘要、请求/行数/事务和数据库身份；无合格H264视频206 fixture则标NOT_RUN，不补造。
- 是**合成后端API/DB E2E**，不含Flutter、Gradle、G2、APK/ADB、真机、RTC/AEC、真实Push、物理15/30天和完整APP设备E2E；这些本轮均未获新许可，不能因后端通过关闭AC05/G2/整版接受。

## 6. 独立硬预算（不继承已STOP任务余额）

唯一新root/attempt-0001/持久ledger；logical和allocated分别≤**16GiB**；单调总窗口≤**240分钟**（14,400秒）。本任务**Docker Desktop/WSL主机激活、重启、升级、修复次数=0**；已有引擎只读资格核查不视作新的激活。可信镜像/依赖下载响应体≤**2GiB**，全部agent发起真实供应请求（含redirect、失败）≤**500次**；具名OCI镜像Digest≤**8**；Docker build≤**3**；真实Composer solver≤**3**，vendor install≤**2**；隔离服务完整启动≤**4组**；PHP CLI进程≤**120**；Feature/Unit≤**5批**；合成业务HTTP≤**240次**；MariaDB migration/seed各≤**2次**。所有失败、重试、超时消耗预算。任何成本动作执行前在原始账本写PREPARE+fsync，保持文件身份和单调时限、检测STOP/并发替换，计量不可证明则STOP。容器组内存建议≤4GiB，真实资源不足STOP。不得跨会话重建根/账本或把前轮激活配额1/1变为新可用额。

## 7. 不可变STOP与成果交付

- 禁止自动启动/重启Docker Desktop或WSL、重新安装/升级、UAC/注册表/全局服务/VM/安全策略/ACL/socket改写；禁止生产或真实数据、既有数据库/设备、费用/新许可、真实AI/Push供应商及敏感上传；禁止清理旧工作树、镜像、SQL/APK、证书/用户隐私原证、历史账本和失败。
- 运行资格/来源/许可/资源、网络计量、预算及独立数据库任何一项无法证明→集中BLOCKED报告并STOP，不得偷偷换成Windows DLL调查或接受mock。合规运行中普通兼容Bug允许Codex同任务自主修复测试。不可重启已STOP root，不自动创建下一任务。
- 唯一普通non-force研发候选sole Parent固定`debe4a11d19f25179efef1d90d04e346980c2867`，不可用Astra审查或本次main task发布Commit为Parent。除必要`services/backend-laravel/`源码、`tools/v1015/linux_backend/`新隔离runner及`docs/versions/v10.1.5/`任务报告外不改产品；不动apps。交付`docs/versions/v10.1.5/RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_API_DB_RESULT_20261030.md`与`docs/versions/v10.1.5/running_docker_engine_laravel_batch_api_db_manifest_20261030.json`，以及具名工具链锁、真实solver/lock/vendor回执、变更path/mode/Blob和预算/STOP账本摘要。若blocked，仍需原始失败LOCAL_ONLY及脱敏正式集中候选。
- 证据等级：`DIRECT_GITHUB_OBJECT`、`CODEX_REPORTED_LOCAL_TEST`、`OWNER_REPORTED_POST_STOP`、`LOCAL_ONLY_RAW`、`NOT_RUN`、`NOT_PROVEN`。候选提交后fresh核GitHub Commit、唯一Parent、Root、每条变更Blob/mode、完整apps/services Tree、main HEAD/Root及ACTIVE_STATE并STOP交Astra，不自行签FUNCTION_ACCEPTED、不合main。
- v10.1.5保持`PARTIAL_NOT_ACCEPTED`、AC01–11为10 PARTIAL/1 OPEN、AC05 RTC/AEC OPEN、G2_READY_FOR_POPEN_FALSE、REAL_PUSH_PROVIDER_PENDING、RTC_AEC_NOT_CLOSED、OS_ENFORCEMENT_NOT_PROVEN、V10.1.6_NOT_STARTED。即使Laravel13真实运行成功，也须Astra独立验收和Owner决定最终长期基线。

## 8. 参考信息

- 本仓两份旧正式任务与debe候选报告、Astra有界review为直接Authority，外部资料只用于版本/许可/兼容性确认。
- Laravel13官方升级 https://laravel.com/framework/docs/13.x/upgrade
- Laravel12官方升级 https://laravel.com/framework/docs/12.x/upgrade
- Composer https://getcomposer.org/download/
- Docker WSL2 https://docs.docker.com/desktop/features/wsl/
- PHP维护 https://www.php.net/supported-versions.php/
