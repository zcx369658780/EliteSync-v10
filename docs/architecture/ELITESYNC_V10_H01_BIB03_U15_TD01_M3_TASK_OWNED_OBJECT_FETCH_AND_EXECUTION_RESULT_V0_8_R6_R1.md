# EliteSync v10｜远端权威门修正、任务自有 Git Object 拉取与条件式 M3 结果 v0.8-R6-R1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — R6R1 EVIDENCE SHARE FAILED — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。主执行模型由 Owner 选择为 GPT-5.6 Sol、Medium；未修改模型配置，未调用辅助代理。

## 1. 结论

本轮 GitHub 远端 authority、旧 R6 证据绑定、唯一 task-owned shallow fetch、修复后 main 对象验证及固定模块物化全部通过。物化得到非空 `apps/flutter_elitesync_module`，但对唯一 Owner Sandbox 建立第一项 R6-R1 evidence share 时，官方 WSB CLI 返回 `Value does not fall within the expected range.`，CLI exit=`-2147024809`。

按既有 share 失败即停合同，本轮未重试 share，未继续 bootstrap/module share，未启动 guest PowerShell，未检查 R4 guest 工具路径，未运行 Git、Java、offline pub 或 M3。最终分类：

`M3 PRECONDITION BLOCKED — R6R1 EVIDENCE SHARE FAILED`

该结果不否定已取得的 fixed-main/module Git 对象或宿主物化内容，也不证明 Owner Sandbox 不可用；只证明本轮首次 R6-R1 evidence share 未建立。AAR=`NOT_CHECKED`、probe=`0`，M2仍为deferred。

## 2. GitHub 远端 authority 与旧 R6 绑定

远端 authority 仅通过 GitHub 数据核验；未使用本机 task ref/object作为门：

| 项目 | 实际值 | 结果 |
| --- | --- | --- |
| main | `ac14a7ccac09fa6117936f133b50593bd5023c1d` | PASS |
| FIRST blob | `18485c95262051e43892436fb52413132c5ee626` | PASS并先读取 |
| task ref/commit | `370089838888af2f477736f961a25adc112137b4` | PASS |
| task blob | `9a79dfd3e0cfc28935e246d5790cb6a9cdc79edf` | PASS |
| task sole parent | `ac14a7ccac09fa6117936f133b50593bd5023c1d` | PASS |
| compare | ahead=1、behind=0、仅新增固定任务文件 | PASS |
| R4 result blob | `cf05d81944aac7f14e49f99207a34d45834df171` | PASS |
| CURRENT_CONTEXT blob | `54169e894e8acec881344a9b2cf86c06c5523956` | PASS |

匿名 GitHub REST 首次 main 查询遭公共 IP rate limit，未取得 authority 数据；随后使用本机已登录 GitHub CLI访问同一官方 API完成上述只读门，未读取或输出凭据值。

旧 R6 `evidence/resume-r6/r6-authority-gate.txt` SHA-256=`5F3C63947DFCA25C950C3F67B64B6AD5C64A82BDA7A60AAA9FE136948B524876`，匹配。旧 `object-r6.git`、旧 resume及全部旧input/evidence未删除、未覆盖，且未被当作当前 authority。

## 3. 唯一 fetch 与固定模块物化

新路径开始时 `object-r6-r1.git`、`input-r6-r1`、`evidence/resume-r6-r1` 均不存在。随后仅执行一次：

```text
git --git-dir=W/object-r6-r1.git -c gc.auto=0 fetch --depth=1 --no-tags --no-write-fetch-head --no-auto-maintenance https://github.com/zcx369658780/EliteSync-v10.git refs/heads/main:refs/r6r1/fixed-main
```

fetch exit=`0`；开始UTC=`2026-09-09T07:46:49.2869585Z`，结束UTC=`2026-09-09T07:46:53.2212666Z`；第二次fetch=`0`。`refs/r6r1/fixed-main^{commit}` 精确为 `ac14a7ccac09fa6117936f133b50593bd5023c1d`，类型=`commit`。

固定模块对象：

