# Laravel13/PHP8.4 安全集成与旧版本本地备份结果（2026-10-30）

**SOURCE_INTEGRATION_CANDIDATE_AWAITING_ASTRA_REVIEW / PREMIGRATION_LOCAL_BACKUP_VERIFIED / DYNAMIC_SUPPLY_BLOCKED / LOCAL_RUNTIME_NOT_RUN / MAIN_PRODUCT_NOT_INTEGRATED / LOCAL_DEV_BASELINE_NOT_ACTIVE。**

本轮完成本机旧版本备份、完整读回、隔离恢复试读及精确来源选择。已形成只含框架/依赖输入和必要测试适配的独立候选。**MariaDB官方镜像层在有界重试中再次响应截断，无法建立完整可信工具链闭包，故停止动态部分；没有执行PHP、Composer install/validate、Feature、HTTP或DB回归。** 不声称运行成功或已生效集成。原工作根、旧vendor、私有配置、旧数据库、全部历史资产与备份保留。

## 权威与状态分离

- Task `V1015_LARAVEL13_MAIN_SAFE_INTEGRATION_AND_BACKUP_20261030`，唯一attempt-0001；正式任务Blob `63712dba26ec1c24539bec7082dd4f0c557df583`。
- 开工fresh main/唯一sole Parent：`7a4595c60ac2fced957cd3bffd132daa23b4db74`；Root `7d9005590deda0cd5f4e98f9676eae8c9a5daa23`。
- Parent正式产品仍为v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。Owner已正式选定Laravel13/PHP8.4方向，产品main与本机默认环境没有因此自动切换。
- Source `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6` / Root `3b9690c1cdd6313d8f192c0ca4105352b8b40188`；其Astra Review `9026a5bb04bbb23358eb8c6f61afba66ae4f2318` / Blob `456c8d47ec98e815c467e9d5f38ea3b4ddf12680` 只接受有界合成后端候选。二者都不是本轮Git Parent。
- CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、正式任务、plan、闭环协议、ACTIVE_STATE及审查均fresh读取；全文任务等按原生Blob核验并保存在本轮新根。所有旧STOP账本、余额和私有运行资源未复用。

`OWNER_SELECTED_DEVELOPMENT_BASELINE=TRUE`；`SOURCE_INTEGRATION_CANDIDATE=TRUE`；`MAIN_PRODUCT_INTEGRATED=FALSE`；`LOCAL_DEV_BASELINE_ACTIVE=FALSE`；`RUNTIME_VERIFIED=FALSE`；`INTEGRATION_ACCEPTED=FALSE`；`FUNCTION_ACCEPTED=FALSE`；`PRODUCTION_DEPLOYED=FALSE`。

## 旧版本归属、备份与恢复

实际用户工作根为本机原有dirty根，local HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、branch main、252项normal dirty、527 refs；与GitHub fresh main明确分层。其composer.lock和现存vendor均为Laravel11.48.0、114包。只读保存代码、index/dirty/untracked/Git来源与相关依赖/配置元数据，不宣称旧PHP或后台服务已成功运行。

新建本机独立备份目录，名称绑定日期及fresh main/local HEAD；真实绝对路径、FileID/Volume、完整逐文件Manifest、ACL、私有配置均LOCAL_ONLY。新备份目录仅Owner/System/Administrators受限访问并完成原生ACL读回；未修改旧根或Windows全局ACL。C/D自由空间已实际核查，未通过清理旧资产腾空间。

