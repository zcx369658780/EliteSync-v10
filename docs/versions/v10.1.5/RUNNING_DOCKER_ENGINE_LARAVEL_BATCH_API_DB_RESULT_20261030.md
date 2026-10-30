# Running Docker Engine · Laravel 批量迁移与真实 API/DB 结果（2026-10-30）

状态：**LARAVEL13_BACKEND_SYNTHETIC_API_DB_PASS / CODEX_REPORTED_LOCAL_TEST / ASTRA_INDEPENDENT_REVIEW_PENDING**。这不是 FUNCTION_ACCEPTED 或 v10.1.5 整版验收。

本任务在已经运行的本机 Linux 引擎上完成 PHP8.4/Laravel13 真实求解、vendor 安装、兼容修复和合成 HTTP/MariaDB 回归。没有启动、重启、安装或升级 Docker Desktop/WSL，没有连接旧数据库或真实用户数据。任务专属 worker、supply、API、DB 已退出；镜像、新卷和原始失败保留 LOCAL_ONLY。

## 固定身份

- Task：`V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030`；唯一 `attempt-0001`；root basename `v1015-running-docker-engine-laravel-batch-20261030`，原始 ledger 使用同一 FileID/Volume 和单调起点（2026-10-30 10:13:18 UTC）。
- 正式任务 Blob：`a1cbc75afe406e3e05712c6c51fb63c86bad928d`。
- sole Parent：`debe4a11d19f25179efef1d90d04e346980c2867`；Parent Root：`5cc585d5344e9a8e00b7512863e3169f662ad52b`。
- Parent apps：`8cd9b6df8e744c8fc9d4217412edce31795a318d`；Parent services：`1b1100808cf275d881a6dd8dde9c0155a7fc2a32`。apps 不变。
- 开工 fresh main：`e1916cd3f3513c5809b695c6e930a433e186e50a`，Root：`6d7aac9e1922c5d906476923b91eb256aeb9a73d`；ACTIVE_STATE Blob：`bb8d450f63d2a579b5058edb31d1d75a6a3ccac8`。该文档 main 不是研发 Parent。
- 已读前轮 Astra 审查：`af29749f8850a89c88aed6ba5a80fedbc7e13e47` / Blob `5f077c38bb3216de30e9b7fa46cd202fd06bf799`。旧任务仍 STOP，不继承或倒改其结论。

本报告与 Manifest 不嵌入包含自身的 Commit/Root，以免循环自哈希；实际身份由包含它们的原生 Git Commit、Tree、Blob 和发布后 `final-readback.json` 绑定。Manifest 列出非循环 payload path/mode/Blob，最终回读列出包括本报告与 Manifest 的全部变更。

## 已运行环境与来源

实际 Desktop `4.97.0.244584`、精确安装目录 CLI/Engine 各 `29.9.2`，`linux/amd64`。安装文件签名 VALID Docker Inc；FileID/hash、backend 进程、local named-pipe owner 和服务端身份相互核对。安装日志显示任务开始前 09:47–09:48 UTC 从 Desktop4.95/build242831 更新到4.97/build244584，含 auto-update/UAC relaunch 记录；不是本任务实施，也不推断 Owner 曾授权升级。旧 Secrets socket 错误根因仍未证明修复。

Owner 已确认同时满足免费小企业人数/收入阈值及无受保护自动启动负载，证据等级 OWNER_REPORTED；当前仍为既有 TermsVersion2，无新许可、登录或费用。初始49个旧容器均未运行，未操作其数据。WSL 注册列表显示 Stopped，而本地引擎报告 WSL2 kernel；不宣称 Ubuntu24.04 已运行。PHP userland 为 Debian12，MariaDB 镜像为 Ubuntu22.04。

官方 PHP/MariaDB 来源先通过计量 HTTPS 获取 index/platform/config/layer 并校验 digest/diff-id，之后才导入私有 tag；没有 docker pull。Docker29/containerd 转换导入 manifest，已导出并核原 config SHA 与完整 diff-id 链，未把转换后的 ID 冒作原始 config。离线 build1 得到 PHP8.4.27（pdo_mysql/sqlite、curl、mbstring、dom/xml、bcmath、pcntl）；官方 Composer2.11.0 及 Debian unzip6.0-28 的 InRelease→Packages→deb 校验链见 toolchain lock。无 Redis/Nginx 扩围。

内部网络无默认出站路由、无 host network/privileged/socket mount，任务 UID、cap-drop、readonly root、私有卷及资源限制均具名记录。预期宿主端口在 internal 网络上未转发，真实 HTTP 改从同一 API 容器 curl `127.0.0.1:8081`；主机只负责原子文件队列与预算。没有 mock response、代理或自动跳转。API 每次请求核源码闭包，使用点继续核 DB/环境/时限；使用专属新空 schema、账户、端口43479和 server_id301030，拒绝3306/43349/43359及 URL/socket 回退。任务 bootstrap 的媒体存储明确选择私有本地 v1011_relationship，公开 index.php 不加载此 test-only bootstrap。

## 求解与兼容修复

