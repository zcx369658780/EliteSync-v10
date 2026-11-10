# AUTH-176｜纯静态 `ctypes` 布局探针回执

**作者候选：`STATIC_LAYOUT_ONLY`，待 Work 独立 LEVEL 3 审查。** 唯一探针 [layout_probe.py](layout_probe.py) SHA-256：`D7FCF61A1321795B6F47DFDEFC604143FB09167B95B88F90DDB8C4B6E7F68349`。脚本只导入 `ctypes`、`json`、`platform`、`struct`、`sys`；未加载 DLL、调用 Win32 API 或启动人工进程。

本地固定来源核对 **2/2 轮**：根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、Git `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 与 dirty/untracked、任务单，以及 AUTH-173/174/175 的 `plan.md`/`work-review.md`。一次静态语法核对使用 `ast.parse`，输出 `SYNTAX_OK`、退出码 0；没有创建字节码。唯一授权运行 `python -B layout_probe.py` **1/1 次**，退出码 **0**，没有重试或测试套件。

## 脱敏 JSON 摘要

```json
{
  "classification": "STATIC_LAYOUT_ONLY",
  "status": "MEASURED",
  "interpreter": {"implementation": "CPython", "version": "3.11.9"},
  "os": "Windows",
  "pointer_size_bytes": 8,
  "candidate_type_sizes_bytes": {
    "BYTE_candidate_c_ubyte": 1,
    "BOOL_candidate_c_int": 4,
    "DWORD_candidate_c_ulong": 4,
    "HANDLE_candidate_c_void_p": 8,
    "POINTER_candidate_c_void_p": 8,
    "WCHAR_candidate_c_wchar": 2,
    "WORD_candidate_c_ushort": 2
  },
  "candidate_structures": {
    "STARTUPINFOW": {
      "size": 104,
      "offsets": {
        "cb": 0, "lpReserved": 8, "lpDesktop": 16, "lpTitle": 24,
        "dwX": 32, "dwY": 36, "dwXSize": 40, "dwYSize": 44,
        "dwXCountChars": 48, "dwYCountChars": 52,
        "dwFillAttribute": 56, "dwFlags": 60,
        "wShowWindow": 64, "cbReserved2": 66, "lpReserved2": 72,
        "hStdInput": 80, "hStdOutput": 88, "hStdError": 96
      }
    },
    "PROCESS_INFORMATION": {
      "size": 24,
      "offsets": {
        "hProcess": 0, "hThread": 8, "dwProcessId": 16, "dwThreadId": 20
      }
    }
  }
}
```

脚本原始固定 schema 另含 `unverified` 清单；上表仅复录脱敏的运行尺寸、字段偏移及分类。当前 `Windows` 且候选 `BYTE`/`DWORD`/`WCHAR`/`WORD` 大小分别为 1/4/2/2 字节，未触发任务单的 `UNAVAILABLE` 分支。这是本机**候选 Python 布局测量**，不是 Windows ABI 一致性判断。

## 来源对应与硬边界

字段顺序来自已获限定 Work 接受的 AUTH-173 `STARTUPINFOW` 十八字段和 AUTH-174 `PROCESS_INFORMATION` 四字段官方 C 声明；`DWORD` 32 位、`WORD` 16 位、`BYTE` 8 位、`WCHAR` 16 位及 `HANDLE`→`PVOID` 来自 AUTH-175 已接受的微软类型账本。`c_ulong`、`c_ushort`、`c_int`、`c_void_p`、`c_wchar`、`c_ubyte` 是本脚本的**候选选择**；AUTH-175 的 Python 官方通用类型表没有直接证明这些 Windows typedef 的当前可调用映射。`LPWSTR`、`LPCWSTR`、`LPBYTE` 和结构指针字段在探针中均只用 `c_void_p` 表示指针宽度，不证明字符编码、可写缓冲、所有权或别名的 FFI 适配。

仍 `NOT_FIXED/UNRESOLVED`：Windows C ABI 对齐与精确 typedef-to-`ctypes` 映射、目标进程位宽和布局、调用约定与 `argtypes`/`restype`、字符串缓冲可写性及生命周期、进程创建与失败清理、Job 行为及进程树清空、硬总墙钟。AUTH-170 仍 `UNAVAILABLE/NOT_CHECKED`；AUTH-155 Phase B、A/B 暂存及真实恢复仍 `NOT_READY`。本次无外网、GitHub、旧 `D:\EliteSync`、本机 SDK/注册表、真实备份/密钥/DB、SSH/云/API、UAC/Docker/WSL/ACL；未提交、pull 或 push。保留全部既有 dirty/untracked，不重置旧任务预算。作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
