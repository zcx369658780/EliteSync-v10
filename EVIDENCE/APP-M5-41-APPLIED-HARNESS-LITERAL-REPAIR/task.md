# APP-M5-41-APPLIED-HARNESS-LITERAL-REPAIR
ISSUED — LEVEL2 SOURCE-ONLY；明确交最新Codex01a0f1ec-ff46-7311-a52f-780a64e3d4fb local/D:\EliteSync-v10，九次启动后idle/error=null沿用。旧01a0f0b9停用。
main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；发布前192条既有status保留。M5-40独立REJECT/CLOSED NOT_DELIVERED，A1/1成功关闭、B0/1未执行关闭；所有运行0及旧budget保持。
仅CreateNew新增本新目录check_applied_sources.py、Invoke-AppliedAarValidation.ps1、summary.md；存在即停。不改旧候选/authority/冻结source/旧证据/SDK。唯一交付是修复harness源码，先独立审查再另授Static/Test。

## 精确修复与不得放宽的门
完整继承M5-40 task规格及work-review，以下只修所列问题：
1 给safe_literal准确识别Constant(str).encode('utf-8')：Call.func为Attribute、receiver为type(value) is str的ast.Constant，attr恰encode，恰一Constant(str)参数值utf-8，无keywords；不得允许任意receiver、其他encoding、Name/动态参数、嵌套Call或任意求值。safe_literal递归容器继续保持原边界，不为oracle执行encode表达式或被审代码。oracle仍完整文本fingerprint核定，而非只查名称/长度。
2 call_gate test同样只额外准许上述准确literal encode形状；建议共用窄predicate，禁止通用任意.encode白名单。不改production授权调用域。
3 test pure builtin bare集合补zip，准确冻结source中对应完整方法fingerprint不变，不开放动态方法/discovery/host调用。
4 launcher checker maximum从32768对齐65536，与task checker≤64KiB一致；byteLimit stdout/stderr仍各32768，59/60秒监控不变。
5 新SOURCE_NOT_ORDINARY/SOURCE_SIZE/SOURCE_HASH加入固定失败标签名单，其余失败/cleanup/原raw回执结构不变。
6 launcher checkerPath准确指本M5-41新目录，其余固定Python/cwd/-I/-B/source/test路径及hash保持。
不得重做/修改ORACLE_DECLARATIONS、FROZEN_FUNCTION_TEXT、13方法名单或任何冻结目标hash。M5-40独立文字核20个完整function/method段与3oracle declaration均匹配；保留它们不是运行证明。不删除原AST结构/类型/六步/hash/不变bytes/附件/Invocation/四模型、Store/Load、两准确loader和sys.modules顺序、runner与testsRun>0/wasSuccessful门。除列明修复不得新增广泛禁词规则或其它功能。
不能执行任意Python、AST、import、compile、checker、launcher、fixture、测试或monitor，即使想预试修复；运行预算0。

## 新来源A 0/1
正常只读authority/本task/M5-40 task-summary-work-review。A准确三来源各一次ReadAllBytes，普通非reparse、单件≤96KiB、总≤128KiB、strict UTF8、size/hash：
EVIDENCE/APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS/check_applied_sources.py 26781 F9332560222DBF8B94920F48BECBB6C61AE12D8CE7C0F93E076DB0CB26656AA6
EVIDENCE/APP-M5-40-APPLIED-MATERIALS-VALIDATION-HARNESS/Invoke-AppliedAarValidation.ps1 9196 367149721F3411A73E66EF8D14011140C66B3C02881EFD684820EC8ED4524D41
apps/android_synthetic_demo/tools/test_aar_applied_materials.py 72513 29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F
总108490bytes。输出仅三身份≤3KiB与旧checker全文≤28KiB，总≤32KiB；其它正文不回显。可用同次内存纯文字组织/固定替换新script，不Python/parser/字面求值。不得补读source/旧日志/搜索目录；A失败首停，不补读重跑。

## 新最终B 0/1
保存两新script后各一次ReadAllBytes，普通非reparse、checker≤64KiB/launcher≤20KiB、总≤84KiB、strictUTF8/hash及固定修复文本核定；仅PowerShell标准库文本核定和内存launcher Parser.ParseInput，不执行launcher。
B失败不修改/重跑，B后script冻结。summary保存A/B同次原回执、最终两hash、精确diff范围、窄encode predicate/zip/launcher两槽和新路径、原manifest保持、未运行限制。A/B至多各1/1；首问题或交付后停Work独立LEVEL2，不自接受/后继。

## 冻结身份与保护门
新production6510/123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224，adapter20338/B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7，新test如上，绝不改。
保留全部192既有dirty/untracked和旧预算，不commit/pull/push/reset/clean/stash；不旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/真实metadata/properties、索引搜索/下载/未知安装启动/Gradle/Flutter/JVM/ADB/构建/UAC。
M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、13方法未运行及真实性/恢复/生产/UAC门保持。UAC前须当前Work Owner明确“我在”，另核具体授权预算。