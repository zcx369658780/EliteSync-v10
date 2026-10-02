# AUTH-177｜纯虚构恢复前失败关闭回执

**作者候选，待 Work 独立 LEVEL 3 审查。** 本任务仅新增本目录 `pre_resume.py`、`test_pre_resume.py` 和本回执；既有 dirty/untracked 未改动。`pre_resume.py` SHA-256 `5685F28D5FE9CF6D43A4F2019C5CF49B425E7B68DD434091CDBE71577FA0B85C`；`test_pre_resume.py` SHA-256 `82270E2F575DA3A7B4ED5BF31B7FA6218B70BB92F26B51BC9E7B0E958E721471`。

候选函数只接收测试提供的内存假适配器和固定 `AUTH177_SYNTHETIC_PARENT` 标记。正向顺序固定为 `create_job → configure_limits → create_parent_suspended → assign_parent → verify_membership → resume_parent`；每步必须返回显式枚举成功，不能以非空值推断成员身份。恢复前失败若有精确假父引用，先在结果顺序中记 `NO_RESUME`，再请求终止该直接父并以固定假等待额度等待；明确终止才报告 `DIRECT_PARENT_TERMINATED_CONFIRMED`，等待超时、终止失败、引用未知或其他不明均报告 `RESIDUAL_UNKNOWN`，从不报告 `TREE_CLEARED`。假创建明确返回未创建时不终止不存在的父；恢复调用自身异常时不声称 `NO_RESUME`。成功分支仅为 `SYNTHETIC_PRE_RESUME_PASSED`。

本地固定来源核对 **2/2 轮**：根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 与 dirty/untracked、本任务单、AUTH-171 `plan.md`/`work-review.md` 及 AUTH-174/175/176 `work-review.md`；`PRODUCT_DECISIONS.md` 相关词限定查找无命中，未从中新增规则。静态语法核对 **1/1**，两份 Python 文件 `ast.parse` 输出 `SYNTAX_OK`、退出码 0。

唯一授权定向运行 **1/1**：`python -B -m unittest test_pre_resume.py`，首跑退出码 **0**，`Ran 10 tests`、`OK`，未复跑。测试覆盖 Job 创建失败、限制配置抛异常、明确未创建父、已创建但引用未知、分配失败并确认直接父终止、分配失败且等待超时、成员身份未知、终止失败、全部前置显式成功且恰好一次假恢复、假恢复抛异常。各前置失败均断言恢复调用计数为 0，并核对 `NO_RESUME`、终止、等待的顺序及最终分类。

**未证边界**：本测试没有加载 DLL、调用 Win32、创建 Job/进程/真实消费者，也没有证明实际父身份、Job 成员关系、Windows ABI/FFI、失败清理、硬总墙钟或进程树清空。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、A/B 暂存、真实 CMS/数据库消费者及恢复仍 `NOT_READY`。未访问外网、GitHub、旧 `D:\EliteSync`、真实备份/密钥/DB、SSH/云/API、Docker/WSL/ACL/注册表，未触发 UAC，未提交、pull 或 push；旧预算不重置。作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
