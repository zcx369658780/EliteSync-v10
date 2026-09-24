# EliteSync v10｜TASK_CURRENT

Task ID: `SEC-05-AUTH-INTERCEPTOR-TOKEN-PRINT-REMOVAL`

Risk Level: `LEVEL 2`（请求 bearer Token 暴露风险；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。交付一处有界修复候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-07 Work LEVEL 2 独立验收在 `apps/flutter_elitesync_module/lib/core/network/interceptors/auth_interceptor.dart:21–26` 确认完整 bearer Token 被调试 `print` 输出。该字符串可能进入设备/开发日志，须停止输出。Owner 此前已授权 SEC-01～04 移除识别出的私密调试输出；本任务依当前已确认的同类风险作单点修复，不扩大为全项目日志审计。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 `EVIDENCE/AUTH-07-LOCAL-LOGIN-REFRESH-T0-GAP-MAP/summary.md`。只有本任务仍为 `ISSUED` 且派发匹配才执行。

仅移除 `AuthInterceptor.onRequest` 内的 `AUTH_INTERCEPTOR_TOKEN` 打印及专为它存在的注释/忽略指令；保留 token provider、Authorization header、401 retry 和错误传递的现有行为。不增加替代 token 片段、hash、长度或响应日志，不改 auth/T0/15/30 天逻辑。

## Scope and verification

允许修改的源码只有 `apps/flutter_elitesync_module/lib/core/network/interceptors/auth_interceptor.dart`；唯一允许新增 `EVIDENCE/SEC-05-AUTH-INTERCEPTOR-TOKEN-PRINT-REMOVAL/summary.md`。核对差异为删除输出语句，定向检查该文件不再有 `AUTH_INTERCEPTOR_TOKEN` 或打印 Token 的语句，且 Authorization header 仍按原逻辑设置。可运行一次该精确文件的 Dart/Flutter 静态分析；若工具不可用，记录 NOT RUN，不扩大测试。只运行一次 `git diff --check`，新文档另作尾随空白检查。无需新增镜像实现的测试。

不读取实际 Token、设备日志、`.env`、私钥、用户/媒体数据；不连接服务器、HTTP/API、DB 或设备；不修改其他文件、部署或路由，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；这只消除一处已识别泄漏，不证明全项目日志安全。
