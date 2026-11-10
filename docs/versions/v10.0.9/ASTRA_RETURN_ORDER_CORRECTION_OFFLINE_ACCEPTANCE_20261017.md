# EliteSync-v10｜v10.0.9 真实网络 exit31 来源返回顺序修复：Astra 离线终验

2026-10-17。**RETURN_ORDER_CORRECTION_OFFLINE_ACCEPTED_WITH_OBSERVATIONS / NEW_REAL_NETWORK_AUTHORIZATION_REQUIRED / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED / NO_K08 / NO_NEXT_VERSION**。

## 1. 独立审阅固定身份

Astra使用GitHub连接实读临时分支 `review/temporary-evidence-v1009-return-order-20261017` 的固定Commit `3175f3c9427f53843fda79f88c641602c5333c7a`、Tree `d4260ef777e75430662d170a006a7ec88bbdbcab`，唯一parent `29984bd24da0f0cffc3a977d825cb014903d40b9`。GitHub独立枚举 `docs/_temporary_review/v1009-return-order-20261017` 子树含**73个blob**（递归结果未截断），`ORIGIN_AND_REDACTION_MANIFEST.json`68个条目对应实际存在的文件；`FILE_INDEX.md`有71个文件链接，另两个是`FILE_INDEX.md/json`自索引文件，无遗漏路径。原exit31审阅分支在本次独立GitHub API查询返回404。

独立UTF-8 SHA256重新计算**17个关键公开文件**，包含7个运行脚本副本、6个离线测试工具、`audit/SHA256.json`、`audit/FROZEN_TEST_BINDING.json`、冻结38项结果及原故障RED复现结果，17/17与已提交的公开副本SHA映射完全相符。另使用七个**声明的原始文件SHA**按`contract.py`所规定的JSON排序哈希算法独立计算Bundle digest，得到 `a8d52ef415ef4157052a0fa128564d36195fc235b595ae51f001e1c67b5ab4ee`，与报告一致。**这只证明Bundle指纹计算与声明哈希一致，不证明Astra直接读取了两份本地私有原件。**

原R3 bundle `abff4948f8cb18e11b3b8c3c5efd3e776d48946a36ae3f55637f022b9f1b1425` 保留；新Bundle只改了3个实际运行文件：
- `network_core.py` SHA256 `205150bbd99f00fa1879f58fe54490c4825174fd19fd6b3d141cc86baf503971`
- `live_provider.py` SHA256 `505f222f72586f05520e1bda64b803c5876837a4f6c4dfdee3f299841b3ca595`
- `FirewallAdapterCore.ps1` SHA256 `cc9034d8742699c2012140005c8091285755dd2a7ae84d2d2a24a71542086f7c`

其余四份运行文件按原始SHA不变。公开副本中的`contract.py`和`FirewallAdapterCore.ps1`由于隐去原绝对路径（可能也移除BOM）与本地原始字节不相同；来源/公开映射记录了区别。真实执行前必须在Codex本机重新逐个SHA以及bundle核对，绝不能运行审阅副本。

## 2. 源码与测试闭环

Astra实际审阅了`audit/RETURN_ORDER_CORRECTION.diff`、7个运行脚本、`tools/run_return_order_matrix.py.txt`、`OfflineAdapterHarness.ps1.txt`、原48/37/5测试工具及`audit/INDEPENDENT_REVIEW.md`。

- 请求仍走原顺序敏感`_normalized`，绑定固定来源参考SHA、原WLAN/LocalAddress、TCP7881/UDP7882及四规则。系统返回spec的`_observed_spec`先核原始类型/成员/数量/唯一性及其它精确字段，且仅成员集合一致才回填可信序列；名称/身份/实例变更不得进入`owned`或获得删除资格。
- 创建回执在Query前固定具名实例；收编、后续创建前检测、verify、cleanup都校验归属与身份；系统观察名称畸形不当作零条；清理只对证据证明的当次对象执行。PowerShell Remove保留PersistentStore、Name/Group/Description/InstanceID及全部非来源字段精确复核，仅将来源项按无序成员核对，避免此次真实源数组重排故障重现。PowerShell Create仍按私有参考固定成员顺序比较。
- LiveProvider记录实际PowerShell子进程exit/序号/安全阶段/错误类别/输出字节数与哈希，不公开原stdout/stderr及私网成员；审计写盘失败不应吞没查询结果/阻断回滚，但整体仍非零。
- 原R3代码进行**RED**模拟真实缺陷：1条创建、0条删除、1条残留、child exit31（红灯用例符合预期不代表产品通过）；**GREEN**冻结新增38例均PASS，包括四条分别来源重排、Create/Query顺序变化、连续Query旋转、创建后抛错的精确回滚、请求乱序拒绝、来源替换/遗漏/扩大/重复/包装/数值类型、marker/实例变更不误删、PowerShell删除时重排与负例、审计IO异常可清理、残留31和未知32。
- 原冻结三组测试`48/48`、`37/37`、`5/5`，及新增`38/38`的**顶层实际exit均报告0**；Astra读取了对应结果JSON、退出回执及具名负例。原三组测试**主脚本**保持字节相同，辅助`OfflineAdapterHarness.ps1`、`simulation.py`为适配乱序模拟明确修改；不能说所有测试工具均字节不变。模拟调用的是`LiveProvider`拼接的真实PowerShell Core，在真正NetSecurity IO处替换为隔离函数，未做真实Windows规则写入。
- 非作者独立复核报告`PASS_WITH_OBSERVATIONS`，确认修正了verify实例固定、数字错误类型、创建前身份门、畸形目标名和审计IO失效问题。Astra独立核对主要安全不变量，未发现该限定修复内尚需另开R5的明确阻断。

