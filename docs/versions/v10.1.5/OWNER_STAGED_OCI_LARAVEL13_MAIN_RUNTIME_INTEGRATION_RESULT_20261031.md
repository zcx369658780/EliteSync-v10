# EliteSync v10.1.5｜Owner 本地 OCI 验真与 Laravel13 目标 main 运行集成结果

状态：**LARAVEL13_TARGET_MAIN_RUNTIME_CANDIDATE_PASS_AWAITING_ASTRA / NO_PRODUCT_MAIN_MERGE / LOCAL_DEFAULT_BASELINE_NOT_SWITCHED**。

## 授权、Git 与范围
本轮唯一合同为任务 Blob `30c993d6a350ba79f62dddea6ddbeb420854ddec`；旧 `ff6a3318` 已取代，未使用。task_id：`V1015_OWNER_STAGED_OCI_L13_MAIN_RUNTIME_INTEGRATION_20261031`，唯一新根、attempt-0001、独立持久账本，不接续任何旧 STOP 余额。

开工 fresh main / sole Parent：`f9f9b97870c6ca482ced83ba09af82dab326f370`；Parent Root：`9a854f32de35907a1462ff5a3a7863b02036696f`。其 apps/services 仍精确为已接受 v10.1.4。源码输入仅为 f407 静态选择候选，Root `976bde38f80720bb9ac44c1a5808e6cc62c686e1`，Astra Review Blob `f6b816e4839b491abb68a3478b5406afd4f94aa6`。本候选不以 f407 或审查分支为 Parent，不合 main。

候选 apps：`3468a3dd97da7accfda2539a0f8d8f68931a6110`；services：`e14dece6cf3eef118875f688fd303a82d34418c2`。包含本文件的唯一 native Commit / Root，以发布后的 Git 对象及封存 fresh readback 为最终身份；不在自身内容中伪造可自引用的 Commit/Root SHA。Manifest 列明全部非自身 path/mode/Blob，自身由同一 native Tree 绑定。最终交付消息及 LOCAL_ONLY 回读回执提供实际 Commit/Root。

## 已实际完成
- 官方 PHP Index → 唯一 amd64 Manifest → Config → 本地导出和 RootFS 闭环通过，10 层原始压缩 SHA/长度及解压 diffID 均独立复算。
- MariaDB 使用获准的新 Jammy Index `7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`，Manifest `dc9dd57be7f46ad6f350c598a331d64f295899c4abac3ec5652eff831fc38a6c`，Config `41096ae9913468679bb5e05bbc19f44edcaf0eae45d67fcde224ffdeda9d3a1f`。8 层完整复算通过；明确不是旧 d769 索引，也未用旧 Config 借位。
- Docker containerd 的 inspect Id 按 Index/平台 Manifest API 语义识别，不错误等同 Config。PATH 旧未签名 CLI 只作只读观察；运行使用 Desktop 自带已签名 CLI 29.9.2、现成 Engine 29.9.2 linux/amd64。没有启动/升级/重启 Desktop 或 WSL，没有签新许可。
- 一次 offline build、PHP 8.4.27、Composer 2.11.1、Laravel 13.39.0 与必要扩展冻结；Debian unzip 输入经官方 InRelease/Packages SHA 和实际离线 gpgv 验证。未改变全局环境。
- 114 个固定包新供应 SHA256、ZIP CRC/路径与固定官方 commit 来源核对；真实 `validate --strict`、`check-platform-reqs`、`install --no-scripts --no-plugins --no-interaction` 通过。solver=0，原目标 composer.json/lock Blob 不变，新 vendor 114 个版本/ref 与锁一致。
- 明确审查自有及七个包 Provider 后执行 package:discover 与 route:list，实际框架引导通过；没有自动运行安装脚本或 composer dev。Guzzle、Workerman 和 lunar-php 的本轮库/API 使用路径有定向真实 PHP 证据，不冒充真实外部供应商或 WebSocket/RTC 验证。
- 最终 **166 tests / 2817 assertions / exit 0**，5 批额度已满；前四批失败原件保留。20 文件 PHP lint、PHP -v/-m 及实际 Laravel 版本通过。
- 真实私有容器回环 HTTP → 当前目标 Laravel → 新空 MariaDB 的登录、CN/MC 双方许可、消息/附件写入、重复回放、不同 payload 冲突、授权 PNG SHA 读取、越权、CSRF、管理员与撤权/旧 token 拒绝均符合预期。重启后再验证了旧 token/撤权仍拒绝。
- 新库 **90 张表**重启前后逐表完整行哈希一致；仅本轮合成数据导出到另一个本轮新空 schema，90 张表的计数/哈希全部相等。没有读取、备份、迁移或恢复旧/生产库。

