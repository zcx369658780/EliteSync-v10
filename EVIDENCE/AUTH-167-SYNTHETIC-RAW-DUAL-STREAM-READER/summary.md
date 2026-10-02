# AUTH-167｜纯虚构双流原始读取候选回执

**作者候选，停 Work 独立 LEVEL 3 审查；现场硬字节/内存保证 `UNRESOLVED`。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；原有 dirty/untracked 工作区保留。唯一新增为本目录 `raw_reader.py`、`test_raw_reader.py`、`summary.md`，未改 AUTH-163 或其他源码。`raw_reader.py` SHA-256 `D24FBA92166766BDA602F524BA16665192D4CDA0AE9EF00306012169CC5BCA53`；`test_raw_reader.py` SHA-256 `CA7DCCC651DC2D6E5A938445D2C5573B04F5B6FE7C7AFBE328B7A5B0DC40B799`。

候选只接受固定场景名与 0～256 的每流限额，内部创建两条本机匿名管道并写入固定虚构 `X/Y` 字节；没有外部子进程、命令或文件路径输入。两条独立线程以同步起点调用 `os.read(fd, min(剩余额度+1, 8))`。每流回执记录逐次请求、返回长度、累计返回量、最大**单次返回块**长度、EOF/错误/超限；第 `L+1` 字节只作为失败见证，任何场景均不返回正文。双流均须结束且线程退出，正常完成还须双流 EOF；异常、超限或线程未清理均为失败态。当前 `peak_retained` 字段只量到最大单次返回块，**不是**对 Python 同时存活的旧/新 `bytes`、运行时内部临时副本或进程总内存的实测峰值；不得据此声称用户态峰值硬限。内核管道与虚构生产者缓冲也不在该计数内。

测试前用 `python -B`、禁写字节码的 `ast.parse` 对两份源码做一次静态语法核对，退出 0。唯一一次定向首跑 `python -B test_raw_reader.py` 退出 0：**8 tests，0 failures，0 reruns**，约 0.003 秒；覆盖 `L=0` 空流和单见证字节、恰好 `L` 后 EOF、单流 `L+1`、双流并发超限、对端关闭、人工 `OSError` 及未知场景拒绝。测试只验证本次虚构管道的请求/返回计数及局部 fail-closed 分类，不量底层 Python 分配峰值或内核缓冲。检查时本目录 `__pycache__` 不存在；没有额外测试文件。

**仍 `UNRESOLVED`：** `os.read` 的 Python/运行时内部复制与真实峰值保留、匿名管道内核缓冲及生产者内存、异常启动/关闭及线程未清理的完整资源处置、总墙钟、Windows 进程树、CMS 认证失败消费者 0 次/0 字节、明文防落盘、隔离目标/引擎限额。通过的虚构用例不能把此候选升级为 AUTH-155 现场监督器；Phase B 与真实恢复继续 `NOT_READY_TO_RUN`。本轮未运行 AUTH-155、CMS/解密/恢复、真实备份/密钥/DB、ACL/注册表/Docker/WSL/VM、UAC、SSH/云/API；未访问旧 `D:\EliteSync`，未提交、pull 或 push。旧预算不重置。
