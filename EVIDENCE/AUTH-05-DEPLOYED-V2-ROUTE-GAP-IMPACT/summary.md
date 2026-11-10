# AUTH-05｜部署 v2 路由差异的本地静态影响清单

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发及执行基线 HEAD `d0e9b42cabba6a5feec17c7befefefbfcb17c838`。工作区原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留；本轮唯一新增文件为本回执。

## 依据与读法

AUTH-04 已获 Work LEVEL 2 接受的**源码事实**：其当次读取的部署 `routes/api.php` 相对本地缺少以下四条 v2 POST 声明及三个 import，多一条 v1 media `process-demo` 声明；这不是服务器当前路由表、HTTP 结果或部署版本的运行证明。当前本地四条声明位于 `services/backend-laravel/routes/api.php:34–42` 的 `v2`、`secure.transport` 组。下表的“若运行路由也缺少”均为**条件性影响**，不把源码差异直接写成线上故障。

| 本地 v2 POST；静态 controller | 已知本地直接消费与接受边界 | 若运行路由也缺少；尚未知 |
|---|---|---|
| `/api/v2/contracts/application-envelope`；`routes/api.php:38` → `app/Http/Controllers/Api/V2/Contracts/TransportEnvelopeController.php:10–18`，`__invoke` 把 JSON body 交给 transport `handle()`。 | `tests/Feature/Api/V2/TransportEnvelopeTest.php:15–35,47–57` 直接枚举该路由并 `postJson`；`docs/architecture/ELITESYNC_V10_LARAVEL_HTTP_TRANSPORT_ADAPTER_IMPLEMENTATION_ACCEPTANCE_V0_1.md:42–60` 接受仅 transport 的 v2 入口，明确不建立 auth/生产权限。 | 这些精确 URI 的合成 HTTP 测试所依赖的入口将不能按本地路由声明分发到该 controller；实际服务是否有缓存路由、替代注册、调用量或返回码 **UNKNOWN**。不能据此说 transport/domain 代码或数据已消失。 |
| `/api/v2/canonical-match/evaluations`；`routes/api.php:39` → `app/Http/Controllers/Api/V2/CanonicalMatch/CanonicalMatchEntryController.php:195,231–232` 的 `evaluate` / `evaluateSynthetic` 分支。 | `tests/Feature/Api/V2/CanonicalMatchEntryTest.php:17,23–63,103,147` 枚举并调用评估入口；`docs/architecture/ELITESYNC_V10_IP_13I_R14_CANONICAL_MATCH_SYNTHETIC_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md:48–78` 接受独立 synthetic/dev-test 入口。 | 若活跃路由表也无此 URI，本地接受的评估 HTTP 入口无法由该精确路径触达；是否有真实客户端调用、其他运行注册或影响范围 **UNKNOWN**，不等于 Canonical Match 权威或生产匹配已中断。 |
| `/api/v2/canonical-match/invalidations`；`routes/api.php:40` → 同一 `CanonicalMatchEntryController.php:200,231–232` 的 `invalidate` / `invalidateSynthetic` 分支。 | 同一 `CanonicalMatchEntryTest.php:19,23–63,202,320` 枚举并调用失效入口；同一 R14 接受文档 `:48–78` 将其列为第二条独立 synthetic/dev-test 路由。 | 若活跃路由表也无此 URI，该精确 HTTP 失效入口不能按本地路由声明分发；不能推断已有生产失效请求、撤权传播或真实保护动作失败，均待独立运行证据。 |
| `/api/v2/runtime-readiness/evaluations`；`routes/api.php:41` → `app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php:110–155` 的 `__invoke` / `evaluateSynthetic`。 | `tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php:16,19–45,72` 枚举并调用入口；`docs/architecture/ELITESYNC_V10_IP_13I_R7_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md:34–49` 接受 synthetic domain→HTTP 垂直片。 | 若活跃路由表也无此 URI，本地接受的合成 Readiness HTTP 路径不能经该声明触达；实际生产 readiness、路由缓存、调用量和响应 **UNKNOWN**。 |

上述三份 Feature 测试是本地已知的精确 URL 调用方；对应 controller 和应用 adapter 的存在只能证明本地实现，不证明部署文件或运行注册。对这四个完整 URL 在限定的 `apps/flutter_elitesync_module/lib` 与 `services/backend-laravel/app` 中作精确搜索，**未定位到字面量调用点**；这不是全仓或线上无调用方证明。代码图谱虽有本项目索引，但对这些 PHP controller 符号返回 0 节点；因此使用任务允许范围内的精确文件和符号搜索，不以图谱空结果推断无代码。

## 远端多出的 media 声明

AUTH-04 的静态差异记录远端多出 `POST /{assetId}/process-demo`，位于 v1 media 组。本地 `routes/api.php:132–138` 无同名声明；限定搜索中，`tests/Feature/MediaProcessingPipelineTest.php:90–91` 是已定位到的同路径调用，并明确期望本地 `NotFound`。本地 `app/Http/Controllers/Api/V1/MediaController.php` 中未定位到同名 `processDemo` 方法。未读取远端 controller、运行路由表或请求行为，故不判断服务器是否能执行、返回什么或是否有真实调用方。

## 后继门与本轮检查

可在纯本地事实层关闭的仅是：当前本地路由、controller、合成 Feature 调用和接受文档之间的对应关系，以及 AUTH-04 已接受的指定部署文件差异。若需确认**当前**服务器加载的路由、请求是否触达、HTTP 结果、调用方或部署修复影响，必须由 Work/Owner 另立有界授权与相应风险门；本任务不选部署方案。`secure.transport` 不是身份/权限证明，四条 synthetic/dev-test 入口不建立真实身份、Match/Readiness 权威、生产持久化或数据权利。

本轮未连接服务器，未使用 SSH、HTTP/API、`php artisan`、DB、设备或真实数据；未读取私钥、`.env`、日志、Token、用户/媒体数据，未修改代码、路由或部署。未运行产品测试或构建。`git diff --check` 按预算运行 **1/1 次，退出 0**；新文档另作只读尾随空白检查，**0 行**。作者不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地静态影响清单。** Work 核对唯一新增证据路径、发布基线 `d0e9b42cabba6a5feec17c7befefefbfcb17c838`、四条本地路由声明、三份 controller、三份 Feature 测试及其精确 URL、三份接受文档存在；媒体测试确对 `process-demo` 期望 404。新文档无尾随空白，未见代码或受保护无关目录改动。候选将服务器运行状态和实际调用方保持 UNKNOWN，没有把 synthetic/dev-test 入口写成生产权限。

下一步若要确认服务器当前加载的路由或请求行为，需要另立精确只读服务器任务并取得 Owner 对该范围的授权。AUTH-04 的一次源码读取授权不延伸至该动作；本验收不授权改部署、调用 API 或读取真实数据。
