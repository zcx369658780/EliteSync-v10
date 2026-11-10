# AUTH-07｜本地登录、refresh 与 T0/15/30 天缺口静态映射

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发及执行基线 HEAD `91845ff227159ac711047cc9e4d9274335ebe5af`。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留；本轮唯一新增文件为本回执。

## 已接受事实与本地代码

Owner 已决定：15 天在线登录期；自最后一次**成功在线登录**起，第 16～30 天在其他门通过且设备仍离线时可只读；满 30 天清理已保存的按账户加密私密内容；自动 Token 续期不重置 T0。来源为 `PRODUCT_DECISIONS.md` 末项。AUTH-02 接受的是部署 `AuthController.php` 与本地同 SHA-256 的文件身份；AUTH-04 接受的是 `v1/auth/login`、`refresh` 在部署路由源码中的相同静态声明；AUTH-06 仅核对四条 v2 synthetic 路由的部署目录 CLI 视图。这些均不证明真实登录事件、服务端配置、客户端请求或 15/30 天规则已运行。

| 链路 | 当前本地源码直接证明 | 对 T0/期限的限度 |
|---|---|---|
| Laravel v1 路由 | `services/backend-laravel/routes/api.php:44,53–56`：`POST /api/v1/auth/login` 走 `AuthController::login`、行内 `throttle:auth`；`POST /api/v1/auth/refresh` 走 `AuthController::refresh`、行内 `auth:sanctum`。 | 路由声明不等于成功在线登录事件或在线期限证明。 |
| 成功 login | `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php:96–119`：核验手机号/密码与 disabled 状态，随后 `createToken('mobile-access')`；响应只有 `user`、`access_token`、`token_type`。同文件 `:68–93` 的 register 也签发同名 Token。 | 未见受信 T0、登录事件 ID/顺序、账户/设备绑定的登录回执或 15 天到期字段；Token 签发事件不能无差别当成功 login，因 register/refresh 也签发。 |
| refresh / 撤销 | 同一 controller `:122–133`：取已认证 user，删除当前 access token，再签发 `mobile-access` Token；返回同样三个字段。`:183–184` 的受限 synthetic 账户删除会删除该用户 tokens。 | refresh 是源码中的 Token 轮换，不是新成功在线登录；未见保留原 T0、禁止重置 30 天计时的字段或规则。删除当前 Token 不等于全账户登出/撤权传播机制。 |
| Token 配置与测试 | `app/Models/User.php:10–15` 使用 `HasApiTokens`；`config/sanctum.php:44–50` 的源码 `expiration => null`；上面三处 `createToken` 均未传显式到期参数。`tests/Feature/AuthQuestionnaireApiTest.php:118–123` 和 `AuthPasswordApiTest.php:33–40` 仅见合成 login/Token 响应断言；对 `tests/Feature` 的精确 `/api/v1/auth/refresh` 搜索无命中。 | 当前源码未提供 15 天强制到期的证据；真实配置、数据库 token 状态、请求时失效、后端运行结果均未核验。现有相关测试不证明 refresh 与 T0 分离。 |
| Flutter 登录入口 | `apps/flutter_elitesync_module/lib/features/auth/data/datasource/auth_remote_data_source.dart:19–38` 可走 mock 或 `POST /api/v1/auth/login`；`data/repository/auth_repository_impl.dart:24–45` 校验非空 access token 后持久化；`presentation/providers/login_form_provider.dart:32–43` 再把 session 交给 `SessionNotifier.setAuthenticated`。 | mock 分支及本地 token 接收都不认证真实 T0；没有服务端登录事件证明被接入。 |
| Flutter 字段/保存 | `data/dto/login_response_dto.dart:18–34` 可解析可选 `refresh_token`；`data/mapper/auth_mapper.dart:48–54` 缺失时映为 `''`，而上述 Laravel login/refresh 响应未返回它。`data/datasource/auth_local_data_source.dart:16–37` 写入 access/refresh token 与 profile；`shared/providers/session_provider.dart:41–59,62–87` 启动读取本地 token/profile，只凭 access token 非空即置 `authenticated`，登录后又写 token/profile。 | `refreshToken` 类型或本地键存在不证明服务器发放独立 refresh token；本地 profile/Token 不证明会话未超 15 天、账户/设备受信绑定或 T0。 |
| Flutter 网络续期与离线判定 | `shared/providers/app_providers.dart:34–61` 的 access token provider 读本地值，`refreshAccessTokenProvider` 明确返回 `null`；`core/network/interceptors/auth_interceptor.dart:32–58` 只在 callback 给出新 Token 时可能重试 401。`core/storage/cache_keys.dart:3–5` 声明 `tokenExpireAt`，在限定 Flutter `lib` 搜索中未见使用。`features/chat/domain/offline_private_retention_policy.dart:24–50,86–95` 仅消费调用方声明的 elapsed/T0 账户绑定，`lib` 中未定位到 `OfflinePrivateRetentionPolicy.evaluate` 调用点。 | 当前 Flutter 链没有可用的自动 refresh 实现，也没有受信经过时间或 30 天清理接线。纯判定器的存在只证明可对**声明**求候选值，不能产生可信输入或执行清理。 |

