# EliteSync v10｜Host Current-View Helper 修复、可观测目录桥与条件式 M3 v0.8-R6-R4-R2

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — HOST HELPER REPAIR FIRST — NO NEW WSB SHARE — CONDITIONAL CONTINUATION`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `45e57fb0f77ac61fa29700d317a3aaaa02f55e87`。该 main 已接受 R6-R4-R1 候选精确 tree：远端 authority、SRC/B3 精确根与冻结 dispatch/copy 绑定通过；R6-R4-R1 成功生成 SRC current-view TSV（527 files / 301 dirs / 3234145 bytes / reparse=0，TSV size=69676，SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`），但 host helper 在唯一一次纠正后仍因裸 `ordinal=true` 触发 Windows PowerShell 5.1 `CommandNotFoundException`，因此 B3 比较与 WSB/guest 未启动。

该 TSV hash 是新的 current-view 诊断对象，不替代历史 legacy manifest `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

本任务唯一目标：**重新实现一个最小、PowerShell 5.1 兼容、host/guest 共用的 current-view helper；先在新的 task-owned synthetic fixture 上通过解析和运行门，再各对 SRC 与 B3 运行一次并比较其 TSV；若当前字节视图一致，则执行一次可观测 guest probe。probe PASS 后直接继续 guest 模块 copy、R4 工具/cache 复用、真实 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R4-R2 任务；允许仅在 `W/evidence/resume-r4` 下新增 `r6r4r2-observable`，并新建 canonical evidence `W/evidence/resume-r6-r4-r2`。允许在新目录内开发/修正一个 host/guest 共用 current-view helper，并用 task-owned synthetic fixture 做最多两次定点代码纠正；纠正必须在读取真实 SRC/B3 current-view 前完成。helper PASS 后允许只读枚举/哈希 SRC 与既有 B3 模块目录各一次，生成新的 path+length+SHA256 TSV并比较；不得修改 B3。允许一次 observable guest probe；probe PASS 后允许主 guest、模块 copy、R4 工具/cache 复用、真实 Git/Java、一次 offline pub及条件式一次M3。不得新 `wsb share`、不得新建/stop/close/reset/kill Sandbox、不得联网补包、不得写原仓库/default index/working tree/受保护 staged state/宿主 SDK/cache/产品源码。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 R6-R4-R2。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始仅从 GitHub 远端核验：
1. main=A=`45e57fb0f77ac61fa29700d317a3aaaa02f55e87`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺 task ref/object 不构成 blocker。
4. task commit 唯一父=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A中R6-R4-R1 result blob=`06abaa8b4efcd717e35f5b2981bf098be4e8358f`。
6. A中CURRENT_CONTEXT blob=`701c2cb96d6b219a7330a0bb4b84acb36495a6b0`。
7. sentinel：`apps/flutter_elitesync_module/pubspec.yaml` blob=`1b807ccdcced1e3166fd6e5378865ecb5bba4708`；`apps/flutter_elitesync_module/lib/main.dart` blob=`607b51186540bd0eb1998c1997472a05447d9a3d`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不仓库枚举/搜索、不访问旧仓库/default index/受保护 staged state。

## 3. 固定本地输入与新路径

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读输入：
- `SRC=W/input-r6-r1/apps/flutter_elitesync_module`；accepted 527 files / 301 dirs / 3234145 bytes / reparse=0。
- `B3=W/evidence/resume-r4/r6r3-bridge/module/apps/flutter_elitesync_module`；R6-R3 host copy曾精确匹配 SRC legacy manifest，本轮只读。
- dispatch SHA=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- copy SHA=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。
- 旧R6-R4-R1 evidence目录 `W/evidence/resume-r4/r6r4r1-observable` 与 `W/evidence/resume-r6-r4-r1` 只读，不复用、不覆盖。

新 observable bridge：`B4=W/evidence/resume-r4/r6r4r2-observable`。新 canonical evidence：`E=W/evidence/resume-r6-r4-r2`。B4/E开始必须均不存在；任一存在 STOP `R6R4R2_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除/清理/复用。

创建B4后只允许写B4：helper、fixture、probe、guest、dispatch/copy副本、expected/current TSV、checkpoint/evidence。不得修改B3或旧bridge/evidence。

