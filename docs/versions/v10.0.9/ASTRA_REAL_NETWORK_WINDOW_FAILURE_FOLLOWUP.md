# EliteSync-v10｜v10.0.9 AC-09-03 首次R3真实网络窗口失败及残留规则清理

2026-10-17。**REAL_NETWORK_WINDOW_FAILED_EXIT31 / RESIDUAL_CLEANUP_REMOVED_VERIFIED_CODEX_REPORTED / FAILURE_CAUSE_NOT_YET_INDEPENDENTLY_REVIEWED / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED**。

## 本次已收到的Codex回执（非Astra直接读取Windows原证）

- 前一轮经Owner明确批准的一次性受控网络窗口实际触发网络失败，原运行退出码`31`，原全部失败证据仍保留。
- 同一Run遗留**1条Block**目标规则。随后执行仅针对该Run残留对象的独立清理：清理子进程exit`0`；据Codex只读回报，Windows防火墙`ActiveStore`及`PersistentStore`的四条原目标规则均为`0`，查询exit`0`。
- DB/SFU保持停止，持久卷保留；清理时没有重开1200秒窗口、没有执行音频测试。未提供任何本Run AC-09-03 的A/B/C人工同一call声音确认。
- `FAILED_WINDOW_REPORT.md`及清理原始回执仍是Codex机器上的Windows绝对本地路径，Astra当前没有这些字节的可读副本。因此残留规则身份、失败链起点、哪条规则残留、原始调用/退出码和自动清理的确切失败原因均**尚未独立审查**；不能从“原运行exit31”直接推断特定PowerShell命令或根因。
- Astra复查GitHub：`main`仍为`f17ef56636a504ccd0b73218916031c8e51c6d2f`，产品开发分支`70612d36652660e8bdd9d12017c1254ada686298`；没有因本轮网络失败回执改变产品源码。

## 独立裁决

- 先前`R3_SCRIPT_SOURCE_REVIEW_PASS_WITH_OBSERVATIONS`是**离线源码/模拟门**，仍有效但不覆盖真实Windows故障。真实运行窗口**FAILED**；人工后续清理成功不能反证最初脚本自动收口成功。
- 本次残留的最终清理可以按Codex提供的回执暂记`RESIDUAL_CLEANUP_REMOVED_VERIFIED_CODEX_REPORTED`，不是Astra直接查询本机防火墙。
- 下一步仅派发一次**只读故障取证/精确归因**：读取原失败报告、真实子进程stdout/stderr/exit、四条规则创建与删除的事件顺序、owner marker/instance、ActiveStore/PersistentStore差异及最终清理回执，在不暴露私有IP、密钥、设备serial的前提下，形成最小可审阅脱敏材料。若确有自动清理缺陷，仅提出与之对应的最小修订建议与额外离线用例，不在该调查任务中修改运行脚本或重试系统网络。
- 原Owner的一次性UAC与20分钟窗口已经使用/结束，不能跨新Run继承。任何再次创建规则/申请UAC/启动DB、SFU或真实媒体，都需要Owner**另行明确授权**并重新做最小实时入场核验。
- 不重做R1-1/R1-2及旧R3全量审查，不合并main、不执行K08或启动下一产品版本；直到AC-09-03证据闭合，v10.0.9仍`NOT_ACCEPTED`。

本文件仅记录收到的明确事实、独立证据限制及下一步门禁，**不是**对本地失败报告内容的全文独立复核，也不是新增网络授权。
