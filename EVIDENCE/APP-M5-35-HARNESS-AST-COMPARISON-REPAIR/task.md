# APP-M5-35-HARNESS-AST-COMPARISON-REPAIR

ISSUED；LEVEL2 SOURCE-ONLY；明确交最新Codex01a0f1ec-ff46-7311-a52f-780a64e3d4fb，local/D:\EliteSync-v10，派发前3次启动沿用。旧01a0f0b9停用。
main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；185条既有status保留。M5-34 REJECT AS EXECUTABLE VALIDATION HARNESS/CLOSED，A/B各1/1关闭；全部旧预算关闭，未执行任何Python/checker/launcher/算法。两原算法source继续完全冻结，Sol/high只读NO_FINDINGS不替代测试。
仅新增本目录check_frozen_sources.py、Invoke-FrozenAarValidation.ps1、summary.md。完整继承M5-34 task的固定harness规格与禁止项；不改旧候选、旧summary/证据、authority、原算法source或SDK。

## 唯一最小修复
1. checker的shape/same不可把赋值Store与表达式Load直接比较。建议专门目标结构helper：Name.id/ctx Store、Subscript(sys.modules、准确key、ctx Store)，准确检查sys.modules登记、suite/outcome绑定；表达式same保留严格Load形状。也允许仅比较副本归一ctx，但必须另核原赋值目标Store，不修改被审source的AST/文件，不降掉唯一登记/准确对象/顺序/loader/退出门。
2. spec_from_file_location路径不可经过两次非raw字符串解析。建议直接核Call/dotted func+恰好2参数/无kwargs及两个Constant.value精确值；固定模块aar_entry_materials，路径D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py。special-host和loader两处必须一致，或安全内层raw/正确repr固定字符串。保留精确路径，不能只查函数名/后缀或删除门。
3. 新launcher仅将固定checkerPath从M5-34目录指向本M5-35目录新checker；其它launcher逻辑/参数/hash门/输出/timeout/raw BaseStream/cleanup/至多一次进程完全保持。原源码候选与旧harness完全保留，修复用新目录。
不增加新特性/新的宽泛拒绝规则，不删除旧AST/原材料/预期bytes/方法/准确load/runner门。保留launcher显式Static/Test与CheckerSha256、固定Python/cwd/两原source/hash、receiver-aware授权unittest runner、32768 raw bytes双流/60秒bounded cleanup与精确失败回执。依原任务，Test需Work先核Static原回执；本任务两个mode均不可执行。

## 新A/B各0/1，无运行预算
A一次准确来源只读：M5-34 checker（18304 bytes，6427B8EA143C8DD39BEA248A040E3C2FAEE48D745990FA4E7F9C117D2E4B15B4）、M5-34 launcher（8091 bytes，DCE5752BED51E3C710338024DD852306921CEB47D26C3DFFB52355D62AC7F574）、原test_aar_entry_materials.py（74376 bytes，F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2）；各普通非reparse≤128KiB、总≤128KiB，各ReadAllBytes一次/hash/大小门。仅回显三身份行和总量、旧两script文本（合计26395 bytes），原test正文不回显；主动UTF8总输出≤32KiB，每身份≤512 bytes、正文只两script，不加整task/summary全文。若确因编码额外开销超限，则旧launcher不回显而只身份，任务已给唯一单路径修正；不能改读取选择重跑。hash/大小/链接失败即停。authority/本task/M5-34 task/summary/work-review可正常只读入口读取，不SDK/来源三回执/旧session日志。
A成功后按三项最小修复保存新script。B一次最终两新script各ReadAllBytes/hash，checker≤32KiB、launcher≤16KiB，普通非reparse门；PowerShell只对内存launcher调用Parser.ParseInput，Python语法/AST子进程仍0。不import/checker/launcher/测试。核定成功后两script冻结；失败不修复重跑，B后不修改。summary准确原回执/两个最终hash/最小diff说明/已跑文本门/未跑限制，停Work独立LEVEL2，不自接受/后继。SOURCE-ONLY接受后由Work另立新精确执行预算，本task不授任何运行。

Python/AST/生产/测试fixture/scratch/launcher/监控试跑/SDK/Gradle/Flutter/JVM/ADB/构建安装启动均预算0。保留185既有dirty/untracked；不commit/pull/push/reset/clean/stash、旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/metadata/properties、目录索引搜索/下载复制/UAC。两原生产hash B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7、test hash如上绝不改。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及账号/Conversation/恢复/UAC门保持；source-only不证明真实兼容/恢复/OS隔离。