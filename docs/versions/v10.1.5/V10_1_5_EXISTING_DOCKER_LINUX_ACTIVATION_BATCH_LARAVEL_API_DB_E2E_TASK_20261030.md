# EliteSync v10.1.5｜已有 Docker Desktop Linux 后端受控激活＋Laravel 13/12 批量迁移＋真实 API/DB E2E｜Owner 综合任务

**状态：OWNER_APPROVED_NEW_BOUNDED_EXISTING_DOCKER_ACTIVATION / ONE_CONSOLIDATED_TASK / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / NO_HOST_INSTALL / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-30（Asia/Singapore）。仓库：zcx369658780/EliteSync-v10。

## 0. 权限来源、任务身份与一次综合任务原则

Owner在Astra对前轮Linux受阻候选 7e9cdc6c 独立限定接受、明确提出下一步须另行授权启动已存在Docker Desktop WSL2后端以后，回复“好的我授权，请继续”。本授权明确覆盖**已安装Docker Desktop的用户会话受控激活、资格验证、在确认安全合法环境之后的任务私有Linux PHP/Composer/Laravel/MariaDB批量迁移和真实合成API/DB回归**。不要求把普通失败拆成连续微任务；本任务内解决版本/依赖/业务源码/运行问题，集中交付一个候选，Astra独立验收。Codex仍须Owner手动派发；Astra发布本文件不代表已派发、启动Docker或消耗新预算。

这是前轮STOP任务之后的**新授权、新task_id、新task-owned root、新attempt-0001、新独立ledger**，不恢复、复用、重置或补领前轮任何已STOP任务的余额。新task_id：V1015_EXISTING_DOCKER_LINUX_BATCH_MIGRATION_20261030；task root basename：v1015-existing-docker-linux-batch-20261030。根必须新建一次、归属独立、可追溯；不得再建第二根规避超额或因任务暂停重新领取时限。

## 1. 冻结Authority与源码来源

- 新研发**唯一sole Parent**：7e9cdc6cbcbd013964824626db52eaf56ce9cbfb；Parent Root：c72a09a6cd803d5cbe184830416a0802a6f8ed55；Parent apps Tree：8cd9b6df8e744c8fc9d4217412edce31795a318d；Parent services Tree：1b1100808cf275d881a6dd8dde9c0155a7fc2a32。它是前轮BLOCKED静态预包候选，不是已经通过产品整版验收的main。不得用Astra审查Commit a448e74bd554857def827738fd699c56df2c100d、任务新发布main或其后的文档Commit作为研发Parent。
- 前轮Astra正式审查：astra/v10.1.5-7e9cdc6c-linux-prepackage-independent-review-20261030:docs/versions/v10.1.5/7E9CDC6C_LINUX_PREPACKAGE_ASTRA_INDEPENDENT_REVIEW_20261030.md；Review Blob 4f1615d0f27f94cbaa011ea213b6544770ac3471。前轮报告 Blob 7338574d9914d58dc6dbae5a530bfec86d3397b7；Manifest Blob 6932aacaa1621dd47d636697a997bd308d4743ac。前轮任务 Blob 03c40a831ed37d8610c9a9aa2760c9a94e17269b，永久STOP。本轮要读其静态预包、矩阵/测试与需要完善的真实运行adapter，但**不得执行/修改前轮task根和账本**。
- 冻结功能目标：docs/versions/v10.1.5/plan.md（Blob 7d3466b3be67135dc641cfee7c7faef78937ba03），AC01–11及已有15场景；工作流 CURRENT_WORKFLOW.md（42ffd18810a3808c7a5852ec57e1daff5da6f9b4）与 TASK_DISPATCH_CLOSURE_PROTOCOL.md（0f62532a71fb9753811fafa9e03819a46422f4bf）。Codex开工fresh查 main/Root/ACTIVE_STATE、正式任务全文+Blob、上述固定研发Parent全部Tree和受保护原证身份；新的main文档HEAD不是研发Parent。
- 签发前main HEAD e46fe31ee9c16c4b84553f50a4d62cb5094a1322、Root 2d12cbcb3861c83af7a92ca53d66285cc0a71f97。唯一正式接受且集成的产品为v10.1.4；main apps 3468a3dd97da7accfda2539a0f8d8f68931a6110、services 0cb1f9d19659291a462488b3686fd0a07a6698ac。后继文档写入可能推进main，必须fresh复核，不反写旧快照。
- 固定历史事故/门禁：PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT、OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN、RESTRICTED_IDENTITY_GATE_BLOCKED、OS_ENFORCEMENT_NOT_PROVEN；Windows E_NOTIMPL及Native闭包未证明。不能因Linux通过而追认Windows原生通过。旧18、两ACL实验树、122原证、五保护根、527 refs、3183 Seed及全部历史ledger/claims/失败/dirty不动。

