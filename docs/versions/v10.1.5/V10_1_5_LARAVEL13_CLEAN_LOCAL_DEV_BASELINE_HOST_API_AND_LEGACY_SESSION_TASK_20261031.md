# EliteSync v10.1.5｜已接受Laravel13/PHP8.4 main → 新干净本地开发入口＋宿主回环API＋旧session有界兼容验证｜Codex唯一综合任务

**状态：OWNER_APPROVED_NEW_CLEAN_LOCAL_L13_DEV_ENTRY / HOST_LOOPBACK_API_VERIFICATION / SYNTHETIC_L11_TO_L13_SESSION_RISK_CLASSIFICATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / NO_OLD_DEFAULT_SWITCH / NO_DELETION / NO_PRODUCTION / NO_V1015_FUNCTION_ACCEPTANCE**

签发：2026-10-31，Asia/Singapore。仓库：`zcx369658780/EliteSync-v10`。本任务是**一次冻结、一个新任务根、一次集中候选、Astra独立复核**，范围内普通Laravel13/PHP8.4兼容/网络调试由Codex自主修复，但不得重启已STOP旧任务、删除旧版本、改变系统全局设置或偷渡未接受业务改动。

## 0. Owner的明确授权与目标

Owner在Astra确认`LARAVEL13_PHP84_DEVELOPMENT_FRAMEWORK_MAIN_INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`之后，对建议“把已接受的GitHub Laravel13开发基线接续到一个新的、干净的本地开发入口，保留现有Laravel11目录和备份，同时核验宿主API连通性及旧会话兼容边界，再继续v10.1.5未完成的功能”回复“可以我同意，请继续”。

因此批准**仅在新隔离本地开发目录**：获取已接受main的精确代码、配置PHP8.4/Composer2 vendor、构建具名可再启动的本地开发入口，使用现成已合规的Docker Engine运行任务自有容器与全新**虚构开发数据库**，做Windows宿主`127.0.0.1`回环API验证，评估真实旧Laravel11二进制产生的**合成**session/Cookie对Laravel13的兼容边界，留下自用开发入口及回滚资料；完工关停任务专属服务，除非正式任务有明确需要的稳定**手动启动**脚本，不设置自启动。

**不批准把旧本地Laravel11工作树变成Laravel13、不修改现有默认开发入口/全局PATH/Windows策略、不覆盖旧vendor/旧数据库、不删11,066项备份或旧版、不恢复真实用户session/生产数据、不开放公网或真实第三方费用、不宣布v10.1.5整体FUNCTION_ACCEPTED或G2放行**。

本任务发布到GitHub并不等于Codex已派发或执行。Owner须亲自复制准确任务Blob和下方启动Prompt，Codex再开始；Astra不代发本地Codex。

## 1. 冻结GitHub与产品Authority

