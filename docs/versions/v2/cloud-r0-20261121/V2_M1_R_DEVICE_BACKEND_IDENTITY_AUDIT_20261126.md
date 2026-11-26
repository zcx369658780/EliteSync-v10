# EliteSync V2｜M1-R 实机后端运行身份只读审计

2026-11-26，北京时间。任务 `V2-M1-R-DEVICE-BACKEND-IDENTITY-20261126`。**结论为 PARTIAL，`NATAL_DEVICE_BACKEND_IDENTITY_BOUND` 未达到。** 实机重算窗口内，已将获准 APP 入口的两条 HTTP 200 与专用 Staging 应用容器中的 POST、GET 各一条按秒对应。部署回执、启动时间和进程日志相互支持。日志缺少原始 API 路径、请求 ID、客户端实例标识和输入／结果版本，无法把这对请求唯一归于 1011814 的 v3 提交和读回。原 M1 具名功能验收及 Owner 重登回执仍有效。

## 检查身份与范围

| 对象 | 固定身份与核验 |
| --- | --- |
| 活动工程 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，`origin` 指向 `zcx369658780/EliteSync-v10`。开工 HEAD `1f11dc99cb011fc023c9b93d52d14f44a98421dc`，tree `07569bbf1ddd8dba41270049236309019d03a4da`，工作区和暂存区干净，远端分支引用一致。 |
| M1 开工及工程源码 | 开工 `2593a079894cb381ed9ad70b2e50977c240d25c0`，本地工程 `242c5b6cea419297a05a4851dccd837050e1b7ae`，对应源码 tree `ee2dc2a8a8d2cd97e69e621dd2290298311725da`。本地源码是固定 M1 报告提交的祖先。 |
| 具名实体 App | `25060RK16C / com.elitesync.v2stagingremote / 1011814`。原安装回执和 20:22 只读身份回执一致。本轮重算归档 APK SHA-256 为 `37b9d370dda05f737cdd5e367d12267e3572220120edd6a27ec7710d8aec18d4`。归档源提交为 `191e90cb6f4eb4c4719a03729ba07fca5e8fcc6b`。离线检查 APK 内 Dart AOT 与原生 DEX，二者都含与已备案 Staging 主机相同的固定目的地。 |
| 本机合成链 | M1 隔离 Android 使用 `com.elitesync.v2functionp042r1 / 1011807`，连接宿主回环 HTTPS，PHP 8.5.3 和隔离 MySQL 9.6.0，server ID 2626126。本机 HTTP 与 SQL 回执只用于合成测试结论。 |

