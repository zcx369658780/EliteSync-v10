# APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS
ISSUED — LEVEL 2 SOURCE-ONLY；Work接管核定通过后明确交给最新Codex 01a0f1ec-ff46-7311-a52f-780a64e3d4fb，local/D:\EliteSync-v10，八次启动后沿用；旧01a0f0b9停用。
唯一实时仓库main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
接管191条status，交接前190成员缺0；六个冻结身份全匹配。M5-39独立ACCEPT/CLOSED SOURCE-ONLY、A/B各1/1关闭，13方法只是编写，Python/AST/import/compile/算法/测试全部NOT_CHECKED。所有旧budget关闭，不重跑或追认。M5/隔离构建NOT_READY。

## 唯一交付和精确写入范围
仅CreateNew新增本目录：check_applied_sources.py、Invoke-AppliedAarValidation.ps1、summary.md。
本task/status-entry由Work持有，Codex不得修改；不改任何authority、冻结source、依赖、旧harness/证据或SDK。交付路径存在即停。
主要结果为稳定验证harness源码候选；本任务所有执行预算0，先独立审查冻结harness，再另授Static；Static同次原回执接受后才另授Test，不能合并放行。

## Harness规格
新checker用Python标准库，未来只读准确新production/test及准确adapter依赖，核普通非reparse/严格UTF8/size/hash。用ast.parse静态检查两新源码，绝不import/exec/compile/runpy/eval执行被审源码，不执行adapter、fixture、算法或tests。ast.literal_eval仅可用于静态已核字面常量，非任意表达式，不动态搜索、sys.path变更或discovery。
完整检查新入口keyword-only、两frozen/slots类型、六步局部scratch/原hash绑定、plugin-deps保留、准确type预检、附件/原Invocation/四固定模型、不可变返回；静态结构证明和算法运行必须分开标记，不能声称算法PASS。循环/comprehension属授权纯内存源码，不用全文禁词误拒；receiver-aware拒绝危险调用，准确允许标准库hash、dataclass与纯内存操作。不得为通过检查删除保护门。
新test必须准确两loader顺序：aar_entry_materials -> aar_applied_materials，绝对路径；module_from_spec后先sys.modules准确key登记再exec_module。后者普通import已登记adapter；不得第三个loader/任意源、sys.path或discovery。常量路径直接核AST Constant.value，不通过二次非raw解析。赋值目标Store与表达式Load分别准确核，不能直接误比较ctx。
必须检查完整独立ORIGINALS/EXPECTED_CODE/EXPECTED_SCRATCH字面和M5-38已接受plan完整定义一致，不从production私有_CODE或实际函数回算expected。建议在来源A同次内存从plan附录完整字面提取并嵌入checker准确expected值或摘要；必须给确定性提取规则/完整身份及每组比较范围，不能只查常量名或长度。未来checker运行不再读取plan或旧receipt/SDK。
检查P1/P2完整config/返回oracle、完整bytes/Attachment/Invocation/四项目OWN表的独立结构及13准确方法名/数量、固定当前模块loadTestsFromModule、testsRun>0/wasSuccessful退出门。测试方法正文按结构检查，不能把13写有当13运行。
允许基于M5-35成熟checker结构，明确新源适配差异；不能原封执行旧checker代替新源验证。将无法可靠静态证明的项目标NOT_PROVEN并停审查，而非模糊放行。输出具名检查结果与准确源身份，不全文回显测试常量。
新launcher仅沿用M5-35已接受原生监控结构：Static/Test明确选择、CheckerSha256外部mandatory参数、固定Python C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe、cwd D:\EliteSync-v10、-I -B、每次至多一次Process.Start；checker path指本新目录，Test path指新test。
启动前核checker身份及三准确冻结Python source（adapter/newproduction/newtest）身份，不运行旧test。checker尺寸≤64KiB；新launcher≤20KiB。保留stdout/stderr各32768 raw bytes异步BaseStream、59秒执行/60秒含cleanup、固定失败标签、严格UTF8、原raw回执、StartCount/StartAttemptCount/ChildExit/timeout/output/cleanup；不Start-Process、不隐藏第二进程、不WaitForExit/ReadToEnd阻塞，不改全局策略/环境。单进程监控不宣称OS隔离或绝对硬截止。

## 来源A 新0/1
authority/本task/M5-39 task-summary-review/M5-35 task-review正常只读入口。A准确六来源各一次ReadAllBytes，普通非reparse、单件≤192KiB、总≤384KiB，核下列size/hash/严格UTF8；失败即停不补读重跑。正文在同次内存用于纯文本组织，不Python/AST/求值。
1 apps/android_synthetic_demo/tools/aar_applied_materials.py 6510 123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224
2 apps/android_synthetic_demo/tools/test_aar_applied_materials.py 72513 29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F
3 apps/android_synthetic_demo/tools/aar_entry_materials.py 20338 B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7
4 EVIDENCE/APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT/plan.md 137079 7DB003A4620EEE403A310192DAE2C7BEEAAE5F88AE8D7A5B8CE6D962F8FC34BD
5 EVIDENCE/APP-M5-35-HARNESS-AST-COMPARISON-REPAIR/check_frozen_sources.py 19323 D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A
6 EVIDENCE/APP-M5-35-HARNESS-AST-COMPARISON-REPAIR/Invoke-FrozenAarValidation.ps1 8089 7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E
输出仅六身份表≤4KiB与旧checker正文≤20KiB，总≤24KiB；其它正文禁止回显全文，至多选择新source关键结构≤8KiB并相应压减总量。不要先全文输出再截断。所有后续作者构造以同次内存；不追加来源读取/目录搜索/旧session日志读取。无法在该方式可靠构造则记录NOT_DELIVERED停门。

## 最终文本B 新0/1
保存两script后各一次ReadAllBytes，普通非reparse、checker≤64KiB/launcher≤20KiB、总≤84KiB，hash/严格UTF8与固定文本核定。只允许PowerShell标准库文本核定和对内存launcher Parser.ParseInput（非执行）。Python/AST/import/compile/launcher/checker/fixture/测试/monitor试跑预算0。
失败不修改/重跑；B后两script冻结。summary保存完整A/B同次原回执、最终两hash、13准确方法名、oracle转录规则与比较范围、旧新launcher差异、未证明项及所有运行NOT_CHECKED，不能复制整plan/source代替证据。
A/B各至多1/1，首失败或交付后停Work独立LEVEL2，不自接受、不派后继、不续旧预算。

## 保护门
保留全部191既有dirty/untracked，不reset/clean/stash/commit/pull/push、不访问旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/真实metadata/properties，不安装启动未知产物，不Gradle/Flutter/JVM/ADB/构建、不UAC。settings/v1全拒绝、loader/runtime false、M5/隔离构建NOT_READY及真实性/恢复/生产门保持。任何后续可能UAC，先等待当前Work Owner明确“我在”，另核具体授权预算。本轮无需UAC。