# AUTH-179 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受 docs-only 的部分 Job 结构依赖类型来源账本。** 唯一作者交付 `plan.md`，SHA-256 `8060FC1FAF8D7C688767F4DA11CEF658B6229BD347120E58656F4A4C820DDB12`；作者本地固定来源 2/2 轮、微软页面限定读取 2/2 轮已耗尽。Work 核对允许路径、文件与哈希，独立只读复核微软 Windows Data Types 页面 HTTP 200，含 `DWORD` 与 `SIZE_T` typedef、`ULONG_PTR`、`LONGLONG` 标识；未重放作者每个页面的完整抽取，接受范围只限候选记录的保守类型事实。

`LARGE_INTEGER` 与 `IO_COUNTERS` 的完整声明未取得；`JOBOBJECTINFOCLASS` 枚举 URL 请求失败，不能把 AUTH-178 的单项值 9 升格为完整枚举/ABI。候选正确保留这些为 `NOT_FIXED`，也未从 `LONGLONG` 名称猜出 `LARGE_INTEGER` 布局。Job 基础/扩展结构的大小、偏移、对齐、Python 映射、调用约定、真实设置/读回和最后句柄所有权仍 `NOT_FIXED/UNRESOLVED`。本接受不授权 FFI 或人工 Job；AUTH-170 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、真实恢复与账号回填 `NOT_READY`。

本次审查未运行测试、编译器、Win32 API、Job/进程或受保护现场动作，未提交、拉取或推送；旧预算不重置。
