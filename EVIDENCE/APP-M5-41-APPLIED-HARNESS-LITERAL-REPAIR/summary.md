# APP-M5-41-APPLIED-HARNESS-LITERAL-REPAIR

NOT_DELIVERED — PREPARATION_JS_SYNTAX_ERROR；停 Work 独立 LEVEL 2。

日期：2026-09-30。
Codex：01a0f1ec-ff46-7311-a52f-780a64e3d4fb；Work：01a0f272-76dc-7712-b368-1b6f9e86d179。
唯一仓库 D:\EliteSync-v10，main，HEAD cf8bfaa4a03b8c9a682105617b185141904413be。

## 首问题及停止

已正常只读核最新 CURRENT/TASK_CURRENT、本 task 全文、M5-40 work-review、AGENTS/REVIEW_GATE 与本地 workflow 技能。M5-41 为明确 ISSUED / SOURCE-ONLY，当前派发与 assignee 一致。

主代理在 functions.exec 中准备 A 的 PowerShell 文字命令时，把含 PowerShell 反引号换行转义的内容放入 JavaScript 模板字符串，导致 JavaScript 解析阶段错误。这是主代理编排错误。

完整同次错误回执：

```text
Script failed
Wall time 0.0 seconds
Output:
Script error:
SyntaxError: Unexpected identifier 'n'
```

该 functions.exec 在 JavaScript 解析阶段失败，未进入脚本执行。没有调用工具执行 A，没有 ReadAllBytes 来源读取，没有保存或启动两份新脚本。没有修正该命令、重试、补读或继续 B。

本 task 的“首问题或交付后停 Work 独立 LEVEL2”优先；仅 CreateNew 保存本终止 summary，随后停止，不自接受或后继。

## 预算与候选身份

A 0/1 未执行，B 0/1 未执行；均随本次终止关闭，不转给修复/后继，不重置旧预算。
A 同次来源身份回执：不存在。B 同次最终文本回执：不存在。

check_applied_sources.py：NOT_DELIVERED，未创建；最终大小/hash：NOT_CHECKED。
Invoke-AppliedAarValidation.ps1：NOT_DELIVERED，未创建；最终大小/hash：NOT_CHECKED。
仅本 summary 新增。没有冒用 M5-40 Work 核定的旧两脚本 hash 作为本 task 最终身份。

## 本轮未完成的修复

准确 literal_utf8_encode predicate 在 safe_literal/test call_gate 共用、test zip、launcher checker 上限 65536、三个 SOURCE_* 固定标签和 M5-41 checkerPath：均 NOT_DELIVERED / NOT_CHECKED。
原 ORACLE_DECLARATIONS、FROZEN_FUNCTION_TEXT、13 方法名单、源 hash 及监控门未改；没有重新构造 oracle 或执行被审代码。

Python/Python AST/import/compile/算法/fixture/scratch/测试/checker/launcher/monitor/PowerShell Parser.ParseInput：全部 NOT_CHECKED，启动 0。
没有 SOURCE-ONLY 修复接受、静态 PASS、测试 PASS、运行或 OS 隔离/硬截止证明。

## 工作区与保护门

入口已保存到本会话内存的 porcelain normal 回执为 193 条，包含 Work 已新建的 M5-41 折叠目录；task 发布前声明保留的既有成员为 192 条。未执行 Git mutation 或任何无关写入。
首问题后未追加状态成员比对或全文件字节检查，不宣称最终逐条/逐字节完整性已核。

不改 authority、M5-40 旧候选、旧证据、冻结 production/adapter/test，不续旧预算，不 commit/pull/push/reset/clean/stash。没有访问旧 D:\EliteSync、真实数据/备份/密钥/生产 DB/API/SSH、SDK/cache/config/env/home/真实 metadata/properties；无索引搜索/下载/安装启动、Gradle/Flutter/JVM/ADB/构建或 UAC。

M5-40 REJECT/CLOSED NOT_DELIVERED、M5-39 ACCEPT/CLOSED SOURCE-ONLY 及全部旧 budget 关闭保持。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false、真实性/Conversation/恢复/生产/UAC 门保持。

最终停点：本终止摘要交 Work 独立 LEVEL 2。是否另立任务或交接执行会话由 Work 判断；Codex 不自行修复、重试、派后继或恢复执行。
