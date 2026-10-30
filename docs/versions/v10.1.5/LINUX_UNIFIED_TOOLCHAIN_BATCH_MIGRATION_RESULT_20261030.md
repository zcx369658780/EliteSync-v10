# 隔离 Linux 工具链与 Laravel 批量迁移集中结果（2026-10-30）

**BLOCKED_LINUX_EXECUTOR_NOT_AVAILABLE / STATIC_MIGRATION_PREPACKAGE_DELIVERED / AWAITING_ASTRA_REVIEW**

本轮证明已有WSL2和Docker客户端，**没有证明可启动的合格隔离Linux执行器**。Ubuntu-24.04及docker-desktop均注册为WSL2、处于Stopped；指定本地Docker引擎管道不存在，服务端查询exit1。合同明确“安装或激活Windows WSL/Docker Desktop…不授权”，因此动态阶段STOP；没有启动既有发行版/桌面引擎、安装系统或退回Windows DLL调查。

集中完成真正可执行的**源码预包工具**、Laravel13/PHP8.4与Laravel12/PHP8.4两份solver输入、全部114件旧锁依赖矩阵、工具链资格缺口锁表和一次集中环境授权需求。唯一生产配置调整是显式保留既有PHP session序列化语义，附未运行的Feature源码。**没有完成框架实际升级、没有真实新lock/vendor、没有PHP/API/DB运行证据。**

## 1. Authority和固定基线

