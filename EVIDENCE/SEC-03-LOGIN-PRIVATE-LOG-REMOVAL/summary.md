# SEC-03｜登录手机号日志移除候选

状态：**Work LEVEL 2 ACCEPT**。作者本地 `main` 基线 `bd3b2ab3caa6b96c018361f44e339cc7c96967e2`；作者未提交、自接受或派发后继。

## 精确差异

唯一修改 `apps/flutter_elitesync_module/lib/features/auth/presentation/providers/login_form_provider.dart`，前 blob `14ef367ef046f369c8b33db0395bbcb89ea867ea`，候选工作区 blob `0e19ccc7ce55ab34d38ad51981d448885c57d47e`。在 `LoginFormNotifier.submit()` 仅删除 `LOGIN_SUBMIT`、`LOGIN_OK` 两处输出手机号值的调试语句与其专属 `ignore: avoid_print`。登录请求、session/token/用户处理、profile 刷新、错误状态和返回路径保持原样。

## 检查与保留风险

- 定点 `git diff`：只见上述两处日志删除；无非日志控制流变化，未发现正式流程依赖该输出。
- `git diff --check`：**1 次，退出 0**。Git 的 LF/CRLF 工作副本提示不是检查失败。
- 修改文件定点搜索 `LOGIN_SUBMIT|LOGIN_OK|LOGIN_FAIL|print(`：**1 次**；前两个标识无命中，仍命中原有 `LOGIN_FAIL $e`。它按任务保持不变。
- `LOGIN_FAIL $e` 的 `$e` 是动态错误对象。只凭该文件不能证明其字符串表示永不含请求字段、服务端回显或个人标识；本轮分类为**可能的敏感输出，具体内容 UNKNOWN**，已报告 Work。没有为探查而运行登录、读取真实数据或扩大写集。
- 未运行 Dart analyze（仅删除两处输出，静态差异与定点搜索已核对）、Flutter 测试、Android/设备、HTTP/API、DB、网络或旧缓存清理；未读取实际令牌、手机号、环境秘密或 app-private data。

根目录原有无关 untracked 保留原状。本回执是唯一新增文件；候选停在 Work LEVEL 2 ACCEPT/REJECT 门。`LOGIN_FAIL` 的风险处置及旧聊天缓存 containment 均须另行定界。

## Work 独立验收（2026-09-23）

**ACCEPT — 限两处手机号值日志。** Work 核对基线、源码与回执 blob，与作者记录一致；独立复核差异仅删 `LOGIN_SUBMIT`/`LOGIN_OK` 及专属 ignore，登录请求、session 写入和错误状态未改。`git diff --check` 退出 0；定点搜索确认两个标识消失。`LOGIN_FAIL $e` 仍在，其内容由动态异常决定，不能认定为安全；另立 SEC-04。未读取真实账户数据、运行登录、产品测试或构建。
