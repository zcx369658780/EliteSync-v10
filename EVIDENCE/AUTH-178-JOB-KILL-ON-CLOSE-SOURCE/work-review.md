# AUTH-178 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受 docs-only 的 Job 清理限制官方来源账本。** 唯一作者交付 `plan.md`，SHA-256 `13260308F85D47C3A32D730EC7C1BEB011CB42F2EEAF8EAD804F939D369EB646`；作者本地固定来源 2/2 轮、微软 Learn 限定读取 2/2 轮均已耗尽，未运行测试或 API。Work 核对允许路径、文件和哈希，并独立只读复核微软 Learn 的两份 Job 限制结构、设置及查询接口页面均返回 HTTP 200；可见 `LimitFlags`、`0x00002000`、`BasicLimitInformation`、`PeakJobMemoryUsed`、扩展限制信息类以及 `JOB_OBJECT_SET_ATTRIBUTES`/`JOB_OBJECT_QUERY` 标识。候选的完整原型和结构文本作为有限官方声明接受，不由此推断本机 ABI。

`KILL_ON_JOB_CLOSE` 的文档语义依赖限制实际设置且**最后一个** Job 句柄关闭；本任务没有证明当前主机设置成功、读回一致、句柄独占、关联成员身份或清理完成。`LARGE_INTEGER`、`IO_COUNTERS`、`SIZE_T`、`ULONG_PTR` 等目标 ABI，结构大小/对齐、Python FFI、嵌套 Job/breakaway、分配权限、有限清理等待及硬总墙钟仍 `NOT_FIXED/UNRESOLVED`。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、A/B 暂存、真实 CMS/DB 消费者及恢复仍 `NOT_READY`；不能据此运行人工 Job 试验。

本次审查未运行测试、Win32 API、Job/人工进程或受保护现场动作，未提交、拉取或推送；旧预算不重置。