- 正式合同Blob `03c40a831ed37d8610c9a9aa2760c9a94e17269b`；开工fresh main `7f83763fa0aa7bb30dadb04bd2465313ecd340cf`，Root `7c1306b0de3f9a63e3c97531dd00ec5b74e88fef`，ACTIVE_STATE Blob `6fb2e88d2f25860b019838a19882b31ee1efbb24`。正式全文/Owner授权、任务在main的路径及ACTIVE同步已直接核对，不以Prompt代替合同。
- 发布前main已前进至 `c89b00a3b6b6e03485a76d5ec73dff4e3eb079b5`，Root `502af5ef8b5a02ff71e1ecb2942cb4969bddebab`，ACTIVE_STATE `d379666bfa7f2305aff203ea2b920f2f5d1f4ed6`；新增交接文档Blob `8f66a46d1acfcf1b8b486b2799577a2d15f3c010`已全文读取。两项文档增量之外任务Blob、Scope、预算、Parent及main产品双Tree不变。交接快照的“未派发/未报告”不冒充本聊天执行状态；本轮以Owner在本聊天的明确手动派发执行，不重复派发、不改main。
- 唯一研发Parent `8941323808ce0cdfc68b9f0c3796f86400a75d43`，Root `6808c706f4b2f03b641975f71315c241ce6e435a`，apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `521cafbb463e0099271618c22cafd1ed6218bea2`；Astra审查Blob `c1b5577728f16077b416c73d82901ba94fa43335`已读，审查分支不作为Parent。
- CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`、AC01–11、15场景、动态目录/状态和必要路线/恢复台账已读取。正式文本均按Git Blob核原字节。
- Parent后端与原E2E工具从具名历史候选副本只读导入新根，逐件与fresh Parent Tree Blob匹配；后端生产控制器/业务服务、旧安全负例、原Windows资格工具和15场景保持不变。图谱只对应受保护原根，不能证明当前候选身份，故迁移触点以已核候选源码只读检索为准。

## 2. 有界只读环境核验

| 项目 | 实际结果 | 不能据此推断 |
|---|---|---|
| 1 命令路径解析 | WSL、Docker可找到，Podman未找到 | PATH没有命中不能证明全盘未安装Podman；未全盘搜索 |
| 2 WSL列表 | Ubuntu-24.04、docker-desktop注册为WSL2，均Stopped，exit0 | 注册名称不能代替真实distro release/架构或可写闭包资格 |
| 3 WSL版本 | 2.6.3.0，内核6.6.87.2-1，exit0 | 不是Linux PHP/Composer/数据库版本 |
| 4 Docker客户端 | 29.3.0，build5927d80，exit0 | 客户端版本不证明Desktop版本/许可或daemon可用 |
| 5 显式本地daemon | 指定本地管道不存在，server=null，exit1 | 未证明其它context不可用；未连接远程context、扫描其它引擎或激活后台 |
| 6 资源 | 约32GiB物理内存，观察时约10GiB可用、任务卷约460GiB可用；仅只读 | 未修改全局WSL资源，也未运行Linux虚拟化/架构探针 |

6项已用，全部原始stdout/stderr、失败exit1与账本LOCAL_ONLY保留。Docker命令使用任务私有空配置和显式本地endpoint，清除继承的remote/TLS context配置，未读取镜像凭据或连接现有/生产服务。原始列表中无关项目的发行版名不公开、不操作。

阻断的准确含义是**本轮允许范围内没有取得合格执行器**，不是宣称Windows没有安装WSL/Docker，也不是安装失败。合同未授权激活Desktop，未为获得PASS擅自启动。`LINUX_DEV_TOOLCHAIN_LOCK_20261030.json`保留实际观察值，其PHP/Composer/MariaDB实际patch、Hash/Digest均null/NOT_RUN，不把目标系列充作已冻结运行版本。Ubuntu兼容性和容器userland尚未证明，不把官方PHP可能采用的Debian/Alpine根文件系统冒充Ubuntu24.04。

## 3. Composer与批量兼容矩阵

真实composer.json Blob `d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56`声明Laravel^12.0/PHP~8.5.12；旧lock Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍Laravel11.48.0，79个生产包+35个开发包。**声明版本不等于已解析/运行版本。** 旧content-hash保持原值，未伪造新锁或RESOLVED。

官方13.x升级指南和Laravel官方skeleton/source元数据实际读取后，预包primary采用Laravel^13.0/PHP~8.4.0、Tinker^3.0、PHPUnit^12.0、Collision^8.6；fallback采用Laravel^12.0/PHP~8.4.0并保留Tinker2/PHPUnit11约束。其它业务依赖和autoload不重写，scripts与plugins在**隔离输入副本**中关闭，不采用config.platform或ignore-platform-reqs伪装扩展。活跃composer.json/lock仍保留Parent原字节，未把两份输入覆盖为正式解析结果。

| 依赖/破坏面 | 静态事实及本轮处理 |
|---|---|
| Sanctum | 旧锁4.3.1及官方4.x当前元数据包含Illuminate11/12/13约束；仍需真实solver选中版本及鉴权回归 |
| Tinker | 旧锁2.11.1的Illuminate范围止于12；主方案提高到3.x，未宣称新包已取得 |
| PHPUnit/Collision | 官方13指南要求PHPUnit12；Collision旧锁8.9.1允许的framework冲突边界不含13，但未证明实际组合。一次官方Collision分支元数据fetch失败原证保留，未据此推断包不兼容 |
| Workerman/lunar-php | 当前5.1.9/1.4.0的完整require、source、dist保留；Linux进程/扩展/信号行为未运行，不因PHP约束可容纳8.4而签运行兼容 |
| 全部传递依赖 | JSON矩阵逐件记录114包的require/conflict/source/dist/license及旧锁版本，全部OLD_LOCK_ONLY_NOT_TARGET_RESOLUTION。不得将此库存当作已求解的新图 |
| bootstrap/middleware/auth | 保留现行configure、provider、顺序与CN/MC/Block/账号保护，不凭升级预期重写已接受业务 |
| session/cache/Redis前缀 | 已有显式旧前缀/cookie命名不改；新增serialization='php'锁定旧格式，避免未来同步13 skeleton时意外改json。并非已复现新框架Bug |
| Eloquent/upsert/日期/存储 | 识别真实触点，包括DevSyntheticUsers的upsert；既有显式私有存储、Carbon/UTC与负例保留，执行兼容NOT_RUN |
| Laravel12CompatibilityTest | 仍有主版本12断言；实际选中13时须同批适配这一版本断言，保留其它安全负例。不能声称当前测试已支持或通过13 |
| SQLite通用TestCase | 原guard保持，不为MariaDB运行删除保护；真实MariaDB仍需独立、准确授权和实例绑定入口 |
| Windows原生E2E入口 | 原Windows资格链原样封存，不把其授权或OS映像例外挪到Linux。Linux独立process/source/DB收据adapter尚未实现 |

**决策：主方案Laravel13待求解，Laravel12回退未尝试；没有因真实包冲突选择fallback，因为本轮根本没有solver运行。** Laravel13最终方向仍需Astra及Owner决定，不改变已接受产品。

## 4. 实际交付的非生产工具与源码

`tools/v1015/linux_backend/prepackage.py`真实提供默认无副作用inspect、固定composer输入核验、两份profile变换、全旧锁库存、候选源码触点和task-owned预包写入。写入绑定本task/Parent/attempt/根身份，PREPARE+fsync、独占文件和回读；扫描后在同一Windows排他账本handle下重验STOP/原ledger身份/窗口/根并持有到输出结束。所有源PHP拒绝hardlink和reparse。`execute`不可被JSON/假授权解锁，且不存在process/network启动代码。POSIX flock仅协作锁，不夸称防非协作者；当前真实写入在Windows私有根。

原始预包3文件保留不覆盖；最终生成器重建值与原输出逐字段相同。正式交付两份composer输入、工具文档、全依赖与兼容矩阵，以及不可执行的隔离蓝图（UID/端口/Digest尚未资格化）。这是一份可用静态预包，**不是声称完整容器执行器或网络预算拦截器已经完成**。

`config/session.php`唯一生产配置新增显式php序列化；`FrameworkSessionCompatibilityTest.php`提供array handler读取合成旧序列化字段/类型与配置名称的Feature源码。该PHP测试**未运行**，也不包含真实HTTP cookie/认证连续性证明，不将数组handler读回当登录安全通过。

## 5. 纯检查与真实NOT_RUN

最终 **34/34纯Python用例通过，failed0/errors0/skipped0，exit0**，输出SHA256 `0f896a8b6b9c7e1102a4261f1a993a9a76c91ec0b36882b9d6d0e4a8675d87aa`；前两批27/27、33/33也通过，三批不是94个独立用例。测试和本地驱动同时拒绝Popen、socket连接、system/startfile，包含拒绝guard自检、错误task/Parent/attempt/root、torn-tail、过期/倒退、扫描期间STOP/过期/账本替换/并发追加、源码hardlink、输入篡改、脚本插件及platform伪装负例。

独立Sol只读辅助审查发现账本提交竞态、PHP扫描hardlink、测试guard证据和session表述4项问题，已集中修复；Sol最后只读复核确认原四项已解决。再加task-private文件的真实Windows第二写/DELETE-access句柄拒绝负例，共比首批增加7用例；没有真正删除文件或观察系统来源。最后审查并未重跑测试，不能代替Astra验收。未运行PHP lint、PHPUnit、Composer或Linux容器以“确认”静态结果。静态表只定位可能破坏面，不制造新业务Bug或虚报已修所有框架问题。

| 动作 | 本轮实际消耗 / 上限 |
|---|---:|
| 只读环境inventory | 6/6 |
| 依赖镜像供应响应体 / 受控供应请求 / 具名Digest | 0/2GiB / 0/500 / 0/8 |
| build / Composer solver / vendor install | 0/3 / 0/3 / 0/2 |
| PHP CLI / Feature-Unit | 0/120 / 0/5 |
| 隔离服务组 | 0/4 |
| 业务HTTP / migration / seed | 0/240 / 0/2 / 0/2 |
| WSL发行版/Desktop激活 / 全局安装及设置修改 | 0 / 0 |
| Flutter/Gradle/G2/APK/ADB/设备/RTC/Push/物理时间 | 0，未授权 |

供应网络计数为0指没有镜像/Composer供给；另有GitHub Authority及官方文档/源码元数据的只读连接器查询，**不声称连接器底层重定向/缓存的物理HTTP计数已经被本地账本完全观察**。未来真实pull/Composer需实现全请求/字节拦截后才能签供应预算合格，不能只计docker命令次数。本轮没有资格化供应网络、lock或vendor。

单task根、attempt-0001、ledger自首次建立起计时；logical/allocated各≤16GiB、窗口≤240分钟。生成报告时空间/耗时见Manifest；最终budget-terminal/completion与账本封存为LOCAL_ONLY，未继承历史余额。

## 6. 保护、来源与证据等级

protected dirty摘要252项、527refs及7个具名历史根的FileId/Volume与ledger/hash/terminal/completion文件摘要前后相同。旧18、两ACL树、122原证、五保护根、3183 Seed沿既有保护回执传递，**未重新逐对象扫描**；没有历史数据库、原SDK/证据、claim、预算或Windows调查修改。旧E_NOTIMPL、native闭包未证及ACL跨尝试超限事故永久保留，Linux预包未覆盖任何历史结论。

| path | Parent Blob | 候选 Blob |
|---|---|---|
| `docs/versions/v10.1.5/LINUX_DEV_TOOLCHAIN_LOCK_20261030.json` | `NEW` | `7199415f6ffc8448738fbb603ef5864c957686c2` |
| `docs/versions/v10.1.5/LINUX_FRAMEWORK_MIGRATION_MATRIX_20261030.json` | `NEW` | `1c5dc0d7f6385bcde1ef4067b811b68e3dcedc1f` |
| `services/backend-laravel/config/session.php` | `7036d0a4140b419fd35005b84bcef12f16449f34` | `dbcb582d0afbab3a0dc95576797730555ce3cd8d` |
| `services/backend-laravel/tests/Feature/FrameworkSessionCompatibilityTest.php` | `NEW` | `b43bdc530389f509c1290a77e940767ed3aba2a8` |
| `tools/v1015/linux_backend/ENVIRONMENT_AUTHORIZATION_REQUIREMENT.md` | `NEW` | `e1a0901c34fe38a38c0227885c3ec11b7d362ac0` |
| `tools/v1015/linux_backend/README.md` | `NEW` | `4e12b5976da530afe60a391751bcc8e5edd6105b` |
| `tools/v1015/linux_backend/prepackage.py` | `NEW` | `8dbb5e2f807390bd0f7177cc1f6415a88205c428` |
| `tools/v1015/linux_backend/profiles/laravel12-php84.composer.input.json` | `NEW` | `a0452dc313ed2895bb55e0aec89735a094662179` |
| `tools/v1015/linux_backend/profiles/laravel13-php84.composer.input.json` | `NEW` | `130793decf84ff8ab93faa0300117b7fab9d1826` |
| `tools/v1015/linux_backend/test_prepackage.py` | `NEW` | `567723a0d0a2774a3b565df9354861f8dd6c9b8b` |

GitHub对象及原文回读属于`DIRECT_GITHUB_OBJECT`；6项inventory、34项纯检查和空间/保护回执属于`CODEX_REPORTED_LOCAL_TEST`；路径/账户/原始stdout/stderr/ledger和原件为`LOCAL_ONLY_RAW`；Linux/PHP/Composer/Feature/API/DB/持久重启为`NOT_RUN_GATE_CLOSED`；执行器完整资格、目标transitive解析、真实框架及APP链为`NOT_PROVEN`。历史23 Feature/77 Widget不充作本轮运行。

## 7. 一次集中后续授权需求与STOP

详见工具目录`ENVIRONMENT_AUTHORIZATION_REQUIREMENT.md`。最小需求是Owner允许启动**已有**Docker Desktop WSL2后端并核许可/版本/架构，然后以新的冻结综合任务完成工具链供给、真实solver和集中回归。不是推荐重装WSL，也不是请求执行未经版本/Hash冻结的latest安装器。若确需安装，官方Windows x86_64 Installer名称/来源、准确维护版本、SHA256/签名和许可必须取得后再批准；当前这些安装资格尚未成立，不能自行下载/安装。材料列出权限、资源、保护/备份、停止与回退边界，不创建或派发后继任务。

唯一non-force候选sole Parent固定89413238；发布后fresh回读Commit、sole Parent、Root、全部变更path/mode/Blob原文、完整apps/services及live main并封存。产品main仍v10.1.4，未签FUNCTION_ACCEPTED。保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`，AC01–11仍10 PARTIAL/1 OPEN。完成后STOP，等Astra独立验收及Owner对Laravel13正式取舍。

官方来源：

- https://laravel.com/framework/docs/13.x/upgrade
- https://laravel.com/framework/docs/12.x/upgrade
- https://github.com/laravel/laravel/blob/13.x/composer.json
- https://github.com/laravel/framework/blob/13.x/composer.json
- https://github.com/laravel/sanctum/blob/4.x/composer.json
- https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- https://docs.docker.com/desktop/setup/install/windows-install/
