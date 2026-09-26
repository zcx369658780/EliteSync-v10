# AUTH-123 Phase B 单次本机只读执行回执

2026-09-26，本地 `main` HEAD `ae1fd832e289068f08b611cd72accd08df4b70cd`。启动前核对 `TASK_CURRENT.md` 为 `ISSUED — PHASE B ONE LOCAL READ RELEASED; 0/1 BEFORE START`，`work-review.md` 有 Work LEVEL 2 单次临运行放行。七份固定启动程序、接收核心、解释器及依赖均为普通非重解析文件，SHA-256 与放行值匹配；唯一目标当时为 2,744 bytes、`Archive`、普通非重解析文件、无 `LinkType`。只查有限元数据，未在启动前读取正文。PowerShell 7 核对通过。

仅一次以固定 PowerShell 7 `-NoProfile -File`、零参数启动 `launch_candidate.ps1`。固定脱敏回执：

```text
receiver_status=ACCEPTED_CANDIDATE
reason=NONE
stage=INPUT_CR
category=FORMAT_INVALID
checked_entries=0
prior_target_candidate=NO
port=UNKNOWN
host_key_trust=UNKNOWN
exit_code=0
outer_exit=0
```

AUTH-123 Phase B 启动/本机真实读取预算 **1/1 已耗尽**；未重试、换路径、修补或再次启动。未显示或保存子进程原始 stdout/stderr、目标正文、主机、公钥、指纹或异常。`INPUT_CR / FORMAT_INVALID` 仅为固定接收协议给出的本机格式诊断类别，不证明文件具体内容、独立服务器 host-key、有效 SSH 端口或现时服务器身份。固定入口运行时的文件身份竞争余量、`Process.Start()` 阻塞上限和进程终止边界仍未由本次回执消除。没有 UAC、密码、SSH、阿里云、DB 或备份动作。本回执交 Work LEVEL 2 独立审查；不自行 ACCEPT 或放行后继。