## 隔离、兼容修复与限制
新 task 专属容器/卷/内部 network、非 root 运行 UID、cap-drop ALL、no-new-privileges、只读应用根及内存/CPU/pid 约束均有本机回执。仅新空卷的初始化使用具名 CHOWN；不碰旧卷。DB TCP 无宿主发布；应用和 DB 共用仅本轮的网络 namespace。既有 main 的逻辑 DB 名/端口别名仅存在于这个新 namespace 和新卷中，以保留原安全 guard；不是连接同名宿主/历史库。

宿主发布端口曾拒绝连接，第一次私有回环 5 秒冷启动探测超时。成功 HTTP 证据来自容器内固定 127.0.0.1:8080 的真实 TCP HTTP；宿主入口仍 **NOT_VERIFIED**。没有通过开防火墙、重启 Docker/WSL或外联来绕过。

17 个源路径中，9 个精确保留 f407 输入，TransportEnvelope 只额外对齐已接受 main 源码哈希；另三项旧测试补齐当前 main 既有提案夹具，并新增依赖兼容测试、测试 trait 与两份 CLI-only 验证工具。**257 个 app/routes 原 Blob 全保持**，SQLite 测试 guard 未改，未带入 9b 广义 F1/F3/F4 业务。细目见源码映射。401 guest 负例仍拒绝访问并增加不泄露字节/存储 key 断言；认证越权、撤权保持 404。

供应计量初版遗漏既有官方 CDN allowlist、一个 helper 名称替换错误均在读取配置前拒绝，原记录保留；修正来源受限名单后闭环通过。失败请求保守最大预留不退款。后续计量纳入探测额外字节、失败全额计费、逐段 deadline，供应 worker 另受父进程总时限控制。Registry bearer 与临时重定向 URL 只留内存，公开不含访问令牌。

## 旧资产、预算与回滚
既有本地备份 **11,066 文件 / 240,617,393 bytes** 全部重开 SHA 复核通过，Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。旧源/vendor/私有元数据 9,643 项比对、dirty 252、refs 527、index/HEAD，以及 122 原证、3183 Seed、旧18当前捕获描述符、两份既有 ACL 夹具、五根 HEAD/branch 和11旧任务 seal均通过具名只读核对。原备份与旧 Laravel11、dirty、历史证据均未删；当前默认本地版本未切换。

预算见配套 JSON；供应 137/500，计费 34054405/2GiB（含失败保守预留），Digest7/8、build1/2、solver0、vendor1/2、服务组3/3、Feature5/5、migration2/2、seed2/2，Desktop/WSL 操作0。Owner 外部 pull 的原字节/请求仍 UNKNOWN_EXTERNAL_BYTES/REQUESTS，未写总供应为0。公开预算是动态关闭后的发布快照；最终墙钟/空间/ledger hash在 fresh 回读后 LOCAL_ONLY 封存，余量不可复用。

回滚保持：本候选未合 main，旧默认与已接受主线未变；备份/旧代码原地保留。未来仅在 Astra 独立接受及另有切换授权时选择新干净目标；不得覆盖 dirty。此次恢复证据只覆盖新合成库，不等于生产 DB、完整 Git 历史或物理异盘灾备。删除始终需未来 Owner 按项确认，本轮无删除/清理后继。

## 尚未关闭的门
真实旧 Laravel11 cookie：**REAL_LEGACY_L11_COOKIE_NOT_PROVEN**；H264 video206、真实 WebSocket gateway、Flutter/Gradle/APK/ADB、RTC/AEC、真实 Push、物理15/30天、完整 APP 设备 E2E、生产部署均未运行。v10.1.5 仍10 PARTIAL/1 OPEN，AC05 OPEN，G2 false，v10.1.6 NOT_STARTED。旧 Windows E_NOTIMPL、PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT、OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN、RESTRICTED_IDENTITY_GATE_BLOCKED、OS_ENFORCEMENT_NOT_PROVEN、EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED 原样保留。

本轮运行、备份/本机哈希与预算属于 CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW；发布后 Git 原生对象属于 DIRECT_GITHUB_OBJECT。Codex 不签 INTEGRATION_ACCEPTED 或 FUNCTION_ACCEPTED。本轮服务已停止、资源留存；唯一候选回读后封存 STOP，等待 Astra 独立验收。
