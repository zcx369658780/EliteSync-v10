# EliteSync v10｜既有 R4 Share 桥接、固定模块续行与条件式 M3 结果 v0.8-R6-R2

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — FIXED_MODULE_CWD_MISSING_AFTER_BRIDGE_EXPAND — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。主执行模型由Owner选择为GPT-5.6 Sol、Medium；未修改模型配置，未调用辅助代理。

## 1. 结论

GitHub远端authority、R6-R1 ZIP/module绑定、R4 existing evidence bridge probe、guest.started、PowerShell 5.1、进程级RemoteSigned、Security系统路径、禁网隔离以及两类dispatch冒烟全部通过。

随后guest调用固定 `Expand-Archive` 展开桥中ZIP时，PowerShell报告 `Microsoft.PowerShell.Archive` 模块无法加载。模块统计尚未开始，固定cwd未建立。按任务停止条件分类：

`M3 PRECONDITION BLOCKED — FIXED_MODULE_CWD_MISSING_AFTER_BRIDGE_EXPAND`

未修改或重试guest脚本，未使用替代解压方法，未检查或恢复R4工具/cache，真实Git/Java/pub/M3均未运行。AAR=`NOT_CHECKED`、probe=`0`，M2保持deferred。

## 2. 远端authority与固定输入

| 项目 | 实际值 | 结果 |
| --- | --- | --- |
| main | `ec16e067b80671a2c9bfeb957a7acc709d9fb78e` | PASS |
| FIRST blob | `18485c95262051e43892436fb52413132c5ee626` | PASS并先读取 |
| task commit | `db5ca28ec19f41b281b8271a212fa2f9b9578a32` | PASS |
| task blob | `680d8d7d77edae918ce809846d5ebc7d866caf4f` | PASS |
| sole parent | `ec16e067b80671a2c9bfeb957a7acc709d9fb78e` | PASS |
| compare | ahead=1、behind=0、只新增固定task文件 | PASS |
| R6-R1 result blob | `b47be1a5c33c7499e14678a0dc842e6d8dc5cf09` | PASS |
| CURRENT_CONTEXT基底blob | `be718e6c3684251f930d0a0f8e7a46ce2983f0e6` | PASS |

R6-R1 ZIP size=`966335`、SHA-256=`342F9D0BCB909CA73660FE9F98D17185F1ABD462C1B8712705DD3916E316B050`。宿主固定模块复核为527文件、301目录、3234145 bytes、reparse=0，manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

冻结dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；copy SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。

## 3. bridge、Sandbox与guest证据

仅在旧R4 host evidence根下新增 `r6r2-bridge`；未修改、覆盖、删除、移动或重命名R4任何既有相对路径。本轮没有调用 `wsb share` 或 `wsb stop`。

fresh `wsb list --raw` exit=0，唯一running Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。同一ID、run-as System的无副作用probe guest ExitCode=0，证明既有 `C:/M3R4/evidence/r6r2-bridge` 可达且guest脚本、ZIP、dispatch/copy哈希匹配。

桥文件执行前哈希：

| 文件 | SHA-256 |
| --- | --- |
| `guest-r6r2.ps1` | `A2A5105F4EB7314D6C9A5049370DC5B79EBBCE03ABB0A7E4C9E17C2330C01635` |
| `probe-r6r2.ps1` | `07D5DC336CDA7F2C5B56EF992131016F820544F8A9DEA89099E1DE7091010BB9` |
| `module-fixed-main.zip` | `342F9D0BCB909CA73660FE9F98D17185F1ABD462C1B8712705DD3916E316B050` |
| `dispatch.ps1` | `2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846` |
| `copy.ps1` | `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC` |

guest nonce=`M3-ISO-V02-008-R6R2-6bb89f2b3c6d4f9e81e85455d5e6c4fe`，Sandbox ID匹配；controller PID=`3400`。PowerShell=`5.1.26100.9168`，Process/effective检查均通过RemoteSigned；Security模块Name=`Microsoft.PowerShell.Security`，Path=`C:/Windows/system32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`；活动网卡=0、默认路由=0，isolation=PASS。

ordinary native smoke exit=0，`override_present=false`，`guest-alpha`和`value with space`实际进入OS。batch pub shape exit=0、M3 shape exit=0、exit37原样返回37，均entry=true。

## 4. 终止点与下游状态

guest在dispatch冒烟后校验ZIP hash通过，执行 `Expand-Archive -LiteralPath ...module-fixed-main.zip -DestinationPath C:/M3R6R2/w` 时停止：

```text
The 'Expand-Archive' command was found in the module 'Microsoft.PowerShell.Archive', but the module could not be loaded.
```

WSB CLI exit=0，guest ExitCode=1。未授权重试或替代展开方法，因此：

| 阶段 | 状态 |
| --- | --- |
| fixed module cwd | NOT_ESTABLISHED |
| guest module统计 | NOT_RUN |
| R4七项工具/cache Test-Path | NOT_RUN |
| R4复用/fallback | NOT_RUN；fallback_count=0 |
| Git `--version` | NOT_RUN |
| Java `-version` | NOT_RUN |
| offline pub | NOT_RUN；dispatch_started=false |
| M3 | NOT_RUN；dispatch_started=false |
| exact AAR | NOT_CHECKED；probe=0 |
| M2 | deferred；NOT_RUN |

## 5. canonical evidence与生命周期

guest结束后host将B完整复制到新的canonical evidence `W/evidence/resume-r6-r2`。执行证据集在B/E均为26文件、1018499 bytes，manifest SHA-256均=`DED7DB3FBCF79F85A95D00B799C2CEE62F7292B2460326230C59D540F62D2665`，一致。B未删除。

`wsb exec`返回后guest控制器已结束；四个smoke native进程均在各自记录中exit并完成。没有真实工具进程启动。未调用新share/stop，Owner Sandbox未close/reset/kill，仍由Owner控制。

本轮未联网、下载、补包，未写原仓库、默认index、working tree、受保护staged state、宿主SDK/cache或产品源码。下一关口仅为fresh独立ACCEPT/REJECT；本候选不授权修复Archive模块、重试guest、续跑pub/M3或执行M2。
