# SEC-01｜accessTokenProvider 令牌值日志移除候选

状态：**Work LEVEL 2 ACCEPT**。作者本地 `main` 基线 `78c042a484d17c26369f3933d94dafcf1fb571a1`；作者未提交或自接受。

## 改动与边界

- 唯一修改：`apps/flutter_elitesync_module/lib/shared/providers/app_providers.dart`。前 blob `c1228beb511341ccff4219ade67ec0e70fbc0c04`，候选工作区 blob `5d6dc5b3a126ba85c00d5b0dab4a50e873009aef`。只删除 `accessTokenProvider` 在读到非空 token 后将**值**打印的条件分支及专为打印存在的注释/ignore；`secureStorageProvider.read(CacheKeys.accessToken)`、`return token`、依赖注入和 refresh provider 均保持原有控制流。
- 本回执为唯一新增路径。未更改其他认证、网络、测试、依赖或配置文件。未读取或输出实际令牌、环境秘密、设备日志或 app-private data。

## 实际核验

- `git diff -- apps/flutter_elitesync_module/lib/shared/providers/app_providers.dart`：仅上述 5 行删除；未看到依赖该打印的正式流程。
- `git diff --check`：**1 次，退出 0**；Git 对工作副本 LF/CRLF 给出提示，不是空白检查失败。
- 定点 `rg -n 'print\(|logger|token='`：**1 次**，范围仅改动文件及直接相邻的 `session_provider.dart`、`login_form_provider.dart`。改动文件不再含 token 值 print/logger 分支。**另发现** `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart` 的 `SessionNotifier.build()` debug assert 仍会打印非空访问令牌的值；已立即报告 Work，属于本任务禁止修改的相邻路径，不能把 SEC-01 候选称作全项目令牌日志清零。`login_form_provider.dart` 的 `LOGIN_OK` 只打印 token 是否非空的布尔结果，不打印 token 值；其账号字段输出也未在本任务中处理。
- 本轮未运行 Dart analyze：改动仅删除输出分支，定点静态差异已足以核对返回路径；未运行 Flutter 测试、Android/设备、HTTP/API、DB、网络或旧缓存清理。

## 未决与停点

相邻 `session_provider.dart` 的令牌值打印需另行精确授权和审查。旧未加密聊天缓存 containment 属独立后继，不由 SEC-01 启动。根目录原有无关 untracked 保留原状；候选停在 Work LEVEL 2 ACCEPT/REJECT 门。

## Work 独立验收（2026-09-23）

**ACCEPT — 限 `accessTokenProvider` 的令牌值日志移除。** Work 核对基线 HEAD、候选源码与回执 blob 均与作者记录一致；独立复核差异仅删除非空令牌打印及其专用注释，`secureStorageProvider.read(CacheKeys.accessToken)`、`return token` 和相邻 provider 绑定不变。`git diff --check` 退出 0。此验收只证明该路径不再输出令牌值，不代表认证日志全局清零，也不证明运行时或发布行为。相邻 `session_provider.dart` 仍有令牌值及手机号输出，另立 SEC-02。未读取实际令牌或设备数据；未运行产品测试或构建。
