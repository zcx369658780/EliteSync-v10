# CACHE-02｜旧私密缓存精确清除候选

Status: `WORK LEVEL 2 ACCEPT`
Risk: `LEVEL 2 / Flutter local privacy cleanup`
Baseline: local `main` HEAD `4a3d9a37366d0c71a10aea6e9f725743767192bd`。本候选未提交、未自接受、未备份或推送。

## 结果与边界

- `LocalStorageService.purgeLegacyPrivateChatCache()` 仅枚举键名并删除 `chat_draft_` 前缀的全部键及 `messages_conversation_snapshot_v1`、`messages_search_history`。不读取、解析、迁移或输出旧值和动态键名；未使用 `clear()` 或安全存储 `deleteAll()`。
- 所有目标删除成功时，专用清理器才正常返回；键枚举、单键删除返回 `false` 或抛异常时，抛出不含值和动态键名的通用失败。边界调用器把结果记为 `false`，仅输出固定的非私密失败提示，继续原有启动或账户操作；已成功删除的键保持删除，下一次边界可重试。空存储和重复调用安全。
- prod/dev/demo 均通过共同 `runEliteSyncApp`，等待清理尝试完成后才展示应用。启动清理失败后继续展示；已接受的 CACHE-01 页面禁读写屏障仍在。不宣称设备旧值已擦除。
- `AuthLocalDataSource.persistSession/clearSession` 在既有账户缓存逻辑前尝试精确清理；直接 `SessionNotifier.setAuthenticated/setUnauthenticated` 也使用同一清理器。清理失败不会阻断既有 Token 写入、删除或直接会话失效。既有 `_clearAccountScopedCaches()` 保持原行为，没有被接入升级清理。
- 未读取或清理真实设备值；未改聊天页面、账户/Token 的既有存取类别、其他缓存类别、登录 UI、后端、DB 或网络。根目录无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。

## 路径与对象标识

以下路径均在 `apps/flutter_elitesync_module/` 下。`—` 表示新增测试、基线没有对应 blob。

| 路径 | 基线 blob | 候选工作区 blob |
|---|---|---|
| `lib/core/storage/local_storage_service.dart` | `6f7e67f4fa65e7c010a4250e78314801a9c44351` | `c6be5824c3cebd0cdb7fe043610fb14f2fd054c5` |
| `lib/app/bootstrap/app_bootstrap.dart` | `8d85959ea355213820881015ea822eeebf1b6007` | `d5d2335e64d48a3b8fe0754d8878a21cfae2988c` |
| `lib/features/auth/data/datasource/auth_local_data_source.dart` | `b07045b16c8a818da65aae75f3df2d94a8ca8e9d` | `315d682361389136ff5ec7bb65af9c86f01cab5d` |
| `lib/shared/providers/session_provider.dart` | `a60d6e5d8ab89e937d5d6cda3fa415599d581ef5` | `999c0b64e3037797449964fcaeb4415f2eb99ebc` |
| `lib/main_dev.dart` | `746c80cfdd881b495dcd42045e3cd7021be72920` | `4df807753694105f3af1b4e753a28f25b8cb83fb` |
| `lib/main_prod.dart` | `86c7bde6387379921c3450df8523f5b28f0ea95c` | `eb9634edf4b614eeecafcedfaa4ca0d223d4ab75` |
| `lib/main_demo.dart` | `a35cbf3f116c91c2db6dbe06a4494082624042e0` | `eea9a39de368f70ffbb4bdfaebc1c37a44c72aeb` |
| `test/features/auth/data/datasource/auth_local_data_source_test.dart` | `8791d88bce531743b675ec36fa5442a13b21ac05` | `8ee664ff6857e3e2816417536dd8ebb132dab48d` |
| `test/android_runtime_bootstrap_test.dart` | `e880b1210ebe61de7855794b2a3e9435add8eba5` | `f35d00cd5ea37267516bd92ebf580f2fa197e06a` |
| `test/core/storage/legacy_private_cache_cleanup_test.dart` | — | `d68f0fdc7f5af1f92af124ba8e642da7694d7e50` |
| `test/legacy_private_cache_lifecycle_test.dart` | — | `cf285f2df2c730b65d041b3d3d0e225a8c6ef5de` |

## 验证回执

工作目录：`D:\EliteSync-v10\apps\flutter_elitesync_module`。`flutter test --no-pub` 未解析或下载依赖。

| 检查 | 次数 | 结果 |
|---|---:|---|
| 四个相关 targeted Flutter test 文件，一次合并执行 | 1 | PASS，13 tests；覆盖精确键集、非匹配/账户/Token/偏好哨兵、畸形值、空存储、重复调用、删除 `false`/异常与重试、共同启动门、登录替换、登出和直接会话路径。 |
| 受限复验：清理器及会话生命周期两个测试文件 | 1 | PASS，7 tests；针对后续会话失效失败路径与稳定键枚举修改。无测试失败。 |
| Work 预审风险修正后的四个相关 targeted Flutter test 文件 | 1 | PASS，16 tests；失败注入证明清理故障不阻断既有登录替换、登出 Token 删除或直接会话失效，失败结果为固定非私密提示；无测试失败。 |
| 11 个改动源码/测试文件的 bounded `dart analyze` | 1 | PASS，0 issues；后续改动仅涉及清理器、session provider 与生命周期测试。 |
| 上述后续改动的 3 个文件的 bounded `dart analyze` | 1 | PASS，0 issues。 |
| Work 预审风险修正后的 7 个文件的 bounded `dart analyze` | 1 | PASS，0 issues。 |
| `git diff --check` | 1 | PASS，exit 0；在 Work 预审风险修正前执行，此后改动经 `dart format` 与有界 analyze，未复跑该检查。 |

未运行全量 Flutter/Android、设备、HTTP/API、backend、DB 或网络检查。共同启动门用注入的合成展示回调验证顺序；没有真实设备升级/登出清理证明。CACHE-01 既有页面禁读写屏障未重测。

## Work 独立验收（2026-09-23）

**LEVEL 2 ACCEPT — 限已识别旧未加密聊天键的精确清除路径。** Work 对照本地 `main` 基线 `4a3d9a37366d0c71a10aea6e9f725743767192bd`、任务允许路径、全部候选 blob 和源码差异：专用清理器仅枚举键名，命中 `chat_draft_` 前缀和两个固定键；值不读取、解析或写入日志。删除返回 `false`、抛异常或枚举失败不会被专用清理器报告为成功；边界方法给出固定非私密失败提示并允许后续启动/账户边界重试。共同 bootstrap 等待清理尝试后才展示 app；登录替换、登出与直接会话失效路径均调用同一清理逻辑。现有账户/Token 与其他缓存清理路径未被重用为升级清理；Work 预审指出的清理失败阻断 Token 操作风险已修正并由失败注入测试覆盖。

Work 独立复跑四份定向 Flutter 测试：**16/16 PASS**。最终工作区 `git diff --check` **exit 0**；候选 blob 与上表一致。测试用 synthetic SharedPreferences 和注入展示回调证明键集、失败/重试及调用顺序；没有真实设备现存数据读取或升级、登出运行观察，也没有 build、Android、后端、DB 或生产结论。CACHE-01 的页面禁读写静态屏障仍为前提。本次接受不证明旧设备值已实际擦除。
