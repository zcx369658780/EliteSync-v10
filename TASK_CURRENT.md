# EliteSync v10｜TASK_CURRENT

Task ID: `SEC-01-ACCESS-TOKEN-LOG-REMOVAL`

Risk Level: `LEVEL 2`（认证秘密日志暴露的单点修复；须由 Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。Work 在准备 Owner 已授权的旧聊天缓存清理时，发现共用 `accessTokenProvider` 打印非空访问令牌；先执行本极窄修复，再回到缓存 containment。本任务只交付候选，不自接受或派发后继。

## Objective / allowed paths

移除 `apps/flutter_elitesync_module/lib/shared/providers/app_providers.dart` 中 `accessTokenProvider` 读取到非空 token 后的值打印，包括只为该打印存在的注释/ignore。保留 provider 返回 token、依赖注入和其它认证行为不变。只允许修改该源码路径，以及新增 `EVIDENCE/SEC-01-ACCESS-TOKEN-LOG-REMOVAL/summary.md` 短回执；不修改 auth/网络其它源码、测试、依赖、配置或旧接受记录。不得读取实际 token、环境秘密、app-private data 或设备日志。

## Acceptance criteria / verification budget

静态核对改动前后 `accessTokenProvider` 的非日志控制流一致，所改路径不再将 token 值输出到 print/logger。限定搜索 `app_providers.dart` 与直接相邻的本地认证 provider 调用，若发现其他具体 secret-value 输出只报告路径，不扩大写集。`git diff --check` 与定点 `rg` 各一次即可；由于仅删除日志分支，无需新增镜像实现的测试。若工具链已可用，可运行一次该文件的有界 Dart analyze；不运行 Flutter 全量测试、Android build、API/DB/设备。回执准确标注实际检查与未运行项。

## Stop conditions / review

若移除打印会改变 token 读取/返回或存在依赖该输出的正式流程，停止并报告；不得为保留日志而脱敏一部分真实 token。保留无关 untracked 目录；不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。完成后停在 Work LEVEL 2 独立验收门。旧聊天缓存清理另立任务，不由本任务启动。
