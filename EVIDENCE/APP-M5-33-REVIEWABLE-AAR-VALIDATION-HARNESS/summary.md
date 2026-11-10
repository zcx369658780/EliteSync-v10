# APP-M5-33｜来源输出门失败终止回执

2026-09-30；SOURCE-ONLY HARNESS NOT_DELIVERED / SOURCE ROUND FAIL / WORK LEVEL 2 REVIEW PENDING。来源轮 A 首次尝试在回显前触发 OUTPUT_GATE；按失败即停，不调整选取后重跑、不补读、不保存 checker/launcher。唯一新增本 summary，不自接受、不派后继。

## 入口与授权

唯一仓库 D:\EliteSync-v10；分支 main；HEAD cf8bfaa4a03b8c9a682105617b185141904413be。执行会话 01a0f1ec-ff46-7311-a52f-780a64e3d4fb；TASK_CURRENT 顶部 M5-33 ISSUED、assignee 与明确派发一致。按 elitesync-local-workflow 执行；旧会话停用、M5-29 DOCS-ONLY ACCEPT 与 M5-30/31/32 REJECT/CLOSED 保持，全部旧预算关闭。

## A 同次首失败

tools.exec_command chunk b5c2c5，exit 1，wall_time_seconds 0.2428252；数值取同次保留的工具结果，不重跑。同次完整可见错误为：

```text
Exception:
Line |
   2 | … ByteCount($payload); if($bytes -gt 32768){throw 'OUTPUT_GATE'}; $payl …
     |                                              ~~~~~~~~~~~~~~~~~~~
     | OUTPUT_GATE
```

五准确来源为 aar_entry_materials.py、test_aar_entry_materials.py、M5-29 plan.md、M5-31 static-original-checker.txt、M5-32 summary.md。该轮仅 PowerShell/.NET 文本与 SHA256：按任务固定顺序，每文件普通非 reparse、≤256 KiB、累计≤512 KiB 后一次 ReadAllBytes；两源固定大小/hash和 plan 固定 hash 的比较在输出门之前。到达 OUTPUT_GATE 表明前序门未抛异常，但本次未回显来源身份回执，不追加读取或以旧回执冒充本轮原始输出。

实现将身份和必要文本先累计入内存，只对≤500字符的源码/原 checker 文本行添加编号，长字面量只加省略标记。累计 UTF8 byte count 最终大于 32768，在任何 payload 回显前抛出 OUTPUT_GATE。输出选取过多属于作者编排错误；没有打印五源正文、fixture 全文、身份表或最终 A_READ_COUNT 标记。准确累计输出字节、五源本轮总大小及未规定预期的两证据 hash 未回显，保持 UNKNOWN；不补证、不修改脚本重新尝试。

A 1/1 已使用并失败关闭。没有 Python 进程、AST parse、compile、import、生产或测试执行，也未执行恢复的 checker 文本。

## B 与交付停点

B 0/1 未开始，在首失败终止门关闭；未读取新脚本文本或调用 PowerShell ParseInput。check_frozen_sources.py 和 Invoke-FrozenAarValidation.ps1 未创建，故没有 script size/hash、PowerShell 解析 PASS、Python 语法 PASS 或 harness 完成声明。Python/AST/算法/测试/launcher/监控试跑/SDK/构建安装启动预算均 0，实际执行均 0。

两原源码未修改；不改 authority、旧 summary 或旧证据，不 commit/pull/push/reset/clean/stash；不访问旧 D:\EliteSync、SDK/cache/config/env/home/metadata、真实数据/备份/密钥/生产 DB/API/SSH；无下载、Gradle/Flutter/JVM/ADB、构建/安装/启动/UAC。只读 Git 成员核对：保存的 183 条基线缺项 0，当前 184 条，唯一新增 status 为本 M5-33 证据目录；这是成员保留证明，不宣称逐字节核验所有既有内容。

候选 harness 未交付；仅本次失败证据停 Work 独立 LEVEL 2 裁决。不得沿用 A 或 B、恢复旧测试预算或在本任务修复重跑。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false 与真实账号/Conversation/恢复/UAC 全部门保持。