- 签发前实时main `30f652c48d266c7df35a208eb5c456cd2ad4f26b`，Root `d4bcaadd5b98a4018570887319bc27ee8db883f2`。**已独立接受的当前产品双Tree**：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `049a8676cc90b3b830e32a524c172720e800fa37`。此任务发布和ACTIVE_STATE更新将推进main纯文档Commit；Codex开工必须fresh读最新main HEAD/Root/ACTIVE_STATE并核产品双Tree仍相同。不得reset到签发前main SHA、也不得用审查分支当Parent。
- 正式已验收框架集成源码Commit `7e1e107ca0faed840e1ce06418694e3590e3b3ae`、Root `e467619683d20582735bb2c28ab806bcd2b0be2f`，集成后文档Commit `b101a8f8d955a624d34a98ce340a97abb576d0ca`，Astra独立Review Commit `71afd7e2da6d1ad56bb53664ec347fe0aa5364ba`，Review Blob `542a34926fddf2e53917a1e362ebded8e8dc43ce`，裁决`LARAVEL13_PHP84_DEVELOPMENT_FRAMEWORK_MAIN_INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`。
- 当前main composer.json Blob `130793decf84ff8ab93faa0300117b7fab9d1826`、composer.lock Blob `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`，PHP`~8.4.0`、Laravel`v13.39.0`、114依赖包，session.serialization已锁`php`。现有composer脚本/allow-plugins空集合，不准擅自执行未知scripts/重算lock/降Laravel12。
- 必读`docs/workflow/CURRENT_WORKFLOW.md` Blob`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/versions/v10.1.5/plan.md` Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`，v10.1.4旧功能接受与v10.1.5原AC保持。上一隔离Laravel13候选 `7bd840200f781466919c7946e3533585caf6f8c3` 的166tests/2817assertions、90表合成恢复是上一任务`PREVIOUS_CODEX_REPORTED_LOCAL_RUNTIME`，并非当前任务动态运行结论。旧任务全部STOP，不允许复用它们的DB卷、私有vendor、ledger或任务标签。

## 2. 旧环境与备份：先只读保护，再新建独立本地入口

- Owner原本机旧Laravel11.48.0开发工作树：本地旧HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、原dirty252项、refs527、受保护index/HEAD、历史旧18捕获视图、两ACL夹具、122原证、3183 Seed、五保护根及旧任务seal；现有旧vendor和凭据均保留不动。原独立备份由Codex报告在`C:\Users\zcxve\EliteSyncBackups\20261030-main-7a4595c60ac2fced-local-4bebc8f3`，11,066文件/240,617,393bytes，Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`，此前已通过完整读回和隔离恢复试读，后续任务已抽检。本次仅在实际触及前做必要**只读**存在性、FileID/Volume/清单/抽样hash及历史seal核查，不能为形式而全盘扫描或重新复制。
- 新入口必须选择**与旧原dirty目录、旧备份、ChatGPT Project mirror、Codex旧STOP根、其它项目都不重叠**的全新独立路径，先只读检查剩余空间、重解析点/软链/ACL/卷身份；禁止在旧工作树内`git pull/reset/clean/stash/rebase`，禁止将旧venv/vendor/.env真实密钥复制到GitHub。新目录如有残留或路径已被占用，STOP并交付路径冲突说明；不覆盖、不移动、不借用原根、不擅自清理。
- 新入口必须直接从**开工fresh main产品Git对象**（而不是7bd未合任务CLI或旧Laravel11 local HEAD）还原完整软件工作树及`composer.lock`，Git状态clean，目标双Tree与main精确一致。路径/本地目录身份/原生Git提交/文件Blob/源锁哈希写入受限LOCAL_ONLY Manifest，公开报告只写脱敏身份；创建独立开发入口且不自动更改系统默认启动快捷方式/别名/用户全局Git config。保留单一可供后续Codex任务使用的稳定路径与具名手动启停说明。
- 旧备份不是旧真实DB恢复保证，也不是异盘容灾；禁用真实身份/私聊数据、真实旧数据库与账号。若实际端口/卷资源或证据身份与旧来源冲突，STOP风险部分，不碰原件。

## 3. 新本地Laravel13/PHP8.4闭包与隔离数据库

- 仅可使用**已经在运行且经签名/进程/本地pipe身份再次确认合规的本机Docker Desktop Linux Engine**；本轮不批准启动、重启、更新、安装或修复Docker Desktop/WSL/Hyper-V、Windows全局PHP/Composer、全局PATH、Windows防火墙/ACL、管理员UAC/策略、生产服务。
- 优先使用Owner已经手动pull并先前由Codex核来源的官方`php:8.4.27-cli-bookworm`及`mariadb:10.11.19-jammy`具名linux/amd64镜像。只读重核本机镜像对象/平台/Config、与源锁一致性，允许由新任务**自有容器**使用；禁止再次普通`docker pull`或从以前已STOP的任务根复制OCI/vendor原始文件。需构建新PHP运行镜像时仅**离线、task-owned tag/build/volume**，受限UID、cap-drop ALL、no-new-privileges、只读根及资源限制、没有宿主Docker socket/privileged/host network/其它项目共享卷；任何新外部下载（必要的Composer2或锁定包）必须有单独有界可信HTTPS计量、Digest/size、PREPARE+fsync，无法计量则STOP，不能擅自调用付费来源。
- 新vendor必须与固定114包lock实际对应，使用真实PHP8.4/Composer2`validate --strict`、`check-platform-reqs`、`install --no-scripts --no-plugins --no-interaction`，solver预算0，不改lock也不使用`--ignore-platform-reqs`或虚报Composer平台。可以使用已明确允许且具有来源hash的非任务私有**官方可核缓存**，但不能访问/搬运旧STOP任务私有缓存、未验真其它项目资源。对package discovery需事前检查受信Provider后显式、预算内单项执行，不能自动运行无界composer dev。
- 新隔离数据库必须是**任务全新空schema/独立自有volume**，使用新生成测试口令、虚构账号与媒体、归属标记、随机非冲突端口/网络，拒绝3306、43349、43359、43325、43479以及旧已保护数据库/卷。检查Docker端口、server_id、DB `APP_DB_CONNECTION`与实际Laravel config、hostname/username/schema，检查数据库初始为空才允许迁移。**不得仅因数据库名字看起来像开发库便使用既有数据库；不能直接连接/恢复真正旧Laravel11 DB**。可运行限定迁移/种子、合成权限正反例及重启后小规模持久读回，独立隔离的数据不自动构成生产数据库恢复。

