# SEC-04｜登录动态异常日志移除候选

状态：**Work LEVEL 2 ACCEPT**。作者本地 `main` 基线 `fdc783b926bf8feb19bf4e728f2f2f84ed557fe7`；作者未提交、自接受或派发后继。

## 精确差异

唯一修改 `apps/flutter_elitesync_module/lib/features/auth/presentation/providers/login_form_provider.dart`，前 blob `0e19ccc7ce55ab34d38ad51981d448885c57d47e`，候选工作区 blob `9641499249a0aa6cf26581cbb10d7357230d014a`。只删除 `LoginFormNotifier.submit()` 的 `LOGIN_FAIL $e` 调试输出及其专属 `ignore: avoid_print`。`catch (e)`、`authErrorMapperProvider.mapToUserMessage(e)`、`submitError` 状态赋值和 `return false` 保持原样；没有输出异常对象的替代片段。

## 实际检查

- 定点 `git diff`：仅两行删除，错误处理与登录控制流无变化；未发现正式流程依赖该调试输出。
- `git diff --check`：**1 次，退出 0**；Git 的 LF/CRLF 工作副本提示不是检查失败。
- 修改文件定点搜索 `LOGIN_FAIL|print(`：**1 次，无命中**。结论限该文件，不宣称全项目日志审计完成。
- 未运行 Dart analyze（仅删除日志语句，静态差异已核对）、Flutter 测试、Android/设备、HTTP/API、DB、网络或旧聊天缓存清理；未读取实际令牌、手机号、环境秘密或 app-private data。

根目录原有无关 untracked 保留原状。本回执是唯一新增文件；候选停在 Work LEVEL 2 ACCEPT/REJECT 门。旧缓存 containment 属另行任务。

## Work 独立验收（2026-09-23）

**ACCEPT — 限登录异常对象日志移除。** Work 核对基线、源码与回执 blob，与作者记录一致；独立复核差异仅删 `print('LOGIN_FAIL $e')` 及专属 ignore，`catch`、错误映射、状态赋值与 `return false` 不变。`git diff --check` 退出 0；所改文件定点搜索无 `LOGIN_FAIL` 或 `print(` 命中。此验收不等于全项目日志审计，未运行真实登录、产品测试或构建。
