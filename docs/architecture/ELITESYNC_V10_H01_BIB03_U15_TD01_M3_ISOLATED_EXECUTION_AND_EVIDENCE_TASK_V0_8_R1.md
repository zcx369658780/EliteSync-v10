# EliteSync v10｜008 权威树修复后续行与条件式隔离 M3 v0.8-R1

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — RESUME EXISTING 008 EVIDENCE — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不改模型配置、不默认调用辅助代理。ChatGPT负责规划与独立验收。

## 1. 修复背景、激活与本轮目标

上一张v0.8任务 `8262bc30815530f550cb472fda08b125efa1f5b0` 的固定main为 `146d6e9eb1219314eaa14e3a1579426dd4ababe8`。执行者按固定入口规则发现该main树与任务声明不符而停止：CURRENT_CONTEXT实际为`284a24...`，v0.7 task/result缺失。随后独立检查确认不是执行者误读，而是接受提交146d6e9e错误指向了pre-candidate tree `965616f...`；007候选`940d8870...`正确tree为`13a0c645...`。ChatGPT已用tree-repair提交 `16225ef1db6063dacadd3bfc8b033b325c11d5df` 恢复精确007候选树并推进main，不改写007内容。

旧v0.8执行没有候选提交，不应伪造为GitHub结果；但其本地008工作区产生了可复用的自有host修复/回归证据。执行者报告：RunNative采用显式`UseSerializedArguments`开关；最终`dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；一次专用RemoteSigned host自测中普通exe 4/4 PASS、批处理6/6 PASS、普通exe override_present=false、batch=true、exit37原样传播，所有宿主测试进程已结束。因为固定main失配，Sandbox及之后阶段均未启动。

本任务不是重做该host测试，而是：绑定并验证既有008本地证据 → 采用同一修复后的dispatch字节冻结runner → 新启动一次Sandbox → guest两类冒烟 → 八项输入复制 → Git/Java真实参数验证 → 一次离线pub → 条件满足时一次M3 → 证据与进程收尾。只有既有host证据无法完整绑定时才停止，不以重跑host测试替代证据缺失。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R1任务；仅在其沙箱客体入口及本任务确需的专用验证进程使用RemoteSigned，限定脚本路径/hash和生命周期；授权复用现有`M3-ISO-V02-008`工作区的已保存host证据，不覆盖旧证据；在新增resume证据子目录中完成绑定后启动一次新Sandbox、一次禁网隔离准备、一次离线pub及条件式一次M3。不改持久策略/组策略/信任/来源标记，不提权、不使用Bypass/Unrestricted，不下载，不写原仓库或宿主SDK/cache，其余边界不变。

无批准只报告`WAITING OWNER ACTIVATION`。批准只限本任务，不自动续期未来任务。

## 2. 固定GitHub入口

仓库`zcx369658780/EliteSync-v10`。开始实时读取main，必须为A=`16225ef1db6063dacadd3bfc8b033b325c11d5df`。
FIRST主动读取A中的`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob=`18485c95262051e43892436fb52413132c5ee626`。历史startup不执行。
随后核验本任务ref/commit/blob、唯一父A、单文件新增范围；失配停止依赖动作，不自行换基线。

其他仓库只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` blob `5ef59aa9e6ad12b03ad34ab335b461fa68bbe5c9`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_7.md` blob `cf7b9f29cc0b0ed81a764239fdf17a34eeb86e33`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md` blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`。
- `docs/architecture/ELITESYNC_V10_M3_CMD_DISPATCH_REPAIR_RESULT_V0_1.md` blob `d1b0fd080665df717b237de44ad47b6285289ace`。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516`及`apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。
可读取A的tree-repair commit消息及146d6e9e/940d8870元数据解释权威修复；不得由此扩大历史读取。

旧task `8262bc...`仅作为已停止的错误固定入口记录，不执行、不恢复其GitHub输出。README/FD02/旧仓库/仓库枚举继续禁止。必要固定对象fetch只到声明ref，不status/index/checkout/pull/reset/stash/clean。

## 3. 复用现有008，不覆盖旧证据

固定工作区W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。本任务明确允许W已存在；禁止删除、清空、覆盖或换号规避。新增续行证据仅写`W/evidence/resume-r1/`及必要的新冻结runner副本；已有`result.json`、`host-dispatch-selftest-1.json`、`script-preflight.json`、`host.log`只读。

