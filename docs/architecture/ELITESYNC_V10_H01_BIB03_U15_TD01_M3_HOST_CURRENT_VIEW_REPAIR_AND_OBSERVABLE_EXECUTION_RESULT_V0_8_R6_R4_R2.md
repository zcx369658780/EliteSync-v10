# EliteSync v10｜Host Current-View Helper 修复、可观测目录桥与条件式 M3 结果 v0.8-R6-R4-R2

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — OFFLINE_PUB_POWERSHELL_EXECUTABLE_NOT_FOUND_IN_GUEST_PATH — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。主执行模型由Owner选择为GPT-5.6 Sol、Medium；未修改模型配置，未调用辅助代理。

## 1. 结论

远端authority、fixture helper自测、SRC↔B3 host current-view、唯一observable probe、主guest隔离/dispatch、模块copy/current-view、R4七项复用及真实Git/Java均通过。

唯一一次`flutter pub get --offline`已实际启动，入口进程exit=1，stderr精确报告：

```text
Error: PowerShell executable not found.
       Either pwsh.exe or PowerShell.exe must be in your PATH.
```

因此最窄分类为：

`M3 PRECONDITION BLOCKED — OFFLINE_PUB_POWERSHELL_EXECUTABLE_NOT_FOUND_IN_GUEST_PATH`

这不是offline依赖/cache不足证据。pub不得重试；M3未启动，AAR=`NOT_CHECKED`、probe=0，M2保持deferred。

## 2. authority与helper

| 项目 | 实际值 | 结果 |
| --- | --- | --- |
| main | `45e57fb0f77ac61fa29700d317a3aaaa02f55e87` | PASS |
| FIRST blob | `18485c95262051e43892436fb52413132c5ee626` | PASS并先读取 |
| task commit/blob | `f0272d3985799a3778f5e45cb55eb3c362b92f60` / `6f270bb1e76be79e49ffca497a38e3cb00014700` | PASS |
| sole parent / compare | 指定main；ahead=1、behind=0、只新增task | PASS |
| R6-R4-R1 result / context blob | `06abaa8b4efcd717e35f5b2981bf098be4e8358f` / `701c2cb96d6b219a7330a0bb4b84acb36495a6b0` | PASS |
| helper SHA-256 | `6ECA7C8ADF8AF51CD2CAE08E736595F4BA4C9324F891AF80DE604A1A3DC6311D` | 冻结 |

fixture包含3文件、1子目录、28 bytes bytes。Windows PowerShell 5.1 parser无错误，裸`true/false`代码token=0，无不兼容泛型静态调用；两次输出均各237 bytes，SHA均=`6B0C91B251AF9A740A1A9B2BA19B3924DE7A50BB8FC29B26AC125B5683CC054E`。helper纠正次数=`0/2`。

## 3. host current-view与observable probe

SRC与B3均为527 files、301 dirs、3234145 bytes、reparse=0；两份TSV均69676 bytes，SHA-256均：

`R6R4R2_CURRENT_VIEW_TSV_SHA256=4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`

size/SHA比较PASS，未进入逐行差异定位；`expected-module-current.tsv`字节复制后SHA保持一致。

WSB版本=`0.8.107.0`，fresh list唯一Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。observable probe count=`1`、run-as System、CLI exit=0、guest ExitCode=0：

| checkpoint | 结果 |
| --- | --- |
| `00-started.json` | PASS；PID=5712，Sandbox/helper绑定匹配 |
| `10-root.json` | PASS；B3 guest根exists/Container |
| `20-sentinels.json` | PASS；pubspec.yaml与lib/main.dart length/SHA匹配expected TSV |
| `30-current-view.json` | PASS；527/301/3234145/0，TSV SHA匹配 |
| `40-compare.json` | PASS；expected/actual均69676 bytes且SHA一致 |
| `90-pass.json` | PASS |

observable链无失败stage/path/exception。

## 4. 主guest、工具与真实命令

nonce=`M3-ISO-V02-008-R6R4R2-01699181a40b4b3781bf75a50fe20e69`；guest.started已建立。PowerShell=`5.1.26100.9168`，Process/effective=`RemoteSigned`；Security模块系统Path匹配；活动网卡=0、默认路由=0。

ordinary native smoke exit=0、`override_present=false`；batch pub/M3 shape均entry=true/exit=0；exit37原样传播。

模块从唯一B3 guest根按冻结copy合同复制到`C:/M3R6R4R2/w/apps/flutter_elitesync_module`：robocopy exit=1、527文件、3234145 bytes、failed/mismatch/extras=0/0/0。冻结helper复核527/301/3234145/reparse0、TSV size=69676、SHA匹配。

R4 Flutter、Android、JDK、Git、Pub cache、Gradle caches、wrapper dists七项全部直接复用，fallback_count=0。

Git：received args=`[--version]`，override_present=false，最终Arguments=`"--version"`，received/normalized executable=`C:/M3R4/t/g/cmd/git.exe` / `C:\M3R4\t\g\cmd\git.exe`，stdout=`git version 2.53.0.windows.1`，stderr空，exit=0；进程退出过快，`actual_executable`未捕获，保持null而不推断。

Java：received args=`[-version]`，override_present=false，最终Arguments=`"-version"`，actual executable=`C:\M3R4\t\j\bin\java.exe`，stderr报告Temurin OpenJDK 17.0.18+8，exit=0。

pub：received args=`[pub,get,--offline]`，最终cmd Arguments=`/d /s /v:off /c ""C:\M3R4\t\f\bin\flutter.bat" "pub" "get" "--offline""`；process_started=true、attempt=1、exit=1，stderr为PowerShell executable not found。guest脚本随后因无空格`throw'OFFLINE_PUB_EXIT_NONZERO'`形成次要`throwOFFLINE_PUB_EXIT_NONZERO` CommandNotFoundException，使其内部classification字段未细化；这发生在真实pub exit=1已落盘之后，不改变首个真实失败原因，也不授权修复/重试。

M3=`NOT_RUN`、dispatch_started=false；AAR=`NOT_CHECKED`、probe=0；M2=`NOT_RUN`。

## 5. evidence与Sandbox生命周期

B4完整复制至`W/evidence/resume-r6-r4-r2`。最终B4/E均71文件、2目录、659719 bytes，按current-view格式计算的evidence manifest均=`5E8ECD29522CC4E1B9292136417CA0A929219F8A15B95AD8AD33F2B75CD6CD75`，一致；B4保留，B3和旧证据未修改。

final `wsb list --raw`仍唯一返回`68ece109-c661-420c-9899-02b1e9518036`。本轮share/stop/new-Sandbox均0；未close/reset/kill，Owner Sandbox仍由Owner控制。未联网补包、下载或写原仓库/default index/working tree、受保护staged state、宿主SDK/cache或产品源码。

下一关口仅为fresh独立ACCEPT/REJECT。本候选不授权补PATH、修脚本、重试pub、运行M3/M2或更新main；执行者不自我接受。