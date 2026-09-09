# EliteSync v10｜可观测目录桥诊断、固定模块续行与条件式 M3 v0.8-R6-R4

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — OBSERVABLE GUEST PROBE — NO NEW WSB SHARE — CONDITIONAL CONTINUATION`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `b7ded0a4251395beb0a25073bf47d6b61d8e9081`。该 main 已接受 R6-R3 候选的精确 tree `e140fc22befc60ab753eedad815b96cdade5d941`：宿主固定模块目录桥接 PASS，`r6r3-bridge/module/apps/flutter_elitesync_module` 在 host 侧精确为 527 文件、301 目录、3234145 bytes、reparse=0，manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。唯一 Owner Sandbox ID 仍为 `68ece109-c661-420c-9899-02b1e9518036`。

R6-R3 的唯一无副作用 probe 由 `C:/M3R4/evidence/r6r3-bridge/probe-r6r3.ps1` 实际执行，WSB CLI exit=0、guest ExitCode=1。由于 probe 不写 guest 诊断，当前**不能证明**失败来自目录不可见、sentinel 缺失、递归枚举、Get-FileHash、manifest 算法或其他脚本检查。能够执行位于 `r6r3-bridge` 中的 probe 脚本本身，反而证明整个新桥根并非简单“完全不可见”。

本任务唯一目标：**不重复制模块、不创建新 share、不使用 archive；仅新增一个可写诊断 bridge 子目录，让 guest probe 在每一阶段都持久化 checkpoint/错误，再根据确切结果条件式继续：若 R6-R3 模块目录在 guest 视图中可完整读取且 manifest 精确匹配，则直接把该既有目录复制到新的 guest 工作目录，随后复用 R4 工具/cache，真实运行 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR；若诊断失败，则以最窄精确原因停止。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R4 任务；允许仅在旧 R4 host evidence 根 `W/evidence/resume-r4` 下新增精确子目录 `r6r4-observable`，只写本轮诊断/guest/bootstrap文件；允许只读检查既有 `r6r3-bridge/module/apps/flutter_elitesync_module`，不得修改或覆盖其任何字节。允许在宿主对 task-owned 固定模块运行一次 manifest 诊断算法自测；仅在本任务专用 host 自测/guest PowerShell 进程使用进程级 RemoteSigned。不得执行新的 `wsb share`、不得新建/stop/close/reset/kill Sandbox、不得使用 archive 解包。若 observable probe 精确 PASS，允许继续 guest 模块复制、R4 工具/cache复用、真实 Git/Java、一次 offline pub 及条件式一次 M3。不联网补包、不写原仓库/默认 index/working tree/受保护 staged state/宿主 SDK/cache/产品源码，其余边界保持。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 v0.8-R6-R4。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始时只通过 GitHub 远端核验：
1. `refs/heads/main` 必须精确为 A=`b7ded0a4251395beb0a25073bf47d6b61d8e9081`。
2. FIRST：A 中 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺少 task ref/object 不构成 blocker。
4. task commit 唯一父必须为 A；相对 A 必须 ahead=1/behind=0 且只新增本任务文件。
5. A 中 R6-R3 result blob 必须=`33613af1985b340c01b984cb6109b19ba6932ab9`。
6. A 中 CURRENT_CONTEXT 必须为 R6-R3 状态，blob=`2410e6c2a35ba28fa0c23373535b5736f70ae839`。
7. A 中 `apps/flutter_elitesync_module/pubspec.yaml` 必须存在，Git blob=`1b807ccdcced1e3166fd6e5378865ecb5bba4708`；`apps/flutter_elitesync_module/lib/main.dart` 必须存在，Git blob=`607b51186540bd0eb1998c1997472a05447d9a3d`。这些仅作为两个固定 sentinel 路径，不扩展仓库读取范围。

仅远端 authority 失配才 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不得仓库枚举/搜索，不访问旧仓库、默认 index 或受保护 staged state。

## 3. 固定本地来源与新 observable bridge

固定工作区：`W=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读绑定：
- 固定宿主模块：`SRC=W/input-r6-r1/apps/flutter_elitesync_module`，accepted：527 files / 301 dirs / 3234145 bytes / reparse=0 / manifest=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。
- 既有 R6-R3 host bridge 模块：`B3=W/evidence/resume-r4/r6r3-bridge/module/apps/flutter_elitesync_module`，只读，accepted 同一 manifest。
- 冻结 dispatch：`W/scripts/dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- 冻结 copy：`W/scripts/copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。

