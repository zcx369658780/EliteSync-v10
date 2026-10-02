# AUTH-184 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受当前 CPython/Windows 的纯静态候选 `ctypes` 布局。** 作者交付 `layout_probe.py` SHA-256 `4453E1CEA38F23A7C97D955EF88BABD95F7B0B2A1A5DDF24FC3E12A5889710F9`，`summary.md` SHA-256 `7BA5B5B0DCF11558B62B39FC834706C9AAB0F44EFE039801F36E329AA69D9E54`。Work 独立只读核对文件、哈希、已接受的 AUTH-178/180 结构声明和 Codex 执行记录：字段名及顺序匹配，导入仅为任务允许的标准库，无 DLL/Win32/Job/进程动作或敏感输出。作者本地固定来源 2/2、语法 1/1、探针运行 1/1、最终交付核对 1/1 均耗尽；语法和探针退出码均为 0，Work 未复跑。

单次输出的 `schema` 为 `AUTH-184-SYNTHETIC-JOB-CTYPES-LAYOUT/v1`，`status=STATIC_LAYOUT_ONLY`，`width_conflicts=[]`；当前 CPython 3.11.9/Windows、指针 64 位下，候选 `LARGE_INTEGER`、`IO_COUNTERS`、基础及扩展 Job 限制结构分别为 8、48、64、144 字节，偏移详见已核对的 `summary.md`。类型选择是 Python **候选映射**；`DUMMYSTRUCTNAME` 宏展开、目标 Windows C ABI 对齐/填充、调用约定、设置/读回、Job 成员与清理、硬总墙钟均未由此证明。AUTH-170 保持 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、真实 CMS 认证/隔离恢复及账号回填继续 `NOT_READY`。

本审查未运行测试或探针，未访问真实密文、生产系统、SSH 或 GitHub，未提交、pull 或 push。AUTH-184 预算不重置；后继必须另行限定并审查。
