# EliteSync v10｜TASK_CURRENT

Task ID: `SEC-04-LOGIN-ERROR-LOG-REMOVAL`

Risk Level: `LEVEL 2`（登录异常可能带敏感内容；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。SEC-01～03 已独立 ACCEPT；本任务只交付候选，不自接受、不下达后继。

## Objective / allowed paths

删除 `apps/flutter_elitesync_module/lib/features/auth/presentation/providers/login_form_provider.dart` 中 `LoginFormNotifier.submit()` 的 `LOGIN_FAIL $e` 调试输出及仅为该输出存在的 ignore/注释。保留 `catch` 分支的错误状态赋值、异常处理及其它登录控制流不变；不得记录异常对象的部分字符串以代替原输出。唯一允许修改的产品路径是该文件；可新增 `EVIDENCE/SEC-04-LOGIN-ERROR-LOG-REMOVAL/summary.md`。不得修改其它认证/网络源码、测试、依赖、配置或旧接受记录。

## Acceptance criteria / verification budget

静态核对删除日志后错误状态和返回流程保持原样；所改文件不再输出该动态异常。一次 `git diff --check`、一次所改文件定点搜索和一次差异核对即可；工具链可用时可做一次该文件的有界 Dart analyze。仅删除日志无需新增镜像测试；不运行 Flutter 全量测试、Android build、设备、API/DB 或网络。回执给出精确基线 HEAD、改动 blob、实际检查及未运行项。其他疑似敏感输出只报告，不扩大写集。

## Stop conditions / review

若删除日志会改变错误处理或正式流程依赖其输出，停止并报告。不得读取实际令牌、手机号、环境秘密、app-private data 或设备日志；保留无关 untracked 目录。不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。完成后停在 Work LEVEL 2 独立验收门。旧聊天缓存 containment 另立任务。