## 缺口判定与后继门

1. **T0 来源／持久记录：NOT ESTABLISHED。** 需要独立明确能代表“最后一次成功在线登录”的服务端事件及其账户、设备、顺序、可靠时间证明和客户端获取/保存方式；不能从 Token `created_at`、启动、profile 更新或 refresh 推断。当前检查的 controller/User/Flutter 链均未见这样的受信记录。
2. **15 天在线登录边界：NOT ESTABLISHED。** 现有 Token 签发与静态 Sanctum `expiration => null` 未体现 Owner 的 15 天规则；真实部署配置/请求行为未核验。在线 read/send 仍须独立当前 Connection、Messaging Consent、CV 与数据权利核验。
3. **refresh 不重置 T0：NOT ESTABLISHED。** 后端 refresh 会轮换 Token，但无原 T0 传递或保留语义；Flutter 目前的 refresh callback 为 `null`。后续合同须明确真正成功交互登录与技术续期的事件区分，不能以新 Token 延长 30 天。
4. **30 天加密私密内容清理：NOT ESTABLISHED。** 当前链路没有可靠时间触发、逐账户受控密文副本清单、删除与失败回执。`AuthLocalDataSource.persistSession` / `SessionNotifier.setAuthenticated` 所调用的 `tryPurgeLegacyPrivateChatCache()` 是旧键清理入口，不能当作新加密内容清理。离线只读资格、清理到期与清理完成仍须分开。

另有一个直接遇到的静态风险：`core/network/interceptors/auth_interceptor.dart:21–26` 含打印运行时 bearer token 的调试语句。本轮未执行、未读取任何实际 Token；这一源码风险需另按授权范围审查和修复，不能由本次只读映射顺带改代码。

本清单只建立当前限定源码中的存在/未定位事实，不判定服务器真实配置、数据库记录、设备内容或真实用户权限。后继若设计/实现受信登录事件、期限、Token 生命周期、离线凭据和清理，应由 Work/Owner 分别明确来源、范围与风险门；本任务不授权接线或生产变更。

## 本轮检查

只读核对本地控制文档、AUTH-02/04/06 接受回执、指定 backend auth/Token/Sanctum 源码与相关 Feature 测试、Flutter 登录和会话/网络直接依赖。代码图谱辅助定位 `AuthRemoteDataSource` 与 `SessionNotifier`，结论仍以本地精确路径为准。未连接服务器，未使用 SSH、HTTP/API、DB、设备或真实数据；未读取 `.env`、实际配置值、私钥、Token、日志、用户/媒体内容；未改 auth、路由、缓存或配置，未运行测试/构建，未访问旧 `D:\EliteSync` 或 GitHub。`git diff --check` 按预算运行 **1 次**，退出码 0、无输出；该命令不检查未跟踪文件。新文档单独只读检查 32 行，尾随空白 0 行。作者不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地静态登录生命周期缺口映射。** Work 核对发布基线 `91845ff227159ac711047cc9e4d9274335ebe5af`、唯一候选路径、`AuthController` 的 login/refresh 签发和轮换逻辑、`config/sanctum.php:50` 的源码 `expiration => null`、Flutter refresh callback 返回 `null`、旧键清理与离线纯判定入口。由这些限定文件可支持“未见可信 T0 与 15/30 天接线”，不能扩大为全项目或真实服务器无实现。Work 另独立确认 `auth_interceptor.dart:21–26` 确实打印完整 bearer Token；这是需单独修复的明确隐私风险。新文档无尾随空白，工作区没有其他任务改动；未运行测试或服务器操作。

本验收不接受生产有效期、真实登录回执或设备清理已建立。下一步先对已确认的 Token 调试输出作有界删除和定向验证，再分别设计可信登录事件及期限执行；不得从 `createToken`、refresh 或本地 `authenticated` 推定 T0。