## 3. 权限及保留观察

**本次只接受“定点脚本离线修复”，不接受整版v10.0.9。** 真实Windows UAC、真正四规则创建/删除、系统挂起/强杀情况下的清理、SFU/DB/APP/音频A/B/C均未由此次修复实测；当前规则双Store均为0、查询exit0为Codex Windows只读回执，不是Astra亲自操作该计算机。原首次异常精确位置及原始内部PowerShell退出码仍`UNKNOWN`，不得回填假原证。

下一次真实操作必须Owner**重新明确**批准唯一新Run、一次UAC、原四规则、最长1200秒受控voice-only窗口，前置确认引擎/DB/SFU归属和保留卷、固定原始7文件SHA、双Store四名0、WLAN/来源、两个安装包及CN/MC资格、独立服务和规则收口监督、Owner现场试听准备。不可自动沿用上轮过期授权、Run ID、STOP或日志目录；任何无法满足的前置停止并报告。AC-09-03只有同call AVD→手机、手机→AVD及同时双向Owner真实听辨才可关闭。保留R1-1/R1-2已关闭结论，不重开整版开发；不擅自`ACCEPT`、合main、K08或未来版本。

## 4. 临时证据清理

依据Owner已批准的`docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md`，独立审阅已完成，允许仅对本临时分支做非强制快进纯清理提交，恢复其创建时的parent Tree，GitHub回读该子目录在最新HEAD不再存在；再由Codex**只按固定新HEAD**删除该临时远端分支，Astra核验API404。**在最终404前必须保留BRANCH_DELETE_PENDING，不可假称完成。** Git历史/缓存中的提交不能保证永久擦除，因此无敏感原证进入公开副本。

## 5. 审阅证据工作树清理实绩

2026-10-17：Astra已执行纯GitHub**non-force fast-forward**临时分支清理：原审阅Commit `3175f3c9427f53843fda79f88c641602c5333c7a` 为唯一parent，新清理Commit `cc639391f906c3e7a9047af3504d5a7a199db7db`，其Tree `50102808ff66225256925751a408a6ae6c4ea843` 精确等于短期分支创建前 `29984bd24da0f0cffc3a977d825cb014903d40b9` 的Tree。GitHub独立回读短期分支最新HEAD与清理Commit一致，`docs/_temporary_review/v1009-return-order-20261017/REPORT.md`在新HEAD返回404；因此73个临时文件已从**最新工作树**清除，但其固定历史Commit不等于被抹除。

后续仅剩**远端临时分支引用删除**，当前`TEMP_REVIEW_TREE_CLEANED / TEMP_BRANCH_DELETE_PENDING`；Codex须在独立核验精确HEAD为`cc639391f906c3e7a9047af3504d5a7a199db7db`后一次性删除`review/temporary-evidence-v1009-return-order-20261017`，Astra再API 404确认。未获得最终404之前不可宣称完整清理。正式main和产品开发分支均未在临时分支清理动作中被更改。

## 6. 临时审阅分支最终删除核验

2026-10-17，Codex在清理后报告：原短期分支 `review/temporary-evidence-v1009-return-order-20261017` 的远端HEAD与 `cc639391f906c3e7a9047af3504d5a7a199db7db` 一致，只执行一次精确删除，实际命令exit0；原本地stdout/exit及Windows资源未由Astra直接读取，这些本地操作声明保持 `CODEX_REPORTED`。

Astra随即独立通过GitHub API查询这一完整分支名，明确得到 **404 Branch not found**。同时远端`main`保持 `843b4d6d395dee648b8cc2031d3e28082545f260`，产品开发分支`codex/v10.0.9-rtc-media`保持 `70612d36652660e8bdd9d12017c1254ada686298`（此次状态记录属于main的后继**纯文档**提交，不改变产品分支）。

最终阶段：`TEMP_REVIEW_BRANCH_REMOVED_VERIFIED`。此前 `TEMP_BRANCH_DELETE_PENDING` 已由此实际回读闭环；但历史Git对象、缓存及外部克隆可能保留原公开材料，不能承诺彻底抹除。

`RETURN_ORDER_CORRECTION_OFFLINE_ACCEPTED_WITH_OBSERVATIONS` 保持有效；任何下一次真实四规则/UAC及最长1200秒音频窗口仍须Owner新的一次性明确授权，按新Bundle `a8d52ef415ef4157052a0fa128564d36195fc235b595ae51f001e1c67b5ab4ee` 重新核验真实原脚本与环境，不得复用上次窗口或Run身份；`AC-09-03 NOT_PROVEN`、`V10.0.9 NOT_ACCEPTED`、不合main产品、不执行K08或后继版本。
