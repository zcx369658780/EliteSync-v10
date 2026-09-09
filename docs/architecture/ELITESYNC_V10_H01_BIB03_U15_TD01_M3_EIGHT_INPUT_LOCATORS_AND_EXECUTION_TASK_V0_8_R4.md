# EliteSync v10｜八项宿主 Locator 固定与现有 Sandbox 条件式 M3 v0.8-R4

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — EXACT HOST LOCATORS SUPPLIED — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、Owner激活与唯一目标

当前 main `fd96ad5b1278b50404abbcc2bacd1c00624063dc` 已接受 v0.8-R3：官方 `wsb.exe` 版本 `0.8.107.0` 已取得唯一 running Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；existing-session share/exec 成功；guest.started、nonce、PowerShell 5.1、Process/effective=`RemoteSigned`、Security 模块系统路径、活动网络适配器0、默认路由0均已实测通过。Owner现有Sandbox未stop/close/reset/kill，仍由Owner控制。旧 host ordinary native 4/4 与 batch 6/6 证据继续有效且未重跑；dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。

R3 的唯一阻塞是任务没有向执行者重新提供八项 host 绝对 locator。该缺口现由本任务直接闭合：以下八项路径是此前 M3 隔离准备链中已经由 Owner/既有任务明确给出的固定宿主 locator；本任务重新具名授权，只允许对这些精确路径做 `Test-Path`、属性/hash/必要只读复制与 `wsb share`，不得搜索、枚举或猜测替代路径。

本任务唯一目标：绑定八项精确 host locator → 复核现有唯一 Sandbox ID → 以只读 share/guest 内部可写副本继续两类 guest 冒烟、八项输入准备、Git/Java真实验证 → 一次 offline pub → pub成功时一次 M3 → 精确AAR证据。M2仍不执行。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R4任务；允许对任务列出的八项精确宿主locator执行有界只读存在性/类型验证、只读share及guest内部复制；允许继续使用官方WSB CLI识别到的当前唯一Owner Sandbox，但不得stop/close/reset/kill该会话。仅在任务专用guest PowerShell进程使用进程级RemoteSigned，限定脚本路径/hash与生命周期。guest隔离与两类冒烟通过后，允许一次八项输入准备、Git/Java验证、一次offline pub及条件式一次M3。不改持久策略/组策略/信任/来源标记，不提权、不使用Bypass/Unrestricted，不下载，不写原仓库或宿主SDK/cache，其余边界保持。

无批准仅报告 `WAITING OWNER ACTIVATION`。本批准只限v0.8-R4。

## 2. 固定 GitHub 入口

仓库：`zcx369658780/EliteSync-v10`。开始实时读取 main，必须恰为 A=`fd96ad5b1278b50404abbcc2bacd1c00624063dc`。

FIRST主动读取A中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob=`18485c95262051e43892436fb52413132c5ee626`。

随后核验本任务ref/commit/blob、唯一父A、相对A仅新增本任务文件。失配停止依赖动作，不自行换基线。

其他GitHub只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 使用A中实际blob作为候选更新基底。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_SANDBOX_SESSION_AND_EVIDENCE_RESULT_V0_8_R3.md` blob `24909ebac92e7c88f3159df4e3a8a3b84d8d7704`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_SANDBOX_SESSION_AND_EVIDENCE_TASK_V0_8_R3.md` blob `84b0e7c7f4e1f1bde01be2ca1a14f5f43567f3e9`，仅沿用WSB CLI、existing-session、share/exec与生命周期合同。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md` blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`，仅沿用guest复制/工具验证合同。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅 direct AAR/defines 合同。

README预算耗尽、FD02永久排除；不读取旧仓库、不仓库枚举/搜索、不访问默认index或受保护staged state。

## 3. 八项精确宿主 Locator（本轮新增的固定授权）

固定工作区 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。以下八项 host locator 是唯一允许的输入来源；只允许精确路径操作：

