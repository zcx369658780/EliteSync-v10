# v10.0.11 Astra 独立验收

**2026-10-18 — ACCEPTED_WITH_OBSERVATIONS / AC-11-01..08 ACCEPTED IN FROZEN SCOPE / PRODUCT MAIN INTEGRATION NOT AUTHORIZED BY THIS RECORD**

## 1. 裁决

Astra 独立审阅 v10.0.11 冻结计划、候选源码、关键实现、机器可读 profile registry、独立参考实现、最终 Python 测试输出、PHP 测试输出、交付清单、源对象清单、数据库/APP 结果摘要、脱敏执行回执与既有复核记录。

**裁决：ACCEPTED_WITH_OBSERVATIONS。** 冻结范围内四组确定功能达到候选接受标准。没有发现足以拒绝本版候选的剩余代码或数学阻断。此接受不代表生产/商用发布、不代表所有天文结果达到物理真值精度、不代表历史条件功能已实现，也不授权直接合并 main 或启动下一产品版本。

## 2. 固定接受身份

- 冻结计划 Blob：`eb6de5a0ef6cdbd0cc8aa2fd35826a22b88b63d9`
- 最终产品源码锚 Commit/Tree：`78ab7827b258cb649920e5121f24d506dae2a93c` / `6f3edd909f37a3a0b8ecaf3fa8da1af02a47f186`
- 完整 apps Tree：`fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7`
- 完整 services Tree：`29cedff599411c7c246ba32e62d53b5d63e28f3f`
- Codex 交付 Commit/Tree：`2d7e96c315a3c19345a4b9d5af3969ddcff4e0ea` / `7ec351844db5c9d989cfd033093df57caee8d306`
- 脱敏审阅包固定于 Commit：`ab8e5a307fe4fe10b90c1fbfe2ff54fc68553b44`
- 实际安装 APK SHA256：`67aa8b7d33dbbbf8ce225612943583e8a898a0b23c3e1ebae593e5baadde7943`
- AAR SHA256：`8126dd9fdc90bdb578b2c3c0d4e7522221b56dac4247fe496423f68d4b133ac0`

接受以固定源码锚及上述制品/证据身份为准。交付分支后续可增加本验收记录，但不得改写接受源码锚、制品hash或将文档后续Commit冒充产品源码。

## 3. AC 终裁

- AC-11-01 来源与完整性：PASS。四组功能与条件旧功能区分清楚；Comparison 不冒称 Composite。
- AC-11-02 输入与私有工作区：PASS。合同拒绝未准入输入，私有结果与计算身份、revision及运行身份关联。
- AC-11-03 双人盘：PASS。实现与独立几何参考覆盖跨侧相位、orb、圆周角、方向性落宫及交换行为；真实 APP 手填链有交付证据。
- AC-11-04 行运：PASS WITH OBSERVATION。目标时刻参与计算，缓存依赖、速度/逆行与外部位置参考已登记；位置数据谱系与生产模型共享关系见观察项。
- AC-11-05 回归：PASS。独立实现完整扫描查询窗口；公开测试16/16 exit0，覆盖零/多事件、边界、环绕、方向、残差与求根区间；真实 API 1900/2100完整窗口及2001零事件、2004多事件结果已回读。
- AC-11-06 持久化/权限/并发：PASS。代码检查确认所有权、禁用用户、revision/CAS、STALE隐藏、迟到响应与Flutter会话隔离；Codex报告真实安装 APP→Laravel→隔离 MariaDB、重登及服务/DB重启读回。
- AC-11-07 独立验证与回归：PASS WITH SCOPE LIMITS。独立数学/事件搜索代码已审阅，明确披露共享位置模型及外部JPL谱系；历史失败没有被抹除。
- AC-11-08 完整交付：PASS WITH EVIDENCE LIMITATION。交付源码、APP子树、制品hash、最终候选、测试输出、资源终态和公开脱敏审阅包的身份闭环足够用于本版接受。

## 4. 必须保留的观察项

1. **真实运行证据等级。** APP、Windows/AVD、API、MariaDB、退出重登和重启实测属于 Codex 报告的本地执行。Astra 对发布到 GitHub 的脱敏副本、hash/exit清单、关键stdout/stderr、源码与测试进行了独立审阅；未直接运行用户 Windows 环境，也未重新安装 APK 或连接其本地数据库。完整原始执行流、APK/AAR二进制及私有物理数据库仍为 LOCAL_ONLY。因此不得把本次接受描述为 Astra 自己重跑了完整端到端环境。
2. **天文精度。** 独立事件搜索共享已接受的 PositionModel 位置层，DE441 与 DE440s 有共同 JPL 谱系。求根 bracket 与 residual 仅证明同一模型内的数值收敛；相关输出保持 `CALCULATED_UNVERIFIED`，不构成物理星历精度或玄学预测有效性认证。
3. **条件旧功能。** 真正中点 Composite、完整 Firdaria、完整 Annual Profection 仍为 `SOURCE_NOT_ESTABLISHED / NOT_IMPLEMENTED`，仅在已核实的具名旧源范围内作此结论；继续留在内测前恢复台账，不冒称已经实现，也不声称所有历史版本绝不存在。
4. **历史及未运行范围。** 既有全量 PHP 16项失败、旧 Flutter 与 RTC/AEC/回声、call65额外终态读回缺口、旧/up根因 UNKNOWN、PDO8.5 deprecation、PHPUnit docblock warnings 均按原记录保留。本版没有执行生产发布、RTC、完整 APP+Web 联合验收、付费许可或真实用户数据外发；均为 NOT_RUN。
5. **隐私交互。** UI 已展示私有排盘用途和不作为关系事实/匹配评分的说明。后续若扩大到分享、上传或读取另一用户资料，必须另行设计明确授权，不得从本版私有手填功能推导此权限。

## 5. 状态边界

- v10.0.11：`ACCEPTED_WITH_OBSERVATIONS`，仅限冻结计划范围。
- v10.0.10：原 `ACCEPTED_WITH_OBSERVATIONS / K08_INTEGRATION_COMPLETE` 不变。
- main：未改动本版产品源码；本记录不授权 main 合并。
- K08/后继集成：需单独冻结任务并由 Owner 手动派发；不得自动执行。
- 下一产品版本：`NOT_STARTED`。

候选实施报告与脱敏审阅包继续保留原件。任何后继集成须从上述接受源码锚显式选取产品对象、保护 main 并发文档、保留原 dirty 根和历史证据，不得盲目 merge 整个开发分支。