| 项目 | 实际值 |
| --- | --- |
| module tree SHA | `e369db9c603838182d29ae501a77f1afe56b6086` |
| object type | `tree` |
| archive exit | `0` |
| ZIP size | `966335` bytes |
| ZIP SHA-256 | `342F9D0BCB909CA73660FE9F98D17185F1ABD462C1B8712705DD3916E316B050` |
| materialized file count | `527` |
| directory count | `301` |
| total bytes | `3234145` |
| reparse count | `0` |
| manifest SHA-256 | `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB` |

精确物化根 `W/input-r6-r1/apps/flutter_elitesync_module` exists=true、Container=true、non-reparse=true、非空。未从原仓库working tree复制，未写 `D:/EliteSync-v10/.git`、默认index或staged state。

## 4. Sandbox 门与终止点

`wsb list --raw` exit=`0`，恰好返回一个running Sandbox：`68ece109-c661-420c-9899-02b1e9518036`。本轮使用existing Owner Sandbox路径，未新建Sandbox。

随后生成nonce=`M3-ISO-V02-008-R6R1-7f31286444ea4440b3c5905fb3d36f6c`，并尝试第一项share：

| Sandbox ID | host path | sandbox path | write语义 | CLI结果 |
| --- | --- | --- | --- | --- |
| `68ece109-c661-420c-9899-02b1e9518036` | `W/evidence/resume-r6-r1` | `C:/M3R6R1/evidence` | `--allow-write` | exit=`-2147024809`；`Value does not fall within the expected range.` |

该share未建立成功。按照失败即停合同：

- evidence share重试次数=`0`；
- bootstrap share=`NOT_RUN`；
- module只读share=`NOT_RUN`；
- guest exec=`NOT_RUN`；
- `guest.started=NOT_ESTABLISHED`；
- nonce仅由host生成，未建立guest绑定；
- 未调用第二次`wsb list`。

冻结 `dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`，冻结 `copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`，均按原字节放入新bootstrap，但因share失败未在guest加载。新preflight脚本SHA-256=`E2B11A4A4B2731F9ACB485C5BEB301201758214947F339CF2A0176666AFE0520`，未执行。

## 5. 下游精确状态

| 阶段 | 状态 |
| --- | --- |
| guest PowerShell 5.1 / Process/effective RemoteSigned | NOT_RUN |
| Security module系统Path | NOT_RUN |
| 活动网卡/默认路由 | NOT_RUN；isolation未建立 |
| ordinary native smoke | NOT_RUN |
| batch pub/M3 shape、exit37 | NOT_RUN |
| R4七项guest工具/cache精确Test-Path | NOT_RUN |
| R4复用/fallback | NOT_RUN / fallback_count=0 |
| module guest copy | NOT_RUN |
| `C:/M3R6R1/w/apps/flutter_elitesync_module` | NOT_ESTABLISHED |
| Git `--version` | NOT_RUN |
| Java `-version` | NOT_RUN |
| `flutter pub get --offline` | NOT_RUN；dispatch_started=false |
| M3 | NOT_RUN；dispatch_started=false |
| exact AAR | NOT_CHECKED；probe=0 |
| M2 | deferred；NOT_RUN |

没有task-owned guest/工具进程启动，因此无task-owned guest子进程残留。没有联网补包、下载、产品源码/Wrapper/SDK/cache写入或持久策略修改。

## 6. 生命周期、证据与下一关口

本轮未调用 `wsb stop`，未close/reset/kill Owner Sandbox。最后已知唯一会话仍由Owner控制；R3/R4既有share保持。本轮失败的R6-R1 evidence share不声明已保留映射。

新增证据仅位于 `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r6-r1`。核心摘要为 `r6r1-result-summary.txt`；固定ZIP与bootstrap均保留。旧R6/R5及全部旧证据未覆盖。

下一关口只能由fresh独立审查对本候选作ACCEPT/REJECT。本报告不授权重试share、另起Sandbox、继续guest/pub/M3、执行M2或修改产品实现。执行者不自我接受、不更新main。
