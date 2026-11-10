# EliteSync-v10｜v10.0.5 Astra 最终独立验收

> **ACCEPTED / CLOSED WITH OBSERVATIONS — PROGRESS THREE-STAGE READONLY CONSUMER — SYNTHETIC/DEV-TEST SCOPE**
>
> 日期：2026-10-14。Astra 为独立于 Codex 作者的最终验收人。本结论不更改冻结计划、前五版接受或实际产品权限。验收归档时 Integration 为 `ISOLATED_CANDIDATE / NOT_MERGED_TO_MAIN`；后续依 Owner 已批准的 K08 规则另行核验定点集成和本地隔离基线，不由验收自动推定已完成。

## 1. 不可变依据与候选身份

- [冻结计划](https://github.com/zcx369658780/EliteSync-v10/blob/2f9027f901f1a4a9804e64f16bdbdf9a50f8221e/docs/versions/v10.0.5/plan.md)：commit `2f9027f901f1a4a9804e64f16bdbdf9a50f8221e`；Git Blob `fd490f9204869504a17ae5b4263bc25e7a5a6f74`。Astra 实际读取了完整计划及 AC-01～AC-07。
- [固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c)：`8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c`；Tree `63a1e9cfe602a274a91e712c8c802c434b4d0550`；唯一父 `4a7091b580977044861ae50ff9b404842ed68283`。已从 Git commit 与 compare 实际核验 sole parent、ahead 1/behind 0 和所有变更路径；分支 `codex/v10.0.5-progress` 已回读指向此候选。
- 相对代码父共 24 个变更路径：一个 Progress 产品源修改、一个新增测试，其余均为本版报告、manifest 和安全证据。Home/Router/Guard/Match/Connection/Conversation 源码及既有测试不在变更清单内。
- [执行报告](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/execution-report.md) Blob `4c7d853d1be7c96d154dc9fc7b926030b276a37f`；[manifest](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/manifest.json) Blob `a8df67d5a32a21e46a127c05be8e45fa8e1c07da`。23/23 payload 路径均实际 fetch，返回的 Git Blob 与 manifest 逐项匹配，manifest 自身不纳入自己的 payload。
- 最终 `progress_page.dart` Blob `4057ee2c101106a3105143b88948eeee78c9fe78`；新 `progress_page_test.dart` Blob `90413fd290611c0e6bd142e287e291c87dba1cda`。Git 对象核验不等于网页重新计算 Windows checkout 或未发布 raw 日志的原始字节哈希。

## 2. 实际源码与运行证据审查

### 三域只读消费及来源边界

Astra 完整读取 Progress 源码、新测试及继承的 `calmHomeProjectionProvider`。Progress 改为 ConsumerWidget，只 watch 既有聚合器并过滤 Conversation 摘要；没有新增 provider、生命周期控制器、存储、HTTP 或业务写入。保留两个原入口/key/go 路由；新增 Readiness 查看采用现有 `meReadiness` push，不复制 Home 的 nextDecision，因此没有 Messages、RTC 或 Relationship 动作。

私有 `_stateLabel` 只解释相应域的已有命名代码；unknown/notYetEstablished、空或不识别代码统一为“当前无法确认”。noRound/noCandidate 的空 Match code 没有被解释成完成、失败、过期或不合格。演示状态逐项标 Synthetic，并声明不代表正式事实或权限。Connection pause/close 替换旧 active；Readiness UNKNOWN 没有新增撤销 Connection 政策。

非 Dev 或 Home 演示 flag 关闭时，继承聚合器在读取业务域之前返回保守投影。对应两项新测试实际断言 Match source reads 为 0，Connection/Conversation provider 没有建立。Dev 演示下聚合器仍间接订阅已有 Conversation synthetic provider；本验收不将其误称为完全无 Conversation 依赖，也没有从中授予消息权限。

### 真实路由、动态变化与可见性

新测试使用真实 `appRouterProvider + MaterialApp.router + AppShell`，其中 15 项经真实聚合器和虚构来源驱动，另 4 项以投影 fixture 验证不识别代码的消费者边界。测试覆盖同次挂载 Match loading/error/failed/closed/noCandidate/noRound 后旧提案消失、三个活动 Match 状态、Connection active→paused→closed、Readiness UNKNOWN 保持 Connection、切 Home 后返回的当前状态以及三个真实详情入口/返回和既有 Match Guard 回退。

320×640、2 倍文字的测试实际滚动、检查摘要与入口 hitTestable 后 tap，并检查无 Flutter 捕获的布局异常。它证明 Widget 测试条件下的可读/可点击行为，不是 Android 设备或人工完整视觉验收。

### 最终结果与源身份绑定

- [final-tests-02 stdout](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/evidence/final-tests-02.stdout.txt) 最终为 `+51: All tests passed!`；[run-receipts](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/evidence/run-receipts.json) 对应 exit 0。五个测试文件为 Progress 19、synthetic Home loop 11、动态 Guard 15、synthetic Connection lifecycle 4、Connection page 2；合计 51，未将旧候选成绩冒称本版执行。
- [final-analyze stdout](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/evidence/final-analyze.stdout.txt) 明确 `No issues found!`，同一收据记录 exit 0；不只依赖退出码。
- 最终测试和分析共同记录源码 raw SHA256 `e24a38835b251efbb7f97e2c945819dc5f78462b323595a21bdc2453ddf4ba3d`、测试 raw SHA256 `5ba83cc8f2f1ce6790a6ee389572e398c0b43bc3f6c1136a6e3018601453c378`，与 manifest/source-identities 一致。
- 两个最终 stderr 均实际读回为空。`stream-identities.json` 将本地原流哈希与路径脱敏后的发布副本哈希分别登记；例如 final-tests-02 原 stdout 为 `783adb4b4f519dc4f3c10fa448c5c45c3abcc28948818e921724eaf85bf2cd85`，发布副本为 `622afaa6ab0c24da691bf52e0d820a8448646d996a2b63aea5ec5cf66107ad22`。差异是已声明的脱敏变换，不能把两个对象混称同一原字节。

### 隔离与原现场保护

新增 19 项测试均采用内层 HttpOverrides.runZoned：先确认 HttpClient 拒绝探针触发一次，重置计数，再在业务段及卸载后检查 HTTP 0；API/Dio/secureStorage/remoteMatch/遥测 provider fail-fast 总调用 0、内存存储写入 0，RTC watcher=false。最终日志包含对应 `PROGRESS_SAFETY` 与 `PROGRESS_HTTP_SENTINEL` 标记。此证据只覆盖新增测试的具名受控路径，不声称全部旧 32 项具有相同哨兵或全机器无联网。

[preservation.json](https://github.com/zcx369658780/EliteSync-v10/blob/8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c/docs/versions/v10.0.5/evidence/preservation.json) 记录原脏主树及共 10 份既有工作树的 HEAD/index/status 前后一致、109 项具名文件 unchanged。Astra 实际读取该回执，但没有访问 C:/D:、没有独立重算全部本机文件或全量历史 EVIDENCE；候选工作树 CLEAN 仍为 Codex 本地回报。

## 3. 冻结 AC 裁定

| AC | 最终裁定 | 适用证据 |
|---|---|---|
| AC-01 源身份、保护、去重 | PASS | 固定单父、限定 24 路径变更、继承源/历史边界及具名本地保护回执 |
| AC-02 Progress 实际消费者 | PASS | 真实三域摘要、来源说明和三个受限查看入口，无新领域写入 |
| AC-03 失败关闭和动态清除 | PASS | 负向 Match 六类、空/未知代码、Connection pause/close、无撤销政策或消息授权 |
| AC-04 路由与受控安全 | PASS（synthetic Widget） | 同次 Router/AppShell、返回/Guard、窄屏双倍字；新增19项受控零调用且检查卸载 |
| AC-05 实际范围回归 | PASS | 最终51/51、exit0；分析明确No issues found且exit0；初始失败链保留 |
| AC-06 固定独立证据 | PASS | 23/23 payload Git Blob、完整关键源码/测试与最终安全原证可读 |
| AC-07 独立终验和后继 | PASS | 本文及事实复盘归档；验收、远端集成、本地新基线和重测各自记录，不自动v10.0.6 |

## 4. 保留观察与最终结论

首轮 regression-01 为31 PASS/1 FAIL，新增摘要使旧测试的 Match 入口超出首屏；progress-01 为18 PASS/1 FAIL；combined-02 为46 PASS/5 FAIL，存在懒构建与测试滚动定位问题。作者保留旧测试，修正入口次序、有限内容的滚动布局及新测试定位，随后联合通过。analyze-01 虽 exit0 仍有 prefer_initializing_formals lint；作者交付前已修复并重测，不需要本次再派 R1，也未伪称旧分析干净。

未建立正式 Readiness 条件集合、身份/准入政策、可信生产状态源或真实消息许可。全应用、PHP/后端/BE-12 Feature、Android/设备、Profile/Release、生产及真实账号数据均 NOT_RUN。BE-12 opaque404、V57/H1/H2/D0、RuntimeReady=false、M6 CLOSED 等保持。

**FINAL：V10.0.5 ACCEPTED / CLOSED WITH OBSERVATIONS。未发现冻结范围内必须返修的问题。** 后续仅按已批准 K08 程序安全定点集成两项接受代码，再由 Owner 手动转交 Codex 接续隔离本地基线并实测；本结论不代表这两项收尾已经完成。
