# EliteSync-v10｜v10.0.6 Astra 独立最终验收

- 决定：**ACCEPT — WITH OBSERVATIONS — SCOPED REAL DEVELOPMENT END-TO-END**。
- 决定日期：2026-10-14。
- 冻结计划：[固定 v10.0.6 plan](https://github.com/zcx369658780/EliteSync-v10/blob/dbe02b9ba603b79820f77ee28663787e405ccc4f/docs/versions/v10.0.6/plan.md)；Blob `77eee557325449543710fc4d5fe2b10aa712fa46`；AC-01～AC-07 未改。
- 代码起点：`3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`；Tree `59969abfc9d04185769b22af5f7ea5d629007a33`。
- 接受候选：`08ce3571ce02af3dea5960705b72cd9737dccb95`；Tree `0cfae117b88a3313b854ecc9a7739b303c06e0f3`；分支 `codex/v10.0.6-restoration-admin`。GitHub 现场 readback 一致；相对固定起点 ahead 5 / behind 0，merge-base 精确为起点。
- 产品源码/构建锚点：`6a6642aa457188866a1b8cd6d9cc733aff86a0c4`；Tree `faede5665a4ffa386bf23257af08a2b46be89351`。GitHub 差异核实该锚点至候选没有 APP/backend 源码或测试更改。
- 交付：[执行报告](https://github.com/zcx369658780/EliteSync-v10/blob/08ce3571ce02af3dea5960705b72cd9737dccb95/docs/versions/v10.0.6/EXECUTION_REPORT.md)｜[Manifest](https://github.com/zcx369658780/EliteSync-v10/blob/08ce3571ce02af3dea5960705b72cd9737dccb95/docs/versions/v10.0.6/manifest.json)｜[Runbook](https://github.com/zcx369658780/EliteSync-v10/blob/08ce3571ce02af3dea5960705b72cd9737dccb95/docs/versions/v10.0.6/RUNBOOK.md)。

## 独立证据方法和限制

Astra通过已授权GitHub读取固定候选的执行报告、Manifest、Runbook、关键 Android/Flutter/Laravel 源码和测试、命令收据及原始安全 stdout/stderr、数据库与 API 读回、账户身份/会话及资源证据；以 base64 方式实际读取并查看 APP 与 Blade 浏览器截图（包括城市保存、重新登录、重启、禁用、退出）。抽核11个源码/测试/截图对象，Git Blob 与 Manifest 全一致。真实设备和数据库操作由Codex执行：**Astra并未连接Windows本机、重新运行服务/ADB，亦未下载本地AAR/APK或独立计算其物理文件hash**。安全证据独立可读，不冒称二次本机操作。Manifest内40个源/测试对象与204个证据对象是索引范围，非声称40/204全被Astra逐项读取。

## AC-01～AC-07逐项判断

| AC | 判断 | 主要证据与限定 |
|---|---|---|
| AC-01 来源/环境/隔离 | **PASS** | 起点及候选/分支Git核验；原Android宿主、Flutter AAR、Laravel代码；Docker身份回执为 MariaDB10.11.18 / loopback43316 / 专用 volume、57迁移、仅三个具名虚构用户。原dirty根保护回执为105个实际测量文件、HEAD/index/status/AGENTS一致；Windows状态属CODEX_REPORTED；不把历史109全部追认。 |
| AC-02 APP城市 | **PASS** | 实际APP“保存城市”截图、源码独立POST后GET严校、ID2的users.city从Initial Development City变为V1006 City A，API/DB确认；再次进入、登出再登录、重启后仍一致；astro rows=0；“保存并重算”入口保留。 |
| AC-03 Blade管理 | **PASS** | /admin真实浏览器截图：ID1管理员查询ID2，禁用前“正常”，禁用后反馈/“已禁用”；API与Web复用DisableUser事务；数据库 disabled=true/moderation_status=banned，tokens/sessions归零；Web logout后返回登录。 |
| AC-04 账号与角色边界 | **PASS** | 后端AdminAccess严格要求未禁用、role=admin且明确名单；空名单/在名单中的普通用户及有效CSRF非法角色POST有Feature测试；旧target token/profile/city/refresh401，新登录403；真实APP清会话及登录失效提示，无虚假成功。control ID3仍可登录、城市POST+GET200。普通用户持久session先有1条再禁用归零，复用旧session返回401。 |
| AC-05 重启与一致 | **PASS** | 两次docker restart exit0与Laravel重启记录；无重seed操作的ID2城市/禁用、ID3正常及城市状态前后数据库读回；API与APP/Web截图交叉印证。 |
| AC-06 构建与验证 | **PASS WITH OBSERVATIONS** | Flutter62/62 exit0；16文件dart analyze stdout No issues found! exit0；PHP 21/123＋4/38 exit0，均有receipt及原输出；Android构建09 BUILD SUCCESSFUL、APK install Success exit0。Manifest登记AAR 3,953,207B / SHA256 6521ff058334f16b24994ed03c8ee8271d0c886efbb7232ce65a93371448b9ad，APK 213,058,140B / SHA256 213c1a3a7081c339626e841706fad08d88e793e8610c93492d297be20cd3f965；本地文件未对Astra开放，哈希为CODEX_REPORTED。 |
| AC-07 交付/独立终验 | **PASS** | 固定GitHub候选、源/测试、操作安全证据、Runbook/Manifest与恢复台账可读；AAR/APK定位为LOCAL_ONLY，保留可复用卷和私有配置；本文件为Astra独立终裁。Acceptance、GitHub代码集成、本地代码基线、目标运行分开登记。 |

## 保留观察项，不构成本版临时新增门槛

1. 较广PHP测试30项有5项既有问卷/匹配题库缺失错误，exit2；本版直接相关25项161断言exit0。不能宣称完整PHP suite PASS。另有PHP8.5 vendor弃用、PSR-4 fixture warnings、Android strip/NDK提示，均已公布。
2. Android构建01–08失败/取消记录保留，09成功；首次Composer安装及迁移的完整原始流未捕获，但后续install readback、迁移status、数据库表及操作实测提供有限替代证据；不追写不存在的原始记录。
3. 独立Web禁用页面只允许对普通账号实施；现有Admin API同名禁用动作虽复用共享事务，但其target角色限制没有完全同步。固定AC没有要求新增管理员互禁策略；此差异可在后续管理员模块的明确范围内收口，不在本版事后加门槛。
4. APP及浏览器的运行确认仅适用于专用本地MariaDB、AVD与虚构账号；历史SQL/VHDX内容、真实用户/生产、问卷/算法/消息/RTC/全APP端到端仍UNKNOWN/NOT_RUN。BE-12等先前保护未解冻。
5. 安装包和大型Windows原证在本地，Astra未直接下载；绝不等同于GitHub附件可获取或生产可安装发布。

## 收尾分类及下一步

- **Acceptance：ACCEPTED WITH OBSERVATIONS（仅v10.0.6冻结范围）**。
- **GitHub源码集成：NOT_YET_DONE**；仅记录正式验收，不能将本文件视为源码已进入main。
- **本地接续基线：CODEX_REPORTED 专用候选CLEAN，K08尚未执行**；原dirty根未被授权覆盖。
- **目标运行：CODEX_REPORTED 实际运行通过、最后服务/容器/AVD STOPPED，volume与私有配置保留**。
- 按现行K08下一步须由Owner手动转交Codex进行具名、安全的代码集成及必要本地接续/回归，记录结果；不默认新工作树、不重新跑全部历史、不因纯文档同步全量重测。
- **v10.0.7 NOT_DISPATCHED**。真实账户、历史数据或生产部署仍需各自授权。

结论：`V10.0.6 ASTRA FINAL ACCEPT — WITH OBSERVATIONS — CODE INTEGRATION AND LOCAL CONTINUATION SEPARATE`。