| # | 输入类别 | 精确 host locator | 预期用途 |
|---:|---|---|---|
| 1 | 固定模块输入根 | `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input` | 已物化的固定任务输入；guest内最终模块为 `apps/flutter_elitesync_module` |
| 2 | Flutter SDK | `D:/flutter` | guest Flutter 工具种子 |
| 3 | Android SDK | `C:/Users/zcxve/AppData/Local/Android/Sdk` | guest Android SDK 种子 |
| 4 | JDK 17 | `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` | guest Java 工具种子 |
| 5 | Git | `C:/Program Files/Git` | guest Git 工具种子 |
| 6 | Pub cache | `C:/Users/zcxve/AppData/Local/Pub/Cache` | offline pub cache 种子 |
| 7 | Gradle caches | `D:/GradleHome/caches` | offline Gradle cache 种子 |
| 8 | Gradle wrapper dists | `D:/GradleHome/wrapper/dists` | wrapper distribution 种子 |

对每项只执行：`Test-Path -LiteralPath`、确认Container、精确根路径规范化、必要时读取根对象属性/ACL可读性和后续share/copy结果。不得列目录来“确认内容”、不得递归统计、不得搜索替代安装位置。若某一精确 locator 不存在或不可读，立即分类 `EIGHT_INPUT_EXACT_LOCATOR_MISS`，报告该项编号与精确路径；不得寻找替代。

第1项 `W/input` 是任务自有输入根，不等于原Git仓库；本轮不得重新物化、重写或从仓库发现文件。后续在guest内部只使用它现有内容，按既有合同形成 `C:/M3R4/w/apps/flutter_elitesync_module`；若精确预期子路径在已share的guest命名空间中不存在，按实际失败停止，不回宿主搜索。

## 4. 现有 Sandbox 会话重新绑定

新增证据仅写 `W/evidence/resume-r4/`。旧 `resume-r1/r2/r3` 只读，不覆盖。

调用官方CLI能力只限：`wsb --version`、`wsb list --raw`、必要的 `wsb share`、`wsb exec`。本轮开始必须再次 `wsb list --raw`：
- 恰好一个running Sandbox且ID仍为 `68ece109-c661-420c-9899-02b1e9518036` → 继续 existing-session。
- 0个running或ID变化 → STOP，分类 `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；本任务不新建Sandbox。
- 多个/不可解析 → STOP，分类 `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

不得 `wsb stop`，不得关闭/reset/kill Owner Sandbox。

R3已有 `resume-r3` evidence/bootstrap share 不作为R4写入目标；R4新建独立：
- `W/evidence/resume-r4` → `C:/M3R4/evidence`，允许write。
- `W/evidence/resume-r4/bootstrap` → `C:/M3R4/bootstrap`，不加allow-write。

bootstrap目录不得嵌套写入会改变已执行脚本字节；脚本执行前后均记录SHA-256。因为host源位于可写evidence根下，报告继续声明别名限制；不得把“未加allow-write”夸大成host文件绝对不可变。

## 5. 八项 share 与guest内部副本

在新的R4 guest preflight再次确认同一Sandbox ID、nonce、Process/effective RemoteSigned、Security模块系统Path、活动网络适配器0、默认路由0后，才能share真实输入。

八项host输入全部使用官方 `wsb share` 绑定到以下只读 guest seed：
1. `W/input` → `C:/M3R4/s/in`
2. `D:/flutter` → `C:/M3R4/s/f`
3. Android SDK → `C:/M3R4/s/a`
4. JDK → `C:/M3R4/s/j`
5. Git → `C:/M3R4/s/g`
6. Pub Cache → `C:/M3R4/s/p`
7. Gradle caches → `C:/M3R4/s/h`
8. Gradle wrapper dists → `C:/M3R4/s/d`

