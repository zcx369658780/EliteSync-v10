# EliteSync v10｜八项宿主 Locator 与条件式 M3 执行结果 v0.8-R4

Status: `PROPOSED RESULT — AWAITING INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — FIXED_MODULE_CWD_MISSING — NO M2 AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。本报告记录 Owner 直接批准的固定 v0.8-R4 执行。执行者不自我接受，不更新 main，不执行 M2 或产品实现。

## 1. 固定入口与复用边界

实时 GitHub main 精确为 `fd96ad5b1278b50404abbcc2bacd1c00624063dc`；FIRST 交接 blob 为 `18485c95262051e43892436fb52413132c5ee626`。任务 `bccd0c04b9a37a98efa1f81290bd3ff9aa997196` 的唯一父为该 main，任务 blob 为 `e72500c1130d871d9b1d98e4ebeee0233c33064d`，相对父提交只新增任务单。

本轮继续使用 `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`，新增证据只写 `evidence/resume-r4`；旧 resume-r1/r2/r3 未覆盖。旧 host ordinary 4/4 与 batch 6/6 只读复用且未重跑。`dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`，`copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`；两者按原字节部署，未重写 dispatch、copy、策略或 cmd 引用算法。

未修改模型配置，未调用辅助代理；未访问旧仓库、README、FD02、默认 index 或受保护 staged state。

## 2. 八项精确 locator 与 fresh Sandbox

仅对任务列出的八项精确路径执行 `Test-Path -LiteralPath`、Container、规范化、根属性和 ACL 可读性检查；没有目录枚举、搜索或替代路径猜测。

| # | 精确 host locator | Exists | Container | 根ACL可读 |
|---:|---|---|---|---|
| 1 | `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input` | true | true | true |
| 2 | `D:/flutter` | true | true | true |
| 3 | `C:/Users/zcxve/AppData/Local/Android/Sdk` | true | true | true |
| 4 | `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` | true | true | true |
| 5 | `C:/Program Files/Git` | true | true | true |
| 6 | `C:/Users/zcxve/AppData/Local/Pub/Cache` | true | true | true |
| 7 | `D:/GradleHome/caches` | true | true | true |
| 8 | `D:/GradleHome/wrapper/dists` | true | true | true |

`wsb.exe`版本=`0.8.107.0`。fresh `wsb list --raw` exit=`0`，恰好返回一个 running Sandbox，ID 仍为 `68ece109-c661-420c-9899-02b1e9518036`；没有新建 Sandbox，没有使用进程名/PID代替官方ID。

## 3. R4 preflight 与两类 guest 冒烟

R4 task share：

| host path | Sandbox path | write语义 | CLI exit |
|---|---|---|---:|
| `W/evidence/resume-r4` | `C:/M3R4/evidence` | allow-write | 0 |
| `W/evidence/resume-r4/bootstrap` | `C:/M3R4/bootstrap` | 未加allow-write | 0 |

bootstrap host源嵌套于可写evidence根，保留别名限制；preflight脚本执行前后SHA-256均为`8D6FE930B1C45369319E3F373ACBF9BBDB362B44BB7BC76DF73185D0A605064D`。

同一Sandbox ID以run-as=`System`执行任务专用Windows PowerShell；CLI exit=`0`。nonce=`M3-ISO-V02-008-R4-6a683733041a4308b212dd90ebb0f336`与`guest.started`、Sandbox ID匹配。结果：PowerShell=`5.1.26100.9168`，Process/effective均`RemoteSigned`，Security模块Name及系统清单精确Path通过，活动网络适配器=0，默认路由=0，隔离PASS。

同一dispatch字节的guest冒烟：

- ordinary native：exit=0，收到`guest-alpha`与`value with space`，`override_present=false`，最终Arguments=`"guest-alpha" "value with space"`，参数实际进入OS；
- batch pub shape：`pub get --offline`，entry=true，exit=0；
- batch M3 shape：`build aar --no-debug --no-profile --no-pub`，entry=true，exit=0；
- exit37：entry=true，exit=37，原样传播。

## 4. 八项只读 share 与 guest copy

八项正式share均使用Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`且不带`--allow-write`；有效记录序列8/8均exit=0：

