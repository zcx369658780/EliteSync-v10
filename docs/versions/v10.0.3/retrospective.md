# EliteSync v10.0.3｜Astra 独立事实复盘

> 日期：2026-10-13；[最终独立验收](acceptance.md) `ACCEPTED/CLOSED WITH OBSERVATIONS`。复盘不修改 [冻结计划](plan.md) 及此前 APP-INT-05 / v10.0.0～0.2 接受，不自动启动 v10.0.4。

## 1. 冻结目标与实现事实

| 目标 | 实际证据 | 不应扩张的范围 |
|---|---|---|
| 真正的动态 Guard 缺口 | 原 `appRouterProvider` watch Guard 每次重建 Router；原始真实 Router 7项中 2通过/5失败，合法 /progress→/home，禁用 Match→/home 而不是 Readiness | 原 bug 有实测证据，但不是正式 App/真实撤销链 |
| 有界源码修复 | **只改 `app_router.dart`**，使用 Provider listen→private ChangeNotifier `refreshListenable`，GoRouter稳定、onDispose释放；未修改 Guard 权威或 Router 拓扑 | 未新增平台生命周期、生产 writer |
| 真实 AppShell 消费与失效回退 | 新增唯一 `home_progress_guard_refresh_test.dart`，15项含 path/query/page、Readiness、Auth、深路径、Home/Match/Connection CTA、解除旧监听 | fixture仅 synthetic，既有 APP-INT-05 不重做 |
| 运行和安全证据 | 15新+27直接相关、42/42 Flutter通过，窄 analyze exit0，新15项受控外部哨兵0 | PHP/DB/BE-12 Feature/Android/Release/全App NOT_RUN |
| 可独立审查交付 | 固定 [候选](https://github.com/zcx369658780/EliteSync-v10/commit/e2f6db455a329c59b2b4158cc50c0e18561a7c99) 单父、Tree固定、45/45文件 Git Blob；失败与修复历程具名留存 | 本地109项资产保护为作者回执，非网页实际磁盘重算 |

## 2. 失败—修复与成本证据

- run-01：Flutter missing package graph，在加载前失败。仅受控故障摘要公开，本地自动 crash/doctor 原流没有发布；文档公开的是准确失败原因、exit 与哈希，不冒称全部 raw 在线可读。按已经存在的依赖图复用、不下载。
- run-02：新测试 Riverpod 3 `StateProvider` legacy import 漏项，编译失败；补测试 import。
- run-03 / run-04-baseline：旧 Router 七项2 PASS、5 FAIL，真实路径复现。run-05-fix 改到刷新而不重建之后七项全部通过。
- run-06-expanded：13 PASS/2 FAIL，源于测试 Future.error 提前报告未处理错误、UNKNOWN Readiness 预期有误；先挂订阅再提供 error、尊重原“前往准备状态”语义，无产品语义更改。
- run-07至run-13：扩展真实场景及 protected API 警告修正，把 HTTP 隔离从不充分的全局 override 改为内层 `HttpOverrides.runZoned` 的实效探针、退出码和最终42项通过；最终 Source/Test 相同原字节 identity，分析0问题。
- 最终 Flutter 联合测试收据计时约5.77秒、分析约3.39秒；**并非版本总开发工时**。实际总工时、token/额度、Owner外部等待 `UNKNOWN`，无法可信计算提速倍数。
- `app_router.dart` 保持已有CRLF惯例；保留代码与脱敏raw中应记录对应字节SHA，不能为了不相关 diff-check 默认行尾警告重写现有整份文件。

## 3. 流程结论与风险

- 第四次完整 `Astra提案→Codex去重与只读技术调查→固定冻结→Owner手动派发→Codex自主复现/修复/重测→GitHub固定候选→Astra独立验收` 有实际可审证据。相比前三版，**本版首次在指定核心 App Router 修复了直接观测到的真实路径错误**，并非纯合成诊断扩展。
- 事先将“源码 watch 存在风险”和“运行确有故障”分开，避免顾问预判当运行事实；旧 APP-INT-05 明确 ACCEPT，所以没有重复开发 Home→Connection→消息同意闭环。
- Codex 首轮工具问题与后续测试时序故障均在同版自主解决，未改变冻结 AC/扩大写路径，也未将未经批准的原脏 local root 成果整包携入。
- HTTP 哨兵经过内层 zonal probe 才成为有意义的外部访问负向证据；但只代表新增15项测试的受控路径，不升级为**所有 App 访问层生产许可**。
- 实际 Flutter Router dispose/刷新测试 ≠ Android进程/后台恢复/热重载长期稳定；缺真实 event source，后续如接正式 Auth/Readiness 时仍需单独授权、再测试实际身份和失效传播。
- 长期 Owner 规则 K08：本版验收后安全定点集成 GitHub **仅两个产品代码/测试对象**，并由 Owner 手动指派 Codex 建立新版可用隔离开发基线，旧脏根不动。集成成功与新基线真实重测必须分别登记；本复盘不是 GitHub merge 或本地完成证明。
- 旧暂缓事项 BE-12 404、V57/H1/H2/D0、M6 不开放；下一版需 Owner 产品方向决定，不自动立版。

**`V10.0.3 RETROSPECTIVE COMPLETE — FOURTH BOUNDED PILOT WITH ACTUAL ROUTER DEFECT REPAIRED — POST_ACCEPTANCE_SAFE_INTEGRATION_SEPARATE`**。
