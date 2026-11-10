# AUTH-171 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受 docs-only 的固定人工父/后代暂停态纳入 Job 顺序与失败分类合同。** 唯一交付 `plan.md` SHA-256 `26996BF29FF9632650C90F1F1119CA46E2833621E286C1086C9C095D24EC7FE0`；作者本地 2/2 轮与微软 Learn 1/1 轮预算已耗尽。Work 独立阅读确认：创建 Job/设置限制、暂停创建人工父、恢复前纳入及核对、分配失败不恢复而直接终止/等待、恢复后核对后代及清理，均写为**待实现候选**；未知、失败和清理不明保留 `TREE_UNCERTAIN/RESIDUAL_UNKNOWN`。`CreateProcessW` 等同步调用和清理阶段无已证硬墙钟，上层超时不能冒充进程终止。

Work 另行只读核对微软官方 [Process Creation Flags](https://learn.microsoft.com/en-us/windows/win32/procthread/process-creation-flags) 与 [Job Objects](https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects) 页面均可达，包含 `CREATE_SUSPENDED`/`ResumeThread` 与两种 breakaway 标志；本审查没有验证其余 API 的精确 ABI、访问权、返回分类或当前主机行为。候选也如实将这些保留 `DOC_SEMANTICS_NOT_VERIFIED/NOT_FIXED`。本接受不批准运行 Win32 API、人工进程或 AUTH-155。AUTH-170 能力继续 `NOT_CHECKED`，A/B、AUTH-155 Phase B 与真实恢复继续 `NOT_READY`。未运行测试或受保护现场动作，未提交、拉取或推送。