云端仅复用已备案的 SSH 主机身份和固定主机密钥，用只读命令检查运行元数据、指定源码、受限日志和进程参数。服务器日志在远端按准许字段筛选。检查未打开实机截图像素、数据库业务行或命盘原文，也未操作手机、重提命盘、修改配置、重启服务、调用百度或探测公网 443。 [M1 固定验收报告](https://github.com/zcx369658780/EliteSync-v10/blob/1f11dc99cb011fc023c9b93d52d14f44a98421dc/docs/versions/v2/cloud-r0-20261121/V2_M1_NATAL_SAVE_READBACK_REPORT_20261126.md)

## 已存回执、时间窗与请求关联

以下为 2026-11-26 北京时间。窗口由历史回执夹定，截图时间表示当时页面已读到状态，提交及重登的准确请求时间另行分级。

| 观察项 | 证据与等级 |
| --- | --- |
| 19:54:38 后的地点补丁 | `c6945738f303b85c2ab7dbcc8f5cbd375e3e4553` 的受限部署回执为 PASS。新镜像于 20:00:27.800 启动，回执本机文件时间 20:00:30.692。仅 `staging-app` 更新，数据库、网关、队列和出站代理继续运行。部署在实机提交窗口之前。部署回执 `DIRECTLY_VERIFIED`，其与历史请求窗口连续性的结论为 `CORROBORATED`。 |
| v2 正式提交及重登范围 | 20:22:00 实体身份已核对，20:33:01 为 Owner 重登后结果摘要的截图回执，20:34:22 和 20:35:58 分别记录 v2/v2 的页面结果及重入。以 20:22:00 至 20:33:02 为历史检索窗口，外层共 13 条获准 APP HTTP 200，应用 FPM 同窗口为 2 条 POST、11 条 GET，均为 200。计数 `DIRECTLY_VERIFIED`，具体命盘请求配对 `UNKNOWN`。 |
| v3 重算候选窗口 | 从 v2 重入回执 20:35:58 至重算后首份截图 20:42:34。外层在 20:41:12、20:41:13 各有一条 `app / allowed / 200 / ok`，耗时 7.263 秒和 0.883 秒。相同窗口内，容器 `c4fd3374d566` 的 FPM 仅有 POST `/index.php` 200（20:41:12.879）和 GET `/index.php` 200（20:41:13.934），各与一条外层记录同秒。记录内容 `DIRECTLY_VERIFIED`，入口与该容器的时间配对 `CORROBORATED`，解释为 Owner 的排盘 POST 与重读 GET 属于 `INFERRED`。 |
| v3 页面重入与重登 | 20:43:27 回执直接显示输入版本 3、结果版本 3，八字 `COMPUTED_UNVERIFIED`。20:42:34 西洋盘和 20:44:05 紫微回执均记录 `CALCULATED`。Owner 明确确认重算后退出账号重登并读到三盘 v3。20:45:55 至 20:49:18 的复核区间为重登确认上下文，现存外层有 9 条获准 APP 200，应用 FPM 有 1 条 POST、8 条 GET 200。页面版本与计算状态 `DIRECTLY_VERIFIED`，重登读回为 Owner 回执与已存证据 `CORROBORATED`，具体重登请求 `UNKNOWN`。 |

外层日志此窗口仍可读，实际字段为 `time/route/source/status/upstream/seconds`。其中 `source` 是放行判定，`route` 是入口分类。外层 Nginx 配置向上游传递 `X-Request-Id`，Laravel 的追踪中间件可在响应返回该标识。留存的外层日志和 FPM 记录未保存请求 ID，FPM 路径字段实际为 `/index.php`。内层网关的现有日志格式具备方法、状态和上游字段，本窗口按该格式筛选到 0 条，未用它完成历史归因。应用源码仅对计算异常记录固定分类，缺少可关联成功请求与输入、结果版本的日志。 [请求追踪中间件](../../../../services/backend-laravel/app/Http/Middleware/RequestTraceMiddleware.php) · [命盘保存控制器](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/NatalProfileController.php)

## 专用 Staging 运行身份与 M1 源码比对

| 对象 | 现场值和证据等级 |
| --- | --- |
| 当前实例与容器 | 21:23 只读观察到 `aliyun-beta-20261122-160321`、Compose `elitesync-v2-shared-staging-beta`。业务容器 `staging-app / c4fd3374d566`，State.StartedAt 为 20:00:27.800，RestartCount 为 0。镜像 ID 为 `sha256:cf7243d010ba792aa361d1acaf1f3080d7f24e65c242a2131bf4833d0b7fd2d2`，`RepoDigests` 为空。该数值是容器实际引用的本地镜像 ID。当前身份 `DIRECTLY_VERIFIED`。 |
| 历史实例与镜像 | 部署回执中由镜像 `sha256:7019922fee8a108895614faae87a1b897c9c678deb1147d334a5a0921dab1f39` 派生当前镜像，只覆盖 3 个地点搜索文件。当前 StartAt 早于实机窗口，且独立 FPM 历史日志来自同一应用容器。历史运行身份 `CORROBORATED`。Docker 事件保留窗口未返回相关生命周期事件，未以空结果证明历史无操作。 |
| 源码等价身份 | 镜像基础 OCI 标签为 `7e0009df4fe69e48967c4fbc111717626c85ed80`，增量标签为 `c6945738f303b85c2ab7dbcc8f5cbd375e3e4553`。运行中的 `GeoController.php`、`BaiduNatalPlaceSearch.php`、`NatalAreaCatalog.php` 的 SHA-256 与后者 3 个补丁文件逐一一致。应用镜像的来源以基础标签、旧镜像、受限覆盖清单和活体哈希共同识别。标签与当前文件比对 `DIRECTLY_VERIFIED`。 |
| 保存和读回控制器 | 当前 `NatalProfileController.php` SHA-256 为 `2e5ad9624305d51bf703d8188e2febd11fb3457b032b7f34f7d4afe42cd59075`，匹配 `191e90cb`，M1 本地 `242c5b6c` 为 `079ad08f1d22c493c816055f32eeba339e392dcfbb79e1f8e30a409a682caac1`。保留旧保存验证合同，M1 新增坐标来源字段的控制器修订未进入这套 Staging 镜像。当前版本差异 `DIRECTLY_VERIFIED`，该差异适用历史实机窗口为 `CORROBORATED`。 |
| 三盘算法、路由与锁 | 另核的 12 项路由、计算与读回源码及依赖锁字节同时匹配 `191e90cb` 和 `242c5b6c`，含 `routes/api.php`、计算编排、时间与运行身份、八字、紫微、西盘及 Composer／Node 锁。具体文件一致性 `DIRECTLY_VERIFIED`。 |
| API 上游与进程 | 外层 Nginx 已存运行配置允许命盘路由，严格校验转发至回环 HTTPS 18446。专用网关 `staging-edge / 3d1595fde643` 的回环端口绑定和只读挂载配置指向 `staging-app:9000`。应用容器 PID 1 为 PHP-FPM，历史执行业务请求的 FPM 记录已核。当前关系 `DIRECTLY_VERIFIED`，历史入口到同一容器的配对 `CORROBORATED`。 |
| 三盘依赖与数据 | 当前同一应用容器实读 PHP 8.4.28、Laravel 13.39.0、Python 3.11.2、Node 22.23.5、Skyfield 1.55、iztro 2.5.8、lunar-php 1.4.7，DE440s SHA-256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`。固定 M1 报告中的 lunar-php 1.4.0 为文档版本笔误，M1 隔离实际安装清单和固定 Composer lock 均为 1.4.7。当前包版本和文件哈希 `DIRECTLY_VERIFIED`，逐请求计算运行时指纹 `UNKNOWN`。 |
| 数据库实例 | 同项目 `staging-db / dd787d366373`，MariaDB 10.11.19，运行进程参数 `--server-id=2621124`，启动为 2026-11-22 16:20:30.713。应用配置 `mariadb / staging-db:3306 / elitesync_v2_beta_staging` 与库容器配置一致，两者共享项目网络。当前进程身份及配置 `DIRECTLY_VERIFIED`，历史计算和保存连到这套项目内库 `CORROBORATED`，本轮 SQL 身份查询及命盘业务行读取 `NOT_RUN`。 |

## 证据分级及出口

| 任务目标 | 等级 | 判定 |
| --- | --- | --- |
| 1011814 固定的后端目的地 | `DIRECTLY_VERIFIED` | 归档 APK、安装及实体只读回执一致，原生和 Dart 内含同一专用 Staging 目的地。 |
| 历史窗口的处理实例、应用容器和镜像 | `CORROBORATED` | 部署回执、当前启动时间、容器历史 FPM 记录和外层同秒状态相互支持。 |
| M1 最终工程与云端保存控制器是否对应 | `DIRECTLY_VERIFIED` | 云端当前保存控制器匹配 `191e90cb`，本地 M1 最终源码为 `242c5b6c`。算法源码及依赖锁的具名样本一致。 |
| 唯一识别手机实际提交的服务端请求 | `INFERRED` | 20:41:12 的候选 POST 随后有一条同实例 GET。现有记录无法证明 POST 的原始路径、手机身份或命盘用途。 |
| 绑定 POST 的计算、保存和 GET 至同一 v3/v3 | `UNKNOWN` | 设备端 v3/v3 及三盘结果有回执。服务器留存记录没有请求 ID、输入版本、结果版本或成功计算事件，无法跨端唯一关联。 |
| 同一项目的 API、计算配置和数据库 | `DIRECTLY_VERIFIED` | 当前项目网络、FPM 进程、三个计算依赖及数据库进程配置互相对应。逐请求运行时和持久化事务身份仍为 `UNKNOWN`。 |
| 重新提交、启动新检查流量或改环境 | `NOT_RUN` | 无新增实际业务写入和受保护操作。 |

**对原 M1 的影响。** 保留合成端到端通过、南阳代表点回填与具名 1011814 正式保存、重入及 Owner 重登回执。历史实机结果支持当时 Staging 的功能闭环，其覆盖范围是旧保存控制器和已读回的三盘结果。M1 新增提交核对页、坐标来源持久化仍按已通过的本地工程范围引用。本审计以 `PARTIAL` 收尾，固定报告由 Owner 手动转交网页 GPT 顾问集中复审。总体保持 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。

## 既有证据定位

本机 M1 目录 `D:/EliteSync/development/v2-m1-natal-local-20261126`。归档 APK 原安装回执 SHA-256 `6320cef8dabcc793d80519064ee5abe8928a9d7ad26f717cd486f82ccbf1b448`，20:22 实体身份回执 `5a45555814bc8b36f623a9ee9245b37bf267305a3f62468ff2ebe7dcc8d72b75`。南阳部署回执 `v2-natal-city-staging-20261126/rollout-r3.stdout` SHA-256 `1b35a50538a691a51ef8a7afabd60afc85015b8198892bd51042619857ab1d77`。v3 重入的脱敏元数据 `owner-device-m1-20261126-private/recomputed/after-reentry.json` SHA-256 `4be5701b97654b2882312f200ca241dd02828a41c8bd230b453070df73d49ed6`。完整出生资料、截屏及服务端日志原件均留私有环境。
