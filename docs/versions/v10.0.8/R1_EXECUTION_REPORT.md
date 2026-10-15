# v10.0.8 R1｜受限用户本人处罚申诉

**V10.0.8 R1 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE**。仅补齐D2/AC-08-04的本人Restrict申诉，不改冻结AC，不重新实施B01～B06，不自接受、合main或启动0.9。

## 身份

| 项目 | 固定身份 |
|---|---|
| 初始候选 | `cff049ae602049adf49014ec2ed27963dc40aff5` / Tree `0da1d69a06a91be3c765d9f4bb6a1febac69d08f` |
| 唯一冻结plan | `ac57d3370a2f2f17c042987a758d86c9aa725650` / Blob `0856e7372d1f91fadfa3350b30f926f7af9cf809` |
| Owner政策 | `cacfa889128f9a3a4b443efa87f4c347a178f1d5` / Blob `4f84f1968ee2737b842f828ad2e0cbdd5c929936`；D1/D2/D3不变 |
| Astra R1原审查 | `08044b1cff4379ce2a73127dac3d9e13cc032c75` / Blob `c91a7fbeb4f838278dff28db9234ea9abd170e61`；[原文](ASTRA_R1_REVIEW_FINDINGS.md) |
| 执行时main | `d15aa037b63edda2adc54ee47242a171c27eb4cc`，仅读取，没有产品集成 |
| R1最终产品源码 | `788f7d13927d57e6f31a22b5ce1a990b98bd2f53` / Tree `e8ef3f5f1157011df59f415704df5df649cb712c` |
| Flutter lib / Android Tree | `db3185dda6e35988f01315ea6dabc021bd1e1eae` / `7e76419254e889c95d846d91bde7674020331c75` |
| Backend Tree | `c8328534804b32e1b5f6964839f85103f824bf75` |

独立分支仍为 `codex/v10.0.8-web-admin`。最终包含本文与原证的发布commit/tree由交付回报和本地 `r1/publication-receipt.json` 的GitHub回读固定；Manifest不伪填包含自身内容的递归hash。产品源码锚后只发布文档/证据，不再改产品。

## 最小修复

- 新增 `app/Services/SanctionAppeals.php`、`Api/V1/SanctionAppealController.php`与迁移 `2026_10_15_090000_create_sanction_appeals.php`。`sanction_appeals`独立于举报人申诉，保存可信user_id、sanction_id、status=submitted、说明、提交时间；sanction_id唯一且有外键。
- `GET /api/v1/moderation/sanctions`只按认证身份读取当前有效Restrict的ID/类型/时间及本人已提交说明。不给用户返回处罚原始reason、report_id、举报人、管理员身份或私信。无有效处罚返回空集合。
- `POST /api/v1/moderation/sanctions/{id}/appeals`仅收note，服务端锁定当前User，再锁本人的active、restored_at为空、kind=restrict处罚；禁用/未知账号状态fail closed。user_id/sanction_id/status伪造字段禁止。首次201；同文完全重试200并返回同记录；不同文重复409，不覆盖原说明。有效性检查先于幂等返回，处罚已恢复后同文也404。
- 申诉记录不写User、token、CN/MC或消息授权；不设计自动裁决。当前用户行锁与现有UserGovernance恢复/禁用共用，唯一键补充防重。
- APP实际Me入口新增 `SanctionAppealCard`，用户主动读取本人处罚、填写并提交、查看服务端状态/时间。失败保留输入并刷新当前状态，拒绝未经确认的成功与原始错误内容，不改权限provider。
- 现有Blade用户详情新增“被处罚者本人申诉”，仅当前role＋管理员名单＋未禁用身份可访问；说明由Blade转义，访问在同库审计且不复制说明正文到审计/日志。管理员仍用既有具名处罚服务处理，不自动解除。列表为目标用户的有限记录，不做全站申诉运营平台。

既有 `ModerationController::appeal`、举报人申诉原路由与模型合同完全未改；其回归测试实际重跑。产品变化仅10个文件，详见 [R1_manifest.json](R1_manifest.json)。

