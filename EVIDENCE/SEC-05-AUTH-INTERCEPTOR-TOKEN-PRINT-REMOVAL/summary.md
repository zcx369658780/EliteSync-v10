# SEC-05｜AuthInterceptor Token 打印移除

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，`main`，派发基线 HEAD `3d74f7da45c18f5012d38c7de6a447d960f7284b`。类型：Flutter 客户端 auth 安全单点修复；不涉及 backend、DB 或 release-chain。

## 变更与边界

唯一源码变更：`apps/flutter_elitesync_module/lib/core/network/interceptors/auth_interceptor.dart` 的 `AuthInterceptor.onRequest` 删除 `AUTH_INTERCEPTOR_TOKEN` 完整 bearer Token 打印，以及专为该打印存在的调试注释和 `avoid_print` 忽略指令。diff 仅删除这三行。原有 token provider、`Authorization: Bearer` 请求头设置、401 条件重试与错误传递代码保留。本轮不修改 T0、15/30 天期限、缓存、路由或服务端。

负向边界：对该精确文件的定向检查未发现 `AUTH_INTERCEPTOR_TOKEN` 或 `print(`；这不等于全项目日志审计。未读取实际 Token、设备日志、`.env`、私钥或用户/媒体数据；未连接服务器、HTTP/API、DB 或设备。无需新增镜像测试；未运行构建或设备验证。

## 验证回执

| 检查 | 结果 |
|---|---|
| 精确源码 diff | 仅删除调试注释、`avoid_print` 忽略指令和完整 Token 打印三行；请求头赋值与 401 路径未改。 |
| 定向标记/打印检查 | `PASS`：该文件没有 `AUTH_INTERCEPTOR_TOKEN` 或 `print(`。 |
| `dart analyze lib/core/network/interceptors/auth_interceptor.dart` | 运行 1 次，退出码 0，`No issues found!`。 |
| `git diff --check` | 按预算运行 1 次，退出码 0；仅有 Git 的 LF/CRLF 工作区转换提示，无 whitespace 错误。该命令不检查新增的未跟踪文档。 |
| 新文档尾随空白 | 单独只读检查：0 行。 |

原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。候选不提交、不备份、不推送、不自接受、不派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。回退可恢复这三行，但会重新引入完整 Token 打印；若审查拒绝，应按审查意见处理，不在本任务自行扩大范围。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受这一处完整 bearer Token 输出移除。** Work 核对发布基线 `3d74f7da45c18f5012d38c7de6a447d960f7284b` 和源码 diff：恰好删除调试注释、`avoid_print` 与 Token 打印三行，`Authorization` 赋值及 401 分支未改；定向检查该文件已无 `AUTH_INTERCEPTOR_TOKEN`/`print(`。作者的一次精确文件 `dart analyze` 报告退出 0、无问题；Work 独立核对暂存差异与新文档尾随空白，未重复运行分析。无其他任务源码改动，无关未跟踪目录保留。

这是静态代码与定向分析结论，未观察设备日志或已分发版本；不能据此认定旧日志已清除或全项目不存在其他敏感输出。AUTH-07 所列可信 T0、15 天期限、30 天密文清理和真实认证缺口仍未解决。
