# EliteSync v10｜TASK_CURRENT

Task ID: `SEC-03-LOGIN-PRIVATE-LOG-REMOVAL`

Risk Level: `LEVEL 2`（登录手机号日志暴露；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。SEC-01/02 已独立 ACCEPT；本任务只交付候选，不自接受、不下达后继。

## Objective / allowed paths

删除 `apps/flutter_elitesync_module/lib/features/auth/presentation/providers/login_form_provider.dart` 的 `LoginFormNotifier.submit()` 中 `LOGIN_SUBMIT` 和 `LOGIN_OK` 两处输出手机号值的调试日志，以及仅为这些输出存在的注释/ignore。保留登录调用、token/用户处理、错误状态和导航逻辑不变。唯一允许修改的产品路径是该文件；可新增 `EVIDENCE/SEC-03-LOGIN-PRIVATE-LOG-REMOVAL/summary.md`。`LOGIN_FAIL $e` 暂不属于本任务写集，需在回执中说明其错误对象是否可能携带敏感内容的静态可判断程度；不得为了探查而运行登录或读取实际数据。不得修改其它认证/网络源码、测试、依赖、配置或旧接受记录。

## Acceptance criteria / verification budget

静态核对两处日志删除前后的非日志控制流一致，所改文件不再通过这两个标识输出手机号值。一次 `git diff --check`、一次所改文件定点搜索和一次差异核对即可；工具链可用时可做一次该文件的有界 Dart analyze。仅删除输出无需新增镜像测试；不运行 Flutter 全量测试、Android build、设备、API/DB 或网络。回执给出精确基线 HEAD、改动 blob、实际检查及未运行项。其他疑似敏感输出只报告，不扩大写集。

## Stop conditions / review

若删除日志会改变登录流程或有正式流程依赖输出，停止并报告。不得读取实际令牌、手机号、环境秘密、app-private data 或设备日志；保留无关 untracked 目录。不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。完成后停在 Work LEVEL 2 独立验收门。旧聊天缓存 containment 另立任务。
