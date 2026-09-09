# EliteSync v10｜可观测目录桥诊断、逐文件校验与条件式 M3 v0.8-R6-R4-R1

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — SUPERSEDES UNACTIVATED R6-R4 — OBSERVABLE GUEST PROBE`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、旧R6-R4作废、激活与唯一目标

当前权威 main 为 `b7ded0a4251395beb0a25073bf47d6b61d8e9081`。该 main 已接受 R6-R3 候选精确 tree `e140fc22befc60ab753eedad815b96cdade5d941`：host 侧 `r6r3-bridge/module/apps/flutter_elitesync_module` 为 527 文件、301 目录、3234145 bytes、reparse=0，历史 accepted manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`；唯一 Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。

R6-R3 唯一无副作用 guest probe 从 `C:/M3R4/evidence/r6r3-bridge/probe-r6r3.ps1` 实际执行，WSB CLI exit=0、guest ExitCode=1，但没有 guest 内诊断文件。因此只能证明“probe内部某一检查失败”，不能证明整个 bridge 根不可见。

先前发布但**尚未激活**的 R6-R4 task commit `93b0ac9ed1c4f3f380db00937204f4c015fbc8fe` / blob `63826e478785fa4f0497c8496bcc7827f68960e2` 现被本任务永久 supersede，不得执行。原因：旧 R6-R4 把新诊断 TSV 的 `relative_path + length + SHA256` 规范错误要求为必须复现历史 `relative-path + SHA256` manifest 值 `6D4E...`；两者不是同一规范。**本任务不重定义、不重算、不替换历史 accepted manifest。**

本任务唯一目标：仅新增一个可写 observable bridge 子目录，让 guest probe 把每阶段 checkpoint/异常写回；使用**新生成、独立命名的逐文件 TSV**做 host↔guest 当前字节视图比较，不宣称该 TSV hash 等于历史 manifest。若 guest 对 R6-R3 模块目录的 527 个文件逐项 path/length/SHA256 全部与 host expected TSV 相同，则直接继续模块复制、R4工具/cache复用、真实 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR；否则以最窄原因停止。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R4-R1 任务；确认旧 R6-R4 `93b0ac...` 不执行。允许仅在 `W/evidence/resume-r4` 下新增 `r6r4r1-observable`，只写本轮诊断/bootstrap/evidence；允许只读检查既有 R6-R3 module bridge，不修改其字节。允许在宿主对 task-owned SRC 生成一次新的逐文件 expected TSV，并对 B3 当前视图做逐项比较；该 TSV 是新诊断对象，不替代历史 manifest。仅在本任务专用 host 自测/guest PowerShell 进程使用进程级 RemoteSigned。不得新 `wsb share`、不得新建/stop/close/reset/kill Sandbox、不得使用 archive 解包。observable probe PASS 后允许 guest module copy、R4工具/cache复用、真实 Git/Java、一次 offline pub 及条件式一次 M3。不联网补包、不写原仓库/default index/working tree/受保护 staged state/宿主 SDK/cache/产品源码，其余边界保持。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 R6-R4-R1。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始仅从 GitHub 远端核验：
1. main=A=`b7ded0a4251395beb0a25073bf47d6b61d8e9081`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺 task ref/object 不构成 blocker。
4. task commit 唯一父=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A中R6-R3 result blob=`33613af1985b340c01b984cb6109b19ba6932ab9`。
6. A中CURRENT_CONTEXT blob=`2410e6c2a35ba28fa0c23373535b5736f70ae839`。
7. 精确 sentinel：`apps/flutter_elitesync_module/pubspec.yaml` Git blob=`1b807ccdcced1e3166fd6e5378865ecb5bba4708`；`apps/flutter_elitesync_module/lib/main.dart` Git blob=`607b51186540bd0eb1998c1997472a05447d9a3d`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不仓库枚举/搜索、不访问旧仓库/default index/受保护 staged state。

