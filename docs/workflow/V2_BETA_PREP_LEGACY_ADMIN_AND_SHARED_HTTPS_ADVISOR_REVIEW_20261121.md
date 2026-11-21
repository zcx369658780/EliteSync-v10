# EliteSync V2｜Beta准备、旧管理员合成恢复与P0.4代码顾问限定验收

日期：2026-11-21。结论：**`BETA_PREP_SYNTHETIC_LEGACY_ADMIN_RESTORE_ACCEPTED_WITH_RESERVATIONS / P0_4_FLUTTER_SCOPED_ACCEPTED_WITH_READBACK_CONCURRENCY_FINDING / REAL_ADMIN_DATA_NOT_AUTHORIZED / SHARED_HTTPS_CAPACITY_BLOCKED / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**。

## 1. 固定证据与工程身份

- 固定报告：[V2 Beta准备综合报告`0fd75198db3067782241b6777054050ac2af6918`](https://github.com/zcx369658780/EliteSync-v10/blob/0fd75198db3067782241b6777054050ac2af6918/docs/versions/v2/cloud-r0-20261121/V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_REPORT_20261121.md)，blob `d4faf1f0730e8926cc309ea17aee9ed5eda61ab5`。
- 开发分支`codex/v2-function-completion-20261121`远端HEAD回读为报告SHA。相对P0.3`651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`ahead3/behind0，merge-base为P0.3。此次三个提交包含P0.4 Flutter聊天/正式关系页面和测试、旧管理员恢复CLI/服务/激活页/迁移/测试及综合报告。
- 报告称本地专用MariaDB10.11.19、原`elitesync_v2_function`和server_id2621121，新增恢复入口仅本机HTTPS18445；原18444用于缺allowlist拒绝对照。新增FPM/edge容器已停止，原功能容器和两卷保留，数据库仍运行。
- 顾问直接抽查报告、Manifest/Target/Restore/CLI/ActivationController/activation Blade/route/migration/测试、AdminAccess、AuthController、AdminController、DeviceSessions、P0.4 Flutter页面与测试。顾问未在本机执行PHP/Flutter/Docker或重新计算日志hash；运行PASS属于`CODEX_REPORTED_LOCAL_E2E`，源码判断属于`ADVISOR_SOURCE_SPOTCHECK`。

## 2. 旧管理员恢复工具：本地合成范围接受

### 源码核对

- `LegacyAdminManifest`采用受限私有JSON、UTF-8/大小/键白名单、1–50候选、唯一候选/旧ID/手机号、E.164登录标识和固定`enabled + admin`来源资格；不接受密码hash/token等额外字段。manifest fingerprint由`APP_KEY`HMAC并排除当前operator。
- `LegacyAdminTarget`要求`APP_ENV=staging`、HTTPS origin与APP_URL一致、debug关闭、secure cookie、MariaDB10.11、schema前缀`elitesync_v2_`、实际schema/server_id/version匹配、DB URL/socket禁用和database session；本地合成目标另固定schema`elitesync_v2_function`、server_id2621121、host`r0-db`、loopback origin。真实Beta目标排除已知旧R0/function schema和server_id。
- `apply`默认CLI dry-run，apply事务内创建disabled普通用户、新V2 ID和旧ID映射，不直接授予admin；手机号冲突/旧ID已映射/ADMIN_PHONES缺失停止。虚构target仅接受202-555-01xx。重复同批返回现有状态，修改来源/快照/清单拒绝。
- `issue` CLI签发30分钟一次性随机码，哈希入库，明文只写入独占新建、权限受限的私有文件；重签使旧码失效。HTTPS激活页POST/CSRF/限速/no-store，激活同事务设置V2新密码、启用账号和管理员角色、消耗激活码及审计。Web与APP继续走现有AdminAccess/登录合同。
- `rollback`禁用并降为普通角色、撤销DeviceSessions及其tokens/database sessions、platform admin sessions，清除激活码并保留审计；allowlist由运维从私有`ADMIN_PHONES`移除，CLI提示明确。
- 新恢复用户保持`verify_status=pending`、`realname_verified=false`，不把管理员角色冒充真实KYC。

### Codex运行回执与顾问结论

报告具名两名虚构管理员，在专用MariaDB+本机HTTPS上完成dry-run零写、apply、原手机号/新ID、重复apply幂等、激活码重签/过期/重复拒绝、APP登录API、Web表单/管理页面、缺allowlist403、激活/登录限速429、回滚后访问/刷新/设备会话/Web会话失效。PHP定向10项/100断言通过。首轮测试夹具清单解析错误失败已保留，使用正式manifest parser复测通过。

**接受为`LOCAL_SYNTHETIC_LEGACY_ADMIN_RESTORE_SCOPED_PASS`**，但不等于真实管理员恢复、真实持有人验证或异地共享登录。

## 3. 真实管理员数据门：仍未通过

报告明确真实账号候选、获批快照、旧数据库真实行读取、备份解压/解密、真实V2库写入、同事本人激活及异地登录均`NOT_RUN/BLOCKED_OWNER_DATA_GATE`。旧MariaDB当前是优先来源，2026-05三份gzip仅回退候选，远端原件SHA/恢复资格未完成。独立GPG组保持不选。

### 真实数据执行前的两项必要加固

1. `LegacyAdminTarget`当前验证实际schema、server_id、version及连接host，但没有把DB username、port与实际`CURRENT_USER()`作为完整身份合同核验。真实数据恢复前须加入预期用户名/端口、实际`CURRENT_USER()`、schema、server_id、version和目标origin全量匹配，禁用DB_URL/socket，错一项立即拒绝。
2. Manifest目前以`approval`短引用与私有配置值比较，并由`APP_KEY`给清单指纹；没有独立Owner签名验证，也没有每位候选的持有人控制登录标识证明/旧私有管理员allowlist命中证据。真实数据门前需使用Owner批准的私有授权包/可独立验证签名或受控签名回执，并为每个候选记录持有人确认引用、旧账号active/disabled状态、原管理名单命中、批准角色、用途和核验操作者。公开GitHub只保留不可逆代号及字段清单，绝不保存真实号码、姓名或ID映射。
3. `ADMIN_PHONES`是服务器私有环境配置；实际部署前需验证配置变更审计、启动/配置缓存后的生效、管理员退出/撤权的跨请求失权和运维回滚。任何恢复账号不得自动获得匹配运营等额外权限，需按最小角色另行判断。

这两项属于真实数据/远程部署门，不否定当前虚构演练。

## 4. P0.4代码验收：限定接受并保留并发读回问题

- Codex报告Flutter定向67项通过，相关Dart静态分析通过。变更包括聊天页端上Block确认、POST结果不明后读取`/api/v1/moderation/blocks`、撤销本地缓存/关系authority、禁用写控件、消息UNKNOWN读回和复用原`client_message_id`；正式关系ACTIVE文案已从通用“已参与”改为“正式关系已建立”。
- 源码抽查确认`_load()`在`_loading`、`_loadingOlder`、`_blockNeedsReadback`、后台等状态下可直接return。当前`_retryUnconfirmedMessage()`仅`await _load()`后就继续检查旧`_messages`并可能POST；若调用时已有读取在途，`_load()`不保证发生新的权威GET。因此“每次UNKNOWN重试前都完成新鲜读回”在并发场景尚未证明。
- 该问题应作为P0.4局部修复：显式等待现有读取完成或执行专用序列化authoritative GET，返回fresh-read成功标记；只有读成功且确认原消息不存在才可使用原key重试。若GET失败/权限变化/切号/后台则保持UNKNOWN、不重发。增加`_loading`/polling重叠、读超时、commit后响应丢失、重复点击、切号和Block竞争测试。
- 本轮P0.4仅有Flutter具名测试，尚无新APK、实体设备回归、媒体/历史受众或外部URI实测。旧1011805只代表P0.3，不能替代新源码APK证据；安装新包需另行Owner确认。

## 5. 共享HTTPS与阿里云

- 当前P0.3 Android是本机`127.0.0.1:18444`+ADB reverse，不是共享服务器。
- 现有上海旧机历史观察2vCPU/2GiB、可用内存约627–628MiB、无swap、旧Laravel/MariaDB/Redis/LiveKit共驻；本轮报告判定同驻V2容量未获批准。
- 本轮没有新的SSH、云写入、实例采购、域名/防火墙/公网改动，新增云支出0。V2共享HTTPS`BLOCKED_CAPACITY_AND_OWNER_GATE`。
- 远程同事需要一个稳定受限HTTPS endpoint、独立V2数据库/应用/媒体/worker、可信TLS及管理员入口保护。可先比较现有机在只读采样后能否承载与独立2vCPU/4GiB/40–60GiB候选；实际价格待报价。未获Owner云写/费用授权不得部署、开公网或更改旧业务。

## 6. 最终判定

**接受本轮本地合成管理员恢复工具与两名虚构管理员演练；接受P0.4已覆盖的端上Block/控件和关系文案修复为Flutter限定范围成果。整体仍PARTIAL。**

状态：
- `LOCAL_SYNTHETIC_LEGACY_ADMIN_RESTORE_SCOPED_PASS`
- `P0_4_FLUTTER_SCOPED_PASS_WITH_READBACK_CONCURRENCY_FIX_REQUIRED`
- `REAL_LEGACY_ADMIN_DATA_NOT_AUTHORIZED`
- `SHARED_HTTPS_CAPACITY_AND_CLOUD_WRITE_BLOCKED`
- `CLOSED_BETA_NO_GO`
- `PRODUCTION_NO_GO`

内测前必须完成：指定旧管理员真实身份来源/持有人核验、Owner数据授权、最小字段迁移、V2新凭据激活、每位同事本人异地APP登录、获准人员Web后台登录，以及共享HTTPS环境。此报告不授权任何真实数据读取/解密、云写入、采购或内测启动。
