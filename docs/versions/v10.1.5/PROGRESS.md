# v10.1.5 版本进度总账｜2026-11-08

**SOFTWARE_COMPLETENESS_IN_PROGRESS / 10_PARTIAL_AC05_OPEN / G2_FALSE / REAL_PUSH_PENDING**

Owner已明确：[整个v10承接旧EliteSync增加功能、提高APP完成度](../../decisions/OWNER_V10_SOFTWARE_COMPLETENESS_SCOPE_20261108.md)。完成v10.1.6后仍有软件完善、整合、联合质量和评议；版本号不自动触发运营。当前继续v10.1.5，未启动v10.1.6；远期公司/资质/收费/运营另行决定。既有恢复义务、接受成果、冻结AC及保护边界保留。

本表汇总现有具名证据与剩余项，不按提交数/测试数换算完成率，也不将不同候选、不同设备或后端子范围拼成整版PASS。旧plan/task_order签发时IMPLEMENTATION_NOT_STARTED不是当前进度。冻结标准见[plan](plan.md)，本表不降低或重新冻结标准。

## 11项验收状态

| AC | 当前成果/有效证据 | 尚需关闭 | 状态 |
|---|---|---|---|
| 01 基线/数据保护 | 独立产品树、具名源码与运行合同；原dirty根/index、旧库/原证/STOP保护持续核对 | 最终候选统一身份与完整交付保护回执 | PARTIAL |
| 02 消息幂等/故障恢复 | 真机文字往返、冷启；真实MariaDB双同键并发；本次图片同键重放/不同payload冲突与跟踪状态保持 | 当前APP弱网/超时/重连等剩余用户旅程 | PARTIAL |
| 03 授权/跨账号晚响应 | MC/Block/CN关闭/peer禁用的真实后台锁交接；旧peer Bearer401；图片旧URL full/Range拒绝；保留前序WS与切号分项 | 其他接口/主体/时序、APP/WS/cache并发、旧JWT/room与跨账号晚回调、设备缓存直接证据 | PARTIAL |
| 04 私有图片/短视频 | 本次真实图片上传→private ready asset→消息附件→DB/文件hash→200/206→撤权旧URL404后端子范围通过 | 当前APP选择/显示、受控重启；合格ffprobe与真实短片输入及短视频完整正向链；媒体并发 | PARTIAL |
| 05 RTC保护/质量 | 既有RTC实现与历史分项证据保留 | 合格双端RTC/AEC、旧令牌拒绝与撤权提交后≤5秒停媒真链 | OPEN |
| 06 可信15/30计时 | 实际登录T0与冷启/在线恢复不续期已有证据 | 15/30边界、可靠时钟异常/回拨及对应受权路径的剩余验证 | PARTIAL |
| 07 加密离线/清理 | 现有策略/实现及此前检查保留，离线闭锁有分项观察 | 当前APP密文读回、切号/重启、超期清理与清理失败真链；缓存零写入未直接测量 | PARTIAL |
| 08 通知隐私/权限 | 既有站内通知、偏好与消息最小payload基线保留 | 当前系统权限拒绝/撤销、锁屏文案、旧通知点击重验及相关撤权矩阵 | PARTIAL |
| 09 Push供应商隔离 | 不将本地开关/替身写成真实送达，真实Push保持PENDING | token登记/轮换/注销与隔离transport剩余检查；真实供应商另需资格/授权 | PARTIAL；真实Push PENDING |
| 10 同候选运行/重启 | 源码Debug产包/真机安装/attach热重载；真机登录/消息/冷启/退出；持久MariaDB后台子范围 | 同一最终APK→API→MariaDB→独立Web→受控重启读回集中验证 | PARTIAL |
| 11 集中交付/审阅 | 节点原证、固定源码/manifest/本地与GitHub回执、非作者复核已持续保存；本表建立集中入口 | 最终整版唯一实施报告/manifest/候选包及统一复核；非作者Codex不是外部独立验收 | PARTIAL |

关键现有入口：[源码Debug产包](../../workflow/V1015_SOURCE_DEBUG_APK_VERIFIED_20261107.md)、[真机源码热重载](../../workflow/V1015_REDMI_ACTUAL_SOURCE_ATTACH_HOT_RELOAD_VERIFIED_20261107.md)、[文字往返/冷启](../../workflow/V1015_REDMI_TEXT_COLD_VERIFIED_LOGOUT_NAV_STOP_20261107.md)、[真机退出撤权](../../workflow/V1015_REDMI_LOGOUT_REVOCATION_VERIFIED_20261108.md)、[双同键/MC并发](../../workflow/V1015_MESSAGE_CONCURRENCY_DUPLICATE_MC_VERIFIED_20261108.md)、[Block/CN/禁用并发](../../workflow/V1015_MESSAGE_PERMISSION_MATRIX_BLOCK_CN_DISABLE_VERIFIED_20261108.md)。这些历史成果本轮未重测，限制继续按各原证保留。