R4 host evidence root：`R4E=W/evidence/resume-r4`。新 observable bridge：`B4=R4E/r6r4-observable`。新 canonical evidence：`E=W/evidence/resume-r6-r4`。

B4 与 E 开始时必须均不存在。任一已存在 => STOP `R6R4_TASK_OWNED_PATH_ALREADY_EXISTS`；不得删除、清空、覆盖或复用。

创建 B4 后，只允许写 B4 内：
- `probe-r6r4.ps1`
- `guest-r6r4.ps1`
- `expected-module-manifest.tsv`
- dispatch/copy 副本
- synthetic batch fixture
- host/guest diagnostic/evidence

不得修改 B3、旧 `r6r2-bridge`、R4E 其他既有路径。

## 4. host manifest 算法自测与 expected manifest

允许只对 SRC 执行一次 manifest 算法自测，不读取其他宿主目录。算法必须：
- 使用 `Get-ChildItem -LiteralPath SRC -File -Recurse -Force -ErrorAction Stop`；
- 相对路径统一 `/`；
- 按相对路径 ordinal 排序；
- 每项记录 `relative_path<TAB>length<TAB>SHA256`；
- manifest hash 为该规范化 UTF-8 文本的 SHA-256；
- 同时记录 file_count、directory_count、total_bytes、reparse_count。

host 自测必须重现 accepted：527 / 301 / 3234145 / 0 / manifest=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。若算法无法重现，最多允许 1 次普通代码纠正后重跑同一 SRC；仍不匹配则 STOP `R6R4_MANIFEST_ALGORITHM_NOT_REPRODUCED`。

通过后把规范化逐文件清单写入 `B4/expected-module-manifest.tsv`，记录其 SHA-256；不得重新物化或重新复制模块。

## 5. 现有 Sandbox 与 observable probe

本任务只允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止 `wsb share`、`wsb stop`、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 => STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 => STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

