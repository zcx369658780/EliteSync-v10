# EliteSync v10.1.5｜7bd84020 Owner已拉取官方OCI镜像、Laravel13目标main隔离回归｜Astra独立验收｜2026-10-31

**正式裁决：`7BD84020_LARAVEL13_TARGET_MAIN_ISOLATED_RUNTIME_CANDIDATE_ACCEPTED_WITH_OBSERVATIONS / READY_FOR_CONTROLLED_MAIN_INTEGRATION_OWNER_GATE / MAIN_PRODUCT_NOT_INTEGRATED / LOCAL_DEFAULT_L11_UNCHANGED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE`。**

**接受范围：** 旧v10.1.4正式main业务源码之上的**选择性Laravel13/PHP8.4框架兼容候选**与Codex报告的隔离PHP/Composer/Feature/真实容器内HTTP/MariaDB/合成库持久及恢复验证。**不代表已把candidate合入main、已经切换本机默认开发环境、已证明真实旧Laravel11 cookie或公网/宿主入口、已接受v10.1.5整版或生产部署。** Astra独立读取GitHub原生Git对象与源码、包锁、脱敏报告/Manifest/回执，**未在Owner本机执行Docker/PHP/Composer或重算私有ledger/11,066件备份原字节**。运行、来源链及保护本机观察的证据等级保持`CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW`。

## 1. 固定Authority与GitHub直接对象核验