- accepted main完整apps/services代码：1420文件、91,671,865 bytes；不是只依赖GitHub留存。
- 本地实际工作代码/自有未提交修改与版本材料1141文件、旧vendor8497文件；私有开发配置/Git恢复元数据另置受限副区。
- 合计 **11,066文件 / 240,617,393 bytes**；复制不使用hardlink，全部文件重新打开SHA256读回。
- 隔离恢复试读再复制 **11,066文件 / 240,617,393 bytes**，逐文件核验；独立新Git对象库恢复出的apps/services原生Tree精确为 `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac`；旧composer元数据可解析。
- 备份Manifest SHA256：`3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。备份目录身份、源/目标SHA、mode、长度、恢复路径和保留清单见LOCAL_ONLY回执。

门禁 **BACKUP_VERIFIED_AND_RESTORE_CHECK_PASS** 已在任何集成工作树修改之前锁定。它证明上述代码/vendor/配置材料可读取并在隔离副本恢复；不是完整Git历史或真实数据库恢复证明，也不是物理磁盘硬件故障冗余证明。旧真实数据库、用户上传/会话/日志、私钥原证和共享SDK缓存未迁移、未公开。

## 精确选择性集成

备份通过后，从fresh main建立独立稀疏Git工作树：native HEAD、全部Tree对象/初始clean状态已核验；原dirty工作树不被吸收或覆盖。

52项services差异分类：框架/依赖与必要测试10、未整版接受业务/相关测试语义26、旧任务专用工具16，UNKNOWN=0；全表见 `LARAVEL13_SOURCE_SELECTION_AND_DIFF_MAP_20261030.md`。最终仅10项源码变更，所有254个main app业务源码保持原Blob，未选择的1411个main产品路径保持原始字节。源apps Tree整体不接入，目标apps保持正式main。

三项依赖/配置：精确composer.json `130793decf84ff8ab93faa0300117b7fab9d1826`、lock `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`、session.php `dbcb582d0afbab3a0dc95576797730555ce3cd8d`。七项测试适配：query私有helper改名、PHPUnit12 DataProvider属性、四个CSRF类别名与新增session array-store测试。V1006只取CSRF别名，保留main旧token refresh断言；没有整段带入source的新T0夹具。

**重要行为差异：** 固定composer profile清空生命周期scripts（包括package:discover和composer dev）及插件白名单；锁还升级Guzzle7.10.0→8.3.1、Workerman5.1.9→5.2.3、lunar-php1.4.0→1.4.7，不能称仅替换框架版本。遵守任务精确目标，未擅自补回scripts、改锁或重求解。未来完整合格验证环境需显式安排并计量package discovery等必要动作；`composer dev`原组合入口当前不再提供，不能用未计量并发进程补位。当前不执行任何替代命令。

不接入F1/F3/F4新业务域、认证/消息/通知改动、新迁移/路由、旧任务资格绕行或Windows/E2E工具；main SQLite TestCase guard原字节保留。无普通兼容错误被拿来放宽权限、删除负例或偷渡未接受业务。相应v10.1.5功能和真实旧Laravel11 cookie依然未接受/未证明。

## 动态停止与真实回执

现有Docker Desktop4.97.0.244584、CLI/Engine29.9.2、linux/amd64，签名/hash、进程和本地pipe身份重新核验；既有TermsVersion2与Owner已确认免费资格保持。没有再次启动/重启/升级Desktop或WSL，也无新许可/登录/费用动作。

新任务供应端先使用持久PREPARE+fsync、响应上界预留与实际读回记账，从官方来源获取镜像，未直接pull、未借用前轮私有镜像/tag/vendor/DB卷。第一次PHP层提前EOF，保留25,738,667字节partial与512MiB最大预留；该次初版失败记录未保存HTTP状态/长度，保持NOT_RECORDED。一次有界重取完成PHP image config与完整diff-id/export身份校验；随后MariaDB层HTTP200声明29,752,488字节、仅收到19,119,531字节，再次截断。MariaDB来源闭包不能证明，停止动态阶段，不第三次尝试、不换旧任务资源补位。

**本轮 build0、solver0、vendor install0、PHP CLI0、Feature/Unit0、业务HTTP0、migration0、seed0、服务组0。** 没有新API/DB服务、没有新测试数据库。已导入本任务PHP输入镜像保留；所有不完整体、原始退出和失败日志保留LOCAL_ONLY。PHP源码lint、Composer validate、依赖安装、权限负例、API/MariaDB与重启回归全部NOT_RUN。旧9b的258测试/3071断言不是本轮目标的运行证据。新增session测试本轮未执行，不能证明真实旧11二进制Cookie兼容。

已完成的本轮本地检查仅为备份/恢复、native Git与Blob身份/范围、非作者只读十文件差异复核、三个纯Python停止门负例；动态STOP已在控制器/容器包装器锁定，不再使用其剩余额度执行动态工作。

动态关闭快照：供应37请求、4个来源镜像index/manifest Digest；成功响应体186,327,053字节，加两项各512MiB失败保守预留，预算占用上界 **1,260,068,877 / 2,147,483,648 bytes**。没有退款失败。其余动态计数均0；task+backup logical/allocated各低于16GiB，单调窗口低于240分钟。快照、最终封存峰值/时间/账本SHA分开保存，不把快照冒作最终值。

## 回滚、保留与独立出口

1. 当前没有覆盖旧版本或切换默认入口，无需向原dirty根反向写入回滚。继续使用原旧目录不需要从候选覆盖还原。
2. 若未来获准切换，出现问题时先停对应新环境，保留失败；仅向另一个获准的隔离目录从本地备份恢复，按Manifest逐件核SHA/mode并重建产品Tree、验证旧composer/vendor与私有配置归属。不能直接覆盖dirty或连接真实旧DB来试验。
3. 私有配置仅在受限LOCAL_ONLY副区恢复试读；真实数据库恢复另需具名授权与真实备份。本轮不能声称具备完整DB回滚或旧运行环境冷启动证明。
4. **本轮删除授权为0，当前可删除项为0。** 本机清单 `NO_DELETION_AND_FUTURE_OWNER_REVIEW_ONLY-LOCAL_ONLY.json` 列明原根、vendor及已识别旧工具路径/FileID/依赖待核状态；不是删除许可。原dirty/历史账本与证据、真实DB备份永久排除，备份保留。未来必须先有Astra独立集成接受、新版本可用及回滚/冷启动证明，再由Owner按每个精确对象确认；不自动派清理任务。

本轮只交一个普通non-force候选，sole Parent固定开工fresh main；不自动合main。报告/Manifest不内嵌包含自身的Commit/Root以避免循环自哈希，发布后用原生Git Commit、Root、全path/mode/Blob、完整apps/services Tree、live main及LOCAL_ONLY final-readback绑定实际身份。完成后同根ledger永久STOP，全部未用余额不可复用，等待Astra；不自签INTEGRATION_ACCEPTED或FUNCTION_ACCEPTED。

永久状态保留：v10.1.5 PARTIAL_NOT_ACCEPTED；AC01–11=10 PARTIAL/1 OPEN；AC05 RTC/AEC OPEN；G2 false；REAL_PUSH_PROVIDER_PENDING；RTC_AEC_NOT_CLOSED；OS_ENFORCEMENT_NOT_PROVEN；REAL_LEGACY_L11_COOKIE_NOT_PROVEN；v10.1.6 NOT_STARTED。四项历史事故门和EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED原样保留，Windows E_NOTIMPL未改写。Flutter/Gradle/G2/APK/ADB/设备RTC/AEC/真实Push/物理15/30天/生产操作均未执行。