## 真实链与正反例

复用 `elitesync_v1008_dev` / `elitesync-v1008-db` / 同一 `elitesync-v1008-db-data`，127.0.0.1:43318，原localhost Laravel/front与指定AVD `emulator-5582`。只迁移新增申诉表，不init/reseed、不覆写原验收记录。追加虚构用户11/12及独立负例13；原用户1～8、原题库/答卷、round/run、Match/CN/MC、动态、举报与release用hash对照保持。

| 链路 | 实际证据与结果（相对本地Q/r1，公开副本在r1-evidence） |
|---|---|
| 验证前合法历史 | 新增用户11/12、明确标注为fixture的已发布Match2，不冒真实consumer结果。双方分别经可信API建立CN/MC；peer通过真实消息API写入消息3。之后真实Blade对用户11施加Restrict #4。`cn-*`、`mc-*`、`history-message.json`、`web-restrict-created.png`。 |
| 受限账号真实登录 | 最终R1包在AVD安装后，APP退出原Bob并登录r1restricted；Me显示受限及新匹配暂停，`app-restricted-login-result.png`、`app-restricted-me.png`。没有恢复原Alice或其它旧处罚。 |
| 真实APP提交 | Me→“查看本人处罚与申诉”→处罚4→输入 `V1008R1PleaseReviewRestrictionNoAutoRestore`→提交；`app-appeal-submitted.png`显示已提交时间。API/DB读回appeal1、user11、sanction4、status submitted，`owner-appeal-readback.json`及 `after-appeal.stdout`。 |
| Blade同ID读取 | `web-appeal-readback.png`明确申诉1/账号11/处罚4/同一说明时间；审计 `sanction_appeal.view`使用可信admin1、目标appeal1，不含note。 |
| 没有自动复权 | `business-comparisons.json`中申诉前后r1_users、sanctions、CN、MC完全相同。`history-after.json`仍200；双向新消息 `send-after-denied.json`、`peer-send-after-denied.json`均404。真实APP `app-history-readonly.png`读到消息3，尝试新发送 `app-send-rejected.png`被服务端拒绝。 |
| 归属/旧凭据 | `nonowner-rejected.json`：peer12提交别人的处罚4返回404；`disabled-old-token.json`：原已禁用Alice旧token访问新申诉入口401，不修改Alice。单测另覆盖伪造user_id、未知ID、失效/错误类型、当前缓存身份变化等。 |
| 幂等 | `exact-duplicate.json`同文200且仍appeal1；`changed-duplicate.json`不同文409不覆盖。另独立用户13的处罚5双HTTP请求得到201/200且同appeal2，`concurrent-restore-proof.json`；PHP服务本身单线程，此项只声称并发HTTP请求防重，不冒多worker并行。 |
| 恢复竞争/失效 | 独立用户13通过既有UserGovernance显式restore处罚5；MariaDB事务持同一User锁3秒，同时真实HTTP重试申诉等待约2.953秒，锁释放后重核并404。`restore-held.*`、`concurrent-restore-proof.json`；随后 `restored-sanction-rejected.json`404、`restored-list-empty.json`空。appeal2历史保留。此为独立测试操作，不是提交申诉触发自动恢复；不改变用户11的MC或历史权限。 |
| 重启持久 | 停指定APP及自有front/PHP，仅重启0.8同volume数据库再启动服务，不reseed。`restart-before.stdout`、`restart-after.stdout`逐字段一致；APP重新读取 `app-restart-appeal.png`、Blade `web-restart-appeal.png`同申诉1，状态仍restricted/submitted；API历史200、新发送404。worker本次未运行，无相关任务写入，不重复初始AC-08-08全套。 |

时间为开发服务数据库时间（UTC）；不以客户端本地时钟推断时间权威。本人说明仅本人和有权管理员可读；所有演示文本均虚构，不含真实举报人/私信/凭据。

## 测试与最终构建

