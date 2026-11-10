# APP-M5-31｜冻结源码验证终止回执

2026-09-30；FROZEN SOURCE VALIDATION / STATIC FAIL / WORK LEVEL2 REVIEW PENDING。固定Python静态进程实际启动1次，source大小/hash均匹配，但内存检查脚本第78行AssertionError，exit1。测试NOT_CHECKED；按失败即停，无修复/重跑/源码修改，不自接受/派后继。M5/隔离构建NOT_READY。

唯一仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，会话01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad；入口181条dirty/untracked保留，authority及明确派发一致。M5-30仍REJECT AS VERIFIED SOURCE CANDIDATE/CLOSED，旧来源/失败静态/未执行测试预算均关闭；本轮是新的静态/测试预算，不沿用旧预算。唯一写本summary。

## 新静态1/1与两最终源码hash

固定executable C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe，存在普通非reparse门通过。两冻结source准确路径普通非reparse及字节门通过；ProcessStartInfo.ArgumentList逐项传入-I、-B、-c及内存检查脚本文本，WorkingDirectory D:\EliteSync-v10。无btoa、未知浏览器全局、临时脚本或依赖安装。

脚本每source读一次，hash/size门后以utf-8-sig解码、AST parse；没有import/执行生产或测试算法。静态代码包含imports/禁止宿主调用、keyword-only/frozen tuple、fixture/hash/独立expected、精确加载/登记/非零testsRun/方法数/覆盖检查，但完整脚本在第78行断言终止，不能把存在这些检查当作全部通过。

| 最终冻结source | bytes | 当前同次SHA256 |
| --- | ---: | --- |
| apps/android_synthetic_demo/tools/aar_entry_materials.py | 20338 | B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 |
| apps/android_synthetic_demo/tools/test_aar_entry_materials.py | 74376 | F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2 |

这是本轮静态读取核定的完整文件hash，不是M5-29片段hash。所有source保持完全冻结，失败后没有再读源码补查或修复。

## 同次完整原回执

工具chunk8565e8，命令工具exit1，墙钟0.3477012秒。子进程监控：elapsed0.1676579秒、stdout612 UTF8 bytes、stderr93 UTF8 bytes、TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False、START_COUNT=1。硬60秒、异步双流逐块UTF8累计各32KiB门实际实现；回显完整，未截断。

```text
STDOUT_BEGIN
FROZEN_SOURCE aar_entry_materials.py BYTES 20338 SHA256 B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7
FROZEN_SOURCE test_aar_entry_materials.py BYTES 74376 SHA256 F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2
INDEPENDENT_EXPECTED_FULL repo-block BYTES 642 SHA256 6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17
INDEPENDENT_EXPECTED_FULL tasks-full BYTES 11437 SHA256 B951D53A72DA69E88FBBAB601EE83DE77AB5220E5458B55D4E3EB95ED683A20A
INDEPENDENT_EXPECTED_FULL init-full BYTES 12709 SHA256 C85D24FDDBBCC05F296FA56E16BEF7187EF316B45969DB6BEC5C31605B347C05
STDERR_BEGIN
Traceback (most recent call last):
  File "<string>", line 78, in <module>
AssertionError
MONITOR EXIT=1 ELAPSED_SECONDS=0.1676579 STDOUT_UTF8_BYTES=612 STDERR_UTF8_BYTES=93 TIMEOUT=False OUTPUT_LIMIT_EXCEEDED=False START_COUNT=1
```

首个失败为本轮静态检查脚本的AssertionError，不是hash漂移、超时、输出超量或生产测试断言。没有执行进一步排查/替代检查；本summary不推定源码算法正确或错误，也不把该失败称M5-30原编排错误复跑。精确失败原因需要Work结合同次完整检查脚本与候选源码独立审查，当前不扩大读取或补跑。

## 覆盖、测试与关闭预算

原fixture/expected内嵌及三个完整scratch期望字节的hash检查已到达并打印上面结果；它们只是独立预期字节的身份，不证明实际转换结果与它们相等。P1/P2全返回字段、实际scratch结果及负例行为均未运行。静态12个test_方法统计及最终coverage PASS标记未回显，保持NOT_CHECKED，不能报12 methods静态PASS或0 tests PASS。

新静态1/1已耗尽，子进程启动1次/exit1；新测试0/1未启动，并在本任务终止门关闭，不转用或自行恢复。实际testsRun、测试exit/elapsed/stdout/stderr/timeout/超量均UNKNOWN / NOT_CHECKED。只有静态检查通过才可测试的前置条件未满足；本轮不再执行任何验证。需要后续授权由Work另立明确预算，不重置本任务或旧预算。

无来源准备重做、SDK或三份旧来源回执读取；无生产算法/测试fixture/scratch执行、Kotlin/Groovy/Gradle/Flutter/JVM/ADB/构建安装启动/UAC、源码/旧summary/authority/旧证据修改、目录搜索索引/下载复制、真实SDK/config/cache/env/home/properties/metadata/engine/plugin材料或旧D:\EliteSync/真实数据/备份密钥/生产DB/API/SSH访问，Git无commit/pull/push/reset/clean/stash。

仅冻结候选及精确首失败证据交付，停Work独立LEVEL2，不自接受/后继。真实Gradle/AGP、TaskAction/registrant、helper最终配置、POM/真实输入/manifest/OS隔离未证；M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与真实账号/Conversation/恢复/UAC等全部保护门保持。
