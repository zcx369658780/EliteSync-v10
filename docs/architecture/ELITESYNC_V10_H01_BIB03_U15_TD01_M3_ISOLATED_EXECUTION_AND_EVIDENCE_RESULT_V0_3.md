# EliteSync v10｜Git定位修复与M3隔离续行结果 v0.3

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — COPY PATH-LENGTH FAILURE**（guest记录主类M3 PRECONDITION BLOCKED）。
Git绑定修复成功、固定过滤输入成功、一次Sandbox实际隔离控制通过；客体复制阶段因CreateDirectory长路径异常停止。pub/M3未启动，AAR=NOT_CHECKED，不是NON-HIT或生成命令失败。
Attempt：M3-ISO-V02-003；日期：2026-09-07。

## 固定入口与历史保护

- 实时main：`d978e9d36e32e0b12f02eb9f4e7de0690a8b7226`，匹配。
- FIRST交接blob：`18485c95262051e43892436fb52413132c5ee626`，匹配；旧startup未恢复。
- task ref：task/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-3 → `1f4ee52b262ee109a4017a4a3540e6309d1f2dc2`；blob `01dc74cb1b4cfd6d11b79a61a00e1a44b52f7d75`。
- task唯一父为上述main；仅新增任务单，ahead=1/behind=0；tree `0e78c98775437156e70e84cb5dc2320f5b3bc4ae`。
- 其余固定输入blob核验匹配：AGENTS f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1；CURRENT_CONTEXT aca04aa63dd179d27c697ed37e23bc718cbe95a2；002结果1b92aa1d1bc561e558955d50921c3e125912f3ea；v0.2任务d158003332c7f3c06f689eb970b18b167dfeba96；build.gradle.kts a7e0f7583c801e2d56afc595d6c7bed84b5ce516；项目properties f0a2e55f89e383466d2c6b481c8c468a3aa0b13d。仅采用声明的合同/相关章节，不跟进引用。
- 本地root D:/EliteSync-v10、origin git@github.com:zcx369658780/EliteSync-v10.git匹配。local HEAD `d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88`仅作上下文。
- 本地固定对象起初不可用；仅fetch声明main到refs/elitesync/m3-iso-v02-003-input，--no-tags/--no-recurse-submodules。输入ref回读恰为固定main；同时Git按既有远端映射更新origin/main，未切换HEAD、未改工作区或默认index。
- 002两个文件开始时安全路径/hash匹配，terminal=true且pub/M3均未启动；没有读其他旧根内容。003在approved root下独占新建attempts/M3-ISO-V02-003，未复用002 input/flags。001/002均保留已接受历史，不倒写为成功。

## Git定位修复与原始证据

一次Get-Command -Name git.exe -CommandType Application返回4个System.Management.Automation.ApplicationInfo对象；在任何守卫前保存git-discovery-1.json，数组化后选第一项Path，不把数组直接交给-notmatch。

| 原始解析顺序 | Path/Source/Definition中的路径（各项三字段一致） |
| --- | --- |
| 1，选中 | `C:Program FilesGitcmdgit.exe` |
| 2，未探测/未切换 | `C:Userszcxvescoopappsgitcurrentcmdgit.exe` |
| 3，未探测/未切换 | `C:Userszcxvescoopshimsgit.exe` |
| 4，未探测/未切换 | `C:Userszcxve.cachecodex-runtimescodex-primary-runtimedependencies
ativegitcmdgit.exe` |

选中原始路径与Trim/斜杠规范化路径一致。该exe及祖先均通过定点reparse检查。
仅对子进程排除GIT_EXEC_PATH覆盖，未读取或修改用户Git配置；两项宿主自描述各执行一次：
- --version：exit=0；stdout为git version 2.53.0.windows.1；stderr空。
- --exec-path：exit=0；stdout为C:/Program Files/Git/mingw64/libexec/git-core；stderr空。

选定完整发行根：`C:Program FilesGit`。cmd入口与exec-path均指向这一根；没有把mingw64当完整根。唯一候选根的cmd/git.exe、mingw64/bin/git.exe、mingw64/libexec/git-core、usr/bin/sh.exe均命中且安全路径检查通过；前二及sh为文件，git-core为目录。不猜常见位置、不搜索其他安装，不复制用户配置/凭据。

定位轮次=1；额外定位=0；本轮准备helper实际缺陷修复轮次=0。针对002的具体采证缺陷，003采证器改为先落盘、数组化和单项选择；003没有重跑002。新返回4对象支持旧数组守卫风险，但不能声称恢复了002当时丢失的原始值。

## 固定输入与冻结合同

W=`D:EliteSync-M3-readiness-v02attemptsM3-ISO-V02-003`。
具名输入沿用任务：D:\flutter；C:\Users\zcxve\AppData\Local\Android\Sdk；C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot；C:\Users\zcxve\AppData\Local\Pub\Cache；D:\GradleHome\caches；D:\GradleHome\wrapper\dists。各根、具名入口及祖先通过元数据/reparse检查；未回退旧.gradle或扫描cache版本。

