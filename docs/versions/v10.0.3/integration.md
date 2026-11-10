# EliteSync v10.0.3｜独立接受后 GitHub main 定点代码集成回执

> 2026-10-13（Asia/Shanghai）。**Owner 预先授权的版本验收后安全集成默认程序**：见 [CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md) K08 规则。此次仅将固定已接受的**一个 Router 源码和一个测试文件**定点纳入 GitHub main，不合并候选历史或未审核的原始报告/日志。  
> 本次实际整合提交 SHA 由 GitHub 发布回执和 [main 版本登记](../README.md) 指认，本文不提前自造其自身 commit 哈希。集成前 GitHub main `5788427d96897f795ea777d6bc06753b9f07ea73`，代码来源候选 [`e2f6db455a329c59b2b4158cc50c0e18561a7c99`](https://github.com/zcx369658780/EliteSync-v10/commit/e2f6db455a329c59b2b4158cc50c0e18561a7c99)，Tree `bd2d0c30cf8fc1d9efd39ffbb52481375ff8fafc`，单父 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`。

## 1. 独立接受依据与集成白名单

- 本版冻结计划 [plan.md](plan.md) Git Blob `4472647408af1f972e365ac66cd8c42d127fff34`；[Astra 独立验收](acceptance.md) `ACCEPTED/CLOSED WITH OBSERVATIONS`；[复盘](retrospective.md) 的 bug 复现与回归记录已发布。接受范围为真实 Flutter Router 的 **synthetic/dev-test** 动态 Guard 路由和有限代码修复，不是正式 auth/message 授权。
- 固定候选相对其代码父提交只改一个 Router 产品源码并新增一个 test；其余45项候选 manifest为报告、测试证据和版本工具，完整证据继续可从原固定候选读取，主线不重复复制。

| 要纳入 GitHub main 的完整路径 | 已接受的 Git Blob | 原 main 状态 |
|---|---|---|
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `2eebd3f0959414f95e2a3ec61e94d73a2779d795` | 旧 Blob `bd68bfecff4a424cf580ec8bee058952122032e1`；此前未改产品源码 |
| `apps/flutter_elitesync_module/test/app/router/home_progress_guard_refresh_test.dart` | `6811828ffc8c2c37f752902d7f91513d6c5dc478` | 此路径不存在，新建 |

在集成前单独比较代码父 `fb8aa352...` → 当前 main `5788427d96897f795ea777d6bc06753b9f07ea73`：后续仅7份版本/治理文档变化、**0个 apps/services 产品源码变化**，所以没有覆盖其他主线实现的路径冲突。已接受旧 APP-INT-05、Home、NavigationGuard 和上三版累计17项安全代码保持原 Git 身份。

## 2. 验证和不可推导的事实

- **GITHUB_MAIN_SCOPED_CODE_INTEGRATED**：代码以 Git tree overlay方式按两个精确 Git Blob 纳入已有 main 的文档历史；不对分叉历史做 merge/cherry-pick，也不修改冻结计划、拒绝原件和旧 acceptance。发布后按固定 main 逐个 readback + 对比变更清单，才能称整合成功。
- **POST_INTEGRATION_RUNTIME_NOT_RUN**：固定候选在其最终身份下42/42 Flutter相关测试通过、analyze exit0；**GitHub本次远端集成没有新运行测试**。不得把候选 PASS 当成新 main 的独立运行回归。
- **LOCAL_BASELINE_PENDING_NEXT_SYNC**：上一已验证隔离干净本地基线 HEAD `2175dd62d9384efa05dd6b5201f58c5282379fbb`；原脏主树 `D:/EliteSync-v10` HEAD `4bebc8f...`，两者均未由本次网页操作改动。需 Owner 手动把新 main SHA 交给 Codex，在保护原旧工作树/109资产下安全建立/接续新隔离开发基线，再进行限域运行重验；不能由 GitHub readback 宣称本地已完成。
- BE-12七条真实消息路由仍默认404，未开放真实 Chat、M6、V57/H1/H2/D0、生产权限或正式 Android 资格。新版 v10.0.4 未规划或启动。

**`V10.0.3 SCOPED ROUTER FIX INTEGRATED_TO_GITHUB_MAIN — LOCAL_BASELINE_PENDING_SAFE_HANDOFF — POST_INTEGRATION_RUNTIME_NOT_RUN`**。
