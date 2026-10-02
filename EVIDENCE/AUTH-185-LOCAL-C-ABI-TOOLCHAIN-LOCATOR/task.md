# AUTH-185｜本机 C ABI 静态对照工具链只读定位

**2026-09-27 Work 派发；LEVEL 3，read-only locator only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-184 只接受 Python 候选布局。此任务只判断本机是否有可用于**后续另行授权**的 Windows C 结构静态对照的编译器及 SDK 头文件；本轮不编译、不执行、不安装或下载。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty、AUTH-184 `summary.md`/`work-review.md`。唯一允许新增/修改本目录 `summary.md`。执行一轮固定的本机只读定位：用 `Get-Command` 精确核对 `cl.exe`、`clang-cl.exe`、`clang.exe`、`gcc.exe` 是否在 PATH；用 `Test-Path -LiteralPath` 仅核对 `C:\Program Files (x86)\Windows Kits\10\Include`、`C:\Program Files\Microsoft Visual Studio`、`C:\Program Files (x86)\Microsoft Visual Studio`、`C:\Program Files\LLVM\bin\clang-cl.exe` 四个固定路径是否存在。只记录工具名称、可用/不可用及上述固定目录的布尔值；不输出完整安装路径、环境变量或用户目录，不遍历目录/注册表，不搜索其它位置。

`summary.md` 记录唯一定位轮的脱敏结果、命令退出码、能否继续构造**后继候选** C 对照任务；若工具或头文件来源不足，结论为 `UNAVAILABLE/NOT_FIXED`，不自行安装或替代。此定位不证明 C ABI、编译器目标位宽、SDK 版本、头文件解析、运行兼容、Job 清理、硬总墙钟或恢复能力。

## 预算与停点

最多 1 轮固定本地来源核对、**1/1 轮**上述固定位置定位，最后 1 次交付文件路径/哈希/格式核对。不得编译、执行测试/探针、加载 DLL 或调用 Win32，不得创建 Job/人工进程、启动安装器、访问网络/GitHub/SSH/云/API、旧 `D:\EliteSync`、真实密文/密钥/DB、ACL/Docker/WSL/UAC，不得提交、pull 或 push。保留既有 dirty/untracked；旧预算不重置。作者不自接受、不派发后继，交付后停 Work 独立 LEVEL 3 审查。