defines按用户home属性→固定项目属性→当前具名环境变量顺序，结果EMPTY，0项；未读其他属性或输出敏感值。固定项目blob无该键。
仅从固定main的apps/flutter_elitesync_module Git对象制作二进制zip并机械过滤至W/input/module，526文件、1条目排除。过滤规则涵盖README类、FD02、build/.dart_tool/.android/.ios/.gradle/Git元数据及凭据/真实数据/运行日志类路径；拒绝穿越/绝对路径/链接。未分析产品源码，没有把旧build/AAR复制进输入。内部manifest仅供物化证据，不上传源码或全量路径清单。

m3.wsb SHA-256：`5F76746F0AE976704CDB3F0EE4B06E53F78055ED205A1E89F71B8475A5111F95`。
配置显式禁用Networking、ClipboardRedirection、AudioInput、VideoInput、PrinterRedirection和VGpu。8个只读映射：W/input及六个seed根、已绑定Git根；唯一可写宿主映射W/evidence→C:\M3\evidence。没有映射002 evidence、全原仓库、用户主目录或D:\GradleHome全部。
启动前XML定点复读核对9项精确映射及控制值，guest脚本语法解析0错误；冻结配置/脚本/参数数组/manifest哈希。启动后未修改合同。

计划并冻结的命令（不是全部已执行的声明，真实阶段见下表）：
- 客体Git：C:\M3\tools\git\cmd\git.exe --version；客体Java：C:\M3\tools\jdk\bin\java.exe -version。
- pub：C:\M3\tools\flutter\bin\flutter.bat pub get --offline，600秒。
- M3：C:\M3\tools\flutter\bin\flutter.bat build aar --no-debug --no-profile --no-pub，1800秒；不追加defines。
- pub/M3 cwd均为C:\M3\work\apps\flutter_elitesync_module；环境只绑定客体工具/系统目录及专用cache/temp。阶段启动标志防重入，超时只针对本次客体子进程树，不重试。

## 实际隔离控制

Owner报告Sandbox Enabled作为来源声明保留，未重跑feature/DISM、未提权。
2026-09-07T15:10:51Z向系统关联提交指定.wsb一次，宿主启动进程PID 20720；宿主返回成功不单独作为隔离证明。
客体2026-09-07T15:11:09Z回传同次nonce `7a451c4c-cd96-4f6f-966a-d740bb379ec2`。isolation-control.json记录up_adapter_count=0，default_routes=[]；4个接口均为Not Present。配置哈希与nonce一致，未ping/DNS/HTTP探测、未对宿主只读映射试写。配置与本次客体记录共同支持本合同隔离控制门通过，不宣称普遍安全证明。


## 真实终态与命令预算

客体在2026-09-07T15:43:50Z保存terminal=true，phase=COPY，timeout=false。异常原文：
> Exception calling "CreateDirectory" with "1" argument(s): "The specified path, file name, or both are too long. The fully qualified file name must be less than 260 characters, and the directory name must be less than 248 characters."

该异常来自自有CopySafe准备helper调用的目录创建，不是Flutter、pub或Gradle输出。已记录Flutter复制开始15:11:16Z、Android复制开始15:14:17Z、JDK开始15:24:06Z、Git开始15:24:16Z。这表明前面Flutter/Android/JDK复制调用已返回；Git及其后pub/Gradle seed没有单独完成标记，无法精确归属失败文件到某个seed。

具体长路径未进入异常/日志；本轮不补猜目录或扫描查找。复制实现对Windows客体路径长度的处理不足是当前可证的准备问题，不说明SDK/cache缺失、依赖不兼容或项目无效。任务§5只允许启动前helper修复、§6禁止启动后改冻结脚本重试，因此本轮保留失败，不重新启动Sandbox或继续到pub。

| 阶段 | 实际结果 |
| --- | --- |
| Git定位 | 1轮；保存4个原始对象，选择第一项；0额外查询轮次 |
| host Git --version / --exec-path | 各1次，均exit=0 |
| 采证/准备helper修复 | 003重新设计修复002采证；003实际错误修复轮次0；启动后修改/重试0 |
| 002保护 | 开始/结束均按两个指定哈希匹配；只读，未复用input/flags |
| 003源码过滤物化 | 526文件/排除1条目；固定Git对象，不用工作区HEAD |
| Sandbox | 指定配置提交1次，guest nonce匹配；活动网络接口0、默认路由0；控制门通过 |
| 客体工具/seed复制 | 未全部完成；CreateDirectory长路径异常 |
| 客体Git --version / Java -version | 均未到达、0次，exit无值；不把宿主Git版本当客体验证 |
| flutter pub get --offline | 0次；pub_started=false、pub_exit=null |
| release-only M3 | 0次；m3_started=false、m3_exit=null |
| exact AAR | 0次探测；NOT_CHECKED；size/SHA-256=null |
| Maven repo导出 | 未执行，无导出AAR哈希 |
| M2证据条件 | 不具备新增产物输入；仍deferred，未执行 |