| 标签 | 实际结果 |
|---|---|
| `php-appeal-red` | 新测试先运行，7项：1 error/6 failures，exit2，预期暴露未交付的接口/表，不记PASS |
| `php-appeal-first` | 31项/360断言，1 error，exit2；新增测试的Web加密key长度不合法 |
| `php-appeal-second` | 修正测试fixture为32字节key，31项/367断言，exit0；保留2项vendor deprecations。包含本人申诉、旧举报人申诉、处罚、资格/同意、R1通知隐私和消息权限相关套件 |
| `flutter-appeal-first/second/third` | 前两次分别13/1失败、exit1：测试漏主题及离屏查找；补正确fixture/滚动前断言，没有删有效断言。最终新13＋既有8＝21项通过、exit0 |
| `analyze-appeal-first` | 三个客户端变更文件No issues/exit0 |
| `analyze-full` | 全范围 `flutter analyze --no-pub`：No issues found/exit0 |
| `build-first` | 最终产品源码AAR/debug host，BUILD SUCCESSFUL、exit0；增量构建6 executed/32 up-to-date |
| `install-first`、`device-pull` | 安装Success/exit0；设备回读APK与最终APK SHA256一致 |

最终产品源码固定 `788f7d1...`，包位于本地Q `/r1/packages/`，不上传实体：

- `v1008-r1-debug.apk`：SHA256 `76817f85f8267552f23e07deb08bbf93879719f9606c4bf9096800a03dfed43b`。
- `v1008-r1-release.aar`：SHA256 `72e04eb1ef628870a6f66cd969c3239debdc940f26b7d2d6416acc5430187562`。
- versionName仍0.08.04、versionCode80400；R1包与初始包不同，身份见独立R1 Manifest。原B06 release记录和旧包hash作为初始成功证据保留，未将其冒称R1物理包元数据或验证下载托管。

其它诊断原流保留：首次迁移在Docker刚启动未ready时SQLSTATE2006/exit1，确认ready后 `migrate-ready`成功exit0。追加fixture首轮week_tag超长，整个事务回滚；Laravel异常处理打印QueryException却返回exit0，因此该次明确 **BUSINESS_FAILED / NOT_PASS**，不因exit0算成功。改短标签并加异常exit包装后仅追加用户11/12，未重seed；原9/10自增空洞保留。另一次snapshot调用工作目录路径错误在执行前失败，随后以正确根路径取得快照，不作为业务结果。原始测试/业务失败与stdout/stderr/exit均保留，不覆盖。

## 保护、原成功材料与NOT_RUN

原初始候选的EXECUTION_REPORT/manifest/TEST_RESULTS/RUNBOOK/evidence和失败记录未改写；新增独立R1材料。`business-comparisons.json`对原用户状态、问卷questions/answers/attempts、轮次、runs、公开动态、举报、release、旧Match1/CN/MC和sanctions1～3的有限hash全部一致。没有把新fixture Match2冒Matching消费成果，也没有重做B01～B06验收。

R1使用新鲜保护锚检查原dirty根HEAD/index/normal status及43项具名hash，结束均相同；历史109项未重审。无关 `%SystemDrive%/`目录保留且不入Git。0.6/0.7库及持久卷、3306、历史SQL/VHDX、真实账号/生产与外部第三方均未访问或启动。

最终自有PHP/front、0.8容器和AVD停止；同一volume/私配/媒体保留。必要运行步骤见 [R1_RUNBOOK.md](R1_RUNBOOK.md)。原证公开索引见 [r1-evidence/INDEX.json](r1-evidence/INDEX.json)；本地私配、token、cookie、包实体不发布。

NOT_RUN：全量Flutter与全量PHP、其余B01～B06全套、worker新消费、生产/商店/第三方/历史恢复。初始0.8的全量Flutter NOT_RUN、0.7历史3失败及exit1、vendor弃用、尚未恢复用户能力和旧通知存储观察均原样保留。本版不提供自动申诉裁决或新的处罚政策。

下一门：Astra针对本人申诉缺口与受影响回归独立复核；不自动ACCEPT、K08、合main或启动后继版本。