## 4. current-view helper 合同与 synthetic selftest

实现一份**同一字节**的 `current-view-r6r4r2.ps1`，之后 host 与 guest 都必须使用它。目标仅输出某个指定 root 的 current-view TSV和统计，不返回含 `true/false` 的自由形态对象，不使用泛型静态方法语法。

固定 TSV 规范：每个文件一行 `relative_path<TAB>length<TAB>SHA256`；relative path统一`/`；确定性排序；UTF-8无BOM、LF换行。另记录 file_count、directory_count、total_bytes、reparse_count、TSV size、TSV SHA-256。

兼容硬门：
- Windows PowerShell 5.1 parser 必须无错误；
- 脚本中的布尔字面量只能写 `$true` / `$false`；不得出现作为代码token的裸 `true`/`false`；
- 不使用 `[Linq.Enumerable]::SequenceEqual[byte]` 或其他 PowerShell 5.1 已知不兼容泛型静态调用语法；
- TSV相等判断只用 **文件size + SHA-256**；若不同再逐行定位首个差异，不需要泛型字节比较。

先在 `B4/fixture` 创建3个小型task-owned文件（含子目录与文件名空格），执行：parser gate → helper运行 → 统计/TSV格式检查 → 同一fixture第二输出与第一输出size+SHA一致。这里不访问SRC/B3。

仅在该 synthetic selftest 阶段允许最多 **2次定点代码纠正**；每次记录 before/after helper SHA、错误与最小diff。selftest仍失败 => STOP `R6R4R2_HOST_HELPER_SELFTEST_FAILED`。selftest PASS 后冻结 helper SHA，之后不得改 helper。

## 5. SRC↔B3 host current-view gate

helper冻结后：
1. 对SRC运行一次，生成 `B4/src-current.tsv` 与统计。
2. 对B3运行一次，生成 `B4/b3-current.tsv` 与统计。
3. 两者都必须为 527 files / 301 dirs / 3234145 bytes / reparse=0。
4. 两份TSV size必须相同，SHA-256必须相同。将相同SHA记为 `R6R4R2_CURRENT_VIEW_TSV_SHA256`。
5. 若不同，只允许逐行比较这两份task-owned TSV，记录首个 relative path/expected/actual 差异，STOP `R6R4R2_HOST_BRIDGE_CURRENT_VIEW_MISMATCH`；不得修改B3。
6. PASS后将 `src-current.tsv` 字节复制为 `B4/expected-module-current.tsv`，并确认SHA仍为上述值。

R6-R4-R1曾生成的 `4F869B12...` 仅作为历史中间值记录；本任务必须独立生成并报告当前SHA，不预设必须等于它。

## 6. 现有 Sandbox 与唯一 observable probe

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止 `wsb share`、`wsb stop`、新Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

将冻结helper、expected TSV、probe脚本、guest脚本、dispatch/copy副本写入B4。因为B4位于R4既有writable evidence mapping源下，guest路径固定为 `C:/M3R4/evidence/r6r4r2-observable`。

observable probe总次数=1，同一Sandbox ID、run-as System、PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。probe必须逐阶段写独立UTF-8 JSON checkpoint到B4映射：
- `00-started.json`：PID/time/Sandbox ID/probe/helper SHA。
- `10-root.json`：guest视图B3根 exists/Container；失败 `R6R3_MODULE_ROOT_NOT_VISIBLE_IN_GUEST`。
- `20-sentinels.json`：精确 `pubspec.yaml`、`lib/main.dart` exists/Length/SHA256；失败 `R6R3_MODULE_SENTINEL_READ_FAILED`。
- `30-current-view.json`：用**冻结同一helper**对guest B3根生成 `guest-b3-current.tsv`，记录统计/helper exit；helper异常必须记录exception type/message；失败 `R6R3_MODULE_CURRENT_VIEW_FAILED`。
- `40-compare.json`：guest TSV size/SHA 与 `expected-module-current.tsv` 比较；不一致时逐行记录首个mismatch；失败 `R6R3_MODULE_GUEST_VIEW_MISMATCH`。
- `90-pass.json`：仅完全PASS时写入 527/301/3234145/0 与 `R6R4R2_CURRENT_VIEW_TSV_SHA256`。

