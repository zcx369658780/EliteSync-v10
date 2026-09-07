# EliteSync v10｜长路径复制修复与M3隔离结果 v0.4

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — HOST SELFTEST SCRIPT POLICY**。
004在宿主合成自测的脚本加载阶段受阻；复制器尚未被执行验证，不能宣布长路径问题已修复。Sandbox、pub和M3均未启动；exact AAR为NOT_CHECKED，不是NON-HIT或M3命令失败。

Attempt：M3-ISO-V02-004；日期：2026-09-08（Asia/Shanghai）。

## 1. 固定入口与已接受历史

实时main A为89d1f091d45b472bd286628942181d7a3647d0c2。FIRST主动读取转型交接，blob 18485c95262051e43892436fb52413132c5ee626匹配。
task/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-4指向a3a149aa83b0cf841e4a3f0d5dca3d48bbe7dfe9（T）；任务blob cb46cea5c9c5610d1771d96448c955d58c5218bb。T唯一父A，相对A仅新增该任务单，ahead=1、behind=0；tree 913f282fd3ce9dc05c62d61da1f92543d7ff9f24。

A中的AGENTS、CURRENT_CONTEXT、003结果、v0.3任务分别核验为f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1、4cc13077cae6cfc0e87f6b68306ff08618b2d1c5、0a814b8ae92497f4927d6aea13cba74bec6c0d6d、01dc74cb1b4cfd6d11b79a61a00e1a44b52f7d75。未跟进引用。由于宿主自测未通过，尚未读取两个Android合同输入、解析defines或物化模块；这不是输入缺失或hash冲突。

003候选99730a363a44c2010ed5fd4361cced0484d9a45d已由A接受为有限执行记录。003的Git绑定和当次隔离控制不自动成为004实测；003复制长路径失败的具体源/目标仍未知，不猜测恢复，不倒写旧报告。
Owner选项1批准继续有效，本轮没有重新申请、重做Git发现或方法研究。

本地HEAD只读结果为d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88，仅作上下文。未fetch、切换或同步本地仓库；未读取默认index或运行git status。

## 2. 历史保护与独立工作区

批准父根D:/EliteSync-M3-readiness-v02及指定祖先、002/003 evidence目录和指定文件通过定点reparse守卫。004路径开始时不存在，独占创建：
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004`。
仅在其中创建input、scripts、scratch、evidence及本轮自有文件；没有ROOT CONFLICT，没有删除旧根、复用003 input或客体副本。

002的result.json、host.log和003的result.json、guest.log、git-binding.json、frozen-contract.json、isolation-control.json、sandbox-launch.json共八份指定证据，开始和结束哈希均匹配任务/003报告。002/003 terminal=true且pub/M3均未启动。记录见本轮old-evidence-preservation.json；八个路径及开始匹配、结束实际hash均已保存。旧文件未写。

从已核验003 git-binding.json采用选中入口C:/Program Files/Git/cmd/git.exe及完整发行根C:/Program Files/Git。该记录sourceCount=4、rounds=1，宿主历史版本2.53.0.windows.1、exec-path C:/Program Files/Git/mingw64/libexec/git-core。本轮Git发现及自描述查询均为0次；只用绑定exe读取HEAD，未猜测复原旧报告中其他原始路径。其余具名根没有进行本次安全/可读性复测或复制，不能报本次工具/cache前置通过。

003启动记录已读取；004未到达Sandbox启动阶段，没有查询、关闭或终止旧窗口，也不声明旧窗口当前已关闭。

## 3. 宿主自测的实际错误

编写自有helper：
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/scripts/copy.ps1`。

该草稿拟用Win32 Unicode扩展路径API创建/读取合成样本和识别reparse，用robocopy基准参数、原生摘要及独立copy_id日志判断结果，并设置deadline。**这些是未验证实现，不是复制合同已通过或已冻结的证据**；未形成可供本轮客体执行的冻结配置。

唯一实际自测启动尝试使用C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe，参数-NoProfile -NonInteractive -Command，先加载上述helper再调用合成测试。包装进程exit=1。脚本加载错误为：

> File D:\\EliteSync-M3-readiness-v02\\attempts\\M3-ISO-V02-004\\scripts\\copy.ps1 cannot be loaded because running scripts is disabled on this system.

异常类别PSSecurityException，FullyQualifiedErrorId=UnauthorizedAccess。随后Invoke-M3SelfTest未识别是helper加载失败的后果，不是第二次测试或复制器输出。
明确错误路径为上述copy.ps1；操作为PowerShell脚本加载，非长路径创建或真实seed复制。启动参数、错误类别、具体路径和长度已保存于host-selftest-load-error.json。未取得可归属的native Win32错误码，记录null及原因；未查询策略scope，不能归因于某项组策略或持久配置。

