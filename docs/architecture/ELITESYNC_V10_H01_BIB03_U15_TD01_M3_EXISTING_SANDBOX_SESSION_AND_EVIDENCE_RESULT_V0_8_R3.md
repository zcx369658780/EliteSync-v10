# EliteSync v10｜现有 Windows Sandbox 会话与证据结果 v0.8-R3

Status: `PROPOSED RESULT — AWAITING INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — EIGHT_INPUT_HOST_LOCATORS_NOT_ESTABLISHED — NO M2 AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。本报告记录 Owner 直接批准的固定 v0.8-R3 执行。执行者不自我接受，不更新 main，不执行 M2 或产品实现。

## 1. 固定入口与复用边界

实时 GitHub main 精确为 `c051d6bf4d725672af4292b000c2829c067ea2b1`；FIRST 交接 blob 为 `18485c95262051e43892436fb52413132c5ee626`。任务 `b41c3609284f773b921b5f2fa2e854dcae8acedd` 的唯一父为该 main，任务 blob 为 `84b0e7c7f4e1f1bde01be2ca1a14f5f43567f3e9`，相对父提交只新增任务单。

本轮继续使用 `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`，新增证据只写 `evidence/resume-r3`。旧 host ordinary native 4/4 与 batch 6/6 只读复用且未重跑。冻结绑定：

- `dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；
- `copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`；
- `guest.ps1` SHA-256=`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`。

未修改模型配置，未调用辅助代理；未访问旧仓库、README、FD02、默认 index 或受保护 staged state。

## 2. 官方 WSB CLI 能力门与现有会话

`Get-Command wsb.exe -ErrorAction SilentlyContinue` 成功：

| 字段 | 实际值 |
| --- | --- |
| resolved path | `C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe` |
| `wsb --version` | `0.8.107.0` |
| `wsb --help` | exit 0；公开 start/list/exec/share/stop/connect/ip |
| `wsb list --help` | exit 0；支持 `--raw` |
| `wsb share --help` | exit 0；支持 ID、host/sandbox path 与 `--allow-write` |
| `wsb exec --help` | exit 0；支持 ID、command、working directory 与 `-r ExistingLogin/System` |

唯一一次主查询 `wsb list --raw` exit=`0`，原始结果为：

```json
{
  "WindowsSandboxEnvironments": [
    {
      "Id": "68ece109-c661-420c-9899-02b1e9518036"
    }
  ]
}
```

`wsb list` 的公开定义是列出当前正在运行的 Windows Sandbox 环境，故解析为 `EXISTING_SESSION_SINGLE`，Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。没有使用进程名或 PID 作为控制句柄，没有新启动 Sandbox，也没有进行 list 状态复核。

## 3. 两项 share、exec 与 guest 隔离

仅先建立两项任务 share：

| host path | Sandbox path | write 语义 | CLI exit |
| --- | --- | --- | ---: |
| `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r3` | `C:/M3R3/evidence` | `--allow-write` | 0 |
| `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r3/bootstrap` | `C:/M3R3/bootstrap` | 未加 `--allow-write` | 0 |

第二项直接 share 为只读；其 host 源位于第一项可写 evidence 根之下，因此保留这一别名限制。实际执行前绑定、执行后复核的 guest preflight 脚本 SHA-256 均为 `C4D19FAF2E4B61F416A4BA1A0E4DB6711FD7606861BF8F8A34A7EE63E5058496`，本轮字节未变。

host 先绑定 nonce=`M3-ISO-V02-008-R3-5d4523ab8929495fa1619b999a1d86e4` 与上述 Sandbox ID。随后对同一 ID 执行：

```text
wsb exec --id 68ece109-c661-420c-9899-02b1e9518036 --run-as System --working-directory C:\M3R3 --command "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File C:\M3R3\bootstrap\guest-preflight-r3.ps1 -Nonce M3-ISO-V02-008-R3-5d4523ab8929495fa1619b999a1d86e4 -SandboxId 68ece109-c661-420c-9899-02b1e9518036" --raw
```

run-as=`System`，WSB CLI exit=`0`，raw stdout 记录 guest ExitCode=`0`。主要证据由 guest 写入共享 evidence，而非依赖 stdout。

`guest.started` 已建立并与 nonce、Sandbox ID 一致；guest PID=`4952`。preflight 结果：

| 检查 | 实际值 |
| --- | --- |
| Windows PowerShell | `5.1.26100.9168` |
| Process policy | `RemoteSigned` |
| effective policy | `RemoteSigned` |
| Security module Name | `Microsoft.PowerShell.Security` |
| Security module Path | `C:/Windows/system32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1` |
| `C:/M3R3` 初始条目 | 仅 `bootstrap`、`evidence` |
| 活动网络适配器 | `0` |
| 默认路由 | `0` |
| isolation | PASS |

没有修改 CurrentUser/LocalMachine 策略、组策略、信任、来源标记或网络设置；没有提权、Bypass/Unrestricted、下载或外部访问。

## 4. 终止阻塞与下游状态

guest 隔离门通过后，执行者复核了任务允许的完整 GitHub 固定来源，以及已接受 R2 明确命名的旧 `result.json`、`script-preflight.json`、`host.log`、`host-dispatch-selftest-1.json`。这些来源只给出八项 guest 目标路径，没有给出八项 host 绝对路径，也没有给出包含该映射的固定本地文件 locator。

在禁止目录枚举、文件搜索、路径猜测和重写复制／策略合同的边界下，不能从 `C:/M3/s/...` 反推宿主来源。因此在共享任何真实 SDK/cache/module/tool 前停止：

`M3 PRECONDITION BLOCKED — EIGHT_INPUT_HOST_LOCATORS_NOT_ESTABLISHED`

这不否定已建立的 WSB ID、guest.started 或隔离证据，也不证明八项输入不存在；只证明固定授权来源不足以定位它们。

| 阶段 | 实际状态 |
| --- | --- |
| host ordinary native | PASS 4/4；旧证据复用，NOT_RERUN |
| host batch | PASS 6/6；旧证据复用，NOT_RERUN |
| guest preflight / isolation | PASS |
| guest ordinary native 冒烟 | NOT_RUN |
| guest batch pub/M3 shape 与 exit37 冒烟 | NOT_RUN |
| 八项输入 share/copy | NOT_RUN；count=`0` |
| Git `--version` | NOT_RUN；exit=null |
| Java `-version` | NOT_RUN；exit=null |
| `flutter pub get --offline` | NOT_RUN；exit=null |
| M3 | NOT_RUN；exit=null |
| exact AAR | NOT_CHECKED；probe_count=`0` |
| M2 | deferred；NOT_RUN |

## 5. Sandbox 生命周期与证据限制

本轮未调用 `wsb stop`，未关闭 Sandbox 窗口，未 reset、销毁或终止 Sandbox 会话进程。Owner 现有 Sandbox 仍由 Owner 控制。公开 CLI help 未提供 unshare 命令，因此两项 task share 在任务结束时仍存在；未通过 stop 清理。

本轮没有写原仓库、宿主 SDK/cache、产品源码、Wrapper 或用户配置。除 task-owned guest PowerShell 进程的 `-ExecutionPolicy RemoteSigned` 外，没有策略变更。新增本地证据仅位于 `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r3`。

最小后续缺口是由 Owner 或新的固定任务提供八项 host 绝对路径，或提供一个具名、可哈希验证且获准读取的映射文件 locator；不得为补 locator 搜索、枚举或猜测路径。本候选不授权自行续跑，不自我接受，不更新 main，不执行 M2。
