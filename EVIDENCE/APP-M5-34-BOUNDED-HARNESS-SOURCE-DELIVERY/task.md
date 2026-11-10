# APP-M5-34-BOUNDED-HARNESS-SOURCE-DELIVERY

ISSUED，LEVEL2 SOURCE-ONLY；明确交最新已接管Codex 01a0f1ec-ff46-7311-a52f-780a64e3d4fb，local/D:\EliteSync-v10，派发前2次启动；旧01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad停用。
main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；184条既有status保留。
M5-29 ACCEPT/CLOSED DOCS-ONLY；M5-30/31/32 REJECT AS VERIFIED SOURCE CANDIDATE/CLOSED，全部旧来源/静态/测试预算关闭；M5-33 HARNESS NOT_DELIVERED/REJECT/CLOSED，A1/1失败/B未执行关闭，不恢复旧预算。M5-34不执行旧候选或新的harness；先保存完整可审查checker/launcher，独立接受后才另行授权执行。两原源码完全冻结，绝不修改来通过扫描器。

仅允许新增本目录三个文件：check_frozen_sources.py、Invoke-FrozenAarValidation.ps1、summary.md；候选主要结果是稳定验证harness，summary仅证据。禁止其它文件写入。

## 保存的checker（本任务不运行）
固定只读两source：D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py（20338 bytes，B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7）；test_aar_entry_materials.py（74376 bytes，F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2）。每source一次bytes入内存，hash/大小及普通非reparse gate，utf-8-sig/AST，不import/call生产或测试。checker只标准库，禁止任意路径参数/网络/env读取/任意import。输出具名CHECK status/清晰失败ID，不打印源码正文。
保留精确生产imports whitelist、无宿主操作、keyword-only参数/frozen tuple、精确测试加载路径及登记顺序、明确unittest loader/非零testsRun、四原fixture hash、独立EXPECTED_CODE/三完整EXPECTED_SCRATCH身份、12方法/P1P2整返回/scratch完整比较/负例结构门。这些是静态结构证明，不宣称形式化纯度或实际算法正确。fixture字符串/注释是数据，不全文禁词。生产与测试规则分别限定receiver：已授权unittest.TextTestRunner(verbosity=2).run(suite)必须被准确识别允许；不能对所有Attribute.run直接拒绝，也不能把所有run豁免。测试仅允许明确importlib精确加载生产源、sys.modules登记、unittest执行/退出以及纯内存操作；拒绝subprocess/os/network/自由文件读取/exec/eval/discovery/sys.path访问。Import whitelist与可执行AST节点检查结合；禁止发现其它方法名便随意加禁词集合。准确标准库exec_module只能用于固定已核生产源加载，避免无限自由允许。

## 保存的launcher（本任务不运行）
固定C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe、cwd D:\EliteSync-v10，UseShellExecute=false/CreateNoWindow=true/ArgumentList直接传参；不btoa/生成命令字符串执行/临时脚本/依赖安装。
仅两个显式Mode Static或Test，无默认Mode；另一必填参数CheckerSha256必须ASCII64hex，供未来Work任务传入接受后的准确checker hash。checker路径固定本目录check_frozen_sources.py，不由用户参数决定路径/命令。核python、checker、两原source普通非reparse/大小、固定source hash与提供checker hash，再启动至多一次子进程。Static参数-I -B 本目录checker；Test参数-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_entry_materials.py。Test模式未来只有Work确认Static原回执成功后另行明确派发；launcher不自判授权、不自动Static后Test、不重试/启动第二进程，不执行任何其它模式或SDK。
每次硬60秒，异步读取两个BaseStream原始byte块、各主动累计≤32768 bytes；超量/超时终止子进程且终止本次，不能无界WaitForExit或继续运行备用命令。确保进程退出后的pipe EOF也在deadline内；异常/failure cleanup无重试。原始双流在限额内完整保存于内存并回显或结构化返回（不写文件），byte数来自原始字节，最终UTF8解码严格/明确失败，不按字符块误计字节。返回exit/elapsed/timeout/limit/start_count，子进程非零不得被launcher exit0掩盖。hash/链接/启动异常failure不能称PASS。固定oracle手工预期hash来自M5-31原检查，不调用生产回算。

## 新预算，仅来源读取与文本核定，无运行预算
A：一次准确来源读取，派发前0/1：上述两冻结source、EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md（hash B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382）、EVIDENCE/APP-M5-31-FROZEN-AAR-MATERIALS-VALIDATION/static-original-checker.txt、EVIDENCE/APP-M5-32-AST-CHECKER-CORRECTION-FROZEN-VALIDATION/summary.md，各普通非reparse≤256KiB、总≤512KiB、各ReadAllBytes一次、固定source大小/hash和plan hash门。只用PowerShell/.NET文本/hash，不Python/AST进程。
输出唯一允许：五行SOURCE relative_path/bytes/hash（每行≤512 bytes），一行总byte与read_count，旧checker文本按UTF8原长度≤16384 bytes则完整回显，超过则只身份/标明BODY_OMITTED_SIZE_LIMIT。两原source、plan和summary正文全部不回显；禁止所有短行过滤/编号全源、JSON封装全文或追加source片段。预计总回显≤20KiB，主动累计≤32KiB仍保留，STATUS_AND_HASH优先。不需要向模型打印已审查fixture或plan正文才能编写harness：下面详细实现规格及已存checker提供结构，仅把旧checker作为文字参考（JS转义未展开、不可执行），全部路径/hash按本task重新明确写入新script，不复制模板转义当有效Python。
任何来源/hash/链接/大小或意外输出超限失败即停，不补读/修复重跑。没有来源内容输出的正文事实保持未回显，不称新的SDK事实。A成功才编写两新script；草稿期写作不运行脚本。authority/task/交接正常入口读取不耗此五来源预算；不可绕过本输出限制再读同一source正文。
B：一次最终harness文本核定，派发前0/1：两新script各一次读入内存/hash，Python checker≤32KiB、launcher≤16KiB；可对内存launcher使用System.Management.Automation.Language.Parser.ParseInput，不执行script。Python本任务不AST parse/compile/import/运行，语法保持待后继验证；通过字符串/内容只读检查不造Python语法PASS。PowerShell ParseInput失败或任一大小/哈希读取失败即停，不修复重跑。成功后两script冻结；summary保存准确大小/hash、来源A回执、B文本/PowerShell解析回执、已知限定/独立审查待办。草稿阶段可编辑，但B后不得再改script。本预算不授权“验证harness”运行。

Python/AST子进程、算法测试/fixture/scratch、launcher执行/子进程监控试跑、SDK/Gradle/Flutter/JVM/ADB/构建/安装/启动预算全部0。禁止执行两个新script、也不syntax smoke跑Python；不能把本任务自检当独立接受。完成或失败停Work LEVEL2，Work独立读完整harness并准确接受/拒绝，接受SOURCE-ONLY后另立新执行预算。
保留184条既有status；不commit/pull/push/reset/clean/stash、旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/真实metadata/properties/目录索引搜索/下载复制/构建安装启动/UAC。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、真实账号/Conversation/恢复门保持。人工静态/测试不能证明真实兼容/恢复/OS隔离。