宿主系统关联启动进程返回不等于工具子命令exit。该启动进程随后退出，按其已记录父PID定点观察到同次WindowsSandboxRemoteSession.exe（PID26840）；只用于有限会话监视，没有按名字杀宿主进程或读取其他会话内容。客体脚本已终态退出，不再等待后台命令；本轮未主动关闭沙箱窗口，也未宣称未导出临时副本具有持久恢复能力。

## 本地保存和可复核范围

003 evidence根：`D:EliteSync-M3-readiness-v02attemptsM3-ISO-V02-003evidence`。
保存了result、host/guest日志、原始Git对象记录、绑定守卫、自有源码manifest、冻结合同/配置哈希、同次隔离控制、启动记录和002保护记录。没有把本地日志、cache、源码或AAR上传GitHub。

| 文件 | SHA-256 |
| --- | --- |
| M3-ISO-V02-003-result.json | 86644B9961C05EE813A8B3738F2F3434C4A214F3B8B81A460A855E69E63398D5 |
| host.log | 25F2A53A3EB90D84B0A5B0DE15645665E063B5E4CAB5EA9540424E1DB3593413 |
| guest.log | 6B04E78A6E3D8A151642FAD25209826332C3C9ECD9B8D7F14E3CAAF43DCC7E53 |
| git-discovery-1.json | F3EC862C13B9D8B947A47CA81ED4F5FDDA411C2FED69919C92E73B77DB4DE526 |
| git-binding.json | BBDD9A76C108D952DE8740D8AEA742DA5D9B2F9D30AB51F9A25597E1F84E1A4C |
| source-manifest.json | 8CF6C895913CF414D61BB7BF9BDA81D917F8483D6347CA88E7984AE8A24E67C3 |
| frozen-contract.json | 2037E03DAB61E282DF4461C9016834EF5668194116F0D37250F8D3FB2ABE53E2 |
| isolation-control.json | 47B4C172608D7293D8E9FFE80E07055E6756282DBC5674CE14C1E1E1E7229703 |
| sandbox-launch.json | F078671C3F1C5E8EF17EA0695B4304DBDB1A42E277AE4A4A97DC35B529E3F0D4 |
| 002-preservation.json | B655A67C3FFCF94F4BBD9E8559CEEE9190A122B3D404D71D6A1FB1963DF16131 |

final-evidence-hashes.json保存上述最终摘要；额外launch-children.json记录同次启动的有限子进程观察。W中prepare/configure/guest脚本及输入配置保留，自有文件哈希见frozen-contract.json。构建阶段日志没有生成，因为对应命令未启动；guest.log是准备/隔离阶段实测日志，不冒充构建日志。

002证据结束复核：
- result.json仍为67067707728C779AB89047D1A6C53DA9E5DE75A06582F2A150F98B8ED1B3E2F7。
- host.log仍为D7ED460EB9D32C0C77D288756D44D13A18A8DD08FBDB70B39DE97E6BE31C40B5。
- 002其他内容未读取/修改；003证据不清理，旧根不删除、不覆盖。

## 最小剩余障碍与非授权边界

Git安装根缺口已闭合，Owner无需手工找Git或重复批准选项1。当前障碍是客体复制helper的长路径处理及缺少失败源/目标路径记录。后续若另行授权续行，最小修正应只针对该复制问题，并在启动前用合成路径/自有目录验证、保存具体失败路径；不得更改宿主长路径策略、缩减未获批准的输入、改产品源码、联网补包或重试本次003。本轮不发布新任务。

001/002历史和003实际证据分开。M3没有真正启动，不具备进入M2的新增AAR证据；不得报告生产证据HIT、App可安装或整体重构进度。产品/法律/Safety/no-processing、旧M1耗尽lane、D-02/U-14/U-12/TP、Backend 0/10、Database 0/8、PUI、LC-03/LC-04/Phase36及产品实现边界保持。
原仓库内容、宿主SDK/cache和用户配置未写；默认index、git status、工作区切换/清理、旧仓库、README/FD02正文及真实用户数据未作agent读取或分析。机械物化与工具复制仅在明确范围内，宿主Git对象传输不是构建联网授权。
Owner声明宿主选择GPT-6 Astra；公开身份为基于GPT-6的Codex，未独立读取model ID/完整加载链，未改模型配置、未启动辅助代理；不宣称整仓clean或自动重载。
仅本报告与CURRENT_CONTEXT指定部分作为一个候选提交；§2/§3/§6/§7原文保留。待独立审查，不自我接受、不更新main、不执行M2、不另发任务、不更新ChatGPT项目源。发表后停止。
