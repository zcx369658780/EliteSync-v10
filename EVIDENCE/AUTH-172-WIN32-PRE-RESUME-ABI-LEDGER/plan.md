# AUTH-172｜Win32 暂停创建、纳入 Job 与失败清理 ABI 来源账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本账本仅记录本轮从微软 Learn 正文实际抽取的 `VERIFIED_DOC_FACT`，与当前 Python/Windows 适配及本机运行证据分层。未抽取、官方页面未说明或仅从 API 名称可猜的细节均 `NOT_FIXED`。AUTH-170 的 Job 能力仍 `UNAVAILABLE/NOT_CHECKED`；总墙钟、后代生存与清理仍 `UNRESOLVED`，AUTH-155 Phase B 和真实恢复仍 `NOT_READY`。本轮 `D:\EliteSync-v10`、本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。

## 资料等级与限定读取

官方读取 2/2 轮只访问任务列出的 `learn.microsoft.com` API/结构页，返回均为 HTTP 200。下表链接文字为 API/结构**标识**；页面 `<title>` 在本轮有限回执中未单独保留，精确标题字段统一 `NOT_FIXED`，不能把标识冒充标题已核。每条正文事实只限表内短语义；没有复核的参数/权限/布局不因页面可达或 AUTH-171 的顺序合同而变成事实。上一任务曾验证 `CREATE_SUSPENDED=0x00000004` 且主线程先暂停，但该数值**不是本轮重新抽取的正文事实**；本账本只把它作为 AUTH-171 已接受的历史来源，不计为本轮 `VERIFIED_DOC_FACT`。

| 官方 URL（HTTP 200；精确页面标题 `NOT_FIXED`） | 本轮实际抽取的 `VERIFIED_DOC_FACT` | 原型/参数、返回/失败、权限与 ABI 未固定项 |
| --- | --- | --- |
| [CreateProcessW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw) | 参数列表含 `LPSTARTUPINFOW lpStartupInfo` 和输出 `LPPROCESS_INFORMATION lpProcessInformation`；后者接收新进程识别信息。成功返回非零，失败返回零并可取扩展错误。 | 完整函数原型、所有输入/输出参数、失败时是否仍有对象、当前 Python 调用约定/指针宽度与可强制的同步调用时限 `NOT_FIXED`。 |
| [STARTUPINFOW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-startupinfow) | 可见成员声明含 `DWORD dwFlags`、`WORD cbReserved2`、`HANDLE hStdInput`；正文列有 `cb` 字段。 | **完整字段顺序、`cb` 类型/赋值、对齐/填充、标准句柄启用条件**没有完整抽取，`NOT_FIXED`。不能据三个成员写 FFI 结构。 |
| [PROCESS_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-process_information) | 可见成员含 `HANDLE hThread`、`DWORD dwProcessId`、`DWORD dwThreadId`，正文亦列 `hProcess`；CreateProcessW 页说明该结构接收新进程信息，并要求关闭其中的句柄。 | 本轮未保留**完整结构声明与字段顺序**，`HANDLE` 实际位宽、Python `ctypes` 对齐/调用约定、失败时句柄有效性 `NOT_FIXED`。 |
| [CreateJobObjectW](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-createjobobjectw) | `lpName=NULL` 时创建无名 Job；成功返回 Job 句柄，具有 `JOB_OBJECT_ALL_ACCESS`；失败返回 `NULL` 并可取扩展错误。若对象已存在，可返回已有对象句柄，`GetLastError` 为 `ERROR_ALREADY_EXISTS`。 | `lpJobAttributes` 的精确原型、实际安全描述符/所有者、该权限在本进程是否可用、句柄继承/最后句柄关闭效果 `NOT_FIXED`。未来候选须拒绝意外取得已有 Job，不能把成功返回当独占证明。 |
| [SetInformationJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-setinformationjobobject) | 成功返回非零，失败返回零并可取扩展错误。 | 精确 `JobObjectExtendedLimitInformation` 信息类值、参数/缓冲区大小、所需 Job 访问权及配置读回语义 `NOT_FIXED`。 |
| [JOBOBJECT_EXTENDED_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_extended_limit_information) | 结构声明可见 `JOBOBJECT_BASIC_LIMIT_INFORMATION BasicLimitInformation`；正文提到其 `LimitFlags` 成员。 | 其他字段及对齐、`JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE` 的精确常量/适用字段和 breakaway 标志组合**未从本轮正文抽取**，均 `NOT_FIXED`。不能写可调用布局。 |
| [AssignProcessToJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-assignprocesstojobobject) | 成功返回非零，失败返回零并可取扩展错误。若进程已在 Job 中，指定 Job 须满足文档所列空 Job 或嵌套层级及 UI 限制条件。 | 完整参数与**确切进程/Job 访问权**、当前进程的既有 Job 状态、失败后父进程是否仍暂停及是否已部分纳入 `NOT_FIXED`。不能把一次返回码当成员身份核对。 |
| [ResumeThread](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-resumethread) | 成功返回线程**先前暂停计数**；失败返回 `(DWORD)-1` 并可取扩展错误。正文说明暂停计数非零时减一，降至零才恢复执行。 | 当前主线程句柄的所需访问权、初始计数的本机证明、恢复后的调度时刻及可撤销性 `NOT_FIXED`。返回非失败不单独证明已开始运行。 |
| [TerminateProcess](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-terminateprocess) | 正文说明该调用请求终止并**立即返回**；若要确认进程已终止，应对进程句柄调用 `WaitForSingleObject`。 | `PROCESS_TERMINATE` 是否为此调用的确切权限、返回/失败分类及系统调用硬耗时，本轮未抽取，`NOT_FIXED`；不能把“已请求”写作“已清理”。 |
| [WaitForSingleObject](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject) | `dwMilliseconds=0` 时不进入等待，`INFINITE` 时等待至对象被触发；页面列出 `WAIT_OBJECT_0`、`WAIT_TIMEOUT`、`WAIT_FAILED`，且说明新 Windows 中睡眠时间不计入该超时时间。 | 三种返回码的完整判义、句柄类型/所需权利、跨系统睡眠语义、有限等待之外的 API/调用者硬截止 `NOT_FIXED`。后继不得用 `INFINITE`。 |
| [CloseHandle](https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle) | 失败返回零并可取扩展错误；关闭线程句柄不会终止关联线程，关闭进程句柄不会终止关联进程。 | 成功返回细节、Job 最后句柄所有权及 `KILL_ON_JOB_CLOSE` 动态效果未在本页回执中抽取，`NOT_FIXED`。不可把关闭父句柄当作父已终止。 |

