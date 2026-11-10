# v10.1.5 Redmi私有API集成：检查探针错误停止，修正候选已保存｜2026-11-07

**BACKEND_READY / OBSERVER_ROUTE_ERROR_STOP / SPENT_1_REMAINING_0 / CANDIDATE_STATIC_ONLY / G2_FALSE**

本节点目标是已安装的同一源码Debug APK接通私有真实API、MariaDB与WS，使用虚构账号验证登录、文字往返、冷启T0/令牌保持及退出撤权。手机普通EliteSync调试授权持续有效；不涉及个人真实账号、其他APP/文件、安全设置、外部服务、费用或发布。

## 实际序列与失败

范围`V1015_REDMI_SOURCE_DEBUG_API_INTEGRATION_20261107_01`。最初Docker Desktop/Linux引擎未运行，入口在claim前阻断，未耗额度。Owner随后明确批准“允许启动现有 Docker/WSL2 引擎继续”；已隐藏启动现有Docker Desktop一次，Linux引擎29.9.2就绪。没有新建VM、Windows Sandbox、下载安装、工具升级或接受新许可。

继续使用同一目录、同一尚未消耗的一次额度和既有入口，未改旧合同、claim或STOP。新私有空库成功迁移至93表、种入4个虚构账号，API/WS启动，`GET /api/v1/app/health`实际返回200。随后观察器误用不存在的`GET /api/v1/me`并预期401，实际404，响应明确指出路由不存在。Codex承担该检查脚本错误；这条404不证明产品鉴权缺陷。

未进入API账号登录、手机账号提交、CN/MC、文字、冷启或退出验证，以上均NOT_RUN。本次后端实际范围**已耗1、余0、已结束，无自动重试**。`READY_SESSION_FINISHED`只说明后端准备完成并结束；外层捕获异常后exit0也不是整体验证通过。

服务源码`7fd374e8f31b67cedbfceb1c757d7d1138c81608`、services树`4530ae85754a2f3698d073182a47038708f2cb55`。沿用既有114包vendor及固定镜像，实际PHP8.4.27/Laravel13.39.0；未重新执行框架迁移工程或Composer安装。手机APK保持SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`，未重编、重装；构建源码c5e2dc34、apps树b673913。

## 限制、收尾与保护

后端容器合计内存2GiB、启动可用3072MiB、1800秒、收尾45秒、工作卷8GiB、输出2GiB采样；一次start/migrate/seed，DB restart为0。fresh可用8749MiB，后端会话49.109秒；这些是历史观测，不能用于下一次启动。

三个本任务新容器均停止/PID0/无OOM；WS/API/DB退出码分别0/137/0，API137如实保留。新卷和两条新网络留存，cleanup_errors为空。USB reverse8021/8022及本任务手机UI临时文件已移除；手机观察器累计28条ADB、2次Activity启动、0次账号提交、0次重装。剩余UI命令预算不授权重开已结束后端。

现有Docker共享引擎仍运行，未擅自关闭。引擎恢复后、本任务创建前记录的143个旧容器，与事后只读核对的完整State全部一致，均停止；未启动或exec旧容器。原dirty根main@4bebc8f3、255项状态及index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`保持。原SDK/AVD/数据库/备份/全部STOP、无关`%SystemDrive%/`保留，旧VM teardown仍UNKNOWN。

## 具体修正候选与证据界限

已执行观察器原件保持不变。独立候选仅将首条探针改为`GET /api/v1/account/sessions`、预期401；该路由在当前`services/backend-laravel/routes/api.php`的`auth:sanctum/account.active`组明确注册。新候选SHA256 `135ca9f3f1cf3538bf4378157a355d1b99751f072ad3420c037424f795ccd5cb`，路由配置Git blob `beadcad593394e921473bf67b6097d69c67b0439`。

10条计划路由模式已静态核对，纯测试拦截首请求并确认正确路径，不发真实HTTP/设备命令。前置10项集成边界及6项手机安全纯检查通过记录保留，本保存节点未重跑；冷启按新phase/cursor及actor/family绑定、最终消息数实读DB、共享45秒收尾、claim前/启动前取消保护修正保留。非作者Codex对失败原证及唯一探针修正复核无新可行动P1/P2；非外部独立验收。**真实401与完整修正后集成NOT_RUN**，未建立后继scope/grant/claim。

LOCAL_ONLY根名`v1015-redmi-source-debug-api-integration-20261107-case01`；先读`IMPLEMENTATION_REPORT.md`、`backend-session-outcome-private.json`、`integration-engine-resume-01-failure-private.json`、`integration-engine-resume-01-cleanup-private.json`、`next-candidate-probe-path-manifest-private.json`和最终本地/Git回执。原始设备、口令、SQL、日志及源码快照不上GitHub。保护ledger承接17687项，仅追加本节点原证，不重扫旧SDK/AVD/Sources。

下一实际运行须另授**修正探针候选一次受控后端额度**；既有手机调试和现有Docker引擎启动权限不重问，也不重建APK。旧一次余额和STOP不恢复、不换目录续额。仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING；不合main、不发布、不启v10.1.6。