使用同一 ID、run-as System 执行 `C:/M3R4/evidence/r6r4-observable/probe-r6r4.ps1`，Windows PowerShell：`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

**probe 必须可观测，不得再是无副作用黑盒。**它只能把本轮诊断写回 `C:/M3R4/evidence/r6r4-observable/`，并在每阶段立即落一个独立 UTF-8 JSON checkpoint；后续失败不得覆盖前面 checkpoint：

1. `00-started.json`：时间、PID、Sandbox ID、probe script SHA。
2. `10-root.json`：精确 `C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module` 的 exists/Container；失败分类 `R6R3_MODULE_ROOT_NOT_VISIBLE_IN_GUEST`。
3. `20-sentinels.json`：精确检查 `pubspec.yaml` 和 `lib/main.dart`；记录 Length 与 SHA-256；任一缺失/读失败 => `R6R3_MODULE_SENTINEL_READ_FAILED`。
4. `30-enumeration.json`：递归 file_count、directory_count、total_bytes、reparse_count；所有异常 catch 后记录 exception type/message/stage，不允许丢失；异常 => `R6R3_MODULE_ENUMERATION_FAILED`。
5. `40-manifest.json`：按与 host 完全相同算法逐文件 SHA；若某个文件 hash 失败，必须记录首个 failing relative path 与 exception；若计算成功，记录 guest manifest hash；异常 => `R6R3_MODULE_FILE_HASH_FAILED`。
6. `50-compare.json`：guest manifest 与 accepted manifest及 expected TSV 比较；数量/长度/hash不匹配时记录 first mismatch relative path、host expected length/hash、guest actual length/hash；分类 `R6R3_MODULE_GUEST_VIEW_MISMATCH`。
7. `90-pass.json`：仅所有阶段 PASS 时写入，包含 accepted manifest。

probe 自身脚本逻辑只能在 host 对 SRC 做一次 synthetic dry-run/parse 检查；不得为了 guest 失败进行第二次 WSB probe。本任务 guest observable probe 总次数=1。

如果 probe WSB CLI/guest exit 非0：host 必须读取已经写回的最后 checkpoint 来给出最窄分类。若连 `00-started.json` 都没有，分类 `R6R4_OBSERVABLE_PROBE_NOT_STARTED`。不得笼统复用 `R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE`，除非证据确实只支持该层级。

只有 `90-pass.json` 建立且 manifest 精确匹配 accepted 值，才继续下游。

## 6. 条件式主 guest：隔离、派发与模块 cwd

observable probe PASS 后生成 nonce=`M3-ISO-V02-008-R6R4-<random>`，同一 Sandbox ID、run-as System 执行 `guest-r6r4.ps1`，PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

所有本轮 guest evidence 只写 B4。主 guest 必须验证：
- guest.started，nonce+Sandbox ID匹配；
- Windows PowerShell 5.1；
- Process/effective=`RemoteSigned`；
- Security module Name/精确系统 Path；
- 活动网络适配器0、默认路由0；
- dispatch/copy SHA 与 host 冻结一致。

随后同一 dispatch 完成 ordinary native 参数冒烟（override_present=false）、batch pub shape、batch M3 shape、exit37原样传播。不得重跑 host 4+6。

模块来源只允许既有 guest bridge：`C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module`。禁止 archive、禁止搜索替代路径。

使用冻结 copy/robocopy 合同直接复制到：`C:/M3R6R4/w/apps/flutter_elitesync_module`。复制后用同一可观测 manifest 函数验证：527 / 301 / 3234145 / reparse=0 / manifest=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。失败必须记录首个具体 stage/path，分类 `FIXED_MODULE_CWD_COPY_OR_MANIFEST_FAILED`，不得搜索或换来源。

## 7. R4 工具/cache 精确复用

模块 cwd PASS 后仅 `Test-Path -LiteralPath`：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android SDK `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub cache `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- wrapper dists `C:/M3R4/h/wrapper/dists`

七项全在 => 直接复用。某项缺失时只检查对应既有 R4 guest seed：`C:/M3R4/s/f`,`s/a`,`s/j`,`s/g`,`s/p`,`s/h`,`s/d`；seed存在才允许 guest 内单项恢复到 R6R4 task-owned 路径。内部副本和seed都缺失 => STOP `R4_GUEST_TOOL_REUSE_NOT_AVAILABLE`。禁止新 share、禁止 host 搜索替代路径。

## 8. 真实 Git/Java、offline pub、M3、AAR

前置全部 PASS 后真实运行一次 Git `--version` 和 Java `-version`。记录 RunNative 收到参数、override_present=false、最终 Arguments、actual executable、stdout/stderr、exit；任一失败立即停止，不重找工具。

设置 guest 环境只指向 guest 内部路径：Flutter、ANDROID_HOME/ANDROID_SDK_ROOT、JAVA_HOME、PUB_CACHE、GRADLE_USER_HOME；HOME/USERPROFILE/TEMP/TMP 指向 `C:/M3R6R4` 下 task-owned 目录。不得写 host seed。

cwd=`C:/M3R6R4/w/apps/flutter_elitesync_module`。

真实 pub 至多一次：Flutter `pub get --offline`，10分钟。不得联网补包、下载、重试；非零必须依据实际 stdout/stderr 分类。

仅 pub exit=0 后真实 M3 至多一次：`build aar --no-debug --no-profile --no-pub`；accepted defines=`EMPTY`，追加0个dart-define，30分钟，不重试。

仅 M3 实际启动后检查一次精确 AAR：`C:/M3R6R4/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。HIT记录 size/SHA-256；M3未启动 => AAR=`NOT_CHECKED`, probe=0。M2不得执行。

## 9. evidence、生命周期与候选

任务结束后 host 将 B4 完整复制到 E；对本轮 task-owned 内容计算 manifest，B4/E必须一致。B4保留，不删除；不得修改旧 R4/R6-R2/R6-R3 bridge。

不得 stop/close/reset/kill Owner Sandbox。task-owned guest/工具进程按既有 Job/PID规则收尾。

候选分支：`review/h01-bib03-u15-td01-m3-observable-directory-bridge-v0-8-r6-r4`。

一个 candidate commit，唯一父为本任务 commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_OBSERVABLE_DIRECTORY_BRIDGE_AND_EXECUTION_RESULT_V0_8_R6_R4.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT 从 fixed main A 的 UTF-8 版本开始；发布前检查无 mojibake。

结果报告必须明确区分：
- observable probe是否启动；
- 最后成功 checkpoint；
- 首个失败 stage/path/exception或具体 mismatch；
- 若 probe PASS，主guest/模块copy/工具复用/Git/Java/pub/M3/AAR 的真实状态；
- B4→E manifest；Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。完成后停止。