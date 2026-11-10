# AUTH-176 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受本机纯静态候选布局测量。** 唯一代码交付 `layout_probe.py` SHA-256 `D7FCF61A1321795B6F47DFDEFC604143FB09167B95B88F90DDB8C4B6E7F68349`，回执 `summary.md` SHA-256 `730D9E7C26ACBB88C79542CA7C8B1128E8E07C6EB9543B1C62BA012170A09B37`。作者本地来源 2/2 轮、语法核对 1/1、`python -B layout_probe.py` 静态运行 1/1 次已耗尽，报告退出 0；Work 未复跑。Work 独立阅读脚本：导入仅为准许的标准库，结构字段顺序与 AUTH-173/174 的已接受 C 声明一致；只使用 `ctypes.sizeof` 和字段 `.offset` 输出固定 JSON，没有 DLL 加载、Win32 调用、子进程或敏感路径输出。文件路径、哈希与回执一致。

接受的本机事实仅是当前 CPython 3.11.9/Windows 候选结构：指针 8 字节，`STARTUPINFOW` 104 字节、`PROCESS_INFORMATION` 24 字节及回执所列字段偏移，分类 `STATIC_LAYOUT_ONLY`。`c_ulong`/`c_void_p` 等为候选映射，未由本次测量证明与目标 Windows C ABI、调用约定或可调用 `argtypes`/`restype` 一致。字符串可写缓冲、句柄/失败清理、Job 限制、硬总墙钟与进程树清空仍 `NOT_FIXED/UNRESOLVED`；AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、A/B 暂存及真实恢复继续 `NOT_READY`。本接受不授权人工进程或真实恢复。

本次审查未复跑脚本、测试或任何受保护现场动作，未提交、拉取或推送；旧预算不重置。
