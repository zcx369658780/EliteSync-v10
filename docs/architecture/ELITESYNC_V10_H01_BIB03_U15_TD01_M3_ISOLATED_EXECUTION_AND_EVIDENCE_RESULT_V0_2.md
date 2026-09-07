# EliteSync v10｜M3 离线隔离执行与证据结果 v0.2

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — GIT INSTALLATION ROOT UNRESOLVED**。
Attempt：M3-ISO-V02-002。日期：2026-09-07。本轮已安全创建自有证据；源码物化、Sandbox、pub、M3均未启动，AAR保持NOT_CHECKED。

主因是任务§3规定的一次Git定位未能闭合可只读映射的安装根：定位后的cmd/bin结构守卫报错，且执行脚本未在守卫前保存定位返回路径。这是本轮绑定证据缺口，不能升级成“Git缺失”“Git不可用”或“实际安装结构一定不符合”的结论。没有再次定位、扫描或猜根；按任务停止依赖步骤。

## 1. 固定入口与来源层级

| 对象 | 本轮证据 |
| --- | --- |
| 实时main | a3736a0d4790fe5fcc01d27a4a8edf06f9162917，匹配 |
| FIRST转型交接 | blob 18485c95262051e43892436fb52413132c5ee626，匹配；未恢复历史startup |
| task ref | task/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-2 → 783efb322a3b390c7f0744ba89d5c3b1e7543fe2 |
| task blob | d158003332c7f3c06f689eb970b18b167dfeba96，匹配 |
| task sole parent | a3736a0d4790fe5fcc01d27a4a8edf06f9162917；仅新增任务单，ahead=1、behind=0 |
| task tree | 0acef8e072b60def1f07e40647d22bdf695c0672 |
| AGENTS | f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1，固定main核验匹配 |
| CURRENT_CONTEXT输入 | ca1dba577e447a652173f2f3f35c1587fdc0b074，匹配 |
| build.gradle.kts合同 | a7e0f7583c801e2d56afc595d6c7bed84b5ce516，匹配；仅采用direct AAR/defines相关部分 |
| 固定项目gradle.properties | f0a2e55f89e383466d2c6b481c8c468a3aa0b13d，匹配；无flutterDartDefines键 |
| 本地root / origin | D:/EliteSync-v10；git@github.com:zcx369658780/EliteSync-v10.git |
| local HEAD，仅上下文 | d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88；未切换，未用作源码快照 |

Owner选项1批准继续有效。任务§1提供的Sandbox Enabled、Android/JDK/Gradle路径及旧版本信息均为OWNER-SUPPLIED HOST EVIDENCE；本轮没有Get-WindowsOptionalFeature/DISM、RunAs、提权、功能启用或方法再研究。
001是已接受历史结果；002是新合同。没有倒写001，也未将旧工程Wrapper 8.14设置为本次版本。

## 2. 自有证据与精确输入结果

身份门通过后检查D:\的reparse属性及专用根精确存在性。根不存在；通过Windows CreateDirectory独占创建成功，建立input/evidence并立即初始化result.json和host.log。无ROOT CONFLICT，无删除、覆盖或换名绕过。

下列字面路径和祖先均完成reparse检查，没有沿跳转读取；仅目录/文件类型检查，没有cache目录内容分析：

| 输入 | 具名路径与结果 |
| --- | --- |
| Flutter SDK | D:\flutter，目录存在；bin\flutter.bat及bin\cache\dart-sdk\bin\dart.exe为文件 |
| Android SDK | C:\Users\zcxve\AppData\Local\Android\Sdk，目录存在 |
| JDK | C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot，目录存在；bin\java.exe为文件 |
| pub seed | C:\Users\zcxve\AppData\Local\Pub\Cache，目录存在；来源为任务展开的上轮默认路径，不冒称Owner本轮实测 |
| Gradle caches | D:\GradleHome\caches，目录存在 |
| wrapper seed | D:\GradleHome\wrapper\dists，目录存在 |
| Git安装根 | 未确认；一次Get-Command git.exe后结构守卫失败，详情见§3 |
| defines | D:\GradleHome\gradle.properties同名键、固定项目同名键、当前ORG_GRADLE_PROJECT_flutterDartDefines均无值；按.orEmpty()得到EMPTY，0项、无键名 |

未回退旧默认.gradle、未扫描版本、未运行宿主Java或任何构建工具。目录存在不是依赖充分性、版本兼容性或可运行性的证据。
用户属性只机械提取flutterDartDefines键；未输出其他本地属性、凭据或敏感值。没有完整参数值进入GitHub报告。
计划中的pub调用数组为Flutter pub/get/--offline，M3为Flutter build/aar/--no-debug/--no-profile/--no-pub；本轮没有形成或执行guest运行合同，不能把计划数组写成实际调用。

## 3. Git绑定阶段的准确异常与限制

执行的一次定位和紧随其后的守卫逻辑：
```powershell
$taskGit=(Get-Command git.exe -CommandType Application -ErrorAction Stop).Source
if ($taskGit -notmatch '\\(?:cmd|bin)\\git\.exe$') {
    throw 'GIT ROOT STRUCTURE UNRESOLVED'
}
```