## 4. Windows宿主`127.0.0.1`→真实API的有界连通验证（原明确缺口）

- 将任务自有API容器通过唯一、已检查的高位端口**仅映射到Windows宿主loopback `127.0.0.1`**。此目的仅证明`HOST_LOOPBACK_API_REACHABILITY`，**不批准对`0.0.0.0`、LAN、公网绑定或增改Windows防火墙、portproxy、Hyper-V/NAT、Docker Desktop配置**。如平台自动绑定到非loopback或无法限制暴露，立即STOP该端口并留原始端口/配置证据。
- 不得使用宿主生产服务或已保护端口；从**Windows宿主进程**（不能拿容器内curl冒充）实际对`http://127.0.0.1:<task-ephemeral-port>`作健康检查、真实Laravel请求/鉴权负例、虚构账号登录及后端独立DB验证（最小正负例），留下带响应码/哈希/耗时且脱敏的原始命令/进程退出回执。循环验证服务启动、必要的受控任务自有容器重启后同一个loopback接口再次可用；不依赖“容器内访问自己就算Windows宿主可达”。
- 如果宿主loopback失败，在合同内先调查**只读**Docker端口发布与进程/回环防火墙状态；可修自己容器的启动参数、健康等待，不能修改共享宿主安全策略或重启Desktop。安全边界内仍不通就报告`HOST_LOOPBACK_API_NOT_VERIFIED`，不伪造PASS。该缺口可以与新本地源码/vendoring有界通过并列报告；**不得声称本地全链已经可用于Windows桌面APP**。
- 默认无运行公网出站、第三方推送、真实账户；成功后关闭任务专属API/DB进程，保留独立开发启动配置、非敏感合成测试数据和启动命令（均手动启用）；不设置后台服务自动启动或自动对外开放。

## 5. 真实旧Laravel11二进制 Cookie/session：只准合成跨版本验证，严禁真实用户资料

- 已知仅`session.serialization=php`、合成PHP array-store和新Laravel13单框架登录回执，**不是**真实Laravel11二进制产生的旧cookie兼容证明。本任务首先只读审阅旧Laravel11.48源码/备份vendor版本及session cookie加密/序列化机制，判断是否存在可以在**本任务自有全新隔离目录**使用旧真实Laravel11引擎生成session+cookie的**虚构账号/全新独立密钥**；不能读取、提取或使用任何真实旧会话文件、旧真实APP_KEY、生产/旧DB、实人cookie。旧版源仅安全地从已确认归属的备份副本复制必要无敏感字节到新任务私有隔离环境，不能运行旧原dirty根。
- 若合规且依赖闭包可用，用**实际Laravel11.48二进制**从虚构账号与测试专用APP_KEY生成真实框架签名/加密Cookie和session wire bytes；以相同**全新测试key**及明确一致的测试用session store交给Laravel13本轮新隔离环境读取，逐步核positive login-preservation及logout/过期/撤权负例。允许独立虚构的`L11_BINARY_TO_L13_SYNTHETIC_SESSION_COMPATIBILITY_PASS`，但**不等于真实生产cookie迁移已经验证**。如果不同框架配置真实冲突，保留`SYNTHETIC_L11_TO_L13_SESSION_INCOMPATIBLE`的可复现脱敏失败，不自动放宽身份或泄露密钥。
- 若任何L11真实二进制依赖不可用、需要借旧私有vendor、要求生产密钥、无法按新身份隔离或超预算，STOP这部分并保持`REAL_LEGACY_L11_COOKIE_NOT_PROVEN`；**不能拿PHP`serialize()`手工制造的旧格式冒充真实旧Laravel11 binary proof**。APP业务接口与真实用户旧会话迁移仍另需Owner后续决定。

## 6. 新任务预算、停止界线与交付