## 2. 第一关：已有Docker Desktop/WSL2有限激活、许可和资源

上一轮Codex只报告WSL 2.6.3.0、Ubuntu-24.04与docker-desktop已注册但Stopped；Docker CLI 29.3.0可见，而限定本地daemon pipe absent。**它不证明可用engine、Desktop安装版本、许可、Ubuntu release、架构、隔离权限，也不是必须重装。**

1. 在**不升级、不安装、不修改Windows功能/全局设置、不触碰他项目容器/volume**的前提下，先只读确认安装路径/签名/现有Desktop版本、真实Docker CLI context和daemon状态（避免继承remote/TLS/生产context）、WSL名单/状态、当前运行服务/auto-start风险、Windows与WSL资源余量；不读取他项目秘密或执行共享容器命令。已有可用合格本地Linux engine时不重新激活。
2. Owner本轮批准：若已有Docker Desktop Linux backend尚未运行，可**最多进行一次用户会话级的启动/激活尝试**，允许其正常启动已存在的docker-desktop WSL2后端；如确需从已注册Ubuntu-24.04中读取release/architecture，可在同一受控用户级范围启动该既有发行版一次，不安装其它distro。启动前记录正常后台服务与共享引擎影响；如果预检显示启动将明显自动恢复生产/其它受保护项目工作负载、修改全局配置或造成不可界定影响，STOP请求具名许可，不为了PASS强开。
3. **Docker Desktop用户许可不得替Owner新签署**：核验既存可用许可/合同和用途资格。官方许可个人/教育及符合条件小企业免费；大企业/政府/其它收费场景不自动合格。若出现首次条款接受、登录/付费订阅、账户授权或用途不明，STOP并向Owner说明具体条件，不自动勾选EULA、不登录他人账号、不购订阅。许可验证成功与启动成功分别记证据；不得用Docker CLI存在推断资格。
4. 若启动要求管理员UAC、服务新安装、Windows功能启用、Hyper-V模式改变、WSL update/install、Docker Desktop更新或全局VM配置，则立即STOP；不请求/提升权限，不替用户更改安全策略。正常Desktop内部已有服务的用户级启动≠允许修改其它服务。核对server版本、engine local endpoint、linux/amd64（或实际架构若非amd64须停下重评）、Linux kernel、后端、发行版release与可用资源。OCI引擎可用不要求PHP官方镜像用户态是Ubuntu；不得把Debian/Alpine冒称Ubuntu24.04。
5. 如用户层激活失败/资格无法成立，交付本任务的**一次集中BLOCKED报告**，保留真实失败、资源与安装/许可请求，不再回Windows DLL调查、不重复启动、不另建第二尝试。成功才进入下一节，并在同一任务的正式预算内继续。

## 3. 统一工具链与安全执行adapter（同任务内建设并运行）

- 目标：Linux PHP 8.4当前受支持维护patch、Composer官方稳定2.x、MariaDB10.11 LTS（既有可合法用10.11.19才定该patch），Laravel13/PHP8.4优先，Laravel12/PHP8.4为**真实依赖/源码兼容阻断后同任务回退**。Redis/Nginx按实际需用具名引入，不为升级而升级。PHP8.5只作可选静态副剖面，不消耗本任务预算做独立全套运行。
- 锁定实际供应商、镜像不可变Digest、平台、PHP版本和扩展、Composer版本/PHAR hash、DB版本、架构、资源和许可；只使用可信官方/发布方来源及经过验证的版本。镜像Digest数、请求数、下载字节必须**真正有受控入口/响应体核算与事前PREPARE+fsync**（包括pull layer/redirect、Composer metadata、package dist、失败/重试），不得靠Docker命令次数或假代理声明满足网络预算。若无法以当前环境/权限合法实现可验证的供应计数器，则**停止所有有成本供给/动态阶段**，给出一次综合技术阻断，不绕过门禁；只读已缓存内容不能等同受信新供给。
- 新task私有代码写入/Composer home/cache/vendor、数据卷、log、网络/localhost端口和容器UID，最小权限；禁止privileged、host network、Docker socket注入容器、挂载其它项目目录/卷、共享数据库、写Global Composer cache、清Docker全局镜像/缓存、触碰历史固定43349/43359。只读源输入、一次性有界映射到可写任务目录。服务应用独立空库，连接精确固定APP_DB_CONNECTION及所有APP_DB/DB_*选择器、host/URL/socket/database，杜绝3306/生产/他版数据库回退。独立专用端口先查占用，固定并记录；若无法自证隔离STOP。
- 真实业务运行期间禁止公网任意外传。原始凭据、数据库、vendor、raw运行日志、镜像auth、绝对用户敏感路径、证件/私聊/令牌全部LOCAL_ONLY；公开仓库只交必要安全源码、真实新composer.lock、Digest/版本的脱敏记录、报告及Manifest。

