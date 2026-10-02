# AUTH-173 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受 docs-only 的部分原始声明账本。** 唯一作者交付 `plan.md`，SHA-256 `BC7AC8DFFCF6F8DB632441A78BE809C5B8A4249D72E9C8D6C5C2AFEDFAC99346`；作者本地固定来源 2/2 轮与微软 Learn 限定读取 2/2 轮已耗尽。Work 核对任务允许路径、文件和哈希，独立阅读候选，并只读复核微软 Learn 的 `CreateProcessW`、`STARTUPINFOW`、`Process Creation Flags` 页面均返回 HTTP 200，含候选所引的输出参数、结构末字段和暂停标志标识。本审查未逐字段重放全文抽取，因此接受限于所记录的官方 C 声明候选与未固定边界，不授予 Python ABI 或现场能力。

`CreateProcessW` 十参数声明、`STARTUPINFOW` 十八字段声明及 `CREATE_SUSPENDED=0x00000004` 被候选分别列为本轮文档声明/事实；`PROCESS_INFORMATION` 完整声明未取得，清楚保留 `NOT_FIXED`。后继不得用 AUTH-172 的局部字段拼出可调用缓冲。类型宽度、结构偏移与对齐、`ctypes` 映射、Job 限制、失败清理、硬总墙钟和进程树清空仍 `NOT_FIXED/UNRESOLVED`。AUTH-170 保持 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、A/B 暂存与真实恢复保持 `NOT_READY`。

本次审查未运行测试、Win32 API、人工进程或受保护现场动作，未提交、拉取或推送。接受不重置旧预算，也不放行人工 Job 试验。