- 正式Owner批准、Codex已手动派发任务：`docs/versions/v10.1.5/V10_1_5_OWNER_STAGED_IMMUTABLE_OCI_IMPORT_AND_LARAVEL13_MAIN_SAFE_RUNTIME_INTEGRATION_TASK_20261031.md`，**最新修订Blob `30c993d6a350ba79f62dddea6ddbeb420854ddec`**；旧Blob`ff6a33189984956ec39bf038cb5e7b1d4204b267`已于派发前被替代。冻结v10.1.5 plan `7d3466b3be67135dc641cfee7c7faef78937ba03`，原AC01–11、旧STOP事故与预算仍然有效。
- GitHub原生候选Commit **`7bd840200f781466919c7946e3533585caf6f8c3`**，唯一Parent **`f9f9b97870c6ca482ced83ba09af82dab326f370`**，候选Root **`cd4b6ae230105c28aebf2790b704a7218cd64055`**，Parent Root `9a854f32de35907a1462ff5a3a7863b02036696f`。compare`ahead1/behind0`，恰好25变更。
- GitHub完整递归Git Tree：candidate 6277、Parent 6261 entries，均`truncated=false`。Manifest所列24个非自引用变更`path/mode/Blob/size` **24/24通过直接Git Tree对照**，Manifest自身Blob `77659710dc85dee31f4e65dbec838837806a7ce8`在同一候选Tree中，故所有25条变更准确，没有额外文件。对source path逐个审阅Commit patch，包括所有测试夹具差异和任务验证工具。
- 候选apps Tree **`3468a3dd97da7accfda2539a0f8d8f68931a6110`** 与正式main完全一致；候选services Tree **`e14dece6cf3eef118875f688fd303a82d34418c2`**。原已接受main services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`仍是当前产品基线。25条变更中：8个脱敏文档、17个backend composer/config/测试夹具/CLI验证文件；**没有修改正式main app/routes生产业务源，也没有全树合入9b较宽F1/F3/F4业务候选**。此次Astra Review分支是审查档案，不是下一研发Parent。
- 直接检查`composer.json` Blob `130793decf84ff8ab93faa0300117b7fab9d1826`：PHP`~8.4.0`、Laravel`^13.0`、scripts/plugins清空。`composer.lock` Blob `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`，合计114包（prod81/dev33），`laravel/framework v13.39.0`、Tinker3.0.2、PHPUnit12.5.42、Guzzle8.3.1、Workerman5.2.3、lunar-php1.4.7；与f407原选择目标锁一致。新包分发来源/每份SHA、vendor真实安装是Codex本地回执，不是Astra在沙盒直接运行Composer。

## 2. 镜像及依赖供应链：限定复核

- Owner预先拉取的`php:8.4.27-cli-bookworm`：冻结OCI Index `sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`，linux/amd64 Manifest `sha256:dd0e2b902f1edfb6ca02fbcb391c28b1554c7d35a4e36e5925876b90aa804851`，Config `sha256:12f6d2ea136f247580f3dc42bda86b27af080fa8f04ea5ec9b581238702093ff`。Codex的本机脱敏回执记录10层原始压缩SHA/字节及解压diffID、平台与本地export闭环通过。
- Owner提供的MariaDB 10.11.19 Jammy镜像是**具名备选官方Index** `sha256:7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`、linux/amd64 Manifest `sha256:dc9dd57be7f46ad6f350c598a331d64f295899c4abac3ec5652eff831fc38a6c`、Config `sha256:41096ae9913468679bb5e05bbc19f44edcaf0eae45d67fcde224ffdeda9d3a1f`；与旧冻结`d769...`不是同一镜像，不能替换身份声明。Codex报告该8层Compressed/diffID/Containerd源链合格、实际MariaDB版本10.11.19。UBI9下载被明确排除，未运行/修改/删除。
- Docker Engine29的`inspect .Id`可能为Index或平台Manifest target，**不要求等于Config Digest**；已核GitHub工具链回执明确区分Image Index、平台Manifest与Config，未把仅有tag/Id当PASS。本机实际签名/OCI raw未由Astra重跑。
- 报告Linux PHP8.4.27、Composer2.11.1、Laravel13.39.0，1次offline build、原114包锁不重新求解（solver0）、真实Composer strict validate/platform-req check及禁scripts/plugins install exit0。7个Provider源码人工界定后显式运行package:discover/route:list，Guzzle8/Workerman/lunar-php为**限定API使用测试**，不证明真实公网依赖/WS gateway或RTC。

## 3. 目标main源码与测试语义

- 本次严格保留现有已接受的**257个app/routes生产文件Git Blob**及完整apps Tree；新增17个backend路径包括FrameworkDependencyCompatibilityTest、FrameworkSessionCompatibilityTest、CreatesAcceptedMainMatch、CLI-only task_fixture/http_request，及旧测试PHPUnit12/CSRF调整。没有引入9b新业务F1/F3/F4控制器、Services、routes、业务迁移。正式生产唯一配置变化为`session.serialization='php'`（旧Laravel11→13格式保护候选），不是已证明旧真实会话保持登录。
- `CreatesAcceptedMainMatch`通过真实当前主线proposal/round/run/两端accept接口构造旧V1007媒体及consent测试前置，而非凭裸DatingMatch假装双方已接受；V1007LiveConsentTest仍保留未同意时拒绝、CN/MC缺一不可、同key重放、撤权后读取及发送拒绝。PrivateMedia的guest断言由404改401与正式`auth:sanctum`路由前置一致，并新增拒绝响应不泄露PNG字节、storage_key；授权外人及撤权仍404。V1009模拟Range/206负例可测试，但**不是实际H264解码或端到端真实video206**。
- `TransportEnvelopeTest`另改一个V1源切片hash pin以对齐正式main，并仍检查v1/v2非权威边界；生产`routes/api.php` Blob未变化。此前固定旧hash与当前main不同，此改动应维持`TEST_PIN_REBASE_TO_ACCEPTED_MAIN`可追溯，不把只修改期望Hash误认作代码变更/安全修复。
- 经目读生产业务门禁没有为测试变绿而删除；需要注意**新增测试夹具与局部安全负例适配仍属于新候选源码**，不能在此直接判定所有v10.1.5功能已经恢复或安全性全面通过。

## 4. Codex本机运行与合成恢复

- 配套回执 `owner_staged_oci_l13_test_receipts_20261031.json` Blob `a192949a88105deafcdda3ae109604038a449284`：5批Feature用满，前4批原失败明确保留（exit2、2、2、1），最终第5批 **166 tests / 2,817 assertions / exit0**。20个PHP文件lint成功；真实PHP版本、Composer validate、平台检查及vendor install有分级退出回执。这**不是完整v10.1.5 11个AC或全项目测试**，先前9b的258/3071不能当新目标main的运行结果。
- 新独立合成MariaDB90张表，真实容器内TCP回环HTTP `127.0.0.1:8080` 进入当前Laravel13：已有账户login、CN/MC双向同意、消息/媒体、同key重放、异payload409、guest/第三方403/404/401、Admin CSRF419、拒绝未经授权推送等重要许可逻辑均有脱敏响应Hash/状态；本轮HTTP尝试47（包含失败/timeout和相关negative），而非把每个状态当单独完成功能版。
- Codex报告重启后90表逐表**行数及排序行哈希相等**，再从新合成库dump到**本任务另一新空Schema**，90表恢复前后行计数/哈希一致；dump Hash `070d38969fb1f38c88320cb8fff501c64963c768f6fe993d2144b7fa117a6e12`，121,210 bytes。只支持此**任务私有虚构数据库数据恢复**，不证明生产DB恢复、旧Laravel11实际迁移、完全Git历史恢复或外部灾难恢复。
- 宿主端口尝试失败且未验证，容器冷启动最初5秒超时，随后内部限定30/45秒回环测试通过，没有为此改宿主防火墙/启动Docker/WSL或放通公网。因此`HOST_PORT_FORWARDING_NOT_VERIFIED`一直保留，不将内部回环冒称本机Windows外部客户端/真机API入口。
- 真实旧Laravel11版本二进制产生的cookie与跨框架会话迁移仍`REAL_LEGACY_L11_COOKIE_NOT_PROVEN`；Laravel13 PHP序列化合成array-store仅为格式检查。H264真实video206、WebSocket gateway、真实Push、RTC/AEC/真机、物理15/30天、生产部署/正常公网均未运行。

## 5. 本地备份、保护、预算与证据等级

- 本轮Codex报告对先前独立本地备份11,066文件 / 240,617,393字节重新打开SHA比对，Manifest SHA `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`；旧源/vendor/私有元数据9,643项，dirty252、refs527、index/HEAD、122旧原证、3183Seed、旧18/两ACL/五根及11旧task封存摘要具名只读核对。旧版本、私有配置、Docker原镜像、备份未清理；但Astra未直接读取这些本地原始字节，报告只作`CODEX_REPORTED_LOCAL_TEST`，不能追认历史ACL/OS安全此前未证明的事实。
- `owner_staged_oci_l13_budget_20261031.json` Blob `92f0603546773b5e985965ce0e2fd995a59d00b4`：任务动态关闭快照供给137/500、计费34,054,405 bytes/2GiB（含失败保守预留）、Digest7/8、build1/2、solver0、vendor1/2、服务组3/3、PHP CLI92/150、Feature5/5、HTTP47/180、migration2/2、seed2/2、Desktop/WSL操作0。快照耗时3528.125秒、logical约3.80GB/allocated约3.83GB，小于单任务240分钟/16GiB。Owner报告实际封存68.48分钟；**最终ledger SHA、真实峰值、completion与空间回执仍LOCAL_ONLY**，Astra只认公开快照和Owner/Codex报告，不声称自己量过封存峰值。所有余额在STOP后不可重启/转借。
- Owner此前的Docker pull是外部供给，外部总bytes/requests明确`UNKNOWN_EXTERNAL_BYTES/REQUESTS`，没有虚算成Codex成本0。OCI、vendor、真实DB卷、下载体/令牌/真实HTTP cookie/旧备份仍LOCAL_ONLY。
- 旧事故不可变：`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`、Windows E_NOTIMPL原样保留。本新Docker成功不倒填旧Windows Native PASS。

## 6. 正式限定接受与后继Authority

**本次接受：`LARAVEL13_TARGET_MAIN_ISOLATED_RUNTIME_CANDIDATE_ACCEPTED_WITH_OBSERVATIONS`。** 直接GitHub身份与保留main生产业务的框架升级候选成立；Codex实测报告包含真实依赖闭包、权限负例、内部HTTP/MariaDB和合成DB重启恢复，这已经足以结束**本次有限后端集成候选**的技术评审，而不应重复同样的网络/镜像前置试探。

**绝不可签：`MAIN_PRODUCT_INTEGRATED`、`LOCAL_DEFAULT_BASELINE_ACTIVE`、`V10.1.5_FUNCTION_ACCEPTED`、`REAL_LEGACY_L11_COOKIE_PROVEN`、`HOST_PORT_FORWARDING_PASS`、`G2_READY_FOR_POPEN`、`AC05_CLOSED`。** Main产品仍正式v10.1.4；v10.1.5 AC01–11状态`10 PARTIAL / 1 OPEN`，AC05 RTC/AEC OPEN，Push provider pending，v10.1.6 NOT_STARTED。

**唯一下一Owner授权门：** Owner如同意，可由Astra准备一次**已验收Laravel13选择性源码候选精确产品main集成、回读双Tree、旧备份/本地开发版本保护、必要最小安全门复核**的综合任务；不应再次无差别下载镜像/重复全部166项，也**不能自动切换原dirty本地默认版本**。Host端口和旧Laravel11真实Cookie作为具名保留缺口，若影响正式主线安全承诺则必须在集成接受时显式设条件或后续专门门禁。产品main集成须按Owner明确许可、Codex一次交付、Astra最终独立验收闭环；**当前审查不会直接把源码push/main merge或删除旧版/备份**。