## 4. 在同一任务内完成真实Composer与Laravel批量迁移

1. 从sole Parent精确导入backend、原测试和本次静态预包。保留此前parent composer.json Blob d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56、composer.lock Blob 66327f584d3961c2b53391bb012047dda9cc9d（原锁Laravel11.48.0）作可核输入。两份既有profile为solver INPUT，不是已升级代码/新锁；不得手造lock或改content-hash欺骗。
2. 在真实PHP8.4及扩展平台先尝试Laravel13；官方13.x升级指南为高优先级，核全部直接/传递依赖及Tinker3/PHPUnit12、Sanctum4、Workerman5、lunar-php、Collision及本仓实际包。执行真实composer validate/solver并在合规空间私装vendor；scripts/plugins全禁，不得ignore-platform-reqs、不伪造config.platform、不运行不受信插件/自动artisan。若确实无法在预算内解决目标13包/框架兼容，记录具名版本约束与实际solver日志，转Laravel12/PHP8.4；同root/attempt内回退，不混用13/12 lock/vendor。
3. 统一迁移Laravel必要兼容面：bootstrap/service provider/config、auth/middleware/Sanctum/session、cache/Redis prefix、queue/Workerman、Eloquent/MySQL upsert/transaction/UTC/date、路由、notifications、private-media storage、tests/fixtures。优先保留既有业务同意与安全语义，不为框架升级重新设计产品。若真实Laravel13变动与静态文档不同，以官方指南+可运行证据决定，记录偏离。
4. 关键回归：F1消息相同幂等键/异payload冲突、CN/MC/Block撤权、旧JWT/token/媒体权限、F3登录成功T0与refresh不延长、F4通知最小披露及消息/状态/活动/Safety否权；Session原PHP序列化兼容固定和登录cookie/旧会话正负例必须真实运行；不可用合成测试替代真实授权路径。真实Bug在冻结范围内自主修改源码和测试。不要将历史旧PHP/Windows原生资格修改为PASS。

## 5. 真实PHP→Laravel→独立MariaDB及HTTP合同

- 至少实际运行 php -v/-m、Composer validate、PHP lint、相关Feature/Unit；使用明确受控的**新空MariaDB10.11实例**和虚构账户运行迁移/必要seed、后端回环HTTP，再次读取/受控重启，记录服务进程退出、数据库行数/事务效果、HTTP status和认证正反例。检查旧测试保护（包括SQLite通用TestCase防护）不被删除、production数据库隔离不被绕开。
- 具名测试重点：消息幂等及冲突409、已授权正向发送/回读、MC/CN/Block否权、旧token禁止、通知偏好隐私、可信T0刷新/跨设备会话、私有附件授权/撤权；无合规视频fixture时206等具名标NOT_RUN。Laravel13/12多分支可以有限验证，但只能一个被最终选定的lock/vendor和后端候选。
- 本轮**只验证后端合成HTTP→Laravel→DB**，不是Flutter/Android、APK、真机RTC/AEC、系统Push、物理15/30天或完整APP→API→DB设备E2E。凡设备/外部供应商/物理时间缺口保留NOT_RUN，不能闭AC05、G2或10.1.5整版。

## 6. 本任务独立、总量硬预算（所有失败/超时均计入）

- 单一新task-owned root / attempt-0001 / 单调持久ledger；从首次建立和PREPARE即计时。logical ≤16GiB、allocated ≤16GiB、单调总窗口 ≤240分钟（14400秒）。任务内服务组内存建议≤4GiB，资源不足及时STOP。即使跨会话也不能重建根/重置时间/回收预算。
- 已存在Docker Desktop用户级激活尝试最多**1次**；已注册Ubuntu发行版为release/architecture探针所需用户级启动最多**1次**。资格失败即STOP动态；不得为第二次启动创建新的任务内attempt。前轮6/6 inventory与STOP完全不重用本轮次数。
- 本轮供应下载响应体 ≤2GiB；真实供应请求 ≤500（包括失败、redirect、镜像层、Composer metadata/dist）；受信OCI镜像Digest ≤8；Docker build ≤3；Composer真实solver ≤3（Laravel13优先、必要时Laravel12回退）；vendor install ≤2；任务专属服务完整启动 ≤4组；PHP CLI启动 ≤120；Laravel Feature/Unit ≤5批；回环业务HTTP ≤240；合成DB migration ≤2、seed ≤2。失败、重试、超时同样消耗；不得用旧余额增加额度。
- 所有预算消耗**执行前**须写同一个原始持久ledger的PREPARE+fsync，随后计入实际状态、结果、退出码/证据Hash；并发锁和重启/异常恢复不得跨root。无可审计计量则停止相应有成本操作，不伪造0或无限重试。旧任务及历史G/APK等预算保持封存。

