# AUTH-184｜纯静态 `ctypes` 候选布局结果

**结果：`STATIC_LAYOUT_ONLY`。** 当前 Windows / CPython 3.11.9 解释器为 64 位；六个候选基础类型未出现固定宽度冲突。以下数字只描述这一次 Python `ctypes` 静态表示，不是目标 Windows C ABI、Job 可调用性或运行行为的证明。

## 交付和预算回执

- 唯一脚本：`layout_probe.py`；SHA-256：`4453E1CEA38F23A7C97D955EF88BABD95F7B0B2A1A5DDF24FC3E12A5889710F9`。
- 固定本地来源核对：2/2 轮（在本交付前完成）。
- 静态语法核对：1/1 次，退出码 `0`，结果 `SYNTAX_OK`。
- `python -B layout_probe.py`：1/1 次，退出码 `0`；单行 JSON schema `AUTH-184-SYNTHETIC-JOB-CTYPES-LAYOUT/v1`，状态 `STATIC_LAYOUT_ONLY`，`width_conflicts=[]`。
- 未运行其它测试、编译器、DLL/Win32 调用、Job 或人工进程；未接触真实数据。

## 脱敏数值摘要

| 候选基础类型 | Python 映射 | `sizeof` 字节 |
| --- | --- | ---: |
| `DWORD` | `ctypes.c_uint32` | 4 |
| `LONG` | `ctypes.c_int32` | 4 |
| `LONGLONG` | `ctypes.c_int64` | 8 |
| `ULONGLONG` | `ctypes.c_uint64` | 8 |
| `SIZE_T` | `ctypes.c_size_t` | 8 |
| `ULONG_PTR` | `ctypes.c_size_t` | 8 |

| 聚合类型 | `sizeof` 字节 | 直接字段偏移（字节，按声明顺序） |
| --- | ---: | --- |
| `LARGE_INTEGER` | 8 | `DUMMYSTRUCTNAME=0`, `u=0`, `QuadPart=0`；两个候选 struct 成员内均为 `LowPart=0`, `HighPart=4` |
| `IO_COUNTERS` | 48 | `ReadOperationCount=0`, `WriteOperationCount=8`, `OtherOperationCount=16`, `ReadTransferCount=24`, `WriteTransferCount=32`, `OtherTransferCount=40` |
| `JOBOBJECT_BASIC_LIMIT_INFORMATION` | 64 | `PerProcessUserTimeLimit=0`, `PerJobUserTimeLimit=8`, `LimitFlags=16`, `MinimumWorkingSetSize=24`, `MaximumWorkingSetSize=32`, `ActiveProcessLimit=40`, `Affinity=48`, `PriorityClass=56`, `SchedulingClass=60` |
| `JOBOBJECT_EXTENDED_LIMIT_INFORMATION` | 144 | `BasicLimitInformation=0`, `IoInfo=64`, `ProcessMemoryLimit=112`, `JobMemoryLimit=120`, `PeakProcessMemoryUsed=128`, `PeakJobMemoryUsed=136` |

## 声明对应与边界

字段名称、嵌套关系及顺序对应已接受的 AUTH-178/180 `plan.md` 所录微软 Job 限制结构声明；`LARGE_INTEGER` 双 struct 成员与 union 亦按其中声明建立候选表示。AUTH-175/179 的来源结论仅支撑部分类型声明，AUTH-176 的静态探针不支撑可调用 ABI。这里的 `DUMMYSTRUCTNAME` 是 Python 候选成员名；宏实际展开及别名为 `NOT_FIXED`。Python typedef 映射、目标 C ABI 的对齐/填充亦为 `NOT_FIXED`，即使本次没有固定宽度冲突，也不能提升为已证事实。

Windows 调用约定、DLL 互操作、Job 设置/读回、成员清空、硬总墙钟、进程树清空与 AUTH-155 恢复均为 `NOT_CHECKED`。AUTH-170 保持 `UNAVAILABLE/NOT_CHECKED`。本候选停在 Work 独立 LEVEL 3 `ACCEPT/REJECT`；作者不自接受、不提交或派发后继。