## 3. 固定本地来源、新TSV与observable bridge

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读来源：
- `SRC=W/input-r6-r1/apps/flutter_elitesync_module`，历史 accepted：527 files / 301 dirs / 3234145 bytes / reparse=0 / legacy manifest=`6D4E...`。
- `B3=W/evidence/resume-r4/r6r3-bridge/module/apps/flutter_elitesync_module`，历史 R6-R3 host copy已证明当时与SRC同一 legacy manifest；本轮只读。
- dispatch SHA=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- copy SHA=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。

新 bridge：`B4=W/evidence/resume-r4/r6r4r1-observable`。新 canonical evidence：`E=W/evidence/resume-r6-r4-r1`。B4/E开始必须均不存在；任一已存在 STOP `R6R4R1_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除/清理/复用。

创建B4后仅写B4：probe、guest、dispatch/copy副本、fixtures、新 expected TSV、diagnostic/evidence。不得修改B3、旧r6r2/r6r3 bridge或R4其它既有内容。

## 4. host current-view TSV gate —— 不重算 legacy manifest

只允许枚举 SRC 与 B3 两个 task-owned/bridge 模块根。生成新的 current-view TSV 规范：每个文件一行 `relative_path<TAB>length<TAB>SHA256`，relative path统一`/`并按 ordinal 排序；UTF-8无BOM，LF换行。分别得到 `src-current.tsv` 与 `b3-current.tsv` 及各自 SHA-256。

要求：
- SRC：527 files、301 dirs、3234145 bytes、reparse=0；
- B3：同样统计；
- 两份 TSV **字节完全相同**，且 TSV SHA-256 相同。

该新 TSV hash 是 `R6R4R1_CURRENT_VIEW_TSV_SHA256`，必须单独记录；**不得把它写成或要求等于历史 `6D4E...` legacy manifest**。

host TSV/诊断函数先在 SRC 做一次自测；普通脚本错误最多允许1次定点纠正。若SRC/B3当前视图不同，STOP `R6R4R1_HOST_BRIDGE_CURRENT_VIEW_MISMATCH`，记录首个 relative path 差异，不修B3。

通过后只把 `src-current.tsv` 的字节副本写成 `B4/expected-module-current.tsv`，记录其SHA。

## 5. 现有 Sandbox 与 observable probe

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`；禁止 `wsb share`/`wsb stop`/新Sandbox。

`wsb list --raw` 必须唯一 ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

同一ID、run-as System执行 `C:/M3R4/evidence/r6r4r1-observable/probe-r6r4r1.ps1`，PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

probe总次数=1；必须逐阶段写独立 UTF-8 JSON checkpoint 到 `C:/M3R4/evidence/r6r4r1-observable/`：
- `00-started.json`：PID/time/Sandbox ID/script SHA。
- `10-root.json`：B3 guest根 `C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module` exists/Container；失败 `R6R3_MODULE_ROOT_NOT_VISIBLE_IN_GUEST`。
- `20-sentinels.json`：`pubspec.yaml`、`lib/main.dart` exists/Length/SHA256；失败 `R6R3_MODULE_SENTINEL_READ_FAILED`。
- `30-enumeration.json`：file_count/dir_count/total_bytes/reparse；异常写 type/message/stage；失败 `R6R3_MODULE_ENUMERATION_FAILED`。
- `40-current-tsv.json`：逐文件 path/length/SHA256 计算；某文件失败必须记录首个 failing relative path + exception；失败 `R6R3_MODULE_FILE_HASH_FAILED`。
- `50-compare.json`：guest current TSV 与 `expected-module-current.tsv` 字节比较；若不同记录 first mismatch relative path、expected/actual length+hash；失败 `R6R3_MODULE_GUEST_VIEW_MISMATCH`。
- `90-pass.json`：仅完全PASS时写入 guest TSV SHA、527/301/3234145/0。

若WSB/guest exit非0，host读取最后checkpoint给出最窄分类。若无 `00-started.json` => `R6R4R1_OBSERVABLE_PROBE_NOT_STARTED`。不得再笼统写 `R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE`，除非checkpoint确实无法进一步区分。

只有 `90-pass.json` 成立且 guest current TSV SHA 精确等于 host `R6R4R1_CURRENT_VIEW_TSV_SHA256`，才继续。

