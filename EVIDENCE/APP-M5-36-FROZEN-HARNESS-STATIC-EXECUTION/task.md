# APP-M5-36-FROZEN-HARNESS-STATIC-EXECUTION
ISSUED — LEVEL 2；明确交最新Codex 01a0f1ec-ff46-7311-a52f-780a64e3d4fb，local/D:\EliteSync-v10；四次启动沿用。旧01a0f0b9停用。
M5-35 Work独立ACCEPT/CLOSED SOURCE-ONLY，见其work-review.md。所有旧预算关闭，本任务是新的独立静态验证授权。
main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；186既有dirty/untracked全保留。

## 固定来源和唯一交付
只写 D:\EliteSync-v10\EVIDENCE\APP-M5-36-FROZEN-HARNESS-STATIC-EXECUTION\summary.md。
只读authority、本task、M5-35 task/summary/work-review及以下精确冻结script/source，不改任何源码/script或其它文件。
launcher D:\EliteSync-v10\EVIDENCE\APP-M5-35-HARNESS-AST-COMPARISON-REPAIR\Invoke-FrozenAarValidation.ps1
8089 bytes SHA256 7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E。
checker 同目录check_frozen_sources.py，19323 bytes SHA256 D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A。
production D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py，20338 bytes SHA256 B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7。
test 同tools目录test_aar_entry_materials.py，74376 bytes SHA256 F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2。

## 唯一新执行预算 0/1
一次静态执行链；在第一次预检/调用前记1/1。链中任何门失败/编排错误/非零/timeout/超输出即停，不修复、不重复、不以Python未启动保留预算。
PowerShell host精确 C:\Program Files\PowerShell\7\pwsh.exe，NoProfile、cwd D:\EliteSync-v10。先在此同一链核launcher普通非reparse、8089 bytes及SHA256，各ReadAllBytes一次；失配立即停，不能调用。
门通过后仅调用上述固定launcher：
& 'D:\EliteSync-v10\EVIDENCE\APP-M5-35-HARNESS-AST-COMPARISON-REPAIR\Invoke-FrozenAarValidation.ps1' -Mode Static -CheckerSha256 'D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A'
不得生成临时checker/launcher、额外Python命令或修改参数。工具shell可直接指定该pwsh及login=false，避免额外包装进程。
launcher固定Python C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe，至多一次child start，-I -B 固定checker。
明确授权launcher执行其固定文件门并只读checker及production/test hash；checker只读两source作AST、人工字节/结构比对，不import/执行两source或测试。launcher gate每文件一次读取、checker分别一次读取，属于不同阶段已授权读取；不要误作全链每文件只能一次。
launcher双流各32768 raw bytes、59秒执行窗口/60秒cleanup观察逻辑完全保留；工具可yield返回session后仅poll同一执行，不能重新调用。OS硬截止/隔离保证尚未建立，不能宣称。
保存同次完整原tool回执与完整JSON：Mode/Failure/Exit/ChildExit/ElapsedSeconds/Timeout/OutputLimitExceeded/StartCount/StartAttemptCount/CleanupObservedExit/双流raw bytes/text/base64。工具截断时只恢复同次输出，不重跑。记录launcher身份预检结果、预算、实际Python启动数和所有未跑阶段。JSON或原输出缺失记UNKNOWN，不虚构PASS。
仅候选Static PASS：tool exit0、Mode Static、Failure null、Exit和ChildExit0、Timeout/OutputLimitExceeded false、StartCount/StartAttemptCount1、完整checker stdout；Work独立核原回执后才接受。不得自接受或自动执行Test。
Test/算法fixture/scratch/monitor试跑及SDK/Gradle/Flutter/JVM/ADB/构建安装启动预算0。本任务只保存静态summary后停Work LEVEL2，失败也保存准确首阻塞。

## 保护门
不commit/pull/push/reset/clean/stash，不访问旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/metadata/properties，不目录索引/搜索/下载复制或UAC。固定Python执行文件位置仅作为已明确授权解释器，非home枚举/配置读取权限。
原两source、M5-35及全部旧candidate完全冻结；新任务不续旧预算。
M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及真实账号/Conversation/恢复门保持；静态PASS不证明算法行为、真实兼容、恢复、OS隔离或生产就绪。可能UAC时触发前停，等待当前Work Owner“我在”与具体授权。