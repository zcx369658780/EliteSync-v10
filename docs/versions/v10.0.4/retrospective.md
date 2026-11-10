# EliteSync v10.0.4｜R1 独立事实复盘

> 2026-10-14；与 [最终独立验收](acceptance.md) 配套。原冻结计划和历史失败证据原样保留；本文件不重新冻结、不启动v10.0.5。

## 实际成果与限定

- **真实产品改善**：`Me → Readiness` 原用户页面增加“当前状态来源”、“正式条件集合尚未确立”和两个兼容恢复入口的用途解释；非Dev异常READY不再显示无证据的“权威来源确认”；Dev示范明确Synthetic，Guard变更移除旧成功。没有猜测正式required/optional、身份等级、用户有效期、年龄/地区政策、实际身份或消息权限。
- **仅两项源码/测试**：`me_purpose_pages.dart` 改动限Readiness类与专用私有展示；新测试 `readiness_purpose_page_test.dart`。旧Me其它四种用途及Router/Guard/Verification/Questionnaire/后端业务代码不变。
- **真实可观察测试**：最终R1新8项Readiness测试+旧5项直接相关用例合计13/13通过，退出码0；两文件`dart analyze`实际stdout `No issues found!` 且exit0。真实AppShell/Router及兼容目的页、返回、非Dev/Dev、动态状态、320×640/2倍文字覆盖；受控外部哨兵0仅代表新增8项的有限依赖。
- **可审核来源**：固定R1 [候选](https://github.com/zcx369658780/EliteSync-v10/commit/bd688297da097297f1d8918631d74b8ca6292010)单父`5728251c6345ba17524fb323dac8a02573d8d8c6`，Tree`d0325969a6382a5897a37c60702dca4161d4c1f7`；39/39manifest文件Git Blob逐个从候选读取一致。执行回执、最终stdout和首轮错误报告分开留证。

## 失败与返修：为何必须检查stdout而非只看exit0

1. 首轮run-01新8项失败，部分因真正缺失来源解释，另有测试harness入口/滚动问题；run-02～03在不改业务权限和Router的情况下修复dock遮挡/路由路径断言，run-04～07联合13项通过。
2. 原候选run-08静态分析`exit0`，但stdout明确`1 issue found: curly_braces_in_flow_control_structures`。原执行报告误称“无问题”；Astra首轮终验据原stdout将AC-05标为PARTIAL并要求同版R1。**退出码0≠无lint**。
3. R1在新隔离候选里仅给`if (displayOnly)`新增一对花括号。网页独立比较原测试全文和R1全文证明**除此之外无差异**，产品源Blob完全不变，旧13项断言和路由目标未降级。
4. R1重新执行同三份测试文件及两文件分析：测试`+13 All tests passed!`、分析`No issues found!`，两个exit0；报告显式承认前版误报。原候选和run-08坏分析stdout留原Git对象，未回写“修好”的历史。
5. 根dirty main/既有干净基线与旧候选隔离worktree均有前后HEAD/index/status不变的Codex作者回执（原根109具名保护零变化），网页未直接检视Windows盘。总开发工时、token和Owner等待未可靠计量，记`UNKNOWN`。

## 可复用的流程经验（不增加审批）

- 下一次“分析无问题”须同时核对实际stdout与exit_code；既有有限运行回执足够，无须新增全面静态审查工具或强制外部review。
- 先用真实已接受的UI与Router，再对准新场景增量，避免把后端synthetic条件或历史兼容验证字段冒称正式权威。
- R1属于原版冻结AC内的**一次集中返修**，不是重新启动版本、重开路线图、扩大源码白名单。一次错误发现与修复，正常的研发行为可透明留下证据。
- 按长期 K08，在独立验收后**定点集成两个已接受Git Blob**，再由Owner手动交Codex安全接续新本地隔离基线并做有限目标回归；原dirty root、完整Feature/Android/生产资格不会因此自动改变。

**RETROSPECTIVE CLOSED — R1 LINT CORRECTION VERIFIED, NO AUTOMATIC v10.0.5.**