- 新任务ID：`V1015_CLEAN_LOCAL_L13_DEV_ENTRY_HOST_API_LEGACY_SESSION_20261031`；唯一root basename `v1015-clean-local-l13-dev-entry-host-session-20261031`、attempt-0001、持久账本；**新工作目录、dev入口、受控API/DB测试资源精确归属**。单调总时长≤**240分钟**，新task+本次新本地开发入口logical/allocated各≤**16GiB**（保留宿主磁盘安全空间），不把之前备份/Owner原拉取图像重复算作本次分配；新任务新增的容器/卷/目录按真实归属计入。若磁盘不足STOP，不删旧版腾空间。
- 受计量新增网络供应≤**2GiB/500 requests**；官方OCI原镜像可重复**只读核验**但不可未经许可重pull，受控来源Digest种类≤8；离线build≤2，Composer真实solver**0**、vendor安装≤2，任务自有服务组≤3，PHP CLI≤150，Feature/Unit≤4批，Windows宿主实际HTTP≤100，容器内部合成HTTP≤120，新空库migration≤2、seed≤2，受控容器API/DB重启≤2；旧Laravel11测试生成链如进行也须纳入相同预算/费用而非另起root。Windows/Docker Desktop/WSL全局启停/升级/安装与宿主防火墙规则变更额度0。费用、失败、超时、重试均计，所有成本`PREPARE`+`fsync`前置，单独终态STOP不可复用余额。
- 新本地干净dev入口可以作为**后续开发候选入口**创建并保留；不覆盖旧默认目录、不写用户环境变量`PATH`或默认开发指针、不自动启动服务、不把现有dirty代码合进来。若入口构建可用但宿主port或旧session没证据，按`LOCAL_L13_CLEAN_SOURCE_READY_WITH_GAPS`、`LOCAL_L13_VENDOR_READY_HOST_UNVERIFIED`、`HOST_LOOPBACK_PASS_LEGACY_SESSION_NOT_PROVEN`等分级，不能一刀切用`LOCAL_BASELINE_FULLY_ACCEPTED`。
- 必交**一份非force、sole Parent为Codex开工fresh main的普通候选**，以GitHub最小**脱敏文档+必要非敏感手动启动说明/配置**形式报告，不在此任务自动合main产品源码或改已接受Laravel13主线；如确有框架兼容代码修复要将修复额外列为独立待Astra复核的`PROPOSED_COMPAT_CODE`，不得默认main集成。新增公开产物：
  `docs/versions/v10.1.5/CLEAN_LOCAL_L13_DEV_ENTRY_HOST_API_LEGACY_SESSION_RESULT_20261031.md`
  `docs/versions/v10.1.5/clean_local_l13_dev_entry_host_api_legacy_session_manifest_20261031.json`
  `docs/versions/v10.1.5/CLEAN_LOCAL_L13_DEV_ENTRY_HANDOFF_20261031.md`
  记录固定main SHA和双Tree、本地新入口实测路径的**脱敏别名**与FileID/Volume（真实私密绝对路径LOCAL_ONLY）、vendor/启动链、宿主实际HTTP身份、旧L11 binary session分级、已运行/NOT_RUN、备份/回滚、成功与失败、各预算计数和封存STOP。
- Codex提交后fresh读取GitHub candidate Commit/sole Parent/Root、完整path/mode/Blob及产品双Tree、live main/ACTIVE_STATE、备份/旧工作树受保护状态，做到候选文档不能随意修改产品源码；所有原始cookie/密钥/源凭据/下载镜像/vendor/DB volume/原日志均LOCAL_ONLY，GitHub报告只发布脱敏Hash和离散结果，等待Astra独立审查。没有权限变更生产、已接受版本的功能AC、AC05/G2、v10.1.6。

## 7. 不可变业务与历史状态

GitHub Laravel13/PHP8.4框架集成`ACCEPTED_WITH_OBSERVATIONS`，不等于本地APP到宿主API全面通过。v10.1.5功能AC仍**10 PARTIAL/1 OPEN**、AC05 RTC/AEC OPEN、G2_READY_FOR_POPEN_FALSE、REAL_PUSH_PROVIDER_PENDING，RTC_AEC_NOT_CLOSED、OS_ENFORCEMENT_NOT_PROVEN、真实旧L11用户cookie`NOT_PROVEN`、H264真片/真机WebSocket/RTC/通知GUI/物理15/30天/生产`NOT_RUN`，v10.1.6 NOT_STARTED。原Windows`E_NOTIMPL`、`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`不可倒改。旧18/两ACL/122原证/3183Seed/五根、11,066备份、旧STOP预算和dirty根全部禁止删除/清理/回写。

**STOP：** 一旦出现非任务资源写入、旧备份损坏、无法限定loopback或真实数据暴露、平台/费用/供应链无法核实、硬预算超限或系统全局操作需求，立刻封存失败并仅交付有界结果。Codex不自行签`LOCAL_L13_BASELINE_ACCEPTED`或`V10.1.5_FUNCTION_ACCEPTED`，不自动开启后继任务、合main、切旧默认目录、删除旧版、放行G2或v10.1.6。