以上八项均不得使用 `--allow-write`。每个share记录sandbox ID、host locator、guest seed、CLI exit；任一失败立即停止，不继续后续share/exec，不修改host源。

随后guest通过任务自有 `copy.ps1` / 已接受robocopy合同将只读seed复制到guest内部可写目录：
- `C:/M3R4/s/in` 中现有固定输入 → `C:/M3R4/w`，最终模块cwd=`C:/M3R4/w/apps/flutter_elitesync_module`
- Flutter → `C:/M3R4/t/f`
- Android SDK → `C:/M3R4/t/a`
- JDK → `C:/M3R4/t/j`
- Git → `C:/M3R4/t/g`
- Pub Cache → `C:/M3R4/p`
- Gradle caches + wrapper dists → `C:/M3R4/h/caches` 与 `C:/M3R4/h/wrapper/dists`

沿用已验证robocopy参数与退出分类，不重新设计复制算法；八项都PASS才继续。不得通过share本身把host目录当可写工作目录。

## 6. guest两类冒烟、真实工具、pub与M3

在八项真实输入share之前，先由R4 bootstrap加载同一dispatch实现并完成：
- ordinary native参数冒烟，`override_present=false`，参数实际进入OS；
- batch pub/M3形状及exit37冒烟。

两类PASS + 隔离PASS后才执行八项share/copy。

复制完成后真实运行一次：
- `C:/M3R4/t/g/cmd/git.exe --version`（若固定Git目录的实际既有可执行路径按已接受guest复制合同为另一精确子路径，则只允许从R3/R7既有固定脚本变量直接取得，不在目录中搜索；无法取得则STOP）
- `C:/M3R4/t/j/bin/java.exe -version`

每次记录RunNative收到参数、`override_present=false`、最终Arguments、actual executable、stdout/stderr、exit。任一失败即停止pub；不重新寻找Git/JDK。

成功后设置任务guest环境变量只指向R4内部副本：Flutter/JAVA/Android/Pub/Gradle/HOME/USERPROFILE/TEMP/TMP均不得写回host seed。cwd固定 `C:/M3R4/w/apps/flutter_elitesync_module`。

真实命令：
1. `C:/M3R4/t/f/bin/flutter.bat pub get --offline`，至多一次，10分钟。
2. 仅pub成功后：`C:/M3R4/t/f/bin/flutter.bat build aar --no-debug --no-profile --no-pub`，追加绑定defines数组；当前已接受defines=`EMPTY`则追加0个define参数。至多一次，30分钟。

不联网、下载、安装、修改Wrapper/SDK/产品源码或重试。非零只按真实诊断分类，不自动写缺包。

仅M3实际启动后一次检查精确AAR：
`C:/M3R4/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录size/SHA-256；未启动保持NOT_CHECKED；不搜替代。M2不执行。

## 7. 生命周期与候选

本任务不得停止Owner现有Sandbox。task-owned guest PowerShell/工具进程必须按既有Job/PID归属规则结束；共享路径若CLI没有unshare能力则保留并报告，不为了清理而stop Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-eight-input-locators-v0-8-r4`。

一个commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EIGHT_INPUT_LOCATORS_AND_EXECUTION_RESULT_V0_8_R4.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从本任务固定main A中的干净UTF-8版本开始更新；发布前检查UTF-8与明显mojibake。

报告至少返回：八项精确locator逐项存在性、fresh sandbox ID、R4两项bootstrap/evidence share、guest隔离/两类冒烟、八项share/copy、Git/Java、pub/M3/AAR、Owner Sandbox最终控制状态、所有旧证据未覆盖声明。发布后只核验一次parent/两路径/blob。

执行者不自我接受、不更新main、不执行M2、不修改AGENTS或ChatGPT项目源。

## 8. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36与产品实现边界保持。除激活后任务专用RemoteSigned外，不改持久策略/信任/系统配置；不下载、不真实数据、不生产访问。宿主SDK/cache与原仓库始终只读。