工具结果记录脚本exit=1及异常GIT ROOT STRUCTURE UNRESOLVED。定位返回值没有在该守卫之前输出或落盘；安装根推导、git-root.txt写入及后续固定commit本地可用性查询都没有到达。

因此证据仅支持“本轮未确认允许的Git安装根”。不能判定究竟是单一路径结构、多返回值处理，还是其他定位结果形态导致守卫失败；更不能从这个异常推断Git本身坏了。执行器没有保存关键中间结果是报告必须保留的限制。

本轮早先Git元数据命令成功只证明宿主相应命令可执行，不证明已取得可复制到客体的完整Git发行根。任务§3规定定位一次且结构不能明确不猜根，本轮没有第二次Get-Command或其他路径搜索来弥补。

另有一次functions编排JavaScript字符串语法错误发生在宿主命令派发前，未执行任何文件/进程动作；修正字符串后才完成唯一的独占根创建。这不消耗pub/M3/Sandbox预算，不隐瞒为成功检查。

## 4. 真实阶段与隔离证据

| 阶段 | 实际状态 |
| --- | --- |
| 身份/main/task/blob门 | PASS |
| 专用根安全创建/自有证据初始化 | PASS |
| 六个具名工具/seed根及指定可执行文件元数据 | PASS，仅存在性与无reparse祖先 |
| Git可映射安装根 | UNRESOLVED，前置停止 |
| 固定Git对象的过滤模块输入 | NOT MATERIALIZED；未archive/fetch/解包/复制，不含旧产物的性质也未形成实测 |
| manifest / m3.wsb / guest脚本 | 未生成，未启动后修改合同 |
| Owner Sandbox功能状态 | Enabled，Owner提供 |
| 本轮Sandbox启动 | 0次；没有启动失败或Disabled的实测结论 |
| XML禁网/只读映射控制核验 | NOT PERFORMED，无配置文件 |
| 同次nonce/guest接口/默认路由 | NOT AVAILABLE，无guest运行；不宣称实际隔离通过 |
| guest java -version | 0次，版本未实测 |
| Flutter-aware offline pub | 未启动，0次，exit=null，无超时 |
| release-only M3 | 未启动，0次，exit=null，无超时 |
| exact AAR探测 | 0次，NOT_CHECKED；不是NON-HIT |
| AAR size/SHA-256/复制 | null/null/未复制 |
| M2条件 | 未获得新生成产物证据，仍deferred，不执行M2 |

没有COMMAND SUCCESS，也没有EXACT AAR HIT，不能记录M3 GENERATION + RELEASE-AAR PRODUCTION EVIDENCE = HIT FOR M3-ISO-V02-002。前置脚本exit=1不是M3 exit code。本结果不是离线缺包、构建失败或Sandbox功能不可用。

## 5. 已保存的本地证据

Evidence root：`D:EliteSync-M3-readiness-v02evidence`，已创建并保留。

| 自有文件 | SHA-256 |
| --- | --- |
| M3-ISO-V02-002-result.json | 67067707728C779AB89047D1A6C53DA9E5DE75A06582F2A150F98B8ED1B3E2F7 |
| M3-ISO-V02-002-host.log | D7ED460EB9D32C0C77D288756D44D13A18A8DD08FBDB70B39DE97E6BE31C40B5 |

JSON已记录terminal=true、真实阶段、Owner功能证据、各计数、pub/m3未启动与exit=null、aar_result=NOT_CHECKED、local HEAD及defines来源/计数。host.log保存初始化、路径检查摘要、Git守卫异常和未执行阶段。
没有guest.log、配置/manifest哈希或maven-repo，因为对应阶段未到达；不伪造空guest运行证据。Git返回路径未保存的缺口见§3。以上文件在终态写入后一次计算哈希；未上传日志、源码或二进制。
专用根现在属于本次保留状态，后续任务不能把它当作不存在、擅自清理或复用。原仓库内容、宿主SDK/cache和用户配置未写；默认index/受保护staged state未接触。

## 6. 最小剩余问题与结束边界

最小缺口是一次可审计的现有Git完整安装根绑定：若后续另有精确授权，应直接绑定明确路径，或允许保存单个Application定位结果后再校验结构。无需重复批准选项1、重新研究离线方案或把管理员功能查询加回门槛。本轮不续发任务、不重试002；下一合同还须明确处理已存在的专用根，不能靠删除让本轮继续。

候选只新增本报告并更新CURRENT_CONTEXT指定部分；§2/§3/§6/§7原文保留。001历史失败、Owner补充和002结果分开。候选待独立审查，不自我接受、不更新main、不执行/下发M2、不更新ChatGPT项目源。
旧M1 lane、M2 deferred、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend 0/10、Database 0/8、PUI及LC-03/LC-04/Phase36/产品实现边界不变。没有README/FD02/旧仓库访问、源码额外分析、依赖下载或真实数据活动。
Owner声明宿主选择GPT-6 Astra；可见身份为基于GPT-6的Codex，未独立读取model ID或完整加载链，未改配置、未调用辅助代理，不宣称整仓clean或自动重载。发表后停止。