## 对后继 FFI 的最小静态约束

本账本支持的**候选顺序**仍是：固定人工 Python 父 → 无名 Job 身份确认 → 设置且核对所需限制 → `CreateProcessW` 输出父进程/主线程句柄并保持主线程暂停 → `AssignProcessToJobObject` 成功且另证成员身份 → 才考虑 `ResumeThread`。任一前置失败或未知，**不恢复主线程**。若纳入失败，候选只能对精确的仍暂停直接父进程请求 `TerminateProcess`，随后用有限 `WaitForSingleObject` 判终止，最后区分关闭进程/线程句柄与实际进程终止；等待超时、返回未知、句柄无效或关闭失败均 `TREE_UNCERTAIN/RESIDUAL_UNKNOWN`，不报告清空。此为待审控制流，不是本机调用结果。

在允许任何人工进程之前，后继需另从官方正文固定并独立审查：完整 API 原型、`STARTUPINFOW`/`PROCESS_INFORMATION`/Job 扩展限制结构的逐字段顺序与 ABI 对齐，`DWORD`/`HANDLE` 的目标进程位宽、调用约定与 `ctypes` 映射，`JobObjectExtendedLimitInformation` 及 `KILL_ON_JOB_CLOSE`/breakaway 的精确值，`AssignProcessToJobObject` 和直接终止/等待所需访问权、已有或嵌套 Job 条件、错误分类与所有句柄的最终所有权。**官方语义、Python/Windows 适配、本机执行证据三层不得互推。** 上表任一 `NOT_FIXED` 都不能用文档标题或旧候选填空。

`TerminateJobObject`、Job 成员枚举/人工后代身份、监督者故障后的 Job 最后句柄、UAC/服务派生均不在本 ABI 账本的已证范围。有限 `WaitForSingleObject` 只约束该等待调用，不能强制同步 `CreateProcessW`、`AssignProcessToJobObject`、`TerminateProcess` 或 Python/FFI 调度的**总墙钟**。没有另审的强制期限和残留治理，AUTH-170 的启动前停点不撤销；A/B、CMS 认证失败消费者 0/0、双流峰值内存、隔离目标及真实 DB 各有独立门。

## 本轮回执

本地固定来源核对 **2/2 轮**：第一轮核对 cwd、Git HEAD/dirty、`CURRENT.md`/`TASK_CURRENT.md`、本任务 `task.md`、workflow 技能及 `REVIEW_GATE.md`；第二轮只读根 `AGENTS.md`、AUTH-170 `work-review.md`、AUTH-171 `plan.md`/`work-review.md`。微软 Learn 限定页面正文读取 **2/2 轮**；只记录上述实际抽取语义，未从第三方资料或旧记忆追补。唯一新增本 `plan.md`。`NOT_RUN`：测试、Python 子进程、Job/Win32 API、AUTH-155、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API；未访问旧 `D:\EliteSync`，未提交、pull 或 push。旧预算不重置；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