## 6. 条件式主guest、模块copy与隔离/dispatch

probe PASS 后生成 nonce=`M3-ISO-V02-008-R6R4R1-<random>`，同一ID run-as System执行 `guest-r6r4r1.ps1`，PowerShell RemoteSigned。所有新guest evidence只写B4。

主guest验证 guest.started + nonce + Sandbox ID、PowerShell 5.1、Process/effective RemoteSigned、Security module系统Path、活动网卡0、默认路由0、dispatch/copy SHA。随后同一dispatch完成 ordinary native smoke（override_present=false）、batch pub shape、batch M3 shape、exit37。不得重跑host 4+6。

模块唯一来源为 B3 guest根；禁止archive、禁止搜索。冻结copy/robocopy直接复制到 `C:/M3R6R4R1/w/apps/flutter_elitesync_module`。

复制后按同一 current TSV 规范生成 guest-work TSV，并要求：527/301/3234145/reparse0，TSV SHA精确等于 host `R6R4R1_CURRENT_VIEW_TSV_SHA256`。失败记录首个stage/path，分类 `FIXED_MODULE_CWD_COPY_OR_CURRENT_VIEW_MISMATCH`。

## 7. R4工具/cache精确复用

module cwd PASS 后只 Test-Path：`C:/M3R4/t/f/bin/flutter.bat`、`C:/M3R4/t/a`、`C:/M3R4/t/j/bin/java.exe`、`C:/M3R4/t/g/cmd/git.exe`、`C:/M3R4/p`、`C:/M3R4/h/caches`、`C:/M3R4/h/wrapper/dists`。

七项存在=>直接复用。缺失项只检查对应既有 seed `C:/M3R4/s/f`,`s/a`,`s/j`,`s/g`,`s/p`,`s/h`,`s/d`；seed存在才允许guest内部单项恢复到R6R4R1 task目录。内部副本和seed都缺失 STOP `R4_GUEST_TOOL_REUSE_NOT_AVAILABLE`。禁止新share/host搜索。

## 8. 真实Git/Java、offline pub、M3、AAR

前置PASS后真实运行一次 Git `--version`、Java `-version`，记录 RunNative args、override_present=false、最终Arguments、actual executable、stdout/stderr、exit。任一失败即停。

guest环境只指向guest内部Flutter/Android/JAVA/Pub/Gradle；HOME/USERPROFILE/TEMP/TMP指向 `C:/M3R6R4R1` task-owned目录。cwd=`C:/M3R6R4R1/w/apps/flutter_elitesync_module`。

真实 pub 一次：`flutter pub get --offline`，最多10分钟，不联网补包/下载/重试，按真实诊断分类。

仅 pub exit=0 后 M3 一次：`flutter build aar --no-debug --no-profile --no-pub`，defines=EMPTY，0个dart-define，最多30分钟，不重试。

仅M3实际启动后检查一次：`C:/M3R6R4R1/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。HIT记录size/SHA256；M3未启动AAR=NOT_CHECKED/probe=0。M2不执行。

## 9. evidence、生命周期与候选

结束后host将B4完整复制到E；本轮B4/E manifest必须一致。B4保留；不得修改旧bridge。Owner Sandbox不得stop/close/reset/kill；task-owned进程按既有Job/PID收尾。

候选分支：`review/h01-bib03-u15-td01-m3-observable-directory-bridge-v0-8-r6-r4-r1`。

一个candidate commit，唯一父为本任务commit，恰好：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_OBSERVABLE_DIRECTORY_BRIDGE_AND_EXECUTION_RESULT_V0_8_R6_R4_R1.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8无mojibake。

结果必须返回：candidate/parent/two blobs；host current TSV hash与SRC↔B3比较；observable各checkpoint与首个失败stage/path/exception；若PASS则主guest、module copy current TSV、R4工具复用、Git/Java、pub、M3、AAR；B4→E manifest；Owner Sandbox最终状态。

不自我接受、不更新main、不执行M2、不修改AGENTS或ChatGPT项目源。完成后停止。