真实 solver1 成功：Laravel **13.39.0**、Tinker **3.0.2**、PHPUnit **12.5.42**，114包（4新增、91更新、4移除）。Composer 自行生成 lock/content-hash，未手改 lock、ignore-platform-reqs 或虚报 platform。114份 dist 均按 immutable source ref 下载、记录 SHA、检查 ZIP 路径/膨胀后填充 native URL-hash cache；vendor install1 在禁网且 scripts/plugins 禁用下完成。validate --strict 和 check-platform-reqs --lock 均 exit0；solver 原生审计输出无 advisory（这是当时的工具结果）。Laravel12 回退未触发；Laravel13 最终长期方向仍待 Astra 与 Owner 决定。

源码修正将未知/停用 peer 的消息404响应与其他拒绝保持一致，保留全部鉴权分支。测试适配 PHPUnit12 attributes、Laravel13 query helper 与 PreventRequestForgery 类名；补齐当前 friendship、owner 登录和 server-issued refresh token 夹具。Block 测试保留 block 前合法读取、block 后拒绝和历史行不删除断言。未削弱 TestCase SQLite guard、CN/MC/Block、token 或私有媒体保护。保留 Parent 已有 session.serialization=php。

## 真实验证

| 检查 | 实际结果 |
| --- | --- |
| 最终 Feature/Unit 第4批 | **258 tests / 3071 assertions，exit0** |
| PHP8.4 全源码 token parser | 581 PHP文件通过；最终变更/新增 PHP `-l` 13/13 exit0 |
| 供应/命令边界纯测试 | 14/14；Windows原生账本/STOP/身份/到期回归原证保留 |
| 新 MariaDB | 实际10.11.19；75迁移；5组虚构pair＋虚构管理员；全新卷/schema |
| 业务 HTTP | 100次尝试，99个真实响应，1次宿主连接失败计费；最终具名断言全部完成 |
| F1 | 4组真实消息/图片：同key同ID且只一次，异payload409，接收方读取200 |
| CN / MC / Block | 撤权前图片字节200；撤权后旧key/新消息/旧消息读取/媒体均404，第三方404 |
| F3 | 登录可信T0；refresh不延长T0/deadline；旧access/refresh401；logout和停用后401/403 |
| F4 | 实际通知记录、账号偏好、test_only设备及未授权provider422；最小payload与去重由相关真实Feature覆盖；未调用真实Push |
| Session/Admin | 管理员登录200；缺CSRF419；logout旧cookie拒绝；合成旧PHP serialize session正向200、logout拒绝 |
| DB/API受控重启 | 同一自有新卷，容器StartedAt实际变化；4消息/4附件/4通知/75迁移与消息事实不变，图片、偏好、幂等及撤权继续成立，合成旧session连续 |

所有失败原样计数并保留：服务组1继承 compress 选项失败；Feature1 discovery fatal、Feature2 9项、Feature3 2项；migration1在执行SQL前因转义下划线 grant 匹配拒绝；seed1超时回滚，seed2检查空库后成功；HTTP宿主端口、私有media输入及admin必填字段夹具失败。没有删除断言或把负例改成永久404来通过。供应原始体、凭据、cookie、vendor、OCI、DB卷、raw日志均 LOCAL_ONLY，公开回执脱敏。

## 硬预算与交接

动态工作关闭快照：**336,590,677 bytes / 317供应请求 / 4来源镜像manifest/index Digest / build1 / solver1 / vendor1 / 服务组4 / PHP CLI计费79 / Feature4 / HTTP100 / migration2 / seed2**。PHP build 不可退预留30，实测9；失败/超时未退款。快照 logical10,361,638,395、allocated10,386,729,472 bytes（含保守加算daemon镜像/新卷上界），约119.28分钟；各≤16GiB/240分钟。新DB `du` 234,901,504 bytes，计量保守预留1GiB。最终发布/回读/封存时的精确耗时、空间和账本SHA见 LOCAL_ONLY budget-terminal/completion receipt。没有可用服务组、migration或seed余额；交付后全部余额不可复用。

只交付一个普通 non-force、sole-parent 候选；发布后 fresh 回读 Commit/Parent/Root、全部变更 path/mode/Blob、完整 apps/services Tree 及 live main/ACTIVE_STATE，然后同根账本封存 STOP。D盘 dirty252项、index、527 refs及9个历史根身份/封存证据需在最终回执核对；不清理任何旧资产，不覆盖历史失败和事故。

**保留门禁：** v10.1.5 PARTIAL_NOT_ACCEPTED；AC01–11仍10 PARTIAL/1 OPEN；AC05 RTC/AEC OPEN；G2_READY_FOR_POPEN_FALSE；REAL_PUSH_PROVIDER_PENDING；RTC_AEC_NOT_CLOSED；OS_ENFORCEMENT_NOT_PROVEN；V10.1.6_NOT_STARTED。无合格H264 fixture的video206、Laravel11二进制实际产生的旧cookie、Flutter/Gradle/APK/ADB/真机/RTC/AEC/真实Push/物理15/30天均 NOT_RUN。Windows API-set E_NOTIMPL和所有历史事故状态不变。不得自动合main、签署FUNCTION_ACCEPTED、放行G2或启动后继任务。
