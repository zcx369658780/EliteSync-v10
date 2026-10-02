# AUTH-179｜Job 限制结构依赖类型来源账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本轮仅从限定微软页面记录确实抽取的 C 声明、类型表文字及未取得项，不写 Python FFI 或可调用 Job 结构。AUTH-170 仍 `UNAVAILABLE/NOT_CHECKED`；硬总墙钟、真实恢复及账号回填继续 `NOT_READY`。

## 来源与可达分类

微软官方页面限定读取 **2/2 轮**。下列两个结构页及 Windows 类型表均在两轮返回 HTTP 200；本轮未从两个结构页抽取到 `LARGE_INTEGER` 或 `IO_COUNTERS` 的直接定义链接。尝试读取微软 `JOBOBJECTINFOCLASS` 枚举 URL 时得到 `HttpResponseException`，未取得可用页面标题、HTTP 成功回执或枚举代码声明，分类 `UNAVAILABLE/NOT_FIXED`；不以 AUTH-178 的单个信息类表项冒充完整枚举。

| 固定 URL | 精确页面标题与实际证据 |
| --- | --- |
| [JOBOBJECT_BASIC_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_basic_limit_information) | `JOBOBJECT_BASIC_LIMIT_INFORMATION (winnt.h) - Win32 apps \| Microsoft Learn`，HTTP 200；代码块中两项 `LARGE_INTEGER`、`DWORD LimitFlags`/`ActiveProcessLimit`/`PriorityClass`/`SchedulingClass`、两项 `SIZE_T`、一项 `ULONG_PTR` 的顺序和类型。完整九字段声明已由 AUTH-178 接受；本轮重复抽取并核对这些依赖名，`VERIFIED_DOC_DECLARATION`。 |
| [JOBOBJECT_EXTENDED_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_extended_limit_information) | `JOBOBJECT_EXTENDED_LIMIT_INFORMATION (winnt.h) - Win32 apps \| Microsoft Learn`，HTTP 200；代码块中 `BasicLimitInformation`、`IO_COUNTERS IoInfo`、四项 `SIZE_T` 的顺序和类型。完整六字段声明已由 AUTH-178 接受；本轮重复抽取依赖名，`VERIFIED_DOC_DECLARATION`。 |
| [Windows Data Types](https://learn.microsoft.com/en-us/windows/win32/winprog/windows-data-types) | `Windows Data Types (BaseTsd.h) - Win32 apps \| Microsoft Learn`，HTTP 200；实际取得下表 `DWORD`、`SIZE_T`、`ULONG_PTR`、`LONGLONG` 类型行。`VERIFIED_DOC_TYPE` 只限每行明确文字。 |
| [尝试的 JOBOBJECTINFOCLASS 枚举 URL](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ne-winnt-jobobjectinfoclass) | 本轮请求 `HttpResponseException`；没有成功页面标题、枚举声明或成员全集。该尝试不是可用类型来源，`UNAVAILABLE/NOT_FIXED`。 |

## 依赖类型的证据上限

| 类型及出现处 | 实际抽取的最短标识 | 32/64 位及布局边界 |
| --- | --- | --- |
| `DWORD`：基础结构四字段 | 类型表：“A 32-bit unsigned integer”；`typedef unsigned long DWORD;`。`VERIFIED_DOC_TYPE`，文档固定 32 位。 | 仅固定该类型本身的文档宽度；结构中的相对偏移、填充和 Python 映射仍 `NOT_FIXED`。 |
| `SIZE_T`：基础结构两字段、扩展结构四字段 | 类型表：“maximum number of bytes to which a pointer can point”；`typedef ULONG_PTR SIZE_T;`。`VERIFIED_DOC_TYPE`：C typedef 链和指针范围用途。 | 本轮没有取得 `ULONG_PTR` 的 `_WIN64`/非 `_WIN64` 完整条件代码，故不把 `SIZE_T` 在目标上的具体 32/64 位宽或对齐写成已固定；`NOT_FIXED`。 |
| `ULONG_PTR`：基础结构 `Affinity` | 类型表行：“An unsigned LONG_PTR”；页面将其作为指针精度整数描述。`VERIFIED_DOC_TYPE` 限于该文字。 | 该行的条件 `typedef` 代码未在本轮可核文本中完整抽取；两种目标位宽的精确声明、对齐和 `Affinity` 偏移 `NOT_FIXED`。 |
| `LARGE_INTEGER`：基础结构两项时间限制 | 两结构页只给字段类型名；Windows 类型表中未取得 `LARGE_INTEGER` 行，亦未取得直接定义页或完整 union/struct 声明。 | 类型的成员、宽度、对齐及 32/64 条件均 `NOT_FIXED`；不得借类型名或别的 64 位整数拼接。 |
| `IO_COUNTERS`：扩展结构 `IoInfo` | 扩展结构页仅给 `IO_COUNTERS IoInfo;`；本轮未取得完整嵌套声明或直接定义页。 | 成员顺序、大小、对齐及目标条件 `NOT_FIXED`。此缺口阻断扩展结构静态可调用布局。 |
| `JOBOBJECTINFOCLASS`：AUTH-178 设置/查询原型 | 本轮枚举页请求不可用，未取得完整声明；AUTH-178 已接受的设置/查询页面只列 `JobObjectExtendedLimitInformation` 值 9，属于**旧任务单项表证据**。 | 枚举底层类型、成员全集、目标参数 ABI `NOT_FIXED`；不能把单项值 9 等同于枚举声明。 |
| `LONGLONG`：类型表辅助行 | 页面行称“64-bit signed integer”，但本轮没有任何材料把 `LARGE_INTEGER` 的内部成员声明绑定到它。 | 不能用这个独立类型的宽度填补 `LARGE_INTEGER` 缺口。 |

上述类型的 C 文档语义、目标 32/64 条件、Python `ctypes` 映射和当前主机布局是不同层级。本轮**没有**得出 `JOBOBJECT_BASIC_LIMIT_INFORMATION` 或 `JOBOBJECT_EXTENDED_LIMIT_INFORMATION` 的 `sizeof`、字段偏移/对齐、完整嵌套布局、缓冲长度或调用约定。AUTH-178 的 `KILL_ON_JOB_CLOSE` 语义也不因本账本而变成已设置、已读回或可执行。

## 回执与停点

本地固定来源核对 **2/2 轮**：第一轮核对 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、既有 dirty/untracked、根 `AGENTS.md`/`CURRENT.md`/`TASK_CURRENT.md`/`REVIEW_GATE.md` 和本任务 `task.md`；第二轮只读 workflow 技能及 AUTH-175、AUTH-178 的 `plan.md`/`work-review.md`。官方限定读取 **2/2 轮**，只访问上表微软 URL；枚举请求失败后未扩展搜索或重试。唯一新增本 `plan.md`，最后仅作一次任务允许的路径、存在性、SHA-256、格式核对。

`NOT_RUN`：测试、编译器、Python FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API；未访问 GitHub、第三方代码、本机 SDK/注册表、其他项目或旧 `D:\EliteSync`，未提交、pull 或 push。保留所有既有 dirty/untracked，旧预算不重置。`AssignProcessToJobObject` 权限、嵌套/breakaway、最后句柄所有权、成员核对、真实清理与硬总墙钟继续未证；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
