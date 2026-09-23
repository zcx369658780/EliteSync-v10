# EliteSync v10｜TASK_CURRENT

Task ID: `CACHE-02-LEGACY-PRIVATE-CACHE-PURGE`

Risk Level: `LEVEL 2`（旧未加密私密值精确删除、启动及账户边界；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。CACHE-01 已由 Work 独立 ACCEPT 并进入本地 `main`；本任务只交付候选和证据，不自接受、不提交、不派发后继。Owner 已授权旧未加密聊天草稿、会话快照/预览和搜索历史不迁移并可清除，含可能丢失的未发送草稿；授权不包括账户、Token 或其他缓存。

## Objective / allowed paths

实现一条幂等的旧私密缓存精确清除路径：仅删除所有以 `chat_draft_` 开头的 SharedPreferences 键，以及 `messages_conversation_snapshot_v1`、`messages_search_history` 两个固定键。升级后在应用展示前执行；登出、换账户/新登录及现有会话失效路径也调用同一清理逻辑。仅枚举键名判断范围，不读取、解析、迁移、输出旧值或动态键名；不使用 `SharedPreferences.clear()`、安全存储 `deleteAll()` 或以宽泛账户缓存清理代替本任务。空存储和重复调用应安全，部分失败不能标作清理完成；下一次启动或账户边界仍可重试。CACHE-01 的禁读写屏障必须保持。

仅允许修改或新增以下路径（均位于 `apps/flutter_elitesync_module/` 下）：

- `lib/core/storage/local_storage_service.dart`
- `lib/app/bootstrap/app_bootstrap.dart`
- `lib/features/auth/data/datasource/auth_local_data_source.dart`
- `lib/shared/providers/session_provider.dart`
- 如共同 bootstrap 的异步签名确需适配：`lib/main_dev.dart`、`lib/main_prod.dart`、`lib/main_demo.dart`
- 既有 `test/features/auth/data/datasource/auth_local_data_source_test.dart`、`test/android_runtime_bootstrap_test.dart`、`test/session_provider_birth_place_test.dart`
- 新增 `test/core/storage/legacy_private_cache_cleanup_test.dart` 和/或 `test/legacy_private_cache_lifecycle_test.dart`
- 新增 `EVIDENCE/CACHE-02-LEGACY-PRIVATE-CACHE-PURGE/summary.md`

不触碰聊天页面、账户/Token 的既有存取语义、其他缓存类别、真实设备值、登录 UI、后端、DB 或网络。既有 `AuthLocalDataSource._clearAccountScopedCaches()` 涉及多个非授权类别，只能维持原有行为，不可将它接入升级清理或据此扩大本任务删除集合；其现有 `remove(CacheKeys.chatDraftPrefix)` 只针对裸前缀，不能替代动态键清理。`SessionNotifier.setUnauthenticated()` 有直接调用者，账户退出覆盖需核对该路径。

## Acceptance criteria / verification budget

- synthetic 测试覆盖至少两种动态草稿键（peer/conversation 形态）、裸前缀键、两个固定键；清除后这些键不存在，近似非匹配键、账户资料、Token 哨兵、列表偏好及其他缓存仍保持原值。区分专用清理器的范围与既有登出动作本来的其他清理。
- 覆盖空存储、重复调用、畸形旧值类型、单键删除失败/异常后的可见失败与重试；不得静默报告完成，也不得把私密正文或动态键名写入日志/证据。
- 用 synthetic 调用路径证明 prod/dev/demo 共用的启动门在展示前清理，以及既有登出、账户替换和直接 `setUnauthenticated()` 路径；如清理失败，保持旧值禁读写，记录有限的非私密失败结果并可重试，不宣称设备已擦除。
- 运行新增/改动的相关 targeted Flutter tests 各一次和 `git diff --check` 一次；失败先定位，必要时按具体风险补一次受限复验。可运行有界 analyze；不做全量 Flutter/Android、设备、HTTP/API、DB 或网络。回执写明精确基线、改动路径/blob、检查结果、失败与未运行项。

## Stop conditions / review

若需要清除更多类别、修改账户或 Token 生命周期、读取真实设备值、选择新加密缓存/保留期限/离线访问政策，或现有入口无法在允许路径内安全实现精确清除，则停止并报告调用路径与风险，不自行扩大范围。根目录无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状；不访问旧 `D:\EliteSync`，不拉取/推送 GitHub，不提交或备份。候选停在 Work LEVEL 2 独立验收门。