| # | host locator | guest seed | exit |
|---:|---|---|---:|
| 1 | `W/input` | `C:/M3R4/s/in` | 0 |
| 2 | `D:/flutter` | `C:/M3R4/s/f` | 0 |
| 3 | Android SDK | `C:/M3R4/s/a` | 0 |
| 4 | JDK | `C:/M3R4/s/j` | 0 |
| 5 | Git | `C:/M3R4/s/g` | 0 |
| 6 | Pub Cache | `C:/M3R4/s/p` | 0 |
| 7 | Gradle caches | `C:/M3R4/s/h` | 0 |
| 8 | wrapper dists | `C:/M3R4/s/d` | 0 |

首次第1项CLI调用返回后，自有collector在构造记录时把PowerShell布尔写成`false`而非`$false`，导致该次exit未持久化，2–8尚未调用。仅修正证据字段布尔字面量后，从第1项重新执行相同只读share；有效序列8项均取得exit=0。未修改host输入或复制算法。

八项guest内部copy按既有robocopy合同均`pass=true`：

| copy | exit | copied | bytes | failed/mismatch/extras |
|---|---:|---:|---:|---|
| module-input | 0 | 0 | 0 | 0/0/0 |
| Flutter | 1 | 17932 | 3230107924 | 0/0/0 |
| Android | 1 | 103648 | 9759961961 | 0/0/0 |
| JDK | 1 | 492 | 317293526 | 0/0/0 |
| Git | 1 | 9311 | 419706698 | 0/0/0 |
| Pub Cache | 1 | 82432 | 1668056282 | 0/0/0 |
| Gradle caches | 1 | 57859 | 8416661749 | 0/0/0 |
| wrapper dists | 1 | 67592 | 1976278523 | 0/0/0 |

第1项固定seed `C:/M3R4/s/in` 的 `source_objects=0`，复制后 `C:/M3R4/w` 仍无对象。八项copy完成后，任务固定cwd：

`C:/M3R4/w/apps/flutter_elitesync_module`

不存在。任务明确要求此时按实际失败停止且不得回宿主搜索，因此最终分类：

`M3 PRECONDITION BLOCKED — FIXED_MODULE_CWD_MISSING`

这证明固定input locator当前可访问但其guest seed没有任务预期内容；不证明模块在其他位置不存在。

## 5. 下游状态与生命周期

| 阶段 | 实际状态 |
|---|---|
| 八项locator | PASS 8/8 |
| fresh Sandbox ID | PASS |
| R4隔离 | PASS |
| guest两类冒烟 | PASS |
| 八项只读share | PASS 8/8；第1项另有一次collector前置调用 |
| 八项copy合同 | PASS 8/8；module-input复制0对象 |
| Git `--version` | NOT_RUN；固定cwd检查先失败 |
| Java `-version` | NOT_RUN |
| `flutter pub get --offline` | NOT_RUN；dispatch_started=false |
| M3 | NOT_RUN；dispatch_started=false |
| exact AAR | NOT_CHECKED；probe_count=0 |
| M2 | deferred；NOT_RUN |

最终guest task ExitCode=`1`；Job在收尾前后都只含控制器PID=`11068`，无已知task-owned子进程残留。没有修改CurrentUser/LocalMachine、组策略、信任、来源标记或网络；没有提权、Bypass/Unrestricted、下载、原仓库写入或宿主SDK/cache写入。

本轮没有调用`wsb stop`，没有close/reset/kill Owner Sandbox。最后已知会话仍由Owner控制；R3/R4 shares因CLI无unshare能力可以保留。新增证据仅位于`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4`。

最小后续缺口是由新的固定任务处理第1项`W/input`与预期`apps/flutter_elitesync_module`内容合同之间的不一致；本报告不授权搜索替代路径、重新物化输入、重试真实pub/M3或执行M2。