若WSB/guest exit非0，host读取最后checkpoint给最窄分类；无00则 `R6R4R2_OBSERVABLE_PROBE_NOT_STARTED`。不得再笼统写 `R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE`，除非checkpoint确实没有更细证据。

只有90-pass成立才继续。

## 7. 条件式主guest、模块cwd与派发/隔离

probe PASS 后生成 nonce=`M3-ISO-V02-008-R6R4R2-<random>`，同一ID run-as System执行 `guest-r6r4r2.ps1`，RemoteSigned。所有新guest evidence只写B4。

验证：guest.started+nonce+Sandbox ID、PowerShell5.1、Process/effective RemoteSigned、Security module系统Path、活动网卡0、默认路由0、helper/dispatch/copy SHA。

随后同一dispatch完成 ordinary native smoke（override_present=false）、batch pub shape、batch M3 shape、exit37。不得重跑host 4+6。

模块唯一来源：guest视图B3根 `C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module`。禁止archive、禁止搜索。冻结copy/robocopy直接复制到 `C:/M3R6R4R2/w/apps/flutter_elitesync_module`。

复制后用冻结helper生成 guest-work TSV；必须 527/301/3234145/reparse0，size/SHA精确等于 `R6R4R2_CURRENT_VIEW_TSV_SHA256`。失败记录stage/path并STOP `FIXED_MODULE_CWD_COPY_OR_CURRENT_VIEW_MISMATCH`。

## 8. R4工具/cache复用与真实执行

module cwd PASS 后只 Test-Path：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- wrapper dists `C:/M3R4/h/wrapper/dists`

七项存在=>直接复用。缺失项只检查对应既有seed `C:/M3R4/s/f`,`s/a`,`s/j`,`s/g`,`s/p`,`s/h`,`s/d`；seed存在才允许guest内部单项恢复到R6R4R2 task目录。内部副本和seed都缺失 STOP `R4_GUEST_TOOL_REUSE_NOT_AVAILABLE`。禁止新share/host搜索。

真实运行一次 Git `--version` 与 Java `-version`；记录 RunNative收到参数、override_present=false、最终Arguments、actual executable、stdout/stderr、exit。任一失败即停。

设置guest环境只指向guest内部Flutter/Android/JAVA/Pub/Gradle；HOME/USERPROFILE/TEMP/TMP指向 `C:/M3R6R4R2` task-owned目录。cwd固定 `C:/M3R6R4R2/w/apps/flutter_elitesync_module`。

Git/Java成功后真实 pub 仅一次：`flutter pub get --offline`，最多10分钟，不联网补包、不重试，按真实诊断分类。

仅 pub exit=0 后运行一次 M3：`flutter build aar --no-debug --no-profile --no-pub`；defines=`EMPTY`，追加0个dart-define；最多30分钟，不重试。

仅M3实际启动后检查一次：`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。HIT记录size/SHA-256；M3未启动=>AAR=`NOT_CHECKED`, probe=0。M2不得执行。

## 9. evidence、生命周期与候选

任务结束后host将B4完整复制到E；本轮task-owned manifest必须B4/E一致。B4保留，不删除；不修改B3/旧bridge/evidence。

不得stop/close/reset/kill Owner Sandbox。task-owned进程按既有Job/PID规则收尾。

候选分支：`review/h01-bib03-u15-td01-m3-host-current-view-repair-v0-8-r6-r4-r2`。

一个candidate commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_HOST_CURRENT_VIEW_REPAIR_AND_OBSERVABLE_EXECUTION_RESULT_V0_8_R6_R4_R2.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从main A正常UTF-8版本开始；发布前检查无mojibake。

报告返回：candidate/parent/two blobs；helper最终SHA与fixture selftest；SRC/B3 TSV size/SHA与比较；全部observable checkpoints及最窄失败stage；若PASS则guest.started/隔离/dispatch、module cwd/current-view、R4工具复用/fallback、Git/Java、pub/M3/AAR；B4→E manifest；Owner Sandbox最终状态。

不自我接受、不更新main、不执行M2、不修改AGENTS或ChatGPT项目源。完成后停止。