## 7. 永久禁止及STOP边界

严禁：重新安装或升级Docker/WSL/Hyper-V/Windows/Linux宿主全局包、改注册表/服务/PATH/系统证书/WSL全局VM配置、UAC提权、自动同意新EULA/支付或接第三方真实身份/Push、生产SSH写入/生产DB、真实用户资料、清理或修改旧资源/ledger/dirty。严禁Flutter/Dart、Gradle/G2、APK/ADB/真机、RTC/AEC、真实Push、物理15/30天、主产品代码合并。任何新费用、敏感外传、不可逆动作、global security、生产/用户数据请求应STOP；Owner作新的具名决定才可继续。

任一必要隔离器资格、许可证、官方供给完整性或预算计量不足，走一次BLOCKED安全出口；如真实API/DB运行失败但在已批准预算内可修复则Codex自主批量修复与集中重测；无法修复则准确PARTIAL/CHANGES_REQUIRED，保留原始失败和未执行项。不能靠Mock/静态自测创造PASS。

## 8. 唯一交付、候选对象和验收

- 在普通**non-force**研发分支提交**一份唯一sole Parent为7e9cdc6cbcbd013964824626db52eaf56ce9cbfb的候选**；从Parent新增/调整实际必要后端composer.json/真实composer.lock、源/测试、tools/v1015/linux_backend/的新task adapter/配置与文档。不得把历史Astra review/当前main文档路径合进研发候选。不修改apps、不改其它项目、不清理旧文件。
- 必交文件：docs/versions/v10.1.5/LINUX_EXISTING_DOCKER_ACTIVATION_LARAVEL_BATCH_API_DB_RESULT_20261030.md；docs/versions/v10.1.5/linux_existing_docker_activation_laravel_batch_api_db_manifest_20261030.json。另交具名工具链版本/供应Digest锁、Composer解算/包依赖来源、工具/测试及安全回执；如BLOCKED同样交报告、清单和阻断需求，不留半成品假成功。
- Manifest按变更path/mode/Blob与固定Parent逐项标识，包含候选Commit/Root/apps/services、版本、预算消耗/剩余、最终限制、真实执行/未执行证据等级：DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN / NOT_PROVEN。公开产物不能含LOCAL_ONLY、token、证书、敏感路径、真实数据库和完整私有日志。
- 若满足真实后端测试，最高仅可记 LINUX_LARAVEL13_OR12_SYNTHETIC_API_DB_CANDIDATE_AWAITING_ASTRA_REVIEW；若阻断则 BLOCKED_EXISTING_DOCKER_ACTIVATION_OR_RUNTIME_GATE，并逐项陈述。Codex不得自签V10.1.5_FUNCTION_ACCEPTED。候选完成后fresh GitHub回读Commit唯一Parent、Root、全部path/mode/Blob及完整apps/services Tree和当前main；**STOP等待Astra独立复核**，Laravel13作为长期基线仍待Owner最终选择。
- main仍只接受v10.1.4；v10.1.5仍10 PARTIAL/1 OPEN、AC05 OPEN、PRODUCT_MAIN_NOT_INTEGRATED、G2_READY_FOR_POPEN_FALSE、REAL_PUSH_PROVIDER_PENDING、RTC_AEC_NOT_CLOSED、OS_ENFORCEMENT_NOT_PROVEN、V10.1.6_NOT_STARTED。不得因本任务改变它们。

## 9. 官方参考（按实际运行版本和当日证据核查）

- Laravel13升级：https://laravel.com/framework/docs/13.x/upgrade
- Laravel12升级：https://laravel.com/framework/docs/12.x/upgrade
- PHP维护：https://www.php.net/supported-versions.php/
- Composer官方：https://getcomposer.org/download/
- Docker Desktop WSL2：https://docs.docker.com/desktop/features/wsl/
- Docker Desktop Windows：https://docs.docker.com/desktop/setup/install/windows-install/
- Docker许可：https://docs.docker.com/subscription-billing/desktop-license/
- Ubuntu24.04：https://documentation.ubuntu.com/release-notes/24.04/
