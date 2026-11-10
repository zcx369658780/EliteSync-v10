# AUTH-172 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受 docs-only 的有限 Win32 来源账本。** 唯一作者交付 `plan.md`，SHA-256 `600D1FA5EB6625E0912A820046C8A922D9B2CCC2B45D6286359910C2BDCFAE4A`；作者声明本地固定来源 2/2 轮、微软 Learn 限定正文 2/2 轮已耗尽，未运行测试或 API。Work 核对本地文件、任务允许路径和哈希，独立阅读账本与 AUTH-170/171 审查，并只读复核微软 Learn 的 `ResumeThread`、`TerminateProcess`、`CreateJobObjectW` 三页均返回 HTTP 200；前两页可见先前暂停计数及终止后等待语义。其余页面的作者实际抽取过程没有独立重放，因此接受范围只限账本所列的保守事实和明确未固定项，不作为完整官方 ABI 审定。

候选正确保留 `STARTUPINFOW`、`PROCESS_INFORMATION` 与 Job 限制结构完整布局、常量、权限、指针宽度、调用约定、已有 Job 状态、失败清理和同步调用硬墙钟为 `NOT_FIXED/UNRESOLVED`。它没有把官方页面可达、Python FFI 适配或本机进程树清空互相推导。接受不允许执行 Win32 API、人工进程、AUTH-155 Phase B、CMS 解密、隔离恢复或数据库写入；AUTH-170 仍为 `UNAVAILABLE/NOT_CHECKED`，真实恢复仍 `NOT_READY`。

本次审查未运行测试或受保护现场动作，未提交、拉取或推送。后继若要尝试人工 Job，须先单独固定并审查完整 ABI、失败清理和硬时间/残留治理；旧作者预算不重置。
