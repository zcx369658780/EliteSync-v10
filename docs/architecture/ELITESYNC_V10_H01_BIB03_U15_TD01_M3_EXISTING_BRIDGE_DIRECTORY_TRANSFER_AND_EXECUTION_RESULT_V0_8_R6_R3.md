# EliteSync v10｜既有 R4 Share 目录桥接、固定模块续行与条件式 M3 结果 v0.8-R6-R3

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。主执行模型由Owner选择为GPT-5.6 Sol、Medium；未修改模型配置，未调用辅助代理。

## 1. 结论

GitHub远端authority与本地固定输入门全部通过。宿主使用冻结copy/robocopy合同，将已接受固定模块目录精确复制进全新R4 writable evidence桥；目标复核为527文件、301目录、3234145 bytes、reparse=0，manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

fresh `wsb list --raw`仍只返回指定Owner Sandbox。随后同一ID、run-as System执行一次无副作用bridge probe：WSB CLI exit=`0`，返回guest命令`ExitCode=1`。probe按合同不写guest证据，故未取得更细guest内错误；不得重试或改用新share/archive。最终分类：

`M3 PRECONDITION BLOCKED — R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE`

本轮未生成主guest nonce，`guest.started=NOT_ESTABLISHED`；未执行guest隔离、dispatch冒烟、guest模块复制、R4工具/cache复用、Git、Java、offline pub或M3。AAR=`NOT_CHECKED`、probe=`0`，M2仍deferred。

## 2. 远端authority

| 项目 | 实际值 | 结果 |
| --- | --- | --- |
| main | `dcebc45e95bb53235ba2bd89b81fb40b56a6cccb` | PASS |
| FIRST blob | `18485c95262051e43892436fb52413132c5ee626` | PASS并先读取 |
| task ref/commit | `1adfdf1b55907654df1ccd6047d652f3cddb670d` | PASS |
| task blob | `16a448051667a565aecc4435d821ecc41763e5f6` | PASS |
| task sole parent | `dcebc45e95bb53235ba2bd89b81fb40b56a6cccb` | PASS |
| compare | ahead=1、behind=0、只新增固定task文件 | PASS |
| R6-R2 result blob | `6c96210e66f11f0618032503f8873ca9ed9812b4` | PASS |
| CURRENT_CONTEXT blob | `679fc67469c18fb6dc2a63f700910f77731ef2d1` | PASS |

本地没有借用默认index/working tree作为authority，也未修改受保护staged state。

## 3. host目录桥接

开始时`B=W/evidence/resume-r4/r6r3-bridge`与`E=W/evidence/resume-r6-r3`均不存在。只新建B，并使用冻结`copy.ps1`：robocopy exit=`1`、copied files=`527`、bytes=`3234145`、failed/mismatch/extras=`0/0/0`、合同PASS。

目标`B/module/apps/flutter_elitesync_module`复核：exists/Container=true、file_count=`527`、directory_count=`301`、total_bytes=`3234145`、reparse_count=`0`、manifest=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`，全部PASS。

冻结文件在B中的SHA-256：dispatch=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；copy=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。本轮probe脚本=`B94DF718E18EED18513326894A27B75FA424DBD6D73C1DD9716627012F91E4DD`；guest脚本=`8C15D87254920CE21410D4505819AD7A83F1FCA2B372307AEA8120C6362F4C2C`。脚本语法检查无错误，且不包含archive/share/stop/new-Sandbox流程。

## 4. Sandbox与终止点

WSB版本=`0.8.107.0`。`wsb list --raw` exit=`0`，唯一running Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`，采用existing Owner Sandbox路径；本轮新share=`0`、stop=`0`、新Sandbox=`0`。

唯一bridge probe使用同一ID、run-as System，并在任务专用PowerShell进程指定`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。WSB CLI exit=`0`，guest命令`ExitCode=1`。按T§5立即停止，probe retry=`0`。因probe无副作用，未生成guest内诊断文件，不能把具体内部失败原因提升为已证事实。

因此：

| 阶段 | 状态 |
| --- | --- |
| bridge probe | FAIL；`R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE` |
| 主guest nonce / guest.started | NOT_GENERATED / NOT_ESTABLISHED |
| PowerShell 5.1、RemoteSigned、Security、网络隔离 | NOT_RUN |
| ordinary/batch dispatch smoke | NOT_RUN |
| guest module copy / fixed cwd | NOT_RUN / NOT_ESTABLISHED |
| R4工具/cache reuse/fallback | NOT_RUN / fallback_count=0 |
| Git / Java | NOT_RUN |
| offline pub | NOT_RUN；dispatch_started=false |
| M3 | NOT_RUN；dispatch_started=false |
| AAR | NOT_CHECKED；probe=0 |
| M2 | deferred；NOT_RUN |

## 5. evidence与生命周期

任务结束时host将B完整复制至E。最终两侧均为538文件、304目录、3755522 bytes，manifest SHA-256均=`5E624D1278F0157D51B7B5C7C55873674E3F695A220E149A9410B528DCD26EBD`，一致；B保留。旧R4、旧`r6r2-bridge`及全部旧resume/input/object未修改、覆盖、删除、移动或重命名。

没有主guest、真实工具或Flutter/Gradle进程启动。未调用`wsb stop`，未close/reset/kill Owner Sandbox；最后已知唯一会话仍由Owner控制。未联网补包、下载或写原仓库、默认index/working tree、宿主SDK/cache、Wrapper或产品源码。

下一关口仅为fresh独立ACCEPT/REJECT。本候选不授权重试probe、新share、新Sandbox、guest/pub/M3、M2或产品实现；执行者不自我接受、不更新main。