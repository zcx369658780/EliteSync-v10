# EliteSync v10｜可观测目录桥诊断、逐文件校验与条件式 M3 结果 v0.8-R6-R4-R1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — R6R4R1_HOST_CURRENT_VIEW_SELFTEST_FAILED — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。主执行模型由Owner选择为GPT-5.6 Sol、Medium；未修改模型配置，未调用辅助代理。

## 1. 结论

GitHub远端authority、新B4/E路径与SRC/B3精确根绑定均通过。host任务专用RemoteSigned PowerShell首次在解析阶段因Windows PowerShell 5.1不接受泛型静态方法调用语法而失败；按任务使用唯一一次定点纠正，仅将字节比较替换为等价Base64精确比较。

纠正后自测生成了SRC current-view TSV和SRC统计，但在`Test-SourceView`返回对象中的`ordinal=true`被Windows PowerShell 5.1解释为命令，触发`System.Management.Automation.CommandNotFoundException`。定点纠正预算已耗尽，故在B3枚举前停止。最终分类：

`M3 PRECONDITION BLOCKED — R6R4R1_HOST_CURRENT_VIEW_SELFTEST_FAILED`

SRC TSV SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`，这是本轮新current-view TSV对象，不是已接受legacy manifest，也不重定义或替换`6D4EAE...`。

## 2. 远端authority与固定输入

| 项目 | 实际值 | 结果 |
| --- | --- | --- |
| main | `b7ded0a4251395beb0a25073bf47d6b61d8e9081` | PASS |
| FIRST blob | `18485c95262051e43892436fb52413132c5ee626` | PASS并先读取 |
| task commit/blob | `d13312277ec891226c6014ffaeb20d56cff976dd` / `aab315287dcb2624439d1a1439e279c217449614` | PASS |
| task sole parent | `b7ded0a4251395beb0a25073bf47d6b61d8e9081` | PASS |
| compare | ahead=1、behind=0、只新增固定task文件 | PASS |
| R6-R3 result blob | `33613af1985b340c01b984cb6109b19ba6932ab9` | PASS |
| CURRENT_CONTEXT blob | `2410e6c2a35ba28fa0c23373535b5736f70ae839` | PASS |
| `pubspec.yaml` blob | `1b807ccdcced1e3166fd6e5378865ecb5bba4708` | PASS |
| `lib/main.dart` blob | `607b51186540bd0eb1998c1997472a05447d9a3d` | PASS |

Owner确认旧R6-R4 task `93b0ac9ed1c4f3f380db00937204f4c015fbc8fe`永久superseded；本轮未执行它。未读取或写入本地默认index/working tree及受保护staged state。

## 3. host current-view gate与首个终止点

B4=`W/evidence/resume-r4/r6r4r1-observable`和E=`W/evidence/resume-r6-r4-r1`开始均不存在。SRC与B3精确根exists/Container=true且根非reparse；冻结dispatch/copy哈希匹配。

首次自测：stage=`PARSE`，exit=1；失败路径=`W/evidence/resume-r4/r6r4r1-observable/host-current-view-r6r4r1.ps1`；异常为Windows PowerShell 5.1 parser拒绝`[Linq.Enumerable]::SequenceEqual[byte]`。任务允许的一次定点纠正已使用，且只改为Base64字节精确比较。

纠正后执行得到：

| 项目 | 实际值 |
| --- | --- |
| SRC files / dirs / bytes / reparse | `527 / 301 / 3234145 / 0` |
| `src-current.tsv` size | `69676` bytes |
| host SRC current TSV SHA-256 | `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E` |
| self-test | FAIL |
| 首个失败stage | `HOST_CURRENT_VIEW_SRC_SELFTEST` |
| 首个失败path | `W/evidence/resume-r4/r6r4r1-observable/host-current-view-r6r4r1.ps1` |
| exception type | `System.Management.Automation.CommandNotFoundException` |
| exception message | `The term 'true' is not recognized as the name of a cmdlet, function, script file, or operable program.` |
| failing expression | `ordinal=true` |
| correction budget | `1/1 used` |

因此B3 current-view枚举、`b3-current.tsv`、SRC↔B3逐项/字节比较和`expected-module-current.tsv`均NOT_RUN/NOT_CREATED。不得把已生成SRC TSV提升为通过自测的host expected TSV。

## 4. observable、guest与真实运行状态

host gate未通过，因此本轮没有调用`wsb --version`、`wsb list --raw`或`wsb exec`，observable probe count=`0`。全部checkpoint状态：

| checkpoint | 状态 |
| --- | --- |
| `00-started.json` | NOT_RUN |
| `10-root.json` | NOT_RUN |
| `20-sentinels.json` | NOT_RUN |
| `30-enumeration.json` | NOT_RUN |
| `40-current-tsv.json` | NOT_RUN |
| `50-compare.json` | NOT_RUN |
| `90-pass.json` | NOT_RUN |

`90-pass.json`不存在，故主guest、nonce/guest.started、RemoteSigned/Security/禁网、dispatch ordinary/batch/exit37、模块复制与固定cwd、R4工具/cache复用、Git、Java、offline pub、M3均NOT_RUN。AAR=`NOT_CHECKED`、probe=0；M2=deferred/NOT_RUN。

## 5. evidence与生命周期

host将B4完整复制至canonical evidence E。最终B4/E均为7文件、0目录、87919 bytes，按`relative_path<TAB>length<TAB>SHA256`、ordinal、UTF-8无BOM、LF计算的evidence manifest均=`FFAED27D44900EE8F7E39AB25BF748CE398D7F89D5EC4D9C7C79AE898937BA4D`，一致；B4保留。

未修改B3、旧R4 bridge或旧resume/input/object。未调用新share、stop或新建Sandbox，未close/reset/kill Owner会话；本轮未查询其运行可用性，且未对其实施任何控制动作。未联网补包、下载或写宿主SDK/cache、Wrapper、产品源码。

下一关口仅为fresh独立ACCEPT/REJECT。本候选不授权修正脚本、重跑host self-test、启动observable probe/guest、执行pub/M3/M2或更新main；执行者不自我接受。