## 本节点：私有图片真实后端链通过

任务`V1015_PRIVATE_IMAGE_20261108_01`，在Owner当前继续和既有同类普通本机工程委派下建立独立一次范围；前次所有已耗claim/STOP保持，不退款/重试。源码输入`063379626f5b282bc16c7b3023e0dbdd29d8c79a`；新增[媒体证据helper](../../../tools/acceptance/v1015_private_media/README.md)，未修改产品APP、鉴权、媒体或消息服务。apps树b673913a4ff0ff1a8bfc83ca98951ff1556a2f23、services树4530ae85754a2f3698d073182a47038708f2cb55保持。复用只读726文件服务快照/114包vendor，没有重复物化源码/SDK或框架迁移。

实际PHP8.4.27/Laravel13.39.0 HTTP API与持久MariaDB，新空库93表/单事务4虚构账号；3个账号真实登录、a/b真实CN/MC放行。使用本轮生成的32×32纯合成PNG，99字节，SHA256 `a99021907f3411b56426e791a2199d43d00a0a50b5ef3b09f02ad89b30e43943`，无个人照片或旧媒体输入。

| 实际操作 | 真实结果 |
|---|---|
| 坏图片、坏视频、伪造storage/public URL三次上传 | 各422；前后所跟踪6类媒体/消息数据均为空且相同，未造假READY |
| multipart PNG上传→发信→持久化 | private v1009 asset1 ready，实际文件/asset SHA与99字节一致；message1/attachment1/通知/发送事件各1；normalize job succeeded |
| 未绑定与绑定读取 | 未绑定owner200，receiver/第三人404、匿名401；绑定后a/b完整200，均为相同原始PNG字节 |
| Range与隐私头 | bytes0-15/99及91-98/99均206，分别16/8字节且等于原PNG切片；Content-Range、private/no-store/max-age0、Vary Authorization/Cookie、Accept-Ranges、nosniff合格 |
| 异主附件、重放与冲突 | 异主发送422；同键同payload返回同ID/replay；同键不同payload409；逐操作相邻快照确认6类跟踪数据无重复或原地改写 |
| 真实MC撤权后旧入口 | MC route200提交，CN仍ACTIVE revision2、双MC REVOKED revision3；同一个旧URL的a/b完整及Range共四404，历史/旧键重放两404，无PNG、私有caption/key/hash、成功身份或URL指针；跟踪状态不变 |

共26条媒体HTTP结果/body有hash与长度原证；登录/授权请求另记。捕获范围为assets（含本任务私有backing文件hash）、messages原始存储、attachments、message notifications、message_sent events及processing jobs，不宣称所有数据库字段/系统零写入。实际图片handler与存储未替换，不用Storage fake或mock kernel。HTTP禁代理/重定向，返回URL须匹配本任务精确loopback origin/asset，令牌不发到外部地址。

6项纯检查通过；内存中绕过拒绝身份判据会被纯检查拒绝。启动前非作者复核发现并修正两P2：解码URL/成功字段/私有marker漏判；foreign422/replay/conflict缺相邻快照。实际原证非作者Codex复核无P1/P2，不是外部独立验收。原生PHP8.5仅语法预检，本次图片链已在合格PHP8.4实际运行；真实故障注入收尾未测。

后端实际95.453秒，已耗1、余0，无重试，controller0/verified=true/cleanup_errors空。合计2GiB、启动3072MiB、1800秒/共享45秒收尾、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及DB restart0、离线保持。完整fresh核验只在既有入口执行一次：可用11727MiB、卷空闲354579017728字节仅为本次历史值。新WS/API/DB均停止/PID0/无OOM，退出0/137/0，API137不归因；新卷/网络留存。164个既有容器完整State前后一致且均停止，共享引擎保持运行；本轮没有新引擎、手机/ADB、产包/安装、云端、真实数据、外部服务或费用操作。

短视频正向**NOT_RUN**：开发配置没有合格ffprobe路径，对既有停止PHP实例的两个具名`/usr/bin/ffprobe`与`/usr/bin/ffmpeg`只读路径检查均不存在，旧实例State保持；不据此宣称全机不存在工具。未下载安装、接受新许可或用模拟verifier替代；坏视频422仅为负例。历史v10.0.9接受的视频成果保留，未按旧运行手册启动旧库/服务或无限寻找旧资产。当前APP选择/渲染、重启及媒体撤权并发均NOT_RUN，AC04/AC03仍PARTIAL、G2 false。

LOCAL_ONLY根名`v1015-private-media-lifecycle-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`verified-private-image-private.json`、`api-observations`具名前后快照、`backend-storage/media-http`结果/body、`non-author-actual-image-review-private.json`及最终回执。原dirty根255项状态/index及%SystemDrive%保护；ledger承接20304项仅追加本节点和上一最终回执，不重扫旧SDK/AVD/Sources。配置/token/SQL/私有日志/媒体不上GitHub。不合main/发布、不启v10.1.6，不自动建立后继动态额度。
