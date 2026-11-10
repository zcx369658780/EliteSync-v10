# AUTH-171｜Windows Job 暂停态纳入与失败清理静态合同

**状态：docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本合同只约束未来用**当前 Python 可执行文件及内部固定人工父/后代**的候选实验，不是可运行脚本或本机能力 PASS。AUTH-170 的 `UNAVAILABLE/NOT_CHECKED` 不变；总墙钟、进程树清空均 `UNRESOLVED`，AUTH-155 Phase B 与真实恢复仍 `NOT_READY`。本轮本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。

## 微软官方资料核对范围与事实等级

本轮唯一外部核对只访问任务限定的 `learn.microsoft.com` Win32 页面，均返回 HTTP 200。**已从页面正文取得的明确语义只有：**[Process Creation Flags](https://learn.microsoft.com/en-us/windows/win32/procthread/process-creation-flags) 将 `CREATE_SUSPENDED` 列为 `0x00000004`，说明新进程**主线程**创建时暂停，直到调用 `ResumeThread`；[Job Objects](https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects) 说明默认子进程关联 Job，但 `JOB_OBJECT_LIMIT_BREAKAWAY_OK` / `JOB_OBJECT_LIMIT_SILENT_BREAKAWAY_OK` 可改变该默认行为。此二点仅为 API 语义，**不是**本机执行或后代身份的观测。

其余限定官方页均可达，但本轮回执仅保留页面标题/HTTP 状态，未保留可核的返回值、访问权、结构布局或失败条件正文；这些细节列为 `DOC_SEMANTICS_NOT_VERIFIED`，不得凭记忆补定：

| 官方页面 | 本轮已核对的上限 |
| --- | --- |
| [CreateProcessW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw)、[CreateJobObjectW](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-createjobobjectw)、[SetInformationJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-setinformationjobobject) | 页面 HTTP 200；精确原型、权限、返回值及句柄所有权未在本轮文本回执中固定。 |
| [JOBOBJECT_EXTENDED_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_extended_limit_information)、[AssignProcessToJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-assignprocesstojobobject)、[ResumeThread](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-resumethread) | 页面 HTTP 200；`JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE` 的结构字段、赋值/分配/恢复失败语义未独立抽取。 |
| [TerminateProcess](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-terminateprocess)、[TerminateJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-terminatejobobject)、[WaitForSingleObject](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject)、[QueryInformationJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-queryinformationjobobject) | 页面 HTTP 200；终止是否完成、等待结果分类和 Job 成员查询布局/上限未独立抽取。 |
| [Nested Jobs](https://learn.microsoft.com/en-us/windows/win32/procthread/nested-jobs) | 页面 HTTP 200；当前进程如已处于 Job 时的可纳入条件、继承/限制冲突仍待精确核对。 |

因此下表的 Win32 调用顺序是**待实现/待审的设计约束**；官方页面可达或一般 API 名称不能替代当前 Windows 版本、Python ABI、权限或运行证明。未来若需精确 FFI，须在新任务固定微软头文件/官方类型页面的 `STARTUPINFOW`、`PROCESS_INFORMATION`、`JOBOBJECT_EXTENDED_LIMIT_INFORMATION`、Job 信息类、`DWORD`/`HANDLE`/指针宽度、调用约定、常量值、`GetLastError`、所需进程/Job 访问权及句柄继承规则，再做独立静态审查。当前均 `NOT_FIXED`，本文件不提供可调用的 `ctypes` 结构或真实命令。

## 候选状态机：恢复主线程前先纳入 Job

| 状态/候选转换 | 前置、所有权与允许动作 | 失败停点及回执 |
| --- | --- | --- |
| `J0_NO_OBJECT` → `J1_JOB_OWNED`：拟以 `CreateJobObjectW` 建立本监督者独占的 Job 句柄。 | 先固定当前 Python 身份、Job/进程权限及句柄继承策略；不采用可被无关进程持有的命名共享 Job。尚无人工父进程。 | 创建失败或句柄身份/所有权不明则 `START_UNAVAILABLE`，启动尝试 0。 |
| `J1` → `J2_LIMITS_VERIFIED`：拟以 `SetInformationJobObject` 设置 `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`，审定不允许 breakaway，并核对设置后的信息。 | `KILL_ON_JOB_CLOSE` 是**候选清理机制**，不替代主动终止、等待和成员核验。任何 `BREAKAWAY_OK`/`SILENT_BREAKAWAY_OK`、嵌套 Job 冲突或句柄泄漏风险必须先拒绝。 | 返回失败、读回不符或无法证实最后 Job 句柄所有者时关闭空 Job 并停止，未启动进程。 |
| `J2` → `J3_PARENT_SUSPENDED`：拟以固定当前 Python 和内部人工脚本调用 `CreateProcessW`，仅固定 `CREATE_SUSPENDED`，不经 ShellExecute/UAC/服务。 | 创建后的主线程在 `ResumeThread` 前不得执行人工脚本。须取得**进程句柄与主线程句柄**并限定继承；仅 PID 或 `Popen` 返回不够，且同步创建耗时未受硬截止控制。 | 创建失败或结果句柄/暂停状态不明为 `START_ERROR/TREE_UNCERTAIN`。如进程可能已创建但句柄不明，不能声称 0 残留；不得继续或临场换工具。 |
| `J3` → `J4_ASSIGNED_UNRESUMED`：拟调用 `AssignProcessToJobObject`，并在恢复前独立核对该精确父进程确属本 Job。 | **只有**成功分配并确认父身份、Job 身份、breakaway 禁止且所有句柄稳定，才允许下一步。分配可因权限/既有或嵌套 Job 等条件失败；当前条件未核。 | 分配失败、未知或核对不符：**绝不调用 `ResumeThread`**；保持暂停，进入 `F_UNASSIGNED_SUSPENDED`，按下节尝试有界直接终止。 |
| `J4` → `J5_PARENT_RUNNING`：拟对这一个主线程调用 `ResumeThread`，并核对返回分类。 | 恢复动作仅对应内部人工父，`shell=False` 的意图不能替代上述 Win32 句柄与分配证明。 | 返回失败/未知、线程仍暂停或可能重复恢复时立即停，`TREE_UNCERTAIN`；不能让子进程结果倒证分配成功。 |
| `J5` → `J6_TREE_OBSERVED`：固定人工父生成有身份标记的人工子/孙，另设父先退出和后代存活负例。 | 须独立记录每个后代的受限身份/句柄及 Job 成员关系，查询 Job 活跃成员并处理 PID 复用；仅父进程退出或 Job 活跃计数为 0 的单一瞬间不足以证明无逃逸后代。 | 后代未被观测、分配/继承不明或查询失败为 `TREE_UNCERTAIN`，不声称 `TREE_CLEARED`。 |
| `J6` → `J7_TERMINATE_REQUESTED` → `J8_TREE_CONFIRMED`：拟以 `TerminateJobObject`/关闭最后句柄触发清理，分别等待已知进程并查询 Job 成员。 | 仍要在同一截止时刻内核对人工父/子/孙不存活与 Job 活跃数，关闭线程/进程/Job 句柄；不以 API 返回成功替代终止完成。 | 任何等待超时、查询/关闭失败、身份不明、后代存活、句柄可能被其他进程继承为 `TREE_UNCERTAIN`；保留隔离责任，不能报告完成。 |

## 纳入失败、监督者故障与时间边界

`F_UNASSIGNED_SUSPENDED` 的候选安全顺序是：不恢复 → 对**仍暂停的精确直接父进程句柄**请求 `TerminateProcess` → 用 `WaitForSingleObject` 在剩余期限内核对其终止 → 关闭主线程/进程句柄 → 关闭空 Job。若父进程句柄、终止请求或等待结果未知，回执为 `TREE_UNCERTAIN/RESIDUAL_UNKNOWN`；不能将“主线程未恢复”当“进程已不存在”。若父已纳入 Job 而恢复失败，应优先按 Job 范围终止并核对，而不是只等待父。监督者崩溃、Job 句柄误继承、关闭最后句柄不明、清理 API 阻塞及其后的残留均有独立负例；`KILL_ON_JOB_CLOSE` 不能替代独立存活核对。

**总墙钟候选测量**：外部独立观察者在调用入口前记录单调时钟，给所有状态共享一个绝对截止；记录创建 Job、设置/读回、同步 `CreateProcessW`、分配/读回、恢复、后代观察、终止、等待、查询、关闭及最终返回的每段进/出时刻。所有等待只使用剩余额度；任何阶段超过截止即失败且不得续预算。人工负例须至少覆盖纳入失败（确认不恢复）、父先退但后代活着、后代逃逸/未观测、Job 句柄误继承、终止/等待超时、监督者故障。每项须以独立句柄/Job 成员证据和最后实际残留状态判定，而不是只读 API 返回码。

**硬上界仍 `UNRESOLVED`**：微软页面和待拟合的 `WaitForSingleObject` 期限均不能强制同步 `CreateProcessW`、`AssignProcessToJobObject`、清理调用、Python/FFI 调度或监督者本身在总时限内返回；在不可中断调用外层只报 timeout，可能留下稍后创建/分配的进程。没有另审的预就绪外部监督/强制截止与异常后残留治理，就不能为未来启动设一个已证有限总墙钟或将 `TREE_UNCERTAIN` 升格为清空。故 AUTH-170 的启动前 `UNAVAILABLE` 停点目前不变。即便未来纯虚构 Job 路径局部通过，UAC、服务派生、真实命令、AUTH-166 双流/峰值内存、CMS 认证失败消费者 0/0、目标 ACL、隔离引擎及真实恢复仍各有独立门。

## 本轮回执与停点

本地固定来源静态核对 **2/2 轮**：第一轮核对 cwd、Git HEAD/dirty、`CURRENT.md`/`TASK_CURRENT.md`、本任务 `task.md`、本地 workflow 技能及 `REVIEW_GATE.md`；第二轮只读根 `AGENTS.md`、AUTH-166 `plan.md`/`work-review.md`、AUTH-170 `task.md`/`summary.md`/`work-review.md`。微软官方 Learn 限定页面核对 **1/1 轮**；可达性与仅两段正文语义的上限已如上记录，未用非官方片段替代。唯一新增本 `plan.md`。`NOT_RUN`：测试、Python 子进程、Job/Win32 API、AUTH-155、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API；未访问旧 `D:\EliteSync`，未提交、pull 或 push。旧预算不重置；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
