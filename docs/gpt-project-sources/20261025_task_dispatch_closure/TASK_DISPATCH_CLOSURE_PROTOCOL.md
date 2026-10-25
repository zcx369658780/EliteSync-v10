# Task Dispatch Closure Protocol｜项目源快照

Owner于2026-10-25明确批准。权威正文请以GitHub实时版本为准：[docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md](../../workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)。

## A｜授权与冻结

核对Owner授权、原正式任务、当前状态、live main/Root、候选HEAD、禁止事项、预算和停止门禁。授权明确后直接执行发布流程；仅在授权不明确或涉及新高风险/不可逆行为时提问。

## B｜创建正式任务

创建唯一任务文件；取得Blob SHA后按路径读取全文，核对正文与目标、预算、范围和STOP条件。创建调用成功但未读回正文，不算发布完成。失败时准确报告，不猜测SHA/链接，不重复创建。

## C｜状态同步与验证

更新ACTIVE_STATE；重新读取live main、Root、任务正文/Blob和状态入口/Blob，必要时核对产品Tree。每次写入可能推进main，最终状态必须来自最后一次回读。失败需报告部分完成，不静默结束。

## D｜一次性交付

同一条回复包含正式任务链接、Blob SHA、最终main/Root/状态Blob、当前状态、禁止事项/停止门禁和单一可复制启动Prompt代码框。启动Prompt不使用开始/结束包装标记，不嵌套代码框。

## 权限边界

Owner手动派发Codex。发布不等于派发/执行；Codex只执行正式任务单范围。Astra独立复核通过也不自动放行下一Gate。不得自动运行、创建后继任务、合并产品或扩大授权。

## 部分完成状态

- `TASK_NOT_PUBLISHED`：正式任务创建失败。
- `TASK_CREATED_READBACK_PENDING`：任务已创建，正文未核验。
- `TASK_PUBLISHED_STATE_SYNC_INCOMPLETE`：任务已发布，状态同步失败。
- `PUBLISHED_READBACK_UNVERIFIED`：最终HEAD/Blob回读未完成。
- `PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED`：发布闭环完成，等待Owner手动派发。