首先定点检查W及祖先没有未授权reparse跳转，并读取上述四个精确证据文件；不得列目录发现其他文件。记录每个文件当前SHA-256、长度及解析状态。检查旧result明确分类为`FIXED MAIN SNAPSHOT INPUT MISMATCH`或等价停止状态，且Sandbox/pub/M3均未启动；host结果必须记录普通exe 4/4、batch 6/6、exit37传播、override false/true；脚本preflight必须把最终dispatch绑定到SHA-256 `2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。如果这些事实无法从保存证据绑定，停止续行并报告`008 LOCAL EVIDENCE BINDING INCOMPLETE`，不得重跑host来自行补齐。

只读核验007四个来源首尾hash仍与007报告一致；只读核验W/scripts/dispatch.ps1主体hash为上述2C0A值。copy/host-selftest/guest脚本可按已有008 preflight精确路径读取hash及AST，不重新开发。若guest仍是进入Sandbox前未冻结草稿，可仅将已验证dispatch开关修复接入guest调用点并做AST/静态参数绑定检查；不得因此重复host 4+6测试。任何脚本字节变化均生成新hash、记录diff，并在guest启动前冻结；dispatch逻辑除显式override语义外不重写。

## 4. 运行条件与guest前置

只有§1获批后执行。本任务专用PowerShell仍为System32 Windows PowerShell 5.1、普通用户，使用`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command <bounded bootstrap>`。不Set-ExecutionPolicy、不改持久scope。正常导入Security模块并核对Name/精确Path；要求本次Process/effective=RemoteSigned。真实管理/签名/应用控制拒绝即停止，不绕行。

已有host PASS不重跑。启动Sandbox前只做：现有host证据绑定、最终脚本AST、hash/部署一致性、m3.wsb/XML映射与guest bootstrap静态核验。若需要验证`UseSerializedArguments`是否在guest调用点正确：只做AST/源码结构检查，确认普通Git/Java调用不传switch，RunBatch明确传switch；不另启一轮host回归。

## 5. Sandbox、guest冒烟、复制和工具验证

一次新Sandbox；沿用007已验证隔离合同：Networking/Clipboard/Audio/Video/Printer/VGpu Disable，八个宿主输入ReadOnly=true，唯一可写宿主映射为W/evidence/resume-r1到guest证据目录。新nonce、实际guest Process/effective=RemoteSigned、活动网卡0、默认路由空必须为本次实测；不ping/DNS/HTTP。

guest先加载与host证据所绑定的同一dispatch实现字节。复制真实工具前执行两类无害冒烟：
1. 批处理pub/M3形状及exit37；
2. 普通exe参数形状，确认override_present=false且参数实际进入OS。
两类PASS后才复制。

固定A模块对象仍机械物化526文件、defines按允许三源重新定点解析；若仍EMPTY则0个追加参数。八项输入及robocopy参数沿007/v0.5已验证合同，不重做算法研究。复制后真实运行Git `--version`、Java `-version`各一次；必须记录函数收到参数、override_present=false、最终Arguments字符串、actual executable、stdout/stderr及exit。Git/Java任一失败即停止pub并按真实错误分类，不重找Git/JDK。

## 6. 真实pub、M3和AAR

Git/Java验证成功后，guest cwd固定`C:/M3/w/apps/flutter_elitesync_module`：
- `C:/M3/t/f/bin/flutter.bat pub get --offline`至多一次，10分钟。
- 仅pub成功后，`flutter.bat build aar --no-debug --no-profile --no-pub`加绑定defines数组至多一次，30分钟。
统一使用已绑定RunBatch/RunNative，不另造调用字符串。真实entry与dispatch分开记录；非零不能自动归为缺包。只有真实依赖诊断支持时才写OFFLINE_PUB_INSUFFICIENT。不联网、下载、安装、改Wrapper/SDK/产品源码或重试。

仅M3实际启动后一次检查精确AAR：`C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。HIT记录size/SHA-256；未启动保持NOT_CHECKED；不搜替代。M2不执行。

进程和Job/timeout/正常Sandbox关闭沿007合同。完成或失败均保存本任务进程结束证据；不得按名字杀其他会话。

## 7. 结果、GitHub候选和CURRENT_CONTEXT

本地新证据仅写resume-r1，旧008证据保持首尾hash不变。报告必须区分：旧008因main树失配停止、旧host自测PASS、tree-repair权威修复、本次resume的新Sandbox/guest/复制/真实工具/pub/M3证据。不能把旧host PASS改写成本轮重新执行。

候选分支`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-8-r1`；一个commit，唯一父本任务commit，恰好两路径：
1. 新增`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R1.md`。
2. 更新`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

报告返回tree-repair main、旧008本地证据hash、最终脚本hash、guest两类冒烟、八项复制、Git/Java、pub/M3/AAR、生命周期和证据限制。发布后一次核验parent/两路径/blob。执行者不自我接受、不更新main、不M2、不改AGENTS或项目源。

## 8. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36和产品实现边界保持。除本任务获批后的专用RemoteSigned外，不改系统策略/信任/安全控制；无下载、真实数据或生产访问；原仓库内容、宿主SDK/cache及用户配置不写。