任务§4写明“不提权、不改宿主或客体系统策略”。本轮在实际脚本加载权限错误后停止依赖步骤，没有更改执行策略、换加载机制绕行或重试。该事实并不证明robocopy不支持长路径或工具安装损坏。
自测修复轮次=0；长源/长目标/中文空格、缺失源错误记录、0/1/7/8/16分类及内容hash测试全部NOT_EXECUTED。没有合成复制文件或原生copy日志；本轮不能以静态代码存在宣称任何测试PASS。

## 4. 真实阶段与预算

| 阶段 | 本轮实际结果 |
| --- | --- |
| 固定入口/task拓扑 | 匹配 |
| 002/003保护 | 开始/结束8/8哈希匹配 |
| 004工作区 | 独占创建；证据已初始化和保存 |
| 宿主自测启动 | 1次包装进程；exit=1，helper加载被拒 |
| robocopy / 合成自测 | 0次；native exit=null；NOT_EXECUTED |
| 固定源码输入/defines | 未到达；未物化/未解析 |
| 真实工具/seed安全检查及复制 | 未到达；0个copy_id启动 |
| 冻结合同/WSB | 未生成、未冻结 |
| Sandbox | 0次；Owner Enabled仍仅来源声明，本次隔离未验证 |
| guest自测/Git/Java | 均0次 |
| offline pub | 0次；started=false，exit=null |
| release-only M3 | 0次；started=false，exit=null |
| exact AAR | 0次probe；NOT_CHECKED；size/SHA-256=null |
| Maven repo导出 | 未执行 |
| M2 | 未具备新增AAR证据条件；deferred，未执行 |

自测包装调用约1.14秒即退出；没有活跃004复制或构建子进程，也没有进入30分钟客体准备计时。不是PREPARATION TIMEOUT，没有以pub/M3未启动为由无限等待。未启动客体，因此无004 nonce、接口/路由证据；不得沿用003的隔离结果。

## 5. 本地保存与序列化

evidence根：
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/evidence`。

| 已保存文件（相对此根） | SHA-256 |
| --- | --- |
| result.json | AB185A357E52FF7A3C34B85AB6D782781CF16C5CCF4DA6D86DBBDDE3242B788B |
| host.log | F9CB80913EBEC62D8FDA3615CA5683E69D36EB2888B4C3D46E111BC82F57D34B |
| host-selftest-load-error.json | 2BC28481AA519A77ABAC8ABA98D70162CFB95728A127A453A0ADB26061C9EA75 |
| old-evidence-preservation.json | 75F9C41C3D635506C5D7530807953354E50EAD357EE52379EC71296EF57739EC |

final-evidence-hashes.json保存上述摘要及未验证helper的SHA-256 9177A1B3A713F1414E6846BCACAD77773CEFE19E24E5FBB81FC81E9A9C397CCD。host.log只追加；result.json保存terminal=true和真实阶段。JSON由序列化器写入，错误路径和evidence绝对路径已round-trip等值验证；报告路径采用盘符正斜杠。异常引用中反斜杠保持字面含义。

guest.log、原生copy日志、自测内容/hash结果、source manifest、冻结配置、004控制记录、pub/M3日志均未生成；原因是相应阶段未启动，不创建假日志充数。本地日志、helper、源码、cache或AAR不上传GitHub。没有删除失败状态。

## 6. 剩余具体障碍与边界

当前新增证据是宿主Windows PowerShell拒绝加载自有helper，尚未验证其长路径复制能力。最小未决项是该精确helper的合法可执行加载条件与本任务禁止策略修改的边界如何兼容；执行策略实际scope未检查。本轮不建议开放网络、重找Git、重新批准选项1或再发仅改编号的全量复制任务。复制、离线输入充分性及M3生产证据仍未知，不宣称已完成复制修复。

§2/§3/§6/§7 CURRENT_CONTEXT原文保留；仅更新页首/§1/§4/§5状态。M1耗尽lane、M2 deferred、D-02/U-14/U-12/TP、Backend 0/10、Database 0/8、PUI、legal/Safety/no-processing、LC-03/LC-04/Phase36和产品实现边界保持。未访问README/FD02或旧仓库；未写原仓库、SDK/cache或用户配置，未安装、提权或修改模型配置。

Owner声明宿主选择GPT-6 Astra；可见身份为基于GPT-6的Codex，未额外读取运行model ID/完整加载链，未启动辅助代理。不宣称整仓clean或本轮自动重载。

本候选唯一父T，只含本报告与CURRENT_CONTEXT两路径。发布即停止，待独立审查；不自我接受、不推进main、不M2、不新任务、不更新ChatGPT项目源。
