# EliteSync v10｜TASK_CURRENT

Task ID: `SEC-02-SESSION-PRIVATE-LOG-REMOVAL`

Risk Level: `LEVEL 2`（认证令牌及个人标识日志暴露；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。SEC-01 已独立 ACCEPT；本任务只交付候选，不自接受、不下达后继。

## Objective / allowed paths

删除 `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart` 内会输出访问令牌**值**或手机号**值**的调试日志及仅为这些日志存在的注释/ignore。具体包括 `SessionNotifier.build()` 中的 `SESSION_BOOT_TOKEN` assert 分支和 `setAuthenticated()` 中的 `SESSION_SET_AUTH` print。保留 token/profile 读取、写入、状态转换和返回逻辑；不得以部分脱敏值替换。唯一允许修改的产品路径是该文件；可新增 `EVIDENCE/SEC-02-SESSION-PRIVATE-LOG-REMOVAL/summary.md` 回执。不得修改 `login_form_provider.dart`、其它认证/网络源码、测试、依赖、配置或旧接受记录。

## Acceptance criteria / verification budget

核对两个日志删除前后的非日志控制流一致，所改文件不再输出 token/手机号值。只作一次 `git diff --check`、一次所改文件定点搜索，并核对差异；若工具链已可用，可运行一次该文件的有界 Dart analyze。由于仅删除输出语句，无需新增镜像实现的测试；不运行 Flutter 全量测试、Android build、设备、API/DB 或网络。回执给出精确基线 HEAD、改动文件 blob、实际检查和未运行项。可限读直接相邻的 `login_form_provider.dart` 识别剩余日志，但只报告，不扩大写集，也不要输出实际用户数据。

## Stop conditions / review

若删除日志会改变认证状态或有正式流程依赖日志，停止并报告。不得读取实际令牌、环境秘密、app-private data 或设备日志；保留无关 untracked 目录。不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。完成后停在 Work LEVEL 2 独立验收门。后续旧聊天缓存 containment 与 `login_form_provider.dart` 日志另由 Work 定界。
